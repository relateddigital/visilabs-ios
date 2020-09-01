//
//  VisilabsLocationManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.08.2020.
//

import Foundation
import CoreLocation

class VisilabsLocationManager : NSObject {
    
    public static let sharedManager = VisilabsLocationManager()
    
    
    
    private var locationManager: CLLocationManager?
    private var requestLocationAuthorizationCallback: ((CLAuthorizationStatus) -> Void)?
    
    
    var currentGeoLocationValue: CLLocationCoordinate2D?
    var sentGeoLocationValue: CLLocationCoordinate2D? //TODO: ne işe yarayacak bu?
    var sentGeoLocationTime: TimeInterval? //for calculate time delta to prevent too often location update notification send.
    var locationServiceEnabled = false
    
    override init(){
        super.init()
    }
    
    deinit {
        locationManager?.delegate = nil
        NotificationCenter.default.removeObserver(self)// TODO: buna gerek var mı tekrar kontrol et.
    }
    
    func stopMonitorRegions(){
        if let regions = self.locationManager?.monitoredRegions {
            for region in regions {
                if region.identifier.contains("visilabs", options: String.CompareOptions.caseInsensitive){
                    self.locationManager?.stopMonitoring(for: region)
                    VisilabsLogger.info("stopped monitoring region: \(region.identifier)")
                }
            }
        }
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
        //TODO:bunu yayınlarken tekrar 100e çek
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // kCLLocationAccuracyHundredMeters
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
        if !locationServiceEnabled {
            return
        } else if (locations.count > 0){
            self.currentGeoLocationValue = locations[0].coordinate
            VisilabsLogger.info("CLLocationManager didUpdateLocations: lat:\(locations[0].coordinate.latitude) lon:\(locations[0].coordinate.longitude)")
        }
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
