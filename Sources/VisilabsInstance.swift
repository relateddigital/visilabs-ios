//
//  VisilabsInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 4.05.2020.
//

import class Foundation.Bundle
import SystemConfiguration
import UIKit
import UserNotifications


typealias Queue = [[String: String]]

public struct VisilabsUser: Codable {
    public var cookieId: String?
    public var exVisitorId: String?
    public var tokenId: String?
    public var appId: String?
    public var visitData: String?
    public var visitorData: String?
    public var userAgent: String?
    public var identifierForAdvertising: String?
    public var sdkVersion: String?
    public var lastEventTime: String?
    public var nrv = 0
    public var pviv = 0
    public var tvc = 0
    public var lvt: String?
    public var appVersion: String?
}

struct VisilabsProfile: Codable {
    var organizationId: String
    var profileId: String
    var dataSource: String
    var channel: String
    var requestTimeoutInSeconds: Int
    var geofenceEnabled: Bool
    var askLocationPermmissionAtStart: Bool
    var inAppNotificationsEnabled: Bool
    var maxGeofenceCount: Int
    var isIDFAEnabled: Bool
    var requestTimeoutInterval: TimeInterval {
        return TimeInterval(requestTimeoutInSeconds)
    }

    var useInsecureProtocol = false
}

class urlConstant {
    static var shared = urlConstant()
    var urlPrefix = "s.visilabs.net"
    var securityTag = "https"    
    func setTest() {
        urlPrefix = "tests.visilabs.net"
        securityTag = "http"
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
    private var observers: [NSObjectProtocol]?

    // TO_DO: www.relateddigital.com ı değiştirmeli miyim?
    static let reachability = SCNetworkReachabilityCreateWithName(nil, "www.relateddigital.com")

    let visilabsEventInstance: VisilabsEvent
    let visilabsSendInstance: VisilabsSend
    let visilabsTargetingActionInstance: VisilabsTargetingAction
    let visilabsRecommendationInstance: VisilabsRecommendation
    let visilabsRemoteConfigInstance: VisilabsRemoteConfig
    let visilabsLocationManager: VisilabsLocationManager

    public var debugDescription: String {
        return "Visilabs(siteId : \(visilabsProfile.profileId)" +
            "organizationId: \(visilabsProfile.organizationId)"
    }

    public var loggingEnabled: Bool = false {
        didSet {
            if loggingEnabled {
                VisilabsLogger.enableLevels([.debug, .info, .warning, .error])
                VisilabsLogger.info("Logging Enabled")
            } else {
                VisilabsLogger.info("Logging Disabled")
                VisilabsLogger.disableLevels([.debug, .info, .warning, .error])
            }
        }
    }

    public var useInsecureProtocol: Bool = false {
        didSet {
            visilabsProfile.useInsecureProtocol = useInsecureProtocol
            VisilabsHelper.setEndpoints(dataSource: visilabsProfile.dataSource,
                                        useInsecureProtocol: useInsecureProtocol)
            VisilabsPersistence.saveVisilabsProfile(visilabsProfile)
        }
    }

    public weak var inappButtonDelegate: VisilabsInappButtonDelegate?

    // swiftlint:disable function_body_length
    init(organizationId: String,
         profileId: String,
         dataSource: String,
         inAppNotificationsEnabled: Bool,
         channel: String,
         requestTimeoutInSeconds: Int,
         geofenceEnabled: Bool,
         askLocationPermmissionAtStart: Bool,
         maxGeofenceCount: Int,
         isIDFAEnabled: Bool = true,
         loggingEnabled: Bool = false) {
        
        if loggingEnabled {
            VisilabsLogger.enableLevels([.debug, .info, .warning, .error])
            VisilabsLogger.info("Logging Enabled")
        }
        
        // TO_DO: bu reachability doğru çalışıyor mu kontrol et
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

        visilabsProfile = VisilabsProfile(organizationId: organizationId,
                                          profileId: profileId,
                                          dataSource: dataSource,
                                          channel: channel,
                                          requestTimeoutInSeconds: requestTimeoutInSeconds,
                                          geofenceEnabled: geofenceEnabled,
                                          askLocationPermmissionAtStart: askLocationPermmissionAtStart,
                                          inAppNotificationsEnabled: inAppNotificationsEnabled,
                                          maxGeofenceCount: (maxGeofenceCount < 0 && maxGeofenceCount > 20) ? 20 : maxGeofenceCount,
                                          isIDFAEnabled: isIDFAEnabled)
        VisilabsPersistence.saveVisilabsProfile(visilabsProfile)

        readWriteLock = VisilabsReadWriteLock(label: "VisilabsInstanceLock")
        let label = "com.relateddigital.\(visilabsProfile.profileId)"
        trackingQueue = DispatchQueue(label: "\(label).tracking)", qos: .utility)
        recommendationQueue = DispatchQueue(label: "\(label).recommendation)", qos: .utility)
        targetingActionQueue = DispatchQueue(label: "\(label).targetingaction)", qos: .utility)
        networkQueue = DispatchQueue(label: "\(label).network)", qos: .utility)
        visilabsEventInstance = VisilabsEvent(visilabsProfile: visilabsProfile)
        visilabsSendInstance = VisilabsSend()
        visilabsTargetingActionInstance = VisilabsTargetingAction(lock: readWriteLock,
                                                                  visilabsProfile: visilabsProfile)
        visilabsRecommendationInstance = VisilabsRecommendation(visilabsProfile: visilabsProfile)
        visilabsRemoteConfigInstance = VisilabsRemoteConfig(profileId: visilabsProfile.profileId)
        visilabsLocationManager = VisilabsLocationManager()
        visilabsUser = unarchive()
        visilabsTargetingActionInstance.inAppDelegate = self
        visilabsUser.sdkVersion = VisilabsHelper.getSdkVersion()
        
        if let appVersion = VisilabsHelper.getAppVersion() {
            visilabsUser.appVersion = appVersion
        }
        
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

        VisilabsHelper.setEndpoints(dataSource: visilabsProfile.dataSource)

        VisilabsHelper.computeWebViewUserAgent { userAgentString in
            self.visilabsUser.userAgent = userAgentString
        }
        
        let ncd = NotificationCenter.default
        observers = []
        
        if !VisilabsHelper.isiOSAppExtension() {
            observers?.append(ncd.addObserver(
                                forName: UIApplication.didBecomeActiveNotification,
                                object: nil,
                                queue: nil,
                                using: self.applicationDidBecomeActive(_:)))
            observers?.append(ncd.addObserver(
                                forName: UIApplication.willResignActiveNotification,
                                object: nil,
                                queue: nil,
                                using: self.applicationWillResignActive(_:)))
        }
    }

    convenience init?() {
        if let visilabsProfile = VisilabsPersistence.readVisilabsProfile() {
            self.init(organizationId: visilabsProfile.organizationId,
                      profileId: visilabsProfile.profileId,
                      dataSource: visilabsProfile.dataSource,
                      inAppNotificationsEnabled: visilabsProfile.inAppNotificationsEnabled,
                      channel: visilabsProfile.channel,
                      requestTimeoutInSeconds: visilabsProfile.requestTimeoutInSeconds,
                      geofenceEnabled: visilabsProfile.geofenceEnabled,
                      askLocationPermmissionAtStart: visilabsProfile.askLocationPermmissionAtStart,
                      maxGeofenceCount: visilabsProfile.maxGeofenceCount,
                      isIDFAEnabled: visilabsProfile.isIDFAEnabled)
        } else {
            return nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willResignActiveNotification,
                                                  object: nil)
    }

    static func sharedUIApplication() -> UIApplication? {
        let shared = UIApplication.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue()
        guard let sharedApplication = shared as? UIApplication else {
            return nil
        }
        return sharedApplication
    }
}

// MARK: - IDFA

extension VisilabsInstance {
    
    public func requestIDFA() {
        
        if VisilabsPersistence.isBlocked() {
            VisilabsLogger.warn("Too much server load, ignoring the request!")
            return
        }
        
        VisilabsHelper.getIDFA { uuid in
            if let idfa = uuid {
                self.visilabsUser.identifierForAdvertising = idfa
                self.customEvent(VisilabsConstants.omEvtGif, properties: [String: String]())
            }
        }
    }
    
}

// MARK: - EVENT

extension VisilabsInstance {
    
    private func checkPushPermission() {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { permission in
                switch permission.authorizationStatus {
                case .authorized:
                    VisilabsConstants.pushPermitStatus = "granted"
                case .denied:
                    VisilabsConstants.pushPermitStatus = "denied"
                case .notDetermined:
                    VisilabsConstants.pushPermitStatus = "denied"
                case .provisional:
                    VisilabsConstants.pushPermitStatus = "default"
                case .ephemeral:
                    VisilabsConstants.pushPermitStatus = "denied"
                @unknown default:
                    VisilabsConstants.pushPermitStatus = "denied"
                }
            })
        }
    
    
    public func customEvent(_ pageName: String, properties: [String: String]) {
        
        if VisilabsPersistence.isBlocked() {
            VisilabsLogger.warn("Too much server load, ignoring the request!")
            return
        }

        if pageName.isEmptyOrWhitespace {
            VisilabsLogger.error("customEvent can not be called with empty page name.")
            return
        }
        
        checkPushPermission()
        
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
                }
            }
            self.send()
        }
    }

    public func sendCampaignParameters(properties: [String: String]) {
        
        if VisilabsPersistence.isBlocked() {
            VisilabsLogger.warn("Too much server load, ignoring the request!")
            return
        }

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
        
        if VisilabsPersistence.isBlocked() {
            VisilabsLogger.warn("Too much server load, ignoring the request!")
            return
        }
        
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
        
        if VisilabsPersistence.isBlocked() {
            VisilabsLogger.warn("Too much server load, ignoring the request!")
            return
        }
        
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

    public func getExVisitorId() -> String? {
        return visilabsUser.exVisitorId
    }
    
    public func getUser() -> VisilabsUser {
        return visilabsUser
    }

    public func logout() {
        VisilabsPersistence.clearUserDefaults()
        visilabsUser.cookieId = nil
        visilabsUser.exVisitorId = nil
        visilabsUser.cookieId = VisilabsHelper.generateCookieId()
        VisilabsPersistence.archiveUser(visilabsUser)
    }
    
}

// MARK: - PERSISTENCE

extension VisilabsInstance {
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
        
        if VisilabsPersistence.isBlocked() {
            VisilabsLogger.warn("Too much server load, ignoring the request!")
            completion(VisilabsFavoriteAttributeActionResponse(favorites: [VisilabsFavoriteAttribute: [String]](), error: .noData))
            return
        }
        
        targetingActionQueue.async { [weak self] in
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

    public func showTargetingAction(_ model: TargetingActionViewModel) {
        visilabsTargetingActionInstance.notificationsInstance.showTargetingAction(model)
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
                                                                                    self.visilabsTargetingActionInstance.notificationsInstance.inappButtonDelegate = self.inappButtonDelegate
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
        properties[VisilabsConstants.domainkey] = "\(visilabsProfile.dataSource)_IOS"
        properties["OM.zn"] = qsArr[0].components(separatedBy: "=")[1]
        properties["OM.zpc"] = qsArr[1].components(separatedBy: "=")[1]
        customEvent(VisilabsConstants.omEvtGif, properties: properties)
    }

    // İleride inapp de s.visilabs.net/mobile üzerinden geldiğinde sadece bu metod kullanılacak
    // checkInAppNotification metodu kaldırılacak.
    func checkTargetingActions(properties: [String: String]) {
        trackingQueue.async { [weak self, properties] in
            guard let self = self else { return }
            self.networkQueue.async { [weak self, properties] in
                guard let self = self else { return }
                self.visilabsTargetingActionInstance.checkTargetingActions(properties: properties, visilabsUser: self.visilabsUser, completion: { model in
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
        properties[VisilabsConstants.domainkey] = "\(visilabsProfile.dataSource)_IOS"
        properties["OM.zn"] = spinToWinReport.click.parseClick().omZn
        properties["OM.zpc"] = spinToWinReport.click.parseClick().omZpc
        customEvent(VisilabsConstants.omEvtGif, properties: properties)
    }
}

// MARK: - Story

extension VisilabsInstance {
    
    public func getStoryViewAsync(actionId: Int? = nil, urlDelegate: VisilabsStoryURLDelegate? = nil
                                  , completion: @escaping ((_ storyHomeView: VisilabsStoryHomeView?) -> Void)) {
        
        if VisilabsPersistence.isBlocked() {
            VisilabsLogger.warn("Too much server load, ignoring the request!")
            completion(nil)
            return
        }
        
        let guid = UUID().uuidString
        let storyHomeView = VisilabsStoryHomeView()
        let storyHomeViewController = VisilabsStoryHomeViewController()
        storyHomeViewController.urlDelegate = urlDelegate
        storyHomeView.controller = storyHomeViewController
        visilabsTargetingActionInstance.visilabsStoryHomeViewControllers[guid] = storyHomeViewController
        visilabsTargetingActionInstance.visilabsStoryHomeViews[guid] = storyHomeView
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
                        completion(nil)
                    } else {
                        if let guid = response.guid, response.storyActions.count > 0,
                           let storyHomeViewController = self.visilabsTargetingActionInstance.visilabsStoryHomeViewControllers[guid],
                           let storyHomeView = self.visilabsTargetingActionInstance.visilabsStoryHomeViews[guid] {
                            DispatchQueue.main.async {
                                storyHomeViewController.loadStoryAction(response.storyActions.first!)
                                storyHomeView.collectionView.reloadData()
                                storyHomeView.setDelegates()
                                storyHomeViewController.collectionView = storyHomeView.collectionView
                                completion(storyHomeView)
                            }
                        } else {
                            completion(nil)
                        }
                    }
                })
            }
        }
    }
    
    public func getStoryView(actionId: Int? = nil, urlDelegate: VisilabsStoryURLDelegate? = nil) -> VisilabsStoryHomeView {
        
        if VisilabsPersistence.isBlocked() {
            VisilabsLogger.warn("Too much server load, ignoring the request!")
            return VisilabsStoryHomeView()
        }
        
        let guid = UUID().uuidString
        let storyHomeView = VisilabsStoryHomeView()
        let storyHomeViewController = VisilabsStoryHomeViewController()
        storyHomeViewController.urlDelegate = urlDelegate
        storyHomeView.controller = storyHomeViewController
        visilabsTargetingActionInstance.visilabsStoryHomeViewControllers[guid] = storyHomeViewController
        visilabsTargetingActionInstance.visilabsStoryHomeViews[guid] = storyHomeView
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
        
        if VisilabsPersistence.isBlocked() {
            VisilabsLogger.warn("Too much server load, ignoring the request!")
        }
        
        
        recommendationQueue.async { [weak self, zoneID, productCode, filters, properties, completion] in
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
                                                              filters: filters) { response in
                    completion(response)
                }
            }
        }
    }
    
    public func trackRecommendationClick(qs: String) {
        
        if VisilabsPersistence.isBlocked() {
            VisilabsLogger.warn("Too much server load, ignoring the request!")
        }
        
        let qsArr = qs.components(separatedBy: "&")
        var properties = [String: String]()
        properties[VisilabsConstants.domainkey] = "\(visilabsProfile.dataSource)_IOS"
        if(qsArr.count > 1) {
            for queryItem in qsArr {
                let arrComponents = queryItem.components(separatedBy: "=")
                if arrComponents.count == 2 {
                    properties[arrComponents[0]] = arrComponents[1]
                }
            }
        } else {
            VisilabsLogger.info("qs length is less than 2")
            return
        }
        customEvent(VisilabsConstants.omEvtGif, properties: properties)
    }
    
}

// MARK: - GEOFENCE

extension VisilabsInstance {

    public var locationServicesEnabledForDevice: Bool {
        return VisilabsGeofenceState.locationServicesEnabledForDevice
    }

    public var locationServiceStateStatusForApplication: VisilabsCLAuthorizationStatus {
        return VisilabsGeofenceState.locationServiceStateStatusForApplication
    }
    
    public func sendLocationPermission() {
        visilabsLocationManager.sendLocationPermission(geofenceEnabled: visilabsProfile.geofenceEnabled)
    }
    
    public func requestLocationPermissions() {
        visilabsLocationManager.requestLocationPermissions()
    }

}

// MARK: - SUBSCRIPTION MAIL

extension VisilabsInstance {
    public func subscribeMail(click: String, actid: String, auth: String, mail: String) {
        if click.isEmpty {
            VisilabsLogger.info("Notification or query string is nil or empty")
            return
        }

        var properties = [String: String]()
        properties[VisilabsConstants.domainkey] = "\(visilabsProfile.dataSource)_IOS"
        properties["OM.zn"] = click.parseClick().omZn
        properties["OM.zpc"] = click.parseClick().omZpc
        customEvent(VisilabsConstants.omEvtGif, properties: properties)
        createSubsJsonRequest(actid: actid, auth: auth, mail: mail)
    }

    private func createSubsJsonRequest(actid: String, auth: String, mail: String, type: String = "subscription_email") {
        var props = [String: String]()
        props[VisilabsConstants.type] = type
        props["actionid"] = actid
        props[VisilabsConstants.authentication] = auth
        props[VisilabsConstants.subscribedEmail] = mail
        VisilabsRequest.sendSubsJsonRequest(properties: props)
    }
}

// MARK: -REMOTE CONFIG

extension VisilabsInstance {

    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        visilabsRemoteConfigInstance.applicationDidBecomeActive()
    }
    
    @objc private func applicationWillResignActive(_ notification: Notification) {
        visilabsRemoteConfigInstance.applicationWillResignActive()
    }
}

public protocol VisilabsInappButtonDelegate: AnyObject {
    func didTapButton(_ notification: VisilabsInAppNotification)
}
