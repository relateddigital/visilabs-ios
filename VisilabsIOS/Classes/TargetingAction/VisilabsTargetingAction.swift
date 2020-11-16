//
//  VisilabsTargetingAction.swift
//  VisilabsIOS
//
//  Created by Egemen on 18.08.2020.
//

import UIKit

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

    func checkInAppNotification(properties: [String: String], visilabsUser: VisilabsUser, timeoutInterval: TimeInterval, completion: @escaping ((_ response: VisilabsInAppNotification?) -> Void)) {
        let semaphore = DispatchSemaphore(value: 0)
        let headers = prepareHeaders(visilabsUser)
        var notifications = [VisilabsInAppNotification]()
        var props = properties
        props["OM.vcap"] = visilabsUser.visitData
        props["OM.viscap"] = visilabsUser.visitorData

        VisilabsRequest.sendInAppNotificationRequest(properties: props, headers: headers, timeoutInterval: timeoutInterval, completion: { visilabsInAppNotificationResult in
            guard let result = visilabsInAppNotificationResult else {
                semaphore.signal()
                completion(nil)
                return
            }

            for rawNotif in result {
                if let actionData = rawNotif["actiondata"] as? [String: Any] {
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

    private func prepareHeaders(_ visilabsUser: VisilabsUser) -> [String: String] {
        var headers = [String: String]()
        headers["User-Agent"] = visilabsUser.userAgent
        return headers
    }

    // MARK: - Favorites

    //class func sendMobileRequest(properties: [String : String], headers: [String : String], timeoutInterval: TimeInterval, completion: @escaping ([String: Any]?) -> Void) {
    //https://s.visilabs.net/mobile?OM.oid=676D325830564761676D453D&OM.siteID=356467332F6533766975593D&OM.cookieID=B220EC66-A746-4130-93FD-53543055E406&OM.exVisitorID=ogun.ozturk%40euromsg.com&action_id=188&action_type=FavoriteAttributeAction&OM.apiver=IOS
    func getFavorites(visilabsUser: VisilabsUser, actionId: Int? = nil, completion: @escaping ((_ response: VisilabsFavoriteAttributeActionResponse) -> Void)) {

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

        VisilabsRequest.sendMobileRequest(properties: props, headers: [String: String](), timeoutInterval: self.visilabsProfile.requestTimeoutInterval, completion: { (result: [String: Any]?, error: VisilabsError?, _: String?) in
            completion(self.parseFavoritesResponse(result, error))
        })
    }

    //{"capping":"{\"data\":{}}","VERSION":1,"FavoriteAttributeAction":[{"actid":188,"title":"fav-test","actiontype":"FavoriteAttributeAction","actiondata":{"attributes":["category","brand"],"favorites":{"category":["6","8","2"],"brand":["Kozmo","Luxury Room","OFS"]}}}]}
    private func parseFavoritesResponse(_ result: [String: Any]?, _ error: VisilabsError?) -> VisilabsFavoriteAttributeActionResponse {
        var favoritesResponse = [VisilabsFavoriteAttribute: [String]]()
        var errorResponse: VisilabsError?
        if let error = error {
            errorResponse = error
        } else if let res = result {
            if let favoriteAttributeActions = res[VisilabsConstants.FAVORITE_ATTRIBUTE_ACTION] as? [[String: Any?]] {
                for favoriteAttributeAction in favoriteAttributeActions {
                    if let actiondata = favoriteAttributeAction[VisilabsConstants.ACTIONDATA] as? [String: Any?] {
                        if let favorites = actiondata[VisilabsConstants.FAVORITES] as? [String: [String]?] {
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

    func getStories(visilabsUser: VisilabsUser, guid: String, actionId: Int? = nil, completion: @escaping ((_ response: VisilabsStoryActionResponse) -> Void)) {

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

        VisilabsRequest.sendMobileRequest(properties: props, headers: [String: String](), timeoutInterval: self.visilabsProfile.requestTimeoutInterval, completion: { (result: [String: Any]?, error: VisilabsError?, guid: String?) in
            completion(self.parseStories(result, error, guid))
        }, guid: guid)
    }

    //TODO: burada storiesResponse kısmı değiştirilmeli. aynı requestte birden fazla story action'ı gelebilir.
    private func parseStories(_ result: [String: Any]?, _ error: VisilabsError?, _ guid: String?) -> VisilabsStoryActionResponse {
        var storiesResponse = [VisilabsStoryAction]()
        var errorResponse: VisilabsError?
        if let error = error {
            errorResponse = error
        } else if let res = result {
            if let storyActions = res[VisilabsConstants.STORY] as? [[String: Any?]] {
                var visilabsStories = [VisilabsStory]()
                for storyAction in storyActions {
                    if let actionId = storyAction[VisilabsConstants.ACTID] as? Int, let actiondata = storyAction[VisilabsConstants.ACTIONDATA] as? [String: Any?], let templateString = actiondata[VisilabsConstants.TATEMPLATE] as? String, let template = VisilabsStoryTemplate.init(rawValue: templateString) {
                        if let stories = actiondata[VisilabsConstants.STORIES] as? [[String: Any]] {
                            for story in stories {
                                if template == .SkinBased {
                                    var storyItems = [VisilabsStoryItem]()
                                    if let items = story[VisilabsConstants.ITEMS] as? [[String: Any]] {
                                        for item in items {
                                            storyItems.append(parseStoryItem(item))
                                        }
                                        if storyItems.count > 0 {
                                            visilabsStories.append(VisilabsStory(title: story[VisilabsConstants.TITLE] as? String, smallImg: story[VisilabsConstants.THUMBNAIL] as? String, link: story[VisilabsConstants.LINK] as? String, items: storyItems))
                                        }
                                    }
                                } else {
                                    visilabsStories.append(VisilabsStory(title: story[VisilabsConstants.TITLE] as? String, smallImg: story[VisilabsConstants.SMALLIMG] as? String, link: story[VisilabsConstants.LINK] as? String))
                                }
                            }
                            let (clickQueryItems, impressionQueryItems) = parseStoryReport(actiondata[VisilabsConstants.REPORT] as? [String: Any?])
                            if stories.count > 0 {
                                storiesResponse.append(VisilabsStoryAction(actionId: actionId, storyTemplate: template, stories: visilabsStories, clickQueryItems: clickQueryItems, impressionQueryItems: impressionQueryItems, extendedProperties: parseStoryExtendedProps(actiondata[VisilabsConstants.EXTENDEDPROPS] as? String)))
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

    private func parseStoryReport(_ report: [String: Any?]?) -> ([String: String], [String: String]) {
        var clickItems = [String: String]()
        var impressionItems = [String: String]()
        //clickItems["OM.domain"] =  "\(self.visilabsProfile.dataSource)_IOS" // TODO: OM.domain ne için gerekiyor?
        if let rep = report {
            if let click = rep[VisilabsConstants.CLICK] as? String {
                let qsArr = click.components(separatedBy: "&")
                for queryItem in qsArr {
                    let queryItemComponents = queryItem.components(separatedBy: "=")
                    if queryItemComponents.count == 2 {
                        clickItems[queryItemComponents[0]] = queryItemComponents[1]
                    }
                }
            }
            if let impression = rep[VisilabsConstants.IMPRESSION] as? String {
                let qsArr = impression.components(separatedBy: "&")
                for queryItem in qsArr {
                    let queryItemComponents = queryItem.components(separatedBy: "=")
                    if queryItemComponents.count == 2 {
                        impressionItems[queryItemComponents[0]] = queryItemComponents[1]
                    }
                }
            }

        }
        return (clickItems, impressionItems)
    }

    private func parseStoryItem(_ item: [String: Any]) -> VisilabsStoryItem {
        let fileType = (item[VisilabsConstants.FILETYPE] as? String) ?? "photo"
        let fileSrc = (item[VisilabsConstants.FILESRC] as? String) ?? ""
        let targetUrl = (item[VisilabsConstants.TARGETURL]  as? String) ?? ""
        let buttonText = (item[VisilabsConstants.BUTTONTEXT]  as? String) ?? ""
        var displayTime = 3
        if let dTime = item[VisilabsConstants.DISPLAYTIME] as? Int, dTime > 0 {
            displayTime = dTime
        }
        var buttonTextColor = UIColor.white
        var buttonColor = UIColor.black
        if let buttonTextColorString = item[VisilabsConstants.BUTTONTEXTCOLOR] as? String {
            if buttonTextColorString.starts(with: "rgba") {
                if let btColor =  UIColor.init(rgbaString: buttonTextColorString) {
                    buttonTextColor = btColor
                }
            } else {
                if let btColor = UIColor.init(hex: buttonTextColorString) {
                    buttonTextColor = btColor
                }
            }
        }
        if let buttonColorString = item[VisilabsConstants.BUTTONCOLOR] as? String {
            if buttonColorString.starts(with: "rgba") {
                if let bColor =  UIColor.init(rgbaString: buttonColorString) {
                    buttonColor = bColor
                }
            } else {
                if let bColor = UIColor.init(hex: buttonColorString) {
                    buttonColor = bColor
                }
            }
        }
        let visilabsStoryItem = VisilabsStoryItem(fileType: fileType, displayTime: displayTime, fileSrc: fileSrc, targetUrl: targetUrl, buttonText: buttonText, buttonTextColor: buttonTextColor, buttonColor: buttonColor)
        return visilabsStoryItem
    }

    private func parseStoryExtendedProps(_ extendedPropsString: String?) -> VisilabsStoryActionExtendedProperties {
        let props = VisilabsStoryActionExtendedProperties()
        if let s = extendedPropsString, let extendedProps = s.urlDecode().convertJsonStringToDictionary() {
            if let imageBorderWidthString = extendedProps[VisilabsConstants.storylb_img_borderWidth] as? String, let imageBorderWidth = Int(imageBorderWidthString) {
                props.imageBorderWidth = imageBorderWidth
            }
            if let imageBorderRadiusString = extendedProps[VisilabsConstants.storylb_img_borderRadius] as? String ?? extendedProps[VisilabsConstants.storyz_img_borderRadius] as? String, let imageBorderRadius = Double(imageBorderRadiusString.trimmingCharacters(in: CharacterSet(charactersIn: "%"))) {
                props.imageBorderRadius = imageBorderRadius / 100.0
            }
            if let imageBorderColorString = extendedProps[VisilabsConstants.storylb_img_borderColor] as? String ?? extendedProps[VisilabsConstants.storyz_img_borderColor] as? String {
                if imageBorderColorString.starts(with: "rgba") {
                    if let imageBorderColor =  UIColor.init(rgbaString: imageBorderColorString) {
                        props.imageBorderColor = imageBorderColor
                    }
                } else {
                    if let imageBorderColor = UIColor.init(hex: imageBorderColorString) {
                        props.imageBorderColor = imageBorderColor
                    }
                }
            }
            if let labelColorString = extendedProps[VisilabsConstants.storylb_label_color] as? String {
                if labelColorString.starts(with: "rgba") {
                    if let labelColor =  UIColor.init(rgbaString: labelColorString) {
                        props.labelColor = labelColor
                    }
                } else {
                    if let labelColor = UIColor.init(hex: labelColorString) {
                        props.labelColor = labelColor
                    }
                }
            }
            if let boxShadowString = extendedProps[VisilabsConstants.storylb_img_boxShadow] as? String, boxShadowString.count > 0 {
                props.imageBoxShadow = true
            }
        }
        return props
    }

}
