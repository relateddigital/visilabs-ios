//
//  VisilabsConfig.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import UIKit

struct VisilabsConstants {
    
    static let sdkVersion = "3.7.0"

    static let HTTP = "http"
    static let HTTPS = urlConstant.shared.securityTag

    static let queueSize = 5000
    static let geofenceHistoryMaxCount = 100
    static let geofenceHistoryErrorMaxCount = 100
    static let geofenceFetchTimeInterval = TimeInterval(15 * 60)
    static let remoteConfigFetchTimeInterval = TimeInterval(15 * 60)

    static var loggerEndPoint = "lgr.visilabs.net"
    static var realtimeEndPoint = "rt.visilabs.net"
    static var recommendationEndPoint = "\(urlConstant.shared.urlPrefix)/json"
    static var actionEndPoint = "\(urlConstant.shared.urlPrefix)/actjson"
    static var geofenceEndPoint = "\(urlConstant.shared.urlPrefix)/geojson"
    static var mobileEndPoint = "\(urlConstant.shared.urlPrefix)/mobile"
    static var subsjsonEndpoint = "\(urlConstant.shared.urlPrefix)/subsjson"
    static var promotionEndpoint = "\(urlConstant.shared.urlPrefix)/promotion"
    static var remoteConfigEndpoint = "mbls.visilabs.net/rc.json"

    // MARK: - UserDefaults Keys

    static let userDefaultsProfileKey = "Visilabs.profile"
    static let userDefaultsUserKey = "Visilabs.user"
    static let userDefaultsGeofenceHistoryKey = "Visilabs.geofenceHistory"
    static let userDefaultsTargetKey = "Visilabs.target"
    static let userDefaultsBlockKey = "Visilabs.block"

    // MARK: - Archive Keys

    static let geofenceHistoryArchiveKey = "Visilabs.geofenceHistory"
    static let userArchiveKey = "Visilabs.user"
    static let profileArchiveKey = "Visilabs.profile"

    static let cookieidArchiveKey = "Visilabs.cookieId"
    // "Visilabs.identity" idi cookieID olarak değiştirmek nasıl sorunlara sebep olur düşün.
    static let identityArchiveKey = "Visilabs.identity"
    static let exvisitorIdArchiveKey = "Visilabs.exVisitorId"
    static let tokenidArchiveKey = "Visilabs.tokenId"
    static let appidArchiveKey = "Visilabs.appId"
    static let useragentArchiveKey = "Visilabs.userAgent"

    static let maxGeofenceCountKey = "maxGeofenceCount"
    static let inAppNotificaitionsKey = "inAppNotificationsEnabled"
    static let geofenceEnabledKey = "geofenceEnabled"
    static let requestTimeoutInSecondsKey = "requestTimeoutInSeconds"
    static let dataSourceKey = "dataSource"
    static let userAgentKey = "OM.userAgent"
    static let visitorData = "visitorData"

    static let lastGeofenceFetchTimeKey = "lastGeofenceFetchTime"
    static let geofencesKey = "geofences"

    static let mobileIdKey = "OM.m_adid"
    static let mobileApplicationKey = "OM.mappl"
    static let mobileSdkVersion = "sdk_version"
    static let mobileAppVersion = "OM.appVersion"

    static let isTrue = "true"

    static let ios = "IOS"
    static let datKey = "dat"
    static let omGif = "om.gif"
    static let domainkey = "OM.domain"
    static let visitCappingKey = "OM.vcap"
    static let visitorCappingKey = "OM.viscap"
    static let omEvtGif = "OM_evt.gif"

    static let organizationIdKey = "OM.oid"
    static let profileIdKey = "OM.siteID"
    static let cookieIdKey = "OM.cookieID"
    static let exvisitorIdKey = "OM.exVisitorID"
    static let zoneIdKey = "OM.zid"
    static let bodyKey = "OM.body"
    static let latitudeKey = "OM.latitude"
    static let longitudeKey = "OM.longitude"
    static let actidKey = "actid"
    static let actKey = "act"
    static let tokenIdKey = "OM.sys.TokenID"
    static let appidKey = "OM.sys.AppID"
    static let loggerUrl = "lgr.visilabs.net"
    static let realTimeUrl = "rt.visilabs.net"
    static let loadBalancePrefix = "NSC"
    static let om3Key = "OM.3rd"
    static let filterKey = "OM.w.f"
    static let apiverKey = "OM.apiver"
    static let geoIdKey = "OM.locationid"
    static let triggerEventKey = "OM.triggerevent"
    static let subscribedEmail = "OM.subsemail"

    static let channelKey = "OM.vchannel"
    static let uriKey = "OM.uri"
    
    static let lastEventTimeKey = "lastEventTime"
    static let nrvKey = "OM.nrv"
    static let pvivKey = "OM.pviv"
    static let tvcKey = "OM.tvc"
    static let lvtKey = "OM.lvt"

    static let utmSourceKey = "utm_source"
    static let utmCampaignKey = "utm_campaign"
    static let utmMediumKey = "utm_medium"
    static let utmContentKey = "utm_content"

    static let getList = "getlist"
    static let processV2 = "processV2"
    static let onEnter = "OnEnter"
    static let onExit = "OnExit"
    static let dwell = "Dwell"
    static let apiverValue = "IOS"

    static let actionType = "action_type"
    static let favoriteAttributeAction = "FavoriteAttributeAction"
    static let story = "Story"
    static let mailSubscriptionForm = "MailSubscriptionForm"
    static let spinToWin = "SpinToWin"
    static let scratchToWin = "ScratchToWin"
    static let productStatNotifier = "ProductStatNotifier"
    static let drawer = "Drawer"

    
    static let actid = "actid"
    static let actionId = "action_id"
    static let actionData = "actiondata"
    static let favorites = "favorites"
    static let stories = "stories"
    static let title = "title"
    static let smallImg = "smallImg"
    static let link = "link"
    static let thumbnail = "thumbnail"
    static let items = "items"
    static let fileType = "fileType"
    static let displayTime = "displayTime"
    static let fileSrc = "fileSrc"
    static let targetUrl = "targetUrl"
    static let buttonText = "buttonText"
    static let buttonTextColor = "buttonTextColor"
    static let buttonColor = "buttonColor"
    static let taTemplate = "taTemplate"
    static let report = "report"
    static let impression = "impression"
    static let click = "click"
    static let extendedProps = "ExtendedProps"
    static let storylbImgBorderWidth = "storylb_img_borderWidth"
    static let storylbImgBorderColor = "storylb_img_borderColor"
    static let storylbImgBorderRadius = "storylb_img_borderRadius"
    static let storylbImgBoxShadow = "storylb_img_boxShadow"
    static let storylbLabelColor = "storylb_label_color"
    static let storyzimgBorderColor = "storyz_img_borderColor"
    static let storyzImgBorderRadius = "storyz_img_borderRadius"
    static let shownStories = "shownStories"
    static let moveShownToEnd = "moveShownToEnd"
    static let storyzLabelColor = "storyz_label_color"
    static let fontFamily = "font_family"
    static let customFontFamilyIos = "custom_font_family_ios"

    
    // Email form constants
    static let message = "message"
    static let placeholder = "placeholder"
    static let type = "type"
    static let buttonLabel = "button_label"
    static let consentText = "consent_text"
    static let successMessage = "success_message"
    static let invalidEmailMessage = "invalid_email_message"
    static let emailPermitText = "emailpermit_text"
    static let checkConsentMessage = "check_consent_message"
    static let authentication = "auth"
    static let titleTextColor = "title_text_color"
    static let titleFontFamily = "title_font_family"
    static let titleTextSize = "title_text_size"
    static let textColor = "text_color"
    static let textFontFamily = "text_font_family"
    static let textSize = "text_size"
    static let buttonFontFamily = "button_font_family"
    static let buttonTextSize = "button_text_size"
    static let emailPermitTextSize = "emailpermit_text_size"
    static let emailPermitTextUrl = "emailpermit_text_url"
    static let consentTextSize = "consent_text_size"
    static let consentTextUrl = "consent_text_url"
    static let closeButtonColor = "close_button_color"
    static let backgroundColor = "background_color"
    static let wheelBorderWidth = "wheel_borderWidth"
    static let wheelBorderColor = "wheel_borderColor"
    static let sliceDisplaynameFontFamily = "slice_displayname_font_family"


    //Drawer
    static let shape = "shape"
    static let position = "pos"
    static let contentMinimizedImage = "content_minimized_image"
    static let contentMinimizedText = "content_minimized_text"
    static let contentMaximizedImage = "content_maximized_image"
    static let iosLnk = "ios_lnk"
    // extended properties
    static let contentMinimizedTextSize = "content_minimized_text_size"
    static let contentMinimizedTextColor = "content_minimized_text_color"
    static let contentMinimizedFontFamily = "content_minimized_font_family"
    static let contentMinimizedCustomFontFamilyIos = "content_minimized_custom_font_family_ios"
    static let contentMinimizedTextOrientation = "content_minimized_text_orientation"
    static let contentMinimizedBackgroundImage = "content_minimized_background_image"
    static let contentMinimizedBackgroundColor = "content_minimized_background_color"
    static let contentMinimizedArrowColor = "content_minimized_arrow_color"
    static let contentMaximizedBackgroundImage = "content_maximized_background_image"
    static let contentMaximizedBackgroundColor = "content_maximized_background_color"

    
    
    
    
    // SpinToWin constants
    static let slices = "slices"
    static let promoAuth = "promoAuth"
    static let mailSubscription = "mail_subscription"
    static let sliceCount = "slice_count"
    static let spinToWinContent = "spin_to_win_content"
    static let promocodeTitle = "promocode_title"
    static let copybuttonLabel = "copybutton_label"
    static let img = "img"
    static let wheelSpinAction = "wheel_spin_action"
    static let promocodesSoldoutMessage = "promocodes_soldout_message"


    // SpinToWin extended properties
    static let displaynameTextColor = "displayname_text_color"
    static let displaynameFontFamily = "displayname_font_family"
    static let displaynameTextSize = "displayname_text_size"
    static let button_color = "button_color"
    static let button_text_color = "button_text_color"
    static let promocodeTitleTextColor = "promocode_title_text_color"
    static let promocodeTitleFontFamily = "promocode_title_font_family"
    static let promocodeTitleTextSize = "promocode_title_text_size"
    static let promocodeBackgroundColor = "promocode_background_color"
    static let promocodeTextColor = "promocode_text_color"
    static let copybuttonColor = "copybutton_color"
    static let copybuttonTextColor = "copybutton_text_color"
    static let copybuttonFontFamily = "copybutton_font_family"
    static let copybuttonTextSize = "copybutton_text_size"
    static let emailpermitTextSize = "emailpermit_text_size"
    static let emailpermitTextUrl = "emailpermit_text_url"
    
    static let displaynameCustomFontFamilyIos = "displayname_custom_font_family_ios"
    static let titleCustomFontFamilyIos = "title_custom_font_family_ios"
    static let textCustomFontFamilyIos = "text_custom_font_family_ios"
    static let buttonCustomFontFamilyIos = "button_custom_font_family_ios"
    static let promocodeTitleCustomFontFamilyIos = "promocode_title_custom_font_family_ios"
    static let copybuttonCustomFontFamilyIos = "copybutton_custom_font_family_ios"
    static let promocodesSoldoutMessageCustomFontFamilyIos = "promocodes_soldout_message_custom_font_family_ios"

    
    static let promocodes_soldout_message_text_color = "promocodes_soldout_message_text_color"
    static let promocodes_soldout_message_font_family = "promocodes_soldout_message_font_family"
    static let promocodes_soldout_message_text_size = "promocodes_soldout_message_text_size"
    static let promocodes_soldout_message_background_color = "promocodes_soldout_message_background_color"
    
    static let title_position = "title_position"
    static let text_position = "text_position"
    static let button_position = "button_position"
    static let copybutton_position = "copybutton_position"
    
    static let promocode_banner_text = "promocode_banner_text"
    static let promocode_banner_text_color = "promocode_banner_text_color"
    static let promocode_banner_background_color = "promocode_banner_background_color"
    static let promocode_banner_button_label = "promocode_banner_button_label"
    

    // SpinToWin slices
    static let displayName = "displayName"
    static let color = "color"
    static let code = "code"
    static let isAvailable = "is_available"
    
    // SpinToWin information properties
    static let promoAction = "OM.promoaction"
    static let promoActionID = "OM.actionid"
    static let promoEmailKey = "OM.promoemail"
    static let promoTitleKey = "OM.promotitle"
    static let promoSlice = "OM.promoslice"

    // Scratch To Win constants
    static let scratchColor = "scratch_color"
    static let waitingTime = "waiting_time"
    static let sendEmail = "send_email"
    static let promotionCode = "promotion_code"
    static let contentTitle = "content_title"
    static let contentBody = "content_body"
    static let contentTitleTextColor = "content_title_text_color"
    static let contentTitleFontFamily = "content_title_font_family"
    static let contentTitleTextSize = "content_title_text_size"
    static let contentBodyTextColor = "content_body_text_color"
    static let contentBodyTextFontFamily = "content_body_font_family"
    static let contentBodyTextSize = "content_body_text_size"
    static let promocodeFontFamily = "promocode_font_family"
    static let promocodeTextSize = "promocode_text_size"
    static let sctwMailSubscriptionForm = "mail_subscription_form"
    
    static let contentTitleCustomFontFamilyIos = "content_title_custom_font_family_ios"
    static let contentBodyCustomFontFamilyIos = "content_body_custom_font_family_ios"
    static let promocodeCustomFontFamilyIos = "promocode_custom_font_family_ios"

    
    
    // ProductStatNotifier constants
    static let content = "content"
    static let pos = "pos"
    static let timeout = "timeout"
    static let bgcolor = "bgcolor"
    static let threshold = "threshold"
    static let showclosebtn = "showclosebtn"
    static let content_text_color = "content_text_color"
    static let content_font_family = "content_font_family"
    static let content_text_size = "content_text_size"
    static let contentcount_text_color = "contentcount_text_color"
    static let contentcount_text_size = "contentcount_text_size"
    
    
    
    static let backgroundClickCloseDisabledInAppNotificationTypes: [VisilabsInAppNotificationType] = [.full, .feedbackForm, .mini, .halfScreenImage]
    

    private static let targetPrefVossStoreKey = "OM.voss"
    private static let targetPrefVcnameStoreKey = "OM.vcname"
    private static let targetPrefVcmediumStoreKey = "OM.vcmedium"
    private static let targetPrefVcsourceStoreKey = "OM.vcsource"
    private static let targetPrefVseg1StoreKey = "OM.vseg1"
    private static let targetPrefVseg2StoreKey = "OM.vseg2"
    private static let targetPrefVseg3StoreKey = "OM.vseg3"
    private static let targetPrefVseg4StoreKey = "OM.vseg4"
    private static let targetPrefVseg5StoreKey = "OM.vseg5"
    private static let targetPrefBdStoreKey = "OM.bd"
    private static let targetPrefGnStoreKey = "OM.gn"
    private static let targetPrefLocStoreKey = "OM.loc"
    private static let targetPrefVPVStoreKey = "OM.vpv"
    private static let targetPrefLPVSStoreKey = "OM.lpvs"
    private static let targetPrefLPPStoreKey = "OM.lpp"
    private static let targetPrefVQStoreKey = "OM.vq"
    private static let targetPrefVRStoreKey = "OM.vrDomain"

    private static let targetPrefVossKey = "OM.OSS"
    private static let targetPrefVcNameKey = "OM.cname"
    private static let targetPrefVcmediumKey = "OM.cmedium"
    private static let targetPrefVcsourceKey = "OM.csource"
    private static let targetPrefVseg1Key = "OM.vseg1"
    private static let targetPrefVseg2Key = "OM.vseg2"
    private static let targetPrefVseg3Key = "OM.vseg3"
    private static let targetPrefVseg4Key = "OM.vseg4"
    private static let targetPrefVseg5Key = "OM.vseg5"
    private static let targetPrefBDKey = "OM.bd"
    private static let targetPrefGNKey = "OM.gn"
    private static let targetPrefLOCKey = "OM.loc"
    private static let targetPrefVPVKey = "OM.pv"
    private static let targetPrefLPVSKey = "OM.pv"
    private static let targetPrefLPPKey = "OM.pp"
    private static let targetPrefVQKey = "OM.q"
    private static let targetPrefVRDomainKey = "OM.rDomain"
    private static let targetPrefPPRKey = "OM.ppr"
    
    //Location Status
    static let locationPermissionReqKey = "OM.locpermit"
    static let locationPermissionAlways = "always"
    static let locationPermissionAppOpen = "appopen"
    static let locationPermissionNone = "none"
    
    //Push Permission Status
        static let pushPermitPermissionReqKey = "OM.pushnotifystatus"
        static var pushPermitStatus = "default"

    private static var targetParameters = [VisilabsParameter]()

    static func visilabsTargetParameters() -> [VisilabsParameter] {
        if targetParameters.count == 0 {
            targetParameters.append(VisilabsParameter(key: targetPrefVossKey, storeKey: targetPrefVossStoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefVcNameKey, storeKey: targetPrefVcnameStoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefVcmediumKey, storeKey: targetPrefVcmediumStoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefVcsourceKey, storeKey: targetPrefVcsourceStoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefVseg1Key, storeKey: targetPrefVseg1StoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefVseg2Key, storeKey: targetPrefVseg2StoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefVseg3Key, storeKey: targetPrefVseg3StoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefVseg4Key, storeKey: targetPrefVseg4StoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefVseg5Key, storeKey: targetPrefVseg5StoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefBDKey, storeKey: targetPrefBdStoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefGNKey, storeKey: targetPrefGnStoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefLOCKey, storeKey: targetPrefLocStoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefVPVKey, storeKey: targetPrefVPVStoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefLPVSKey, storeKey: targetPrefLPVSStoreKey,
                                                      count: 10, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefLPPKey, storeKey: targetPrefLPPStoreKey,
                                                      count: 1, relatedKeys: [targetPrefPPRKey]))
            targetParameters.append(VisilabsParameter(key: targetPrefVQKey, storeKey: targetPrefVQStoreKey,
                                                      count: 1, relatedKeys: nil))
            targetParameters.append(VisilabsParameter(key: targetPrefVRDomainKey, storeKey: targetPrefVRStoreKey,
                                                      count: 1, relatedKeys: nil))
        }
        return targetParameters
    }

}

struct VisilabsInAppNotificationsConstants {
    static let miniInAppHeight: CGFloat = 75
    static let miniBottomPadding: CGFloat = 0 // 10 + (UIDevice.current.iPhoneX ? 34 : 0)
    static let miniSidePadding: CGFloat = 0 // 15
}
