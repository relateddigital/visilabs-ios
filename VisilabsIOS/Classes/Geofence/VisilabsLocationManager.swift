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
    var sentGeoLocationValue: CLLocationCoordinate2D? //TODO: ne işe yarayacak bu?
    var sentGeoLocationTime: TimeInterval? //for calculate time delta to prevent too often location update notification send.
    var locationServiceEnabled = false
    
    override init(){
        super.init()
        createLocationManager()
    }
    
    deinit {
        locationManager?.delegate = nil
        NotificationCenter.default.removeObserver(self)// TODO: buna gerek var mı tekrar kontrol et.
    }
    
    func createLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        #if !TARGET_IPHONE_SIMULATOR
        if self.locationManager?.responds(to: #selector(setter: CLLocationManager.pausesLocationUpdatesAutomatically)) ?? false {
            self.locationManager?.pausesLocationUpdatesAutomatically = false
        }
        #endif
        self.requestLocationAuthorization()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager?.distanceFilter = CLLocationDistance(10)
        self.currentGeoLocationValue = CLLocationCoordinate2DMake(0, 0)
        self.sentGeoLocationValue = CLLocationCoordinate2DMake(0, 0)
        self.sentGeoLocationTime = 0
        
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            VisilabsLogger.info("Start significant location update.")
            locationManager?.startMonitoringSignificantLocationChanges()
            locationServiceEnabled = true
        }
        
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
    
    //TODO: buna bak tekrardan
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.requestLocationAuthorizationCallback?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        VisilabsLogger.info("CLLocationManager didUpdateLocations")
        
        if !locationServiceEnabled {
            return
        } else if (locations.count > 0){
            
        }
        
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    
    }
}
