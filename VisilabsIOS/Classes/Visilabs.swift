import WebKit
import AdSupport

open class Visilabs : NSObject, VisilabsNotificationViewControllerDelegate {
    
    private static var API: Visilabs?
    private static var visilabsReachability : VisilabsReachability?
    
    private static let visilabsLockingQueue: DispatchQueue = DispatchQueue(label:"VisilabsLockingQueue")
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
    
    private var sendQueue : [String]
    private var timer: Timer?
    private var segmentConnection: NSURLConnection?
    private var failureStatus = 0
    private var cookieIDArchiveKey: String?
    private var exVisitorIDArchiveKey: String?
    private var propertiesArchiveKey: String?
    private var tokenIDArchiveKey: String?
    private var appIDArchiveKey: String?
    private var userAgentArchiveKey: String?
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
    internal var isOnline: Bool//TODO: burada = true demek lazım mı?
    internal var userAgent: String?
    private var loggingEnabled: Bool = true
    private var checkForNotificationsOnLoggerRequest: Bool = true
    private var miniNotificationPresentationTime: Float = 10.0
    private var miniNotificationBackgroundColor: UIColor = .clear
    
    
    //TODO: burada synchronized olacak
    public class func callAPI() -> Visilabs? {
        Visilabs.visilabsLockingQueue.sync {
            if Visilabs.API == nil{
                print("Visilabs: WARNING - Visilabs object is not created yet.")
            }
        }
        return Visilabs.API
    }
    
    //TODO: Buradaki DispatchQueue doğru yaklaşım mı?
    @discardableResult
    public class func createAPI(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String, requestTimeoutInSeconds: Int = 60, targetURL: String? = nil, actionURL: String? = nil, geofenceURL: String? = nil, geofenceEnabled: Bool = false, maxGeofenceCount: Int = 20, restURL: String? = nil, encryptedDataSource: String? = nil) -> Visilabs? {
        Visilabs.visilabsLockingQueue.sync {
            if Visilabs.API == nil {
                Visilabs.API = Visilabs(organizationID: organizationID, siteID: siteID, loggerURL: loggerURL, dataSource: dataSource, realTimeURL: realTimeURL, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, restURL: restURL, encryptedDataSource: encryptedDataSource, targetURL: targetURL, actionURL: actionURL, geofenceURL: geofenceURL, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount)
            }
        }
        return Visilabs.API
    }

    
    //TODO:init'te loggerURL ve realTimeURL'ın gerçekten url olup olmadığını kontrol et
    private init(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String, requestTimeoutInSeconds: Int, restURL: String?, encryptedDataSource: String?, targetURL: String?, actionURL: String?, geofenceURL: String?, geofenceEnabled: Bool, maxGeofenceCount: Int) {
        self.organizationID = organizationID
        self.siteID = siteID
        self.loggerURL = loggerURL
        self.dataSource = dataSource
        self.realTimeURL = realTimeURL
        self.channel = channel
        self.requestTimeoutInSeconds = requestTimeoutInSeconds
        self.restURL = restURL
        self.encryptedDataSource = encryptedDataSource
        self.targetURL = targetURL
        self.actionURL = actionURL
        self.geofenceURL = geofenceURL
        self.geofenceEnabled = geofenceEnabled
        self.maxGeofenceCount = maxGeofenceCount
        self.sendQueue = [String]()
        self.isOnline = true //TODO: burada true'ya mı eşitlemek lazım
        
        /*
        if(self.geofenceEnabled && !self.geofenceURL.isNilOrWhiteSpace){
            VisilabsGeofenceApp.sharedInstance()?.isLocationServiceEnabled = true
        }
 */
    }
    
    // MARK: Persistence

    func filePath(forData data: String?) -> String? {
        let filename = "\(data ?? "")"
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last ?? "").appendingPathComponent(filename).absoluteString
    }
    
    func cookieIDFilePath() -> String? {
        return filePath(forData: cookieIDArchiveKey)
    }

    func exVisitorIDFilePath() -> String? {
        return filePath(forData: exVisitorIDArchiveKey)
    }

    func tokenIDFilePath() -> String? {
        return filePath(forData: tokenIDArchiveKey)
    }

    func appIDFilePath() -> String? {
        return filePath(forData: appIDArchiveKey)
    }

    func userAgentFilePath() -> String? {
        return filePath(forData: userAgentArchiveKey)
    }

    func propertiesFilePath() -> String? {
        return filePath(forData: propertiesArchiveKey)
    }
    
    
    /* TODO:
    
    func dispatch_once_on_main_thread(predicate: UnsafeMutableRawPointer?, block: () -> ()) {
        if Thread.isMainThread {
            block
        } else {
            if DISPATCH_EXPECT(IntegerLiteralConvertible(predicate ?? 0) == 0, false) {
                DispatchQueue.main.sync(execute: {
                    block
                })
            }
        }
    }

    func computeWebViewUserAgent() {
        webView = WKWebView(frame: CGRect.zero)
        webView?.loadHTMLString("<html></html>", baseURL: nil)
        weak var weakSelf = self
        dispatch_once_on_main_thread(&computeWebViewUserAgentOnceToken, {
            let strongSelf = weakSelf
            strongSelf.webView?.evaluateJavaScript("navigator.userAgent", completionHandler: { userAgent, error in
                strongSelf.userAgent = userAgent
                strongSelf.webView = nil
                if !NSKeyedArchiver.archiveRootObject(strongSelf.userAgent, toFile: strongSelf.userAgentFilePath()) {
                    DLog("Visilabs: WARNING - Unable to archive userAgent!!!")
                }
            })
        })
    }
    */
    
    //TODO: BUNU DENE
    func computeWebViewUserAgent2() {
        DispatchQueue.main.async {
            let webView : WKWebView? = WKWebView(frame: CGRect.zero)
            webView?.loadHTMLString("<html></html>", baseURL: nil)
            webView?.evaluateJavaScript("navigator.userAgent", completionHandler: { userAgent, error in
                if let uA = userAgent{
                    if type(of: uA) == String.self{
                        self.userAgent = String(describing: uA)
                        if !NSKeyedArchiver.archiveRootObject(self.userAgent!
                            //, toFile: self.userAgentFilePath()
                            , toFile: ""
                            ) {
                            print("Visilabs: WARNING - Unable to archive userAgent!!!")
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
                if let ua = self.userAgent{
                    request?.setValue(ua, forHTTPHeaderField: "User-Agent")
                }
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
    
    
    private func send(){
        
    }
    
    
    
    
    
    
    
    
    
    

    
    
    
    //TODO:
    private func setupLifeCycyleListeners(){
        //applicationWillTerminate
        //applicationWillEnterForeground
        //applicationDidBecomeActive
        //applicationDidEnterBackground
    }
    
    
    //TODO:persistence metodlar
    /*
     filePathForData
     cookieIDFilePath
     exVisitorIDFilePath
     tokenIDFilePath
     appIDFilePath
     userAgentFilePath
     propertiesFilePath
     archive
     archiveProperties
     unarchive
     unarchiveFromFile
     unarchiveProperties
     */
    
    private func getIDFA() -> String? {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            let IDFA = ASIdentifierManager.shared().advertisingIdentifier
            return IDFA.uuidString
        }
        return ""
    }
    
    //TODO: description'a gerek yok.
    
    // MARK: Public Methods
    
    //TODO
    func urlizeProps(_ props: [String : String]) -> String {
    var propsURLPart = ""

        for propKey in props.keys {
        
        let stringKey = propKey

        if stringKey.count == 0 {
            print("Visilabs: WARNING - property keys must not be empty strings. Dropping property.")
            continue
        }

        var stringValue: String? = nil
        if props[stringKey] == nil {
            print("Visilabs: WARNING - property value cannot be nil. Dropping property.")
            continue
        } else {
            stringValue = props[stringKey]
        }

        if stringValue == nil {
            print("Visilabs: WARNING - property value cannot be of type %@. Dropping property.", (type(of: props[stringKey])))
            continue
        }

        if (stringValue?.count ?? 0) == 0 {
            print("Visilabs: WARNING - property values must not be empty strings. Dropping property.")
            continue
        }


            let escapedKey = urlEncode(stringKey)
        if escapedKey.count > 255 {
            print("Visilabs: WARNING - property key cannot longer than 255 characters. When URL escaped, your key is %lu characters long (the submitted value is %@, the URL escaped value is %@). Dropping property.", UInt(escapedKey.count), stringKey, escapedKey)
            continue
        }

        let escapedValue = urlEncode(stringValue!)
        propsURLPart += "&\(escapedKey)=\(escapedValue)"
    }

    return propsURLPart
    }
    
    //TODO:bunu kontrol et: objective-c'de pointer'lı bir şeyler kullanıyorduk
    public func urlEncode(_ prior: String) -> String {
        return prior.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
    //TODO
    internal func buildTargetRequest(zoneID: String, productCode: String, properties: [String : String] = [:], filters: [VisilabsTargetFilter] = []) -> VisilabsTargetRequest? {
        if Visilabs.API == nil {
            //TODO: ne yapacağına karar ver.
            //Error is not handled because the enclosing function is not declared 'throws'
            //throw (NSException(name: NSExceptionName("Visilabs Not Ready"), reason: "Visilabs failed to initialize", userInfo: [:]) as! Error)
            return nil
        }
        return VisilabsTargetRequest(zoneID: zoneID, productCode: productCode, properties: properties, filters: filters)
    }

    //TODO
    internal func buildGeofenceRequest(action: String, latitude: Double, longitude: Double, isDwell: Bool, isEnter: Bool, actionID: String = "", geofenceID: String = "") -> VisilabsGeofenceRequest? {
        if Visilabs.API == nil {
            //TODO: ne yapacağına karar ver.
            //Error is not handled because the enclosing function is not declared 'throws'
            //throw (NSException(name: NSExceptionName("Visilabs Not Ready"), reason: "Visilabs failed to initialize", userInfo: [:]) as! Error)
            return nil
        }
        return VisilabsGeofenceRequest(action: action, actionID: actionID, lastKnownLatitude: latitude, lastKnownLongitude: longitude, geofenceID: geofenceID, isDwell: isDwell, isEnter: isEnter)
    }
    
    //Custom Event için NSKeyedArchiver içerisinde kullanılan path'i URL'e çevirme
    func getDocumentsDirectory() -> URL {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return paths[0]
    }
    
    //TODO:
    public func customEvent(_ pageName: String, properties: [String:String]){
        var vlProperties = properties
        if pageName.isEmptyOrWhitespace || pageName.count == 0 {
            print("Visilabs: WARNING - Tried to record event with empty or nil name. Ignoring.")
            return
        }

        if properties.keys.contains("OM.cookieID") {
            let cookieid = properties["OM.cookieID"]

            if !(cookieID == cookieid) {
                VisilabsPersistentTargetManager.clearParameters()
            }

            cookieID = cookieid
//            if !NSKeyedArchiver.archiveRootObject(cookieID!, toFile: cookieIDFilePath()!) {
//                print("Visilabs: WARNING - Unable to archive identity!!!")
//            }
            let cookieIDFullPath = getDocumentsDirectory().appendingPathComponent(cookieIDFilePath()!)
            do {
              let data = try NSKeyedArchiver.archivedData(withRootObject: cookieID!, requiringSecureCoding: true)
              try data.write(to: cookieIDFullPath)
            } catch {
              print("Could’nt write file")
            }
            
            vlProperties.removeValue(forKey: "OM.cookieID")
        }

        if properties.keys.contains("OM.exVisitorID") {
            let exvisitorid = properties["OM.exVisitorID"]

            if !(exVisitorID == exvisitorid) {
                VisilabsPersistentTargetManager.clearParameters()
            }

            if exVisitorID != nil && !(exVisitorID == exvisitorid) {
                setCookieID()
            }

            exVisitorID = exvisitorid
//            if !NSKeyedArchiver.archiveRootObject(exVisitorID!, toFile: exVisitorIDFilePath()!) {
//                print("Visilabs: WARNING - Unable to archive new identity!!!")
//            }
            let exVisitorIDFullPath = getDocumentsDirectory().appendingPathComponent(exVisitorIDFilePath()!)
            do {
              let data = try NSKeyedArchiver.archivedData(withRootObject: exVisitorID!, requiringSecureCoding: true)
              try data.write(to: exVisitorIDFullPath)
            } catch {
              print("Could’nt write file")
            }
            vlProperties.removeValue(forKey: "OM.exVisitorID")
        }

        if properties.keys.contains("OM.sys.TokenID") {
            let tokenid = properties["OM.sys.TokenID"]
            tokenID = tokenid

//            if !NSKeyedArchiver.archiveRootObject(tokenID!, toFile: tokenIDFilePath()!) {
//                print("Visilabs: WARNING - Unable to archive tokenID!!!")
//            }
            let tokenIDFullPath = getDocumentsDirectory().appendingPathComponent(tokenIDFilePath()!)
            do {
              let data = try NSKeyedArchiver.archivedData(withRootObject: tokenID!, requiringSecureCoding: true)
              try data.write(to: tokenIDFullPath)
            } catch {
              print("Could’nt write file")
            }
            vlProperties.removeValue(forKey: "OM.sys.TokenID")
        }

        if properties.keys.contains("OM.sys.AppID") {
            let appid = properties["OM.sys.AppID"]
            appID = appid

//            if !NSKeyedArchiver.archiveRootObject(appID!, toFile: appIDFilePath()!) {
//                print("Visilabs: WARNING - Unable to archive appID!!!")
//            }
            let appIDFullPath = getDocumentsDirectory().appendingPathComponent(appIDFilePath()!)
            do {
              let data = try NSKeyedArchiver.archivedData(withRootObject: appID!, requiringSecureCoding: true)
              try data.write(to: appIDFullPath)
            } catch {
              print("Could’nt write file")
            }
            vlProperties.removeValue(forKey: "OM.sys.AppID")
        }
        
        if properties.keys.contains("OM.m_adid") {
            vlProperties.removeValue(forKey: "OM.m_adid")
        }

        if properties.keys.contains(VisilabsConfig.APIVER_KEY) {
            vlProperties.removeValue(forKey: VisilabsConfig.APIVER_KEY)
        }

        var chan = channel
        if properties.keys.contains("OM.vchannel") {
            chan = urlEncode(properties["OM.vchannel"]!)
            vlProperties.removeValue(forKey: "OM.vchannel")
        }

        let escapedPageName = urlEncode(pageName)

        let actualTimeOfevent = Int(Date().timeIntervalSince1970)

        var segURL: String? = nil
        
        segURL = String(format: "%@/%@/%@?%@=%@&%@=%@&%@=%@&%@=%@&%@=%i&%@=%@&%@=%@&%@=%@&%@=%@&", loggerURL, dataSource, "om.gif", "OM.cookieID", cookieID!, "OM.vchannel", chan, "OM.siteID", siteID, "OM.oid", organizationID, "dat", actualTimeOfevent, "OM.uri", escapedPageName, "OM.mappl", "true", "OM.m_adid", identifierForAdvertising!, VisilabsConfig.APIVER_KEY, "IOS")
    

        if exVisitorID != nil && !(exVisitorID == "") {
            let escapedIdentity = urlEncode(exVisitorID!)
            segURL = "\(segURL ?? "")\("OM.exVisitorID")=\(escapedIdentity)"
        }

        if tokenID != nil && !(tokenID == "") {
            let escapedToken = urlEncode(tokenID!)
            segURL = "\(segURL ?? "")&\("OM.sys.TokenID")=\(escapedToken)"
        }
        if appID != nil && !(appID == "") {
            let escapedAppID = urlEncode(appID!)
            segURL = "\(segURL ?? "")&\("OM.sys.AppID")=\(escapedAppID)"
        }
        
        
            VisilabsPersistentTargetManager.saveParameters(properties)
            let additionalURL = urlizeProps(properties)
        if additionalURL.count > 0 {
            segURL = "\(segURL ?? "")\(additionalURL)"
            }
        
        
        var rtURL: String? = nil
        if realTimeURL.isEmptyOrWhitespace && !(realTimeURL == "") {
            rtURL = segURL!.replacingOccurrences(of: loggerURL, with: realTimeURL)
        }

        if checkForNotificationsOnLoggerRequest && actionURL != nil {
            showNotification(pageName, properties: properties)
        }


        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            sendQueue.append(segURL!)
            if rtURL != nil {
                sendQueue.append(rtURL ?? "")
            }
        }
        //send()
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
        let escapedPageName = urlEncode("/Push")

        var pushURL = "\(restURL!)/\(encryptedDataSource!)/\(dataSource)/\(cookieID ?? "")?\(VisilabsConfig.CHANNEL_KEY)=\(channel)&\(VisilabsConfig.URI_KEY)=\(escapedPageName)&\(VisilabsConfig.SITEID_KEY)=\(siteID)&\(VisilabsConfig.ORGANIZATIONID_KEY)=\(organizationID)&dat=\(actualTimeOfevent)"
        
        if !self.exVisitorID.isNilOrWhiteSpace {
            pushURL = "\(pushURL)&\(VisilabsConfig.EXVISITORID_KEY)=\(urlEncode(exVisitorID!))"
        }
        if !source.isEmptyOrWhitespace{
            pushURL = "\(pushURL)&\(VisilabsConfig.UTM_SOURCE_KEY)=\(urlEncode(source))"
        }
        if !campaign.isEmptyOrWhitespace{
            pushURL = "\(pushURL)&\(VisilabsConfig.UTM_CAMPAIGN_KEY)=\(urlEncode(campaign))"
        }
        if !medium.isEmptyOrWhitespace{
            pushURL = "\(pushURL)&\(VisilabsConfig.UTM_MEDIUM_KEY)=\(urlEncode(medium))"
        }
        if !content.isEmptyOrWhitespace{
            pushURL = "\(pushURL)&\(VisilabsConfig.UTM_CONTENT_KEY)=\(urlEncode(content))"
        }
        return pushURL
    }
    
    private func setCookieID() {
        cookieID = UUID().uuidString
        //TODO:
        if !NSKeyedArchiver.archiveRootObject(cookieID!, toFile: "") {
            //TODO:
            //DLog("Visilabs: WARNING - Unable to archive identity!!!")
        }
    }

    
    public func setExVisitorIDToNull(){
        self.exVisitorID = nil
    }
}

