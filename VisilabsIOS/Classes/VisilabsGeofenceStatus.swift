//
//  VisilabsGeofenceStatus.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import Foundation

/// The object to handle geofence status inside SHAppStatus.
class VisilabsGeofenceStatus: NSObject {
    /// Singleton for get app status instance.
    class func sharedInstance() -> VisilabsGeofenceStatus? {
        return nil
    }

    /// Match to `app_status` dictionary's `geofences`. It's a time stamp of server provided geofence list. If the time stamp is newer than client fetch time, client should fetch geofence list again and monitor new list; if the time stamp is NULL or empty, client should clear cached geofence and stop monitor.
    var geofenceTimestamp: String?
    var arrayGeofenceFetchList: [AnyHashable]?
}
