//
//  VisilabsGeofenceRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.04.2020.
//

import Foundation

class VisilabsGeofenceRequest: VisilabsAction {
    var geofenceUrl: String
    var action: String
    var actionID: String
    var lastKnownLatitude: Double
    var lastKnownLongitude: Double
    var geofenceID: String
    var isDwell: Bool
    var isEnter: Bool
    
    internal init(geofenceUrl: String, siteID: String, organizationID: String, cookieID: String?, exVisitorID: String?, tokenID: String?, appID: String?, action: String, actionID: String, lastKnownLatitude: Double = 0.0, lastKnownLongitude: Double = 0.0, geofenceID: String, isDwell: Bool = false, isEnter: Bool = false) {
        self.geofenceUrl = geofenceUrl
        self.action = action
        self.actionID = actionID
        self.lastKnownLatitude = lastKnownLatitude
        self.lastKnownLongitude = lastKnownLongitude
        self.geofenceID = geofenceID
        self.isDwell = isDwell
        self.isEnter = isEnter
        super.init(siteID: siteID, organizationID: organizationID, cookieID: cookieID, exVisitorID: exVisitorID, tokenID: tokenID, appID: appID, requestMethod: "GET")
    }
    
    override func buildURL() -> URL? {
        let queryParameters = getParametersAsQueryString()
        geofenceUrl = geofenceUrl + queryParameters
        return URL(string: geofenceUrl)
    }
    
    private func getParametersAsQueryString() -> String {
        
        var queryParameters = "?\(VisilabsConfig.ORGANIZATIONID_KEY)=\(organizationID)&\(VisilabsConfig.SITEID_KEY)=\(siteID)"

        if !cookieID.isNilOrWhiteSpace {
            let encodedCookieIDValue = cookieID!.urlEncode()
            let cookieParameter = "&\(VisilabsConfig.COOKIEID_KEY)=\(encodedCookieIDValue)"
            queryParameters = queryParameters + cookieParameter
        }
        
        if !exVisitorID.isNilOrWhiteSpace {
            let encodedExVisitorIDValue = exVisitorID!.urlEncode()
            let exVisitorIDParameter = "&\(VisilabsConfig.EXVISITORID_KEY)=\(encodedExVisitorIDValue)"
            queryParameters = queryParameters + exVisitorIDParameter
        }

        if action.count > 0 {
            let encodedActionValue = action.urlEncode()
            let actionParameter = "&\(VisilabsConfig.ACT_KEY)=\(encodedActionValue)"
            queryParameters = queryParameters + actionParameter
        }
        
        if actionID.count > 0 {
            let encodedActionIDValue = actionID.urlEncode()
            let actionIDParameter = "&\(VisilabsConfig.ACT_ID_KEY)=\(encodedActionIDValue)"
            queryParameters = queryParameters + actionIDParameter
        }
        
        if !tokenID.isNilOrWhiteSpace {
            let encodedTokenValue = tokenID!.urlEncode()
            let tokenParameter = "&\(VisilabsConfig.TOKENID_KEY)=\(encodedTokenValue)"
            queryParameters = queryParameters + tokenParameter
        }
        
        if !appID.isNilOrWhiteSpace {
            let encodedAppValue = appID!.urlEncode()
            let appParameter = "&\(VisilabsConfig.APPID_KEY)=\(encodedAppValue)"
            queryParameters = queryParameters + appParameter
        }
        
        //TODO: Burada büyüktür 0 kontrolü doğru mu sedat'a sor
        if lastKnownLatitude > 0 {
            let encodedLatitudeValue = String(format: "%.013f", lastKnownLatitude)
            let latitudeParameter = "&\(VisilabsConfig.LATITUDE_KEY)=\(encodedLatitudeValue)"
            queryParameters = queryParameters + latitudeParameter
        }

        if lastKnownLongitude > 0 {
            let encodedLongitudeValue = String(format: "%.013f", lastKnownLongitude)
            let longitudeParameter = "&\(VisilabsConfig.LONGITUDE_KEY)=\(encodedLongitudeValue)"
            queryParameters = queryParameters + longitudeParameter
        }
        
        if geofenceID.count > 0 {
            let encodedGeofenceID = geofenceID.urlEncode()
            let geofenceIDParameter = "&\(VisilabsConfig.GEO_ID_KEY)=\(encodedGeofenceID)"
            queryParameters = queryParameters + geofenceIDParameter
        }
        
        //TODO: OnEnter ve OnExit i VisilabsConfig e koy
        if isDwell {
            if isEnter {
                let triggerEventParameter = "&\(VisilabsConfig.TRIGGER_EVENT_KEY)=\("OnEnter")"
                queryParameters = queryParameters + triggerEventParameter
            } else {
                let triggerEventParameter = "&\(VisilabsConfig.TRIGGER_EVENT_KEY)=\("OnExit")"
                queryParameters = queryParameters + triggerEventParameter
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
