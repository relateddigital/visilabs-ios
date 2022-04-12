//
//  VisilabsCLAuthorizationStatus.swift
//  VisilabsIOS
//
//  Created by Egemen on 2.09.2020.
//

import Foundation
import CoreLocation

public enum VisilabsCLAuthorizationStatus: Int32 {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorizedAlways = 3
    case authorizedWhenInUse = 4
    case none = 5
}

public enum LocationSource: Int {
    case foregroundLocation
    case backgroundLocation
    case manualLocation
    case geofenceEnter
    case geofenceExit
    case mockLocation
    case unknown
}

extension CLAuthorizationStatus {
    var string: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        @unknown default: return "unknown \(self.rawValue)"
        }
    }
    
    var queryStringValue : String {
        switch self {
        case .denied: return VisilabsConstants.locationPermissionNone
        case .authorizedAlways: return VisilabsConstants.locationPermissionAlways
        case .authorizedWhenInUse: return VisilabsConstants.locationPermissionAppOpen
        case .notDetermined, .restricted: return VisilabsConstants.locationPermissionNone
        @unknown default: return VisilabsConstants.locationPermissionNone
        }
    }
}
