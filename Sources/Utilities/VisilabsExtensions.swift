//
//  VisilabsExtensions.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

import UIKit

/**
Extensions to standard primitive and collections classes to support easier json
parsing. Internally, it uses the system provided 'NSJSONSerialization' class to perform
the actual json serialization/deserialization
*/

extension Data {
    func objectFromJsonData() -> Any? {
        return try? JSONSerialization.jsonObject(with: self as Data, options: .allowFragments)
    }
}

/**
JSON convenient categories on NSString
*/
extension String {

    //TO_DO:self as nsstring'e gerek var mı?
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

    func contains(_ string: String, options: String.CompareOptions) -> Bool {
        let rng = (self as NSString).range(of: string, options: options)
        return rng.location != NSNotFound
    }

    func contains(_ string: String) -> Bool {
        return contains(string, options: [])
    }

    //TO_DO:bunu kontrol et: objective-c'de pointer'lı bir şeyler kullanıyorduk
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }

    func urlDecode() -> String {
        return self.removingPercentEncoding ?? ""
    }

    func convertJsonStringToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }

    var isEmptyOrWhitespace: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /**
    Returns a Foundation object from the given JSON string.
     
    - returns: A Foundation object from the JSON string, or nil if an error occurs.
    */

    func objectFromJsonString() -> Any? {
        let data = self.data(using: .utf8)
        return data?.objectFromJsonData()
    }

    func getUrlWithoutExtension() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().absoluteString
    }

    func getUrlExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}

/**
JSON convenient extensions on NSArray
*/

extension Array {

    /**
    Returns JSON string from the given array.
    
    - returns: returns  a JSON String, or nil if an internal error occurs. The resulting data is an encoded in UTF-8.
    */

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

    /**
    Returns JSON data from the given array.
    
    - returns: returns a JSON data, or nil if an internal error occurs. The resulting data is an encoded in UTF-8.
    */

    func jsonData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

/**
JSON convenient extensions on Dictionary
*/

extension Dictionary {

    /**
    Returns JSON string from the given dictionary.
    
    - returns: returns a JSON String, or nil if an internal error occurs. The resulting data is an encoded in UTF-8.
    */

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

    /**
    Returns JSON data from the given dictionary.
    
    - returns:returns a JSON data, or nil if an internal error occurs. The resulting data is an encoded in UTF-8.
    */

    func jsonData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

extension Optional where Wrapped == String {

    var isNilOrWhiteSpace: Bool {
        return self?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
    }

}

extension Optional where Wrapped == [String] {
    mutating func mergeStringArray(_ newArray: [String]) {
        self = self ?? [String]()
        for newArrayElement in newArray {
            if !self!.contains(newArrayElement) {
                self!.append(newArrayElement)
            }
        }
    }
}

extension Int {
    var toFloat: CGFloat {
        return CGFloat(self)
    }
}
