//
//  VisilabsTargetingAction.swift
//  VisilabsIOS
//
//  Created by Egemen on 18.08.2020.
//

import Foundation

class VisilabsTargetingAction {
    
    
    let visilabsProfile: VisilabsProfile
    
    required init(lock: VisilabsReadWriteLock, visilabsProfile: VisilabsProfile) {
        self.notificationsInstance = VisilabsInAppNotifications(lock: lock)
        self.visilabsProfile = visilabsProfile
    }
    
    // MARK: - InApp Notifications
    
    var notificationsInstance: VisilabsInAppNotifications
    
    var inAppDelegate: VisilabsInAppNotificationsDelegate? {
        set {
            notificationsInstance.delegate = newValue
        }
        get {
            return notificationsInstance.delegate
        }
    }
    
    
    
    func checkInAppNotification(properties: [String:String], visilabsUser: VisilabsUser, timeoutInterval: TimeInterval, completion: @escaping ((_ response: VisilabsInAppNotification?) -> Void)){
        let semaphore = DispatchSemaphore(value: 0)
        let headers = prepareHeaders(visilabsUser)
        var notifications = [VisilabsInAppNotification]()
        
        VisilabsRequest.sendInAppNotificationRequest(properties: properties, headers: headers, timeoutInterval: timeoutInterval, completion: { visilabsInAppNotificationResult in
            guard let result = visilabsInAppNotificationResult else  {
                semaphore.signal()
                completion(nil)
                return
            }

            for rawNotif in result{
                if let actionData = rawNotif["actiondata"] as? [String : Any] {
                    if let typeString = actionData["msg_type"] as? String, let _ = VisilabsInAppNotificationType(rawValue: typeString), let notification = VisilabsInAppNotification(JSONObject: rawNotif) {
                        notifications.append(notification)
                    }
                }
            }
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        VisilabsLogger.info("in app notification check: \(notifications.count) found. actid's: \(notifications.map({String($0.actId)}).joined(separator: ","))")
        
        self.notificationsInstance.inAppNotification = notifications.first
        completion(notifications.first)
    }
    
    private func prepareHeaders(_ visilabsUser: VisilabsUser) -> [String:String] {
        var headers = [String:String]()
        headers["User-Agent"] = visilabsUser.userAgent
        return headers
    }
    
    // MARK: - Favorites
    
    //class func sendMobileRequest(properties: [String : String], headers: [String : String], timeoutInterval: TimeInterval, completion: @escaping ([String: Any]?) -> Void) {
    //https://s.visilabs.net/mobile?OM.oid=676D325830564761676D453D&OM.siteID=356467332F6533766975593D&OM.cookieID=B220EC66-A746-4130-93FD-53543055E406&OM.exVisitorID=ogun.ozturk%40euromsg.com&action_id=188&action_type=FavoriteAttributeAction&OM.apiver=IOS
    func getFavorites(visilabsUser: VisilabsUser, actionId: Int? = nil, completion: @escaping ((_ response: VisilabsFavoritesResponse) -> Void)){
        
        var props = [String: String]()
        props[VisilabsConstants.ORGANIZATIONID_KEY] = self.visilabsProfile.organizationId
        props[VisilabsConstants.PROFILEID_KEY] = self.visilabsProfile.profileId
        props[VisilabsConstants.COOKIEID_KEY] = visilabsUser.cookieId
        props[VisilabsConstants.EXVISITORID_KEY] = visilabsUser.exVisitorId
        props[VisilabsConstants.TOKENID_KEY] = visilabsUser.tokenId
        props[VisilabsConstants.APPID_KEY] = visilabsUser.appId
        props[VisilabsConstants.APIVER_KEY] = VisilabsConstants.APIVER_VALUE
        props[VisilabsConstants.ACTION_TYPE] = VisilabsConstants.FAVORITE_ATTRIBUTE_ACTION
        props[VisilabsConstants.ACTION_ID] = actionId == nil ? nil : String(actionId!)
        
        VisilabsRequest.sendMobileRequest(properties: props, headers: [String : String](), timeoutInterval: self.visilabsProfile.requestTimeoutInterval, completion: { (result:[String: Any]?, reason: VisilabsReason?) in
            

            if reason != nil {
                //completion(VisilabsRecommendationResponse(products: [VisilabsProduct](), error: reason))
            }else {
                for r in result!{
                    if let product = VisilabsProduct(JSONObject: r as? [String: Any?]) {
                        products.append(product)
                    }
                }
                
                completion(VisilabsRecommendationResponse(products: products, error: nil))
            }
        })
        
    }
    
    //{"capping":"{\"data\":{}}","VERSION":1,"FavoriteAttributeAction":[{"actid":188,"title":"fav-test","actiontype":"FavoriteAttributeAction","actiondata":{"attributes":["category","brand"],"favorites":{"category":["6","8","2"],"brand":["Kozmo","Luxury Room","OFS"]}}}]}
    private func parseFavoritesResponse(result:[String: Any]?, reason: VisilabsReason?) -> VisilabsFavoritesResponse {
        if let error = reason {
            return VisilabsFavoritesResponse(favorites: [VisilabsFavoriteAttribute : [String]](), error: error)
        } else if let res = result {
            if let favoriteAttributeActions = res[VisilabsConstants.FAVORITE_ATTRIBUTE_ACTION] as? [[String: Any?]] {
                for favoriteAttributeAction in favoriteAttributeActions {
                    if let actiondata = favoriteAttributeAction[VisilabsConstants.ACTIONDATA] as? [String: Any?] {
                        if let favorites = actiondata[VisilabsConstants.FAVORITES] as? [String: [String]?]{
                            
                        }
                    }
                }
            }
        }
        return VisilabsFavoritesResponse(favorites: [VisilabsFavoriteAttribute : [String]](), error: VisilabsReason.noData)
    }
    
}

