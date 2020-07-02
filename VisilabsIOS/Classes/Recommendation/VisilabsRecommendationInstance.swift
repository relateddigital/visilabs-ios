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
    
    func recommend(zoneID: String, productCode: String, visilabsUser: VisilabsUser, channel: String, timeoutInterval: TimeInterval, properties: [String : String] = [:], filters: [VisilabsRecommendationFilter] = [], completion: @escaping ((_ response: VisilabsRecommendationResponse) -> Void)){
        
        var props = cleanProperties(properties)
        
        if filters.count > 0 {
            props[VisilabsConfig.FILTER_KEY] = getFiltersQueryStringValue(filters)
        }
        
        props[VisilabsConfig.ORGANIZATIONID_KEY] = self.organizationId
        props[VisilabsConfig.SITEID_KEY] = self.siteId
        props[VisilabsConfig.COOKIEID_KEY] = visilabsUser.cookieId
        props[VisilabsConfig.EXVISITORID_KEY] = visilabsUser.exVisitorId
        props[VisilabsConfig.TOKENID_KEY] = visilabsUser.tokenId
        props[VisilabsConfig.APPID_KEY] = visilabsUser.appId
        props[VisilabsConfig.APIVER_KEY] = VisilabsConfig.APIVER_VALUE
        
        if zoneID.count > 0 {
            props[VisilabsConfig.ZONE_ID_KEY] = zoneID
        }
        if productCode.count > 0 {
            props[VisilabsConfig.BODY_KEY] = productCode
        }
        
        for (key, value) in VisilabsPersistence.getParameters() {
            if !key.isEmptyOrWhitespace && !value.isNilOrWhiteSpace && props[key] == nil {
                props[key] = value
            }
        }
        
        VisilabsRecommendationRequest.sendRequest(properties: props, headers: [String : String](), timeoutInterval: timeoutInterval, completion: { (result: [Any]?, reason: VisilabsReason?) in
            
            if reason != nil {
                completion(VisilabsRecommendationResponse(products: [VisilabsProduct](), error: reason))
            }else {
                completion(VisilabsRecommendationResponse(products: (result as? [VisilabsProduct]) ?? [VisilabsProduct](), error: nil))
            }
        })
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

}
