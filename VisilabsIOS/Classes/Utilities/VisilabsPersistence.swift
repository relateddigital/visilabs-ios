//
//  VisilabsPersistence.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import Foundation

class VisilabsPersistence {
    
    // MARK: - ARCHIVE
    
    private static let archiveQueueUtility = DispatchQueue(label: "com.relateddigital.archiveQueue", qos: .utility)
    
    private class func filePath(filename: String) -> String? {
        let manager = FileManager.default
        let url = manager.urls(for: .libraryDirectory, in: .userDomainMask).last
        guard let urlUnwrapped = url?.appendingPathComponent(filename).path else {
            return nil
        }
        return urlUnwrapped
    }

    class func archiveUser(_ visilabsUser: VisilabsUser) {
        archiveQueueUtility.sync { [visilabsUser] in
            let propertiesFilePath = filePath(filename: VisilabsConstants.USER_ARCHIVE_KEY)
            guard let path = propertiesFilePath else {
                VisilabsLogger.error("bad file path, cant fetch file")
                return
            }
            var userDic = [String : String?]()
            userDic[VisilabsConstants.COOKIEID_KEY] = visilabsUser.cookieId
            userDic[VisilabsConstants.EXVISITORID_KEY] = visilabsUser.exVisitorId
            userDic[VisilabsConstants.APPID_KEY] = visilabsUser.appId
            userDic[VisilabsConstants.TOKENID_KEY] = visilabsUser.tokenId
            userDic[VisilabsConstants.USERAGENT_KEY] = visilabsUser.userAgent
            userDic[VisilabsConstants.VISITOR_CAPPING_KEY] = visilabsUser.visitorData
            userDic[VisilabsConstants.VISITORDATA] = visilabsUser.visitorData
            userDic[VisilabsConstants.MOBILEADID_KEY] = visilabsUser.identifierForAdvertising
            
            VisilabsExceptionWrapper.try({ [cObject = userDic, cPath = path] in
                if !NSKeyedArchiver.archiveRootObject(cObject, toFile: cPath) {
                    VisilabsLogger.error("failed to archive user")
                    return
                }
            }, catch: { (error) in
                VisilabsLogger.error("failed to archive user due to an uncaught exception")
                VisilabsLogger.error(error.debugDescription)
                return
            }, finally: {})
        }
    }
    
    //TODO: bunu ExceptionWrapper içine al
    class func unarchiveUser() -> VisilabsUser {
        var visilabsUser = VisilabsUser()
        
        //Before Visilabs.identity is used as archive key, to retrieve Visilabs.cookieID set by objective-c library we added this control.
        if let cidfp = filePath(filename: VisilabsConstants.IDENTITY_ARCHIVE_KEY), let cid = NSKeyedUnarchiver.unarchiveObject(withFile: cidfp) as? String {
            visilabsUser.cookieId = cid
        }else{
            VisilabsLogger.warn("Error while unarchiving cookieId.")
        }
        
        if let cidfp = filePath(filename: VisilabsConstants.COOKIEID_ARCHIVE_KEY), let cid = NSKeyedUnarchiver.unarchiveObject(withFile: cidfp) as? String {
            visilabsUser.cookieId = cid
        }else{
            VisilabsLogger.warn("Error while unarchiving cookieId.")
        }
        
        if let exvidfp = filePath(filename: VisilabsConstants.EXVISITORID_ARCHIVE_KEY), let exvid = NSKeyedUnarchiver.unarchiveObject(withFile: exvidfp) as? String {
            visilabsUser.exVisitorId = exvid
        }else{
            VisilabsLogger.warn("Error while unarchiving exVisitorId.")
        }
        
        if let appidfp = filePath(filename: VisilabsConstants.APPID_ARCHIVE_KEY), let aid = NSKeyedUnarchiver.unarchiveObject(withFile: appidfp) as? String {
            visilabsUser.appId = aid
        }else{
            VisilabsLogger.warn("Error while unarchiving appId.")
        }
        
        if let tidfp = filePath(filename: VisilabsConstants.TOKENID_ARCHIVE_KEY), let tid = NSKeyedUnarchiver.unarchiveObject(withFile: tidfp) as? String {
            visilabsUser.tokenId = tid
        }else{
            VisilabsLogger.warn("Error while unarchiving tokenID.")
        }
        
        if let uafp = filePath(filename: VisilabsConstants.USERAGENT_ARCHIVE_KEY), let ua = NSKeyedUnarchiver.unarchiveObject(withFile: uafp) as? String {
            visilabsUser.userAgent = ua
        }else{
            VisilabsLogger.warn("Error while unarchiving userAgent.")
        }
        
        if let propsfp = filePath(filename: VisilabsConstants.USER_ARCHIVE_KEY), let props = NSKeyedUnarchiver.unarchiveObject(withFile: propsfp) as? [String : String?] {
            
            if let cid = props[VisilabsConstants.COOKIEID_KEY], !cid.isNilOrWhiteSpace {
                visilabsUser.cookieId = cid
            }
            
            if let exvid = props[VisilabsConstants.EXVISITORID_KEY], !exvid.isNilOrWhiteSpace {
                visilabsUser.exVisitorId = exvid
            }
            
            if let aid = props[VisilabsConstants.APPID_KEY], !aid.isNilOrWhiteSpace {
                visilabsUser.appId = aid
            }
            
            if let tid = props[VisilabsConstants.TOKENID_KEY], !tid.isNilOrWhiteSpace {
                visilabsUser.tokenId = tid
            }
            
            if let ua = props[VisilabsConstants.USERAGENT_KEY], !ua.isNilOrWhiteSpace {
                visilabsUser.userAgent = ua
            }
            
            if let vd = props[VisilabsConstants.VISITORDATA], !vd.isNilOrWhiteSpace {
                visilabsUser.visitorData = vd
            }
            
            if let vd = props[VisilabsConstants.VISITOR_CAPPING_KEY], !vd.isNilOrWhiteSpace {
                visilabsUser.visitorData = vd
            }
            
            if let madid = props[VisilabsConstants.MOBILEADID_KEY], !madid.isNilOrWhiteSpace {
                visilabsUser.identifierForAdvertising = madid
            }
            
        }else{
            VisilabsLogger.warn("Visilabs: Error while unarchiving properties.")
        }

        return visilabsUser
    }
    
    
    //TODO: buradaki encode işlemleri doğru mu kontrol et, archiveQueue.sync { yerine archiveQueue.sync {[parameters] in
    class func saveParameters(_ parameters: [String : String]) {
        archiveQueueUtility.sync {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            
            for visilabsParameter in VisilabsConstants.visilabsParameters() {
                let key = visilabsParameter.key
                let storeKey = visilabsParameter.storeKey
                let relatedKeys = visilabsParameter.relatedKeys
                let count = visilabsParameter.count

                if let parameterValue = parameters[key], parameterValue.count > 0 {
                    if count == 1 {
                        if relatedKeys != nil && relatedKeys!.count > 0 {
                            var parameterValueToStore = parameterValue.copy() as! String
                            let relatedKey = relatedKeys![0]
                            if parameters[relatedKey] != nil {
                                let relatedKeyValue = (parameters[relatedKey])?.trimmingCharacters(in: CharacterSet.whitespaces)
                                parameterValueToStore = parameterValueToStore + ("|")
                                parameterValueToStore = parameterValueToStore + (relatedKeyValue ?? "")
                            } else {
                                parameterValueToStore = parameterValueToStore + ("|0")
                            }
                            parameterValueToStore = parameterValueToStore + (dateString)
                            saveUserDefaults(storeKey, withObject: parameterValueToStore)
                        } else {
                            saveUserDefaults(storeKey, withObject: parameterValue)
                        }
                    }
                    else if count > 1 {
                        let previousParameterValue = readUserDefaults(storeKey) as? String
                        var parameterValueToStore = parameterValue.copy() as! String + ("|")
                        parameterValueToStore = parameterValueToStore + (dateString)
                        if previousParameterValue != nil && previousParameterValue!.count > 0 {
                            let previousParameterValueParts = previousParameterValue!.components(separatedBy: "~")
                            for i in 0..<previousParameterValueParts.count {
                                if i == 9 {
                                    break
                                }
                                let decodedPreviousParameterValuePart = previousParameterValueParts[i] as String
                                //TODO:burayı kontrol et java'da "\\|" yapmak gerekiyordu.
                                let decodedPreviousParameterValuePartArray = decodedPreviousParameterValuePart.components(separatedBy: "|")
                                if decodedPreviousParameterValuePartArray.count == 2 {
                                    parameterValueToStore = parameterValueToStore + ("~")
                                    parameterValueToStore = parameterValueToStore + (decodedPreviousParameterValuePart )
                                }
                            }
                        }
                        saveUserDefaults(storeKey, withObject: parameterValueToStore)
                    }
                    
                }
            }
            
        }
    }
    
    class func getParameters() -> [String : String?] {
        var parameters: [String : String?] = [:]
        for visilabsParameter in VisilabsConstants.visilabsParameters() {
            let storeKey = visilabsParameter.storeKey
            let value = readUserDefaults(storeKey) as? String
            if value != nil && (value?.count ?? 0) > 0 {
                parameters[storeKey] = value
            }
        }
        return parameters
    }

    class func clearParameters() {
        for visilabsParameter in VisilabsConstants.visilabsParameters() {
            removeUserDefaults(visilabsParameter.storeKey)
        }
    }
    
    // MARK: - USER DEFAULTS
    
    
    static func saveUserDefaults(_ key: String, withObject value: Any?) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func readUserDefaults(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }

    static func removeUserDefaults(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func saveVisilabsProfile(_ visilabsProfile: VisilabsProfile) {
        let encoder = JSONEncoder()
        if let encodedVisilabsProfile = try? encoder.encode(visilabsProfile) {
            saveUserDefaults(VisilabsConstants.USER_DEFAULTS_PROFILE_KEY, withObject: encodedVisilabsProfile)
        }
    }
    
    static func readVisilabsProfile() -> VisilabsProfile? {
        if let savedVisilabsProfile = readUserDefaults(VisilabsConstants.USER_DEFAULTS_PROFILE_KEY) as? Data {
            let decoder = JSONDecoder()
            if let loadedVisilabsProfile = try? decoder.decode(VisilabsProfile.self, from: savedVisilabsProfile) {
                return loadedVisilabsProfile
            }
        }
        return nil
    }
    
    static func saveVisilabsGeofenceHistory(_ visilabsGeofenceHistory: VisilabsGeofenceHistory) {
        let encoder = JSONEncoder()
        if let encodedVisilabsGeofenceHistory = try? encoder.encode(visilabsGeofenceHistory) {
            saveUserDefaults(VisilabsConstants.USER_DEFAULTS_GEOFENCE_HISTORY_KEY, withObject: encodedVisilabsGeofenceHistory)
        }
    }
    
    public static func readVisilabsGeofenceHistory() -> VisilabsGeofenceHistory {
        if let savedVisilabsGeofenceHistory = readUserDefaults(VisilabsConstants.USER_DEFAULTS_GEOFENCE_HISTORY_KEY) as? Data {
            let decoder = JSONDecoder()
            if let loadedVisilabsGeofenceHistory = try? decoder.decode(VisilabsGeofenceHistory.self, from: savedVisilabsGeofenceHistory) {
                return loadedVisilabsGeofenceHistory
            }
        }
        return VisilabsGeofenceHistory()
    }
}
