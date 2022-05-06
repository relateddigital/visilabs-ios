//
//  VisilabsGeofenceOptions.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 11.04.2022.
//

import Foundation
import CoreLocation

class VisilabsGeofenceOptions {
    var desiredStoppedUpdateInterval = 0
    var desiredMovingUpdateInterval = 150
    var desiredSyncInterval = 20
    var desiredAccuracy = DesiredAccuracy.medium
    var stopDuration = 140
    var stopDistance = 70
    var replay = Replay.none
    var syncLocations = SyncLocations.syncAll
    var showBlueBar = false
    var useStoppedGeofence = true
    var stoppedGeofenceRadius = 100
    var useMovingGeofence = false
    var movingGeofenceRadius = 0
    var syncGeofences = true
    var useSignificantLocationChanges = true
    
    var desiredCLLocationAccuracy: CLLocationAccuracy {
        if desiredAccuracy == .medium {
            return kCLLocationAccuracyHundredMeters
        } else if desiredAccuracy == .high {
            return kCLLocationAccuracyBest
        } else {
            return kCLLocationAccuracyKilometer
        }
    }
    
    var locationBackgroundMode: Bool {
        let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String]
        return backgroundModes != nil && backgroundModes?.contains("location") ?? false
    }
    
}

enum DesiredAccuracy: Int {
    case high
    case medium
    case low
}

enum Replay: Int {
    case stops
    case none
}

enum SyncLocations: Int {
    case syncAll
    case syncStopsAndExits
    case syncNone
}

