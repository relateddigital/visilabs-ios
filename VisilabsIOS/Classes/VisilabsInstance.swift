//
//  VisilabsInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 4.05.2020.
//

import Foundation
import SystemConfiguration

typealias Queue = [[String: String]]

struct VisilabsUser : Codable {
    var cookieId: String?
    var exVisitorId: String?
    var tokenId: String?
    var appId: String?
    var visitData: String?
    var visitorData: String?
    var userAgent: String?
    var identifierForAdvertising: String?
}

struct VisilabsProfile : Codable {
    var organizationId: String
    var profileId: String
    var dataSource: String
    var channel: String
    var requestTimeoutInSeconds: Int
    var geofenceEnabled: Bool
    var inAppNotificationsEnabled: Bool
    var maxGeofenceCount: Int
    var requestTimeoutInterval: TimeInterval {
        return TimeInterval(requestTimeoutInSeconds)
    }
}

public class VisilabsInstance: CustomDebugStringConvertible {

    var visilabsUser: VisilabsUser!
    var visilabsProfile: VisilabsProfile!
    var visilabsCookie = VisilabsCookie()
    var eventsQueue = Queue()
    var trackingQueue: DispatchQueue!
    var targetingActionQueue: DispatchQueue!
    var recommendationQueue: DispatchQueue!
    var networkQueue: DispatchQueue!
    let readWriteLock: VisilabsReadWriteLock

    // TODO: www.relateddigital.com ı değiştirmeli miyim?
    static let reachability = SCNetworkReachabilityCreateWithName(nil, "www.relateddigital.com")

    let visilabsEventInstance: VisilabsEvent
    let visilabsSendInstance: VisilabsSend
    let visilabsTargetingActionInstance: VisilabsTargetingAction
    let visilabsRecommendationInstance: VisilabsRecommendation
    
    public var debugDescription: String {
        return "Visilabs(siteId : \(self.visilabsProfile.profileId) organizationId: \(self.visilabsProfile.organizationId)"
    }

    public var loggingEnabled: Bool = false {
        didSet {
            if loggingEnabled {
                VisilabsLogger.enableLevel(.debug)
                VisilabsLogger.enableLevel(.info)
                VisilabsLogger.enableLevel(.warning)
                VisilabsLogger.enableLevel(.error)
                VisilabsLogger.info("Logging Enabled")
            } else {
                VisilabsLogger.info("Logging Disabled")
                VisilabsLogger.disableLevel(.debug)
                VisilabsLogger.disableLevel(.info)
                VisilabsLogger.disableLevel(.warning)
                VisilabsLogger.disableLevel(.error)
            }
        }
    }

    init(organizationId: String, profileId: String, dataSource: String, inAppNotificationsEnabled: Bool, channel: String, requestTimeoutInSeconds: Int, geofenceEnabled: Bool, maxGeofenceCount: Int) {
        
        //TODO: bu reachability doğru çalışıyor mu kontrol et
        if let reachability = VisilabsInstance.reachability {
            var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            func reachabilityCallback(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, unsafePointer: UnsafeMutableRawPointer?) {
                let wifi = flags.contains(SCNetworkReachabilityFlags.reachable) && !flags.contains(SCNetworkReachabilityFlags.isWWAN)
                VisilabsLogger.info("reachability changed, wifi=\(wifi)")
            }
            if SCNetworkReachabilitySetCallback(reachability, reachabilityCallback, &context) {
                if !SCNetworkReachabilitySetDispatchQueue(reachability, trackingQueue) {
                    // cleanup callback if setting dispatch queue failed
                    SCNetworkReachabilitySetCallback(reachability, nil, nil)
                }
            }
        }
        
        
        
        self.visilabsProfile = VisilabsProfile(organizationId: organizationId, profileId: profileId, dataSource: dataSource, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, geofenceEnabled: geofenceEnabled, inAppNotificationsEnabled: inAppNotificationsEnabled, maxGeofenceCount: (maxGeofenceCount < 0 && maxGeofenceCount > 20) ? 20 : maxGeofenceCount)
        VisilabsDataManager.saveVisilabsProfile(visilabsProfile)

        self.readWriteLock = VisilabsReadWriteLock(label: "VisilabsInstanceLock")
        let label = "com.relateddigital.\(self.visilabsProfile.profileId)"
        self.trackingQueue = DispatchQueue(label: "\(label).tracking)", qos: .utility)
        self.recommendationQueue = DispatchQueue(label: "\(label).recommendation)", qos: .utility)
        self.targetingActionQueue = DispatchQueue(label: "\(label).targetingaction)", qos: .utility)
        self.networkQueue = DispatchQueue(label: "\(label).network)", qos: .utility)
        self.visilabsEventInstance = VisilabsEvent(visilabsProfile: self.visilabsProfile)
        self.visilabsSendInstance = VisilabsSend()
        self.visilabsTargetingActionInstance = VisilabsTargetingAction(lock: self.readWriteLock, visilabsProfile: self.visilabsProfile)
        self.visilabsRecommendationInstance = VisilabsRecommendation(visilabsProfile: visilabsProfile)
        
        self.visilabsUser = self.unarchive()
        self.visilabsTargetingActionInstance.inAppDelegate = self
        
        if let idfa = VisilabsHelper.getIDFA() {
            visilabsUser.identifierForAdvertising = idfa
        }

        if visilabsUser.cookieId.isNilOrWhiteSpace {
            visilabsUser.cookieId = VisilabsHelper.generateCookieId()
            VisilabsDataManager.saveVisilabsUser(visilabsUser)
            //VisilabsPersistence.archiveUser(visilabsUser)
        }

        if(self.visilabsProfile.geofenceEnabled){
            self.startGeofencing()
        }
        
        VisilabsHelper.setEndpoints(dataSource: self.visilabsProfile.dataSource)
        
        VisilabsHelper.computeWebViewUserAgent { (userAgentString) in
            self.visilabsUser.userAgent = userAgentString
        }
        
    }

    static func sharedUIApplication() -> UIApplication? {
        guard let sharedApplication = UIApplication.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue() as? UIApplication else {
            return nil
        }
        return sharedApplication
    }
}

// MARK: - EVENT

extension VisilabsInstance {

    public func customEvent(_ pageName: String, properties: [String: String]) {
        if pageName.isEmptyOrWhitespace {
            VisilabsLogger.error("customEvent can not be called with empty page name.")
            return
        }
        trackingQueue.async { [weak self, pageName, properties] in
            guard let self = self else { return }
            var eQueue = Queue()
            var vUser = VisilabsUser()
            var chan = ""
            self.readWriteLock.read {
                eQueue = self.eventsQueue
                vUser = self.visilabsUser
                chan = self.visilabsProfile.channel
            }
            let (eventsQueue, visilabsUser, clearUserParameters, channel) = self.visilabsEventInstance.customEvent(pageName: pageName, properties: properties, eventsQueue: eQueue, visilabsUser: vUser, channel: chan)
            self.readWriteLock.write {
                self.eventsQueue = eventsQueue
                self.visilabsUser = visilabsUser
                self.visilabsProfile.channel = channel
            }
            self.readWriteLock.read {
                VisilabsDataManager.saveVisilabsUser(self.visilabsUser)
                //VisilabsPersistence.archiveUser(self.visilabsUser)
                if clearUserParameters {
                    VisilabsPersistence.clearParameters()
                }
            }
            if let event = self.eventsQueue.last {
                VisilabsPersistence.saveParameters(event)
                if let _ = VisilabsBasePath.endpoints[.action], self.visilabsProfile.inAppNotificationsEnabled {
                    self.checkInAppNotification(properties: event)
                }
            }

            self.send()
        }
    }

    public func login(exVisitorId: String, properties: [String: String] = [String: String]()) {
        if exVisitorId.isEmptyOrWhitespace {
            VisilabsLogger.error("login can not be called with empty exVisitorId.")
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
            VisilabsLogger.error("signUp can not be called with empty exVisitorId.")
            return
        }
        var props = properties
        props[VisilabsConstants.EXVISITORID_KEY] = exVisitorId
        props["SignUp"] = exVisitorId
        props["OM.b_sgnp"] = "SignUp"
        customEvent("SignUpPage", properties: props)
    }
}

// MARK: - PERSISTENCE

extension VisilabsInstance {

    private func archive() {
        
    }

    // TODO: kontrol et sıra doğru mu? gelen değerler null ise set'lemeli miyim?
    private func unarchive() -> VisilabsUser {
        if let visilabsUser = VisilabsDataManager.readVisilabsUser(), !visilabsUser.cookieId.isNilOrWhiteSpace{
            return visilabsUser
        } else {
            return VisilabsPersistence.unarchiveUser()
        }
    }
}

// MARK: - SEND

extension VisilabsInstance {
    
    private func send() {
        trackingQueue.async { [weak self] in
            self?.networkQueue.async { [weak self] in
                guard let self = self else { return }
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
                let cookie = self.visilabsSendInstance.sendEventsQueue(eQueue, visilabsUser: vUser, visilabsCookie: vCookie, timeoutInterval: TimeInterval(self.visilabsProfile.requestTimeoutInSeconds))
                self.readWriteLock.write {
                    self.visilabsCookie = cookie
                }
            }
        }
    }
}


// MARK: - TARGETING ACTIONS

// MARK: - Favorite Attribute Actions

extension VisilabsInstance {
    
    public func getFavoriteAttributeActions(actionId: Int? = nil, completion: @escaping ((_ response: VisilabsFavoriteAttributeActionResponse) -> Void)){
        self.targetingActionQueue.async { [weak self] in
            self?.networkQueue.async { [weak self] in
                guard let self = self else { return }
                var vUser = VisilabsUser()
                self.readWriteLock.read {
                    vUser = self.visilabsUser
                }
                self.visilabsTargetingActionInstance.getFavorites(visilabsUser: vUser, actionId: actionId, completion: completion)
            }
        }
    }
    
}

// MARK: - InAppNotification

extension VisilabsInstance: VisilabsInAppNotificationsDelegate {

    // This method added for test purposes
    public func showNotification(_ visilabsInAppNotification: VisilabsInAppNotification) {
        visilabsTargetingActionInstance.notificationsInstance.showNotification(visilabsInAppNotification)
    }

    func checkInAppNotification(properties: [String: String]) {
        trackingQueue.async { [weak self, properties] in
            guard let self = self else { return }
            self.networkQueue.async { [weak self, properties] in
                guard let self = self else { return }
                self.visilabsTargetingActionInstance.checkInAppNotification(properties: properties, visilabsUser: self.visilabsUser, timeoutInterval: TimeInterval(self.visilabsProfile.requestTimeoutInSeconds), completion: { visilabsInAppNotification in
                    if let notification = visilabsInAppNotification {
                        self.visilabsTargetingActionInstance.notificationsInstance.showNotification(notification)
                    }
                })
            }
        }
    }

    func notificationDidShow(_ notification: VisilabsInAppNotification) {
        visilabsUser.visitData = notification.visitData
        visilabsUser.visitorData = notification.visitorData
        VisilabsDataManager.saveVisilabsUser(visilabsUser)
    }

    func trackNotification(_ notification: VisilabsInAppNotification, event: String, properties: [String : String]) {
        if (notification.queryString == nil || notification.queryString == "") {
            VisilabsLogger.info("Notification or query string is nil or empty")
            return
        }
        let qs = notification.queryString
        let qsArr = qs!.components(separatedBy: "&")
        var properties = properties
        properties["OM.domain"] =  "\(self.visilabsProfile.dataSource)_IOS"
        properties["OM.zn"] = qsArr[0].components(separatedBy: "=")[1]
        properties["OM.zpc"] = qsArr[1].components(separatedBy: "=")[1]
        customEvent("OM_evt.gif", properties: properties)
    }
 
}

// MARK: - Story

extension VisilabsInstance {
    
    public func showStory(actionId: Int? = nil){
        
    }
    
}



//MARK: - RECOMMENDATION

extension VisilabsInstance {
    
    public func recommend(zoneID: String, productCode: String, filters: [VisilabsRecommendationFilter] = [], properties: [String : String] = [:], completion: @escaping ((_ response: VisilabsRecommendationResponse) -> Void)) {
        self.recommendationQueue.async { [weak self, zoneID, productCode, filters, properties, completion] in
            self?.networkQueue.async { [weak self, zoneID, productCode, filters, properties, completion] in
                guard let self = self else { return }
                var vUser = VisilabsUser()
                var channel = "IOS"
                self.readWriteLock.read {
                    vUser = self.visilabsUser
                    channel = self.visilabsProfile.channel
                }
                self.visilabsRecommendationInstance.recommend(zoneID: zoneID, productCode: productCode, visilabsUser: vUser, channel: channel, properties: properties, filters: filters) { (response) in
                    completion(response)
                }
            }
        }
    }
    
}


//MARK: - GEOFENCE

extension VisilabsInstance {
    
    private func startGeofencing() {
        VisilabsGeofence.sharedManager?.startGeofencing()
    }
    
    public var locationServicesEnabledForDevice: Bool {
        return VisilabsGeofence.sharedManager?.locationServicesEnabledForDevice ?? false
    }
    
    public var locationServiceStateStatusForApplication: VisilabsCLAuthorizationStatus {
        return VisilabsGeofence.sharedManager?.locationServiceStateStatusForApplication ?? .none
    }
}
