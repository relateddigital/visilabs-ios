//
//  VisilabsManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.07.2020.
//
import Foundation

class VisilabsManager {
    
    static var initializeCalled = false;
    static let sharedInstance = VisilabsManager()
    private var instance: VisilabsInstance?
    
    init() {
        VisilabsLogger.addLogging(VisilabsPrintLogging())
    }
    // swiftlint:disable function_parameter_count
    func initialize(organizationId: String,
                    profileId: String,
                    dataSource: String,
                    inAppNotificationsEnabled: Bool,
                    channel: String,
                    requestTimeoutInSeconds: Int,
                    geofenceEnabled: Bool,
                    askLocationPermmissionAtStart: Bool,
                    maxGeofenceCount: Int,
                    isIDFAEnabled: Bool,
                    loggingEnabled: Bool,
                    sdkType: String,
                    isTest: Bool) -> VisilabsInstance {
        VisilabsManager.initializeCalled = true
        setTest(test: isTest)
        let instance = VisilabsInstance(organizationId: organizationId,
                                        profileId: profileId,
                                        dataSource: dataSource,
                                        inAppNotificationsEnabled: inAppNotificationsEnabled,
                                        channel: channel,
                                        requestTimeoutInSeconds: requestTimeoutInSeconds,
                                        geofenceEnabled: geofenceEnabled,
                                        askLocationPermmissionAtStart: askLocationPermmissionAtStart,
                                        maxGeofenceCount: maxGeofenceCount,
                                        isIDFAEnabled: isIDFAEnabled,
                                        loggingEnabled: loggingEnabled,
                                        sdkType: sdkType)
        self.instance = instance
        return instance
    }
    
    func setTest(test:Bool) {
        if test {
            urlConstant.shared.setTest()
        }
    }
    
    func initialize() {
        VisilabsManager.initializeCalled = true
        if let instance = VisilabsInstance() {
            self.instance = instance
        }
    }
    
    func getInstance() -> VisilabsInstance? {
        return instance
    }
    
    func getBannerView(properties:[String:String], completion: @escaping ((BannerView?) -> Void)) {
        let guid = UUID().uuidString
        
        var props = properties
        props[VisilabsConstants.organizationIdKey] = instance?.visilabsProfile.organizationId
        props[VisilabsConstants.profileIdKey] = instance?.visilabsProfile.profileId
        props[VisilabsConstants.cookieIdKey] = instance?.visilabsUser.cookieId
        props[VisilabsConstants.exvisitorIdKey] = instance?.visilabsUser.exVisitorId
        props[VisilabsConstants.tokenIdKey] = instance?.visilabsUser.tokenId
        props[VisilabsConstants.appidKey] = instance?.visilabsUser.appId
        props[VisilabsConstants.apiverKey] = instance?.visilabsProfile.apiver
        props[VisilabsConstants.actionType] = VisilabsConstants.appBanner
        props[VisilabsConstants.channelKey] = instance?.visilabsProfile.channel
        props[VisilabsConstants.sdkTypeKey] = instance?.visilabsProfile.sdkType
        
        props[VisilabsConstants.nrvKey] = String(instance?.visilabsUser.nrv ?? 0)
        props[VisilabsConstants.pvivKey] = String(instance?.visilabsUser.pviv ?? 0)
        props[VisilabsConstants.tvcKey] = String(instance?.visilabsUser.tvc ?? 0)
        props[VisilabsConstants.lvtKey] = instance?.visilabsUser.lvt
        
        for (key, value) in VisilabsPersistence.readTargetParameters() {
            if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
                props[key] = value
            }
        }
        
        self.instance?.visilabsTargetingActionInstance.getAppBanner(properties: props , rdUser: (self.instance?.visilabsUser)!, guid: guid) { response in
            
            if response.error != nil {
                completion(nil)
            } else {
                DispatchQueue.main.async {
                    let bannerView : BannerView = .fromNib()
                    bannerView.model = response
                    bannerView.propertiesLocal = props
                    completion(bannerView)
                }
            }
            
        }
    }
}
