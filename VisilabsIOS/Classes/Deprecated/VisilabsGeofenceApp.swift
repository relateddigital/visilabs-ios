//
//  VisilabsGeofenceApp.swift
//  VisilabsIOS
//
//  Created by Egemen on 21.04.2020.
//

import Foundation

typealias VisilabsCallbackHandler = (Any?, Error?) -> Void

class VisilabsGeofenceApp: NSObject, UIApplicationDelegate {
    private static var instance: VisilabsGeofenceApp?
    
    private var isBridgeInitCalled = false
    private var isRegisterInstallForAppCalled = false
    private var isFinishLaunchOptionCalled = false
    private var isDebugMode = false
    
    var isDefaultLocationServiceEnabled = false
    
    private var _locationManager: VisilabsGeofenceLocationManager?
    var locationManager : VisilabsGeofenceLocationManager? {
        get { return _locationManager }
        set {
            //TODO: bunu kontrol et, bu init doğru mu?
            _locationManager = VisilabsGeofenceLocationManager()
        }
    }
    
    // hiçbir zaman set edilmiyor sanırım. kaldırılabilir.
    var reportWorkHomeLocationOnly: Bool {
        get {
            //TODO: "REPORT_WORKHOME_LOCATION_ONLY" ı VisilabsConfig e al
            return UserDefaults.standard.object(forKey: "REPORT_WORKHOME_LOCATION_ONLY") as? Bool ?? false
        }
        set {
            //TODO: "REPORT_WORKHOME_LOCATION_ONLY" ı VisilabsConfig e al
            UserDefaults.standard.set(newValue, forKey: "REPORT_WORKHOME_LOCATION_ONLY")
            UserDefaults.standard.synchronize()
            //TODO: "SH_LMBridge_StartMonitorGeoLocation" ı VisilabsConfig e al
            NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_StartMonitorGeoLocation"), object: nil)
        }
    }
    
    public class func sharedInstance() -> VisilabsGeofenceApp? {
        if instance == nil{
            instance = VisilabsGeofenceApp()
        }
        if (!instance!.isBridgeInitCalled){
            instance!.isBridgeInitCalled = true
            /*
            let geofenceBridge: AnyClass? = NSClassFromString("VisilabsGeofenceBridge")
            if let geofenceBridge = geofenceBridge {
                print("Bridge for geofence: \(geofenceBridge).")
                //TODO: "SH_InitBridge_Notification" VisilabsConfig'e taşı
                NotificationCenter.default.addObserver(geofenceBridge, selector: #selector(VisilabsGeofenceBridge.bridgeHandler(_:)), name: NSNotification.Name(rawValue: "SH_InitBridge_Notification"), object: nil)
            }
             */
            
            NotificationCenter.default.addObserver(VisilabsGeofenceBridge.self, selector: #selector(VisilabsGeofenceBridge.bridgeHandler(_:)), name: NSNotification.Name(rawValue: "SH_InitBridge_Notification"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("SH_InitBridge_Notification"), object: nil)

            //TODO: added by egemen. normally calls another methpd
            NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_CreateLocationManager"), object: nil)
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
        
        self.backgroundQueue = OperationQueue()
        self.backgroundQueue.maxConcurrentOperationCount = 1
        self.install_semaphore = DispatchSemaphore(value: 1)
        
        super.init()
        self.setupNotifications()
        
    }
    
    var isLocationServiceEnabled: Bool{
        get{
            guard let locationServiceEnabled = VisilabsDataManager.read("ENABLE_LOCATION_SERVICE") as? Bool else{
                return self.isDefaultLocationServiceEnabled
            }
            return locationServiceEnabled
        }set{
            if newValue != self.isLocationServiceEnabled {
                VisilabsDataManager.save("ENABLE_LOCATION_SERVICE", withObject: newValue)
                if newValue {
                    self.locationManager?.requestPermissionSinceiOS8()
                    NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_StartMonitorGeoLocation"), object: nil)
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_StopMonitorGeoLocation"), object: nil)
                }
                self.registerOrUpdateInstallWithHandler(handler: nil)
            }
        }
    }
    
    var install_semaphore: DispatchSemaphore
    var backgroundQueue: OperationQueue

    func registerOrUpdateInstallWithHandler(handler: VisilabsCallbackHandler?) {
        DispatchQueue.global(qos: .default).async(execute: {
            assert(!Thread.isMainThread, "registerOrUpdateInstallWithHandler wait in main thread.")
            if !Thread.isMainThread {
                (self.install_semaphore.wait(timeout: DispatchTime.distantFuture) == .success ? 0 : -1)
            }
        })
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidFinishLaunchingNotificationHandler(_:)), name: UIApplication.didFinishLaunchingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidFinishLaunchingNotificationHandler(_:)), name: NSNotification.Name("VisilabsDelayLaunchOptionsNotification"), object: nil) //handle both direct send and delay send
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActiveNotificationHandler(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackgroundNotificationHandler(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForegroundNotificationHandler(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotificationHandler(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminateNotificationHandler(_:)), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidReceiveMemoryWarningNotificationHandler(_:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timeZoneChangeNotificationHandler(_:)), name: UIApplication.significantTimeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appStatusChange(_:)), name: NSNotification.Name("SHAppStatusChangeNotification"), object: nil)
    }
    
    @objc func applicationDidFinishLaunchingNotificationHandler(_ notification: Notification?) {
        if self.isFinishLaunchOptionCalled {
            return
        }
        self.isFinishLaunchOptionCalled = true
        var isFromDelayLaunch = false
        if let n = notification{
            //TODO: rawValue == kontrolü doğru mu?
            isFromDelayLaunch = n.name.rawValue == "VisilabsDelayLaunchOptionsNotification"
        }
        
        let launchOptions = notification?.userInfo
        
        if isFromDelayLaunch {
            if let notificationInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any]{
                var dictUserInfo: [AnyHashable : Any] = [:]
                dictUserInfo["payload"] = notificationInfo
                dictUserInfo["needComplete"] = NSNumber(value: false)
                NotificationCenter.default.post(name: NSNotification.Name("SH_PushBridge_ReceiveRemoteNotification"), object: nil, userInfo: dictUserInfo)
            }
        }
        
        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_StartMonitorGeoLocation"), object: nil)
        }
        
        if UIApplication.shared.applicationState != .background {
            var dictComment: [AnyHashable : Any] = [:]
            dictComment["action"] = "App launch from not running."
            NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_UpdateGeoLocation"), object: nil)
            let lat = (UserDefaults.standard.object(forKey: "SH_GEOLOCATION_LAT") as? NSNumber)?.doubleValue ?? 0.0
            let lng = (UserDefaults.standard.object(forKey: "SH_GEOLOCATION_LNG") as? NSNumber)?.doubleValue ?? 0.0
            if lat != 0 && lng != 0 {
                dictComment["lat"] = NSNumber(value: lat)
                dictComment["lng"] = NSNumber(value: lng)
            }
        }
    
        if UIApplication.shared.responds(to: #selector(UIApplication.setMinimumBackgroundFetchInterval(_:))) {
            UIApplication.shared.setMinimumBackgroundFetchInterval(30 * 60)
        }
        
    }
    
    @objc func applicationWillResignActiveNotificationHandler( _ notification: Notification?) {
        if let userInfo = notification?.userInfo {
            print("Application will resignActive with info: \(userInfo).")
        }
    }
    
    @objc func applicationDidEnterBackgroundNotificationHandler(_ notification: Notification?) {
        if let userInfo = notification?.userInfo {
            print("Application did enter background with info: \(userInfo)")
        }
        NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_StartMonitorGeoLocation"), object: nil)
        
        //TODO:
        /*
        let backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundTask(backgroundTask)
        })
         let op = BlockOperation(block: {
             if !op.isCancelled {
                 var dictComment: [AnyHashable : Any] = [:]
                 dictComment["action"] = "App to BG."
                 NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_UpdateGeoLocation"), object: nil)
                 let lat = (UserDefaults.standard.object(forKey: "SH_GEOLOCATION_LAT") as? NSNumber)?.doubleValue ?? 0.0
                 let lng = (UserDefaults.standard.object(forKey: "SH_GEOLOCATION_LNG") as? NSNumber)?.doubleValue ?? 0.0
                 if lat != 0 && lng != 0 {
                     dictComment["lat"] = NSNumber(value: lat)
                     dictComment["lng"] = NSNumber(value: lng)
                 }
             } else {
                 self.endBackgroundTask(backgroundTask)
             }
         })
         backgroundQueue.addOperation(op)
         */
    }
    
    @objc func applicationWillEnterForegroundNotificationHandler(_ notification: Notification?) {

        if let userInfo = notification?.userInfo {
            print("Application will enter foreground with info: \(userInfo)")
        }

        var dictComment: [AnyHashable : Any] = [:]
        dictComment["action"] = "App opened from BG."
        NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_UpdateGeoLocation"), object: nil)

        let lat = (UserDefaults.standard.object(forKey: "SH_GEOLOCATION_LAT") as? NSNumber)?.doubleValue ?? 0.0
        let lng = (UserDefaults.standard.object(forKey: "SH_GEOLOCATION_LNG") as? NSNumber)?.doubleValue ?? 0.0
        if lat != 0 && lng != 0 {
            dictComment["lat"] = NSNumber(value: lat)
            dictComment["lng"] = NSNumber(value: lng)
        }

    }

    
    @objc func applicationDidBecomeActiveNotificationHandler( _ notification: Notification?) {
        if let userInfo = notification?.userInfo {
            print("Application did become active with info: \(userInfo)")
        }
        NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_StartMonitorGeoLocation"), object: nil)
        //TODO:
        //shRegularTask(nil, needComplete: false)
    }
    
    @objc func applicationWillTerminateNotificationHandler(_ notification: Notification?) {
        if let userInfo = notification?.userInfo {
            print("Application will terminate with info: \(userInfo)")
        }
        NotificationCenter.default.post(name: NSNotification.Name("SH_LMBridge_StartMonitorGeoLocation"), object: nil)
    }

    @objc func applicationDidReceiveMemoryWarningNotificationHandler(_ notification: Notification?) {
        print("Visilabs Received memory warning")
    }
    
    @objc func timeZoneChangeNotificationHandler(_ notification: Notification?) {
        //TODO:
        //checkUtcOffsetUpdate()
    }
    
    @objc func appStatusChange( _ notification: Notification?) {
        return
    }
    
    func endBackgroundTask(_ backgroundTask: UIBackgroundTaskIdentifier) {
        var backgroundTask = backgroundTask
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}

