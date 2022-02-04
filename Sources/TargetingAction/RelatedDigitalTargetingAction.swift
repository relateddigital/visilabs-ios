//
//  VisilabsTargetingAction.swift
//  VisilabsIOS
//
//  Created by Egemen on 18.08.2020.
//

import UIKit
// swiftlint:disable type_body_length
class RelatedDigitalTargetingAction {

    let visilabsProfile: VisilabsProfile

    required init(lock: RelatedDigitalReadWriteLock, visilabsProfile: VisilabsProfile) {
        self.notificationsInstance = RelatedDigitalInAppNotifications(lock: lock)
        self.visilabsProfile = visilabsProfile
    }

    private func prepareHeaders(_ visilabsUser: VisilabsUser) -> [String: String] {
        var headers = [String: String]()
        headers["User-Agent"] = visilabsUser.userAgent
        return headers
    }

    // MARK: - InApp Notifications

    var notificationsInstance: RelatedDigitalInAppNotifications

    var inAppDelegate: RelatedDigitalInAppNotificationsDelegate? {
        get {
            return notificationsInstance.delegate
        }
        set {
            notificationsInstance.delegate = newValue
        }
    }

    func checkInAppNotification(properties: [String: String],
                                visilabsUser: VisilabsUser,
                                completion: @escaping ((_ response: RelatedDigitalInAppNotification?) -> Void)) {
        let semaphore = DispatchSemaphore(value: 0)
        let headers = prepareHeaders(visilabsUser)
        var notifications = [RelatedDigitalInAppNotification]()
        var props = properties
        props["OM.vcap"] = visilabsUser.visitData
        props["OM.viscap"] = visilabsUser.visitorData
        props[RelatedDigitalConstants.nrvKey] = String(visilabsUser.nrv)
        props[RelatedDigitalConstants.pvivKey] = String(visilabsUser.pviv)
        props[RelatedDigitalConstants.tvcKey] = String(visilabsUser.tvc)
        props[RelatedDigitalConstants.lvtKey] = visilabsUser.lvt

        for (key, value) in RelatedDigitalPersistence.readTargetParameters() {
           if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
               props[key] = value
           }
        }
        
        props[RelatedDigitalConstants.pushPermitPermissionReqKey] = RelatedDigitalConstants.pushPermitStatus

        RelatedDigitalRequest.sendInAppNotificationRequest(properties: props,
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
                       RelatedDigitalInAppNotificationType(rawValue: typeString) != nil,
                       let notification = RelatedDigitalInAppNotification(JSONObject: rawNotif) {
                        notifications.append(notification)
                    }
                }
            }
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        RelatedDigitalLogger.info("in app notification check: \(notifications.count) found." +
                            " actid's: \(notifications.map({String($0.actId)}).joined(separator: ","))")

        self.notificationsInstance.inAppNotification = notifications.first
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
        props[RelatedDigitalConstants.nrvKey] = String(visilabsUser.nrv)
        props[RelatedDigitalConstants.pvivKey] = String(visilabsUser.pviv)
        props[RelatedDigitalConstants.tvcKey] = String(visilabsUser.tvc)
        props[RelatedDigitalConstants.lvtKey] = visilabsUser.lvt
        
        
        props[RelatedDigitalConstants.actionType] = "\(RelatedDigitalConstants.mailSubscriptionForm)~\(RelatedDigitalConstants.spinToWin)~\(RelatedDigitalConstants.scratchToWin)~\(RelatedDigitalConstants.productStatNotifier)"

        for (key, value) in RelatedDigitalPersistence.readTargetParameters() {
           if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
               props[key] = value
           }
        }
        
        props[RelatedDigitalConstants.pushPermitPermissionReqKey] = RelatedDigitalConstants.pushPermitStatus

        RelatedDigitalRequest.sendMobileRequest(properties: props,
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
        if let mailFormArr = result[RelatedDigitalConstants.mailSubscriptionForm] as? [[String: Any?]], let mailForm = mailFormArr.first {
            return parseMailForm(mailForm)
        } else if let spinToWinArr = result[RelatedDigitalConstants.spinToWin] as? [[String: Any?]], let spinToWin = spinToWinArr.first {
            return parseSpinToWin(spinToWin)
        } else if let sctwArr = result[RelatedDigitalConstants.scratchToWin] as? [[String: Any?]], let sctw = sctwArr.first {
            return parseScratchToWin(sctw)
        } else if let psnArr = result[RelatedDigitalConstants.productStatNotifier] as? [[String: Any?]], let psn = psnArr.first {
            if let productStatNotifier = parseProductStatNotifier(psn) {
                if productStatNotifier.attributedString == nil {
                    return nil
                }
                if productStatNotifier.contentCount < productStatNotifier.threshold {
                    RelatedDigitalLogger.warn("Product stat notifier: content count below threshold.")
                    return nil
                }
                return productStatNotifier
            }
        }
        return nil
    }
    
    // MARK: SpinToWin

    private func parseSpinToWin(_ spinToWin: [String: Any?]) -> SpinToWinViewModel? {
        guard let actionData = spinToWin[RelatedDigitalConstants.actionData] as? [String: Any] else { return nil }
        guard let slices = actionData[RelatedDigitalConstants.slices] as? [[String: Any]] else { return nil }
        guard let spinToWinContent = actionData[RelatedDigitalConstants.spinToWinContent] as? [String: Any] else { return nil }
        let encodedStr = actionData[RelatedDigitalConstants.extendedProps] as? String ?? ""
        guard let extendedProps = encodedStr.urlDecode().convertJsonStringToDictionary() else { return nil }
        // guard let report = actionData[VisilabsConstants.report] as? [String: Any] else { return nil } //mail_subscription false olduğu zaman report gelmiyor.

        let taTemplate = actionData[RelatedDigitalConstants.taTemplate] as? String ?? "half_spin"
        let img = actionData[RelatedDigitalConstants.img] as? String ?? ""

        let report = actionData[RelatedDigitalConstants.report] as? [String: Any] ?? [String: Any]()
        let actid = spinToWin[RelatedDigitalConstants.actid] as? Int ?? 0
        let auth = actionData[RelatedDigitalConstants.authentication] as? String ?? ""
        let promoAuth = actionData[RelatedDigitalConstants.promoAuth] as? String ?? ""
        let type = actionData[RelatedDigitalConstants.type] as? String ?? "spin_to_win_email"
        let mailSubscription = actionData[RelatedDigitalConstants.mailSubscription] as? Bool ?? false
        let sliceCount = actionData[RelatedDigitalConstants.sliceCount] as? String ?? ""
        let promocodesSoldoutMessage = actionData[RelatedDigitalConstants.promocodesSoldoutMessage] as? String ?? ""
        // report
        let impression = report[RelatedDigitalConstants.impression] as? String ?? ""
        let click = report[RelatedDigitalConstants.click] as? String ?? ""
        let spinToWinReport = SpinToWinReport(impression: impression, click: click)

        // spin_to_win_content
        let title = spinToWinContent[RelatedDigitalConstants.title] as? String ?? ""
        let message = spinToWinContent[RelatedDigitalConstants.message] as? String ?? ""
        let placeholder = spinToWinContent[RelatedDigitalConstants.placeholder] as? String ?? ""
        let buttonLabel = spinToWinContent[RelatedDigitalConstants.buttonLabel] as? String ?? ""
        let consentText = spinToWinContent[RelatedDigitalConstants.consentText] as? String ?? ""
        let invalidEmailMessage = spinToWinContent[RelatedDigitalConstants.invalidEmailMessage] as? String ?? ""
        let successMessage = spinToWinContent[RelatedDigitalConstants.successMessage] as? String ?? ""
        let emailPermitText = spinToWinContent[RelatedDigitalConstants.emailPermitText] as? String ?? ""
        let checkConsentMessage = spinToWinContent[RelatedDigitalConstants.checkConsentMessage] as? String ?? ""
        let promocodeTitle = actionData[RelatedDigitalConstants.promocodeTitle] as? String ?? ""
        let copybuttonLabel = actionData[RelatedDigitalConstants.copybuttonLabel] as? String ?? ""
        let wheelSpinAction = actionData[RelatedDigitalConstants.wheelSpinAction] as? String ?? ""

        // extended properties
        let displaynameTextColor = extendedProps[RelatedDigitalConstants.displaynameTextColor] as? String ?? ""
        let displaynameFontFamily = extendedProps[RelatedDigitalConstants.displaynameFontFamily] as? String ?? ""
        let displaynameTextSize = extendedProps[RelatedDigitalConstants.displaynameTextSize] as? String ?? ""
        let titleTextColor = extendedProps[RelatedDigitalConstants.titleTextColor] as? String ?? ""
        let titleFontFamily = extendedProps[RelatedDigitalConstants.titleFontFamily] as? String ?? ""
        let titleTextSize = extendedProps[RelatedDigitalConstants.titleTextSize] as? String ?? ""
        let textColor = extendedProps[RelatedDigitalConstants.textColor] as? String ?? ""
        let textFontFamily = extendedProps[RelatedDigitalConstants.textFontFamily] as? String ?? ""
        let textSize = extendedProps[RelatedDigitalConstants.textSize] as? String ?? ""
        let button_color = extendedProps[RelatedDigitalConstants.button_color] as? String ?? ""
        let button_text_color = extendedProps[RelatedDigitalConstants.button_text_color] as? String ?? ""
        let buttonFontFamily = extendedProps[RelatedDigitalConstants.buttonFontFamily] as? String ?? ""
        let buttonTextSize = extendedProps[RelatedDigitalConstants.buttonTextSize] as? String ?? ""
        let promocodeTitleTextColor = extendedProps[RelatedDigitalConstants.promocodeTitleTextColor] as? String ?? ""
        let promocodeTitleFontFamily = extendedProps[RelatedDigitalConstants.promocodeTitleFontFamily] as? String ?? ""
        let promocodeTitleTextSize = extendedProps[RelatedDigitalConstants.promocodeTitleTextSize] as? String ?? ""
        let promocodeBackgroundColor = extendedProps[RelatedDigitalConstants.promocodeBackgroundColor] as? String ?? ""
        let promocodeTextColor = extendedProps[RelatedDigitalConstants.promocodeTextColor] as? String ?? ""
        let copybuttonColor = extendedProps[RelatedDigitalConstants.copybuttonColor] as? String ?? ""
        let copybuttonTextColor = extendedProps[RelatedDigitalConstants.copybuttonTextColor] as? String ?? ""
        let copybuttonFontFamily = extendedProps[RelatedDigitalConstants.copybuttonFontFamily] as? String ?? ""
        let copybuttonTextSize = extendedProps[RelatedDigitalConstants.copybuttonTextSize] as? String ?? ""
        let emailpermitTextSize = extendedProps[RelatedDigitalConstants.emailpermitTextSize] as? String ?? ""
        let emailpermitTextUrl = extendedProps[RelatedDigitalConstants.emailpermitTextUrl] as? String ?? ""
        
        
        let displaynameCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.displaynameCustomFontFamilyIos] as? String ?? ""
        let titleCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.titleCustomFontFamilyIos] as? String ?? ""
        let textCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.textCustomFontFamilyIos] as? String ?? ""
        let buttonCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.buttonCustomFontFamilyIos] as? String ?? ""
        let promocodeTitleCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.promocodeTitleCustomFontFamilyIos] as? String ?? ""
        let copybuttonCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.copybuttonCustomFontFamilyIos] as? String ?? ""
        let promocodesSoldoutMessageCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.promocodesSoldoutMessageCustomFontFamilyIos] as? String ?? ""

        let consentTextSize = extendedProps[RelatedDigitalConstants.consentTextSize] as? String ?? ""
        let consentTextUrl = extendedProps[RelatedDigitalConstants.consentTextUrl] as? String ?? ""
        let closeButtonColor = extendedProps[RelatedDigitalConstants.closeButtonColor] as? String ?? ""
        let backgroundColor = extendedProps[RelatedDigitalConstants.backgroundColor] as? String ?? ""
        
        let wheelBorderWidth = extendedProps[RelatedDigitalConstants.wheelBorderWidth] as? String ?? ""
        let wheelBorderColor = extendedProps[RelatedDigitalConstants.wheelBorderColor] as? String ?? ""
        let sliceDisplaynameFontFamily = extendedProps[RelatedDigitalConstants.sliceDisplaynameFontFamily] as? String ?? ""
        
        
        let promocodesSoldoutMessageTextColor = extendedProps[RelatedDigitalConstants.promocodes_soldout_message_text_color] as? String ?? ""
        let promocodesSoldoutMessageFontFamily = extendedProps[RelatedDigitalConstants.promocodes_soldout_message_font_family] as? String ?? ""
        let promocodesSoldoutMessageTextSize = extendedProps[RelatedDigitalConstants.promocodes_soldout_message_text_size] as? String ?? ""
        let promocodesSoldoutMessageBackgroundColor = extendedProps[RelatedDigitalConstants.promocodes_soldout_message_background_color] as? String ?? ""

        var sliceArray = [SpinToWinSliceViewModel]()

        for slice in slices {
            let displayName = slice[RelatedDigitalConstants.displayName] as? String ?? ""
            let color = slice[RelatedDigitalConstants.color] as? String ?? ""
            let code = slice[RelatedDigitalConstants.code] as? String ?? ""
            let type = slice[RelatedDigitalConstants.type] as? String ?? ""
            let isAvailable = slice[RelatedDigitalConstants.isAvailable] as? Bool ?? true
            let spinToWinSliceViewModel = SpinToWinSliceViewModel(displayName: displayName, color: color, code: code, type: type, isAvailable: isAvailable)
            sliceArray.append(spinToWinSliceViewModel)
        }

        let model = SpinToWinViewModel(targetingActionType: .spinToWin, actId: actid, auth: auth, promoAuth: promoAuth, type: type, title: title, message: message, placeholder: placeholder, buttonLabel: buttonLabel, consentText: consentText, emailPermitText: emailPermitText, successMessage: successMessage, invalidEmailMessage: invalidEmailMessage, checkConsentMessage: checkConsentMessage, promocodeTitle: promocodeTitle, copyButtonLabel: copybuttonLabel, mailSubscription: mailSubscription, sliceCount: sliceCount, slices: sliceArray, report: spinToWinReport, taTemplate: taTemplate, img: img, wheelSpinAction: wheelSpinAction, promocodesSoldoutMessage: promocodesSoldoutMessage, displaynameTextColor: displaynameTextColor, displaynameFontFamily: displaynameFontFamily, displaynameTextSize: displaynameTextSize, titleTextColor: titleTextColor, titleFontFamily: titleFontFamily, titleTextSize: titleTextSize, textColor: textColor, textFontFamily: textFontFamily, textSize: textSize, buttonColor: button_color, buttonTextColor: button_text_color, buttonFontFamily: buttonFontFamily, buttonTextSize: buttonTextSize, promocodeTitleTextColor: promocodeTitleTextColor, promocodeTitleFontFamily: promocodeTitleFontFamily, promocodeTitleTextSize: promocodeTitleTextSize, promocodeBackgroundColor: promocodeBackgroundColor, promocodeTextColor: promocodeTextColor, copybuttonColor: copybuttonColor, copybuttonTextColor: copybuttonTextColor, copybuttonFontFamily: copybuttonFontFamily, copybuttonTextSize: copybuttonTextSize, emailpermitTextSize: emailpermitTextSize, emailpermitTextUrl: emailpermitTextUrl, consentTextSize: consentTextSize, consentTextUrl: consentTextUrl, closeButtonColor: closeButtonColor, backgroundColor: backgroundColor,wheelBorderWidth: wheelBorderWidth,wheelBorderColor: wheelBorderColor,sliceDisplaynameFontFamily: sliceDisplaynameFontFamily, promocodesSoldoutMessageTextColor: promocodesSoldoutMessageTextColor, promocodesSoldoutMessageFontFamily: promocodesSoldoutMessageFontFamily, promocodesSoldoutMessageTextSize: promocodesSoldoutMessageTextSize, promocodesSoldoutMessageBackgroundColor: promocodesSoldoutMessageBackgroundColor,displaynameCustomFontFamilyIos:displaynameCustomFontFamilyIos ,titleCustomFontFamilyIos:titleCustomFontFamilyIos,textCustomFontFamilyIos:textCustomFontFamilyIos,buttonCustomFontFamilyIos:buttonCustomFontFamilyIos,promocodeTitleCustomFontFamilyIos:promocodeTitleCustomFontFamilyIos,copybuttonCustomFontFamilyIos:copybuttonCustomFontFamilyIos,promocodesSoldoutMessageCustomFontFamilyIos:promocodesSoldoutMessageCustomFontFamilyIos)

        return model
    }


    // MARK: ProductStatNotifier

    private func parseProductStatNotifier(_ productStatNotifier: [String: Any?]) -> RelatedDigitalProductStatNotifierViewModel? {
        guard let actionData = productStatNotifier[RelatedDigitalConstants.actionData] as? [String: Any] else { return nil }
        let encodedStr = actionData[RelatedDigitalConstants.extendedProps] as? String ?? ""
        guard let extendedProps = encodedStr.urlDecode().convertJsonStringToDictionary() else { return nil }
        let content = actionData[RelatedDigitalConstants.content] as? String ?? ""
        let timeout = actionData[RelatedDigitalConstants.timeout] as? String ?? ""
        var position = VisilabsProductStatNotifierPosition.bottom
        if let positionString = actionData[RelatedDigitalConstants.pos] as? String, let pos = VisilabsProductStatNotifierPosition.init(rawValue: positionString) {
            position = pos
        }
        let bgcolor = actionData[RelatedDigitalConstants.bgcolor] as? String ?? ""
        let threshold = actionData[RelatedDigitalConstants.threshold] as? Int ?? 0
        let showclosebtn = actionData[RelatedDigitalConstants.showclosebtn] as? Bool ?? false
        
        // extended properties
        let content_text_color = extendedProps[RelatedDigitalConstants.content_text_color] as? String ?? ""
        let content_font_family = extendedProps[RelatedDigitalConstants.content_font_family] as? String ?? ""
        let content_text_size = extendedProps[RelatedDigitalConstants.content_text_size] as? String ?? ""
        let contentcount_text_color = extendedProps[RelatedDigitalConstants.contentcount_text_color] as? String ?? ""
        let contentcount_text_size = extendedProps[RelatedDigitalConstants.contentcount_text_size] as? String ?? ""
        let closeButtonColor = extendedProps[RelatedDigitalConstants.closeButtonColor] as? String ?? "black"
        
        var productStatNotifier = RelatedDigitalProductStatNotifierViewModel(targetingActionType: .productStatNotifier, content: content, timeout: timeout, position: position, bgcolor: bgcolor, threshold: threshold, showclosebtn: showclosebtn, content_text_color: content_text_color, content_font_family: content_font_family, content_text_size: content_text_size, contentcount_text_color: contentcount_text_color, contentcount_text_size: contentcount_text_size, closeButtonColor: closeButtonColor)
        productStatNotifier.setAttributedString()
        return productStatNotifier
    }

    // MARK: MailSubscriptionForm

    private func parseMailForm(_ mailForm: [String: Any?]) -> MailSubscriptionViewModel? {
        guard let actionData = mailForm[RelatedDigitalConstants.actionData] as? [String: Any] else { return nil }
        let encodedStr = actionData[RelatedDigitalConstants.extendedProps] as? String ?? ""
        guard let extendedProps = encodedStr.urlDecode().convertJsonStringToDictionary() else { return nil }
        guard let report = actionData[RelatedDigitalConstants.report] as? [String: Any] else { return nil }
        let title = actionData[RelatedDigitalConstants.title] as? String ?? ""
        let message = actionData[RelatedDigitalConstants.message] as? String ?? ""
        let actid = mailForm[RelatedDigitalConstants.actid] as? Int ?? 0
        let type = actionData[RelatedDigitalConstants.type] as? String ?? "subscription_email"
        let buttonText = actionData[RelatedDigitalConstants.buttonLabel] as? String ?? ""
        let auth = actionData[RelatedDigitalConstants.authentication] as? String ?? ""
        let consentText = actionData[RelatedDigitalConstants.consentText] as? String
        let successMsg = actionData[RelatedDigitalConstants.successMessage] as? String ?? ""
        let invalidMsg = actionData[RelatedDigitalConstants.invalidEmailMessage] as? String ?? ""
        let emailPermitText = actionData[RelatedDigitalConstants.emailPermitText] as? String ?? ""
        let checkConsent = actionData[RelatedDigitalConstants.checkConsentMessage] as? String ?? ""
        let placeholder = actionData[RelatedDigitalConstants.placeholder] as? String ?? ""

        let titleTextColor = extendedProps[RelatedDigitalConstants.titleTextColor] as? String ?? ""
        let titleFontFamily = extendedProps[RelatedDigitalConstants.titleFontFamily] as? String ?? ""
        let titleTextSize = extendedProps[RelatedDigitalConstants.titleTextSize] as? String ?? ""
        let textColor = extendedProps[RelatedDigitalConstants.textColor] as? String ?? ""
        let textFontFamily = extendedProps[RelatedDigitalConstants.textFontFamily] as? String ?? ""
        let textSize = extendedProps[RelatedDigitalConstants.textSize] as? String ?? ""
        let buttonColor = extendedProps[RelatedDigitalInAppNotification.PayloadKey.buttonColor] as? String ?? ""
        let buttonTextColor = extendedProps[RelatedDigitalInAppNotification.PayloadKey.buttonTextColor] as? String ?? ""
        let buttonTextSize = extendedProps[RelatedDigitalConstants.buttonTextSize] as? String ?? ""
        let buttonFontFamily = extendedProps[RelatedDigitalConstants.buttonFontFamily] as? String ?? ""
        let emailPermitTextSize = extendedProps[RelatedDigitalConstants.emailPermitTextSize] as? String ?? ""
        let emailPermitTextUrl = extendedProps[RelatedDigitalConstants.emailPermitTextUrl] as? String ?? ""
        let consentTextSize = extendedProps[RelatedDigitalConstants.consentTextSize] as? String ?? ""
        let consentTextUrl = extendedProps[RelatedDigitalConstants.consentTextUrl] as? String ?? ""
        let closeButtonColor = extendedProps[RelatedDigitalConstants.closeButtonColor] as? String ?? "black"
        let backgroundColor = extendedProps[RelatedDigitalConstants.backgroundColor] as? String ?? ""
        
        let titleCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.titleCustomFontFamilyIos] as? String ?? ""
        let textCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.textCustomFontFamilyIos] as? String ?? ""
        let buttonCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.buttonCustomFontFamilyIos] as? String ?? ""
        
        let impression = report[RelatedDigitalConstants.impression] as? String ?? ""
        let click = report[RelatedDigitalConstants.click] as? String ?? ""
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

    private func parseScratchToWin(_ scratchToWin: [String: Any?]) -> ScratchToWinModel? {
        guard let actionData = scratchToWin[RelatedDigitalConstants.actionData] as? [String: Any] else { return nil }
        let encodedStr = actionData[RelatedDigitalConstants.extendedProps] as? String ?? ""
        guard let extendedProps = encodedStr.urlDecode().convertJsonStringToDictionary() else { return nil }

        let actid = scratchToWin[RelatedDigitalConstants.actid] as? Int ?? 0
        let auth = actionData[RelatedDigitalConstants.authentication] as? String ?? ""
        let hasMailForm = actionData[RelatedDigitalConstants.mailSubscription] as? Bool ?? false
        let scratchColor = actionData[RelatedDigitalConstants.scratchColor] as? String ?? "000000"
        let waitingTime = actionData[RelatedDigitalConstants.waitingTime] as? Int ?? 0
        let promotionCode = actionData[RelatedDigitalConstants.code] as? String ?? ""
        let sendMail = actionData[RelatedDigitalConstants.sendEmail] as? Bool ?? false
        let copyButtonText = actionData[RelatedDigitalConstants.copybuttonLabel] as? String ?? ""
        let img = actionData[RelatedDigitalConstants.img] as? String ?? ""
        let title = actionData[RelatedDigitalConstants.contentTitle] as? String ?? ""
        let message = actionData[RelatedDigitalConstants.contentBody] as? String ?? ""
        // Email parameters
        var mailPlaceholder: String?
        var mailButtonTxt: String?
        var consentText: String?
        var invalidEmailMsg: String?
        var successMsg: String?
        var emailPermitTxt: String?
        var checkConsentMsg: String?

        if let mailForm = actionData[RelatedDigitalConstants.sctwMailSubscriptionForm] as? [String: Any] {
            mailPlaceholder = mailForm[RelatedDigitalConstants.placeholder] as? String
            mailButtonTxt = mailForm[RelatedDigitalConstants.buttonLabel] as? String
            consentText = mailForm[RelatedDigitalConstants.consentText] as? String
            invalidEmailMsg = mailForm[RelatedDigitalConstants.invalidEmailMessage] as? String
            successMsg = mailForm[RelatedDigitalConstants.successMessage] as? String
            emailPermitTxt = mailForm[RelatedDigitalConstants.emailPermitText] as? String
            checkConsentMsg = mailForm[RelatedDigitalConstants.checkConsentMessage] as? String
        }

        // extended props
        let titleTextColor = extendedProps[RelatedDigitalConstants.contentTitleTextColor] as? String
        let titleFontFamily = extendedProps[RelatedDigitalConstants.contentTitleFontFamily] as? String
        let titleTextSize = extendedProps[RelatedDigitalConstants.contentTitleTextSize] as? String
        let messageTextColor = extendedProps[RelatedDigitalConstants.contentBodyTextColor] as? String
        let messageTextSize = extendedProps[RelatedDigitalConstants.contentBodyTextSize] as? String
        let messageTextFontFamily = extendedProps[RelatedDigitalConstants.contentBodyTextFontFamily] as? String
        let mailButtonColor = extendedProps[RelatedDigitalConstants.button_color] as? String
        let mailButtonTextColor = extendedProps[RelatedDigitalConstants.button_text_color] as? String
        let mailButtonFontFamily = extendedProps[RelatedDigitalConstants.buttonFontFamily] as? String
        let mailButtonTextSize = extendedProps[RelatedDigitalConstants.buttonTextSize] as? String
        let promocodeTextColor = extendedProps[RelatedDigitalConstants.promocodeTextColor] as? String
        let promocodeFontFamily = extendedProps[RelatedDigitalConstants.promocodeFontFamily] as? String
        let promocodeTextSize = extendedProps[RelatedDigitalConstants.promocodeTextSize] as? String
        let copyButtonColor = extendedProps[RelatedDigitalConstants.copybuttonColor] as? String
        let copyButtonTextColor = extendedProps[RelatedDigitalConstants.copybuttonTextColor] as? String
        let copyButtonFontFamily = extendedProps[RelatedDigitalConstants.copybuttonFontFamily] as? String
        let copyButtonTextSize = extendedProps[RelatedDigitalConstants.copybuttonTextSize] as? String
        let emailPermitTextSize = extendedProps[RelatedDigitalConstants.emailPermitTextSize] as? String
        let emailPermitTextUrl = extendedProps[RelatedDigitalConstants.emailPermitTextUrl] as? String
        let consentTextSize = extendedProps[RelatedDigitalConstants.consentTextSize] as? String
        let consentTextUrl = extendedProps[RelatedDigitalConstants.consentTextUrl] as? String
        let closeButtonColor = extendedProps[RelatedDigitalConstants.closeButtonColor] as? String
        let backgroundColor = extendedProps[RelatedDigitalConstants.backgroundColor] as? String

        let contentTitleCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.contentTitleCustomFontFamilyIos] as? String ?? ""
        let contentBodyCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.contentBodyCustomFontFamilyIos] as? String ?? ""
        let buttonCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.buttonCustomFontFamilyIos] as? String ?? ""
        let promocodeCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.promocodeCustomFontFamilyIos] as? String ?? ""
        let copybuttonCustomFontFamilyIos = extendedProps[RelatedDigitalConstants.copybuttonCustomFontFamilyIos] as? String

        
        var click = ""
        var impression = ""
        if let report = actionData[RelatedDigitalConstants.report] as? [String: Any] {
            click = report[RelatedDigitalConstants.click] as? String ?? ""
            impression = report[RelatedDigitalConstants.impression] as? String ?? ""
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
        let titleFont = RelatedDigitalInAppNotification.getFont(fontFamily: emailForm.extendedProps.titleFontFamily,
                                                          fontSize: emailForm.extendedProps.titleTextSize,
                                                          style: .title2,customFont: emailForm.extendedProps.titleCustomFontFamilyIos)
        let messageFont = RelatedDigitalInAppNotification.getFont(fontFamily: emailForm.extendedProps.textFontFamily,
                                                            fontSize: emailForm.extendedProps.textSize,
                                                            style: .body,customFont: emailForm.extendedProps.textCustomFontFamilyIos)
        let buttonFont = RelatedDigitalInAppNotification.getFont(fontFamily: emailForm.extendedProps.buttonFontFamily,
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
                      completion: @escaping ((_ response: RelatedDigitalFavoriteAttributeActionResponse) -> Void)) {

        var props = [String: String]()
        props[RelatedDigitalConstants.organizationIdKey] = self.visilabsProfile.organizationId
        props[RelatedDigitalConstants.profileIdKey] = self.visilabsProfile.profileId
        props[RelatedDigitalConstants.cookieIdKey] = visilabsUser.cookieId
        props[RelatedDigitalConstants.exvisitorIdKey] = visilabsUser.exVisitorId
        props[RelatedDigitalConstants.tokenIdKey] = visilabsUser.tokenId
        props[RelatedDigitalConstants.appidKey] = visilabsUser.appId
        props[RelatedDigitalConstants.apiverKey] = RelatedDigitalConstants.apiverValue
        props[RelatedDigitalConstants.actionType] = RelatedDigitalConstants.favoriteAttributeAction
        props[RelatedDigitalConstants.actionId] = actionId == nil ? nil : String(actionId!)
        
        
        props[RelatedDigitalConstants.nrvKey] = String(visilabsUser.nrv)
        props[RelatedDigitalConstants.pvivKey] = String(visilabsUser.pviv)
        props[RelatedDigitalConstants.tvcKey] = String(visilabsUser.tvc)
        props[RelatedDigitalConstants.lvtKey] = visilabsUser.lvt

        for (key, value) in RelatedDigitalPersistence.readTargetParameters() {
           if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
               props[key] = value
           }
        }

        RelatedDigitalRequest.sendMobileRequest(properties: props, headers: [String: String](),
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
                                        _ error: VisilabsError?) -> RelatedDigitalFavoriteAttributeActionResponse {
        var favoritesResponse = [RelatedDigitalFavoriteAttribute: [String]]()
        var errorResponse: VisilabsError?
        if let error = error {
            errorResponse = error
        } else if let res = result {
            if let favoriteAttributeActions = res[RelatedDigitalConstants.favoriteAttributeAction] as? [[String: Any?]] {
                for favoriteAttributeAction in favoriteAttributeActions {
                    if let actiondata = favoriteAttributeAction[RelatedDigitalConstants.actionData] as? [String: Any?] {
                        if let favorites = actiondata[RelatedDigitalConstants.favorites] as? [String: [String]?] {
                            for favorite in favorites {
                                if let favoriteAttribute = RelatedDigitalFavoriteAttribute(rawValue: favorite.key),
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
        return RelatedDigitalFavoriteAttributeActionResponse(favorites: favoritesResponse, error: errorResponse)
    }

    // MARK: - Story

    var visilabsStoryHomeViewControllers = [String: RelatedDigitalStoryHomeViewController]()
    var visilabsStoryHomeViews = [String: RelatedDigitalStoryHomeView]()

    func getStories(visilabsUser: VisilabsUser,
                    guid: String, actionId: Int? = nil,
                    completion: @escaping ((_ response: RelatedDigitalStoryActionResponse) -> Void)) {

        var props = [String: String]()
        props[RelatedDigitalConstants.organizationIdKey] = self.visilabsProfile.organizationId
        props[RelatedDigitalConstants.profileIdKey] = self.visilabsProfile.profileId
        props[RelatedDigitalConstants.cookieIdKey] = visilabsUser.cookieId
        props[RelatedDigitalConstants.exvisitorIdKey] = visilabsUser.exVisitorId
        props[RelatedDigitalConstants.tokenIdKey] = visilabsUser.tokenId
        props[RelatedDigitalConstants.appidKey] = visilabsUser.appId
        props[RelatedDigitalConstants.apiverKey] = RelatedDigitalConstants.apiverValue
        props[RelatedDigitalConstants.actionType] = RelatedDigitalConstants.story
        props[RelatedDigitalConstants.channelKey] = self.visilabsProfile.channel
        props[RelatedDigitalConstants.actionId] = actionId == nil ? nil : String(actionId!)
        
        props[RelatedDigitalConstants.nrvKey] = String(visilabsUser.nrv)
        props[RelatedDigitalConstants.pvivKey] = String(visilabsUser.pviv)
        props[RelatedDigitalConstants.tvcKey] = String(visilabsUser.tvc)
        props[RelatedDigitalConstants.lvtKey] = visilabsUser.lvt

        for (key, value) in RelatedDigitalPersistence.readTargetParameters() {
           if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
               props[key] = value
           }
        }

        RelatedDigitalRequest.sendMobileRequest(properties: props,
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
                              _ guid: String?) -> RelatedDigitalStoryActionResponse {
        var storiesResponse = [RelatedDigitalStoryAction]()
        var errorResponse: VisilabsError?
        if let error = error {
            errorResponse = error
        } else if let res = result {
            if let storyActions = res[RelatedDigitalConstants.story] as? [[String: Any?]] {
                var visilabsStories = [RelatedDigitalStory]()
                for storyAction in storyActions {
                    if let actionId = storyAction[RelatedDigitalConstants.actid] as? Int,
                       let actiondata = storyAction[RelatedDigitalConstants.actionData] as? [String: Any?],
                       let templateString = actiondata[RelatedDigitalConstants.taTemplate] as? String,
                       let template = RelatedDigitalStoryTemplate.init(rawValue: templateString) {
                        if let stories = actiondata[RelatedDigitalConstants.stories] as? [[String: Any]] {
                            for story in stories {
                                if template == .skinBased {
                                    var storyItems = [RelatedDigitalStoryItem]()
                                    if let items = story[RelatedDigitalConstants.items] as? [[String: Any]] {
                                        for item in items {
                                            storyItems.append(parseStoryItem(item))
                                        }
                                        if storyItems.count > 0 {
                                            visilabsStories.append(RelatedDigitalStory(title: story[RelatedDigitalConstants.title]
                                                                                    as? String,
                                            smallImg: story[RelatedDigitalConstants.thumbnail] as? String,
                                            link: story[RelatedDigitalConstants.link] as? String, items: storyItems, actid: actionId))
                                        }
                                    }
                                } else {
                                    visilabsStories.append(RelatedDigitalStory(title: story[RelatedDigitalConstants.title]
                                                                            as? String,
                                    smallImg: story[RelatedDigitalConstants.smallImg] as? String,
                                    link: story[RelatedDigitalConstants.link] as? String, actid: actionId))
                                }
                            }
                            let (clickQueryItems, impressionQueryItems)
                                = parseStoryReport(actiondata[RelatedDigitalConstants.report] as? [String: Any?])
                            if stories.count > 0 {
                                storiesResponse.append(RelatedDigitalStoryAction(actionId: actionId,
                                                                           storyTemplate: template,
                                                                           stories: visilabsStories,
                                                                           clickQueryItems: clickQueryItems,
                                                                           impressionQueryItems: impressionQueryItems,
                        extendedProperties: parseStoryExtendedProps(actiondata[RelatedDigitalConstants.extendedProps]
                                                                                                    as? String)))
                            }
                        }
                    }
                }
            }
        } else {
            errorResponse = VisilabsError.noData
        }
        return RelatedDigitalStoryActionResponse(storyActions: storiesResponse, error: errorResponse, guid: guid)
    }

    private func parseStoryReport(_ report: [String: Any?]?) -> ([String: String], [String: String]) {
        var clickItems = [String: String]()
        var impressionItems = [String: String]()
        // clickItems[VisilabsConstants.domainkey] =  "\(self.visilabsProfile.dataSource)_IOS" // TO_DO: OM.domain ne için gerekiyor?
        if let rep = report {
            if let click = rep[RelatedDigitalConstants.click] as? String {
                let qsArr = click.components(separatedBy: "&")
                for queryItem in qsArr {
                    let queryItemComponents = queryItem.components(separatedBy: "=")
                    if queryItemComponents.count == 2 {
                        clickItems[queryItemComponents[0]] = queryItemComponents[1]
                    }
                }
            }
            if let impression = rep[RelatedDigitalConstants.impression] as? String {
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

    private func parseStoryItem(_ item: [String: Any]) -> RelatedDigitalStoryItem {
        let fileType = (item[RelatedDigitalConstants.fileType] as? String) ?? "photo"
        let fileSrc = (item[RelatedDigitalConstants.fileSrc] as? String) ?? ""
        let targetUrl = (item[RelatedDigitalConstants.targetUrl]  as? String) ?? ""
        let buttonText = (item[RelatedDigitalConstants.buttonText]  as? String) ?? ""
        var displayTime = 3
        if let dTime = item[RelatedDigitalConstants.displayTime] as? Int, dTime > 0 {
            displayTime = dTime
        }
        var buttonTextColor = UIColor.white
        var buttonColor = UIColor.black
        if let buttonTextColorString = item[RelatedDigitalConstants.buttonTextColor] as? String {
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
        if let buttonColorString = item[RelatedDigitalConstants.buttonColor] as? String {
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
        let visilabsStoryItem = RelatedDigitalStoryItem(fileType: fileType,
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
            if let imageBorderWidthString = extendedProps[RelatedDigitalConstants.storylbImgBorderWidth] as? String,
               let imageBorderWidth = Int(imageBorderWidthString) {
                props.imageBorderWidth = imageBorderWidth
            }
            if let imageBorderRadiusString = extendedProps[RelatedDigitalConstants.storylbImgBorderRadius] as? String
                ?? extendedProps[RelatedDigitalConstants.storyzImgBorderRadius] as? String,
               let imageBorderRadius = Double(imageBorderRadiusString.trimmingCharacters(in:
                                                                        CharacterSet(charactersIn: "%"))) {
                props.imageBorderRadius = imageBorderRadius / 100.0
            }
            let storyzLabelColor = extendedProps[RelatedDigitalConstants.storyzLabelColor] as? String ?? ""
            props.storyzLabelColor = storyzLabelColor
            storyCustomVariables.shared.storyzLabelColor = storyzLabelColor

            let fontFamily = extendedProps[RelatedDigitalConstants.fontFamily] as? String ?? ""
            props.fontFamily = fontFamily
            storyCustomVariables.shared.fontFamily = fontFamily


            let customFontFamilyIos = extendedProps[RelatedDigitalConstants.customFontFamilyIos] as? String ?? ""
            props.customFontFamilyIos = customFontFamilyIos
            storyCustomVariables.shared.customFontFamilyIos = customFontFamilyIos

            
            if let imageBorderColorString = extendedProps[RelatedDigitalConstants.storylbImgBorderColor] as? String
                ?? extendedProps[RelatedDigitalConstants.storyzimgBorderColor] as? String {
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
            if let labelColorString = extendedProps[RelatedDigitalConstants.storylbLabelColor] as? String {
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
            if let boxShadowString = extendedProps[RelatedDigitalConstants.storylbImgBoxShadow] as? String,
               boxShadowString.count > 0 {
                props.imageBoxShadow = true
            }

            if let moveEnd = extendedProps[RelatedDigitalConstants.moveShownToEnd] as? String, moveEnd.lowercased() == "false" {
                props.moveShownToEnd = false
            } else {
                props.moveShownToEnd = true
            }
        }
        return props
    }

}
