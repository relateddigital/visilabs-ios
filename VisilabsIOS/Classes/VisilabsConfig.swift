//
//  VisilabsConfig.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import Foundation

struct VisilabsConfig {
    
    static let ORGANIZATIONID_KEY = "OM.oid"
    static let SITEID_KEY = "OM.siteID"
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
            params.append(VisilabsParameter(key: TARGET_PREF_VOSS_KEY, storeKey: TARGET_PREF_VOSS_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VCNAME_KEY, storeKey: TARGET_PREF_VCNAME_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VCMEDIUM_KEY, storeKey: TARGET_PREF_VCMEDIUM_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VCSOURCE_KEY, storeKey: TARGET_PREF_VCSOURCE_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VSEG1_KEY, storeKey: TARGET_PREF_VSEG1_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VSEG2_KEY, storeKey: TARGET_PREF_VSEG2_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VSEG3_KEY, storeKey: TARGET_PREF_VSEG3_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VSEG4_KEY, storeKey: TARGET_PREF_VSEG4_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VSEG5_KEY, storeKey: TARGET_PREF_VSEG5_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_BD_KEY, storeKey: TARGET_PREF_BD_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_GN_KEY, storeKey: TARGET_PREF_GN_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_LOC_KEY, storeKey: TARGET_PREF_LOC_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VPV_KEY, storeKey: TARGET_PREF_VPV_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_LPVS_KEY, storeKey: TARGET_PREF_LPVS_STORE_KEY, count: NSNumber(value: 10), relatedKeys: [TARGET_PREF_PPR_KEY]))
            params.append(VisilabsParameter(key: TARGET_PREF_LPP_KEY, storeKey: TARGET_PREF_LPP_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VQ_KEY, storeKey: TARGET_PREF_VQ_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
            params.append(VisilabsParameter(key: TARGET_PREF_VRDOMAIN_KEY, storeKey: TARGET_PREF_VRDOMAIN_STORE_KEY, count: NSNumber(value: 1), relatedKeys: nil))
        }
        return params
    }
    
}