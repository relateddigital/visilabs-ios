//
//  VisilabsJson.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

import Foundation

extension Data {
    func objectFromJSONData() -> Any? {
        return try? JSONSerialization.jsonObject(with: self as Data, options: .allowFragments)
    }
}

extension String {
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
