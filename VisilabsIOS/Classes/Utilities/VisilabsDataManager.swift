//
//  VisilabsDataManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 16.04.2020.
//

import Foundation

class VisilabsDataManager {
    
    static func saveVisilabsProfile(_ visilabsProfile: VisilabsProfile) {
        let encoder = JSONEncoder()
        if let encodedVisilabsProfile = try? encoder.encode(visilabsProfile) {
            save(VisilabsConstants.USER_DEFAULTS_PROFILE_KEY, withObject: encodedVisilabsProfile)
        }
    }
    
    static func readVisilabsProfile() -> VisilabsProfile? {
        if let savedVisilabsProfile = read(VisilabsConstants.USER_DEFAULTS_PROFILE_KEY) as? Data {
            let decoder = JSONDecoder()
            if let loadedVisilabsProfile = try? decoder.decode(VisilabsProfile.self, from: savedVisilabsProfile) {
                return loadedVisilabsProfile
            }
        }
        return nil
    }
    
    static func saveVisilabsUser(_ visilabsUser: VisilabsUser) {
        let encoder = JSONEncoder()
        if let encodedVisilabsUser = try? encoder.encode(visilabsUser) {
            save(VisilabsConstants.USER_DEFAULTS_USER_KEY, withObject: encodedVisilabsUser)
        }
    }
    
    static func readVisilabsUser() -> VisilabsUser? {
        if let savedVisilabsUser = read(VisilabsConstants.USER_DEFAULTS_USER_KEY) as? Data {
            let decoder = JSONDecoder()
            if let loadedVisilabsUser = try? decoder.decode(VisilabsUser.self, from: savedVisilabsUser) {
                return loadedVisilabsUser
            }
        }
        return nil
    }
    
    static func saveVisilabsGeofenceHistory(_ visilabsGeofenceHistory: VisilabsGeofenceHistory) {
        let encoder = JSONEncoder()
        if let encodedVisilabsGeofenceHistory = try? encoder.encode(visilabsGeofenceHistory) {
            save(VisilabsConstants.USER_DEFAULTS_GEOFENCE_HISTORY_KEY, withObject: encodedVisilabsGeofenceHistory)
        }
    }
    
    static func readVisilabsGeofenceHistory() -> VisilabsGeofenceHistory? {
        if let savedVisilabsGeofenceHistory = read(VisilabsConstants.USER_DEFAULTS_GEOFENCE_HISTORY_KEY) as? Data {
            let decoder = JSONDecoder()
            if let loadedVisilabsGeofenceHistory = try? decoder.decode(VisilabsGeofenceHistory.self, from: savedVisilabsGeofenceHistory) {
                return loadedVisilabsGeofenceHistory
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
