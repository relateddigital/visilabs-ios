//
//  VisilabsInstallTracker.swift
//  VisilabsIOS
//

import Foundation
import StoreKit

public enum VisilabsInstallType: String {
    case firstInstall = "first_install"
    case reinstall = "reinstall"
}

public final class VisilabsInstallTracker {

    public static let shared = VisilabsInstallTracker()

    private let lock = NSLock()
    private var _initialInstallType: VisilabsInstallType = .firstInstall
    private var _isStoreKitEvaluated = false

    /// Bu cihaz kurulumunun ilk kez mi yoksa reinstall mi olduğunu döner.
    public var initialInstallType: VisilabsInstallType {
        lock.lock()
        defer { lock.unlock() }
        return _initialInstallType
    }

    /// İlk kurulumun ilk oturumunda olup olmadığını döner (veya ilk indirme durumu).
    public var isFirstInstall: Bool {
        return initialInstallType == .firstInstall
    }

    /// Yeniden kurulum durumunda olup olmadığını döner.
    public var isReinstall: Bool {
        return initialInstallType == .reinstall
    }

    public var isFirstInstallString: String {
        return isFirstInstall ? "1" : "0"
    }

    public var isReinstallString: String {
        return isReinstall ? "1" : "0"
    }

    private init() {
        evaluateInstallStatus()
        evaluateStoreKitAccountPurchaseIfAvailable()
    }

    /// Cihaz düzeyinde Keychain ve UserDefaults kıyası ile ilk kurulum / reinstall tespitini yapar.
    private func evaluateInstallStatus() {
        lock.lock()
        defer { lock.unlock() }

        let defaults = UserDefaults.standard
        let hasUserDefaultsInstall = defaults.bool(forKey: VisilabsConstants.userDefaultsInstalledKey)
        let keychainInstalled = VisilabsKeychain.get(VisilabsConstants.keychainInstalledKey)

        if hasUserDefaultsInstall {
            // Bu kurulum daha önce tespit edilmiş (normal sonraki açılışlar)
            if let savedTypeRaw = defaults.string(forKey: VisilabsConstants.userDefaultsInstallTypeKey),
               let savedType = VisilabsInstallType(rawValue: savedTypeRaw) {
                _initialInstallType = savedType
            } else {
                _initialInstallType = (keychainInstalled == "true") ? .reinstall : .firstInstall
            }
            return
        }

        // UserDefaults boş -> Uygulama ya ilk kez açılıyor ya da silinip tekrar indirilmiş!
        if keychainInstalled == "true" {
            // Keychain'de kayıt var ama UserDefaults boş -> REINSTALL!
            _initialInstallType = .reinstall
            VisilabsLogger.info("VisilabsInstallTracker: App reinstall detected via Keychain.")
        } else {
            // Ne Keychain'de ne UserDefaults'ta kayıt yok -> FIRST INSTALL!
            _initialInstallType = .firstInstall
            VisilabsLogger.info("VisilabsInstallTracker: First install detected.")

            // Gelecekteki reinstall'ları yakalayabilmek için Keychain'e yaz
            VisilabsKeychain.set("true", forKey: VisilabsConstants.keychainInstalledKey)
            let isoDate = VisilabsHelper.formatDate(Date())
            VisilabsKeychain.set(isoDate, forKey: VisilabsConstants.keychainInstallDateKey)
        }

        // Mevcut kurulum için UserDefaults'a kaydet
        defaults.set(true, forKey: VisilabsConstants.userDefaultsInstalledKey)
        defaults.set(_initialInstallType.rawValue, forKey: VisilabsConstants.userDefaultsInstallTypeKey)
        defaults.synchronize()
    }

    /// StoreKit 2 (iOS 16.0+) üzerinden Apple ID seviyesinde daha önce satın alma/indirme olup olmadığını inceler.
    /// Kullanıcı yeni telefon almış olsa dahi, Apple ID'de bu uygulama daha önce indirilmişse reinstall olarak işaretler.
    private func evaluateStoreKitAccountPurchaseIfAvailable() {
        if #available(iOS 16.0, *) {
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let verificationResult = try await AppTransaction.shared
                    switch verificationResult {
                    case .verified(let appTransaction):
                        let originalPurchaseDate = appTransaction.originalPurchaseDate
                        // Eğer Apple ID satın alma tarihi kurulum anından en az 1 saat eskiyse,
                        // bu Apple ID başka/eski bir cihazda bu uygulamayı daha önce edinmiş demektir.
                        let now = Date()
                        if now.timeIntervalSince(originalPurchaseDate) > 3600 {
                            self.markAsReinstallFromStoreKit(originalDate: originalPurchaseDate)
                        }
                    case .unverified(_, let error):
                        VisilabsLogger.warn("VisilabsInstallTracker: StoreKit AppTransaction unverified: \(error)")
                    }
                } catch {
                    VisilabsLogger.warn("VisilabsInstallTracker: StoreKit AppTransaction fetch error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func markAsReinstallFromStoreKit(originalDate: Date) {
        lock.lock()
        defer { lock.unlock() }

        if _initialInstallType != .reinstall {
            _initialInstallType = .reinstall
            VisilabsLogger.info("VisilabsInstallTracker: StoreKit 2 detected prior purchase on Apple ID (\(originalDate)). Updated to reinstall.")

            let defaults = UserDefaults.standard
            defaults.set(VisilabsInstallType.reinstall.rawValue, forKey: VisilabsConstants.userDefaultsInstallTypeKey)
            defaults.synchronize()

            VisilabsKeychain.set("true", forKey: VisilabsConstants.keychainInstalledKey)
        }
    }

    /// customEvent içerisine eklenecek OM.is_first_install değerini belirler.
    /// İlk kurulumun ilk oturumunda (tvc <= 1) "1", sonraki oturumlarda veya reinstall ise "0" döner.
    public func isFirstInstallValue(tvc: Int) -> String {
        lock.lock()
        defer { lock.unlock() }
        if _initialInstallType == .firstInstall && tvc <= 1 {
            return "1"
        }
        return "0"
    }

    /// customEvent içerisine eklenecek OM.is_reinstall değerini belirler.
    /// Reinstall durumunun ilk oturumunda (tvc <= 1) "1", sonraki oturumlarda veya ilk kurulum ise "0" döner.
    public func isReinstallValue(tvc: Int) -> String {
        lock.lock()
        defer { lock.unlock() }
        if _initialInstallType == .reinstall && tvc <= 1 {
            return "1"
        }
        return "0"
    }

    /// Test / Debug amaçlı sıfırlama metodu
    public func resetForTesting() {
        lock.lock()
        defer { lock.unlock() }
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: VisilabsConstants.userDefaultsInstalledKey)
        defaults.removeObject(forKey: VisilabsConstants.userDefaultsInstallTypeKey)
        defaults.synchronize()
        VisilabsKeychain.delete(VisilabsConstants.keychainInstalledKey)
        VisilabsKeychain.delete(VisilabsConstants.keychainInstallDateKey)
        _initialInstallType = .firstInstall
    }
}
