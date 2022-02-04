//
//  VisilabsRecommendation.swift
//  VisilabsIOS
//
//  Created by Egemen on 29.06.2020.
//

import Foundation

class RelatedDigitalRecommendation {
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
            props[RelatedDigitalConstants.filterKey] = getFiltersQueryStringValue(filters)
        }

        props[RelatedDigitalConstants.organizationIdKey] = self.visilabsProfile.organizationId
        props[RelatedDigitalConstants.profileIdKey] = self.visilabsProfile.profileId
        props[RelatedDigitalConstants.cookieIdKey] = visilabsUser.cookieId
        props[RelatedDigitalConstants.exvisitorIdKey] = visilabsUser.exVisitorId
        props[RelatedDigitalConstants.tokenIdKey] = visilabsUser.tokenId
        props[RelatedDigitalConstants.appidKey] = visilabsUser.appId
        props[RelatedDigitalConstants.apiverKey] = RelatedDigitalConstants.apiverValue
        
        props[RelatedDigitalConstants.nrvKey] = String(visilabsUser.nrv)
        props[RelatedDigitalConstants.pvivKey] = String(visilabsUser.pviv)
        props[RelatedDigitalConstants.tvcKey] = String(visilabsUser.tvc)
        props[RelatedDigitalConstants.lvtKey] = visilabsUser.lvt

        if zoneID.count > 0 {
            props[RelatedDigitalConstants.zoneIdKey] = zoneID
        }
        if !productCode.isNilOrWhiteSpace {
            props[RelatedDigitalConstants.bodyKey] = productCode
        }

        for (key, value) in RelatedDigitalPersistence.readTargetParameters() {
            if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
                props[key] = value
            }
        }

        RelatedDigitalRequest.sendRecommendationRequest(properties: props,
                                                  headers: [String: String](),
                                                  timeoutInterval: visilabsProfile.requestTimeoutInterval,
                                                  completion: { (results: [Any]?, error: VisilabsError?) in
            var products = [VisilabsProduct]()
            if error != nil {
                completion(VisilabsRecommendationResponse(products: [VisilabsProduct](), error: error))
            } else {
                var widgetTitle = ""
                var counter = 0
                for result in results! {
                    if let jsonObject = result as? [String: Any?], let product = VisilabsProduct(JSONObject: jsonObject) {
                        products.append(product)
                        if counter == 0 {
                            widgetTitle = jsonObject["wdt"] as? String ?? ""
                        }
                        counter = counter + 1
                    }
                }
                completion(VisilabsRecommendationResponse(products: products, widgetTitle: widgetTitle, error: nil))
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
            RelatedDigitalLogger.warn("exception serializing recommendation filters: \(error.localizedDescription)")
        }
        return queryStringValue
    }

    private func cleanProperties(_ properties: [String: String]) -> [String: String] {
        var props = properties
        for propKey in props.keys {
            if !propKey.isEqual(RelatedDigitalConstants.organizationIdKey)
                && !propKey.isEqual(RelatedDigitalConstants.profileIdKey)
                && !propKey.isEqual(RelatedDigitalConstants.exvisitorIdKey)
                && !propKey.isEqual(RelatedDigitalConstants.cookieIdKey)
                && !propKey.isEqual(RelatedDigitalConstants.zoneIdKey)
                && !propKey.isEqual(RelatedDigitalConstants.bodyKey)
                && !propKey.isEqual(RelatedDigitalConstants.tokenIdKey)
                && !propKey.isEqual(RelatedDigitalConstants.appidKey)
                && !propKey.isEqual(RelatedDigitalConstants.apiverKey)
                && !propKey.isEqual(RelatedDigitalConstants.filterKey) {
                continue
            } else {
                props.removeValue(forKey: propKey)
            }
        }
        return props
    }

}
