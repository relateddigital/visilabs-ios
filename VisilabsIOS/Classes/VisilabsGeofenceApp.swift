//
//  VisilabsGeofenceApp.swift
//  VisilabsIOS
//
//  Created by Egemen on 21.04.2020.
//

import Foundation

class VisilabsGeofenceApp: NSObject, UIApplicationDelegate {
    private static var instance: VisilabsGeofenceApp?
    
    private var isBridgeInitCalled = false
    private var isRegisterInstallForAppCalled = false
    private var isFinishLaunchOptionCalled = false
    private var isDebugMode = false

    
    public class func sharedInstance() -> VisilabsGeofenceApp? {
        if instance == nil{
            instance = VisilabsGeofenceApp()
        }
        
        if (!instance!.isBridgeInitCalled){
            instance!.isBridgeInitCalled = true
        }
        
        return instance
    }
    
    override init() {
        //TODO: SH_GEOLOCATION_LAT isimlerini değiştir ve tipi CGFloat mu olacak kontrol et
        //NSUserDefaults value for passing value between modules. It's not used as local cache for location, and before use it must have notification "SH_LMBridge_UpdateGeoLocation" to update the value.
        //#define SH_GEOLOCATION_LAT      @"SH_GEOLOCATION_LAT"
        //#define SH_GEOLOCATION_LNG      @"SH_GEOLOCATION_LNG"
        VisilabsDataManager.save("SH_GEOLOCATION_LAT", withObject: CGFloat(0))
        VisilabsDataManager.save("SH_GEOLOCATION_LNG", withObject: CGFloat(0))
        
    }
}


