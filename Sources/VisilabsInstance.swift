//
//  VisilabsInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 4.05.2020.
//

import UIKit
import SystemConfiguration

typealias Queue = [[String: String]]

struct VisilabsUser: Codable {
    var cookieId: String?
    var exVisitorId: String?
    var tokenId: String?
    var appId: String?
    var visitData: String?
    var visitorData: String?
    var userAgent: String?
    var identifierForAdvertising: String?
}

struct VisilabsProfile: Codable {
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
    var useInsecureProtocol = false
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

    // TO_DO: www.relateddigital.com ı değiştirmeli miyim?
    static let reachability = SCNetworkReachabilityCreateWithName(nil, "www.relateddigital.com")

    let visilabsEventInstance: VisilabsEvent
    let visilabsSendInstance: VisilabsSend
    let visilabsTargetingActionInstance: VisilabsTargetingAction
    let visilabsRecommendationInstance: VisilabsRecommendation

    public var debugDescription: String {
        return "Visilabs(siteId : \(self.visilabsProfile.profileId)" +
            "organizationId: \(self.visilabsProfile.organizationId)"
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

    public var useInsecureProtocol: Bool = false {
        didSet {
            self.visilabsProfile.useInsecureProtocol = useInsecureProtocol
            VisilabsHelper.setEndpoints(dataSource: self.visilabsProfile.dataSource,
                                        useInsecureProtocol: useInsecureProtocol)
            VisilabsPersistence.saveVisilabsProfile(self.visilabsProfile)
        }
    }
    //swiftlint:disable function_body_length
    init(organizationId: String,
         profileId: String,
         dataSource: String,
         inAppNotificationsEnabled: Bool,
         channel: String,
         requestTimeoutInSeconds: Int,
         geofenceEnabled: Bool,
         maxGeofenceCount: Int,
         isIDFAEnabled: Bool = true) {

        //TO_DO: bu reachability doğru çalışıyor mu kontrol et
        if let reachability = VisilabsInstance.reachability {
            var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil,
                                                       release: nil, copyDescription: nil)

            func reachabilityCallback(reachability: SCNetworkReachability,
                                      flags: SCNetworkReachabilityFlags,
                                      unsafePointer: UnsafeMutableRawPointer?) {
                let wifi = flags.contains(SCNetworkReachabilityFlags.reachable)
                    && !flags.contains(SCNetworkReachabilityFlags.isWWAN)
                VisilabsLogger.info("reachability changed, wifi=\(wifi)")
            }
            if SCNetworkReachabilitySetCallback(reachability, reachabilityCallback, &context) {
                if !SCNetworkReachabilitySetDispatchQueue(reachability, trackingQueue) {
                    // cleanup callback if setting dispatch queue failed
                    SCNetworkReachabilitySetCallback(reachability, nil, nil)
                }
            }
        }

        self.visilabsProfile = VisilabsProfile(organizationId: organizationId,
                                               profileId: profileId,
                                               dataSource: dataSource,
                                               channel: channel,
                                               requestTimeoutInSeconds: requestTimeoutInSeconds,
                                               geofenceEnabled: geofenceEnabled,
                                               inAppNotificationsEnabled: inAppNotificationsEnabled,
                                               maxGeofenceCount: (maxGeofenceCount < 0 && maxGeofenceCount > 20) ? 20 : maxGeofenceCount)
        VisilabsPersistence.saveVisilabsProfile(visilabsProfile)

        self.readWriteLock = VisilabsReadWriteLock(label: "VisilabsInstanceLock")
        let label = "com.relateddigital.\(self.visilabsProfile.profileId)"
        self.trackingQueue = DispatchQueue(label: "\(label).tracking)", qos: .utility)
        self.recommendationQueue = DispatchQueue(label: "\(label).recommendation)", qos: .utility)
        self.targetingActionQueue = DispatchQueue(label: "\(label).targetingaction)", qos: .utility)
        self.networkQueue = DispatchQueue(label: "\(label).network)", qos: .utility)
        self.visilabsEventInstance = VisilabsEvent(visilabsProfile: self.visilabsProfile)
        self.visilabsSendInstance = VisilabsSend()
        self.visilabsTargetingActionInstance = VisilabsTargetingAction(lock: self.readWriteLock,
                                                                       visilabsProfile: self.visilabsProfile)
        self.visilabsRecommendationInstance = VisilabsRecommendation(visilabsProfile: visilabsProfile)

        self.visilabsUser = self.unarchive()
        self.visilabsTargetingActionInstance.inAppDelegate = self

        if isIDFAEnabled {
            VisilabsHelper.getIDFA { uuid in
                if let idfa = uuid {
                    self.visilabsUser.identifierForAdvertising = idfa
                }
            }
        }

        if visilabsUser.cookieId.isNilOrWhiteSpace {
            visilabsUser.cookieId = VisilabsHelper.generateCookieId()
            VisilabsPersistence.archiveUser(visilabsUser)
        }

        if self.visilabsProfile.geofenceEnabled {
            self.startGeofencing()
        }

        VisilabsHelper.setEndpoints(dataSource: self.visilabsProfile.dataSource)

        VisilabsHelper.computeWebViewUserAgent { (userAgentString) in
            self.visilabsUser.userAgent = userAgentString
        }

    }

    static func sharedUIApplication() -> UIApplication? {
        let shared = UIApplication.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue()
        guard let sharedApplication = shared as? UIApplication else {
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
            let result = self.visilabsEventInstance.customEvent(pageName: pageName,
                                                                properties: properties,
                                                                eventsQueue: eQueue,
                                                                visilabsUser: vUser,
                                                                channel: chan)
            self.readWriteLock.write {
                self.eventsQueue = result.eventsQueque
                self.visilabsUser = result.visilabsUser
                self.visilabsProfile.channel = result.channel
            }
            self.readWriteLock.read {
                VisilabsPersistence.archiveUser(self.visilabsUser)
                if result.clearUserParameters {
                    VisilabsPersistence.clearTargetParameters()
                }
            }
            if let event = self.eventsQueue.last {
                VisilabsPersistence.saveTargetParameters(event)
                if VisilabsBasePath.endpoints[.action] != nil,
                   self.visilabsProfile.inAppNotificationsEnabled,
                   pageName != VisilabsConstants.omEvtGif {
                    self.checkInAppNotification(properties: event)
                    self.checkTargetingActions(properties: event)
                    //self.checkMailSubsForm(properties: event)
                }
            }
            self.send()
        }
    }
    
    public func sendCampaignParameters(properties: [String: String]) {

        trackingQueue.async { [weak self, properties] in
            guard let strongSelf = self else { return }
            var eQueue = Queue()
            var vUser = VisilabsUser()
            var chan = ""
            strongSelf.readWriteLock.read {
                eQueue = strongSelf.eventsQueue
                vUser = strongSelf.visilabsUser
                chan = strongSelf.visilabsProfile.channel
            }
            let result = strongSelf.visilabsEventInstance.customEvent(properties: properties,
                                                                eventsQueue: eQueue,
                                                                visilabsUser: vUser,
                                                                channel: chan)
            strongSelf.readWriteLock.write {
                strongSelf.eventsQueue = result.eventsQueque
                strongSelf.visilabsUser = result.visilabsUser
                strongSelf.visilabsProfile.channel = result.channel
            }
            strongSelf.readWriteLock.read {
                VisilabsPersistence.archiveUser(strongSelf.visilabsUser)
                if result.clearUserParameters {
                    VisilabsPersistence.clearTargetParameters()
                }
            }
            if let event = strongSelf.eventsQueue.last {
                VisilabsPersistence.saveTargetParameters(event)
            }
            strongSelf.send()
        }
    }

    public func login(exVisitorId: String, properties: [String: String] = [String: String]()) {
        if exVisitorId.isEmptyOrWhitespace {
            VisilabsLogger.error("login can not be called with empty exVisitorId.")
            return
        }
        var props = properties
        props[VisilabsConstants.exvisitorIdKey] = exVisitorId
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
        props[VisilabsConstants.exvisitorIdKey] = exVisitorId
        props["SignUp"] = exVisitorId
        props["OM.b_sgnp"] = "SignUp"
        customEvent("SignUpPage", properties: props)
    }
}

// MARK: - PERSISTENCE

extension VisilabsInstance {

    private func archive() {

    }

    // TO_DO: kontrol et sıra doğru mu? gelen değerler null ise set'lemeli miyim?
    private func unarchive() -> VisilabsUser {
        return VisilabsPersistence.unarchiveUser()
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
                let cookie = self.visilabsSendInstance.sendEventsQueue(eQueue,
                                                                       visilabsUser: vUser,
                                                                       visilabsCookie: vCookie,
                                    timeoutInterval: self.visilabsProfile.requestTimeoutInterval)
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

    public func getFavoriteAttributeActions(actionId: Int? = nil,
                                            completion: @escaping ((_ response: VisilabsFavoriteAttributeActionResponse)
                                                                   -> Void)) {
        self.targetingActionQueue.async { [weak self] in
            self?.networkQueue.async { [weak self] in
                guard let self = self else { return }
                var vUser = VisilabsUser()
                self.readWriteLock.read {
                    vUser = self.visilabsUser
                }
                self.visilabsTargetingActionInstance.getFavorites(visilabsUser: vUser,
                                                                  actionId: actionId,
                                                                  completion: completion)
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
                self.visilabsTargetingActionInstance.checkInAppNotification(properties: properties,
                                                                            visilabsUser: self.visilabsUser,
                                                                            completion: { visilabsInAppNotification in
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
        VisilabsPersistence.archiveUser(visilabsUser)
    }

    func trackNotification(_ notification: VisilabsInAppNotification, event: String, properties: [String: String]) {
        if notification.queryString == nil || notification.queryString == "" {
            VisilabsLogger.info("Notification or query string is nil or empty")
            return
        }
        let queryString = notification.queryString
        let qsArr = queryString!.components(separatedBy: "&")
        var properties = properties
        properties["OM.domain"] =  "\(self.visilabsProfile.dataSource)_IOS"
        properties["OM.zn"] = qsArr[0].components(separatedBy: "=")[1]
        properties["OM.zpc"] = qsArr[1].components(separatedBy: "=")[1]
        customEvent(VisilabsConstants.omEvtGif, properties: properties)
    }
    
    func showTargetingAction(_ model: TargetingActionViewModel) {
        visilabsTargetingActionInstance.notificationsInstance.showTargetingAction(model)
    }
    
    //İleride inapp de s.visilabs.net/mobile üzerinden geldiğinde sadece bu metod kullanılacak
    //checkInAppNotification metodu kaldırılacak.
    func checkTargetingActions(properties: [String: String]) {
        trackingQueue.async { [weak self, properties] in
            guard let self = self else { return }
            self.networkQueue.async { [weak self, properties] in
                guard let self = self else { return }
                self.visilabsTargetingActionInstance.checkTargetingActions(properties: properties, visilabsUser: self.visilabsUser, completion: { (model) in
                    if let targetingAction = model {
                        self.showTargetingAction(targetingAction)
                    }
                })
            }
        }
    }
    
    func subscribeSpinToWinMail(actid: String, auth: String, mail: String) {
        createSubsJsonRequest(actid: actid, auth: auth, mail: mail, type: "spin_to_win_email")
    }
    
    func trackSpinToWinClick(spinToWinReport: SpinToWinReport) {
        var properties = [String: String]()
        properties["OM.domain"] =  "\(self.visilabsProfile.dataSource)_IOS"
        properties["OM.zn"] = spinToWinReport.click.parseClick().omZn
        properties["OM.zpc"] = spinToWinReport.click.parseClick().omZpc
        customEvent(VisilabsConstants.omEvtGif, properties: properties)
    }
    
    
    

}

// MARK: - Story

extension VisilabsInstance {

    public func getStoryView(actionId: Int? = nil, urlDelegate: VisilabsStoryURLDelegate? = nil) -> VisilabsStoryHomeView {
        let guid = UUID().uuidString
        let storyHomeView = VisilabsStoryHomeView()
        let storyHomeViewController = VisilabsStoryHomeViewController()
        storyHomeViewController.urlDelegate = urlDelegate
        storyHomeView.controller = storyHomeViewController
        self.visilabsTargetingActionInstance.visilabsStoryHomeViewControllers[guid] = storyHomeViewController
        self.visilabsTargetingActionInstance.visilabsStoryHomeViews[guid] = storyHomeView
        storyHomeView.setDelegates()
        storyHomeViewController.collectionView = storyHomeView.collectionView

        trackingQueue.async { [weak self, actionId, guid] in
            guard let self = self else { return }
            self.networkQueue.async { [weak self, actionId, guid] in
                guard let self = self else { return }
                self.visilabsTargetingActionInstance.getStories(visilabsUser: self.visilabsUser,
                                                                guid: guid,
                                                                actionId: actionId,
                                                                completion: { response in
                    if let error = response.error {
                        VisilabsLogger.error(error)
                    } else {
                        if let guid = response.guid, response.storyActions.count > 0,
        let storyHomeViewController = self.visilabsTargetingActionInstance.visilabsStoryHomeViewControllers[guid],
                           let storyHomeView = self.visilabsTargetingActionInstance.visilabsStoryHomeViews[guid] {
                            DispatchQueue.main.async {
                                storyHomeViewController.loadStoryAction(response.storyActions.first!)
                                storyHomeView.collectionView.reloadData()
                                storyHomeView.setDelegates()
                                storyHomeViewController.collectionView = storyHomeView.collectionView
                            }
                        }
                    }
                })
            }
        }

        return storyHomeView
    }

}

// MARK: - RECOMMENDATION

extension VisilabsInstance {

    public func recommend(zoneID: String,
                          productCode: String? = nil,
                          filters: [VisilabsRecommendationFilter] = [],
                          properties: [String: String] = [:],
                          completion: @escaping ((_ response: VisilabsRecommendationResponse) -> Void)) {

        self.recommendationQueue.async { [weak self, zoneID, productCode, filters, properties, completion] in
            self?.networkQueue.async { [weak self, zoneID, productCode, filters, properties, completion] in
                guard let self = self else { return }
                var vUser = VisilabsUser()
                var channel = "IOS"
                self.readWriteLock.read {
                    vUser = self.visilabsUser
                    channel = self.visilabsProfile.channel
                }
                self.visilabsRecommendationInstance.recommend(zoneID: zoneID,
                                                              productCode: productCode,
                                                              visilabsUser: vUser,
                                                              channel: channel,
                                                              properties: properties,
                                                              filters: filters) { (response) in
                    completion(response)
                }
            }
        }
    }

}

// MARK: - GEOFENCE

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
    //swiftlint:disable file_length
}

// MARK: - SUBSCRIPTION MAIL

extension VisilabsInstance {
    
    public func subscribeMail(click: String, actid: String, auth: String, mail: String) {
        if click.isEmpty {
            VisilabsLogger.info("Notification or query string is nil or empty")
            return
        }
        
        var properties = [String: String]()
        properties["OM.domain"] =  "\(self.visilabsProfile.dataSource)_IOS"
        properties["OM.zn"] = click.parseClick().omZn
        properties["OM.zpc"] = click.parseClick().omZpc
        customEvent(VisilabsConstants.omEvtGif, properties: properties)
        createSubsJsonRequest(actid: actid, auth: auth, mail: mail)
    }
    
    
    private func createSubsJsonRequest(actid: String, auth: String, mail: String, type: String = "subscription_email") {
        var props = [String: String]()
        props[VisilabsConstants.organizationIdKey] = self.visilabsProfile.organizationId//Om.oid
        props[VisilabsConstants.profileIdKey] = self.visilabsProfile.profileId//Om.siteId
        props[VisilabsConstants.cookieIdKey] = visilabsUser.cookieId
        props[VisilabsConstants.exvisitorIdKey] = visilabsUser.exVisitorId
        props[VisilabsConstants.type] = type
        props["actionid"] = actid
        props[VisilabsConstants.authentication] = auth
        props[VisilabsConstants.subscribedEmail] = mail
        VisilabsRequest.sendSubsJsonRequest(properties: props, headers: [String : String](), timeOutInterval: self.visilabsProfile.requestTimeoutInterval)
    }
}
