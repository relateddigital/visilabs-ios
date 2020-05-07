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

class VisilabsGeofenceLocationManager: NSObject {
    
    var locationManager: CLLocationManager? /*The internal operating iOS object. */
    var sentGeoLocationValue: CLLocationCoordinate2D? /*sent by log location 20 */
    var sentGeoLocationTime: TimeInterval = 0.0 //for calculate time delta to prevent too often location update notification send.
    var reachability: VisilabsReachability?
    
    private(set) var geolocationMonitorState: SHGeoLocationMonitorState?
    
    
    // MARK: - visit geo location detective result
    var currentGeoLocationValue: CLLocationCoordinate2D?
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
    
    func requestPermissionSinceiOS8() {
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
    
    @discardableResult
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
            //TODO:forced unwrap kaldırılmalı mı?, "SHErrorDomain" VisilabsConfig'e
            self.locationManager(self.locationManager!, didFailWithError: NSError(domain: "SHErrorDomain", code: CLError.Code.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "Device not capable to monitor region: \(region)."]))
            return false
        }
 
        //check whether this region is already monitored. if same region is monitored ignore this call; if not same region but with same identifier is monitored, print warning.
        var sameIdRegion: CLRegion? = nil
        
        
        self.locationManager?.monitoredRegions.forEach({ (monitoredRegion) in
            if monitoredRegion.identifier.compare(region.identifier, options: .caseInsensitive, range: nil, locale: .current) == .orderedSame {
                sameIdRegion = monitoredRegion //find one already monitored with same identifier
            }
        })
        
        if let sameIdRegion = sameIdRegion{
            if self.isRegionSame(sameIdRegion, with: region){
                return false
            }else{
                print("Warning: same identifier region \(sameIdRegion) monitored. Add new \(region) will remove the already monitored one.")
            }
        }
        
        print("LocationManager Action: Start monitor region %@.", region);
        locationManager?.startMonitoring(for: region)
        //TODO: "Region" ı VisilabsConfig e aktar
        let userInfo = ["Region": region]
        //TODO: "SHLMStartMonitorRegionNotification" ı VisilabsConfig e aktar
        let notification = Notification( name: Notification.Name(rawValue: "SHLMStartMonitorRegionNotification"), object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)
        return true
    }
    
    func stopMonitorRegion(_ region: CLRegion) {
        if VisilabsGeofenceApp.sharedInstance() == nil || !VisilabsGeofenceApp.sharedInstance()!.isLocationServiceEnabled {
            return //initialize CLLocationManager but cannot call any function to avoid promote.
        }
        var isFound = false
        self.locationManager?.monitoredRegions.forEach({ (monitoredRegion) in
            if self.isRegionSame(monitoredRegion, with: region){
                isFound = true
            }
        })
        if isFound{
            print("LocationManager Action: Stop monitor region \(region).")
            self.locationManager?.stopMonitoring(for: region)
            //TODO: "SHLMStopMonitorRegionNotification", "Region" VisilabsConfig e taşı
            let notification = Notification(name: Notification.Name(rawValue: "SHLMStopMonitorRegionNotification"), object: self, userInfo: ["Region": region])
            NotificationCenter.default.post(notification)
        }
    }
    
    
    // MARK: - private functions
    
    private func sendGeoLocationUpdate(){
        if let si = VisilabsGeofenceApp.sharedInstance(), si.reportWorkHomeLocationOnly{
            return; //not send logline 20.
        }
        //TODO: geofence latitude veya longitude 0 olabilir. kontrol et.
        if (self.currentGeoLocation?.latitude == 0 || self.currentGeoLocation?.longitude == 0){
            return; //if current location is not detected, not send log 20.
        }
        if reachability?.connection != VisilabsReachability.Connection.wifi && reachability?.connection != VisilabsReachability.Connection.cellular {
            return //only do location 20 when network available
        }
        
        let isFG = UIApplication.shared.applicationState != .background //When asking for permission it's InActive
        let minTimeBWEvents: Double = isFG ? fgMinTimeBetweenEvents * 60 : bgMinTimeBetweenEvents * 60
        let minDistanceBWEvents = isFG ? fgMinDistanceBetweenEvents : bgMinDistanceBetweenEvents
        let timeDelta = Date().timeIntervalSince1970 - sentGeoLocationTime
        
        if let cgl = self.currentGeoLocation, let sgl = self.sentGeoLocationValue{
            //TODO: bu hesaplamalar ve kontroller doğru mu?
            let distSquared = VisilabsHelper.distanceSquared(lat1: cgl.latitude, lng1: cgl.longitude, lat2: sgl.latitude, lng2: sgl.longitude)
            let distanceDelta = Float(sqrt(distSquared))
            if (sgl.latitude == 0 || sgl.longitude == 0) /*if not send before, do it anyway */ || ((timeDelta >= minTimeBWEvents) && (distanceDelta >= minDistanceBWEvents)) {
                print("LocationManager Delegate: FG (\(isFG ? "Yes" : "No")), new location (\(cgl.latitude), \(cgl.longitude)), old location (\(sgl.latitude), \(sgl.longitude)), distance (\(distanceDelta) >= \(minDistanceBWEvents)), last time (\(Date(timeIntervalSince1970: sentGeoLocationTime))), time delta (\(timeDelta) >= \(minTimeBWEvents)).")
                self.sentGeoLocationValue = currentGeoLocation //do it early
                self.sentGeoLocationTime = Date().timeIntervalSince1970
                //Only send logline 20 when have location bridge. Above check must kept here because the internal variables cannot move to SHLocationBridge.
            }
        }
    }
    
    func isRegionSame(_ r1: CLRegion?, with r2: CLRegion?) -> Bool {
        if r1 == nil && r2 == nil {
            return true
        }

        //CLCircularRegion compares identifier.
        if let gr1 = r1 as? CLCircularRegion, let gr2 = r2 as? CLCircularRegion{
            return gr1.identifier == gr2.identifier
        }
        return r1?.isEqual(r2) ?? false
    }
    
    
    //handle for notification for network status change.
    @objc func networkStatusChanged(_ notification: Notification?) {
        if updateRecoverTime() {
            sendGeoLocationUpdate() //when network recover check whether need to send location update.
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
}


extension VisilabsGeofenceLocationManager: CLLocationManagerDelegate{
    
    // MARK: - CLLocationManagerDelegate implementation
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if let si = VisilabsGeofenceApp.sharedInstance(), !si.isLocationServiceEnabled {
            return //initialize CLLocationManager but cannot call any function to avoid promote.
        }
        if locations.count > 0 {
            if let previousLocation = self.currentGeoLocation{
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
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        if let si = VisilabsGeofenceApp.sharedInstance(), !si.isLocationServiceEnabled {
            return //initialize CLLocationManager but cannot call any function to avoid promote.
        }
        if let clErr = error as? CLError, clErr.code == CLError.Code.denied {
            //TODO: "LOCATION_DENIED_SENT" i VisilabsConfig e taşı
            let sentFlag = UserDefaults.standard.object(forKey: "LOCATION_DENIED_SENT") as? String
            if (sentFlag == nil || (sentFlag?.count ?? 0) == 0) {
                UserDefaults.standard.set("Sent", forKey: "LOCATION_DENIED_SENT")
                UserDefaults.standard.synchronize()
            }
        } else {
            print("LocationManager Delegate: Update Failed: \(error.localizedDescription)")
        }
        //TODO:"Error" ve "SHLMUpdateFailNotification" i VisilabsConfig e taşı
        let userInfo = ["Error": error]
        let notification = Notification(name: Notification.Name(rawValue: "SHLMUpdateFailNotification"), object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion){
        print("LocationManager Delegate: Enter Region: \(region.identifier)")
        if let geofences = VisilabsGeofenceStatus.sharedInstance()?.arrayGeofenceFetchList {
            for geofence in geofences {
                if (geofence.suid == region.identifier) {
                    let elements = region.identifier.components(separatedBy: "_")
                    if elements.count >= 6 {
                        let geoID = elements[5]
                        if (geofence.type == "OnEnter") {
                            //TODO: burada isEnter false geçmişim neden?
                            VisilabsHelper.sendGeofencePushNotification(actionID: elements[1], geofenceID: geoID, isDwell: false, isEnter: false)
                        }else if (geofence.type == "Dwell") {
                            VisilabsHelper.sendGeofencePushNotification(actionID: elements[1], geofenceID: geoID, isDwell: true, isEnter: true)
                        }
                    }
                }
            }
        }
        
        if let si = VisilabsGeofenceApp.sharedInstance(), !si.isLocationServiceEnabled {
            return //initialize CLLocationManager but cannot call any function to avoid promote.
        }
        //TODO: "Region" ve "SHLMEnterRegionNotification" ı VisilabsConfig e taşı
        let userInfo = ["Region": region]
        let notification = Notification( name: Notification.Name(rawValue: "SHLMEnterRegionNotification"), object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion){
        print("LocationManager Delegate: Exit Region: \(region.identifier)")
        if let geofences = VisilabsGeofenceStatus.sharedInstance()?.arrayGeofenceFetchList {
            for geofence in geofences {
                if (geofence.suid == region.identifier) {
                    let elements = region.identifier.components(separatedBy: "_")
                    if elements.count >= 6 {
                        let geoID = elements[5]
                        if (geofence.type == "OnExit") {
                            VisilabsHelper.sendGeofencePushNotification(actionID: elements[1], geofenceID: geoID, isDwell: false, isEnter: false)
                        }else if (geofence.type == "Dwell") {
                            VisilabsHelper.sendGeofencePushNotification(actionID: elements[1], geofenceID: geoID, isDwell: true, isEnter: false)
                        }
                    }
                }
            }
        }
        if let si = VisilabsGeofenceApp.sharedInstance(), !si.isLocationServiceEnabled {
            return //initialize CLLocationManager but cannot call any function to avoid promote.
        }
        print("LocationManager Delegate: Exit Region: \(region)")
        //TODO: "Region" ve "SHLMExitRegionNotification" ı VisilabsConfig e taşı
        let userInfo = ["Region": region]
        let notification = Notification( name: Notification.Name(rawValue: "SHLMExitRegionNotification"), object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion){
        if let si = VisilabsGeofenceApp.sharedInstance(), !si.isLocationServiceEnabled {
            return //initialize CLLocationManager but cannot call any function to avoid promote.
        }
        print("LocationManager Delegate: Monitoring started for region: \(region)")
        //TODO: "Region" ve "SHLMMonitorRegionSuccessNotification" ı VisilabsConfig e taşı
        let userInfo = ["Region": region]
        let notification = Notification(name: Notification.Name(rawValue: "SHLMMonitorRegionSuccessNotification"), object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)

        if self.locationManager != nil && self.locationManager!.responds(to: #selector(CLLocationManager.requestState(for:))) {
            self.locationManager!.requestState(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error){
        if let si = VisilabsGeofenceApp.sharedInstance(), !si.isLocationServiceEnabled {
            return //initialize CLLocationManager but cannot call any function to avoid promote.
        }
        print("LocationManager Delegate: Monitoring Failed for Region(\(region)): \(error.localizedDescription)")
        //TODO: "Region", "Error" ve "SHLMMonitorRegionFailNotification" ı VisilabsConfig e taşı, bu notification kullanılmıyor sanırım kaldırılabilir.
        let userInfo : [String : Any] = ["Region": region ?? CLRegion(), "Error": error]
        let notification = Notification(name: Notification.Name(rawValue: "SHLMMonitorRegionFailNotification"), object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion){
        if let si = VisilabsGeofenceApp.sharedInstance(), !si.isLocationServiceEnabled {
            return //initialize CLLocationManager but cannot call any function to avoid promote.
        }
        var strState = ""
        switch state {
            case .unknown:
                strState = "\"unknown\""
            case .inside:
                strState = "\"inside\""
            case .outside:
                strState = "\"outside\""
            default:
                break
        }
        print("LocationManager Delegate: Determine State \(strState) for Region \(region)")
        //TODO: "Region", "RegionState" ve "SHLMRegionStateChangeNotification" ı VisilabsConfig e taşı
        let userInfo : [String : Any] = ["Region": region, "RegionState": state]
        let notification = Notification(name: Notification.Name(rawValue: "SHLMRegionStateChangeNotification"), object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if let si = VisilabsGeofenceApp.sharedInstance(), !si.isLocationServiceEnabled {
            return //initialize CLLocationManager but cannot call any function to avoid promote.
        }
        var authStatus = ""
        switch status {
            case .notDetermined:
                authStatus = "Not determinded"
            case .restricted:
                authStatus = "Restricted"
            case .denied:
                authStatus = "Denied"
            case .authorizedAlways /*equal kCLAuthorizationStatusAuthorized (3) */:
                authStatus = "Always Authorized"
            case .authorizedWhenInUse:
                authStatus = "When in Use"
            default:
                break
        }
        print("LocationManager Delegate: Authorisation status changed: \(authStatus).")
        //TODO: "AuthStatus" ve "SHLMChangeAuthorizationStatusNotification" ı VisilabsConfig e taşı, bu notification kullanılmıyor sanırım kaldırılabilir.
        let userInfo = ["AuthStatus": status]
        let notification = Notification(name: Notification.Name(rawValue: "SHLMChangeAuthorizationStatusNotification"), object: self, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
}
