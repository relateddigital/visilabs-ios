//
//  VisilabsGeofenceState.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 12.04.2022.
//

import Foundation
import CoreLocation

class VisilabsGeofenceState {
    
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
    
    static var locationServicesEnabledForDevice: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    static var locationAuthorizationStatus: CLAuthorizationStatus {
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
    
    // notDetermined, restricted, denied, authorizedAlways, authorizedWhenInUse
    static var locationServiceStateStatus: CLAuthorizationStatus {
        if  locationServicesEnabledForDevice {
            return locationAuthorizationStatus
        }
        return .notDetermined
    }
    
    static var locationServiceEnabledForApplication: Bool {
        return locationServiceStateStatusForApplication == .authorizedAlways
        || locationServiceStateStatusForApplication == .authorizedWhenInUse
    }
    
    // notDetermined, restricted, denied, authorizedAlways, authorizedWhenInUse
    static var locationServiceStateStatusForApplication: VisilabsCLAuthorizationStatus {
        return VisilabsCLAuthorizationStatus(rawValue: locationServiceStateStatus.rawValue) ?? .none
    }
}

