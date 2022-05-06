//
//  VisilabsTargetingAction.swift
//  VisilabsIOS
//
//  Created by Egemen on 18.08.2020.
//

import UIKit
// swiftlint:disable type_body_length
class VisilabsTargetingAction {

    let visilabsProfile: VisilabsProfile

    required init(lock: VisilabsReadWriteLock, visilabsProfile: VisilabsProfile) {
        self.notificationsInstance = VisilabsInAppNotifications(lock: lock)
        self.visilabsProfile = visilabsProfile
    }

    private func prepareHeaders(_ visilabsUser: VisilabsUser) -> [String: String] {
        var headers = [String: String]()
        headers["User-Agent"] = visilabsUser.userAgent
        return headers
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
                                completion: @escaping ((_ response: VisilabsInAppNotification?) -> Void)) {
        let semaphore = DispatchSemaphore(value: 0)
        let headers = prepareHeaders(visilabsUser)
        var notifications = [VisilabsInAppNotification]()
        var props = properties
        props["OM.vcap"] = visilabsUser.visitData
        props["OM.viscap"] = visilabsUser.visitorData
        props[VisilabsConstants.nrvKey] = String(visilabsUser.nrv)
        props[VisilabsConstants.pvivKey] = String(visilabsUser.pviv)
        props[VisilabsConstants.tvcKey] = String(visilabsUser.tvc)
        props[VisilabsConstants.lvtKey] = visilabsUser.lvt

        for (key, value) in VisilabsPersistence.readTargetParameters() {
           if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
               props[key] = value
           }
        }
        
        props[VisilabsConstants.pushPermitPermissionReqKey] = VisilabsConstants.pushPermitStatus

        VisilabsRequest.sendInAppNotificationRequest(properties: props,
                                                     headers: headers,
                                                     timeoutInterval: self.visilabsProfile.requestTimeoutInterval,
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

        completion(notifications.first)
    }

    // MARK: - Targeting Actions

    func checkTargetingActions(properties: [String: String],
                                visilabsUser: VisilabsUser,
                                completion: @escaping ((_ response: TargetingActionViewModel?) -> Void)) {

        let semaphore = DispatchSemaphore(value: 0)
        var targetingActionViewModel: TargetingActionViewModel?
        var props = properties
        props["OM.vcap"] = visilabsUser.visitData
        props["OM.viscap"] = visilabsUser.visitorData
        props[VisilabsConstants.nrvKey] = String(visilabsUser.nrv)
        props[VisilabsConstants.pvivKey] = String(visilabsUser.pviv)
        props[VisilabsConstants.tvcKey] = String(visilabsUser.tvc)
        props[VisilabsConstants.lvtKey] = visilabsUser.lvt
        
        
        props[VisilabsConstants.actionType] = "\(VisilabsConstants.mailSubscriptionForm)~\(VisilabsConstants.spinToWin)~\(VisilabsConstants.scratchToWin)~\(VisilabsConstants.productStatNotifier)~\(VisilabsConstants.drawer)"

        for (key, value) in VisilabsPersistence.readTargetParameters() {
           if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
               props[key] = value
           }
        }
        
        props[VisilabsConstants.pushPermitPermissionReqKey] = VisilabsConstants.pushPermitStatus

        VisilabsRequest.sendMobileRequest(properties: props,
                                          headers: prepareHeaders(visilabsUser),
                                          timeoutInterval: self.visilabsProfile.requestTimeoutInterval,
                                          completion: {(result: [String: Any]?, _: VisilabsError?, _: String?) in
            guard let result = result else {
                semaphore.signal()
                completion(nil)
                return
            }
            targetingActionViewModel = self.parseTargetingAction(result)
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        completion(targetingActionViewModel)
    }

    func parseTargetingAction(_ result: [String: Any]?) -> TargetingActionViewModel? {
        guard let result = result else { return nil }
        if let mailFormArr = result[VisilabsConstants.mailSubscriptionForm] as? [[String: Any?]], let mailForm = mailFormArr.first {
            return parseMailForm(mailForm)
        } else if let spinToWinArr = result[VisilabsConstants.spinToWin] as? [[String: Any?]], let spinToWin = spinToWinArr.first {
            return parseSpinToWin(spinToWin)
        } else if let sctwArr = result[VisilabsConstants.scratchToWin] as? [[String: Any?]], let sctw = sctwArr.first {
            return parseScratchToWin(sctw)
        }  else if let drawerArr = result[VisilabsConstants.drawer] as? [[String: Any?]], let drw = drawerArr.first {
            return parseDrawer(drw)
        } else if let psnArr = result[VisilabsConstants.productStatNotifier] as? [[String: Any?]], let psn = psnArr.first {
            if let productStatNotifier = parseProductStatNotifier(psn) {
                if productStatNotifier.attributedString == nil {
                    return nil
                }
                if productStatNotifier.contentCount < productStatNotifier.threshold {
                    VisilabsLogger.warn("Product stat notifier: content count below threshold.")
                    return nil
                }
                return productStatNotifier
            }
        }
        return nil
    }
    
    // MARK: SpinToWin

    private func parseSpinToWin(_ spinToWin: [String: Any?]) -> SpinToWinViewModel? {
        guard let actionData = spinToWin[VisilabsConstants.actionData] as? [String: Any] else { return nil }
        guard let slices = actionData[VisilabsConstants.slices] as? [[String: Any]] else { return nil }
        guard let spinToWinContent = actionData[VisilabsConstants.spinToWinContent] as? [String: Any] else { return nil }
        let encodedStr = actionData[VisilabsConstants.extendedProps] as? String ?? ""
        guard let extendedProps = encodedStr.urlDecode().convertJsonStringToDictionary() else { return nil }
        // guard let report = actionData[VisilabsConstants.report] as? [String: Any] else { return nil } //mail_subscription false olduğu zaman report gelmiyor.

        let taTemplate = actionData[VisilabsConstants.taTemplate] as? String ?? "half_spin"
        let img = actionData[VisilabsConstants.img] as? String ?? ""

        let report = actionData[VisilabsConstants.report] as? [String: Any] ?? [String: Any]()
        let actid = spinToWin[VisilabsConstants.actid] as? Int ?? 0
        let auth = actionData[VisilabsConstants.authentication] as? String ?? ""
        let promoAuth = actionData[VisilabsConstants.promoAuth] as? String ?? ""
        let type = actionData[VisilabsConstants.type] as? String ?? "spin_to_win_email"
        let mailSubscription = actionData[VisilabsConstants.mailSubscription] as? Bool ?? false
        let sliceCount = actionData[VisilabsConstants.sliceCount] as? String ?? ""
        let promocodesSoldoutMessage = actionData[VisilabsConstants.promocodesSoldoutMessage] as? String ?? ""
        // report
        let impression = report[VisilabsConstants.impression] as? String ?? ""
        let click = report[VisilabsConstants.click] as? String ?? ""
        let spinToWinReport = SpinToWinReport(impression: impression, click: click)

        // spin_to_win_content
        let title = spinToWinContent[VisilabsConstants.title] as? String ?? ""
        let message = spinToWinContent[VisilabsConstants.message] as? String ?? ""
        let placeholder = spinToWinContent[VisilabsConstants.placeholder] as? String ?? ""
        let buttonLabel = spinToWinContent[VisilabsConstants.buttonLabel] as? String ?? ""
        let consentText = spinToWinContent[VisilabsConstants.consentText] as? String ?? ""
        let invalidEmailMessage = spinToWinContent[VisilabsConstants.invalidEmailMessage] as? String ?? ""
        let successMessage = spinToWinContent[VisilabsConstants.successMessage] as? String ?? ""
        let emailPermitText = spinToWinContent[VisilabsConstants.emailPermitText] as? String ?? ""
        let checkConsentMessage = spinToWinContent[VisilabsConstants.checkConsentMessage] as? String ?? ""
        let promocodeTitle = actionData[VisilabsConstants.promocodeTitle] as? String ?? ""
        let copybuttonLabel = actionData[VisilabsConstants.copybuttonLabel] as? String ?? ""
        let wheelSpinAction = actionData[VisilabsConstants.wheelSpinAction] as? String ?? ""

        // extended properties
        let displaynameTextColor = extendedProps[VisilabsConstants.displaynameTextColor] as? String ?? ""
        let displaynameFontFamily = extendedProps[VisilabsConstants.displaynameFontFamily] as? String ?? ""
        let displaynameTextSize = extendedProps[VisilabsConstants.displaynameTextSize] as? String ?? ""
        let titleTextColor = extendedProps[VisilabsConstants.titleTextColor] as? String ?? ""
        let titleFontFamily = extendedProps[VisilabsConstants.titleFontFamily] as? String ?? ""
        let titleTextSize = extendedProps[VisilabsConstants.titleTextSize] as? String ?? ""
        let textColor = extendedProps[VisilabsConstants.textColor] as? String ?? ""
        let textFontFamily = extendedProps[VisilabsConstants.textFontFamily] as? String ?? ""
        let textSize = extendedProps[VisilabsConstants.textSize] as? String ?? ""
        let button_color = extendedProps[VisilabsConstants.button_color] as? String ?? ""
        let button_text_color = extendedProps[VisilabsConstants.button_text_color] as? String ?? ""
        let buttonFontFamily = extendedProps[VisilabsConstants.buttonFontFamily] as? String ?? ""
        let buttonTextSize = extendedProps[VisilabsConstants.buttonTextSize] as? String ?? ""
        let promocodeTitleTextColor = extendedProps[VisilabsConstants.promocodeTitleTextColor] as? String ?? ""
        let promocodeTitleFontFamily = extendedProps[VisilabsConstants.promocodeTitleFontFamily] as? String ?? ""
        let promocodeTitleTextSize = extendedProps[VisilabsConstants.promocodeTitleTextSize] as? String ?? ""
        let promocodeBackgroundColor = extendedProps[VisilabsConstants.promocodeBackgroundColor] as? String ?? ""
        let promocodeTextColor = extendedProps[VisilabsConstants.promocodeTextColor] as? String ?? ""
        let copybuttonColor = extendedProps[VisilabsConstants.copybuttonColor] as? String ?? ""
        let copybuttonTextColor = extendedProps[VisilabsConstants.copybuttonTextColor] as? String ?? ""
        let copybuttonFontFamily = extendedProps[VisilabsConstants.copybuttonFontFamily] as? String ?? ""
        let copybuttonTextSize = extendedProps[VisilabsConstants.copybuttonTextSize] as? String ?? ""
        let emailpermitTextSize = extendedProps[VisilabsConstants.emailpermitTextSize] as? String ?? ""
        let emailpermitTextUrl = extendedProps[VisilabsConstants.emailpermitTextUrl] as? String ?? ""
        
        
        let displaynameCustomFontFamilyIos = extendedProps[VisilabsConstants.displaynameCustomFontFamilyIos] as? String ?? ""
        let titleCustomFontFamilyIos = extendedProps[VisilabsConstants.titleCustomFontFamilyIos] as? String ?? ""
        let textCustomFontFamilyIos = extendedProps[VisilabsConstants.textCustomFontFamilyIos] as? String ?? ""
        let buttonCustomFontFamilyIos = extendedProps[VisilabsConstants.buttonCustomFontFamilyIos] as? String ?? ""
        let promocodeTitleCustomFontFamilyIos = extendedProps[VisilabsConstants.promocodeTitleCustomFontFamilyIos] as? String ?? ""
        let copybuttonCustomFontFamilyIos = extendedProps[VisilabsConstants.copybuttonCustomFontFamilyIos] as? String ?? ""
        let promocodesSoldoutMessageCustomFontFamilyIos = extendedProps[VisilabsConstants.promocodesSoldoutMessageCustomFontFamilyIos] as? String ?? ""

        let consentTextSize = extendedProps[VisilabsConstants.consentTextSize] as? String ?? ""
        let consentTextUrl = extendedProps[VisilabsConstants.consentTextUrl] as? String ?? ""
        let closeButtonColor = extendedProps[VisilabsConstants.closeButtonColor] as? String ?? ""
        let backgroundColor = extendedProps[VisilabsConstants.backgroundColor] as? String ?? ""
        
        let wheelBorderWidth = extendedProps[VisilabsConstants.wheelBorderWidth] as? String ?? ""
        let wheelBorderColor = extendedProps[VisilabsConstants.wheelBorderColor] as? String ?? ""
        let sliceDisplaynameFontFamily = extendedProps[VisilabsConstants.sliceDisplaynameFontFamily] as? String ?? ""
        
        
        let promocodesSoldoutMessageTextColor = extendedProps[VisilabsConstants.promocodes_soldout_message_text_color] as? String ?? ""
        let promocodesSoldoutMessageFontFamily = extendedProps[VisilabsConstants.promocodes_soldout_message_font_family] as? String ?? ""
        let promocodesSoldoutMessageTextSize = extendedProps[VisilabsConstants.promocodes_soldout_message_text_size] as? String ?? ""
        let promocodesSoldoutMessageBackgroundColor = extendedProps[VisilabsConstants.promocodes_soldout_message_background_color] as? String ?? ""
        
        let titlePosition = extendedProps[VisilabsConstants.title_position] as? String ?? ""
        let textPosition = extendedProps[VisilabsConstants.text_position] as? String ?? ""
        let buttonPosition = extendedProps[VisilabsConstants.button_position] as? String ?? ""
        let copybuttonPosition = extendedProps[VisilabsConstants.copybutton_position] as? String ?? ""
        
        let promocodeBannerText = extendedProps[VisilabsConstants.promocode_banner_text] as? String ?? ""
        let promocodeBannerTextColor = extendedProps[VisilabsConstants.promocode_banner_text_color] as? String ?? ""
        let promocodeBannerBackgroundColor = extendedProps[VisilabsConstants.promocode_banner_background_color] as? String ?? ""
        let promocodeBannerButtonLabel = extendedProps[VisilabsConstants.promocode_banner_button_label] as? String ?? ""

        var sliceArray = [SpinToWinSliceViewModel]()

        for slice in slices {
            let displayName = slice[VisilabsConstants.displayName] as? String ?? ""
            let color = slice[VisilabsConstants.color] as? String ?? ""
            let code = slice[VisilabsConstants.code] as? String ?? ""
            let type = slice[VisilabsConstants.type] as? String ?? ""
            let isAvailable = slice[VisilabsConstants.isAvailable] as? Bool ?? true
            let spinToWinSliceViewModel = SpinToWinSliceViewModel(displayName: displayName, color: color, code: code, type: type, isAvailable: isAvailable)
            sliceArray.append(spinToWinSliceViewModel)
        }

        let model = SpinToWinViewModel(targetingActionType: .spinToWin, actId: actid, auth: auth, promoAuth: promoAuth, type: type, title: title, message: message, placeholder: placeholder, buttonLabel: buttonLabel, consentText: consentText, emailPermitText: emailPermitText, successMessage: successMessage, invalidEmailMessage: invalidEmailMessage, checkConsentMessage: checkConsentMessage, promocodeTitle: promocodeTitle, copyButtonLabel: copybuttonLabel, mailSubscription: mailSubscription, sliceCount: sliceCount, slices: sliceArray, report: spinToWinReport, taTemplate: taTemplate, img: img, wheelSpinAction: wheelSpinAction, promocodesSoldoutMessage: promocodesSoldoutMessage, displaynameTextColor: displaynameTextColor, displaynameFontFamily: displaynameFontFamily, displaynameTextSize: displaynameTextSize, titleTextColor: titleTextColor, titleFontFamily: titleFontFamily, titleTextSize: titleTextSize, textColor: textColor, textFontFamily: textFontFamily, textSize: textSize, buttonColor: button_color, buttonTextColor: button_text_color, buttonFontFamily: buttonFontFamily, buttonTextSize: buttonTextSize, promocodeTitleTextColor: promocodeTitleTextColor, promocodeTitleFontFamily: promocodeTitleFontFamily, promocodeTitleTextSize: promocodeTitleTextSize, promocodeBackgroundColor: promocodeBackgroundColor, promocodeTextColor: promocodeTextColor, copybuttonColor: copybuttonColor, copybuttonTextColor: copybuttonTextColor, copybuttonFontFamily: copybuttonFontFamily, copybuttonTextSize: copybuttonTextSize, emailpermitTextSize: emailpermitTextSize, emailpermitTextUrl: emailpermitTextUrl, consentTextSize: consentTextSize, consentTextUrl: consentTextUrl, closeButtonColor: closeButtonColor, backgroundColor: backgroundColor,wheelBorderWidth: wheelBorderWidth,wheelBorderColor: wheelBorderColor,sliceDisplaynameFontFamily: sliceDisplaynameFontFamily, promocodesSoldoutMessageTextColor: promocodesSoldoutMessageTextColor, promocodesSoldoutMessageFontFamily: promocodesSoldoutMessageFontFamily, promocodesSoldoutMessageTextSize: promocodesSoldoutMessageTextSize, promocodesSoldoutMessageBackgroundColor: promocodesSoldoutMessageBackgroundColor,displaynameCustomFontFamilyIos:displaynameCustomFontFamilyIos ,titleCustomFontFamilyIos:titleCustomFontFamilyIos,textCustomFontFamilyIos:textCustomFontFamilyIos,buttonCustomFontFamilyIos:buttonCustomFontFamilyIos,promocodeTitleCustomFontFamilyIos:promocodeTitleCustomFontFamilyIos,copybuttonCustomFontFamilyIos:copybuttonCustomFontFamilyIos,promocodesSoldoutMessageCustomFontFamilyIos:promocodesSoldoutMessageCustomFontFamilyIos, titlePosition: titlePosition, textPosition: textPosition, buttonPosition: buttonPosition, copybuttonPosition: copybuttonPosition, promocodeBannerText: promocodeBannerText, promocodeBannerTextColor: promocodeBannerTextColor, promocodeBannerBackgroundColor: promocodeBannerBackgroundColor, promocodeBannerButtonLabel: promocodeBannerButtonLabel)

        return model
    }


    // MARK: ProductStatNotifier

    private func parseProductStatNotifier(_ productStatNotifier: [String: Any?]) -> VisilabsProductStatNotifierViewModel? {
        guard let actionData = productStatNotifier[VisilabsConstants.actionData] as? [String: Any] else { return nil }
        let encodedStr = actionData[VisilabsConstants.extendedProps] as? String ?? ""
        guard let extendedProps = encodedStr.urlDecode().convertJsonStringToDictionary() else { return nil }
        let content = actionData[VisilabsConstants.content] as? String ?? ""
        let timeout = actionData[VisilabsConstants.timeout] as? String ?? ""
        var position = VisilabsProductStatNotifierPosition.bottom
        if let positionString = actionData[VisilabsConstants.pos] as? String, let pos = VisilabsProductStatNotifierPosition.init(rawValue: positionString) {
            position = pos
        }
        let bgcolor = actionData[VisilabsConstants.bgcolor] as? String ?? ""
        let threshold = actionData[VisilabsConstants.threshold] as? Int ?? 0
        let showclosebtn = actionData[VisilabsConstants.showclosebtn] as? Bool ?? false
        
        // extended properties
        let content_text_color = extendedProps[VisilabsConstants.content_text_color] as? String ?? ""
        let content_font_family = extendedProps[VisilabsConstants.content_font_family] as? String ?? ""
        let content_text_size = extendedProps[VisilabsConstants.content_text_size] as? String ?? ""
        let contentcount_text_color = extendedProps[VisilabsConstants.contentcount_text_color] as? String ?? ""
        let contentcount_text_size = extendedProps[VisilabsConstants.contentcount_text_size] as? String ?? ""
        let closeButtonColor = extendedProps[VisilabsConstants.closeButtonColor] as? String ?? "black"
        
        var productStatNotifier = VisilabsProductStatNotifierViewModel(targetingActionType: .productStatNotifier, content: content, timeout: timeout, position: position, bgcolor: bgcolor, threshold: threshold, showclosebtn: showclosebtn, content_text_color: content_text_color, content_font_family: content_font_family, content_text_size: content_text_size, contentcount_text_color: contentcount_text_color, contentcount_text_size: contentcount_text_size, closeButtonColor: closeButtonColor)
        productStatNotifier.setAttributedString()
        return productStatNotifier
    }

    // MARK: MailSubscriptionForm

    private func parseMailForm(_ mailForm: [String: Any?]) -> MailSubscriptionViewModel? {
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
        
        let titleCustomFontFamilyIos = extendedProps[VisilabsConstants.titleCustomFontFamilyIos] as? String ?? ""
        let textCustomFontFamilyIos = extendedProps[VisilabsConstants.textCustomFontFamilyIos] as? String ?? ""
        let buttonCustomFontFamilyIos = extendedProps[VisilabsConstants.buttonCustomFontFamilyIos] as? String ?? ""
        
        let impression = report[VisilabsConstants.impression] as? String ?? ""
        let click = report[VisilabsConstants.click] as? String ?? ""
        let mailReport = TargetingActionReport(impression: impression, click: click)
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
                                                               backgroundColor: backgroundColor,titleCustomFontFamilyIos:titleCustomFontFamilyIos,textCustomFontFamilyIos:textCustomFontFamilyIos,buttonCustomFontFamilyIos:buttonCustomFontFamilyIos)

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

    private func parseDrawer(_ drawer: [String: Any?]) -> SideBarServiceModel? {
        
        guard let actionData = drawer[VisilabsConstants.actionData] as? [String: Any] else { return nil }
        var sideBarServiceModel = SideBarServiceModel(targetingActionType: .drawer)
        sideBarServiceModel.actId = drawer[VisilabsConstants.actid] as? Int ?? 0
        sideBarServiceModel.title = drawer[VisilabsConstants.title] as? String ?? ""
        let encodedStr = actionData[VisilabsConstants.extendedProps] as? String ?? ""
        guard let extendedProps = encodedStr.urlDecode().convertJsonStringToDictionary() else { return nil }

        
        //actionData
        sideBarServiceModel.shape = actionData[VisilabsConstants.shape] as? String ?? ""
        sideBarServiceModel.pos = actionData[VisilabsConstants.position] as? String ?? ""
        sideBarServiceModel.contentMinimizedImage  = actionData[VisilabsConstants.contentMinimizedImage] as? String ?? ""
        sideBarServiceModel.contentMinimizedText = actionData[VisilabsConstants.contentMinimizedText] as? String ?? ""
        sideBarServiceModel.contentMaximizedImage = actionData[VisilabsConstants.contentMaximizedImage] as? String ?? ""
        sideBarServiceModel.waitingTime = actionData[VisilabsConstants.waitingTime] as? Int ?? 0
        sideBarServiceModel.iosLnk = actionData[VisilabsConstants.iosLnk] as? String ?? ""
        
        //extended Props
        sideBarServiceModel.contentMinimizedTextSize = extendedProps[VisilabsConstants.contentMinimizedTextSize] as? String ?? ""
        sideBarServiceModel.contentMinimizedTextColor = extendedProps[VisilabsConstants.contentMinimizedTextColor] as? String ?? ""
        sideBarServiceModel.contentMinimizedFontFamily = extendedProps[VisilabsConstants.contentMinimizedFontFamily] as? String ?? ""
        sideBarServiceModel.contentMinimizedCustomFontFamilyIos = extendedProps[VisilabsConstants.contentMinimizedCustomFontFamilyIos] as? String ?? ""
        sideBarServiceModel.contentMinimizedTextOrientation = extendedProps[VisilabsConstants.contentMinimizedTextOrientation] as? String ?? ""
        sideBarServiceModel.contentMinimizedBackgroundImage = extendedProps[VisilabsConstants.contentMinimizedBackgroundImage] as? String ?? ""
        sideBarServiceModel.contentMinimizedBackgroundColor = extendedProps[VisilabsConstants.contentMinimizedBackgroundColor] as? String ?? ""
        sideBarServiceModel.contentMinimizedArrowColor = extendedProps[VisilabsConstants.contentMinimizedArrowColor] as? String ?? ""
        sideBarServiceModel.contentMaximizedBackgroundImage = extendedProps[VisilabsConstants.contentMaximizedBackgroundImage] as? String ?? ""
        sideBarServiceModel.contentMaximizedBackgroundColor = extendedProps[VisilabsConstants.contentMaximizedBackgroundColor] as? String ?? ""
    

        return sideBarServiceModel
    }
    private func parseScratchToWin(_ scratchToWin: [String: Any?]) -> ScratchToWinModel? {
        guard let actionData = scratchToWin[VisilabsConstants.actionData] as? [String: Any] else { return nil }
        let encodedStr = actionData[VisilabsConstants.extendedProps] as? String ?? ""
        guard let extendedProps = encodedStr.urlDecode().convertJsonStringToDictionary() else { return nil }

        let actid = scratchToWin[VisilabsConstants.actid] as? Int ?? 0
        let auth = actionData[VisilabsConstants.authentication] as? String ?? ""
        let hasMailForm = actionData[VisilabsConstants.mailSubscription] as? Bool ?? false
        let scratchColor = actionData[VisilabsConstants.scratchColor] as? String ?? "000000"
        let waitingTime = actionData[VisilabsConstants.waitingTime] as? Int ?? 0
        let promotionCode = actionData[VisilabsConstants.code] as? String ?? ""
        let sendMail = actionData[VisilabsConstants.sendEmail] as? Bool ?? false
        let copyButtonText = actionData[VisilabsConstants.copybuttonLabel] as? String ?? ""
        let img = actionData[VisilabsConstants.img] as? String ?? ""
        let title = actionData[VisilabsConstants.contentTitle] as? String ?? ""
        let message = actionData[VisilabsConstants.contentBody] as? String ?? ""
        // Email parameters
        var mailPlaceholder: String?
        var mailButtonTxt: String?
        var consentText: String?
        var invalidEmailMsg: String?
        var successMsg: String?
        var emailPermitTxt: String?
        var checkConsentMsg: String?

        if let mailForm = actionData[VisilabsConstants.sctwMailSubscriptionForm] as? [String: Any] {
            mailPlaceholder = mailForm[VisilabsConstants.placeholder] as? String
            mailButtonTxt = mailForm[VisilabsConstants.buttonLabel] as? String
            consentText = mailForm[VisilabsConstants.consentText] as? String
            invalidEmailMsg = mailForm[VisilabsConstants.invalidEmailMessage] as? String
            successMsg = mailForm[VisilabsConstants.successMessage] as? String
            emailPermitTxt = mailForm[VisilabsConstants.emailPermitText] as? String
            checkConsentMsg = mailForm[VisilabsConstants.checkConsentMessage] as? String
        }

        // extended props
        let titleTextColor = extendedProps[VisilabsConstants.contentTitleTextColor] as? String
        let titleFontFamily = extendedProps[VisilabsConstants.contentTitleFontFamily] as? String
        let titleTextSize = extendedProps[VisilabsConstants.contentTitleTextSize] as? String
        let messageTextColor = extendedProps[VisilabsConstants.contentBodyTextColor] as? String
        let messageTextSize = extendedProps[VisilabsConstants.contentBodyTextSize] as? String
        let messageTextFontFamily = extendedProps[VisilabsConstants.contentBodyTextFontFamily] as? String
        let mailButtonColor = extendedProps[VisilabsConstants.button_color] as? String
        let mailButtonTextColor = extendedProps[VisilabsConstants.button_text_color] as? String
        let mailButtonFontFamily = extendedProps[VisilabsConstants.buttonFontFamily] as? String
        let mailButtonTextSize = extendedProps[VisilabsConstants.buttonTextSize] as? String
        let promocodeTextColor = extendedProps[VisilabsConstants.promocodeTextColor] as? String
        let promocodeFontFamily = extendedProps[VisilabsConstants.promocodeFontFamily] as? String
        let promocodeTextSize = extendedProps[VisilabsConstants.promocodeTextSize] as? String
        let copyButtonColor = extendedProps[VisilabsConstants.copybuttonColor] as? String
        let copyButtonTextColor = extendedProps[VisilabsConstants.copybuttonTextColor] as? String
        let copyButtonFontFamily = extendedProps[VisilabsConstants.copybuttonFontFamily] as? String
        let copyButtonTextSize = extendedProps[VisilabsConstants.copybuttonTextSize] as? String
        let emailPermitTextSize = extendedProps[VisilabsConstants.emailPermitTextSize] as? String
        let emailPermitTextUrl = extendedProps[VisilabsConstants.emailPermitTextUrl] as? String
        let consentTextSize = extendedProps[VisilabsConstants.consentTextSize] as? String
        let consentTextUrl = extendedProps[VisilabsConstants.consentTextUrl] as? String
        let closeButtonColor = extendedProps[VisilabsConstants.closeButtonColor] as? String
        let backgroundColor = extendedProps[VisilabsConstants.backgroundColor] as? String

        let contentTitleCustomFontFamilyIos = extendedProps[VisilabsConstants.contentTitleCustomFontFamilyIos] as? String ?? ""
        let contentBodyCustomFontFamilyIos = extendedProps[VisilabsConstants.contentBodyCustomFontFamilyIos] as? String ?? ""
        let buttonCustomFontFamilyIos = extendedProps[VisilabsConstants.buttonCustomFontFamilyIos] as? String ?? ""
        let promocodeCustomFontFamilyIos = extendedProps[VisilabsConstants.promocodeCustomFontFamilyIos] as? String ?? ""
        let copybuttonCustomFontFamilyIos = extendedProps[VisilabsConstants.copybuttonCustomFontFamilyIos] as? String

        
        var click = ""
        var impression = ""
        if let report = actionData[VisilabsConstants.report] as? [String: Any] {
            click = report[VisilabsConstants.click] as? String ?? ""
            impression = report[VisilabsConstants.impression] as? String ?? ""
        }
        let rep = TargetingActionReport(impression: impression, click: click)

        return ScratchToWinModel(type: .scratchToWin,
                                 actid: actid,
                                 auth: auth,
                                 hasMailForm: hasMailForm,
                                 scratchColor: scratchColor,
                                 waitingTime: waitingTime,
                                 promocode: promotionCode,
                                 sendMail: sendMail,
                                 copyButtonText: copyButtonText,
                                 imageUrlString: img,
                                 title: title,
                                 message: message,
                                 mailPlaceholder: mailPlaceholder,
                                 mailButtonText: mailButtonTxt,
                                 consentText: consentText,
                                 invalidEmailMsg: invalidEmailMsg,
                                 successMessage: successMsg,
                                 emailPermitText: emailPermitTxt,
                                 checkConsentMessage: checkConsentMsg,
                                 titleTextColor: titleTextColor,
                                 titleFontFamily: titleFontFamily,
                                 titleTextSize: titleTextSize,
                                 messageTextColor: messageTextColor,
                                 messageFontFamily: messageTextFontFamily,
                                 messageTextSize: messageTextSize,
                                 mailButtonColor: mailButtonColor,
                                 mailButtonTextColor: mailButtonTextColor,
                                 mailButtonFontFamily: mailButtonFontFamily,
                                 mailButtonTextSize: mailButtonTextSize,
                                 promocodeTextColor: promocodeTextColor,
                                 promocodeTextFamily: promocodeFontFamily,
                                 promocodeTextSize: promocodeTextSize,
                                 copyButtonColor: copyButtonColor,
                                 copyButtonTextColor: copyButtonTextColor,
                                 copyButtonFontFamily: copyButtonFontFamily,
                                 copyButtonTextSize: copyButtonTextSize,
                                 emailPermitTextSize: emailPermitTextSize,
                                 emailPermitUrl: emailPermitTextUrl,
                                 consentTextSize: consentTextSize,
                                 consentUrl: consentTextUrl,
                                 closeButtonColor: closeButtonColor,
                                 backgroundColor: backgroundColor,
                                 report: rep,
                                 contentTitleCustomFontFamilyIos:contentTitleCustomFontFamilyIos,
                                 contentBodyCustomFontFamilyIos:contentBodyCustomFontFamilyIos,
                                 buttonCustomFontFamilyIos:buttonCustomFontFamilyIos,
                                 promocodeCustomFontFamilyIos:promocodeCustomFontFamilyIos,
                                 copybuttonCustomFontFamilyIos:copybuttonCustomFontFamilyIos)
    }

    private func convertJsonToEmailViewModel(emailForm: MailSubscriptionModel) -> MailSubscriptionViewModel {
        var parsedConsent: ParsedPermissionString?
        if let consent = emailForm.consentText, !consent.isEmpty {
            parsedConsent = consent.parsePermissionText()
        }
        let parsedPermit = emailForm.emailPermitText.parsePermissionText()
        let titleFont = VisilabsHelper.getFont(fontFamily: emailForm.extendedProps.titleFontFamily,
                                                          fontSize: emailForm.extendedProps.titleTextSize,
                                                          style: .title2,customFont: emailForm.extendedProps.titleCustomFontFamilyIos)
        let messageFont = VisilabsHelper.getFont(fontFamily: emailForm.extendedProps.textFontFamily,
                                                            fontSize: emailForm.extendedProps.textSize,
                                                            style: .body,customFont: emailForm.extendedProps.textCustomFontFamilyIos)
        let buttonFont = VisilabsHelper.getFont(fontFamily: emailForm.extendedProps.buttonFontFamily,
                                                           fontSize: emailForm.extendedProps.buttonTextSize,
                                                           style: .title2,customFont: emailForm.extendedProps.buttonCustomFontFamilyIos)
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
        let viewModel = MailSubscriptionViewModel(targetingActionType: .mailSubscriptionForm,
                                                  auth: emailForm.auth,
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

    // MARK: - Favorites

    // class func sendMobileRequest(properties: [String : String],
    // headers: [String : String], timeoutInterval: TimeInterval, completion: @escaping ([String: Any]?) -> Void) {
    //https://s.visilabs.net/mobile?OM.oid=676D325830564761676D453D&OM
    // .siteID=356467332F6533766975593D&OM.cookieID=B220EC66-A746-4130-93FD-53543055E406&
    // OM.exVisitorID=ogun.ozturk%40euromsg.com&action_id=188&action_type=FavoriteAttributeAction&OM.apiver=IOS
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
        
        
        props[VisilabsConstants.nrvKey] = String(visilabsUser.nrv)
        props[VisilabsConstants.pvivKey] = String(visilabsUser.pviv)
        props[VisilabsConstants.tvcKey] = String(visilabsUser.tvc)
        props[VisilabsConstants.lvtKey] = visilabsUser.lvt

        for (key, value) in VisilabsPersistence.readTargetParameters() {
           if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
               props[key] = value
           }
        }

        VisilabsRequest.sendMobileRequest(properties: props, headers: [String: String](),
                                          timeoutInterval: self.visilabsProfile.requestTimeoutInterval,
                                          completion: { (result: [String: Any]?, error: VisilabsError?, _: String?) in
            completion(self.parseFavoritesResponse(result, error))
        })
    }

    // {"capping":"{\"data\":{}}","VERSION":1,"FavoriteAttributeAction:
    // [{"actid":188,"title":"fav-test","actiontype":"FavoriteAttributeAction",
    // "actiondata":{"attributes":["category","brand"],"favorites":{"category":["6","8","2"],
    // "brand":["Kozmo","Luxury Room","OFS"]}}}]}
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
        props[VisilabsConstants.channelKey] = self.visilabsProfile.channel
        props[VisilabsConstants.actionId] = actionId == nil ? nil : String(actionId!)
        
        props[VisilabsConstants.nrvKey] = String(visilabsUser.nrv)
        props[VisilabsConstants.pvivKey] = String(visilabsUser.pviv)
        props[VisilabsConstants.tvcKey] = String(visilabsUser.tvc)
        props[VisilabsConstants.lvtKey] = visilabsUser.lvt

        for (key, value) in VisilabsPersistence.readTargetParameters() {
           if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
               props[key] = value
           }
        }

        VisilabsRequest.sendMobileRequest(properties: props,
                                          headers: [String: String](),
                                          timeoutInterval: self.visilabsProfile.requestTimeoutInterval,
                                          completion: {(result: [String: Any]?, error: VisilabsError?, guid: String?) in
            completion(self.parseStories(result, error, guid))
        }, guid: guid)
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    // TO_DO: burada storiesResponse kısmı değiştirilmeli. aynı requestte birden fazla story action'ı gelebilir.
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
                                            link: story[VisilabsConstants.link] as? String, items: storyItems, actid: actionId))
                                        }
                                    }
                                } else {
                                    visilabsStories.append(VisilabsStory(title: story[VisilabsConstants.title]
                                                                            as? String,
                                    smallImg: story[VisilabsConstants.smallImg] as? String,
                                    link: story[VisilabsConstants.link] as? String, actid: actionId))
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
        // clickItems[VisilabsConstants.domainkey] =  "\(self.visilabsProfile.dataSource)_IOS" // TO_DO: OM.domain ne için gerekiyor?
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

    // swiftlint:disable cyclomatic_complexity
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
            let storyzLabelColor = extendedProps[VisilabsConstants.storyzLabelColor] as? String ?? ""
            props.storyzLabelColor = storyzLabelColor
            storyCustomVariables.shared.storyzLabelColor = storyzLabelColor

            let fontFamily = extendedProps[VisilabsConstants.fontFamily] as? String ?? ""
            props.fontFamily = fontFamily
            storyCustomVariables.shared.fontFamily = fontFamily


            let customFontFamilyIos = extendedProps[VisilabsConstants.customFontFamilyIos] as? String ?? ""
            props.customFontFamilyIos = customFontFamilyIos
            storyCustomVariables.shared.customFontFamilyIos = customFontFamilyIos

            
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

            if let moveEnd = extendedProps[VisilabsConstants.moveShownToEnd] as? String, moveEnd.lowercased() == "false" {
                props.moveShownToEnd = false
            } else {
                props.moveShownToEnd = true
            }
        }
        return props
    }

}
