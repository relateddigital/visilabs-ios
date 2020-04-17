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
}
