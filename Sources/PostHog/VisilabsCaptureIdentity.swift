//
//  VisilabsCaptureIdentity.swift
//  VisilabsIOS
//

import Foundation

/// posthog-ios `PostHogStorageManager` karşılığı. Üç farklı kimlik var:
///
/// - `anonymousId`: İlk açılışta üretilen UUIDv7. Kullanıcı login olana kadar `distinct_id` budur.
///   `reset()` (logout) ile yenilenir.
/// - `distinctId`: Event'lerin gittiği kişi. Login öncesi `anonymousId`, login sonrası exVisitorId.
/// - `deviceId` (`$device_id`): Kurulum başına sabit; login/logout'tan etkilenmez, sadece
///   uygulama silinip yüklenince değişir.
///
/// Sadece `VisilabsCapture`'ın seri kuyruğundan erişilir, bu yüzden kilit yok.
final class VisilabsCaptureIdentity {

    private enum Key {
        static let anonymousId = "VisilabsCapture.anonymousId"
        static let distinctId = "VisilabsCapture.distinctId"
        static let deviceId = "VisilabsCapture.deviceId"
        static let isIdentified = "VisilabsCapture.isIdentified"
        static let personProcessing = "VisilabsCapture.personProcessing"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var anonymousId: String {
        get {
            if let existing = defaults.string(forKey: Key.anonymousId), !existing.isEmpty {
                return existing
            }
            let generated = VisilabsCaptureUtils.uuidV7()
            defaults.set(generated, forKey: Key.anonymousId)
            return generated
        }
        set { defaults.set(newValue, forKey: Key.anonymousId) }
    }

    var distinctId: String {
        get {
            if let existing = defaults.string(forKey: Key.distinctId), !existing.isEmpty {
                return existing
            }
            return anonymousId
        }
        set { defaults.set(newValue, forKey: Key.distinctId) }
    }

    var deviceId: String {
        if let existing = defaults.string(forKey: Key.deviceId), !existing.isEmpty {
            return existing
        }
        let seeded = anonymousId
        defaults.set(seeded, forKey: Key.deviceId)
        return seeded
    }

    var isIdentified: Bool {
        get { defaults.bool(forKey: Key.isIdentified) }
        set { defaults.set(newValue, forKey: Key.isIdentified) }
    }

    /// Anonim kullanıcı için `setPersonProperties` çağrıldığında açılır; o andan itibaren
    /// event'ler `$process_person_profile: true` ile gider.
    var personProcessing: Bool {
        get { defaults.bool(forKey: Key.personProcessing) }
        set { defaults.set(newValue, forKey: Key.personProcessing) }
    }

    /// Logout: yeni anonim kimlik. `deviceId` korunur.
    func reset() {
        _ = deviceId
        defaults.removeObject(forKey: Key.distinctId)
        defaults.removeObject(forKey: Key.isIdentified)
        defaults.removeObject(forKey: Key.personProcessing)
        defaults.set(VisilabsCaptureUtils.uuidV7(), forKey: Key.anonymousId)
    }
}

/// posthog-ios `PostHogSessionManager` karşılığı: 30 dk hareketsizlikte veya 24 saati
/// geçince yeni `$session_id` (UUIDv7). posthog-ios gibi bellekte tutulur; soğuk açılış yeni session'dır.
final class VisilabsCaptureSession {

    static let inactivityTimeout: TimeInterval = 30 * 60
    static let maxLength: TimeInterval = 24 * 60 * 60

    private var sessionId: String?
    private var startedAt: Date?
    private var lastActivityAt: Date?

    func sessionId(at date: Date) -> String {
        if let sessionId = sessionId, let startedAt = startedAt, let lastActivityAt = lastActivityAt,
           date.timeIntervalSince(lastActivityAt) < VisilabsCaptureSession.inactivityTimeout,
           date.timeIntervalSince(startedAt) < VisilabsCaptureSession.maxLength {
            self.lastActivityAt = max(lastActivityAt, date)
            return sessionId
        }
        // UUIDv7'nin zaman kısmı session'ın ilk event'inden sonra olmamalı; event zamanıyla üretiliyor.
        let newSessionId = VisilabsCaptureUtils.uuidV7(at: date)
        sessionId = newSessionId
        startedAt = date
        lastActivityAt = date
        return newSessionId
    }

    func reset() {
        sessionId = nil
        startedAt = nil
        lastActivityAt = nil
    }
}
