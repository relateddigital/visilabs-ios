//
//  VisilabsConfig.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import Foundation

struct VisilabsConstants {
    
    static var QUEUE_SIZE = 5000
    
    //TODO: bunlar https e çevirilecek
    static var LOGGER_END_POINT = "http://lgr.visilabs.net"
    static var REALTIME_END_POINT = "http://rt.visilabs.net"
    static var RECOMMENDATION_END_POINT = "http://s.visilabs.net/json"
    static var ACTION_END_POINT = "http://s.visilabs.net/actjson"
    static var GEOFENCE_END_POINT = "http://s.visilabs.net/geojson"
    static var MOBILE_END_POINT = "http://s.visilabs.net/mobile"
    
    
    //MARK: -UserDefaults Keys
    
    static let USER_DEFAULTS_PROFILE_KEY = "Visilabs.profile"
    static let USER_DEFAULTS_USER_KEY = "Visilabs.user"
    static let USER_DEFAULTS_GEOFENCE_HISTORY_KEY = "Visilabs.geofenceHistory"
    
    //MARK: -Archive Keys
    

    static let GEOFENCE_HISTORY_ARCHIVE_KEY = "Visilabs.geofenceHistory"
    static let USER_ARCHIVE_KEY = "Visilabs.user";
    static let PROFILE_ARCHIVE_KEY = "Visilabs.profile";
    
    static let COOKIEID_ARCHIVE_KEY = "Visilabs.cookieId"; //"Visilabs.identity" idi cookieID olarak değiştirmek nasıl sorunlara sebep olur düşün.
    static let IDENTITY_ARCHIVE_KEY = "Visilabs.identity";
    static let EXVISITORID_ARCHIVE_KEY = "Visilabs.exVisitorId";
    static let TOKENID_ARCHIVE_KEY = "Visilabs.tokenId";
    static let APPID_ARCHIVE_KEY = "Visilabs.appId";
    static let USERAGENT_ARCHIVE_KEY = "Visilabs.userAgent";
    

    
    static let MAXGEOFENCECOUNT_KEY = "maxGeofenceCount";
    static let INAPPNOTIFICATIONSENABLED_KEY = "inAppNotificationsEnabled";
    static let GEOFENCEENABLED_KEY = "geofenceEnabled";
    static let REQUESTTIMEINSECONDS_KEY = "requestTimeoutInSeconds";
    static let DATASOURCE_KEY = "dataSource";
    static let USERAGENT_KEY = "OM.userAgent";
    static let VISITORDATA = "visitorData";
    
    
    static let LAST_GEOFENCE_FETCH_TIME_KEY = "lastGeofenceFetchTime"
    static let GEOFENCES_KEY = "geofences"
    
    
    static let MOBILEADID_KEY = "OM.m_adid"
    static let MOBILEAPPLICATION_KEY = "OM.mappl"
    
    static let TRUE = "true"
    
    static let IOS = "IOS"
    static let DAT_KEY = "dat"
    static let OM_GIF = "om.gif"
    static let DOMAIN_KEY = "OM.domain"
    static let VISIT_CAPPING_KEY = "OM.vcap"
    static let VISITOR_CAPPING_KEY = "OM.viscap"
    
    static let ORGANIZATIONID_KEY = "OM.oid"
    static let PROFILEID_KEY = "OM.siteID"
    static let COOKIEID_KEY = "OM.cookieID"
    static let EXVISITORID_KEY = "OM.exVisitorID"
    static let ZONE_ID_KEY = "OM.zid"
    static let BODY_KEY = "OM.body"
    static let LATITUDE_KEY = "OM.latitude"
    static let LONGITUDE_KEY = "OM.longitude"
    static let ACT_ID_KEY = "actid"
    static let ACT_KEY = "act"
    static let TOKENID_KEY = "OM.sys.TokenID"
    static let APPID_KEY = "OM.sys.AppID"
    static let LOGGER_URL = "lgr.visilabs.net"
    static let REAL_TIME_URL = "rt.visilabs.net"
    static let LOAD_BALANCE_PREFIX = "NSC"
    static let OM_3_KEY = "OM.3rd"
    static let FILTER_KEY = "OM.w.f"
    static let APIVER_KEY = "OM.apiver"
    static let GEO_ID_KEY = "OM.locationid"
    static let TRIGGER_EVENT_KEY = "OM.triggerevent"
    
    static let CHANNEL_KEY = "OM.vchannel"
    static let URI_KEY = "OM.uri"
    
    static let UTM_SOURCE_KEY = "utm_source"
    static let UTM_CAMPAIGN_KEY = "utm_campaign"
    static let UTM_MEDIUM_KEY = "utm_medium"
    static let UTM_CONTENT_KEY = "utm_content"
    
    static let GET_LIST = "getlist"
    static let PROCESSV2 = "processV2"
    static let ON_ENTER = "OnEnter"
    static let ON_EXIT = "OnExit"
    static let DWELL = "Dwell"
    static let APIVER_VALUE = "IOS"
    
    private static let TARGET_PREF_VOSS_STORE_KEY = "OM.voss"
    private static let TARGET_PREF_VCNAME_STORE_KEY = "OM.vcname"
    private static let TARGET_PREF_VCMEDIUM_STORE_KEY = "OM.vcmedium"
    private static let TARGET_PREF_VCSOURCE_STORE_KEY = "OM.vcsource"
    private static let TARGET_PREF_VSEG1_STORE_KEY = "OM.vseg1"
    private static let TARGET_PREF_VSEG2_STORE_KEY = "OM.vseg2"
    private static let TARGET_PREF_VSEG3_STORE_KEY = "OM.vseg3"
    private static let TARGET_PREF_VSEG4_STORE_KEY = "OM.vseg4"
    private static let TARGET_PREF_VSEG5_STORE_KEY = "OM.vseg5"
    private static let TARGET_PREF_BD_STORE_KEY = "OM.bd"
    private static let TARGET_PREF_GN_STORE_KEY = "OM.gn"
    private static let TARGET_PREF_LOC_STORE_KEY = "OM.loc"
    private static let TARGET_PREF_VPV_STORE_KEY = "OM.vpv"
    private static let TARGET_PREF_LPVS_STORE_KEY = "OM.lpvs"
    private static let TARGET_PREF_LPP_STORE_KEY = "OM.lpp"
    private static let TARGET_PREF_VQ_STORE_KEY = "OM.vq"
    private static let TARGET_PREF_VRDOMAIN_STORE_KEY = "OM.vrDomain"
    
    private static let TARGET_PREF_VOSS_KEY = "OM.OSS"
    private static let TARGET_PREF_VCNAME_KEY = "OM.cname"
    private static let TARGET_PREF_VCMEDIUM_KEY = "OM.cmedium"
    private static let TARGET_PREF_VCSOURCE_KEY = "OM.csource"
    private static let TARGET_PREF_VSEG1_KEY = "OM.vseg1"
    private static let TARGET_PREF_VSEG2_KEY = "OM.vseg2"
    private static let TARGET_PREF_VSEG3_KEY = "OM.vseg3"
    private static let TARGET_PREF_VSEG4_KEY = "OM.vseg4"
    private static let TARGET_PREF_VSEG5_KEY = "OM.vseg5"
    private static let TARGET_PREF_BD_KEY = "OM.bd"
    private static let TARGET_PREF_GN_KEY = "OM.gn"
    private static let TARGET_PREF_LOC_KEY = "OM.loc"
    private static let TARGET_PREF_VPV_KEY = "OM.pv"
    private static let TARGET_PREF_LPVS_KEY = "OM.pv"
    private static let TARGET_PREF_LPP_KEY = "OM.pp"
    private static let TARGET_PREF_VQ_KEY = "OM.q"
    private static let TARGET_PREF_VRDOMAIN_KEY = "OM.rDomain"
    private static let TARGET_PREF_PPR_KEY = "OM.ppr"
    
    private static var params = [VisilabsParameter]()
    
    static func visilabsParameters() -> [VisilabsParameter] {
        if params.count == 0 {
            params.append(VisilabsParameter(key: TARGET_PREF_VOSS_KEY, storeKey: TARGET_PREF_VOSS_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VCNAME_KEY, storeKey: TARGET_PREF_VCNAME_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VCMEDIUM_KEY, storeKey: TARGET_PREF_VCMEDIUM_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VCSOURCE_KEY, storeKey: TARGET_PREF_VCSOURCE_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VSEG1_KEY, storeKey: TARGET_PREF_VSEG1_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VSEG2_KEY, storeKey: TARGET_PREF_VSEG2_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VSEG3_KEY, storeKey: TARGET_PREF_VSEG3_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VSEG4_KEY, storeKey: TARGET_PREF_VSEG4_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VSEG5_KEY, storeKey: TARGET_PREF_VSEG5_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_BD_KEY, storeKey: TARGET_PREF_BD_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_GN_KEY, storeKey: TARGET_PREF_GN_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_LOC_KEY, storeKey: TARGET_PREF_LOC_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VPV_KEY, storeKey: TARGET_PREF_VPV_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_LPVS_KEY, storeKey: TARGET_PREF_LPVS_STORE_KEY, count: 10, relatedKeys: [TARGET_PREF_PPR_KEY]))
            params.append(VisilabsParameter(key: TARGET_PREF_LPP_KEY, storeKey: TARGET_PREF_LPP_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VQ_KEY, storeKey: TARGET_PREF_VQ_STORE_KEY, count: 1, relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VRDOMAIN_KEY, storeKey: TARGET_PREF_VRDOMAIN_STORE_KEY, count: 1, relatedKeys: nil))
        }
        return params
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
