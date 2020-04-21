//
//  VisilabsGeofenceRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.04.2020.
//

import Foundation

class VisilabsGeofenceRequest: VisilabsAction {
    var action: String
    var actionID: String
    var lastKnownLatitude: Double
    var lastKnownLongitude: Double
    var geofenceID: String
    var isDwell: Bool
    var isEnter: Bool
    
    internal init(action: String, actionID: String, lastKnownLatitude: Double = 0.0, lastKnownLongitude: Double = 0.0, geofenceID: String, isDwell: Bool = false, isEnter: Bool = false) {
        self.action = action
        self.actionID = actionID
        self.lastKnownLatitude = lastKnownLatitude
        self.lastKnownLongitude = lastKnownLongitude
        self.geofenceID = geofenceID
        self.isDwell = isDwell
        self.isEnter = isEnter
        super.init(requestMethod: "GET")
    }
    
    override func buildURL() -> URL? {
        
        if Visilabs.callAPI() == nil || Visilabs.callAPI()!.organizationID.count == 0 || Visilabs.callAPI()!.siteID.count == 0 {
            return nil
        }
        
        var geofenceURL = Visilabs.callAPI()!.geofenceURL
        let queryParameters = getParametersAsQueryString()
        geofenceURL = geofenceURL! + queryParameters!
        return URL(string: geofenceURL!)
    }
    
    private func getParametersAsQueryString() -> String? {
    
        return nil
    }
}
