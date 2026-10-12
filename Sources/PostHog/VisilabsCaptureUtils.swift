//
//  VisilabsCaptureUtils.swift
//  VisilabsIOS
//

import Foundation

enum VisilabsCaptureUtils {

    // MARK: - UUIDv7

    /// RFC 9562 UUIDv7: ilk 48 bit unix milisaniye, kalanı rastgele.
    /// PostHog `$session_id` için UUIDv7 şart koşuyor (aksi halde event session
    /// hesaplarına girmiyor). Zaman sıralı olduğu için kuyruk dosya adı olarak da kullanılıyor.
    static func uuidV7(at date: Date = Date()) -> String {
        let milliseconds = UInt64(max(0, date.timeIntervalSince1970) * 1000)
        var bytes = [UInt8](repeating: 0, count: 16)
        for index in 0..<6 {
            bytes[index] = UInt8(truncatingIfNeeded: milliseconds >> (8 * (5 - index)))
        }
        for index in 6..<16 {
            bytes[index] = UInt8.random(in: 0...255)
        }
        bytes[6] = (bytes[6] & 0x0F) | 0x70 // version 7
        bytes[8] = (bytes[8] & 0x3F) | 0x80 // RFC 4122 variant
        let uuid = UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
                               bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
        return uuid.uuidString.lowercased()
    }

    // MARK: - Tarih

    private static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()

    /// PostHog `timestamp` / `sent_at` alanları ISO 8601 bekliyor. Unix saniye string'i
    /// ("1790922526") HTTP 200 dönse de ingestion'da geçersiz sayılıp sunucu saatiyle değiştiriliyor.
    static func iso8601String(_ date: Date) -> String {
        iso8601Formatter.string(from: date)
    }

    // MARK: - Property temizleme

    /// Değerleri JSON'a yazılabilir hale getirir; desteklenmeyen tipler loglanıp atılır.
    static func sanitize(_ properties: [String: Any]?) -> [String: Any] {
        guard let properties = properties else { return [:] }
        var result = [String: Any]()
        for (key, value) in properties {
            if let sanitized = sanitizeValue(value) {
                result[key] = sanitized
            } else {
                VisilabsLogger.warn("capture: '\(key)' property'si desteklenmeyen tipte (\(type(of: value))), gönderilmeyecek.")
            }
        }
        return result
    }

    private static func sanitizeValue(_ value: Any) -> Any? {
        switch value {
        case let string as String:
            return string
        case let number as NSNumber:
            // NaN / Infinity JSONSerialization'ı patlatır.
            if let double = value as? Double, !double.isFinite { return nil }
            return number
        case let date as Date:
            return iso8601String(date)
        case let url as URL:
            return url.absoluteString
        case let uuid as UUID:
            return uuid.uuidString.lowercased()
        case is NSNull:
            return value
        case let array as [Any]:
            return array.compactMap { sanitizeValue($0) }
        case let dictionary as [String: Any]:
            return sanitize(dictionary)
        default:
            return nil
        }
    }

    /// CFBundleVersion sayıysa Int, değilse String (posthog-ios ile aynı).
    static func parseBundleVersion(_ value: String?) -> Any? {
        guard let value = value else { return nil }
        return Int(value) ?? value
    }
}
