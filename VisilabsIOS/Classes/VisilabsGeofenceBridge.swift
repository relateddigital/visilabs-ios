//
//  VisilabsGeofenceBridge.swift
//  VisilabsIOS
//
//  Created by Egemen on 21.04.2020.
//

import Foundation

/**
Bridge for handle geofence module notifications.
*/
class VisilabsGeofenceBridge {
    
    /**
    Static entry point for bridge init.
    */
    class func bridgeHandler(_ notification: Notification?) {
        
        VisilabsGeofenceApp.sharedInstance()?.isDefaultLocationServiceEnabled = true

        //TODO: SH_LMBridge_CreateLocationManager'ları visilabsconfig e taşı
        NotificationCenter.default.addObserver(self, selector: #selector(createLocationManagerHandler(_:)), name: NSNotification.Name("SH_LMBridge_CreateLocationManager"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setGeofenceTimestampHandler(_:)), name: NSNotification.Name("SH_LMBridge_SetGeofenceTimestamp"), object: nil)

        //TODO: timestamp tarihini değiştirirsem ne olur?, SH_LMBridge_SetGeofenceTimestamp i visilabsconfig e taşı
        NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_SetGeofenceTimestamp"), object: nil, userInfo: [ "timestamp": "2016-01-01"])
 
    }
    
    // MARK: - private functions
    
    class func geofenceTimestampTimer() -> Timer? {
        return nil
    }

    class func setGeofenceTimestampTimer(_ timer: Timer?) {
        
    }
    
    //TODO: @objc kaldırılabiliyor mu kontrol et, private yapılabiliyor mu kontrol et
    @objc class func createLocationManagerHandler(_ notification: Notification?) {
        if VisilabsGeofenceApp.sharedInstance()!.locationManager == nil {
            VisilabsGeofenceApp.sharedInstance()!.locationManager = VisilabsGeofenceLocationManager.sharedInstance() //cannot move to `init` because it starts `startMonitorGeoLocationStandard` when create.
        }
    }

    //TODO: @objc kaldırılabiliyor mu kontrol et
    @objc class func setGeofenceTimestampHandler(_ notification: Notification?) {
        if self.geofenceTimestampTimer() != nil {
            self.geofenceTimestampTimer()!.invalidate()
        }
        self.setGeofenceTimestampTimer(nil)
        
        //TODO: buradaki timeInterval i visilabsconfig e taşı
        self.setGeofenceTimestampTimer(Timer.scheduledTimer(timeInterval: 900, target: self, selector: #selector(setHandler), userInfo: nil, repeats: true))
        self.geofenceTimestampTimer()!.fire()
    }
}
