//
//  VisilabsTargetRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.04.2020.
//

import Foundation

class VisilabsTargetRequest: VisilabsAction {
    var zoneID: String?
    var productCode: String?
    var properties: [String : Any]?
    var filters: [VisilabsTargetFilter]?
    
    override func buildURL() -> URL? {
        var targetURL = Visilabs.callAPI()!.targetURL
        let queryParameters = getParametersAsQueryString()
        targetURL = targetURL + (queryParameters)
        let uri = URL(string: targetURL!)
        return uri
    }
    
    func cleanParameters() {
        if properties != nil {
            for propKey in properties!.keys {
                if !propKey.isEqual(VisilabsConfig.ORGANIZATIONID_KEY) && !propKey.isEqual(VisilabsConfig.SITEID_KEY) && !propKey.isEqual(VisilabsConfig.EXVISITORID_KEY) && !propKey.isEqual(VisilabsConfig.COOKIEID_KEY) && !propKey.isEqual(VisilabsConfig.ZONE_ID_KEY) && !propKey.isEqual(VisilabsConfig.BODY_KEY) && !propKey.isEqual(VisilabsConfig.TOKENID_KEY) && !propKey.isEqual(VisilabsConfig.APPID_KEY) && !propKey.isEqual(VisilabsConfig.APIVER_KEY) && !propKey.isEqual(VisilabsConfig.FILTER_KEY) {
                    continue
                } else {
                    properties?.removeValue(forKey: propKey)
                }
            }
        }
    }
    
}
