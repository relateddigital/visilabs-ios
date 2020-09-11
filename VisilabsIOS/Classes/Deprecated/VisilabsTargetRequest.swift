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
        let queryParameters = getParametersAsQueryString()
        targetUrl = targetUrl + queryParameters
        return URL(string: targetUrl)
    }
    
    private func cleanParameters() {
        for propKey in properties.keys {
            if !propKey.isEqual(VisilabsConstants.ORGANIZATIONID_KEY) && !propKey.isEqual(VisilabsConstants.PROFILEID_KEY) && !propKey.isEqual(VisilabsConstants.EXVISITORID_KEY) && !propKey.isEqual(VisilabsConstants.COOKIEID_KEY) && !propKey.isEqual(VisilabsConstants.ZONE_ID_KEY) && !propKey.isEqual(VisilabsConstants.BODY_KEY) && !propKey.isEqual(VisilabsConstants.TOKENID_KEY) && !propKey.isEqual(VisilabsConstants.APPID_KEY) && !propKey.isEqual(VisilabsConstants.APIVER_KEY) && !propKey.isEqual(VisilabsConstants.FILTER_KEY) {
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
        var queryParameters = "?\(VisilabsConstants.ORGANIZATIONID_KEY)=\(organizationID)&\(VisilabsConstants.PROFILEID_KEY)=\(siteID)"

        if !cookieID.isNilOrWhiteSpace {
            let encodedCookieIDValue = cookieID!.urlEncode()
            let cookieParameter = "&\(VisilabsConstants.COOKIEID_KEY)=\(encodedCookieIDValue)"
            queryParameters = queryParameters + cookieParameter
        }
        
        if !exVisitorID.isNilOrWhiteSpace {
            let encodedExVisitorIDValue = exVisitorID!.urlEncode()
            let exVisitorIDParameter = "&\(VisilabsConstants.EXVISITORID_KEY)=\(encodedExVisitorIDValue)"
            queryParameters = queryParameters + exVisitorIDParameter
        }

        if zoneID.count > 0 {
            let encodedZoneIDValue = zoneID.urlEncode()
            let zoneIDParameter = "&\(VisilabsConstants.ZONE_ID_KEY)=\(encodedZoneIDValue)"
            queryParameters = queryParameters + zoneIDParameter
        }
        
        if productCode.count > 0 {
            let encodedProductCodeValue = productCode.urlEncode()
            let productCodeParameter = "&\(VisilabsConstants.BODY_KEY)=\(encodedProductCodeValue)"
            queryParameters = queryParameters + productCodeParameter
        }
        
        if !tokenID.isNilOrWhiteSpace {
            let encodedTokenValue = tokenID!.urlEncode()
            let tokenParameter = "&\(VisilabsConstants.TOKENID_KEY)=\(encodedTokenValue)"
            queryParameters = queryParameters + tokenParameter
        }
        
        if !appID.isNilOrWhiteSpace {
            let encodedAppValue = appID!.urlEncode()
            let appParameter = "&\(VisilabsConstants.APPID_KEY)=\(encodedAppValue)"
            queryParameters = queryParameters + appParameter
        }
        
        cleanParameters()
                        
        if let fs = getFiltersQueryString(filters), !fs.isEmptyOrWhitespace {
            queryParameters = "\(queryParameters)&\(VisilabsConstants.FILTER_KEY)=\(fs.urlEncode())"
        }
        
        queryParameters = "\(queryParameters)&\(VisilabsConstants.APIVER_KEY)=\(VisilabsConstants.APIVER_VALUE)"
        
        for (key, value) in properties {
            if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace {
                queryParameters = "\(queryParameters)&\(key)=\(value.urlEncode())"
            }
        }
        
        for (key, value) in VisilabsPersistence.readTargetParameters() {
            if !key.isEmptyOrWhitespace && !value.isNilOrWhiteSpace {
                queryParameters = "\(queryParameters)&\(key)=\(value!.urlEncode())"
            }
        }

        return queryParameters
    }
    
}
