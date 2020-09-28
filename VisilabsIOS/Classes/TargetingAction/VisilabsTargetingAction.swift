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
        var props = properties
        props["OM.vcap"] = visilabsUser.visitData
        props["OM.viscap"] = visilabsUser.visitorData
        
        VisilabsRequest.sendInAppNotificationRequest(properties: props, headers: headers, timeoutInterval: timeoutInterval, completion: { visilabsInAppNotificationResult in
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
    func getFavorites(visilabsUser: VisilabsUser, actionId: Int? = nil, completion: @escaping ((_ response: VisilabsFavoriteAttributeActionResponse) -> Void)){
        
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
        
        VisilabsRequest.sendMobileRequest(properties: props, headers: [String : String](), timeoutInterval: self.visilabsProfile.requestTimeoutInterval, completion: { (result:[String: Any]?, error: VisilabsError?, guid: String?) in
            completion(self.parseFavoritesResponse(result, error))
        })
    }
    
    //{"capping":"{\"data\":{}}","VERSION":1,"FavoriteAttributeAction":[{"actid":188,"title":"fav-test","actiontype":"FavoriteAttributeAction","actiondata":{"attributes":["category","brand"],"favorites":{"category":["6","8","2"],"brand":["Kozmo","Luxury Room","OFS"]}}}]}
    private func parseFavoritesResponse(_ result:[String: Any]?, _ error: VisilabsError?) -> VisilabsFavoriteAttributeActionResponse {
        var favoritesResponse = [VisilabsFavoriteAttribute : [String]]()
        var errorResponse: VisilabsError? = nil
        if let error = error {
            errorResponse = error
        } else if let res = result {
            if let favoriteAttributeActions = res[VisilabsConstants.FAVORITE_ATTRIBUTE_ACTION] as? [[String: Any?]] {
                for favoriteAttributeAction in favoriteAttributeActions {
                    if let actiondata = favoriteAttributeAction[VisilabsConstants.ACTIONDATA] as? [String: Any?] {
                        if let favorites = actiondata[VisilabsConstants.FAVORITES] as? [String: [String]?]{
                            for favorite in favorites {
                                if let favoriteAttribute = VisilabsFavoriteAttribute(rawValue: favorite.key), let favoriteValues = favorite.value {
                                    favoritesResponse[favoriteAttribute].mergeStringArray(favoriteValues)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            errorResponse = VisilabsError.noData
        }
        return VisilabsFavoriteAttributeActionResponse(favorites: favoritesResponse, error: errorResponse)
    }
    
    // MARK: - Story
    
    
    var visilabsStoryHomeViewControllers = [String: VisilabsStoryHomeViewController]()
    var visilabsStoryHomeViews = [String: VisilabsStoryHomeView]()
    
    func getStories(visilabsUser: VisilabsUser, guid: String, actionId: Int? = nil, completion: @escaping ((_ response: VisilabsStoryActionResponse) -> Void)){
        
        var props = [String: String]()
        props[VisilabsConstants.ORGANIZATIONID_KEY] = self.visilabsProfile.organizationId
        props[VisilabsConstants.PROFILEID_KEY] = self.visilabsProfile.profileId
        props[VisilabsConstants.COOKIEID_KEY] = visilabsUser.cookieId
        props[VisilabsConstants.EXVISITORID_KEY] = visilabsUser.exVisitorId
        props[VisilabsConstants.TOKENID_KEY] = visilabsUser.tokenId
        props[VisilabsConstants.APPID_KEY] = visilabsUser.appId
        props[VisilabsConstants.APIVER_KEY] = VisilabsConstants.APIVER_VALUE
        props[VisilabsConstants.ACTION_TYPE] = VisilabsConstants.STORY
        props[VisilabsConstants.ACTION_ID] = actionId == nil ? nil : String(actionId!)
        
        VisilabsRequest.sendMobileRequest(properties: props, headers: [String : String](), timeoutInterval: self.visilabsProfile.requestTimeoutInterval, completion: { (result:[String: Any]?, error: VisilabsError?, guid: String?) in
            completion(self.parseStories(result, error, guid))
        }, guid: guid)
    }
    
    //TODO: burada storiesResponse kısmı değiştirilmeli. aynı requestte birden fazla story action'ı gelebilir.
    private func parseStories(_ result:[String: Any]?, _ error: VisilabsError?, _ guid: String?) -> VisilabsStoryActionResponse {
        var storiesResponse = [VisilabsStoryAction]()
        var errorResponse: VisilabsError? = nil
        if let error = error {
            errorResponse = error
        } else if let res = result {
            if let storyActions = res[VisilabsConstants.STORY] as? [[String: Any?]] {
                var visilabsStories = [VisilabsStory]()
                for storyAction in storyActions {
                    if let actionId = storyAction[VisilabsConstants.ACTID] as? Int, let actiondata = storyAction[VisilabsConstants.ACTIONDATA] as? [String: Any?], let templateString = actiondata[VisilabsConstants.TATEMPLATE] as? String
                    , let template = VisilabsStoryTemplate.init(rawValue: templateString){
                        if let stories = actiondata[VisilabsConstants.STORIES] as? [[String: String]]{
                            for story in stories {
                                visilabsStories.append(VisilabsStory(title: story[VisilabsConstants.TITLE], smallImg: story[VisilabsConstants.SMALLIMG], link: story[VisilabsConstants.LINK]))
                            }
                            var clickQueryString = ""
                            if let report = actiondata[VisilabsConstants.REPORT] as? [String: Any?], let click = report[VisilabsConstants.CLICK] as? String {
                                clickQueryString = click
                            }
                            if stories.count > 0 {
                                storiesResponse.append(VisilabsStoryAction(actionId: actionId, storyTemplate: template, stories: visilabsStories, clickQueryString: clickQueryString, extendedProperties: parseStoryExtendedProps()))
                            }
                        }
                    }
                }
            }
        } else {
            errorResponse = VisilabsError.noData
        }
        return VisilabsStoryActionResponse(storyActions: storiesResponse, error: errorResponse, guid: guid)
    }
    
    
    private func parseStoryExtendedProps() -> VisilabsStoryActionExtendedProperties {
        return VisilabsStoryActionExtendedProperties()
    }
    
}

