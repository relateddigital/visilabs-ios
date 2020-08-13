//
//  VisilabsLocationManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.08.2020.
//

import Foundation
import CoreLocation

class VisilabsLocationManager : NSObject {
    
    private var instance: VisilabsLocationManager?
    private static let sharedInstanceSharedLocationManager: VisilabsLocationManager? = {
        var sharedLocationManager = VisilabsLocationManager()
        return sharedLocationManager
    }()
    class func sharedInstance() -> VisilabsLocationManager {
        return sharedInstanceSharedLocationManager!
    }
    
    
    
    private var locationManager: CLLocationManager?
    private var requestLocationAuthorizationCallback: ((CLAuthorizationStatus) -> Void)?
    
    
    var currentGeoLocationValue: CLLocationCoordinate2D?
    
    override init(){
        super.init()
        createLocationManager()
    }
    
    func createLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        #if !TARGET_IPHONE_SIMULATOR
        if locationManager?.responds(to: #selector(setter: CLLocationManager.pausesLocationUpdatesAutomatically)) ?? false {
            locationManager?.pausesLocationUpdatesAutomatically = false
        }
        #endif
        requestLocationAuthorization()
    }
    
    public func requestLocationAuthorization() {
        let currentStatus = CLLocationManager.authorizationStatus()

        guard currentStatus == .notDetermined else { return }

        if #available(iOS 13.4, *) {
            self.requestLocationAuthorizationCallback = { status in
                if status == .authorizedWhenInUse {
                    self.locationManager?.requestAlwaysAuthorization()
                }
            }
            self.locationManager?.requestWhenInUseAuthorization()
        } else {
            self.locationManager?.requestAlwaysAuthorization()
        }
    }
}

extension VisilabsLocationManager: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate implementation
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.requestLocationAuthorizationCallback?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        print("didUpdateLocations")
        
        
        /*
        if let si = VisilabsGeofenceApp.sharedInstance(), !si.isLocationServiceEnabled {
            return //initialize CLLocationManager but cannot call any function to avoid promote.
        }
        
        
        if locations.count > 0 {
            if let previousLocation = self.currentGeoLocation {
                currentGeoLocationValue = (locations[0]).coordinate //no matter sent log or not, keep current geo location fresh.
                sendGeoLocationUpdate()
                //send out notification for location change
                let oldLocation = CLLocation(latitude: previousLocation.latitude, longitude: previousLocation.longitude)
                //TODO: "NewLocation", "OldLocation" ve "SHLMUpdateLocationSuccessNotification" ı VisilabsConfig e taşı
                let userInfo = ["NewLocation": locations[0], "OldLocation": oldLocation]
                let notification = Notification(name: Notification.Name(rawValue: "SHLMUpdateLocationSuccessNotification"), object: self, userInfo: userInfo)
                NotificationCenter.default.post(notification)
            }
        }
 */
        
    }
}
