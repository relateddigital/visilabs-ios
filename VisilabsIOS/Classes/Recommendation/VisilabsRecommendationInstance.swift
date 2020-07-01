//
//  VisilabsRecommendationInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 29.06.2020.
//

import Foundation

class VisilabsRecommendationInstance {
    let organizationId: String
    let siteId: String
    

    init(organizationId: String, siteId: String) {
        self.organizationId = organizationId
        self.siteId = siteId
    }
    
    func recommend(zoneID: String, productCode: String, visilabsUser: VisilabsUser, channel: String, properties: [String : String] = [:], filters: [VisilabsRecommendationFilter] = [], completion: @escaping ((_ response: VisilabsRecommendationResponse) -> Void)){
        var props = cleanProperties(properties)
        var vUser = visilabsUser
        var chan = channel
        let actualTimeOfevent = Int(Date().timeIntervalSince1970)
        
        if filters.count > 0 {
            props[VisilabsConfig.FILTER_KEY] = getFiltersQueryStringValue(filters)
        }
        
        
        
        
    }
    
    
    private func getFiltersQueryStringValue(_ filters: [VisilabsRecommendationFilter]) -> String?{
        var queryStringValue: String?
        var abbrevatedFilters: [[String:String]] = []
        for filter in filters {
            if filter.value.count > 0 {
                var abbrevatedFilter = [String : String]()
                abbrevatedFilter["attr"] = filter.attribute.rawValue
                abbrevatedFilter["ft"] = String(filter.filterType.rawValue)
                abbrevatedFilter["fv"] = filter.value
                abbrevatedFilters.append(abbrevatedFilter)
            }
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: abbrevatedFilters, options: [])
            queryStringValue = String(data: jsonData, encoding: .utf8)
        } catch {
            VisilabsLogger.warn(message: "exception serializing recommendation filters: \(error.localizedDescription)")
        }
        return queryStringValue
    }
    
    private func cleanProperties(_ properties: [String : String]) -> [String : String] {
        var props = properties
        for propKey in props.keys {
            if !propKey.isEqual(VisilabsConfig.ORGANIZATIONID_KEY) && !propKey.isEqual(VisilabsConfig.SITEID_KEY) && !propKey.isEqual(VisilabsConfig.EXVISITORID_KEY) && !propKey.isEqual(VisilabsConfig.COOKIEID_KEY) && !propKey.isEqual(VisilabsConfig.ZONE_ID_KEY) && !propKey.isEqual(VisilabsConfig.BODY_KEY) && !propKey.isEqual(VisilabsConfig.TOKENID_KEY) && !propKey.isEqual(VisilabsConfig.APPID_KEY) && !propKey.isEqual(VisilabsConfig.APIVER_KEY) && !propKey.isEqual(VisilabsConfig.FILTER_KEY) {
                continue
            } else {
                props.removeValue(forKey: propKey)
            }
        }
        return props
    }
    
    
    
    func customEvent(pageName: String, properties: [String:String], eventsQueue: Queue, visilabsUser: VisilabsUser, channel: String) -> (eventsQueque: Queue, visilabsUser: VisilabsUser, clearUserParameters: Bool, channel: String) {
        var props = properties
        var vUser = visilabsUser
        var chan = channel
        var clearUserParameters = false
        let actualTimeOfevent = Int(Date().timeIntervalSince1970)
        
        if let cookieId = props[VisilabsConfig.COOKIEID_KEY] {
            if vUser.cookieId != cookieId {
                clearUserParameters = true
            }
            vUser.cookieId = cookieId
            props.removeValue(forKey: VisilabsConfig.COOKIEID_KEY)
        }
        
        if let exVisitorId = props[VisilabsConfig.EXVISITORID_KEY] {
            if vUser.exVisitorId != exVisitorId {
                clearUserParameters = true
            }
            if vUser.exVisitorId != nil && vUser.exVisitorId != exVisitorId {
                //TODO: burada cookieId generate etmek doğru mu tekrar kontrol et
                vUser.cookieId = VisilabsHelper.generateCookieId()
            }
            vUser.exVisitorId = exVisitorId
            props.removeValue(forKey: VisilabsConfig.EXVISITORID_KEY)
        }
        
        if let tokenId = props[VisilabsConfig.TOKENID_KEY] {
            vUser.tokenId = tokenId
            props.removeValue(forKey: VisilabsConfig.TOKENID_KEY)
        }
        
        if let appId = props[VisilabsConfig.APPID_KEY]{
            vUser.appId = appId
            props.removeValue(forKey: VisilabsConfig.APPID_KEY)
        }
        
        //TODO: Dışarıdan mobile ad id gelince neden siliyoruz?
        if props.keys.contains(VisilabsConfig.MOBILEADID_KEY) {
            props.removeValue(forKey: VisilabsConfig.MOBILEADID_KEY)
        }
        
        if props.keys.contains(VisilabsConfig.APIVER_KEY) {
            props.removeValue(forKey: VisilabsConfig.APIVER_KEY)
        }
        
        if props.keys.contains(VisilabsConfig.CHANNEL_KEY) {
            chan = props[VisilabsConfig.CHANNEL_KEY]!
            props.removeValue(forKey: VisilabsConfig.CHANNEL_KEY)
        }
        
        props[VisilabsConfig.ORGANIZATIONID_KEY] = self.organizationId
        props[VisilabsConfig.SITEID_KEY] = self.siteId
        props[VisilabsConfig.COOKIEID_KEY] = vUser.cookieId ?? ""
        props[VisilabsConfig.CHANNEL_KEY] = chan
        props[VisilabsConfig.URI_KEY] = pageName
        props[VisilabsConfig.MOBILEAPPLICATION_KEY] = VisilabsConfig.TRUE
        props[VisilabsConfig.MOBILEADID_KEY] = vUser.identifierForAdvertising ?? ""
        props[VisilabsConfig.APIVER_KEY] = VisilabsConfig.IOS
        
        if !vUser.exVisitorId.isNilOrWhiteSpace {
            props[VisilabsConfig.EXVISITORID_KEY] = vUser.exVisitorId
        }
        
        if !vUser.tokenId.isNilOrWhiteSpace{
            props[VisilabsConfig.TOKENID_KEY] = vUser.tokenId
        }
        
        if !vUser.appId.isNilOrWhiteSpace{
            props[VisilabsConfig.APPID_KEY] = vUser.appId
        }
        
        props[VisilabsConfig.DAT_KEY] = String(actualTimeOfevent)
        

        var eQueue = eventsQueue
        
        eQueue.append(props)
        if eQueue.count > VisilabsConfig.QUEUE_SIZE {
            eQueue.remove(at: 0)
        }
        //TODO: VisilabsPersistentTargetManager.saveParameters dışarıda yapılacak
        
        return (eQueue, vUser, clearUserParameters, chan)
    }

}