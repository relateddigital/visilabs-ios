import WebKit
import AdSupport

open class Visilabs : NSObject, VisilabsNotificationViewControllerDelegate {
    
    private static var API: Visilabs?
    private static var visilabsReachability : VisilabsReachability?
    
    private static let visilabsLockingQueue: DispatchQueue = DispatchQueue(label:"VisilabsLockingQueue")//TODO:eski SDK'da label'ın içinde profil id yazıyordu. gerekli mi?
    private let serialQueue: DispatchQueue = DispatchQueue(label:"VisilabsSerialQueue")
    
    var organizationID : String
    var siteID : String
    private var loggerURL : String
    private var dataSource : String
    private var realTimeURL : String
    private var channel : String
    private var requestTimeoutInSeconds : Int
    private var restURL : String?
    private var encryptedDataSource : String?
    internal var targetURL : String?
    private var actionURL : String?
    internal var geofenceURL : String?
    private var geofenceEnabled : Bool
    var maxGeofenceCount : Int
    
    private var sendQueue = [String]()
    private var timer: Timer?
    private var segmentConnection: NSURLConnection?
    private var failureStatus = 0
    private var visitData: String?
    private var visitorData: String?
    private var identifierForAdvertising: String?
    
    private var currentlyShowingNotification: VisilabsNotification?
    private var notificationViewController: UIViewController?
    private var notificationResponseCached = false
    
    private var loggerCookieKey: String?
    private var loggerCookieValue: String?
    private var realTimeCookieKey: String?
    private var realTimeCookieValue: String?
    private var loggerOM3rdCookieValue: String?
    private var realTimeOM3rdCookieValue: String?
    
    private var visilabsCookie: VisilabsCookie?
    
    private var webView: WKWebView?
    
    var cookieID: String?
    var exVisitorID: String?
    var tokenID: String?
    var appID: String?
    internal var isOnline : Bool = true //TODO: burada = true demek lazım mı?
    internal var userAgent: String = VisilabsConfig.IOS
    private var loggingEnabled: Bool = true
    private var checkForNotificationsOnLoggerRequest: Bool = true
    private var miniNotificationPresentationTime: Float = 10.0
    private var miniNotificationBackgroundColor: UIColor?
    
    
    public class func callAPI() -> Visilabs? {
        Visilabs.visilabsLockingQueue.sync {
            if Visilabs.API == nil{
                print("Visilabs: WARNING - Visilabs object is not created yet.")
            }
        }
        return Visilabs.API
    }
    
    @discardableResult
    public class func createAPI(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String = "IOS", requestTimeoutInSeconds: Int = 60, targetURL: String? = nil, actionURL: String? = nil, geofenceURL: String? = nil, geofenceEnabled: Bool = false, maxGeofenceCount: Int = 20, restURL: String? = nil, encryptedDataSource: String? = nil) -> Visilabs? {
        Visilabs.visilabsLockingQueue.sync {
            if Visilabs.API == nil {
                Visilabs.API = Visilabs(organizationID: organizationID, siteID: siteID, loggerURL: loggerURL, dataSource: dataSource, realTimeURL: realTimeURL, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, restURL: restURL, encryptedDataSource: encryptedDataSource, targetURL: targetURL, actionURL: actionURL, geofenceURL: geofenceURL, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount)
            }
        }
        return Visilabs.API
    }

    
    //TODO:init'te loggerURL ve realTimeURL'ın gerçekten url olup olmadığını kontrol et
    private init(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String, requestTimeoutInSeconds: Int, restURL: String?, encryptedDataSource: String?, targetURL: String?, actionURL: String?, geofenceURL: String?, geofenceEnabled: Bool, maxGeofenceCount: Int) {
        
        
        //Input parameters are set here
        self.organizationID = organizationID
        self.siteID = siteID
        self.loggerURL = loggerURL
        self.dataSource = dataSource
        self.realTimeURL = realTimeURL
        self.channel = channel.urlEncode() // TODO: urlEncode'a gerek var mı? zaten request atarken encode ediliyor olabilir.
        self.requestTimeoutInSeconds = requestTimeoutInSeconds
        self.restURL = restURL
        self.encryptedDataSource = encryptedDataSource
        self.targetURL = targetURL
        self.actionURL = actionURL
        self.geofenceURL = geofenceURL
        self.geofenceEnabled = geofenceEnabled
        self.maxGeofenceCount = (maxGeofenceCount < 20 && maxGeofenceCount > 0) ? maxGeofenceCount :20
        
        
        //TODO: super.init'ten kurtul
        super.init()
        self.registerForNetworkReachabilityNotifications()
        
        self.identifierForAdvertising = getIDFA()
        
        if let cidfp = cookieIDFilePath(), let cid = NSKeyedUnarchiver.unarchiveObject(withFile: cidfp) as? String{
            self.cookieID = cid
        }else{
            print("Visilabs: Error while unarchiving cookieID.")
        }
        
        if self.cookieID == nil{
            self.setCookieID()
        }
        
        if let exvidfp = exVisitorIDFilePath(), let exvid = NSKeyedUnarchiver.unarchiveObject(withFile: exvidfp) as? String{
            self.exVisitorID = exvid
        }else{
            print("Visilabs: Error while unarchiving exVisitorID.")
        }
        
        //TODO: neden clearExVisitorID çağırılıyor?
        if(self.exVisitorID != nil){
            self.clearExVisitorID()
        }
        
        if let tidfp = tokenIDFilePath(), let tid = NSKeyedUnarchiver.unarchiveObject(withFile: tidfp) as? String{
            self.tokenID = tid
        }else{
            print("Visilabs: Error while unarchiving tokenID.")
        }
        
        if let appidfp = appIDFilePath(), let appid = NSKeyedUnarchiver.unarchiveObject(withFile: appidfp) as? String{
            self.appID = appid
        }else{
            print("Visilabs: Error while unarchiving appID.")
        }
        
        if let uafp = userAgentFilePath(), let ua = NSKeyedUnarchiver.unarchiveObject(withFile: uafp) as? String{
            self.userAgent = ua
        }else{
            print("Visilabs: Error while unarchiving userAgent.")
        }
        
        self.computeWebViewUserAgent2()
        self.setupLifeCycyleListeners()
        self.unarchive()
        
        //TODO bu çağırım gereksiz gibi
        //self.applicationWillEnterForeground()
        
        
        if(self.geofenceEnabled && !self.geofenceURL.isNilOrWhiteSpace){
            VisilabsGeofenceApp.sharedInstance()?.isLocationServiceEnabled = true
        }
 
    }
    
    // MARK: Persistence

    func filePath(forData data: String) -> String? {
        let filename = data
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last ?? "").appendingPathComponent(filename).absoluteString
    }
    
    func cookieIDFilePath() -> String? {
        return filePath(forData: VisilabsConfig.COOKIEID_ARCHIVE_KEY)
    }

    func exVisitorIDFilePath() -> String? {
        return filePath(forData: VisilabsConfig.EXVISITORID_ARCHIVE_KEY)
    }

    func tokenIDFilePath() -> String? {
        return filePath(forData: VisilabsConfig.TOKENID_ARCHIVE_KEY)
    }

    func appIDFilePath() -> String? {
        return filePath(forData: VisilabsConfig.APPID_ARCHIVE_KEY)
    }

    func userAgentFilePath() -> String? {
        return filePath(forData: VisilabsConfig.USERAGENT_ARCHIVE_KEY)
    }

    func propertiesFilePath() -> String? {
        return filePath(forData: VisilabsConfig.PROPERTIES_ARCHIVE_KEY)
    }
    
    private func archive() {
        archiveProperties()
    }
    
    private func archiveProperties() {
        let filePath = propertiesFilePath()
        var dic: [String : String?] = [:]
        dic["visitorData"] = self.visitorData
        if !NSKeyedArchiver.archiveRootObject(dic, toFile: filePath!) {
            print("\(self) unable to archive properties data")
        }
    }
    
    private func unarchive() {
        unarchiveProperties()
    }
    
    private func unarchive(fromFile filePath: String) -> Any? {
        if let unarchivedData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath){
            print("\(self) unarchived data from \(filePath): \(unarchivedData)")
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                } catch {
                    print("\(self) unable to remove archived file at \(filePath) - \(error)")
                }
            }
            return unarchivedData
        }else{
            return nil
        }
    }
    
    private func unarchiveProperties() {
        if let dic = unarchive(fromFile: propertiesFilePath()!) as? [String : String?] {
            self.visitorData = dic["visitorData"] ?? ""
        }
    }
    
    //TODO: BUNU DENE
    func computeWebViewUserAgent2() {
        DispatchQueue.main.async {
            let webView : WKWebView? = WKWebView(frame: CGRect.zero)
            webView?.loadHTMLString("<html></html>", baseURL: nil)
            webView?.evaluateJavaScript("navigator.userAgent", completionHandler: { userAgent, error in
                if let uA = userAgent{
                    if type(of: uA) == String.self{
                        self.userAgent = String(describing: uA)
                        if let uafp = self.userAgentFilePath(){
                            if !NSKeyedArchiver.archiveRootObject(self.userAgent, toFile: uafp) {
                                print("Visilabs: WARNING - Unable to archive userAgent!!!")
                            }
                        }
                    }
                }
            })
        }
        
    }
    
    
    
    
    // MARK: In-App Notification

    private func trackNotificationClick(visilabsNotification: VisilabsNotification){
        if visilabsNotification.ID == 0 {
            print("Visilabs: WARNING - Tried to record empty or nil notification. Ignoring.")
            return
        }
        let actualTimeOfevent = Int(Date().timeIntervalSince1970)
        var props = [VisilabsConfig.COOKIEID_KEY : self.cookieID ?? ""
            , VisilabsConfig.CHANNEL_KEY : self.channel
            , VisilabsConfig.SITEID_KEY : self.siteID
            , VisilabsConfig.ORGANIZATIONID_KEY : self.organizationID
            , VisilabsConfig.DAT_KEY : String(actualTimeOfevent)
            , VisilabsConfig.URI_KEY : "/OM_evt.gif".urlEncode()
            , VisilabsConfig.DOMAIN_KEY : "\(self.dataSource)_\(VisilabsConfig.IOS)"
            , VisilabsConfig.APIVER_KEY : VisilabsConfig.IOS]
        
        if !self.exVisitorID.isNilOrWhiteSpace{
            props[VisilabsConfig.EXVISITORID_KEY] = self.exVisitorID!.urlEncode()
        }

        let lUrl = VisilabsHelper.buildUrl(url: "\(self.loggerURL)/\(self.dataSource)/\(VisilabsConfig.OM_GIF)", props: props, additionalQueryString: visilabsNotification.queryString ?? "")
        let rtUrl = VisilabsHelper.buildUrl(url: "\(self.realTimeURL)/\(self.dataSource)/\(VisilabsConfig.OM_GIF)", props: props, additionalQueryString: visilabsNotification.queryString ?? "")
        print("\(self) tracking notification click \(lUrl)")
        
        Visilabs.visilabsLockingQueue.sync {
            self.sendQueue.append(lUrl)
            self.sendQueue.append(rtUrl)
            self.send()
        }
        
    }
    
    private func checkForNotificationsResponse(completion: @escaping (_ notifications: [VisilabsNotification]?) -> Void, pageName: String, properties: [String : String?]) {
        self.notificationResponseCached = false
        
        //TODO: properties aşağıdakileri içeriyorsa uçur
        //TODO: if ([key  isEqual: @"OM.cookieID"] || [key  isEqual: @"OM.siteID"] || [key  isEqual: @"OM.oid"] || [key  isEqual: [VisilabsConfig APIVER_KEY]] || [key  isEqual: @"OM.uri"] || [key  isEqual: @"OM.exVisitorID"]) {continue;}
        
        var externalProps = properties
        self.serialQueue.async(execute: {

            var parsedNotifications: [VisilabsNotification] = []

            if !self.notificationResponseCached{
                let actualTimeOfevent = Int(Date().timeIntervalSince1970)
                var props = [VisilabsConfig.COOKIEID_KEY : self.cookieID ?? ""
                    , VisilabsConfig.SITEID_KEY : self.siteID
                    , VisilabsConfig.ORGANIZATIONID_KEY : self.organizationID
                    , VisilabsConfig.DAT_KEY : String(actualTimeOfevent)
                    , VisilabsConfig.APIVER_KEY : VisilabsConfig.IOS
                    , VisilabsConfig.URI_KEY : pageName.urlEncode()]
                
                if !self.exVisitorID.isNilOrWhiteSpace{
                    props[VisilabsConfig.EXVISITORID_KEY] = self.exVisitorID!.urlEncode()
                }
                if !self.visitData.isNilOrWhiteSpace{
                    props[VisilabsConfig.VISIT_CAPPING_KEY] = self.visitData!.urlEncode()
                }
                if !self.visitorData.isNilOrWhiteSpace{
                    props[VisilabsConfig.VISITOR_CAPPING_KEY] = self.visitorData!.urlEncode()
                }
                if !self.tokenID.isNilOrWhiteSpace{
                    props[VisilabsConfig.TOKENID_KEY] = self.tokenID!.urlEncode()
                }
                if !self.appID.isNilOrWhiteSpace{
                    props[VisilabsConfig.APPID_KEY] = self.appID!.urlEncode()
                }
                
                for (key, value) in VisilabsPersistentTargetManager.getParameters(){
                    if value.isNilOrWhiteSpace{
                        externalProps.removeValue(forKey: key)
                    }else{
                        props[key] = value!.urlEncode()
                    }
                }
                
                for (key, value) in properties{
                    if value.isNilOrWhiteSpace{
                        externalProps.removeValue(forKey: key)
                    }else{
                        props[key] = value!.urlEncode()
                    }
                }
                let actionUrl = VisilabsHelper.buildUrl(url: "\(self.actionURL!)", props: props)
                let anURL = URL(string: actionUrl)
                var request: URLRequest? = nil
                if let anURL = anURL {
                    request = URLRequest(url: anURL)
                }
                
                request?.setValue(self.userAgent, forHTTPHeaderField: "User-Agent")
                
                var urlResponse: URLResponse? = nil
                var data: Data? = nil
                do {
                    if let request = request {
                        data = try NSURLConnection.sendSynchronousRequest(request, returning: &urlResponse)
                    }
                } catch {
                    print("\(self) notification check http error: \(error.localizedDescription)")
                    return
                }

                var rawNotifications: [Any]? = nil
                do {
                    rawNotifications = try JSONSerialization.jsonObject(with: data ?? Data(), options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [Any]
                } catch {
                    print("\(self) notification check json error: \(error), data: \(String(data: data ?? Data(), encoding: .utf8) ?? "")")
                    return
                }
                
                if rawNotifications != nil{
                    for obj in rawNotifications! {
                        if let o = obj as? [String : Any?] {
                            if let notification = VisilabsNotification.notification(jsonObject: o){
                                parsedNotifications.append(notification)
                            }
                        }
                    }
                } else {
                    if let rawNotifications = rawNotifications {
                        print("\(self) in-app notifs check response format error: \(rawNotifications)")
                    }
                }
                
                self.notificationResponseCached = true
                
            }else{
                print("\(self) notification cache found, skipping network request")
            }
            completion(parsedNotifications)

        })
    
    }
    
    //TODO: kontrol et doğru mu?
    private class func topPresentedViewController() -> UIViewController?{
        var controller = UIApplication.shared.keyWindow?.rootViewController
        while controller?.presentedViewController != nil {
            controller = controller?.presentedViewController
        }
        return controller
    }
    
    //TODO: viewController is UIAlertController ne için gerekli bak
    private class func canPresentFromViewController(viewController: UIViewController) -> Bool{
        // This fixes the NSInternalInconsistencyException caused when we try present a
        // survey on a viewcontroller that is itself being presented.
        if viewController.isBeingPresented || viewController.isBeingDismissed || viewController is UIAlertController {
            return false
        }
        return true
    }
    
    //TODO: bunlara shown kontrolü koyulacak.showNotificationWithID,showNotificationWithType,showNotification
    
    private func showNotification(pageName: String) {
        checkForNotificationsResponse(
        completion: { notifications in
            if (notifications?.count ?? 0) > 0 {
                if let n = notifications?[0]{
                    self.showNotification(withObject: n)
                }
            }
        }
        , pageName: pageName
        , properties: [:])
    }
    
    private func showNotification(_ pageName: String, properties: [String : String?]) {
        checkForNotificationsResponse(
        completion: { notifications in
            if (notifications?.count ?? 0) > 0 {
                if let n = notifications?[0]{
                    self.showNotification(withObject: n)
                }
            }
        },
        pageName: pageName,
        properties: properties)
    }
    
    private func showNotification(withObject notification: VisilabsNotification) {
        //TODO: burada neden nil kontrolü yapılmış? fonksiyonun devamında image kullanılmıyor.
        if notification.image == nil {
            return
        }
        DispatchQueue.main.async(execute: {
            if self.currentlyShowingNotification != nil {
                print("\(self) already showing in-app notification: \(self.currentlyShowingNotification)")
            } else {
                self.currentlyShowingNotification = notification
                var shown: Bool
                if notification.visitData != nil && !(notification.visitData == "") {
                    self.visitData = notification.visitData
                }
                if notification.visitorData != nil && !(notification.visitorData == "") {
                    self.visitorData = notification.visitorData
                }
                if (notification.type == VisilabsNotificationType.mini) {
                    shown = self.showMiniNotification(withObject: notification)
                } else {
                    shown = self.showFullNotification(withObject: notification)
                }

                if !shown {
                    self.currentlyShowingNotification = nil
                }
            }
            
            
        })

    }

    private func showMiniNotification(withObject notification: VisilabsNotification?) -> Bool {
        let controller = VisilabsMiniNotificationViewController()
        controller.notification = notification
        controller.delegate = self
        controller.backgroundColor = miniNotificationBackgroundColor
        notificationViewController = controller

        controller.showWithAnimation()

        //TODO: popTime hesaplaması doğru mu kontrol et
        let popTime = DispatchTime.now() + Double(Int64(Double(miniNotificationPresentationTime) * Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
            self.notificationController(controller, wasDismissedWithStatus: false)
        })
        return true
    }

    private func showFullNotification(withObject notification: VisilabsNotification?) -> Bool {
        let presentingViewController = Visilabs.topPresentedViewController()
        //TODO: buradaki forced-unwrap doğru mu?
        if Visilabs.canPresentFromViewController(viewController: presentingViewController!) {
            let storyboard = UIStoryboard(name: "VisilabsNotification", bundle: Bundle(for: Visilabs.self))
            let controller = storyboard.instantiateViewController(withIdentifier: "VisilabsFullNotificationViewController") as? VisilabsFullNotificationViewController

            controller?.backgroundImage = presentingViewController?.view.visilabs_snapshotImage()
            controller?.notification = notification
            controller?.delegate = self
            notificationViewController = controller

            if let controller = controller {
                presentingViewController?.present(controller, animated: true)
            }
            return true
        } else {
            return false
        }
    }

    //VisilabsNotificationViewControllerDelegate delege metodu
    func notificationController(_ controller: VisilabsNotificationViewController?, wasDismissedWithStatus status: Bool){
        //TODO: !== reference equality için kullanılıyor. aşağıdaki kontrol doğru mu?
        if controller == nil || self.currentlyShowingNotification !== controller!.notification {
            return
        }

        let completionBlock: (() -> Void) = {
            self.currentlyShowingNotification = nil
            self.notificationViewController = nil
        }
        
        if status && controller!.notification != nil && controller!.notification!.buttonURL != nil {
            if let buttonURL = controller!.notification!.buttonURL {
                print("\(self) opening URL \(buttonURL)")
            }
            var success = false
            if let buttonURL = controller!.notification!.buttonURL {
                success = UIApplication.shared.openURL(buttonURL)
            }

            controller?.hide(withAnimation: !success, completion: completionBlock)

            if !success {
                print("Visilabs failed to open given URL: \(controller!.notification!.buttonURL)")
            }

            //TODO: Notification butonuna tıkladığında track etmek için
            trackNotificationClick(visilabsNotification: controller!.notification!)
        } else {
            controller?.hide(withAnimation: true, completion: completionBlock)
        }
        
    }
    
    
    
    
    // MARK: Life-Cycle
    
    //TODO:
    private func setupLifeCycyleListeners(){
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)),name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        Visilabs.visilabsLockingQueue.sync {
            print("\(self) application did become active");
            //TODO: bunlar VisilabsCookie objesine taşınacak
            self.loggerCookieKey = nil;
            self.loggerCookieValue = nil;
            self.realTimeCookieKey = nil;
            self.realTimeCookieValue = nil;
        }
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        print("\(self) did enter background")
        self.serialQueue.async(execute: {
            self.archive()
        })
    }
    
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        Visilabs.visilabsLockingQueue.sync {
            //TODO: burada bir şey yapılmasına gerek yok sanırım
        }
    }
    
    @objc func applicationWillTerminate(_ notification: Notification) {
        Visilabs.visilabsLockingQueue.sync {
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            if segmentConnection != nil {
                segmentConnection!.cancel()
            }
        }
    }
    
    
    
    
    
    // MARK: Network
    
    private func registerForNetworkReachabilityNotifications() {
        if Visilabs.visilabsReachability == nil {
            do{
                Visilabs.visilabsReachability = try VisilabsReachability()
                if let vr = Visilabs.visilabsReachability{
                    if vr.connection == .wifi || vr.connection == .cellular{
                        self.isOnline = true
                    }else{
                        self.isOnline = false
                    }
                    try vr.startNotifier()
                }
                //TODO ReachabilityChangedNotification ismini VisilabsReachabilityChangedNotification olarak değiştirmeme gerek var mı?
                NotificationCenter.default.addObserver(self, selector: #selector(networkReachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: nil)
            }catch {
                print("registerForNetworkReachabilityNotifications error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func networkReachabilityChanged(_ note: Notification?) {
        if let vr = Visilabs.visilabsReachability{
            if vr.connection == .wifi || vr.connection == .cellular{
                self.isOnline = true
            }else{
                self.isOnline = false
            }
        }
        print("Visilabs network status changed. Current status: \(isOnline)")
    }
    
    
    
    
    // MARK: Target
    
    public func buildTargetRequest(zoneID: String, productCode: String, properties: [String : String] = [:], filters: [VisilabsTargetFilter] = []) -> VisilabsTargetRequest? {
        if Visilabs.API == nil{
            //TODO: print'leri kaldır
            print("Visilabs: WARNING - Visilabs object is not created yet.")
            return nil
        }
        return VisilabsTargetRequest(zoneID: zoneID, productCode: productCode, properties: properties, filters: filters)
    }
    
    internal func buildGeofenceRequest(action: String, latitude: Double, longitude: Double, isDwell: Bool, isEnter: Bool, actionID: String = "", geofenceID: String = "") -> VisilabsGeofenceRequest? {
        if Visilabs.API == nil {
            //TODO: print'leri kaldır
            print("Visilabs: WARNING - Visilabs object is not created yet.")
            return nil
        }
        return VisilabsGeofenceRequest(action: action, actionID: actionID, lastKnownLatitude: latitude, lastKnownLongitude: longitude, geofenceID: geofenceID, isDwell: isDwell, isEnter: isEnter)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private func send(){
        
    }
    
    
    
    
    
    
    
    
    private func getIDFA() -> String? {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            let IDFA = ASIdentifierManager.shared().advertisingIdentifier
            return IDFA.uuidString
        }
        //TODO: disabled ise ARCHIVE_KEY olarak okunmaya çalışılabilir.
        return ""
    }
    
    //TODO: description'a gerek yok.
    
    // MARK: Public Methods
    
    //Custom Event için NSKeyedArchiver içerisinde kullanılan path'i URL'e çevirme
    func getDocumentsDirectory() -> URL {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return paths[0]
    }
    
    
    public func customEvent(_ pageName: String, properties: [String:String]){
        if pageName.isEmptyOrWhitespace{
            print("Visilabs: WARNING - Custom Event can not be called with empty page name. Ignoring.")
            return
        }
        var props = properties
        
        if let cookieID = props[VisilabsConfig.COOKIEID_KEY] {
            if self.cookieID != cookieID {
                VisilabsPersistentTargetManager.clearParameters()
            }
            self.cookieID = cookieID
            if let cidfp = self.cookieIDFilePath(){
                if !NSKeyedArchiver.archiveRootObject(self.cookieID!, toFile: cidfp) {
                    print("Visilabs: WARNING - Unable to archive userAgent!!!")
                }
            }
            props.removeValue(forKey: VisilabsConfig.COOKIEID_KEY)
        }
        
        if let exVisitorID = props[VisilabsConfig.EXVISITORID_KEY] {
            if self.exVisitorID != exVisitorID {
                VisilabsPersistentTargetManager.clearParameters()
            }
            if self.exVisitorID != nil && self.exVisitorID != exVisitorID{
                self.setCookieID()
            }
            self.exVisitorID = exVisitorID
            if let exvidfp = self.exVisitorIDFilePath(){
                if !NSKeyedArchiver.archiveRootObject(self.exVisitorID!, toFile: exvidfp) {
                    print("Visilabs: WARNING - Unable to archive exVisitorID!!!")
                }
            }
            props.removeValue(forKey: VisilabsConfig.EXVISITORID_KEY)
        }
 
        if let tokenID = props[VisilabsConfig.TOKENID_KEY]{
            self.tokenID = tokenID
            if let tidfp = self.tokenIDFilePath(){
                if !NSKeyedArchiver.archiveRootObject(self.tokenID!, toFile: tidfp) {
                    print("Visilabs: WARNING - Unable to archive tokenID!!!")
                }
            }
            props.removeValue(forKey: VisilabsConfig.TOKENID_KEY)
        }
        
        if let appID = props[VisilabsConfig.APPID_KEY]{
            self.appID = appID
            if let appidfp = self.appIDFilePath(){
                if !NSKeyedArchiver.archiveRootObject(self.appID!, toFile: appidfp) {
                    print("Visilabs: WARNING - Unable to archive appID!!!")
                }
            }
            props.removeValue(forKey: VisilabsConfig.APPID_KEY)
        }
        
        //TODO: Dışarıdan mobile ad id gelince neden siliyoruz?
        if props.keys.contains(VisilabsConfig.MOBILEADID_KEY) {
            props.removeValue(forKey: VisilabsConfig.MOBILEADID_KEY)
        }
        
        if props.keys.contains(VisilabsConfig.APIVER_KEY) {
            props.removeValue(forKey: VisilabsConfig.APIVER_KEY)
        }
        

        var chan = self.channel
        if props.keys.contains(VisilabsConfig.CHANNEL_KEY) {
            chan = props[VisilabsConfig.CHANNEL_KEY]!
            props.removeValue(forKey: VisilabsConfig.CHANNEL_KEY)
        }
        
        let actualTimeOfevent = Int(Date().timeIntervalSince1970)
        var eventProperties = [VisilabsConfig.COOKIEID_KEY : self.cookieID ?? ""
            , VisilabsConfig.CHANNEL_KEY : chan
            , VisilabsConfig.SITEID_KEY : self.siteID
            , VisilabsConfig.ORGANIZATIONID_KEY : self.organizationID
            , VisilabsConfig.DAT_KEY : String(actualTimeOfevent)
            , VisilabsConfig.URI_KEY : pageName.urlEncode()
            , VisilabsConfig.MOBILEAPPLICATION_KEY : VisilabsConfig.TRUE
            , VisilabsConfig.MOBILEADID_KEY : self.identifierForAdvertising ?? ""
            , VisilabsConfig.APIVER_KEY : VisilabsConfig.IOS]
        
        if !self.exVisitorID.isNilOrWhiteSpace{
            eventProperties[VisilabsConfig.EXVISITORID_KEY] = self.exVisitorID!.urlEncode()
        }
        
        if !self.tokenID.isNilOrWhiteSpace{
            eventProperties[VisilabsConfig.TOKENID_KEY] = self.tokenID!.urlEncode()
        }
        
        if !self.appID.isNilOrWhiteSpace{
            eventProperties[VisilabsConfig.APPID_KEY] = self.appID!.urlEncode()
        }
        
        for (key, value) in props{
            if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace{
                let encodedKey = key.urlEncode()
                let encodedValue = value.urlEncode()
                if encodedKey.count > 255 {
                    print("Visilabs: WARNING - property key cannot be longer than 255 characters. When URL escaped, your key is \(encodedKey.count) characters long (the submitted value is \(key), the URL escaped key is \(encodedKey). Dropping property.")
                }else{
                    eventProperties[encodedKey] = encodedValue
                }
            }
        }
        
        VisilabsPersistentTargetManager.saveParameters(props)

        let lUrl = VisilabsHelper.buildUrl(url: "\(self.loggerURL)/\(self.dataSource)/\(VisilabsConfig.OM_GIF)", props: eventProperties)
        let rtUrl = VisilabsHelper.buildUrl(url: "\(self.realTimeURL)/\(self.dataSource)/\(VisilabsConfig.OM_GIF)", props: eventProperties)
        
        if self.checkForNotificationsOnLoggerRequest && !self.actionURL.isNilOrWhiteSpace{
            self.showNotification(pageName, properties: props)
        }
        
        Visilabs.visilabsLockingQueue.sync {
            self.sendQueue.append(lUrl)
            self.sendQueue.append(rtUrl)
        }
        self.send()
    }
    
    public func login(exVisitorID: String, properties: [String:String] = [String:String]()){
        if exVisitorID.isEmptyOrWhitespace{
            print("Visilabs: WARNING - attempted to use empty identity. Ignoring.")
            return
        }else {
            if self.exVisitorID != nil && !(self.exVisitorID == exVisitorID) {
                setCookieID()
            }
            var props = properties
            props[VisilabsConfig.EXVISITORID_KEY] = exVisitorID
            props["Login"] = exVisitorID
            props["OM.b_login"] = "Login"
            customEvent("LoginPage", properties: props)
        }
    }
    
    public func signUp(exVisitorID: String, properties: [String:String] = [String:String]()){
        if exVisitorID.isEmptyOrWhitespace{
            print("Visilabs: WARNING - attempted to use empty identity. Ignoring.")
            return
        }else {
            if self.exVisitorID != nil && !(self.exVisitorID == exVisitorID) {
                setCookieID()
            }
            var props = properties
            props[VisilabsConfig.EXVISITORID_KEY] = exVisitorID
            props["SignUp"] = exVisitorID
            props["OM.b_sgnp"] = "SignUp"
            customEvent("SignUpPage", properties: props)
        }
    }
    
    
    public func getPushURL(source: String, campaign: String, medium: String, content: String) -> String? {
        if self.restURL.isNilOrWhiteSpace {
            print("Rest URL is not defined.")
            return nil
        }
        
        let actualTimeOfevent = Int(Date().timeIntervalSince1970)
        let escapedPageName = "/Push".urlEncode()

        var pushURL = "\(restURL!)/\(encryptedDataSource!)/\(dataSource)/\(cookieID ?? "")?\(VisilabsConfig.CHANNEL_KEY)=\(channel)&\(VisilabsConfig.URI_KEY)=\(escapedPageName)&\(VisilabsConfig.SITEID_KEY)=\(siteID)&\(VisilabsConfig.ORGANIZATIONID_KEY)=\(organizationID)&dat=\(actualTimeOfevent)"
        
        if !self.exVisitorID.isNilOrWhiteSpace {
            pushURL = "\(pushURL)&\(VisilabsConfig.EXVISITORID_KEY)=\(exVisitorID!.urlEncode())"
        }
        if !source.isEmptyOrWhitespace{
            pushURL = "\(pushURL)&\(VisilabsConfig.UTM_SOURCE_KEY)=\(source.urlEncode())"
        }
        if !campaign.isEmptyOrWhitespace{
            pushURL = "\(pushURL)&\(VisilabsConfig.UTM_CAMPAIGN_KEY)=\(campaign.urlEncode())"
        }
        if !medium.isEmptyOrWhitespace{
            pushURL = "\(pushURL)&\(VisilabsConfig.UTM_MEDIUM_KEY)=\(medium.urlEncode())"
        }
        if !content.isEmptyOrWhitespace{
            pushURL = "\(pushURL)&\(VisilabsConfig.UTM_CONTENT_KEY)=\(content.urlEncode())"
        }
        return pushURL
    }
    
    private func setCookieID() {
        self.cookieID = UUID().uuidString
        if let cidfp = self.cookieIDFilePath(){
            if !NSKeyedArchiver.archiveRootObject(self.cookieID!, toFile: cidfp) {
                print("Visilabs: WARNING - Unable to archive cookieID!!!")
            }
        }else{
            print("Visilabs: WARNING - Unable to get cookieID file path!!!")
        }
    }

    
    public func setExVisitorIDToNull(){
        self.exVisitorID = nil
    }
    
    private func clearExVisitorID() {
        self.exVisitorID = nil
    }
}

