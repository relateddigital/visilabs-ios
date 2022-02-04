//
//  VisilabsLocationManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.08.2020.
//

import Foundation
import CoreLocation

class RelatedDigitalLocationManager: NSObject {
    
    static let sharedManager = RelatedDigitalLocationManager()
    
    var locationManager: CLLocationManager
    var lowPowerLocationManager: CLLocationManager
    var lastKnownCLAuthorizationStatus : CLAuthorizationStatus?
    var currentGeoLocationValue: CLLocationCoordinate2D?
    
    var geofenceEnabled = false
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = RelatedDigitalHelper.hasBackgroundLocationCabability() && CLLocationManager.authorizationStatus() == .authorizedAlways
        lowPowerLocationManager = CLLocationManager()
        lowPowerLocationManager = CLLocationManager()
        lowPowerLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        lowPowerLocationManager.distanceFilter = CLLocationDistance(3000)
        lowPowerLocationManager.allowsBackgroundLocationUpdates = RelatedDigitalHelper.hasBackgroundLocationCabability()
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
        if !acceptedAuthorizationStatuses.contains(RelatedDigitalLocationManager.locationServiceStateStatus) {
            return
        }
        locationManager.allowsBackgroundLocationUpdates = RelatedDigitalHelper.hasBackgroundLocationCabability() && CLLocationManager.authorizationStatus() == .authorizedAlways
        locationManager.pausesLocationUpdatesAutomatically = false
        lowPowerLocationManager.allowsBackgroundLocationUpdates = RelatedDigitalHelper.hasBackgroundLocationCabability()
        lowPowerLocationManager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 11, *) {
            lowPowerLocationManager.showsBackgroundLocationIndicator = false
        }
        lowPowerLocationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()

        self.currentGeoLocationValue = CLLocationCoordinate2DMake(0, 0)
        
        if let loc = self.locationManager.location {
            RelatedDigitalGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: loc.coordinate.latitude, lastKnownLongitude: loc.coordinate.longitude)
        }
        
    }
    
    func stopMonitorRegions() {
        for region in self.locationManager.monitoredRegions {
            if region.identifier.contains("visilabs", options: String.CompareOptions.caseInsensitive) {
                self.locationManager.stopMonitoring(for: region)
                RelatedDigitalLogger.info("stopped monitoring region: \(region.identifier)")
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
                authorizationStatus = RelatedDigitalLocationManager.sharedManager.locationManager.authorizationStatus
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
        let authorizationStatus = status ?? RelatedDigitalLocationManager.locationServiceStateStatus
        if authorizationStatus != lastKnownCLAuthorizationStatus {
            var properties = [String: String]()
            properties[RelatedDigitalConstants.locationPermissionReqKey] = authorizationStatus.queryStringValue
            RelatedDigital.callAPI().customEvent(RelatedDigitalConstants.omEvtGif, properties: properties)
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
        
        if alwaysIsEnabled, RelatedDigitalHelper.hasBackgroundLocationCabability() {
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
            RelatedDigitalLogger.warn("Your app does not have background location capability.")
            if status == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
        } else {
            RelatedDigitalLogger.error("NSLocationAlwaysAndWhenInUseUsageDescription and NSLocationWhenInUseUsageDescription plist keys missing.")
            return
        }
    }
    
    
    private let acceptedAuthorizationStatuses:[CLAuthorizationStatus] = [.authorizedAlways, .authorizedWhenInUse]
    
}

extension RelatedDigitalLocationManager: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate implementation
    
    // TO_DO: buna bak tekrardan
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        RelatedDigitalLogger.info("CLLocationManager didChangeAuthorization: status: \(status.string)")
        sendLocationPermission(status: status)
        if !self.geofenceEnabled {
            stopUpdates()
            return
        }
        requestLocationAuthorization()
        if acceptedAuthorizationStatuses.contains(status) {
            startGeofencing()
            RelatedDigitalGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: locationManager.location?.coordinate.latitude, lastKnownLongitude: locationManager.location?.coordinate.longitude)
        }
    }
    
    func locationManagerDidChangeAuthorization (_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            RelatedDigitalLogger.info("CLLocationManager didChangeAuthorization: status: \(manager.authorizationStatus.string)")
            sendLocationPermission(status: manager.authorizationStatus)
            if !self.geofenceEnabled {
                stopUpdates()
                return
            }
            requestLocationAuthorization()
            if acceptedAuthorizationStatuses.contains(manager.authorizationStatus) {
                startGeofencing()
                RelatedDigitalGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: locationManager.location?.coordinate.latitude, lastKnownLongitude: locationManager.location?.coordinate.longitude)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !self.geofenceEnabled {
            stopUpdates()
        }
        if locations.count > 0 {
            self.currentGeoLocationValue = locations[0].coordinate
            RelatedDigitalLogger.info("CLLocationManager didUpdateLocations: lat:\(locations[0].coordinate.latitude) lon:\(locations[0].coordinate.longitude)")
            RelatedDigitalGeofence.sharedManager?.getGeofenceList(lastKnownLatitude: self.currentGeoLocationValue?.latitude, lastKnownLongitude: self.currentGeoLocationValue?.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        RelatedDigitalLogger.error("CLLocationManager didFailWithError : \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let elements = region.identifier.components(separatedBy: "_")
        if elements.count == 4, elements[0] == "visilabs" {
            let actionId = elements[1]
            let geofenceId = elements[2]
            let targetEvent = elements[3]
            if targetEvent == RelatedDigitalConstants.onEnter {
                RelatedDigitalGeofence.sharedManager?.sendPushNotification(actionId: actionId, geofenceId: geofenceId, isDwell: false, isEnter: false)
            } else if targetEvent == RelatedDigitalConstants.dwell {
                RelatedDigitalGeofence.sharedManager?.sendPushNotification(actionId: actionId, geofenceId: geofenceId, isDwell: true, isEnter: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let elements = region.identifier.components(separatedBy: "_")
        if elements.count == 4, elements[0] == "visilabs" {
            let actionId = elements[1]
            let geofenceId = elements[2]
            let targetEvent = elements[3]
            if targetEvent == RelatedDigitalConstants.onExit {
                RelatedDigitalGeofence.sharedManager?.sendPushNotification(actionId: actionId, geofenceId: geofenceId, isDwell: false, isEnter: false)
            } else if targetEvent == RelatedDigitalConstants.dwell {
                RelatedDigitalGeofence.sharedManager?.sendPushNotification(actionId: actionId, geofenceId: geofenceId, isDwell: true, isEnter: false)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        RelatedDigitalLogger.info("CLLocationManager didStartMonitoringFor: region identifier: \(region.identifier)")
        self.locationManager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        RelatedDigitalLogger.error("CLLocationManager monitoringDidFailFor: region identifier: \(String(describing: region?.identifier)) error: \(error.localizedDescription)")
    }
    
    // TO_DO: buna gerek yok sanırım
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        RelatedDigitalLogger.info("CLLocationManager didDetermineState: region identifier: \(region.identifier) state: \(state)")
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
        case .denied: return RelatedDigitalConstants.locationPermissionNone
        case .authorizedAlways: return RelatedDigitalConstants.locationPermissionAlways
        case .authorizedWhenInUse: return RelatedDigitalConstants.locationPermissionAppOpen
        case .notDetermined, .restricted: return RelatedDigitalConstants.locationPermissionNone
        @unknown default: return RelatedDigitalConstants.locationPermissionNone
        }
    }
}
