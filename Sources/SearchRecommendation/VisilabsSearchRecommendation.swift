//
//  VisilabsSearchRecommendation.swift
//  CleanyModal
//
//  Created by Orhun Akmil on 9.02.2024.
//

import Foundation


class VisilabsSearchRecommendation {
        
    let visilabsProfile: VisilabsProfile

    init(visilabsProfile: VisilabsProfile) {
        self.visilabsProfile = visilabsProfile
    }
    
    
    func searchRecommend(visilabsUser: VisilabsUser,
                         properties: [String: String] = [:],
                         keyword: String = "",
                         completion: @escaping ((_ response: VisilabsSearchRecommendationResponse) -> Void)) {
        
        
        var props = cleanProperties(properties)


        props[VisilabsConstants.organizationIdKey] = self.visilabsProfile.organizationId
        props[VisilabsConstants.profileIdKey] = self.visilabsProfile.profileId
        props[VisilabsConstants.cookieIdKey] = visilabsUser.cookieId
        props[VisilabsConstants.exvisitorIdKey] = visilabsUser.exVisitorId
        props[VisilabsConstants.tokenIdKey] = visilabsUser.tokenId
        props[VisilabsConstants.appidKey] = visilabsUser.appId
        props[VisilabsConstants.apiverKey] = VisilabsConstants.apiverValue
        props[VisilabsConstants.channelKey] = VisilabsConstants.ios
        props[VisilabsConstants.sdkTypeKey] = VisilabsConstants.sdkType
        props[VisilabsConstants.utmCampaignKey] = visilabsUser.utmCampaign
        props[VisilabsConstants.utmMediumKey] = visilabsUser.utmMedium
        props[VisilabsConstants.utmSourceKey] = visilabsUser.utmSource
        props[VisilabsConstants.utmContentKey] = visilabsUser.utmContent
        props[VisilabsConstants.utmTermKey] = visilabsUser.utmTerm
        
        props[VisilabsConstants.nrvKey] = String(visilabsUser.nrv)
        props[VisilabsConstants.pvivKey] = String(visilabsUser.pviv)
        props[VisilabsConstants.tvcKey] = String(visilabsUser.tvc)
        props[VisilabsConstants.lvtKey] = visilabsUser.lvt
        props[VisilabsConstants.keyword] = keyword
        props[VisilabsConstants.searchChannel] = VisilabsConstants.webKey

        

        for (key, value) in VisilabsPersistence.readTargetParameters() {
            if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
                props[key] = value
            }
        }
        
        VisilabsRequest.sendSearchRecommendationRequest(properties: props, headers: [String: String](), timeoutInterval: visilabsProfile.requestTimeoutInterval) { result in
            guard let result = result else {
                completion(VisilabsSearchRecommendationResponse(responseDict: [String : Any]()))
                return
            }
            
            completion(VisilabsSearchRecommendationResponse(responseDict: result))            
            
        }
        
    }
    
    
    private func cleanProperties(_ properties: [String: String]) -> [String: String] {
        var props = properties
        for propKey in props.keys {
            if !propKey.isEqual(VisilabsConstants.organizationIdKey)
                && !propKey.isEqual(VisilabsConstants.profileIdKey)
                && !propKey.isEqual(VisilabsConstants.exvisitorIdKey)
                && !propKey.isEqual(VisilabsConstants.cookieIdKey)
                && !propKey.isEqual(VisilabsConstants.zoneIdKey)
                && !propKey.isEqual(VisilabsConstants.bodyKey)
                && !propKey.isEqual(VisilabsConstants.tokenIdKey)
                && !propKey.isEqual(VisilabsConstants.appidKey)
                && !propKey.isEqual(VisilabsConstants.apiverKey)
                && !propKey.isEqual(VisilabsConstants.filterKey)
                && !propKey.isEqual(VisilabsConstants.channelKey)
                && !propKey.isEqual(VisilabsConstants.sdkTypeKey)
                && !propKey.isEqual(VisilabsConstants.utmCampaignKey)
                && !propKey.isEqual(VisilabsConstants.utmMediumKey)
                && !propKey.isEqual(VisilabsConstants.utmSourceKey)
                && !propKey.isEqual(VisilabsConstants.utmContentKey)
                && !propKey.isEqual(VisilabsConstants.utmTermKey) {
                continue
            } else {
                props.removeValue(forKey: propKey)
            }
        }
        return props
    }
    
}
