//
//  DataManager.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 17.08.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

class DataManager {

    static let visilabsProfileKey = "VisilabsProfile"

    static func saveVisilabsProfile(_ visilabsProfile: VisilabsProfile) {
        let encoder = JSONEncoder()
        if let encodedVisilabsProfile = try? encoder.encode(visilabsProfile) {
            save(visilabsProfileKey, withObject: encodedVisilabsProfile)
        }
    }

    static func readVisilabsProfile() -> VisilabsProfile? {
        if let savedVisilabsProfile = read(visilabsProfileKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedVisilabsProfile = try? decoder.decode(VisilabsProfile.self, from: savedVisilabsProfile) {
                return loadedVisilabsProfile
            }
        }
        return nil
    }

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
