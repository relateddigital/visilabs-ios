//
//  VisilabsGeofence.swift
//  VisilabsIOS
//
//  Created by Egemen on 10.06.2020.
//

import Foundation
import CoreLocation

class VisilabsGeofence {
    
    typealias VLogger = VisilabsLogger

    static let sharedManager = VisilabsGeofence()

    let profile: VisilabsProfile
    let visilabsLocationManager: VisilabsLocationManager

    init?() {
        if let profile = VisilabsPersistence.readVisilabsProfile() {
            self.profile = profile
            VisilabsHelper.setEndpoints(dataSource: self.profile.dataSource)// TO_DO: bunu if içine almaya gerek var mı?
            self.visilabsLocationManager = VisilabsLocationManager()
        } else {
            return nil
        }
    }
    
    func requestLocationPermissions() {
        visilabsLocationManager.requestLocationPermissions()
    }

    var locationServicesEnabledForDevice: Bool {
        return VisilabsGeofenceState.locationServicesEnabledForDevice
    }

    func startGeofencing() {
        _ = VisilabsLocationManager()
    }

    

}
