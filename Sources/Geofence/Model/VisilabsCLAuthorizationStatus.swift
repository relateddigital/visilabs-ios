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

class GeofenceState {
    
    typealias VP = VisilabsPersistence
    
    enum Key: String {
        case geofenceEnabled = "geofenceEnabled"
        case geofenceLastLocation = "geofenceLastLocation"
        case geofenceStopped = "geofenceStopped"
        case geofenceLastMovedLocation = "geofenceLastMovedLocation"
        case geofenceLastMovedAt = "geofenceLastMovedAt"
        case geofenceLastSentAt = "geofenceLastSentAt"
        case geofenceLastFailedStoppedLocation = "geofenceLastFailedStoppedLocation"
    }
    
    
    static func setGeofenceEnabled(_ geofenceEnabled: Bool){
        VP.saveUserDefaults(Key.geofenceEnabled.rawValue, withObject: geofenceEnabled)
    }
    
    static func getGeofenceEnabled() -> Bool{
        return VP.readUserDefaults(Key.geofenceEnabled.rawValue) as? Bool ?? true
    }
    
    static func validLocation(_ location: CLLocation) -> Bool {
        let latitudeValid = location.coordinate.latitude > -90 && location.coordinate.latitude < 90
        let longitudeValid = location.coordinate.longitude > -180 && location.coordinate.latitude < 180
        let horizontalAccuracyValid = location.horizontalAccuracy > 0
        return latitudeValid && longitudeValid && horizontalAccuracyValid
    }
    
    private static func saveLocation(_ location: CLLocation, key: String) {
        let encoder = JSONEncoder()
        let vLoc = VisilabsCLLocation(location: location, mocked: false)
        if let vLocData = try? encoder.encode(vLoc) {
            VP.saveUserDefaults(key, withObject: vLocData)
        }
    }
    
    private static func getLocation(key: String) -> CLLocation? {
        if let data = VP.readUserDefaults(key) as? Data {
            let decoder = JSONDecoder()
            if let vLoc = try? decoder.decode(VisilabsCLLocation.self, from: data) {
                let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(vLoc.latitude), CLLocationDegrees(vLoc.longitude))
                return CLLocation(
                    coordinate: coordinate,
                    altitude: CLLocationDistance(vLoc.altitude),
                    horizontalAccuracy: CLLocationAccuracy(vLoc.horizontalAccuracy),
                    verticalAccuracy: CLLocationAccuracy(vLoc.verticalAccuracy),
                    timestamp: vLoc.timestamp)
            }
        }
        return nil
    }
    
    static func setLastLocation(_ loc: CLLocation) {
        if validLocation(loc) {
            saveLocation(loc, key: Key.geofenceLastLocation.rawValue)
        }
    }
    
    static func getLastLocation() -> CLLocation? {
        guard let loc = getLocation(key: Key.geofenceLastLocation.rawValue), validLocation(loc) else {
            return nil
        }
        return loc
    }
    
    static func setLastMovedLocation(_ loc: CLLocation) {
        if validLocation(loc) {
            saveLocation(loc, key: Key.geofenceLastMovedLocation.rawValue)
        }
    }
    
    static func getLastMovedLocation() -> CLLocation? {
        guard let loc = getLocation(key: Key.geofenceLastMovedLocation.rawValue), validLocation(loc) else {
            return nil
        }
        return loc
    }
    
    static func setLastMovedAt(_ lastMovedAt: Date) {
        VP.saveUserDefaults(Key.geofenceLastMovedAt.rawValue, withObject: lastMovedAt)
    }
    
    static func getLastMovedAt() -> Date? {
        return VP.readUserDefaults(Key.geofenceLastMovedAt.rawValue) as? Date
    }
    
    static func setStopped(_ stopped: Bool) {
        VP.saveUserDefaults(Key.geofenceStopped.rawValue, withObject: stopped)
    }
    
    static func getStopped() -> Bool {
        return VP.readUserDefaults(Key.geofenceStopped.rawValue) as? Bool ?? true
    }
    
    static func setLastSentAt() {
        VP.saveUserDefaults(Key.geofenceLastSentAt.rawValue, withObject: Date())
    }
    
    static func getLastSentAt() -> Date? {
        return VP.readUserDefaults(Key.geofenceLastSentAt.rawValue) as? Date
    }
    
    
    
    static func getLastFailedStoppedLocation() -> CLLocation? {
        guard let loc = getLocation(key: Key.geofenceLastFailedStoppedLocation.rawValue), validLocation(loc) else {
            return nil
        }
        return loc
    }
    
    static func setLastFailedStoppedLocation(_ loc: CLLocation?) {
        if let loc = loc, validLocation(loc) {
            saveLocation(loc, key: Key.geofenceLastFailedStoppedLocation.rawValue)
        }
    }
    
    
    static func locationAuthorizationStatus() -> CLAuthorizationStatus {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .authorizedWhenInUse:
            return .authorizedWhenInUse
        case .authorizedAlways:
            return .authorizedAlways
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        default:
            return .notDetermined
        }
    }
    
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
