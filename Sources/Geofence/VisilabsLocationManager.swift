//
//  VisilabsLocationManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.08.2020.
//

import Foundation
import CoreLocation

class VisilabsLocationManager: NSObject {
    
    static let sharedManager = VisilabsLocationManager()
    
    private var locationManager: CLLocationManager
    private var lastKnownCLAuthorizationStatus : CLAuthorizationStatus?
    
    var currentGeoLocationValue: CLLocationCoordinate2D?
    var sentGeoLocationValue: CLLocationCoordinate2D? // TO_DO: ne işe yarayacak bu?
    var sentGeoLocationTime: TimeInterval?
    // for calculate time delta to prevent too often location update notification send.
    var locationServiceEnabled = true //TODO var locationServiceEnabled = false
    
    var locationManagerCreated = false
    
    override init() {
        locationManager = CLLocationManager()
        locationManagerCreated = true
        super.init()
        locationManager.delegate = self
    }
    
    deinit {
        locationManager.delegate = nil
        NotificationCenter.default.removeObserver(self)// TO_DO: buna gerek var mı tekrar kontrol et.
    }
    
    
    func startGeofencing() {
#if !TARGET_IPHONE_SIMULATOR
        if locationManager.responds(to: #selector(setter: CLLocationManager.pausesLocationUpdatesAutomatically)) {
            locationManager.pausesLocationUpdatesAutomatically = false
        }
#endif
        
        requestLocationAuthorization()
        
        // TO_DO:bunu yayınlarken tekrar 100e çek
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // kCLLocationAccuracyHundredMeters
        self.locationManager.distanceFilter = CLLocationDistance(10)
        self.currentGeoLocationValue = CLLocationCoordinate2DMake(0, 0)
        self.sentGeoLocationValue = CLLocationCoordinate2DMake(0, 0)
        self.sentGeoLocationTime = 0
        
        self.locationManager.allowsBackgroundLocationUpdates = VisilabsHelper.hasBackgroundLocationCabability()
        //self.locationManager?.startUpdatingLocation()
        
        
        //self.locationManager?.startMonitoringSignificantLocationChanges()
        
        self.requestLocationAuthorization()
        
        if let loc = self.locationManager.location {
            VisilabsGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: loc.coordinate.latitude, lastKnownLongitude: loc.coordinate.longitude)
        }
        
    }
    
    func stopMonitorRegions() {
        for region in self.locationManager.monitoredRegions {
            if region.identifier.contains("visilabs", options: String.CompareOptions.caseInsensitive) {
                self.locationManager.stopMonitoring(for: region)
                VisilabsLogger.info("stopped monitoring region: \(region.identifier)")
            }
        }
    }
    
    // notDetermined, restricted, denied, authorizedAlways, authorizedWhenInUse
    static var locationServiceStateStatus: CLAuthorizationStatus {
        if locationServicesEnabledForDevice {
            var authorizationStatus: CLAuthorizationStatus = .denied
            if #available(iOS 14.0, *) {
                authorizationStatus = VisilabsLocationManager.sharedManager.locationManager.authorizationStatus
            } else {
                authorizationStatus = CLLocationManager.authorizationStatus()
            }
            return authorizationStatus
        }
        return .notDetermined
    }
    
    static var locationServicesEnabledForDevice: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func sendLocationPermission(_ status: CLAuthorizationStatus? = nil) {
        let authorizationStatus = status ?? VisilabsLocationManager.locationServiceStateStatus
        if !authorizationStatus.queryStringValue.isEmpty, authorizationStatus != lastKnownCLAuthorizationStatus {
            var properties = [String: String]()
            properties[VisilabsConstants.locationPermissionReqKey] = authorizationStatus.queryStringValue
            Visilabs.callAPI().customEvent(VisilabsConstants.omEvtGif, properties: properties)
            lastKnownCLAuthorizationStatus = authorizationStatus
        }
    }
    
    
    func startMonitorRegion(region: CLRegion) {
        if CLLocationManager.isMonitoringAvailable(for: type(of: region)) {
            locationManager.startMonitoring(for: region)
        }
    }
    
    public func requestLocationAuthorization() {
        var status = CLAuthorizationStatus.notDetermined
        if #available(iOS 14.0, *) {
            status = self.locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        let alwaysIsEnabled = Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil
        let onlyInUseEnabled = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil
        
        if alwaysIsEnabled, VisilabsHelper.hasBackgroundLocationCabability() {
            self.locationManager.requestAlwaysAuthorization()
        } else if onlyInUseEnabled {
            VisilabsLogger.warn("Your app does not have background location capability.")
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    private let acceptedAuthorization:[CLAuthorizationStatus] = [.authorizedAlways, .authorizedWhenInUse]
    
}

extension VisilabsLocationManager: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate implementation
    
    // TO_DO: buna bak tekrardan
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        VisilabsLogger.info("CLLocationManager didChangeAuthorization: status: \(status.string)")
        sendLocationPermission(status)
        if acceptedAuthorization.contains(status) {
            VisilabsGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: locationManager.location?.coordinate.latitude, lastKnownLongitude: locationManager.location?.coordinate.longitude)
        }
    }
    
    func locationManagerDidChangeAuthorization (_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            VisilabsLogger.info("CLLocationManager didChangeAuthorization: status: \(manager.authorizationStatus.string)")
            sendLocationPermission(manager.authorizationStatus)
            if acceptedAuthorization.contains(manager.authorizationStatus), let loc = self.locationManager.location {
                VisilabsGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: loc.coordinate.latitude, lastKnownLongitude: loc.coordinate.longitude)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locationServiceEnabled {
            return
        } else if locations.count > 0 {
            self.currentGeoLocationValue = locations[0].coordinate
            let infoMessage = "CLLocationManager didUpdateLocations: lat:\(locations[0].coordinate.latitude)" +
            " lon:\(locations[0].coordinate.longitude)"
            VisilabsLogger.info(infoMessage)
            VisilabsGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: self.currentGeoLocationValue?.latitude,
                                                            lastKnownLongitude: self.currentGeoLocationValue?.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        VisilabsLogger.error("CLLocationManager didFailWithError : \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let elements = region.identifier.components(separatedBy: "_")
        if elements.count == 4, elements[0] == "visilabs" {
            let actionId = elements[1]
            let geofenceId = elements[2]
            let targetEvent = elements[3]
            if targetEvent == VisilabsConstants.onEnter {
                // TO_DO: burada isEnter false geçmişim neden?
                VisilabsGeofence.sharedManager?.sendPushNotification(actionId: actionId,
                                                                     geofenceId: geofenceId,
                                                                     isDwell: false, isEnter: false)
            } else if targetEvent == VisilabsConstants.dwell {
                VisilabsGeofence.sharedManager?.sendPushNotification(actionId: actionId,
                                                                     geofenceId: geofenceId,
                                                                     isDwell: true, isEnter: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let elements = region.identifier.components(separatedBy: "_")
        if elements.count == 4, elements[0] == "visilabs" {
            let actionId = elements[1]
            let geofenceId = elements[2]
            let targetEvent = elements[3]
            if targetEvent == VisilabsConstants.onExit {
                VisilabsGeofence.sharedManager?.sendPushNotification(actionId: actionId,
                                                                     geofenceId: geofenceId,
                                                                     isDwell: false, isEnter: false)
            } else if targetEvent == VisilabsConstants.dwell {
                VisilabsGeofence.sharedManager?.sendPushNotification(actionId: actionId,
                                                                     geofenceId: geofenceId,
                                                                     isDwell: true, isEnter: false)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        VisilabsLogger.info("CLLocationManager didStartMonitoringFor: region identifier: \(region.identifier)")
        self.locationManager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        let errorMessage = "CLLocationManager monitoringDidFailFor: region identifier:" +
        " \(region?.identifier ?? "nil") error: \(error.localizedDescription)"
        VisilabsLogger.error(errorMessage)
    }
    
    // TO_DO: buna gerek yok sanırım
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        let infoMessage = "CLLocationManager didDetermineState: region identifier: \(region.identifier) state: \(state)"
        VisilabsLogger.info(infoMessage)
    }
}


extension CLAuthorizationStatus {
    var string: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        @unknown default: return "unknown \(self.rawValue)"
        }
    }
    
    var queryStringValue : String {
        switch self {
        case .denied: return VisilabsConstants.locationPermissionNone
        case .authorizedAlways: return VisilabsConstants.locationPermissionAlways
        case .authorizedWhenInUse: return VisilabsConstants.locationPermissionAppOpen
        case .notDetermined, .restricted: return ""
        @unknown default: return ""
            
        }
    }
}
