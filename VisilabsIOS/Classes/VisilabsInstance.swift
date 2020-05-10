//
//  VisilabsInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 4.05.2020.
//

import Foundation
import SystemConfiguration
import AdSupport

class Visilabs2 {
    
    public class func callAPI() -> VisilabsInstance {
        if let instance = VisilabsManager.sharedInstance.getInstance() {
            return instance
        } else {
            assert(false, "You have to call createAPI before calling the callAPI.")
            return Visilabs2.createAPI(organizationId: "", siteId: "", loggerUrl: "", dataSource: "", realTimeUrl: "")
        }
    }
    
    @discardableResult
    public class func createAPI(organizationId: String, siteId: String, loggerUrl: String, dataSource: String, realTimeUrl: String, channel: String = "IOS", requestTimeoutInSeconds: Int = 60, targetUrl: String? = nil, actionUrl: String? = nil, geofenceUrl: String? = nil, geofenceEnabled: Bool = false, maxGeofenceCount: Int = 20, restUrl: String? = nil, encryptedDataSource: String? = nil) -> VisilabsInstance {
        VisilabsManager.sharedInstance.initialize(organizationId: organizationId, siteId: siteId, loggerUrl: loggerUrl, dataSource: dataSource, realTimeUrl: realTimeUrl, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, targetUrl: targetUrl
        , actionUrl: actionUrl, geofenceUrl: geofenceUrl, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount, restUrl: restUrl, encryptedDataSource: encryptedDataSource)
    }
}

public typealias Properties = [String: String]
typealias InternalProperties = [String: Any]
typealias Queue = [InternalProperties]


struct VisilabsUser {
    var cookieId: String?
    var exVisitorId: String?
    var tokenId: String?
    var appId: String?
    var visitData: String?
    var visitorData: String?
    var identifierForAdvertising: String?
}

class VisilabsInstance: CustomDebugStringConvertible {
    
    var organizationId = ""
    var siteId = ""
    var dataSource = ""
    var channel = ""
    var requestTimeoutInSeconds : Int
    var geofenceEnabled = false
    var maxGeofenceCount : Int
    var restUrl : String?
    var encryptedDataSource : String?
    
    var visilabsUser = VisilabsUser()
    var eventsQueue = Queue()
    var flushEventsQueue = Queue()
    var trackingQueue: DispatchQueue!
    var networkQueue: DispatchQueue!
    let readWriteLock: VisilabsReadWriteLock
    
    //TODO: www.relateddigital.com ı değiştirmeli miyim?
    static let reachability = SCNetworkReachabilityCreateWithName(nil, "www.relateddigital.com")
    
    
    let visilabsEventInstance: VisilabsEvent
    
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
    
    init(organizationId: String, siteId: String, loggerUrl: String, dataSource: String, realTimeUrl: String, channel: String, requestTimeoutInSeconds: Int, targetUrl: String?, actionUrl: String?, geofenceUrl: String?, geofenceEnabled: Bool, maxGeofenceCount: Int, restUrl: String?, encryptedDataSource: String?) {
        self.readWriteLock = VisilabsReadWriteLock(label: "VisilabsInstanceLock")
        let label = "com.relateddigital.\(siteId)"
        self.trackingQueue = DispatchQueue(label: "\(label).tracking)", qos: .utility)
        self.networkQueue = DispatchQueue(label: "\(label).network)", qos: .utility)
        self.visilabsEventInstance = VisilabsEvent(apiToken: self.siteId, lock: self.readWriteLock)
        
        if let reachability = VisilabsInstance.reachability {
            var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            func reachabilityCallback(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, unsafePointer: UnsafeMutableRawPointer?) -> Void {
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
        self.maxGeofenceCount = (maxGeofenceCount < 0 && maxGeofenceCount > 20) ? 20 : maxGeofenceCount
        self.restUrl = restUrl
        self.encryptedDataSource = encryptedDataSource
        VisilabsBasePath.endpoints[.logger] = loggerUrl
        VisilabsBasePath.endpoints[.realtime] = realTimeUrl
        VisilabsBasePath.endpoints[.target] = targetUrl
        VisilabsBasePath.endpoints[.action] = actionUrl
        VisilabsBasePath.endpoints[.geofence] = geofenceUrl
        
        
        self.visilabsUser.identifierForAdvertising = getIDFA()
        
    }
    
}

extension VisilabsInstance {
    
    //MARK: - Event
    
    public func customEvent(_ pageName: String, properties: [String:String]){
        if pageName.isEmptyOrWhitespace {
            VisilabsLogger.error(message: "Visilabs: customEvent can not be called with empty page name.")
            return
        }
        
        let epochInterval = Date().timeIntervalSince1970
        
        trackingQueue.async { [weak self, pageName, properties, epochInterval] in
            guard let self = self else { return }
            var shadowEventsQueue = Queue()
            var shadowTimedEvents = InternalProperties()
            var shadowSuperProperties = InternalProperties()
            
            self.readWriteLock.read {
                shadowEventsQueue = self.eventsQueue
                //shadowTimedEvents = self.timedEvents
                //shadowSuperProperties = self.superProperties
            }
            let (eventsQueue, timedEvents, mergedProperties) = self.visilabsEventInstance.track(event: pageName, properties: properties, eventsQueue: shadowEventsQueue,
                                                                                        superProperties: shadowSuperProperties,
                                                                                        distinctId: self.distinctId,
                                                                                        anonymousId: self.anonymousId,
                                                                                        userId: self.userId,
                                                                                        hadPersistedDistinctId: self.hadPersistedDistinctId,
                                                                                        epochInterval: epochInterval)
            self.readWriteLock.write {
                self.eventsQueue = eventsQueue
                self.timedEvents = timedEvents
            }

            self.readWriteLock.read {
                Persistence.archiveEvents(self.flushEventsQueue + self.eventsQueue, token: self.apiToken)
            }
            
            self.decideInstance.notificationsInstance.showNotification(event: event, properties: mergedProperties)
            
        }
        
    }
    
    public func login(exVisitorId: String, properties: [String:String] = [String:String]()){
        if exVisitorId.isEmptyOrWhitespace {
            VisilabsLogger.error(message: "Visilabs: login can not be called with empty exVisitorId.")
            return
        }
        var props = properties
        props[VisilabsConfig.EXVISITORID_KEY] = exVisitorId
        props["Login"] = exVisitorId
        props["OM.b_login"] = "Login"
        customEvent("LoginPage", properties: props)
    }
    
    public func signUp(exVisitorId: String, properties: [String:String] = [String:String]()){
        if exVisitorId.isEmptyOrWhitespace {
            VisilabsLogger.error(message: "Visilabs: signUp can not be called with empty exVisitorId.")
            return
        }
        var props = properties
        props[VisilabsConfig.EXVISITORID_KEY] = exVisitorId
        props["SignUp"] = exVisitorId
        props["OM.b_sgnp"] = "SignUp"
        customEvent("SignUpPage", properties: props)
    }
    
}

extension VisilabsInstance {

    //MARK: - Persistence
    
    private func archive() {
        
    }
    
    private func unarchive() {
        
    }
    
    private func getIDFA() -> String {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            let IDFA = ASIdentifierManager.shared().advertisingIdentifier
            return IDFA.uuidString
        }
        //TODO: disabled ise ARCHIVE_KEY olarak okunmaya çalışılabilir.
        return ""
    }
}


class VisilabsManager {
    
    static let sharedInstance = VisilabsManager()
    private var instance: VisilabsInstance?
    
    init() {
        VisilabsLogger.addLogging(VisilabsPrintLogging())
    }
    
    func initialize(organizationId: String, siteId: String, loggerUrl: String, dataSource: String, realTimeUrl: String, channel: String, requestTimeoutInSeconds: Int, targetUrl: String?, actionUrl: String?, geofenceUrl: String?, geofenceEnabled: Bool, maxGeofenceCount: Int, restUrl: String?, encryptedDataSource: String?) -> VisilabsInstance {
        return VisilabsInstance(organizationId: organizationId, siteId: siteId, loggerUrl: loggerUrl, dataSource: dataSource, realTimeUrl: realTimeUrl, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, targetUrl: targetUrl
        , actionUrl: actionUrl, geofenceUrl: geofenceUrl, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount, restUrl: restUrl, encryptedDataSource: encryptedDataSource)
    }
    
    func getInstance() -> VisilabsInstance? {
        return instance
    }
}