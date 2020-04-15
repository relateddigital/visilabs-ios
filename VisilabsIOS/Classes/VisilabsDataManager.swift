//
//  VisilabsDataManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 16.04.2020.
//

import Foundation

class VisilabsDataManager {
    
    class func save(_ key: String?, withObject value: Any?) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key ?? "")
        defaults.synchronize()
    }

    class func read(_ key: String?) -> Any? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key ?? "")
    }

    class func remove(_ key: String?) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key ?? "")
        defaults.synchronize()
    }
    
}
