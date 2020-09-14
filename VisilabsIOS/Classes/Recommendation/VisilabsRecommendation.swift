//
//  VisilabsRecommendation.swift
//  VisilabsIOS
//
//  Created by Egemen on 29.06.2020.
//

import Foundation

class VisilabsRecommendation {
    let visilabsProfile: VisilabsProfile

    init(visilabsProfile: VisilabsProfile) {
        self.visilabsProfile = visilabsProfile
    }
    
    func recommend(zoneID: String, productCode: String, visilabsUser: VisilabsUser, channel: String, properties: [String : String] = [:], filters: [VisilabsRecommendationFilter] = [], completion: @escaping ((_ response: VisilabsRecommendationResponse) -> Void)){
        
        var props = cleanProperties(properties)
        
        if filters.count > 0 {
            props[VisilabsConstants.FILTER_KEY] = getFiltersQueryStringValue(filters)
        }
        
        props[VisilabsConstants.ORGANIZATIONID_KEY] = self.visilabsProfile.organizationId
        props[VisilabsConstants.PROFILEID_KEY] = self.visilabsProfile.profileId
        props[VisilabsConstants.COOKIEID_KEY] = visilabsUser.cookieId
        props[VisilabsConstants.EXVISITORID_KEY] = visilabsUser.exVisitorId
        props[VisilabsConstants.TOKENID_KEY] = visilabsUser.tokenId
        props[VisilabsConstants.APPID_KEY] = visilabsUser.appId
        props[VisilabsConstants.APIVER_KEY] = VisilabsConstants.APIVER_VALUE
        
        if zoneID.count > 0 {
            props[VisilabsConstants.ZONE_ID_KEY] = zoneID
        }
        if productCode.count > 0 {
            props[VisilabsConstants.BODY_KEY] = productCode
        }
        
        for (key, value) in VisilabsPersistence.readTargetParameters() {
            if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
                props[key] = value
            }
        }
        
        VisilabsRequest.sendRecommendationRequest(properties: props, headers: [String : String](), timeoutInterval: visilabsProfile.requestTimeoutInterval, completion: { (result: [Any]?, reason: VisilabsError?) in
            var products = [VisilabsProduct]()
            if reason != nil {
                completion(VisilabsRecommendationResponse(products: [VisilabsProduct](), error: reason))
            }else {
                for r in result!{
                    if let product = VisilabsProduct(JSONObject: r as? [String: Any?]) {
                        products.append(product)
                    }
                }
                
                completion(VisilabsRecommendationResponse(products: products, error: nil))
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
            VisilabsLogger.warn("exception serializing recommendation filters: \(error.localizedDescription)")
        }
        return queryStringValue
    }
    
    private func cleanProperties(_ properties: [String : String]) -> [String : String] {
        var props = properties
        for propKey in props.keys {
            if !propKey.isEqual(VisilabsConstants.ORGANIZATIONID_KEY) && !propKey.isEqual(VisilabsConstants.PROFILEID_KEY) && !propKey.isEqual(VisilabsConstants.EXVISITORID_KEY) && !propKey.isEqual(VisilabsConstants.COOKIEID_KEY) && !propKey.isEqual(VisilabsConstants.ZONE_ID_KEY) && !propKey.isEqual(VisilabsConstants.BODY_KEY) && !propKey.isEqual(VisilabsConstants.TOKENID_KEY) && !propKey.isEqual(VisilabsConstants.APPID_KEY) && !propKey.isEqual(VisilabsConstants.APIVER_KEY) && !propKey.isEqual(VisilabsConstants.FILTER_KEY) {
                continue
            } else {
                props.removeValue(forKey: propKey)
            }
        }
        return props
    }

}
