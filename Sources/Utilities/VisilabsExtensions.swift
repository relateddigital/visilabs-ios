//
//  VisilabsExtensions.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

import UIKit

/**
JSON convenient categories on NSString
*/
extension String {

    func contains(_ string: String, options: String.CompareOptions) -> Bool {
        let rng = (self as NSString).range(of: string, options: options)
        return rng.location != NSNotFound
    }

    func contains(_ string: String) -> Bool {
        return contains(string, options: [])
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
