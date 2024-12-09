//
//  Visilabs.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.07.2020.
//

import UserNotifications

public class Visilabs {
    public class func callAPI() -> VisilabsInstance {
        if let instance = VisilabsManager.sharedInstance.getInstance() {
            return instance
        } else {
            assert(false, "You have to call createAPI before calling the callAPI.")
            return Visilabs.createAPI(organizationId: "", profileId: "", dataSource: "",geofenceEnabled: false,askLocationPermmissionAtStart: false)
        }
    }

    @discardableResult
    public class func createAPI(organizationId: String,
                                profileId: String,
                                dataSource: String,
                                inAppNotificationsEnabled: Bool = false,
                                channel: String = "IOS",
                                requestTimeoutInSeconds: Int = 30,
                                geofenceEnabled: Bool = false,
                                askLocationPermmissionAtStart: Bool = false,
                                maxGeofenceCount: Int = 20,
                                isIDFAEnabled: Bool = true,
                                loggingEnabled: Bool = false,
                                sdkType: String = "native",
                                isTest:Bool = false) -> VisilabsInstance {


        VisilabsManager.sharedInstance.initialize(organizationId: organizationId,
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
                                                  sdkType: sdkType,
                                                  isTest: isTest)
    }
    
    public class func createAPI() {
        VisilabsManager.sharedInstance.initialize()
    }
    
    public class func initializeCalled() -> Bool {
        return VisilabsManager.initializeCalled
    }
    
    public static func deleteNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func removeNotification(withPushID pushID: String, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        center.getDeliveredNotifications { notifications in
            for notification in notifications {
                if let userInfo = notification.request.content.userInfo as? [String: Any] {
                    if let notificationPushID = userInfo["pushId"] as? String {
                        if notificationPushID == pushID {
                            center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                            completion(true)
                            return
                        }
                    } else {
                        completion(false)
                    }
                }
            }
            completion(false)
        }
    }
    
    public static func getBannerView(properties: [String:String],completion: @escaping (BannerView?) -> Void) {
        VisilabsManager.sharedInstance.getBannerView(properties: properties) { bannerView in
            bannerView?.reloadBannerViewData()
            if let banV = bannerView {
                if let height = banV.model.height {
                    NSLayoutConstraint.activate([bannerView!.heightAnchor.constraint(equalToConstant:CGFloat(height))])
                }
                
                if let width = banV.model.width {
                    NSLayoutConstraint.activate([bannerView!.heightAnchor.constraint(equalToConstant:CGFloat(width))])
                }
                bannerView?.heightRD = banV.model.height
                bannerView?.widthRD = banV.model.width
            }

            completion(bannerView)
        }
    }
    
}
