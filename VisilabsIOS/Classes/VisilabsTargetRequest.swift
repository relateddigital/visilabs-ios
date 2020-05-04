//
//  VisilabsTargetRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.04.2020.
//

import Foundation

public class VisilabsTargetRequest: VisilabsAction {
    var targetUrl: String
    var zoneID: String
    var productCode: String
    var properties: [String : String]
    var filters: [VisilabsTargetFilter]
    
    internal init(targetUrl: String, siteID: String, organizationID: String, cookieID: String?, exVisitorID: String?, tokenID: String?, appID: String?, zoneID: String, productCode: String, properties : [String : String], filters: [VisilabsTargetFilter]) {
        self.targetUrl = targetUrl
        self.zoneID = zoneID
        self.productCode = productCode
        self.properties = properties
        self.filters = filters
        super.init(siteID: siteID, organizationID: organizationID, cookieID: cookieID, exVisitorID: exVisitorID, tokenID: tokenID, appID: appID, requestMethod: "GET")
    }
    
    override func buildURL() -> URL? {        
        if Visilabs.callAPI() == nil || organizationID.count == 0 || siteID.count == 0 {
            return nil
        }
        let queryParameters = getParametersAsQueryString()
        targetUrl = targetUrl + queryParameters
        return URL(string: targetUrl)
    }
    
    private func cleanParameters() {
        for propKey in properties.keys {
            if !propKey.isEqual(VisilabsConfig.ORGANIZATIONID_KEY) && !propKey.isEqual(VisilabsConfig.SITEID_KEY) && !propKey.isEqual(VisilabsConfig.EXVISITORID_KEY) && !propKey.isEqual(VisilabsConfig.COOKIEID_KEY) && !propKey.isEqual(VisilabsConfig.ZONE_ID_KEY) && !propKey.isEqual(VisilabsConfig.BODY_KEY) && !propKey.isEqual(VisilabsConfig.TOKENID_KEY) && !propKey.isEqual(VisilabsConfig.APPID_KEY) && !propKey.isEqual(VisilabsConfig.APIVER_KEY) && !propKey.isEqual(VisilabsConfig.FILTER_KEY) {
                continue
            } else {
                properties.removeValue(forKey: propKey)
            }
        }
    }
    
    private func getFiltersQueryString(_ filters: [VisilabsTargetFilter]) -> String? {
        var abbFilters: [[String:String]] = []
        
        for propKey in filters {
            if (propKey.attribute != nil) && propKey.attribute != "" && (propKey.filterType != nil) && propKey.filterType != "" && (propKey.value != nil) && propKey.value != "" {
                var abbFilter: [String : String] = [:]
                abbFilter["attr"] = propKey.attribute
                abbFilter["ft"] = propKey.filterType
                abbFilter["fv"] = propKey.value
                abbFilters.append(abbFilter)
            }
        }
        
        if abbFilters.count > 0 {
            var jsonData: Data? = nil
            var jsonString: String? = nil
            do {
                jsonData = try JSONSerialization.data(withJSONObject: abbFilters, options: [])
                if let jsonData = jsonData {
                    jsonString = String(data: jsonData, encoding: .utf8)
                    //TODO: bunu sil sonra
                    print("JSON Output: \(jsonString ?? "")")
                    return jsonString
                }
            } catch {
                //TODO: bunu sil sonra
                print("JSONSerialization Error Description: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    private func getParametersAsQueryString() -> String {
        var queryParameters = "?\(VisilabsConfig.ORGANIZATIONID_KEY)=\(organizationID)&\(VisilabsConfig.SITEID_KEY)=\(siteID)"

        if Visilabs.callAPI()!.cookieID != nil && Visilabs.callAPI()!.cookieID!.count > 0 {
            let encodedCookieIDValue = Visilabs.callAPI()!.cookieID!.urlEncode()
            let cookieParameter = "&\(VisilabsConfig.COOKIEID_KEY)=\(encodedCookieIDValue)"
            queryParameters = queryParameters + cookieParameter
        }
        
        if Visilabs.callAPI()!.exVisitorID != nil && Visilabs.callAPI()!.exVisitorID!.count > 0 {
            let encodedExVisitorIDValue = Visilabs.callAPI()!.exVisitorID!.urlEncode()
            let exVisitorIDParameter = "&\(VisilabsConfig.EXVISITORID_KEY)=\(encodedExVisitorIDValue)"
            queryParameters = queryParameters + exVisitorIDParameter
        }

        if zoneID.count > 0 {
            let encodedZoneIDValue = zoneID.urlEncode()
            let zoneIDParameter = "&\(VisilabsConfig.ZONE_ID_KEY)=\(encodedZoneIDValue)"
            queryParameters = queryParameters + zoneIDParameter
        }
        
        if productCode.count > 0 {
            let encodedProductCodeValue = productCode.urlEncode()
            let productCodeParameter = "&\(VisilabsConfig.BODY_KEY)=\(encodedProductCodeValue)"
            queryParameters = queryParameters + productCodeParameter
        }
        
        if Visilabs.callAPI()!.tokenID != nil && Visilabs.callAPI()!.tokenID!.count > 0 {
            let encodedTokenValue = Visilabs.callAPI()!.tokenID!.urlEncode()
            let tokenParameter = "&\(VisilabsConfig.TOKENID_KEY)=\(encodedTokenValue)"
            queryParameters = queryParameters + tokenParameter
        }
        
        if Visilabs.callAPI()!.appID != nil && Visilabs.callAPI()!.appID!.count > 0 {
            let encodedAppValue = Visilabs.callAPI()!.appID!.urlEncode()
            let appParameter = "&\(VisilabsConfig.APPID_KEY)=\(encodedAppValue)"
            queryParameters = queryParameters + appParameter
        }
        
        cleanParameters()
                        
        if let fs = getFiltersQueryString(filters), !fs.isEmptyOrWhitespace {
            queryParameters = "\(queryParameters)&\(VisilabsConfig.FILTER_KEY)=\(fs.urlEncode())"
        }
        
        queryParameters = "\(queryParameters)&\(VisilabsConfig.APIVER_KEY)=\(VisilabsConfig.APIVER_VALUE)"
        
        for (key, value) in properties {
            if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace {
                queryParameters = "\(queryParameters)&\(key)=\(value.urlEncode())"
            }
        }
        
        for (key, value) in VisilabsPersistentTargetManager.getParameters() {
            if !key.isEmptyOrWhitespace && !value.isNilOrWhiteSpace {
                queryParameters = "\(queryParameters)&\(key)=\(value!.urlEncode())"
            }
        }

        return queryParameters
    }
    
}
