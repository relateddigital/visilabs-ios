//
//  VisilabsCLLocation.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 11.04.2022.
//

import Foundation
import CoreLocation

@objc public class VisilabsCLLocation: NSObject, Codable {
    public let latitude: Double
    public let longitude: Double
    public let altitude: Double
    public let horizontalAccuracy: Double
    public let verticalAccuracy: Double
    public let timestamp: Date
    public let mocked: Bool

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        altitude = try container.decode(Double.self, forKey: .altitude)
        horizontalAccuracy = try container.decode(Double.self, forKey: .horizontalAccuracy)
        verticalAccuracy = try container.decode(Double.self, forKey: .verticalAccuracy)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        mocked = try container.decode(Bool.self, forKey: .mocked)
    }

    public init(location: CLLocation, mocked: Bool) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        altitude = location.altitude
        horizontalAccuracy = location.horizontalAccuracy
        verticalAccuracy = location.verticalAccuracy
        timestamp = location.timestamp
        self.mocked = mocked
    }

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, altitude, horizontalAccuracy, verticalAccuracy, timestamp, mocked
    }
}

