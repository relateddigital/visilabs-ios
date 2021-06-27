//
//  VisilabsGeofenceHistory.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.09.2020.
//

import Foundation

public class VisilabsGeofenceHistory: Codable {
    internal init(lastKnownLatitude: Double? = nil,
                  lastKnownLongitude: Double? = nil,
                  lastFetchTime: Date? = nil,
                  fetchHistory: [Date: [VisilabsGeofenceEntity]]? = nil,
                  errorHistory: [Date: VisilabsError]? = nil) {
        self.lastKnownLatitude = lastKnownLatitude
        self.lastKnownLongitude = lastKnownLongitude
        self.lastFetchTime = lastFetchTime
        self.fetchHistory = fetchHistory ?? [Date: [VisilabsGeofenceEntity]]()
        self.errorHistory = errorHistory ??  [Date: VisilabsError]()
    }

    internal init() {
        self.fetchHistory = [Date: [VisilabsGeofenceEntity]]()
        self.errorHistory = [Date: VisilabsError]()
    }
    public var lastKnownLatitude: Double?
    public var lastKnownLongitude: Double?
    public var lastFetchTime: Date?
    public var fetchHistory: [Date: [VisilabsGeofenceEntity]]
    public var errorHistory: [Date: VisilabsError]
}
