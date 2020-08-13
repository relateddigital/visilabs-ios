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

        if action.count > 0 {
            let encodedActionValue = action.urlEncode()
            let actionParameter = "&\(VisilabsConstants.ACT_KEY)=\(encodedActionValue)"
            queryParameters = queryParameters + actionParameter
        }
        
        if actionID.count > 0 {
            let encodedActionIDValue = actionID.urlEncode()
            let actionIDParameter = "&\(VisilabsConstants.ACT_ID_KEY)=\(encodedActionIDValue)"
            queryParameters = queryParameters + actionIDParameter
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
        
        //TODO: Burada büyüktür 0 kontrolü doğru mu sedat'a sor
        if lastKnownLatitude > 0 {
            let encodedLatitudeValue = String(format: "%.013f", lastKnownLatitude)
            let latitudeParameter = "&\(VisilabsConstants.LATITUDE_KEY)=\(encodedLatitudeValue)"
            queryParameters = queryParameters + latitudeParameter
        }

        if lastKnownLongitude > 0 {
            let encodedLongitudeValue = String(format: "%.013f", lastKnownLongitude)
            let longitudeParameter = "&\(VisilabsConstants.LONGITUDE_KEY)=\(encodedLongitudeValue)"
            queryParameters = queryParameters + longitudeParameter
        }
        
        if geofenceID.count > 0 {
            let encodedGeofenceID = geofenceID.urlEncode()
            let geofenceIDParameter = "&\(VisilabsConstants.GEO_ID_KEY)=\(encodedGeofenceID)"
            queryParameters = queryParameters + geofenceIDParameter
        }
        
        //TODO: OnEnter ve OnExit i VisilabsConfig e koy
        if isDwell {
            if isEnter {
                let triggerEventParameter = "&\(VisilabsConstants.TRIGGER_EVENT_KEY)=\("OnEnter")"
                queryParameters = queryParameters + triggerEventParameter
            } else {
                let triggerEventParameter = "&\(VisilabsConstants.TRIGGER_EVENT_KEY)=\("OnExit")"
                queryParameters = queryParameters + triggerEventParameter
            }
        }
        
        for (key, value) in VisilabsPersistence.getParameters() {
            if !key.isEmptyOrWhitespace && !value.isNilOrWhiteSpace {
                queryParameters = "\(queryParameters)&\(key)=\(value!.urlEncode())"
            }
        }

        return queryParameters
    }
}
