//
//  VisilabsPersistence.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import Foundation

class VisilabsPersistence {
    
    private static let archiveQueue: DispatchQueue = DispatchQueue(label: "com.relateddigital.archiveQueue", qos: .utility)
    
    private class func filePath(filename: String) -> String? {
        let manager = FileManager.default
        let url = manager.urls(for: .libraryDirectory, in: .userDomainMask).last
        guard let urlUnwrapped = url?.appendingPathComponent(filename).path else {
            return nil
        }
        return urlUnwrapped
    }

    
    //TODO: bunu ExceptionWrapper içine al
    class func unarchive() -> (cookieId: String?, exVisitorId: String?, appId: String?, tokenId: String?, userAgent: String?, visitorData: String?, mobileAdId: String?){
        var cookieId: String?
        var exVisitorId: String?
        var appId: String?
        var tokenId: String?
        var userAgent: String?
        var visitorData: String?
        var mobileAdId: String?
        
        //Before Visilabs.identity is used as archive key, to retrieve Visilabs.cookieID set by objective-c library we added this control.
        if let cidfp = filePath(filename: VisilabsConfig.IDENTITY_ARCHIVE_KEY), let cid = NSKeyedUnarchiver.unarchiveObject(withFile: cidfp) as? String {
            cookieId = cid
        }else{
            VisilabsLogger.warn(message: "Visilabs: Error while unarchiving cookieId.")
        }
        
        if let cidfp = filePath(filename: VisilabsConfig.COOKIEID_ARCHIVE_KEY), let cid = NSKeyedUnarchiver.unarchiveObject(withFile: cidfp) as? String {
            cookieId = cid
        }else{
            VisilabsLogger.warn(message: "Visilabs: Error while unarchiving cookieId.")
        }
        
        if let exvidfp = filePath(filename: VisilabsConfig.EXVISITORID_ARCHIVE_KEY), let exvid = NSKeyedUnarchiver.unarchiveObject(withFile: exvidfp) as? String {
            exVisitorId = exvid
        }else{
            VisilabsLogger.warn(message: "Visilabs: Error while unarchiving exVisitorId.")
        }
        
        if let appidfp = filePath(filename: VisilabsConfig.APPID_ARCHIVE_KEY), let aid = NSKeyedUnarchiver.unarchiveObject(withFile: appidfp) as? String {
            appId = aid
        }else{
            VisilabsLogger.warn(message: "Visilabs: Error while unarchiving appId.")
        }
        
        if let tidfp = filePath(filename: VisilabsConfig.TOKENID_ARCHIVE_KEY), let tid = NSKeyedUnarchiver.unarchiveObject(withFile: tidfp) as? String {
            tokenId = tid
        }else{
            VisilabsLogger.warn(message: "Visilabs: Error while unarchiving tokenID.")
        }
        
        if let uafp = filePath(filename: VisilabsConfig.USERAGENT_ARCHIVE_KEY), let ua = NSKeyedUnarchiver.unarchiveObject(withFile: uafp) as? String {
            userAgent = ua
        }else{
            VisilabsLogger.warn(message: "Visilabs: Error while unarchiving userAgent.")
        }
        
        if let propsfp = filePath(filename: VisilabsConfig.PROPERTIES_ARCHIVE_KEY), let props = NSKeyedUnarchiver.unarchiveObject(withFile: propsfp) as? [String : String?] {
            
            if let cid = props[VisilabsConfig.COOKIEID_KEY], !cid.isNilOrWhiteSpace {
                cookieId = cid
            }
            
            if let exvid = props[VisilabsConfig.EXVISITORID_KEY], !exvid.isNilOrWhiteSpace {
                exVisitorId = exvid
            }
            
            if let aid = props[VisilabsConfig.APPID_KEY], !aid.isNilOrWhiteSpace {
                appId = aid
            }
            
            if let tid = props[VisilabsConfig.TOKENID_KEY], !tid.isNilOrWhiteSpace {
                tokenId = tid
            }
            
            if let ua = props[VisilabsConfig.USERAGENT_KEY], !ua.isNilOrWhiteSpace {
                userAgent = ua
            }
            
            if let vd = props[VisilabsConfig.VISITORDATA], !vd.isNilOrWhiteSpace {
                visitorData = vd
            }
            
            if let vd = props[VisilabsConfig.VISITOR_CAPPING_KEY], !vd.isNilOrWhiteSpace {
                visitorData = vd
            }
            
            if let madid = props[VisilabsConfig.MOBILEADID_KEY], !madid.isNilOrWhiteSpace {
                mobileAdId = madid
            }
            
            
        }else{
            VisilabsLogger.warn(message: "Visilabs: Error while unarchiving properties.")
        }
        
        
        
        return (cookieId, exVisitorId, appId, tokenId, userAgent, visitorData, mobileAdId)
    }
    
    
    //TODO: buradaki encode işlemleri doğru mu kontrol et
    class func saveParameters(_ parameters: [String : String]) {
        archiveQueue.sync {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            
            for visilabsParameter in VisilabsConfig.visilabsParameters() {
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
                            VisilabsDataManager.save(storeKey, withObject: parameterValueToStore)
                        } else {
                            VisilabsDataManager.save(storeKey, withObject: parameterValue)
                        }
                    }
                    else if count > 1 {
                        let previousParameterValue = VisilabsDataManager.read(storeKey) as? String
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
                        VisilabsDataManager.save(storeKey, withObject: parameterValueToStore)
                    }
                    
                }
            }
            
        }
    }
    
    class func getParameters() -> [String : String?] {
        var parameters: [String : String?] = [:]
        for visilabsParameter in VisilabsConfig.visilabsParameters() {
            let storeKey = visilabsParameter.storeKey
            let value = VisilabsDataManager.read(storeKey) as? String
            if value != nil && (value?.count ?? 0) > 0 {
                parameters[storeKey] = value
            }
        }
        return parameters
    }

    class func clearParameters() {
        for visilabsParameter in VisilabsConfig.visilabsParameters() {
            VisilabsDataManager.remove(visilabsParameter.storeKey)
        }
    }
}
