//
//  VisilabsDataManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 16.04.2020.
//

import Foundation

class VisilabsDataManager {
    
    static func save(_ key: String, withObject value: Any?) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func read(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }

    static func remove(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
}
