//
//  DataManager.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 17.08.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

class DataManager {
    
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
