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

struct VisilabsUser: Codable {
    var cookieId: String?
    var exVisitorId: String?
    var tokenId: String?
    var appId: String?
    var visitData: String?
    var visitorData: String?
    var userAgent: String?
    var identifierForAdvertising: String?
    var sdkVersion: String?
    var lastEventTime: String?
    var nrv = 0
    var pviv = 0
    var tvc = 0
    var lvt: String?
    var appVersion: String?
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
    var organizationId = "676D325830564761676D453D"
    var profileId = "356467332F6533766975593D"
    
    func setTest() {
        urlPrefix = "tests.visilabs.net"
        securityTag = "http"
    }
}

public class RelatedDigitalInstance: CustomDebugStringConvertible {
    var visilabsUser: VisilabsUser!
    var visilabsProfile: VisilabsProfile!
    var visilabsCookie = RelatedDigitalCookie()
    var eventsQueue = Queue()
    var trackingQueue: DispatchQueue!
    var targetingActionQueue: DispatchQueue!
    var recommendationQueue: DispatchQueue!
    var networkQueue: DispatchQueue!
    let readWriteLock: RelatedDigitalReadWriteLock
    private var observers: [NSObjectProtocol]?

    // TO_DO: www.relateddigital.com ı değiştirmeli miyim?
    static let reachability = SCNetworkReachabilityCreateWithName(nil, "www.relateddigital.com")

    let visilabsEventInstance: RelatedDigitalEvent
    let visilabsSendInstance: RelatedDigitalSend
    let visilabsTargetingActionInstance: RelatedDigitalTargetingAction
    let visilabsRecommendationInstance: RelatedDigitalRecommendation
    let visilabsRemoteConfigInstance: RelatedDigitalRemoteConfig

    public var debugDescription: String {
        return "Visilabs(siteId : \(visilabsProfile.profileId)" +
            "organizationId: \(visilabsProfile.organizationId)"
    }

    public var loggingEnabled: Bool = false {
        didSet {
            if loggingEnabled {
                RelatedDigitalLogger.enableLevels([.debug, .info, .warning, .error])
                RelatedDigitalLogger.info("Logging Enabled")
            } else {
                RelatedDigitalLogger.info("Logging Disabled")
                RelatedDigitalLogger.disableLevels([.debug, .info, .warning, .error])
            }
        }
    }

    public var useInsecureProtocol: Bool = false {
        didSet {
            visilabsProfile.useInsecureProtocol = useInsecureProtocol
            RelatedDigitalHelper.setEndpoints(dataSource: visilabsProfile.dataSource,
                                        useInsecureProtocol: useInsecureProtocol)
            RelatedDigitalPersistence.saveVisilabsProfile(visilabsProfile)
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
         maxGeofenceCount: Int,
         isIDFAEnabled: Bool = true,
         loggingEnabled: Bool = false) {
        
        if loggingEnabled {
            RelatedDigitalLogger.enableLevels([.debug, .info, .warning, .error])
            RelatedDigitalLogger.info("Logging Enabled")
        }
        
        // TO_DO: bu reachability doğru çalışıyor mu kontrol et
        if let reachability = RelatedDigitalInstance.reachability {
            var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil,
                                                       release: nil, copyDescription: nil)

            func reachabilityCallback(reachability: SCNetworkReachability,
                                      flags: SCNetworkReachabilityFlags,
                                      unsafePointer: UnsafeMutableRawPointer?) {
                let wifi = flags.contains(SCNetworkReachabilityFlags.reachable)
                    && !flags.contains(SCNetworkReachabilityFlags.isWWAN)
                RelatedDigitalLogger.info("reachability changed, wifi=\(wifi)")
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
                                          inAppNotificationsEnabled: inAppNotificationsEnabled,
                                          maxGeofenceCount: (maxGeofenceCount < 0 && maxGeofenceCount > 20) ? 20 : maxGeofenceCount,
                                          isIDFAEnabled: isIDFAEnabled)
        RelatedDigitalPersistence.saveVisilabsProfile(visilabsProfile)

        readWriteLock = RelatedDigitalReadWriteLock(label: "VisilabsInstanceLock")
        let label = "com.relateddigital.\(visilabsProfile.profileId)"
        trackingQueue = DispatchQueue(label: "\(label).tracking)", qos: .utility)
        recommendationQueue = DispatchQueue(label: "\(label).recommendation)", qos: .utility)
        targetingActionQueue = DispatchQueue(label: "\(label).targetingaction)", qos: .utility)
        networkQueue = DispatchQueue(label: "\(label).network)", qos: .utility)
        visilabsEventInstance = RelatedDigitalEvent(visilabsProfile: visilabsProfile)
        visilabsSendInstance = RelatedDigitalSend()
        visilabsTargetingActionInstance = RelatedDigitalTargetingAction(lock: readWriteLock,
                                                                  visilabsProfile: visilabsProfile)
        visilabsRecommendationInstance = RelatedDigitalRecommendation(visilabsProfile: visilabsProfile)
        visilabsRemoteConfigInstance = RelatedDigitalRemoteConfig(profileId: visilabsProfile.profileId)
        visilabsUser = unarchive()
        visilabsTargetingActionInstance.inAppDelegate = self

        visilabsUser.sdkVersion = RelatedDigitalHelper.getSdkVersion()
        
        if let appVersion = RelatedDigitalHelper.getAppVersion() {
            visilabsUser.appVersion = appVersion
        }
        
        if isIDFAEnabled {
            RelatedDigitalHelper.getIDFA { uuid in
                if let idfa = uuid {
                    self.visilabsUser.identifierForAdvertising = idfa
                }
            }
        }
        
        if visilabsUser.cookieId.isNilOrWhiteSpace {
            visilabsUser.cookieId = RelatedDigitalHelper.generateCookieId()
            RelatedDigitalPersistence.archiveUser(visilabsUser)
        }

        if visilabsProfile.geofenceEnabled {
            startGeofencing()
        }

        RelatedDigitalHelper.setEndpoints(dataSource: visilabsProfile.dataSource)

        RelatedDigitalHelper.computeWebViewUserAgent { userAgentString in
            self.visilabsUser.userAgent = userAgentString
        }
        
        let ncd = NotificationCenter.default
        observers = []
        
        if !RelatedDigitalHelper.isiOSAppExtension() {
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
        if let visilabsProfile = RelatedDigitalPersistence.readVisilabsProfile() {
            self.init(organizationId: visilabsProfile.organizationId,
                      profileId: visilabsProfile.profileId,
                      dataSource: visilabsProfile.dataSource,
                      inAppNotificationsEnabled: visilabsProfile.inAppNotificationsEnabled,
                      channel: visilabsProfile.channel,
                      requestTimeoutInSeconds: visilabsProfile.requestTimeoutInSeconds,
                      geofenceEnabled: visilabsProfile.geofenceEnabled,
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

extension RelatedDigitalInstance {
    
    public func requestIDFA() {
        
        if RelatedDigitalPersistence.isBlocked() {
            RelatedDigitalLogger.warn("Too much server load, ignoring the request!")
            return
        }
        
        RelatedDigitalHelper.getIDFA { uuid in
            if let idfa = uuid {
                self.visilabsUser.identifierForAdvertising = idfa
                self.customEvent(RelatedDigitalConstants.omEvtGif, properties: [String: String]())
            }
        }
    }
    
}

// MARK: - EVENT

extension RelatedDigitalInstance {
    
    private func checkPushPermission() {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { permission in
                switch permission.authorizationStatus {
                case .authorized:
                    RelatedDigitalConstants.pushPermitStatus = "granted"
                case .denied:
                    RelatedDigitalConstants.pushPermitStatus = "denied"
                case .notDetermined:
                    RelatedDigitalConstants.pushPermitStatus = "denied"
                case .provisional:
                    RelatedDigitalConstants.pushPermitStatus = "default"
                case .ephemeral:
                    RelatedDigitalConstants.pushPermitStatus = "denied"
                @unknown default:
                    RelatedDigitalConstants.pushPermitStatus = "denied"
                }
            })
        }
    
    private func sideBarTest(imageData:UIImage) {

        let model = SideBarModel()
        model.dataImage = imageData
        let sideBar = RelatedDigitalSideBarViewController(model:model)
        sideBar.show(animated: true)

    }
    
    public func customEvent(_ pageName: String, properties: [String: String]) {
        
        if RelatedDigitalPersistence.isBlocked() {
            RelatedDigitalLogger.warn("Too much server load, ignoring the request!")
            return
        }

        if pageName.isEmptyOrWhitespace {
            RelatedDigitalLogger.error("customEvent can not be called with empty page name.")
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
                RelatedDigitalPersistence.archiveUser(self.visilabsUser)
                if result.clearUserParameters {
                    RelatedDigitalPersistence.clearTargetParameters()
                }
            }
            if let event = self.eventsQueue.last {
                RelatedDigitalPersistence.saveTargetParameters(event)
                if VisilabsBasePath.endpoints[.action] != nil,
                   self.visilabsProfile.inAppNotificationsEnabled,
                   pageName != RelatedDigitalConstants.omEvtGif {
                    self.checkInAppNotification(properties: event)
                    self.checkTargetingActions(properties: event)
                }
            }
            self.send()
        }
    }

    public func sendCampaignParameters(properties: [String: String]) {
        
        if RelatedDigitalPersistence.isBlocked() {
            RelatedDigitalLogger.warn("Too much server load, ignoring the request!")
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
                RelatedDigitalPersistence.archiveUser(strongSelf.visilabsUser)
                if result.clearUserParameters {
                    RelatedDigitalPersistence.clearTargetParameters()
                }
            }
            if let event = strongSelf.eventsQueue.last {
                RelatedDigitalPersistence.saveTargetParameters(event)
            }
            strongSelf.send()
        }
    }

    public func login(exVisitorId: String, properties: [String: String] = [String: String]()) {
        
        if RelatedDigitalPersistence.isBlocked() {
            RelatedDigitalLogger.warn("Too much server load, ignoring the request!")
            return
        }
        
        if exVisitorId.isEmptyOrWhitespace {
            RelatedDigitalLogger.error("login can not be called with empty exVisitorId.")
            return
        }
        var props = properties
        props[RelatedDigitalConstants.exvisitorIdKey] = exVisitorId
        props["Login"] = exVisitorId
        props["OM.b_login"] = "Login"
        customEvent("LoginPage", properties: props)
    }

    public func signUp(exVisitorId: String, properties: [String: String] = [String: String]()) {
        
        if RelatedDigitalPersistence.isBlocked() {
            RelatedDigitalLogger.warn("Too much server load, ignoring the request!")
            return
        }
        
        if exVisitorId.isEmptyOrWhitespace {
            RelatedDigitalLogger.error("signUp can not be called with empty exVisitorId.")
            return
        }
        var props = properties
        props[RelatedDigitalConstants.exvisitorIdKey] = exVisitorId
        props["SignUp"] = exVisitorId
        props["OM.b_sgnp"] = "SignUp"
        customEvent("SignUpPage", properties: props)
    }

    public func getExVisitorId() -> String? {
        return visilabsUser.exVisitorId
    }

    public func logout() {
        RelatedDigitalPersistence.clearUserDefaults()
        visilabsUser.cookieId = nil
        visilabsUser.exVisitorId = nil
        visilabsUser.cookieId = RelatedDigitalHelper.generateCookieId()
        RelatedDigitalPersistence.archiveUser(visilabsUser)
    }
    
}

// MARK: - PERSISTENCE

extension RelatedDigitalInstance {
    private func archive() {
    }

    // TO_DO: kontrol et sıra doğru mu? gelen değerler null ise set'lemeli miyim?
    private func unarchive() -> VisilabsUser {
        return RelatedDigitalPersistence.unarchiveUser()
    }
}

// MARK: - SEND

extension RelatedDigitalInstance {
    private func send() {
        trackingQueue.async { [weak self] in
            self?.networkQueue.async { [weak self] in
                guard let self = self else { return }
                var eQueue = Queue()
                var vUser = VisilabsUser()
                var vCookie = RelatedDigitalCookie()
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

extension RelatedDigitalInstance {
    public func getFavoriteAttributeActions(actionId: Int? = nil,
                                            completion: @escaping ((_ response: RelatedDigitalFavoriteAttributeActionResponse)
                                                -> Void)) {
        
        if RelatedDigitalPersistence.isBlocked() {
            RelatedDigitalLogger.warn("Too much server load, ignoring the request!")
            completion(RelatedDigitalFavoriteAttributeActionResponse(favorites: [RelatedDigitalFavoriteAttribute: [String]](), error: .noData))
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

extension RelatedDigitalInstance: RelatedDigitalInAppNotificationsDelegate {
    // This method added for test purposes
    public func showNotification(_ visilabsInAppNotification: RelatedDigitalInAppNotification) {
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

    func notificationDidShow(_ notification: RelatedDigitalInAppNotification) {
        visilabsUser.visitData = notification.visitData
        visilabsUser.visitorData = notification.visitorData
        RelatedDigitalPersistence.archiveUser(visilabsUser)
    }

    func trackNotification(_ notification: RelatedDigitalInAppNotification, event: String, properties: [String: String]) {
        if notification.queryString == nil || notification.queryString == "" {
            RelatedDigitalLogger.info("Notification or query string is nil or empty")
            return
        }
        let queryString = notification.queryString
        let qsArr = queryString!.components(separatedBy: "&")
        var properties = properties
        properties[RelatedDigitalConstants.domainkey] = "\(visilabsProfile.dataSource)_IOS"
        properties["OM.zn"] = qsArr[0].components(separatedBy: "=")[1]
        properties["OM.zpc"] = qsArr[1].components(separatedBy: "=")[1]
        customEvent(RelatedDigitalConstants.omEvtGif, properties: properties)
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
        properties[RelatedDigitalConstants.domainkey] = "\(visilabsProfile.dataSource)_IOS"
        properties["OM.zn"] = spinToWinReport.click.parseClick().omZn
        properties["OM.zpc"] = spinToWinReport.click.parseClick().omZpc
        customEvent(RelatedDigitalConstants.omEvtGif, properties: properties)
    }
}

// MARK: - Story

extension RelatedDigitalInstance {
    
    public func getStoryViewAsync(actionId: Int? = nil, urlDelegate: VisilabsStoryURLDelegate? = nil
                                  , completion: @escaping ((_ storyHomeView: RelatedDigitalStoryHomeView?) -> Void)) {
        
        if RelatedDigitalPersistence.isBlocked() {
            RelatedDigitalLogger.warn("Too much server load, ignoring the request!")
            completion(nil)
            return
        }
        
        let guid = UUID().uuidString
        let storyHomeView = RelatedDigitalStoryHomeView()
        let storyHomeViewController = RelatedDigitalStoryHomeViewController()
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
                        RelatedDigitalLogger.error(error)
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
    
    public func getStoryView(actionId: Int? = nil, urlDelegate: VisilabsStoryURLDelegate? = nil) -> RelatedDigitalStoryHomeView {
        
        if RelatedDigitalPersistence.isBlocked() {
            RelatedDigitalLogger.warn("Too much server load, ignoring the request!")
            return RelatedDigitalStoryHomeView()
        }
        
        let guid = UUID().uuidString
        let storyHomeView = RelatedDigitalStoryHomeView()
        let storyHomeViewController = RelatedDigitalStoryHomeViewController()
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
                                                                        RelatedDigitalLogger.error(error)
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

extension RelatedDigitalInstance {
    public func recommend(zoneID: String,
                          productCode: String? = nil,
                          filters: [VisilabsRecommendationFilter] = [],
                          properties: [String: String] = [:],
                          completion: @escaping ((_ response: VisilabsRecommendationResponse) -> Void)) {
        
        if RelatedDigitalPersistence.isBlocked() {
            RelatedDigitalLogger.warn("Too much server load, ignoring the request!")
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
        
        if RelatedDigitalPersistence.isBlocked() {
            RelatedDigitalLogger.warn("Too much server load, ignoring the request!")
        }
        
        let qsArr = qs.components(separatedBy: "&")
        var properties = [String: String]()
        properties[RelatedDigitalConstants.domainkey] = "\(visilabsProfile.dataSource)_IOS"
        if(qsArr.count > 1) {
            for queryItem in qsArr {
                let arrComponents = queryItem.components(separatedBy: "=")
                if arrComponents.count == 2 {
                    properties[arrComponents[0]] = arrComponents[1]
                }
            }
        } else {
            RelatedDigitalLogger.info("qs length is less than 2")
            return
        }
        customEvent(RelatedDigitalConstants.omEvtGif, properties: properties)
    }
    
}

// MARK: - GEOFENCE

extension RelatedDigitalInstance {
    private func startGeofencing() {
        RelatedDigitalGeofence.sharedManager?.startGeofencing()
    }

    public var locationServicesEnabledForDevice: Bool {
        return RelatedDigitalGeofence.sharedManager?.locationServicesEnabledForDevice ?? false
    }

    public var locationServiceStateStatusForApplication: RelatedDigitalCLAuthorizationStatus {
        return RelatedDigitalGeofence.sharedManager?.locationServiceStateStatusForApplication ?? .none
    }
    
    public func sendLocationPermission() {
        RelatedDigitalLocationManager.sharedManager.sendLocationPermission(geofenceEnabled: visilabsProfile.geofenceEnabled)
    }

    // swiftlint:disable file_length
}

// MARK: - SUBSCRIPTION MAIL

extension RelatedDigitalInstance {
    public func subscribeMail(click: String, actid: String, auth: String, mail: String) {
        if click.isEmpty {
            RelatedDigitalLogger.info("Notification or query string is nil or empty")
            return
        }

        var properties = [String: String]()
        properties[RelatedDigitalConstants.domainkey] = "\(visilabsProfile.dataSource)_IOS"
        properties["OM.zn"] = click.parseClick().omZn
        properties["OM.zpc"] = click.parseClick().omZpc
        customEvent(RelatedDigitalConstants.omEvtGif, properties: properties)
        createSubsJsonRequest(actid: actid, auth: auth, mail: mail)
    }

    private func createSubsJsonRequest(actid: String, auth: String, mail: String, type: String = "subscription_email") {
        var props = [String: String]()
        props[RelatedDigitalConstants.type] = type
        props["actionid"] = actid
        props[RelatedDigitalConstants.authentication] = auth
        props[RelatedDigitalConstants.subscribedEmail] = mail
        RelatedDigitalRequest.sendSubsJsonRequest(properties: props)
    }
}

// MARK: -REMOTE CONFIG


extension RelatedDigitalInstance {

    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        visilabsRemoteConfigInstance.applicationDidBecomeActive()
    }
    
    @objc private func applicationWillResignActive(_ notification: Notification) {
        visilabsRemoteConfigInstance.applicationWillResignActive()
    }
}



public protocol VisilabsInappButtonDelegate: AnyObject {
    func didTapButton(_ notification: RelatedDigitalInAppNotification)
}
