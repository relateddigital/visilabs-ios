//
//  VisilabsJson.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

import Foundation

/**
Extensions to standard primitive and collections classes to support easier json
parsing. Internally, it uses the system provided 'NSJSONSerialization' class to perform
the actual json serialization/deserialization
*/

extension Data {
    func objectFromJSONData() -> Any? {
        return try? JSONSerialization.jsonObject(with: self as Data, options: .allowFragments)
    }
}

extension String {
    
    func stringBetweenString(start: String?, end: String?) -> String? {
        let startRange = (self as NSString).range(of: start ?? "")
        if startRange.location != NSNotFound {
            var targetRange: NSRange = NSRange()
            targetRange.location = startRange.location + startRange.length
            targetRange.length = count - targetRange.location
            let endRange = (self as NSString).range(of: end ?? "", options: [], range: targetRange)
            if endRange.location != NSNotFound {
                targetRange.length = endRange.location - targetRange.location
                return (self as NSString).substring(with: targetRange)
            }
        }
        return nil
    }

    func contains(_ string: String?, options: String.CompareOptions) -> Bool {
        let rng = (self as NSString).range(of: string ?? "", options: options)
        return rng.location != NSNotFound
    }

    func contains(_ string: String) -> Bool {
        return contains(string, options: [])
    }
    
    func objectFromJSONString() -> Any? {
        let data = self.data(using: .utf8)
        return data?.objectFromJSON()
    }
}

extension [AnyHashable] {
    func jsonString() -> String? {
        let data = jsonData()
        if data != nil {
            if let data = data {
                return String(data: data, encoding: .utf8)
            }
            return nil
        }

        return nil
    }

    func jsonData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

extension [AnyHashable : Any] {
    func jsonString() -> String? {
        let data = jsonData()
        if data != nil {
            if let data = data {
                return String(data: data, encoding: .utf8)
            }
            return nil
        }

        return nil
    }

    func jsonData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}
