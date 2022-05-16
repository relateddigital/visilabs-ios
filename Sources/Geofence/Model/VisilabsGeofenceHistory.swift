//
//  VisilabsGeofenceHistory.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.09.2020.
//

import Foundation

public class VisilabsGeofenceHistory: Codable {
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
