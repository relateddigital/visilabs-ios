//
//  VisilabsKeychain.swift
//  VisilabsIOS
//

import Foundation
import Security

final class VisilabsKeychain {

    private static let defaultService = (Bundle.main.bundleIdentifier ?? "com.relateddigital.visilabs") + ".keychain"

    @discardableResult
    static func set(_ value: String,
                    forKey key: String,
                    service: String = defaultService,
                    thisDeviceOnly: Bool = true) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Önce mevcut bir kayıt varsa sil
        delete(key, service: service)

        let accessibility = thisDeviceOnly
            ? kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            : kSecAttrAccessibleAfterFirstUnlock

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: accessibility
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            VisilabsLogger.warn("VisilabsKeychain: Failed to save key '\(key)' with status \(status)")
            return false
        }
        return true
    }

    static func get(_ key: String,
                    service: String = defaultService) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess, let data = dataTypeRef as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    static func delete(_ key: String,
                       service: String = defaultService) -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
