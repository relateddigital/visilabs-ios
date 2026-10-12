//
//  VisilabsCapture.swift
//  VisilabsIOS
//

import Foundation
import UIKit

/// PostHog uyumlu `capture` altyapısı. posthog-ios'un kimlik, session ve uygulama yaşam döngüsü
/// davranışını taklit eder, event'leri `event.visilabs.net/batch/` adresine gönderir.
///
/// Kimlik akışı:
/// 1. İlk açılış: `distinct_id` = anonim UUIDv7.
/// 2. `login`/`signUp` (exVisitorId): `$identify` event'i `distinct_id` = exVisitorId ve
///    `$anon_distinct_id` = önceki anonim id ile gider. PostHog iki kimliği bu event'te birleştirir;
///    login öncesi anonim event'ler de kullanıcıya bağlanır. Sonraki tüm event'ler exVisitorId ile gider.
/// 3. `logout`: yeni anonim id + yeni session. `$device_id` değişmez.
final class VisilabsCapture {

    static let shared = VisilabsCapture()

    private let queue = DispatchQueue(label: "com.relateddigital.capture", qos: .utility)
    private let identity: VisilabsCaptureIdentity
    private let session = VisilabsCaptureSession()
    private let eventQueue: VisilabsCaptureQueue
    private var context: VisilabsCaptureContext?
    private var apiKey: String?

    // Uygulama yaşam döngüsü (posthog-ios `PostHogAppLifeCycleIntegration`)
    private var observers = [NSObjectProtocol]()
    private var isAppInBackground = true
    private var isFreshLaunch = true
    private var didRecordAppVersion = false

    private enum Key {
        static let appVersion = "VisilabsCapture.appVersion"
        static let appBuild = "VisilabsCapture.appBuild"
    }

    init(identity: VisilabsCaptureIdentity = VisilabsCaptureIdentity(), session urlSession: URLSession? = nil,
         directory: URL? = VisilabsCaptureQueue.defaultDirectory()) {
        self.identity = identity
        eventQueue = VisilabsCaptureQueue(dispatchQueue: queue, session: urlSession, directory: directory)
    }

    // MARK: - Kurulum

    /// `createAPI` her çağrıldığında çalışır. Tekrar çağrılması güvenlidir.
    /// - Parameters:
    ///   - exVisitorId: Visilabs'ta kayıtlı kullanıcı. SDK güncellemesinden önce login olmuş
    ///     kullanıcıların capture tarafında da tanınması için kullanılır.
    ///   - isExistingInstall: Visilabs daha önce bu cihazda çalıştıysa `true`. Capture özelliğini
    ///     içeren SDK sürümüne geçişte tüm mevcut kullanıcılar için sahte `Application Installed`
    ///     gönderilmesini engeller.
    func configure(apiKey: String?, exVisitorId: String?, isExistingInstall: Bool) {
        // App extension'ların UserDefaults'u uygulamadan ayrı; orada çalışırsa sahte
        // "Application Installed" ve ikinci bir anonim kimlik oluşur.
        guard !VisilabsHelper.isiOSAppExtension() else { return }
        let apiKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        if context == nil {
            context = VisilabsCaptureContext(sdkVersion: VisilabsConstants.sdkVersion)
            registerLifecycleObservers()
        }

        queue.async { [weak self] in
            guard let self = self else { return }
            self.apiKey = apiKey.isNilOrWhiteSpace ? nil : apiKey
            self.eventQueue.apiKey = self.apiKey
            let installOrUpdate = self.recordAppVersion(isExistingInstall: isExistingInstall)

            guard self.isEnabled else {
                VisilabsLogger.info("capture: captureApiKey verilmediği için capture kapalı.")
                return
            }

            if let exVisitorId = exVisitorId, !exVisitorId.isEmptyOrWhitespace {
                self.identifyOnQueue(exVisitorId, userProperties: nil, userPropertiesSetOnce: nil)
            }
            if let installOrUpdate = installOrUpdate {
                self.enqueue(installOrUpdate.event, properties: installOrUpdate.properties, timestamp: Date())
            }
            self.eventQueue.startTimer()
            self.eventQueue.flush()
        }

        // createAPI uygulama zaten açıkken çağrıldıysa didBecomeActive kaçmış olur.
        DispatchQueue.main.async { [weak self] in
            if VisilabsInstance.sharedUIApplication()?.applicationState == .active {
                self?.applicationDidBecomeActive()
            }
        }
    }

    private var isEnabled: Bool { apiKey != nil }

    // MARK: - Public API'nin karşılıkları

    func capture(_ event: String, properties: [String: Any]?) {
        let timestamp = Date()
        let trimmed = event.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            VisilabsLogger.error("capture: event adı boş olamaz.")
            return
        }
        let sanitized = VisilabsCaptureUtils.sanitize(properties)
        queue.async { [weak self] in
            guard let self = self else { return }
            guard self.isEnabled else {
                VisilabsLogger.warn("capture: createAPI'ye captureApiKey verilmediği için '\(trimmed)' gönderilmedi.")
                return
            }
            // Event içinde `$set` / `$set_once` varsa kişi profili işlenmeli (posthog-ios ile aynı).
            if sanitized["$set"] != nil || sanitized["$set_once"] != nil {
                self.identity.personProcessing = true
            }
            self.enqueue(trimmed, properties: sanitized, timestamp: timestamp)
        }
    }

    func identify(_ distinctId: String) {
        queue.async { [weak self] in
            guard let self = self, self.isEnabled else { return }
            self.identifyOnQueue(distinctId, userProperties: nil, userPropertiesSetOnce: nil)
        }
    }

    func setPersonProperties(_ properties: [String: Any], setOnce: [String: Any]) {
        let set = VisilabsCaptureUtils.sanitize(properties)
        let setOnce = VisilabsCaptureUtils.sanitize(setOnce)
        guard !set.isEmpty || !setOnce.isEmpty else { return }
        let timestamp = Date()
        queue.async { [weak self] in
            guard let self = self, self.isEnabled else { return }
            self.identity.personProcessing = true
            self.enqueue("$set", properties: [:], timestamp: timestamp,
                         userProperties: set, userPropertiesSetOnce: setOnce)
        }
    }

    /// Logout: yeni anonim kimlik ve yeni session.
    func reset() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.identity.reset()
            self.session.reset()
        }
    }

    func flush(completion: (() -> Void)? = nil) {
        queue.async { [weak self] in
            self?.eventQueue.flush(completion: completion)
        }
    }

    var distinctId: String { queue.sync { identity.distinctId } }
    var anonymousId: String { queue.sync { identity.anonymousId } }
    var deviceId: String { queue.sync { identity.deviceId } }

    // MARK: - Kimlik

    /// posthog-ios `identify` mantığı. Seri kuyrukta çalışmalı.
    private func identifyOnQueue(_ newDistinctId: String, userProperties: [String: Any]?, userPropertiesSetOnce: [String: Any]?) {
        let newDistinctId = newDistinctId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newDistinctId.isEmpty else { return }

        if identity.isIdentified && identity.distinctId != newDistinctId {
            // posthog-ios bu durumda hiçbir şey yapmaz (önce reset bekler). Visilabs'ta exVisitorId
            // değişince yeni ziyaretçi kabul edildiği için burada da önce kimlik sıfırlanıyor;
            // böylece iki farklı kullanıcı aynı kişi profilinde birleşmez.
            VisilabsLogger.info("capture: farklı bir kullanıcı ile login, kimlik sıfırlanıyor.")
            identity.reset()
            session.reset()
        }

        let previousDistinctId = identity.distinctId
        if !identity.isIdentified && previousDistinctId != newDistinctId {
            identity.distinctId = newDistinctId
            identity.isIdentified = true
            identity.personProcessing = true
            // PostHog anonim ve tanımlı kişiyi sadece `$identify` event'indeki `$anon_distinct_id`
            // ile birleştirir. Başka event'lere `$anon_distinct_id` eklemenin etkisi yoktur.
            enqueue("$identify",
                    properties: ["distinct_id": newDistinctId, "$anon_distinct_id": previousDistinctId],
                    timestamp: Date(),
                    userProperties: userProperties,
                    userPropertiesSetOnce: userPropertiesSetOnce)
        } else if !identity.isIdentified {
            // Anonim id ile aynı değerle identify edildi: birleştirilecek başka kimlik yok.
            identity.isIdentified = true
            identity.personProcessing = true
            enqueue("$set", properties: [:], timestamp: Date(),
                    userProperties: userProperties ?? [:], userPropertiesSetOnce: userPropertiesSetOnce)
        }
        // Aynı kullanıcıyla tekrar login: bir şey yapmaya gerek yok.
    }

    // MARK: - Event oluşturma

    /// Seri kuyrukta çalışmalı.
    private func enqueue(_ event: String,
                         properties: [String: Any],
                         timestamp: Date,
                         userProperties: [String: Any]? = nil,
                         userPropertiesSetOnce: [String: Any]? = nil) {
        let distinctId = identity.distinctId
        var props = context?.staticProperties ?? [:]
        props.merge(context?.dynamicProperties() ?? [:]) { _, new in new }
        props["$device_id"] = identity.deviceId
        props["$session_id"] = session.sessionId(at: timestamp)
        props["$is_identified"] = identity.isIdentified
        // posthog-ios varsayılanı (`personProfiles: .identifiedOnly`): anonim kullanıcılar için kişi
        // profili oluşturulmaz, event'leri daha ucuzdur. identify sonrası anonim event'ler yine kişiye bağlanır.
        props["$process_person_profile"] = identity.isIdentified || identity.personProcessing
        if let userProperties = userProperties {
            props["$set"] = userProperties
        }
        if let userPropertiesSetOnce = userPropertiesSetOnce {
            props["$set_once"] = userPropertiesSetOnce
        }
        // Event'in kendi alanları context'i ezer.
        props.merge(properties) { _, new in new }

        eventQueue.add([
            "event": event,
            "distinct_id": distinctId,
            "properties": props,
            "timestamp": VisilabsCaptureUtils.iso8601String(timestamp),
            // PostHog aynı uuid'li event'i tekrar yazmaz; yeniden denemelerde çift kayıt oluşmaz.
            "uuid": VisilabsCaptureUtils.uuidV7(at: timestamp)
        ])
    }

    // MARK: - Uygulama yaşam döngüsü

    /// `Application Installed` / `Application Updated` kararını verir ve sürümü kaydeder.
    /// Capture kapalıyken de sürüm kaydedilir; ileride açıldığında yanlış "Installed" gitmez.
    private func recordAppVersion(isExistingInstall: Bool) -> (event: String, properties: [String: Any])? {
        guard !didRecordAppVersion else { return nil }
        didRecordAppVersion = true

        let defaults = UserDefaults.standard
        let info = Bundle.main.infoDictionary ?? [:]
        let version = info["CFBundleShortVersionString"] as? String
        let build = info["CFBundleVersion"] as? String
        let previousVersion = defaults.string(forKey: Key.appVersion)
        let previousBuild = defaults.string(forKey: Key.appBuild)
        defaults.set(version, forKey: Key.appVersion)
        defaults.set(build, forKey: Key.appBuild)

        var properties = [String: Any]()
        properties["version"] = version
        properties["build"] = VisilabsCaptureUtils.parseBundleVersion(build)

        if previousVersion == nil && previousBuild == nil {
            if isExistingInstall {
                return nil
            }
            return ("Application Installed", properties)
        }
        if previousVersion == version && previousBuild == build {
            return nil
        }
        properties["previous_version"] = previousVersion
        properties["previous_build"] = VisilabsCaptureUtils.parseBundleVersion(previousBuild)
        return ("Application Updated", properties)
    }

    private func registerLifecycleObservers() {
        guard !VisilabsHelper.isiOSAppExtension() else { return }
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                            object: nil, queue: .main) { [weak self] _ in
            self?.applicationDidBecomeActive()
        })
        observers.append(center.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                            object: nil, queue: .main) { [weak self] _ in
            self?.applicationDidEnterBackground()
        })
    }

    /// Main thread. Kontrol merkezi / sistem uyarısı gibi `willResignActive` → `didBecomeActive`
    /// geçişlerinde tekrar event atmamak için sadece arka plandan dönüşte sayılır.
    private func applicationDidBecomeActive() {
        guard isAppInBackground else { return }
        isAppInBackground = false

        var properties: [String: Any] = ["from_background": !isFreshLaunch]
        if isFreshLaunch {
            let info = Bundle.main.infoDictionary ?? [:]
            properties["version"] = info["CFBundleShortVersionString"] as? String
            properties["build"] = VisilabsCaptureUtils.parseBundleVersion(info["CFBundleVersion"] as? String)
            isFreshLaunch = false
        }
        let timestamp = Date()
        queue.async { [weak self] in
            guard let self = self, self.isEnabled else { return }
            self.enqueue("Application Opened", properties: properties, timestamp: timestamp)
            self.eventQueue.flush()
        }
    }

    /// Main thread. Arka plana geçerken kuyruk boşaltılır; uygulama askıya alınmadan
    /// istek tamamlanabilsin diye background task açılır.
    private func applicationDidEnterBackground() {
        guard !isAppInBackground else { return }
        isAppInBackground = true

        let application = VisilabsInstance.sharedUIApplication()
        var taskId = UIBackgroundTaskIdentifier.invalid
        let endTask = {
            DispatchQueue.main.async {
                if taskId != .invalid {
                    application?.endBackgroundTask(taskId)
                    taskId = .invalid
                }
            }
        }
        taskId = application?.beginBackgroundTask(withName: "VisilabsCaptureFlush", expirationHandler: endTask) ?? .invalid

        let timestamp = Date()
        queue.async { [weak self] in
            guard let self = self, self.isEnabled else {
                endTask()
                return
            }
            self.enqueue("Application Backgrounded", properties: [:], timestamp: timestamp)
            self.eventQueue.flush(completion: endTask)
        }
    }
}
