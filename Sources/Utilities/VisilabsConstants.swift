//
//  VisilabsConfig.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import UIKit

struct VisilabsConstants {

    static let HTTP = "http"
    static let HTTPS = "https"

    static let queueSize = 5000
    static let geofenceHistoryMaxCount = 500 //TO_DO: bunu sonra değiştir
    static let geofenceHistoryErrorMaxCount = 500 //TO_DO: bunu sonra değiştir
    static let geofenceFetchTimeInterval = TimeInterval(60) //TO_DO: bunu sonra değiştir 15 dakika yap

    //TO_DO: bunlar https e çevirilecek
    static var loggerEndPoint = "lgr.visilabs.net"
    static var realtimeEndPoint = "rt.visilabs.net"
    static var recommendationEndPoint = "s.visilabs.net/json"
    static var actionEndPoint = "s.visilabs.net/actjson"
    static var geofenceEndPoint = "s.visilabs.net/geojson"
    static var mobileEndPoint = "s.visilabs.net/mobile"
    static var subsjsonEndpoint = "s.visilabs.net/subsjson"
    static var promotionEndpoint = "s.visilabs.net/promotion"

    // MARK: - UserDefaults Keys

    static let userDefaultsProfileKey = "Visilabs.profile"
    static let userDefaultsUserKey = "Visilabs.user"
    static let userDefaultsGeofenceHistoryKey = "Visilabs.geofenceHistory"
    static let userDefaultsTargetKey = "Visilabs.target"

    // MARK: - Archive Keys

    static let geofenceHistoryArchiveKey = "Visilabs.geofenceHistory"
    static let userArchiveKey = "Visilabs.user"
    static let profileArchiveKey = "Visilabs.profile"

    static let cookieidArchiveKey = "Visilabs.cookieId"
    //"Visilabs.identity" idi cookieID olarak değiştirmek nasıl sorunlara sebep olur düşün.
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
    //Email form constants
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
    
    
    //SpinToWin constants
    static let slices = "slices"
    static let promoAuth = "promoAuth"
    static let mailSubscription = "mail_subscription"
    static let sliceCount = "slice_count"
    static let spinToWinContent = "spin_to_win_content"
    static let promocodeTitle = "promocode_title"
    static let copybuttonLabel = "copybutton_label"
    static let img = "img"
    
    //SpinToWin extended properties
    static let displaynameTextColor = "displayname_text_color"
    static let displaynameFontFamily = "displayname_font_family"
    static let displaynameTextSize = "displayname_text_size"
    //static let titleTextColor = "title_text_color" // varmış zaten
    //static let titleFontFamily = "title_font_family" // varmış zaten
    //static let titleTextSize = "title_text_size" // varmış zaten
    //static let textColor = "text_color" // varmış zaten
    //static let textFontFamily = "text_font_family" // varmış zaten
    //static let textSize = "text_size" // varmış zaten
    static let button_color = "button_color"
    static let button_text_color = "button_text_color"
    //static let buttonFontFamily = "button_font_family" // varmış zaten
    //static let buttonTextSize = "button_text_size" // varmış zaten
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
    //static let consentTextSize = "consent_text_size" // varmış zaten
    //static let consentTextUrl = "consent_text_url" // varmış zaten
    //static let closeButtonColor = "close_button_color" // varmış zaten
    //static let backgroundColor = "background_color" // varmış zaten
    
    //SpinToWin slices
    static let displayName = "displayName"
    static let color = "color"
    static let code = "code"
    //static let type = "type" // varmış zaten


    
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

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}
