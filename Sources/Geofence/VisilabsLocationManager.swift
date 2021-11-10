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
    
    var locationManager: CLLocationManager
    var lowPowerLocationManager: CLLocationManager
    var lastKnownCLAuthorizationStatus : CLAuthorizationStatus?
    var currentGeoLocationValue: CLLocationCoordinate2D?
    
    var geofenceEnabled = false
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = VisilabsHelper.hasBackgroundLocationCabability() && CLLocationManager.authorizationStatus() == .authorizedAlways
        lowPowerLocationManager = CLLocationManager()
        lowPowerLocationManager = CLLocationManager()
        lowPowerLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        lowPowerLocationManager.distanceFilter = CLLocationDistance(3000)
        lowPowerLocationManager.allowsBackgroundLocationUpdates = VisilabsHelper.hasBackgroundLocationCabability()
        super.init()
        locationManager.delegate = self
    }
    
    deinit {
        locationManager.delegate = nil
        lowPowerLocationManager.delegate = nil
        NotificationCenter.default.removeObserver(self)// TO_DO: buna gerek var mı tekrar kontrol et.
    }
    
    
    func startGeofencing() {
        geofenceEnabled = true
        requestLocationAuthorization()
        if !acceptedAuthorizationStatuses.contains(VisilabsLocationManager.locationServiceStateStatus) {
            return
        }
        locationManager.allowsBackgroundLocationUpdates = VisilabsHelper.hasBackgroundLocationCabability() && CLLocationManager.authorizationStatus() == .authorizedAlways
        locationManager.pausesLocationUpdatesAutomatically = false
        lowPowerLocationManager.allowsBackgroundLocationUpdates = VisilabsHelper.hasBackgroundLocationCabability()
        lowPowerLocationManager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 11, *) {
            lowPowerLocationManager.showsBackgroundLocationIndicator = false
        }
        lowPowerLocationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()

        self.currentGeoLocationValue = CLLocationCoordinate2DMake(0, 0)
        
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
    
    func stopUpdates() {
        stopMonitorRegions()
        locationManager.stopMonitoringSignificantLocationChanges()
        lowPowerLocationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        lowPowerLocationManager.stopUpdatingLocation()
        
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
    
    func sendLocationPermission(status: CLAuthorizationStatus? = nil, geofenceEnabled: Bool = true) {
        let authorizationStatus = status ?? VisilabsLocationManager.locationServiceStateStatus
        if authorizationStatus != lastKnownCLAuthorizationStatus {
            var properties = [String: String]()
            properties[VisilabsConstants.locationPermissionReqKey] = authorizationStatus.queryStringValue
            Visilabs.callAPI().customEvent(VisilabsConstants.omEvtGif, properties: properties)
            lastKnownCLAuthorizationStatus = authorizationStatus
        }
        if !geofenceEnabled {
            self.geofenceEnabled = false
            stopUpdates()
        }
    }
    
    
    func startMonitorRegion(region: CLRegion) {
        if CLLocationManager.isMonitoringAvailable(for: type(of: region)) {
            locationManager.startMonitoring(for: region)
        }
    }
    
    public func requestLocationAuthorization() {
        var status: CLAuthorizationStatus = .notDetermined
        if #available(iOS 14.0, *) {
            status = self.locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        let alwaysIsEnabled = Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil
        let onlyInUseEnabled = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil
        
        if alwaysIsEnabled, VisilabsHelper.hasBackgroundLocationCabability() {
            if #available(iOS 13.4, *) {
                if status == .notDetermined {
                    self.locationManager.requestWhenInUseAuthorization()
                } else if status == .authorizedWhenInUse {
                    self.locationManager.requestAlwaysAuthorization()
                }
            } else {
                self.locationManager.requestAlwaysAuthorization()
            }
        } else if onlyInUseEnabled {
            VisilabsLogger.warn("Your app does not have background location capability.")
            if status == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        } else {
            VisilabsLogger.error("NSLocationAlwaysAndWhenInUseUsageDescription and NSLocationWhenInUseUsageDescription plist keys missing.")
            return
        }
    }
    
    
    private let acceptedAuthorizationStatuses:[CLAuthorizationStatus] = [.authorizedAlways, .authorizedWhenInUse]
    
}

extension VisilabsLocationManager: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate implementation
    
    // TO_DO: buna bak tekrardan
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        VisilabsLogger.info("CLLocationManager didChangeAuthorization: status: \(status.string)")
        sendLocationPermission(status: status)
        if !self.geofenceEnabled {
            stopUpdates()
            return
        }
        requestLocationAuthorization()
        if acceptedAuthorizationStatuses.contains(status) {
            startGeofencing()
            VisilabsGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: locationManager.location?.coordinate.latitude, lastKnownLongitude: locationManager.location?.coordinate.longitude)
        }
    }
    
    func locationManagerDidChangeAuthorization (_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            VisilabsLogger.info("CLLocationManager didChangeAuthorization: status: \(manager.authorizationStatus.string)")
            sendLocationPermission(status: manager.authorizationStatus)
            if !self.geofenceEnabled {
                stopUpdates()
                return
            }
            requestLocationAuthorization()
            if acceptedAuthorizationStatuses.contains(manager.authorizationStatus) {
                startGeofencing()
                VisilabsGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: locationManager.location?.coordinate.latitude, lastKnownLongitude: locationManager.location?.coordinate.longitude)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !self.geofenceEnabled {
            stopUpdates()
        }
        if locations.count > 0 {
            self.currentGeoLocationValue = locations[0].coordinate
            VisilabsLogger.info("CLLocationManager didUpdateLocations: lat:\(locations[0].coordinate.latitude) lon:\(locations[0].coordinate.longitude)")
            VisilabsGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: self.currentGeoLocationValue?.latitude, lastKnownLongitude: self.currentGeoLocationValue?.longitude)
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
                VisilabsGeofence.sharedManager?.sendPushNotification(actionId: actionId, geofenceId: geofenceId, isDwell: false, isEnter: false)
            } else if targetEvent == VisilabsConstants.dwell {
                VisilabsGeofence.sharedManager?.sendPushNotification(actionId: actionId, geofenceId: geofenceId, isDwell: true, isEnter: true)
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
                VisilabsGeofence.sharedManager?.sendPushNotification(actionId: actionId, geofenceId: geofenceId, isDwell: false, isEnter: false)
            } else if targetEvent == VisilabsConstants.dwell {
                VisilabsGeofence.sharedManager?.sendPushNotification(actionId: actionId, geofenceId: geofenceId, isDwell: true, isEnter: false)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        VisilabsLogger.info("CLLocationManager didStartMonitoringFor: region identifier: \(region.identifier)")
        self.locationManager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        VisilabsLogger.error("CLLocationManager monitoringDidFailFor: region identifier: \(String(describing: region?.identifier)) error: \(error.localizedDescription)")
    }
    
    // TO_DO: buna gerek yok sanırım
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        VisilabsLogger.info("CLLocationManager didDetermineState: region identifier: \(region.identifier) state: \(state)")
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
        case .notDetermined, .restricted: return VisilabsConstants.locationPermissionNone
        @unknown default: return VisilabsConstants.locationPermissionNone
        }
    }
}
