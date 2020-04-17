//
//  VisilabsTargetRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.04.2020.
//

import Foundation

class VisilabsTargetRequest: VisilabsAction {
    var zoneID: String
    var productCode: String
    var properties: [String : Any]
    var filters: [VisilabsTargetFilter]
    
    init(zoneID: String, productCode: String, properties : [String : Any], filters: [VisilabsTargetFilter], requestMethod: String) {
        self.zoneID = zoneID
        self.productCode = productCode
        self.properties = properties
        self.filters = filters
        
        super.init()
        self.requestMethod = requestMethod
        
    }
    
    override func buildURL() -> URL? {
        var targetURL = Visilabs.callAPI()!.targetURL
        let queryParameters = getParametersAsQueryString()
        targetURL = targetURL! + queryParameters!
        let uri = URL(string: targetURL!)
        return uri
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
    
    private func getParametersAsQueryString() -> String? {
        if Visilabs.callAPI() == nil || Visilabs.callAPI()!.organizationID.count == 0 || Visilabs.callAPI()!.siteID.count == 0 {
            return nil
        }
        
        var queryParameters = "?\(VisilabsConfig.ORGANIZATIONID_KEY)=\(Visilabs.callAPI()!.organizationID)&\(VisilabsConfig.SITEID_KEY)=\(Visilabs.callAPI()!.siteID)"

        if Visilabs.callAPI()!.cookieID != nil && Visilabs.callAPI()!.cookieID!.count > 0 {
            let encodedCookieIDValue = Visilabs.callAPI()!.urlEncode(Visilabs.callAPI()!.cookieID!)
            let cookieParameter = "&\(VisilabsConfig.COOKIEID_KEY)=\(encodedCookieIDValue)"
            queryParameters = queryParameters + cookieParameter
        }
        
        if Visilabs.callAPI()!.exVisitorID != nil && Visilabs.callAPI()!.exVisitorID!.count > 0 {
            let encodedExVisitorIDValue = Visilabs.callAPI()!.urlEncode(Visilabs.callAPI()!.exVisitorID!)
            let exVisitorIDParameter = "&\(VisilabsConfig.EXVISITORID_KEY)=\(encodedExVisitorIDValue)"
            queryParameters = queryParameters + exVisitorIDParameter
        }

        if zoneID.count > 0 {
            let encodedZoneIDValue = Visilabs.callAPI()!.urlEncode(zoneID)
            let zoneIDParameter = "&\(VisilabsConfig.ZONE_ID_KEY)=\(encodedZoneIDValue)"
            queryParameters = queryParameters + zoneIDParameter
        }
        
        if productCode.count > 0 {
            let encodedProductCodeValue = Visilabs.callAPI()!.urlEncode(productCode)
            let productCodeParameter = "&\(VisilabsConfig.BODY_KEY)=\(encodedProductCodeValue)"
            queryParameters = queryParameters + productCodeParameter
        }
        
        if Visilabs.callAPI()!.tokenID != nil && Visilabs.callAPI()!.tokenID!.count > 0 {
            let encodedTokenValue = Visilabs.callAPI()!.urlEncode(Visilabs.callAPI()!.tokenID!)
            let tokenParameter = "&\(VisilabsConfig.TOKENID_KEY)=\(encodedTokenValue)"
            queryParameters = queryParameters + tokenParameter
        }
        
        if Visilabs.callAPI()!.appID != nil && Visilabs.callAPI()!.appID!.count > 0 {
            let encodedAppValue = Visilabs.callAPI()!.urlEncode(Visilabs.callAPI()!.appID!)
            let appParameter = "&\(VisilabsConfig.APPID_KEY)=\(encodedAppValue)"
            queryParameters = queryParameters + appParameter
        }
        
        cleanParameters()
        
        //TODO:burası devam edecek
        
        return queryParameters
        
    }
    
}
