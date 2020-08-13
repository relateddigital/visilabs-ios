//
//  VisilabsInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 4.05.2020.
//

import Foundation
import SystemConfiguration
import WebKit

typealias Queue = [[String: String]]

protocol AppLifecycle {
    func applicationDidBecomeActive()
    func applicationWillResignActive()
}

struct VisilabsUser {
    var cookieId: String?
    var exVisitorId: String?
    var tokenId: String?
    var appId: String?
    var visitData: String?
    var visitorData: String?
    var userAgent: String?
    var identifierForAdvertising: String?
}

struct VisilabsProfile {
    var organizationId: String
    var siteId: String
    var dataSource: String
    var channel: String
    var requestTimeoutInSeconds: Int
    var geofenceEnabled: Bool
    var inAppNotificationsEnabled: Bool
    var maxGeofenceCount: Int
}

public class VisilabsInstance: CustomDebugStringConvertible {
    var organizationId = ""
    var siteId = ""
    var dataSource = ""
    var channel = ""
    var requestTimeoutInSeconds: Int
    var geofenceEnabled = false
    var inAppNotificationsEnabled = false
    var maxGeofenceCount: Int
    var restUrl: String?
    var encryptedDataSource: String?

    var visilabsUser: VisilabsUser!
    var visilabsCookie = VisilabsCookie()
    var eventsQueue = Queue()
    // var flushEventsQueue = Queue()
    var trackingQueue: DispatchQueue!
    var recommendationQueue: DispatchQueue!
    var networkQueue: DispatchQueue!
    let readWriteLock: VisilabsReadWriteLock

    // TODO: www.relateddigital.com ı değiştirmeli miyim?
    static let reachability = SCNetworkReachabilityCreateWithName(nil, "www.relateddigital.com")

    let visilabsEventInstance: VisilabsEventInstance
    let visilabsSendInstance: VisilabsSendInstance
    let visilabsInAppNotificationInstance: VisilabsInAppNotificationInstance
    let visilabsRecommendationInstance: VisilabsRecommendationInstance
    
    public var debugDescription: String {
        return "Visilabs(siteId : \(siteId) organizationId: \(organizationId)"
    }

    public var loggingEnabled: Bool = false {
        didSet {
            if loggingEnabled {
                VisilabsLogger.enableLevel(.debug)
                VisilabsLogger.enableLevel(.info)
                VisilabsLogger.enableLevel(.warning)
                VisilabsLogger.enableLevel(.error)
                VisilabsLogger.info(message: "Visilabs Logging Enabled")
            } else {
                VisilabsLogger.info(message: "Visilabs Logging Disabled")
                VisilabsLogger.disableLevel(.debug)
                VisilabsLogger.disableLevel(.info)
                VisilabsLogger.disableLevel(.warning)
                VisilabsLogger.disableLevel(.error)
            }
        }
    }

    init(organizationId: String, siteId: String, dataSource: String, inAppNotificationsEnabled: Bool, channel: String, requestTimeoutInSeconds: Int, geofenceEnabled: Bool, maxGeofenceCount: Int, restUrl: String?, encryptedDataSource: String?) {
        if let reachability = VisilabsInstance.reachability {
            var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            func reachabilityCallback(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, unsafePointer: UnsafeMutableRawPointer?) {
                let wifi = flags.contains(SCNetworkReachabilityFlags.reachable) && !flags.contains(SCNetworkReachabilityFlags.isWWAN)
                VisilabsLogger.info(message: "reachability changed, wifi=\(wifi)")
            }
            if SCNetworkReachabilitySetCallback(reachability, reachabilityCallback, &context) {
                if !SCNetworkReachabilitySetDispatchQueue(reachability, trackingQueue) {
                    // cleanup callback if setting dispatch queue failed
                    SCNetworkReachabilitySetCallback(reachability, nil, nil)
                }
            }
        }
        
        

        self.organizationId = organizationId
        self.siteId = siteId
        self.dataSource = dataSource
        self.channel = channel
        self.requestTimeoutInSeconds = requestTimeoutInSeconds
        self.geofenceEnabled = geofenceEnabled
        self.inAppNotificationsEnabled = inAppNotificationsEnabled
        self.maxGeofenceCount = (maxGeofenceCount < 0 && maxGeofenceCount > 20) ? 20 : maxGeofenceCount
        self.restUrl = restUrl
        self.encryptedDataSource = encryptedDataSource

        readWriteLock = VisilabsReadWriteLock(label: "VisilabsInstanceLock")
        let label = "com.relateddigital.\(self.siteId)"
        self.trackingQueue = DispatchQueue(label: "\(label).tracking)", qos: .utility)
        self.recommendationQueue = DispatchQueue(label: "\(label).recommendation)", qos: .utility)
        self.networkQueue = DispatchQueue(label: "\(label).network)", qos: .utility)
        self.visilabsEventInstance = VisilabsEventInstance(organizationId: self.organizationId, siteId: self.siteId, lock: self.readWriteLock)
        self.visilabsSendInstance = VisilabsSendInstance()
        self.visilabsInAppNotificationInstance = VisilabsInAppNotificationInstance(lock: self.readWriteLock)
        self.visilabsRecommendationInstance = VisilabsRecommendationInstance(organizationId: self.organizationId, siteId: self.siteId)
        
        self.visilabsUser = unarchive()
        self.visilabsInAppNotificationInstance.inAppDelegate = self
        
        

        if let idfa = VisilabsHelper.getIDFA() {
            visilabsUser.identifierForAdvertising = idfa
        }

        if visilabsUser.cookieId.isNilOrWhiteSpace {
            visilabsUser.cookieId = VisilabsHelper.generateCookieId()
            VisilabsPersistence.archiveUser(visilabsUser: visilabsUser)
        }

        
        if(self.geofenceEnabled && VisilabsBasePath.endpoints[.geofence] != nil){
            
        }

        computeWebViewUserAgent2()
    }

    var webView: WKWebView?

    func computeWebViewUserAgent2() {
        DispatchQueue.main.async {
            self.webView = WKWebView(frame: CGRect.zero)
            self.webView?.loadHTMLString("<html></html>", baseURL: nil)
            self.webView?.evaluateJavaScript("navigator.userAgent", completionHandler: { userAgent, _ in
                if let userAgentString = userAgent as? String {
                    self.visilabsUser.userAgent = userAgentString
                }
            })
        }
    }

    private func setEndpoints() {
        VisilabsBasePath.endpoints[.logger] = "\(VisilabsConstants.LOGGER_END_POINT)/\(dataSource)/\(VisilabsConstants.OM_GIF)"
        VisilabsBasePath.endpoints[.realtime] = "\(VisilabsConstants.REALTIME_END_POINT)/\(dataSource)/\(VisilabsConstants.OM_GIF)"
        VisilabsBasePath.endpoints[.target] = VisilabsConstants.RECOMMENDATION_END_POINT
        VisilabsBasePath.endpoints[.action] = VisilabsConstants.ACTION_END_POINT
        VisilabsBasePath.endpoints[.geofence] = VisilabsConstants.GEOFENCE_END_POINT
        VisilabsBasePath.endpoints[.mobile] = VisilabsConstants.MOBILE_END_POINT
    }

    static func sharedUIApplication() -> UIApplication? {
        guard let sharedApplication = UIApplication.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue() as? UIApplication else {
            return nil
        }
        return sharedApplication
    }
}

extension VisilabsInstance {
    // MARK: - Event

    public func customEvent(_ pageName: String, properties: [String: String]) {
        if pageName.isEmptyOrWhitespace {
            VisilabsLogger.error(message: "Visilabs: customEvent can not be called with empty page name.")
            return
        }

        // let epochInterval = Date().timeIntervalSince1970

        trackingQueue.async { [weak self, pageName, properties] in
            guard let self = self else { return }
            var eQueue = Queue()
            var vUser = VisilabsUser()
            var chan = ""

            self.readWriteLock.read {
                eQueue = self.eventsQueue
                vUser = self.visilabsUser
                chan = self.channel
            }

            let (eventsQueue, visilabsUser, clearUserParameters, channel) = self.visilabsEventInstance.customEvent(pageName: pageName, properties: properties, eventsQueue: eQueue, visilabsUser: vUser, channel: chan)

            self.readWriteLock.write {
                self.eventsQueue = eventsQueue
                self.visilabsUser = visilabsUser
                self.channel = channel
            }

            self.readWriteLock.read {
                VisilabsPersistence.archiveUser(visilabsUser: self.visilabsUser)

                if clearUserParameters {
                    VisilabsPersistence.clearParameters()
                }
            }

            if let event = self.eventsQueue.last {
                VisilabsPersistence.saveParameters(event)
                if let _ = VisilabsBasePath.endpoints[.action], self.inAppNotificationsEnabled {
                    self.checkInAppNotification(properties: event)
                }
            }

            self.send()

            // TODO:
            // self.decideInstance.notificationsInstance.showNotification(event: event, properties: mergedProperties)
        }
    }

    public func login(exVisitorId: String, properties: [String: String] = [String: String]()) {
        if exVisitorId.isEmptyOrWhitespace {
            VisilabsLogger.error(message: "Visilabs: login can not be called with empty exVisitorId.")
            return
        }
        var props = properties
        props[VisilabsConstants.EXVISITORID_KEY] = exVisitorId
        props["Login"] = exVisitorId
        props["OM.b_login"] = "Login"
        customEvent("LoginPage", properties: props)
    }

    public func signUp(exVisitorId: String, properties: [String: String] = [String: String]()) {
        if exVisitorId.isEmptyOrWhitespace {
            VisilabsLogger.error(message: "Visilabs: signUp can not be called with empty exVisitorId.")
            return
        }
        var props = properties
        props[VisilabsConstants.EXVISITORID_KEY] = exVisitorId
        props["SignUp"] = exVisitorId
        props["OM.b_sgnp"] = "SignUp"
        customEvent("SignUpPage", properties: props)
    }
}

extension VisilabsInstance {
    // MARK: - Persistence

    private func archive() {
        
    }

    // TODO: kontrol et sıra doğru mu? gelen değerler null ise set'lemeli miyim?
    private func unarchive() -> VisilabsUser {
        return VisilabsPersistence.unarchiveUser()
    }
}

extension VisilabsInstance {
    // MARK: - Send

    private func send() {
        trackingQueue.async { [weak self] in
            self?.networkQueue.async { [weak self] in
                guard let self = self else {
                    return
                }

                var eQueue = Queue()
                var vUser = VisilabsUser()
                var vCookie = VisilabsCookie()

                self.readWriteLock.read {
                    eQueue = self.eventsQueue
                    vUser = self.visilabsUser
                    vCookie = self.visilabsCookie
                }

                self.readWriteLock.write {
                    self.eventsQueue.removeAll()
                }

                let cookie = self.visilabsSendInstance.sendEventsQueue(eQueue, visilabsUser: vUser, visilabsCookie: vCookie, timeoutInterval: TimeInterval(self.requestTimeoutInSeconds))

                self.readWriteLock.write {
                    self.visilabsCookie = cookie
                }
            }
        }
    }
}


public enum VisilabsFavoriteAttribute: String {
    case ageGroup
    case attr1
    case attr2
    case attr3
    case attr4
    case attr5
    case attr6
    case attr7
    case attr8
    case attr9
    case attr10
    case brand
    case category
    case color
    case gender
    case material
    case title
}

public class VisilabsFavoritesResponse {
    public var favorites: [VisilabsFavoriteAttribute: [String]]
    public var error: VisilabsReason?
    
    internal init(favorites: [VisilabsFavoriteAttribute: [String]], error: VisilabsReason? = nil) {
        self.favorites = favorites
        self.error = error
    }
}



extension VisilabsInstance: VisilabsInAppNotificationsDelegate {
    
    // MARK: - TargetingActions

    
    public func getFavorites(actionId: String, completion: @escaping ((_ response: VisilabsFavoritesResponse) -> Void)){
        
    }
    
    // TODO: this method added for test purposes
    public func showNotification(_ visilabsInAppNotification: VisilabsInAppNotification) {
        visilabsInAppNotificationInstance.notificationsInstance.showNotification(visilabsInAppNotification)
    }

    func checkInAppNotification(properties: [String: String]) {
        trackingQueue.async { [weak self, properties] in
            guard let self = self else { return }

            self.networkQueue.async { [weak self, properties] in

                guard let self = self else {
                    return
                }

                self.visilabsInAppNotificationInstance.checkInAppNotification(properties: properties, visilabsUser: self.visilabsUser, timeoutInterval: TimeInterval(self.requestTimeoutInSeconds), completion: { visilabsInAppNotification in
                    if let notification = visilabsInAppNotification {
                        self.visilabsInAppNotificationInstance.notificationsInstance.showNotification(notification)
                    }
                })
            }
        }
    }

    func notificationDidShow(_ notification: VisilabsInAppNotification) {
        visilabsUser.visitData = notification.visitData
        visilabsUser.visitorData = notification.visitorData
        
        // TODO: burada archive da yapılacak.
    }

    func trackNotification(_ notification: VisilabsInAppNotification, event: String, properties: [String : String]) {
        
        if (notification.queryString == nil || notification.queryString == "") {
            VisilabsLogger.info(message: "Notification or query string is nil or empty")
            return
        }
        
        let qs = notification.queryString
        let qsArr = qs!.components(separatedBy: "&")
        var properties = properties
        properties["OM.domain"] =  "\(self.dataSource)_IOS"
        properties["OM.zn"] = qsArr[0].components(separatedBy: "=")[1]
        properties["OM.zpc"] = qsArr[1].components(separatedBy: "=")[1]
        customEvent("OM_evt.gif", properties: properties)
    }
}


extension VisilabsInstance {
    
    //MARK: - Recommendation
    
    public func recommend(zoneID: String, productCode: String, filters: [VisilabsRecommendationFilter] = [], properties: [String : String] = [:], completion: @escaping ((_ response: VisilabsRecommendationResponse) -> Void)) {
        
        if VisilabsBasePath.endpoints[.target] == nil {
            return
        }
        
        self.recommendationQueue.async { [weak self, zoneID, productCode, filters, properties, completion] in
            self?.networkQueue.async { [weak self, zoneID, productCode, filters, properties, completion] in
                guard let self = self else {
                    return
                }
                
                var vUser = VisilabsUser()
                var channel = "IOS"
                
                self.readWriteLock.read {
                    vUser = self.visilabsUser
                    channel = self.channel
                }
                
                self.visilabsRecommendationInstance.recommend(zoneID: zoneID, productCode: productCode, visilabsUser: vUser, channel: channel, timeoutInterval: TimeInterval(self.requestTimeoutInSeconds), properties: properties, filters: filters) { (response) in
                    completion(response)
                }
                
            }
        }
    }
}


