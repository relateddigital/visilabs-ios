//
//  VisilabsGeofenceLocationManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import Foundation
import CoreLocation

/// The state of current geolocation update.
enum SHGeoLocationMonitorState : Int {
    /// Not monitor geolocation.
    case Stopped
    /// Monitor geolocation in standard way, called by `startUpdatingLocation`.
    case MonitorStandard
    /// Monitor geolocation in significant change way, called by `startMonitoringSignificantLocationChanges`.
    case MonitorSignificant
}

//TODO:
let SHLocation_FG_Interval = 1
let SHLocation_FG_Distance = 100
let SHLocation_BG_Interval = 5
let SHLocation_BG_Distance = 500

class VisilabsGeofenceLocationManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager? /*The internal operating iOS object. */
    var sentGeoLocationValue: CLLocationCoordinate2D? /*sent by log location 20 */
    var sentGeoLocationTime: TimeInterval = 0.0 //for calculate time delta to prevent too often location update notification send.
    var reachability: VisilabsReachability?
    
    private(set) var geolocationMonitorState: SHGeoLocationMonitorState?
    
    
    // MARK: - visit geo location detective result
    var currentGeoLocation : CLLocationCoordinate2D? {
        get {
            if VisilabsGeofenceLocationManager.locationServiceEnabled(forApp: false){ //If location service disabled, this local value is meaningless.
                return self.currentGeoLocationValue
            }else{
                return CLLocationCoordinate2DMake(0, 0)
            }
        }
    }
    
    
    
    var desiredAccuracy: CLLocationAccuracy = 0
    
    //TODO: hiçbir yerde kullanılmıyor sanırım, kaldırılabilir
    var distanceFilter: CLLocationDistance = 0
    
    
    var fgMinTimeBetweenEvents: TimeInterval {
        get {
            //TODO: "SH_FG_INTERVAL" ı VisilabsConfig e al
            let value = TimeInterval(UserDefaults.standard.object(forKey: "SH_FG_INTERVAL") as? Double ?? 0.0)
            assert(value >= 0, "Not find suitable value for SH_FG_INTERVAL")
            if value >= 0 {
                return value
            } else {
                //TODO:
                return TimeInterval(SHLocation_FG_Interval)
            }
        }
        set {
            if newValue >= 0 {
                //TODO: "SH_FG_INTERVAL" ı VisilabsConfig e al
                UserDefaults.standard.set(newValue, forKey: "SH_FG_INTERVAL")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    var fgMinDistanceBetweenEvents: Float {
        get {
            //TODO: "SH_FG_DISTANCE" ı VisilabsConfig e al
            let value = UserDefaults.standard.object(forKey: "SH_FG_DISTANCE") as? Float ?? 0.0
            assert(value >= 0, "Not find suitable value for SH_FG_DISTANCE")
            if value >= 0 {
                return value
            } else {
                return Float(SHLocation_FG_Distance)
            }
        }
        set {
            if newValue >= 0 {
                //TODO: "SH_FG_DISTANCE" ı VisilabsConfig e al
                UserDefaults.standard.set(newValue, forKey: "SH_FG_DISTANCE")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    var bgMinTimeBetweenEvents: TimeInterval {
        get {
            //TODO: "SH_BG_INTERVAL" ı VisilabsConfig e al
            let value = TimeInterval(UserDefaults.standard.object(forKey: "SH_BG_INTERVAL") as? Double ?? 0.0)
            assert(value >= 0, "Not find suitable value for SH_BG_INTERVAL")
            if value >= 0 {
                return value
            } else {
                //TODO:
                return TimeInterval(SHLocation_BG_Interval)
            }
        }
        set {
            if newValue >= 0 {
                //TODO: "SH_BG_INTERVAL" ı VisilabsConfig e al
                UserDefaults.standard.set(NSNumber(value: newValue), forKey: "SH_BG_INTERVAL")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    var bgMinDistanceBetweenEvents: Float {
        get {
            //TODO: "SH_BG_DISTANCE" ı VisilabsConfig e al
            let value = UserDefaults.standard.object(forKey: "SH_BG_DISTANCE") as? Float ?? 0.0
            assert(value >= 0, "Not find suitable value for SH_BG_DISTANCE")
            if value >= 0 {
                return value
            } else {
                return Float(SHLocation_BG_Distance)
            }
        }
        set {
            if newValue >= 0 {
                //TODO: "SH_BG_DISTANCE" ı VisilabsConfig e al
                UserDefaults.standard.set(newValue, forKey: "SH_BG_DISTANCE")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    // TODO: burada weak vardı, gerek var mı?
    var monitoredRegions: [CLRegion]? {
        get {
            return Array(self.locationManager?.monitoredRegions ?? [])
        }
    }
    
    
    var geofenceMaximumRadius: CLLocationDistance {
        get { return locationManager?.maximumRegionMonitoringDistance ?? CLLocationDistance()}
    }
    
    
    
    var currentGeoLocationValue: CLLocationCoordinate2D?
    
    // MARK: - life cycle
    
    //TODO: bu initialize'ı incele, override?, SH'leri uçur, kullanılmıyorsa sil
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
    
    override init() {
        super.init()
        createLocationManager()
        createNetworkMonitor()
    }
    
    //create internal operating iOS object.
    func createLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        #if !TARGET_IPHONE_SIMULATOR
        if locationManager?.responds(to: #selector(setter: CLLocationManager.pausesLocationUpdatesAutomatically)) ?? false {
            locationManager?.pausesLocationUpdatesAutomatically = false //since iOS 6.0, if error happen whether pause location update to save battery? Set to NO so that retrying and keeping report.
        }
        #endif
        
        requestPermissionSinceiOS8()

        desiredAccuracy = kCLLocationAccuracyHundredMeters
        distanceFilter = CLLocationDistance(10.0)

        //initialize detecting location
        currentGeoLocationValue = CLLocationCoordinate2DMake(0, 0)

        sentGeoLocationValue = CLLocationCoordinate2DMake(0, 0)
        sentGeoLocationTime = 0 //not update yet
        geolocationMonitorState = SHGeoLocationMonitorState.Stopped
        
        //TODO: bu niye var,SH_LMBridge_StartMonitorGeoLocation ı VisilabsConfig e taşı
        NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_StartMonitorGeoLocation"), object: nil)

        //bunu sonradan ekledim.
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            //TODO: print i kaldır
            print("LocationManager Action: Start significant location update.")
            locationManager?.startMonitoringSignificantLocationChanges()
            geolocationMonitorState = SHGeoLocationMonitorState.MonitorSignificant
        }
    }
    
    //TODO: implement
    //create Reachability to monitor network status change.
    func createNetworkMonitor() {
        do{
            reachability = try VisilabsReachability()
            //TODO ReachabilityChangedNotification ismini VisilabsReachabilityChangedNotification olarak değiştirmeme gerek var mı?
            NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged(_:)), name: Notification.Name.reachabilityChanged, object: nil)
            try reachability?.startNotifier()
        }catch {
            print("createNetworkMonitor error: \(error.localizedDescription)")
        }
        updateRecoverTime() //notifier not trigger when start, update to correct value in initalize.
    }
    
    deinit {
        locationManager?.delegate = nil
        NotificationCenter.default.removeObserver(self)
        reachability?.stopNotifier()
    }
    
    // MARK: - check system setup app's enable
    
    //TODO: çağırıldığı yerleri kontrol et
    class func locationServiceEnabled(forApp allowNotDetermined: Bool) -> Bool {
        //Since iOS 8 must add key in Info.plist otherwise location service won't start.
        let locationAlwaysStr = Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") as? String
        let locationWhileInUseStr = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") as? String
        if locationAlwaysStr == nil && locationWhileInUseStr == nil {
            return false //this iOS 8 App not configure location service key, it's not enabled. cannot avoid this check as it's [CLLocationManager authorizationStatus] is kCLAuthorizationStatusNotDetermined.
        }
        guard let va = VisilabsGeofenceApp.sharedInstance() else{
            return false
        }
        if !va.isLocationServiceEnabled || !CLLocationManager.locationServicesEnabled() {
            return false
        }
        
        var isEnabled: Bool
        //TODO: buradaki authorized'ları kontrol et.
        if allowNotDetermined {
            isEnabled = CLLocationManager.authorizationStatus() == .authorized //Individual App location service is enabled.*/ || CLLocationManager.authorizationStatus() == .authorizedAlways /*Sinc iOS 8, equal to kCLAuthorizationStatusAuthorized*/ || CLLocationManager.authorizationStatus() == .authorizedWhenInUse /*Since iOS 8, */ || CLLocationManager.authorizationStatus() == .notDetermined /*Need this also, otherwise not ask for permission at first launch.
        } else {
            isEnabled = CLLocationManager.authorizationStatus() == .authorized //Individual App location service is enabled.*/ || CLLocationManager.authorizationStatus() == .authorizedAlways /*Sinc iOS 8, equal to kCLAuthorizationStatusAuthorized*/ || CLLocationManager.authorizationStatus() == .authorizedWhenInUse /*Since iOS 8,
        }
        
        if isEnabled {
            //TODO: "LOCATION_DENIED_SENT" 'i VisilabsConfig e aktar
            if let sentFlag = UserDefaults.standard.object(forKey: "LOCATION_DENIED_SENT") as? String, sentFlag.count > 0 {
                //clear location denied flag
                UserDefaults.standard.set("", forKey: "LOCATION_DENIED_SENT")
                UserDefaults.standard.synchronize()
            }
        }
        return isEnabled
    }
    
    // MARK: - operation
    
    private func requestPermissionSinceiOS8() {
        let status = CLLocationManager.authorizationStatus()
        let enabled = VisilabsGeofenceApp.sharedInstance()?.isLocationServiceEnabled ?? false
        if enabled && status == .notDetermined {
            let locationAlwaysStr = Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") as? String
            if locationAlwaysStr != nil { //if customer added "Always" uses this permission, recommended. cannot check length != 0 because Info.plist can add empty string for these key and location is enabled.
                if locationManager?.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) ?? false {
                    locationManager?.requestAlwaysAuthorization() //since iOS 8.0, must request for one authorization type, meanwhile, customer App must add `NSLocationAlwaysUsageDescription` in Info.plist.
                }
            }else{
                let locationWhileInUseStr = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") as? String
                if locationWhileInUseStr != nil {
                    if locationManager?.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) ?? false {
                        locationManager?.requestWhenInUseAuthorization() //since iOS 8.0, if Always not available, try WhenInUse as secondary option.
                    }
                }
            }
        }
    }
    
    func startMonitorRegion(_ region: CLRegion) -> Bool {
        if let shared = VisilabsGeofenceApp.sharedInstance(), !shared.isLocationServiceEnabled{
            return false //initialize  CLLocationManager but cannot call any function to avoid promote.
        }
        self.requestPermissionSinceiOS8() //request before action, it simply return if not suitable.
        var isMonitorRegionAvailable = VisilabsGeofenceLocationManager.locationServiceEnabled(forApp: false)
        
        if isMonitorRegionAvailable {
            /*
            if CLLocationManager.responds(to: #selector(CLLocationManager.isMonitoringAvailable(for:))) { //TODO: bu kontrole gerek var mı? derleme hatası oluyor.
                isMonitorRegionAvailable = CLLocationManager.isMonitoringAvailable(for: type(of: region))
            } else {
                isMonitorRegionAvailable = false //[CLLocationManager regionMonitoringAvailable];
            }
 */
            isMonitorRegionAvailable = CLLocationManager.isMonitoringAvailable(for: type(of: region))
        }else{
            
        }
 
        
        
        return true
    }
    
    
    
    //handle for notification for network status change.
    @objc func networkStatusChanged(_ notification: Notification?) {
        if updateRecoverTime() {
            //TODO: uncomment
            //sendGeoLocationUpdate() //when network recover check whether need to send location update.
        }
    }
    
    //update NETWORK_RECOVER_TIME value. Return YES if connect and non-connect change.
    //TODO: dönüş tipi kullanılmıyorsa void yap
    @discardableResult
    func updateRecoverTime() -> Bool {
        var recoverTime: TimeInterval = 0
        //TODO: "NETWORK_RECOVER_TIME" ı VisilabsConfig e taşı
        if let recoverTimeValue = UserDefaults.standard.object(forKey: "NETWORK_RECOVER_TIME") as? Double{
            recoverTime = TimeInterval(recoverTimeValue)
        }
        if let r = self.reachability, r.connection == VisilabsReachability.Connection.unavailable{
            if recoverTime != 0 {
                UserDefaults.standard.set(0, forKey: "NETWORK_RECOVER_TIME") //not connected
                UserDefaults.standard.synchronize()
                return true
            }
        } else {
            if recoverTime == 0 {
                UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: "NETWORK_RECOVER_TIME") //connected
                UserDefaults.standard.synchronize()
                return true
            }
        }
        return false //not change
    }
    
    
    
    func stopMonitorRegion(_ region: CLRegion?) {
    }
    
}
