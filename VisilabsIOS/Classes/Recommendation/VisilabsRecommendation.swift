//
//  VisilabsRecommendation.swift
//  VisilabsIOS
//
//  Created by Egemen on 29.06.2020.
//

import Foundation

class VisilabsRecommendation {
    let visilabsProfile: VisilabsProfile

    init(visilabsProfile: VisilabsProfile) {
        self.visilabsProfile = visilabsProfile
    }

    func recommend(zoneID: String,
                   productCode: String?,
                   visilabsUser: VisilabsUser,
                   channel: String,
                   properties: [String: String] = [:],
                   filters: [VisilabsRecommendationFilter] = [],
                   completion: @escaping ((_ response: VisilabsRecommendationResponse) -> Void)) {

        var props = cleanProperties(properties)

        if filters.count > 0 {
            props[VisilabsConstants.filterKey] = getFiltersQueryStringValue(filters)
        }

        props[VisilabsConstants.organizationIdKey] = self.visilabsProfile.organizationId
        props[VisilabsConstants.profileIdKey] = self.visilabsProfile.profileId
        props[VisilabsConstants.cookieIdKey] = visilabsUser.cookieId
        props[VisilabsConstants.exvisitorIdKey] = visilabsUser.exVisitorId
        props[VisilabsConstants.tokenIdKey] = visilabsUser.tokenId
        props[VisilabsConstants.appidKey] = visilabsUser.appId
        props[VisilabsConstants.apiverKey] = VisilabsConstants.apiverValue

        if zoneID.count > 0 {
            props[VisilabsConstants.zoneIdKey] = zoneID
        }
        if !productCode.isNilOrWhiteSpace {
            props[VisilabsConstants.bodyKey] = productCode
        }

        for (key, value) in VisilabsPersistence.readTargetParameters() {
            if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
                props[key] = value
            }
        }

        VisilabsRequest.sendRecommendationRequest(properties: props,
                                                  headers: [String: String](),
                                                  timeoutInterval: visilabsProfile.requestTimeoutInterval,
                                                  completion: { (results: [Any]?, error: VisilabsError?) in
            var products = [VisilabsProduct]()
            if error != nil {
                completion(VisilabsRecommendationResponse(products: [VisilabsProduct](), error: error))
            } else {
                for result in results! {
                    if let product = VisilabsProduct(JSONObject: result as? [String: Any?]) {
                        products.append(product)
                    }
                }

                completion(VisilabsRecommendationResponse(products: products, error: nil))
            }
        })
    }

    private func getFiltersQueryStringValue(_ filters: [VisilabsRecommendationFilter]) -> String? {
        var queryStringValue: String?
        var abbrevatedFilters: [[String: String]] = []
        for filter in filters where filter.value.count > 0 {
            var abbrevatedFilter = [String: String]()
            abbrevatedFilter["attr"] = filter.attribute.rawValue
            abbrevatedFilter["ft"] = String(filter.filterType.rawValue)
            abbrevatedFilter["fv"] = filter.value
            abbrevatedFilters.append(abbrevatedFilter)
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: abbrevatedFilters, options: [])
            queryStringValue = String(data: jsonData, encoding: .utf8)
        } catch {
            VisilabsLogger.warn("exception serializing recommendation filters: \(error.localizedDescription)")
        }
        return queryStringValue
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
                && !propKey.isEqual(VisilabsConstants.filterKey) {
                continue
            } else {
                props.removeValue(forKey: propKey)
            }
        }
        return props
    }

}
