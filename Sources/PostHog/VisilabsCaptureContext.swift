//
//  VisilabsCaptureContext.swift
//  VisilabsIOS
//

import Foundation
import Network
import UIKit

/// Her capture event'ine otomatik eklenen `$` property'leri.
/// Anahtar isimleri posthog-ios `PostHogContext.swift` ile aynı tutuldu; PostHog arayüzündeki
/// OS / Device Type / Library kolonları bu isimleri okuyor.
final class VisilabsCaptureContext {

    static let libName = "visilabs-ios"

    /// Uygulama ömrü boyunca değişmeyen değerler.
    let staticProperties: [String: Any]

    private let lock = NSLock()
    private var screenSize: CGSize?
    private var isWiFi: Bool?
    private var isCellular: Bool?
    private let pathMonitor = NWPathMonitor()
    private var observers = [NSObjectProtocol]()

    init(sdkVersion: String) {
        staticProperties = VisilabsCaptureContext.buildStaticProperties(sdkVersion: sdkVersion)

        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let satisfied = path.status == .satisfied
            self.lock.lock()
            self.isWiFi = satisfied && path.usesInterfaceType(.wifi)
            self.isCellular = satisfied && path.usesInterfaceType(.cellular)
            self.lock.unlock()
        }
        pathMonitor.start(queue: DispatchQueue(label: "com.relateddigital.capture.network", qos: .utility))

        let center = NotificationCenter.default
        for name in [UIApplication.didBecomeActiveNotification,
                     UIDevice.orientationDidChangeNotification,
                     UIWindow.didBecomeKeyNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.refreshScreenSize()
            })
        }
        if Thread.isMainThread {
            refreshScreenSize()
        } else {
            DispatchQueue.main.async { [weak self] in self?.refreshScreenSize() }
        }
    }

    deinit {
        pathMonitor.cancel()
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    /// Her event'te yeniden okunan değerler. Herhangi bir thread'den çağrılabilir.
    func dynamicProperties() -> [String: Any] {
        var properties: [String: Any] = [
            "$locale": VisilabsCaptureContext.localeIdentifier,
            "$timezone": TimeZone.current.identifier
        ]

        lock.lock()
        let screenSize = self.screenSize
        let isWiFi = self.isWiFi
        let isCellular = self.isCellular
        lock.unlock()

        if let screenSize = screenSize {
            properties["$screen_width"] = Int(screenSize.width)
            properties["$screen_height"] = Int(screenSize.height)
        }
        if let isWiFi = isWiFi, let isCellular = isCellular {
            properties["$network_wifi"] = isWiFi
            properties["$network_cellular"] = isCellular
        }
        return properties
    }

    /// Ekran boyutu UIKit'ten okunduğu için main thread'de güncellenip cache'leniyor.
    private func refreshScreenSize() {
        guard let size = VisilabsCaptureContext.currentWindowSize() else { return }
        lock.lock()
        screenSize = size
        lock.unlock()
    }

    private static func currentWindowSize() -> CGSize? {
        let scenes = VisilabsInstance.sharedUIApplication()?.connectedScenes.compactMap { $0 as? UIWindowScene } ?? []
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        if let scene = scene {
            let window = scene.windows.first { $0.isKeyWindow } ?? scene.windows.first
            return window?.bounds.size ?? scene.screen.bounds.size
        }
        return UIScreen.main.bounds.size
    }

    // MARK: - Statik context

    private static func buildStaticProperties(sdkVersion: String) -> [String: Any] {
        let info = Bundle.main.infoDictionary ?? [:]
        let device = UIDevice.current
        let isMac = isIOSAppOnMac || isMacCatalystApp
        let model = hardwareModel(isMac: isMac)

        var properties: [String: Any] = [
            "$lib": libName,
            "$lib_version": sdkVersion,
            "$device_manufacturer": "Apple",
            "$device_model": model,
            "$is_emulator": isSimulator,
            "$is_ios_running_on_mac": isIOSAppOnMac,
            "$is_mac_catalyst_app": isMacCatalystApp
        ]

        if let appName = (info[kCFBundleNameKey as String] ?? info["CFBundleDisplayName"]) as? String {
            properties["$app_name"] = appName
        }
        if let appVersion = info["CFBundleShortVersionString"] as? String {
            properties["$app_version"] = appVersion
        }
        if let appBuild = VisilabsCaptureUtils.parseBundleVersion(info["CFBundleVersion"] as? String) {
            properties["$app_build"] = appBuild
        }
        if let bundleId = Bundle.main.bundleIdentifier {
            properties["$app_namespace"] = bundleId
        }
        if let deviceType = deviceType(isMac: isMac) {
            properties["$device_type"] = deviceType
        }

        let osName: String
        if isMac {
            // Mac'te userInterfaceIdiom .pad döner, systemName de iOS'u gösterir; posthog-ios gibi macOS yazılıyor.
            osName = "macOS"
            properties["$os_version"] = macOSVersion
            properties["$device_name"] = "Mac"
        } else {
            osName = device.systemName
            properties["$os_version"] = device.systemVersion
            // iOS 16+ `UIDevice.name` entitlement olmadan zaten "iPhone" döner; posthog-ios `model` kullanıyor.
            properties["$device_name"] = device.model
        }
        // Mobil SDK'lar `$os_name`, web SDK'sı `$os` yazıyor; PostHog'daki iki filtre de çalışsın diye ikisi de gönderiliyor.
        properties["$os_name"] = osName
        properties["$os"] = osName

        return properties
    }

    /// "tr_TR" biçiminde; takvim vb. eklentiler (`@calendar=...`) dahil edilmiyor.
    private static var localeIdentifier: String {
        let locale = Locale.current
        guard let language = locale.languageCode else { return locale.identifier }
        if let region = locale.regionCode {
            return "\(language)_\(region)"
        }
        return language
    }

    private static func hardwareModel(isMac: Bool) -> String {
        #if targetEnvironment(simulator)
        if let identifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return identifier
        }
        #endif
        // Mac'te "hw.machine" alttaki iPad modelini döner, Mac modeli "hw.model"de.
        let name = isMac ? "hw.model" : "hw.machine"
        var size = 0
        sysctlbyname(name, nil, &size, nil, 0)
        guard size > 0 else { return "" }
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname(name, &machine, &size, nil, 0)
        return String(cString: machine)
    }

    private static func deviceType(isMac: Bool) -> String? {
        if isMac { return "Desktop" }
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return "Mobile"
        case .pad: return "Tablet"
        case .tv: return "TV"
        case .carPlay: return "CarPlay"
        case .mac: return "Desktop"
        default: return nil
        }
    }

    private static var macOSVersion: String {
        let versionString = ProcessInfo.processInfo.operatingSystemVersionString
        if let range = versionString.range(of: #"\d+\.\d+(\.\d+)?"#, options: .regularExpression) {
            return String(versionString[range])
        }
        return versionString
    }

    private static let isIOSAppOnMac: Bool = ProcessInfo.processInfo.isiOSAppOnMac

    private static let isMacCatalystApp: Bool = {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }()

    private static let isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
}
