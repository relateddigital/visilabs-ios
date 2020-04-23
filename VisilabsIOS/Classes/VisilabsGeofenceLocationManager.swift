//
//  VisilabsGeofenceLocationManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import Foundation
import CoreLocation

class VisilabsGeofenceLocationManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager? /*The internal operating iOS object. */
    var sentGeoLocationValue: CLLocationCoordinate2D? /*sent by log location 20 */
    var sentGeoLocationTime: TimeInterval = 0.0 //for calculate time delta to prevent too often location update notification send.
    var reachability: VisilabsReachability?
    
    //TODO: bu initialize'ı incele, override?, SH'leri uçur
    class func initialize2() {
        var initialDefaults: [String : Any] = [:]
        initialDefaults["SH_FG_INTERVAL"] = 1 //value for location update time interval in FG
        initialDefaults["SH_FG_DISTANCE"] = 100 //value for location update distance in FG
        initialDefaults["SH_BG_INTERVAL"] = 5 //value for location update time interval in BG
        initialDefaults["SH_BG_DISTANCE"] = 500 //value for location update distance in BG
        UserDefaults.standard.register(defaults: initialDefaults)
    }
    
    private static let sharedInstanceSharedLocationManager: VisilabsGeofenceLocationManager? = {
        var sharedLocationManager = VisilabsGeofenceLocationManager()
        return sharedLocationManager
    }()

    //TODO: sharedInstance düzgün çalışıyor mu incele
    class func sharedInstance() -> VisilabsGeofenceLocationManager {
        // `dispatch_once()` call was converted to a static variable initializer
        return sharedInstanceSharedLocationManager!
    }
    
}
