//
//  VisilabsTargetingAction.swift
//  VisilabsIOS
//
//  Created by Egemen on 18.08.2020.
//

import UIKit
//swiftlint:disable type_body_length
class VisilabsTargetingAction {

    let visilabsProfile: VisilabsProfile

    required init(lock: VisilabsReadWriteLock, visilabsProfile: VisilabsProfile) {
        self.notificationsInstance = VisilabsInAppNotifications(lock: lock)
        self.visilabsProfile = visilabsProfile
    }

    // MARK: - InApp Notifications

    var notificationsInstance: VisilabsInAppNotifications

    var inAppDelegate: VisilabsInAppNotificationsDelegate? {
        get {
            return notificationsInstance.delegate
        }
        set {
            notificationsInstance.delegate = newValue
        }
    }

    func checkInAppNotification(properties: [String: String],
                                visilabsUser: VisilabsUser,
                                timeoutInterval: TimeInterval,
                                completion: @escaping ((_ response: VisilabsInAppNotification?) -> Void)) {
        let semaphore = DispatchSemaphore(value: 0)
        let headers = prepareHeaders(visilabsUser)
        var notifications = [VisilabsInAppNotification]()
        var props = properties
        props["OM.vcap"] = visilabsUser.visitData
        props["OM.viscap"] = visilabsUser.visitorData

        VisilabsRequest.sendInAppNotificationRequest(properties: props,
                                                     headers: headers,
                                                     timeoutInterval: timeoutInterval,
                                                     completion: { visilabsInAppNotificationResult in
            guard let result = visilabsInAppNotificationResult else {
                semaphore.signal()
                completion(nil)
                return
            }

            for rawNotif in result {
                if let actionData = rawNotif["actiondata"] as? [String: Any] {
                    if let typeString = actionData["msg_type"] as? String,
                       VisilabsInAppNotificationType(rawValue: typeString) != nil,
                       let notification = VisilabsInAppNotification(JSONObject: rawNotif) {
                        notifications.append(notification)
                    }
                }
            }
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        VisilabsLogger.info("in app notification check: \(notifications.count) found." +
                            " actid's: \(notifications.map({String($0.actId)}).joined(separator: ","))")

        self.notificationsInstance.inAppNotification = notifications.first
        completion(notifications.first)
    }

    private func prepareHeaders(_ visilabsUser: VisilabsUser) -> [String: String] {
        var headers = [String: String]()
        headers["User-Agent"] = visilabsUser.userAgent
        return headers
    }

    // MARK: - Favorites

    //class func sendMobileRequest(properties: [String : String],
    //headers: [String : String], timeoutInterval: TimeInterval, completion: @escaping ([String: Any]?) -> Void) {
    //https://s.visilabs.net/mobile?OM.oid=676D325830564761676D453D&OM
    //.siteID=356467332F6533766975593D&OM.cookieID=B220EC66-A746-4130-93FD-53543055E406&
    //OM.exVisitorID=ogun.ozturk%40euromsg.com&action_id=188&action_type=FavoriteAttributeAction&OM.apiver=IOS
    func getFavorites(visilabsUser: VisilabsUser, actionId: Int? = nil,
                      completion: @escaping ((_ response: VisilabsFavoriteAttributeActionResponse) -> Void)) {

        var props = [String: String]()
        props[VisilabsConstants.organizationIdKey] = self.visilabsProfile.organizationId
        props[VisilabsConstants.profileIdKey] = self.visilabsProfile.profileId
        props[VisilabsConstants.cookieIdKey] = visilabsUser.cookieId
        props[VisilabsConstants.exvisitorIdKey] = visilabsUser.exVisitorId
        props[VisilabsConstants.tokenIdKey] = visilabsUser.tokenId
        props[VisilabsConstants.appidKey] = visilabsUser.appId
        props[VisilabsConstants.apiverKey] = VisilabsConstants.apiverValue
        props[VisilabsConstants.actionType] = VisilabsConstants.favoriteAttributeAction
        props[VisilabsConstants.actionId] = actionId == nil ? nil : String(actionId!)

        VisilabsRequest.sendMobileRequest(properties: props, headers: [String: String](),
                                          timeoutInterval: self.visilabsProfile.requestTimeoutInterval,
                                          completion: { (result: [String: Any]?, error: VisilabsError?, _: String?) in
            completion(self.parseFavoritesResponse(result, error))
        })
    }

    //{"capping":"{\"data\":{}}","VERSION":1,"FavoriteAttributeAction:
    //[{"actid":188,"title":"fav-test","actiontype":"FavoriteAttributeAction",
    //"actiondata":{"attributes":["category","brand"],"favorites":{"category":["6","8","2"],
    //"brand":["Kozmo","Luxury Room","OFS"]}}}]}
    private func parseFavoritesResponse(_ result: [String: Any]?,
                                        _ error: VisilabsError?) -> VisilabsFavoriteAttributeActionResponse {
        var favoritesResponse = [VisilabsFavoriteAttribute: [String]]()
        var errorResponse: VisilabsError?
        if let error = error {
            errorResponse = error
        } else if let res = result {
            if let favoriteAttributeActions = res[VisilabsConstants.favoriteAttributeAction] as? [[String: Any?]] {
                for favoriteAttributeAction in favoriteAttributeActions {
                    if let actiondata = favoriteAttributeAction[VisilabsConstants.actionData] as? [String: Any?] {
                        if let favorites = actiondata[VisilabsConstants.favorites] as? [String: [String]?] {
                            for favorite in favorites {
                                if let favoriteAttribute = VisilabsFavoriteAttribute(rawValue: favorite.key),
                                   let favoriteValues = favorite.value {
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

    func getStories(visilabsUser: VisilabsUser,
                    guid: String, actionId: Int? = nil,
                    completion: @escaping ((_ response: VisilabsStoryActionResponse) -> Void)) {

        var props = [String: String]()
        props[VisilabsConstants.organizationIdKey] = self.visilabsProfile.organizationId
        props[VisilabsConstants.profileIdKey] = self.visilabsProfile.profileId
        props[VisilabsConstants.cookieIdKey] = visilabsUser.cookieId
        props[VisilabsConstants.exvisitorIdKey] = visilabsUser.exVisitorId
        props[VisilabsConstants.tokenIdKey] = visilabsUser.tokenId
        props[VisilabsConstants.appidKey] = visilabsUser.appId
        props[VisilabsConstants.apiverKey] = VisilabsConstants.apiverValue
        props[VisilabsConstants.actionType] = VisilabsConstants.story
        props[VisilabsConstants.actionId] = actionId == nil ? nil : String(actionId!)

        VisilabsRequest.sendMobileRequest(properties: props,
                                          headers: [String: String](),
                                          timeoutInterval: self.visilabsProfile.requestTimeoutInterval,
                                          completion: {(result: [String: Any]?, error: VisilabsError?, guid: String?) in
            completion(self.parseStories(result, error, guid))
        }, guid: guid)
    }

    func getEmailForm(visilabsUser: VisilabsUser,
                      guid: String, actionId: Int? = nil,
                      completion: @escaping ((_ response: MailSubscriptionViewModel?) -> Void)) {
    
        var props = [String: String]()
        props[VisilabsConstants.organizationIdKey] = self.visilabsProfile.organizationId
        props[VisilabsConstants.profileIdKey] = self.visilabsProfile.profileId
        props[VisilabsConstants.cookieIdKey] = visilabsUser.cookieId
        props[VisilabsConstants.exvisitorIdKey] = visilabsUser.exVisitorId
        props[VisilabsConstants.tokenIdKey] = visilabsUser.tokenId
        props[VisilabsConstants.appidKey] = visilabsUser.appId
        props[VisilabsConstants.apiverKey] = VisilabsConstants.apiverValue
        props[VisilabsConstants.actionType] = VisilabsConstants.mailSubscriptionForm
        props[VisilabsConstants.actionId] = actionId == nil ? nil : String(actionId!)

        VisilabsRequest.sendMobileRequest(properties: props,
                                          headers: [String : String](),
                                          timeoutInterval: self.visilabsProfile.requestTimeoutInterval,
                                          completion: {(result: [String: Any]?, error: VisilabsError?, guid: String?) in
                                            completion(self.parseMailForm(result, error, guid))

        }, guid: guid)
    }
    
    private func parseMailForm(_ result: [String: Any]?,
                               _ error: VisilabsError?,
                               _ guid: String?) -> MailSubscriptionViewModel? {
        guard let result = result else { return nil }
        guard let mailFormArr = result[VisilabsConstants.mailSubscriptionForm] as? [[String: Any?]] else { return nil }
        guard let mailForm = mailFormArr.first else { return nil }
        guard let actionData = mailForm[VisilabsConstants.actionData] as? [String: Any] else { return nil }
        let encodedStr = actionData[VisilabsConstants.extendedProps] as? String ?? ""
        guard let extendedProps = encodedStr.urlDecode().convertJsonStringToDictionary() else { return nil }
        guard let report = actionData[VisilabsConstants.report] as? [String: Any] else { return nil }
        let title = actionData[VisilabsConstants.title] as? String ?? ""
        let message = actionData[VisilabsConstants.message] as? String ?? ""
        let actid = mailForm[VisilabsConstants.actid] as? Int ?? 0
        let type = actionData[VisilabsConstants.type] as? String ?? "subscription_email"
        let buttonText = actionData[VisilabsConstants.buttonLabel] as? String ?? ""
        let auth = actionData[VisilabsConstants.authentication] as? String ?? ""
        let consentText = actionData[VisilabsConstants.consentText] as? String
        let successMsg = actionData[VisilabsConstants.successMessage] as? String ?? ""
        let invalidMsg = actionData[VisilabsConstants.invalidEmailMessage] as? String ?? ""
        let emailPermitText = actionData[VisilabsConstants.emailPermitText] as? String ?? ""
        let checkConsent = actionData[VisilabsConstants.checkConsentMessage] as? String ?? ""
        let placeholder = actionData[VisilabsConstants.placeholder] as? String ?? ""

        let titleTextColor = extendedProps[VisilabsConstants.titleTextColor] as? String ?? ""
        let titleFontFamily = extendedProps[VisilabsConstants.titleFontFamily] as? String ?? ""
        let titleTextSize = extendedProps[VisilabsConstants.titleTextSize] as? String ?? ""
        let textColor = extendedProps[VisilabsConstants.textColor] as? String ?? ""
        let textFontFamily = extendedProps[VisilabsConstants.textFontFamily] as? String ?? ""
        let textSize = extendedProps[VisilabsConstants.textSize] as? String ?? ""
        let buttonColor = extendedProps[VisilabsInAppNotification.PayloadKey.buttonColor] as? String ?? ""
        let buttonTextColor = extendedProps[VisilabsInAppNotification.PayloadKey.buttonTextColor] as? String ?? ""
        let buttonTextSize = extendedProps[VisilabsConstants.buttonTextSize] as? String ?? ""
        let buttonFontFamily = extendedProps[VisilabsConstants.buttonFontFamily] as? String ?? ""
        let emailPermitTextSize = extendedProps[VisilabsConstants.emailPermitTextSize] as? String ?? ""
        let emailPermitTextUrl = extendedProps[VisilabsConstants.emailPermitTextUrl] as? String ?? ""
        let consentTextSize = extendedProps[VisilabsConstants.consentTextSize] as? String ?? ""
        let consentTextUrl = extendedProps[VisilabsConstants.consentTextUrl] as? String ?? ""
        let closeButtonColor = extendedProps[VisilabsConstants.closeButtonColor] as? String ?? "black"
        let backgroundColor = extendedProps[VisilabsConstants.backgroundColor] as? String ?? ""
        let impression = report[VisilabsConstants.impression] as? String ?? ""
        let click = report[VisilabsConstants.click] as? String ?? ""
        let mailReport = MailReport(impression: impression, click: click)
        let extendedProperties = MailSubscriptionExtendedProps(titleTextColor: titleTextColor,
                                                               titleFontFamily: titleFontFamily,
                                                               titleTextSize: titleTextSize,
                                                               textColor: textColor,
                                                               textFontFamily: textFontFamily,
                                                               textSize: textSize,
                                                               buttonColor: buttonColor,
                                                               buttonTextColor: buttonTextColor,
                                                               buttonTextSize: buttonTextSize,
                                                               buttonFontFamily: buttonFontFamily,
                                                               emailPermitTextSize: emailPermitTextSize,
                                                               emailPermitTextUrl: emailPermitTextUrl,
                                                               consentTextSize: consentTextSize,
                                                               consentTextUrl: consentTextUrl,
                                                               closeButtonColor: ButtonColor(rawValue: closeButtonColor) ?? ButtonColor.black,
                                                               backgroundColor: backgroundColor)
        
        let mailModel = MailSubscriptionModel(auth: auth,
                                              title: title,
                                              message: message,
                                              actid: actid,
                                              type: type,
                                              placeholder: placeholder,
                                              buttonTitle: buttonText,
                                              consentText: consentText,
                                              successMessage: successMsg,
                                              invalidEmailMessage: invalidMsg,
                                              emailPermitText: emailPermitText,
                                              extendedProps: extendedProperties,
                                              checkConsentMessage: checkConsent,
                                              report: mailReport)
        return convertJsonToEmailViewModel(emailForm: mailModel)
    }
    
    private func convertJsonToEmailViewModel(emailForm: MailSubscriptionModel) -> MailSubscriptionViewModel {
        var parsedConsent: ParsedPermissionString? = nil
        if let consent = emailForm.consentText, !consent.isEmpty {
            parsedConsent = consent.parsePermissionText()
        }
        let parsedPermit = emailForm.emailPermitText.parsePermissionText()
        let titleFont = VisilabsInAppNotification.getFont(fontFamily: emailForm.extendedProps.titleFontFamily,
                                                          fontSize: emailForm.extendedProps.titleTextSize,
                                                          style: .title2)
        let messageFont = VisilabsInAppNotification.getFont(fontFamily: emailForm.extendedProps.textFontFamily,
                                                            fontSize: emailForm.extendedProps.textSize,
                                                            style: .body)
        let buttonFont = VisilabsInAppNotification.getFont(fontFamily: emailForm.extendedProps.buttonFontFamily,
                                                           fontSize: emailForm.extendedProps.buttonTextSize,
                                                           style: .title2)
        let closeButtonColor = getCloseButtonColor(from: emailForm.extendedProps.closeButtonColor)
        let titleColor = UIColor(hex: emailForm.extendedProps.titleTextColor) ?? .white
        let textColor = UIColor(hex: emailForm.extendedProps.textColor) ?? .white
        let backgroundColor = UIColor(hex: emailForm.extendedProps.backgroundColor) ?? .black
        let emailPermitUrl = URL(string: emailForm.extendedProps.emailPermitTextUrl)
        let consentUrl = URL(string: emailForm.extendedProps.consentTextUrl)
        let buttonTextColor = UIColor(hex: emailForm.extendedProps.buttonTextColor) ?? .white
        let buttonColor = UIColor(hex: emailForm.extendedProps.buttonColor) ?? .black
        let permitTextSize = (Int(emailForm.extendedProps.emailPermitTextSize) ?? 0) + 6
        let consentTextSize = (Int(emailForm.extendedProps.consentTextSize) ?? 0) + 6
        let viewModel = MailSubscriptionViewModel(auth: emailForm.auth,
                                                  actId: emailForm.actid,
                                                  type: emailForm.type,
                                                  title: emailForm.title,
                                                  message: emailForm.message,
                                                  placeholder: emailForm.placeholder,
                                                  buttonTitle: emailForm.buttonTitle,
                                                  consentText: parsedConsent,
                                                  permitText: parsedPermit,
                                                  successMessage: emailForm.successMessage,
                                                  invalidEmailMessage: emailForm.invalidEmailMessage,
                                                  checkConsentMessage: emailForm.checkConsentMessage,
                                                  titleFont: titleFont,
                                                  messageFont: messageFont,
                                                  buttonFont: buttonFont,
                                                  buttonTextColor: buttonTextColor,
                                                  buttonColor: buttonColor,
                                                  emailPermitUrl: emailPermitUrl,
                                                  consentUrl: consentUrl,
                                                  closeButtonColor: closeButtonColor,
                                                  titleColor: titleColor,
                                                  textColor: textColor,
                                                  backgroundColor: backgroundColor,
                                                  permitTextSize: permitTextSize,
                                                  consentTextSize: consentTextSize,
                                                  report: emailForm.report)
        return viewModel
    }
    
    func getCloseButtonColor(from buttonColor: ButtonColor) -> UIColor {
        if buttonColor == .white {
            return .white
        } else {
            return .black
        }
    }

    //swiftlint:disable function_body_length cyclomatic_complexity
    //TO_DO: burada storiesResponse kısmı değiştirilmeli. aynı requestte birden fazla story action'ı gelebilir.
    private func parseStories(_ result: [String: Any]?,
                              _ error: VisilabsError?,
                              _ guid: String?) -> VisilabsStoryActionResponse {
        var storiesResponse = [VisilabsStoryAction]()
        var errorResponse: VisilabsError?
        if let error = error {
            errorResponse = error
        } else if let res = result {
            if let storyActions = res[VisilabsConstants.story] as? [[String: Any?]] {
                var visilabsStories = [VisilabsStory]()
                for storyAction in storyActions {
                    if let actionId = storyAction[VisilabsConstants.actid] as? Int,
                       let actiondata = storyAction[VisilabsConstants.actionData] as? [String: Any?],
                       let templateString = actiondata[VisilabsConstants.taTemplate] as? String,
                       let template = VisilabsStoryTemplate.init(rawValue: templateString) {
                        if let stories = actiondata[VisilabsConstants.stories] as? [[String: Any]] {
                            for story in stories {
                                if template == .skinBased {
                                    var storyItems = [VisilabsStoryItem]()
                                    if let items = story[VisilabsConstants.items] as? [[String: Any]] {
                                        for item in items {
                                            storyItems.append(parseStoryItem(item))
                                        }
                                        if storyItems.count > 0 {
                                            visilabsStories.append(VisilabsStory(title: story[VisilabsConstants.title]
                                                                                    as? String,
                                            smallImg: story[VisilabsConstants.thumbnail] as? String,
                                            link: story[VisilabsConstants.link] as? String, items: storyItems))
                                        }
                                    }
                                } else {
                                    visilabsStories.append(VisilabsStory(title: story[VisilabsConstants.title]
                                                                            as? String,
                                    smallImg: story[VisilabsConstants.smallImg] as? String,
                                    link: story[VisilabsConstants.link] as? String))
                                }
                            }
                            let (clickQueryItems, impressionQueryItems)
                                = parseStoryReport(actiondata[VisilabsConstants.report] as? [String: Any?])
                            if stories.count > 0 {
                                storiesResponse.append(VisilabsStoryAction(actionId: actionId,
                                                                           storyTemplate: template,
                                                                           stories: visilabsStories,
                                                                           clickQueryItems: clickQueryItems,
                                                                           impressionQueryItems: impressionQueryItems,
                        extendedProperties: parseStoryExtendedProps(actiondata[VisilabsConstants.extendedProps]
                                                                                                    as? String)))
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
        //clickItems["OM.domain"] =  "\(self.visilabsProfile.dataSource)_IOS" // TO_DO: OM.domain ne için gerekiyor?
        if let rep = report {
            if let click = rep[VisilabsConstants.click] as? String {
                let qsArr = click.components(separatedBy: "&")
                for queryItem in qsArr {
                    let queryItemComponents = queryItem.components(separatedBy: "=")
                    if queryItemComponents.count == 2 {
                        clickItems[queryItemComponents[0]] = queryItemComponents[1]
                    }
                }
            }
            if let impression = rep[VisilabsConstants.impression] as? String {
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
        let fileType = (item[VisilabsConstants.fileType] as? String) ?? "photo"
        let fileSrc = (item[VisilabsConstants.fileSrc] as? String) ?? ""
        let targetUrl = (item[VisilabsConstants.targetUrl]  as? String) ?? ""
        let buttonText = (item[VisilabsConstants.buttonText]  as? String) ?? ""
        var displayTime = 3
        if let dTime = item[VisilabsConstants.displayTime] as? Int, dTime > 0 {
            displayTime = dTime
        }
        var buttonTextColor = UIColor.white
        var buttonColor = UIColor.black
        if let buttonTextColorString = item[VisilabsConstants.buttonTextColor] as? String {
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
        if let buttonColorString = item[VisilabsConstants.buttonColor] as? String {
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
        let visilabsStoryItem = VisilabsStoryItem(fileType: fileType,
                                                  displayTime: displayTime,
                                                  fileSrc: fileSrc,
                                                  targetUrl: targetUrl,
                                                  buttonText: buttonText,
                                                  buttonTextColor: buttonTextColor,
                                                  buttonColor: buttonColor)
        return visilabsStoryItem
    }
    //swiftlint:disable cyclomatic_complexity
    private func parseStoryExtendedProps(_ extendedPropsString: String?) -> VisilabsStoryActionExtendedProperties {
        let props = VisilabsStoryActionExtendedProperties()
        if let propStr = extendedPropsString, let extendedProps = propStr.urlDecode().convertJsonStringToDictionary() {
            if let imageBorderWidthString = extendedProps[VisilabsConstants.storylbImgBorderWidth] as? String,
               let imageBorderWidth = Int(imageBorderWidthString) {
                props.imageBorderWidth = imageBorderWidth
            }
            if let imageBorderRadiusString = extendedProps[VisilabsConstants.storylbImgBorderRadius] as? String
                ?? extendedProps[VisilabsConstants.storyzImgBorderRadius] as? String,
               let imageBorderRadius = Double(imageBorderRadiusString.trimmingCharacters(in:
                                                                        CharacterSet(charactersIn: "%"))) {
                props.imageBorderRadius = imageBorderRadius / 100.0
            }
            if let imageBorderColorString = extendedProps[VisilabsConstants.storylbImgBorderColor] as? String
                ?? extendedProps[VisilabsConstants.storyzimgBorderColor] as? String {
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
            if let labelColorString = extendedProps[VisilabsConstants.storylbLabelColor] as? String {
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
            if let boxShadowString = extendedProps[VisilabsConstants.storylbImgBoxShadow] as? String,
               boxShadowString.count > 0 {
                props.imageBoxShadow = true
            }
        }
        return props
    }

}
