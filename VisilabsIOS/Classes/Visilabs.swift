import WebKit
import AdSupport

open class Visilabs{
    
    private static var API: Visilabs?
    private static var visilabsReachability : VisilabsReachability?
    
    private var organizationID : String
    private var siteID : String
    private var loggerURL : String
    private var dataSource : String
    private var realTimeURL : String
    private var channel : String
    private var requestTimeoutInSeconds : Int
    private var restURL : String?
    private var encryptedDataSource : String?
    private var targetURL : String?
    private var actionURL : String?
    private var geofenceURL : String?
    private var geofenceEnabled : Bool
    private var maxGeofenceCount : Int
    
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
    private var serialQueue: DispatchQueue?
    private var currentlyShowingNotification: Any?
    private var notificationViewController: UIViewController?
    private var notificationResponseCached = false
    private var loggerCookieKey: String?
    private var loggerCookieValue: String?
    private var realTimeCookieKey: String?
    private var realTimeCookieValue: String?
    private var loggerOM3rdCookieValue: String?
    private var realTimeOM3rdCookieValue: String?
    private var webView: WKWebView?
    
    private var cookieID: String?
    private var exVisitorID: String?
    private var tokenID: String?
    private var appID: String?
    private var isOnline: Bool = true
    private var userAgent: String?
    private var loggingEnabled: Bool = true
    private var checkForNotificationsOnLoggerRequest: Bool = true
    private var miniNotificationPresentationTime: Float = 0.0
    private var miniNotificationBackgroundColor: UIColor = .clear

    
    /* TODO:
    func dispatch_once_on_main_thread(_ predicate: UnsafeMutableRawPointer?, _ block: () -> ()) {
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

    //TODO:
    private func trackNotificationClick(visilabsNotification: VisilabsNotification){
    }
    
    //TODO:
    private func checkForNotificationsResponse(withCompletion completion: @escaping (_ notifications: [AnyHashable]?) -> Void, pageName: String?, properties: inout [AnyHashable : Any]) {
    }
    
    //TODO: class func vs static farkı nedir?
    private class func topPresentedViewController() -> UIViewController?{
        return nil
    }
    
    //TODO: class func vs static farkı nedir?
    private class func canPresentFromViewController(viewController: UIViewController?) -> Bool{
        return false
    }
    
    //TODO:
    private func showNotification(pageName: String?) {
    }
    
    //TODO:
    private func showNotification(_ pageName: String?, properties: [AnyHashable : Any]?) {
    }

    //TODO:
    private func showNotification(withObject notification: VisilabsNotification?) {
    }

    //TODO:
    private func showMiniNotification(withObject notification: VisilabsNotification?) -> Bool {
        return false
    }

    //TODO:
    private func showFullNotification(withObject notification: VisilabsNotification?) -> Bool {
        return false
    }

    //TODO:
    private func notificationController(controller: VisilabsNotificationViewController?, wasDismissedWithStatus status: Bool) {
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
    }
    
    // MARK: Public Methods
    
    //TODO
    public func urlEncode(prior: String) -> String{
        return "TODO"
    }
    
    //TODO
    func buildTargetRequest(zoneID: String?,productCode: String?) -> VisilabsTargetRequest? {
        return nil
    }

    //TODO
    func buildTargetRequest(zoneID: String?, productCode: String?, properties: inout [AnyHashable : Any], filters: inout [VisilabsTargetFilter]) -> VisilabsTargetRequest? {
        return nil
    }

    //TODO
    func buildGeofenceRequest(action: String?, actionID: String?, latitude: Double, longitude: Double, geofenceID: String?, isDwell: Bool, isEnter: Bool) -> VisilabsGeofenceRequest? {
        return nil
    }
    
    //TODO: burada synchronized olacak
    public class func callAPI() -> Visilabs? {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if Visilabs.API == nil{
                print("zort")
            }
        }
        return Visilabs.API
    }
    
    //TODO: Buradaki DispatchQueue doğru yaklaşım mı?
    public class func createAPI(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String) -> Visilabs? {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if API == nil {
                API = Visilabs(organizationID: organizationID, siteID: siteID, loggerURL: loggerURL, dataSource: dataSource, realTimeURL: realTimeURL, channel: channel, requestTimeoutInSeconds: 60, restURL: nil, encryptedDataSource: nil, targetURL: nil, actionURL: nil, geofenceURL: nil, geofenceEnabled: false, maxGeofenceCount: 20)
            }
        }
        return API
    }
    
    //TODO: Buradaki DispatchQueue doğru yaklaşım mı?
    public class func createAPI(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String, requestTimeoutInSeconds: Int) -> Visilabs? {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if API == nil {
                API = Visilabs(organizationID: organizationID, siteID: siteID, loggerURL: loggerURL, dataSource: dataSource, realTimeURL: realTimeURL, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, restURL: nil, encryptedDataSource: nil, targetURL: nil, actionURL: nil, geofenceURL: nil, geofenceEnabled: false, maxGeofenceCount: 20)
            }
        }
        return API
    }
    
    //TODO: Buradaki DispatchQueue doğru yaklaşım mı?
    public class func createAPI(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String, requestTimeoutInSeconds: Int, targetURL: String) -> Visilabs? {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if API == nil {
                API = Visilabs(organizationID: organizationID, siteID: siteID, loggerURL: loggerURL, dataSource: dataSource, realTimeURL: realTimeURL, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, restURL: nil, encryptedDataSource: nil, targetURL: targetURL, actionURL: nil, geofenceURL: nil, geofenceEnabled: false, maxGeofenceCount: 20)
            }
        }
        return API
    }
    
    //TODO: Buradaki DispatchQueue doğru yaklaşım mı?
    public class func createAPI(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String, requestTimeoutInSeconds: Int, targetURL: String, actionURL: String) -> Visilabs? {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if API == nil {
                API = Visilabs(organizationID: organizationID, siteID: siteID, loggerURL: loggerURL, dataSource: dataSource, realTimeURL: realTimeURL, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, restURL: nil, encryptedDataSource: nil, targetURL: targetURL, actionURL: actionURL, geofenceURL: nil, geofenceEnabled: false, maxGeofenceCount: 20)
            }
        }
        return API
    }
    
    //TODO: Buradaki DispatchQueue doğru yaklaşım mı?
    public class func createAPI(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String, requestTimeoutInSeconds: Int, targetURL: String, actionURL: String, geofenceURL: String, geofenceEnabled: Bool) -> Visilabs? {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if API == nil {
                API = Visilabs(organizationID: organizationID, siteID: siteID, loggerURL: loggerURL, dataSource: dataSource, realTimeURL: realTimeURL, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, restURL: nil, encryptedDataSource: nil, targetURL: targetURL, actionURL: actionURL, geofenceURL: geofenceURL, geofenceEnabled: geofenceEnabled, maxGeofenceCount: 20)
            }
        }
        return API
    }

    //TODO: Buradaki DispatchQueue doğru yaklaşım mı?
    public class func createAPI(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String, requestTimeoutInSeconds: Int, targetURL: String, actionURL: String, geofenceURL: String, geofenceEnabled: Bool, maxGeofenceCount: Int) -> Visilabs? {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if API == nil {
                API = Visilabs(organizationID: organizationID, siteID: siteID, loggerURL: loggerURL, dataSource: dataSource, realTimeURL: realTimeURL, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, restURL: nil, encryptedDataSource: nil, targetURL: targetURL, actionURL: actionURL, geofenceURL: geofenceURL, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount)
            }
        }
        return API
    }
    
    //TODO: Buradaki DispatchQueue doğru yaklaşım mı?
    public class func createAPI(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String, requestTimeoutInSeconds: Int, targetURL: String, actionURL: String, geofenceURL: String, geofenceEnabled: Bool, maxGeofenceCount: Int, restURL: String, encryptedDataSource: String) -> Visilabs? {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if API == nil {
                API = Visilabs(organizationID: organizationID, siteID: siteID, loggerURL: loggerURL, dataSource: dataSource, realTimeURL: realTimeURL, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, restURL: restURL, encryptedDataSource: encryptedDataSource, targetURL: targetURL, actionURL: actionURL, geofenceURL: geofenceURL, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount)
            }
        }
        return API
    }

    public func customEvent(pageName: String, properties: [String:String]){
        
    }

    public func login(exVisitorID: String){
        
    }

    public func signUp(exVisitorID: String){
        
    }
    
    public func login(exVisitorID: String, properties: [String:String]){
        
    }
    
    public func signUp(exVisitorID: String, properties: [String:String]){
        
    }
    
    public func getPushURL(source: String, campaign: String, medium: String, content: String) -> String?{
        return nil
    }
    
    public func setExVisitorIDToNull(){
        
    }
}

extension String {
    func stringBetweenString(start: String?, end: String?) -> String? {
        let startRange = (self as NSString).range(of: start ?? "")
        if startRange.location != NSNotFound {
            var targetRange: NSRange = NSRange()
            targetRange.location = startRange.location + startRange.length
            targetRange.length = count - targetRange.location
            let endRange = (self as NSString).range(of: end ?? "", options: [], range: targetRange)
            if endRange.location != NSNotFound {
                targetRange.length = endRange.location - targetRange.location
                return (self as NSString).substring(with: targetRange)
            }
        }
        return nil
    }

    func contains(_ string: String?, options: String.CompareOptions) -> Bool {
        let rng = (self as NSString).range(of: string ?? "", options: options)
        return rng.location != NSNotFound
    }

    func contains(_ string: String) -> Bool {
        return contains(string, options: [])
    }
}
