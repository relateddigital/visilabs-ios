//
//  VisilabsGeofenceHistory.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.09.2020.
//

class VisilabsGeofenceHistory: Codable {
    internal init(lastKnownLatitude: Double? = nil, lastKnownLongitude: Double? = nil, lastFetchTime: Date? = nil, fetchHistory: [Date : [VisilabsGeofenceEntity]]? = nil, errorHistory:[Date: VisilabsReason]? = nil) {
        self.lastKnownLatitude = lastKnownLatitude
        self.lastKnownLongitude = lastKnownLongitude
        self.lastFetchTime = lastFetchTime
        self.fetchHistory = fetchHistory ?? [Date: [VisilabsGeofenceEntity]]()
        self.errorHistory = errorHistory ??  [Date: VisilabsReason]()
    }
    
    internal init(){
        self.fetchHistory = [Date: [VisilabsGeofenceEntity]]()
        self.errorHistory = [Date: VisilabsReason]()
    }
    var lastKnownLatitude : Double?
    var lastKnownLongitude : Double?
    var lastFetchTime : Date?
    var fetchHistory: [Date: [VisilabsGeofenceEntity]]
    var errorHistory: [Date: VisilabsReason]
}
