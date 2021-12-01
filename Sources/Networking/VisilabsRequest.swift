//
//  VisilabsRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 6.08.2020.
//

import Foundation

class VisilabsRequest {
    
    // MARK: - EVENT
    
    class func sendEventRequest(visilabsEndpoint: VisilabsEndpoint,
                                properties: [String: String],
                                headers: [String: String],
                                timeoutInterval: TimeInterval,
                                completion: @escaping ([String: String]?) -> Void) {
        
        var queryItems = [URLQueryItem]()
        for property in properties {
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }
        
        let resource = VisilabsNetwork.buildResource(endPoint: visilabsEndpoint,
                                                     method: .get,
                                                     timeoutInterval: timeoutInterval,
                                                     requestBody: nil,
                                                     queryItems: queryItems,
                                                     headers: headers,
                                                     parse: {_ in return true})
        
        sendEventRequestHandler(resource: resource, completion: { success in completion(success) })
    }
    
    private class func sendEventRequestHandler(resource: VisilabsResource<Bool>,
                                               completion: @escaping ([String: String]?) -> Void) {
        VisilabsNetwork.apiRequest(resource: resource,
                                   failure: { (error, _, response) in
            
            var requestUrl = VisilabsBasePath.getEndpoint(visilabsEndpoint: resource.endPoint)
            if let httpResponse = response as? HTTPURLResponse {
                if let url = httpResponse.url {
                    requestUrl = url.absoluteString
                }
            }
            VisilabsLogger.error("API request to \(requestUrl) has failed with error \(error)")
            completion(nil)
        }, success: { (_, response) in
            
            if let httpResponse = response as? HTTPURLResponse, let url = httpResponse.url {
                VisilabsLogger.info("\(url.absoluteString) request sent successfully")
                let cookies = getCookies(url)
                completion(cookies)
            } else {
                let end = VisilabsBasePath.getEndpoint(visilabsEndpoint: resource.endPoint)
                VisilabsLogger.error("\(end) can not convert to HTTPURLResponse")
                completion(nil)
            }
            
        })
    }
    
    private class func getCookies(_ url: URL) -> [String: String] {
        var cookieKeyValues = [String: String]()
        for cookie in VisilabsHelper.readCookie(url) {
            if cookie.name.contains(VisilabsConstants.loadBalancePrefix, options: .caseInsensitive) {
                cookieKeyValues[cookie.name] = cookie.value
            }
            if cookie.name.contains(VisilabsConstants.om3Key, options: .caseInsensitive) {
                cookieKeyValues[cookie.name] = cookie.value
            }
        }
        return cookieKeyValues
    }
    
    // MARK: - RECOMMENDATION
    
    // TO_DO: completion Any mi olmalı, yoksa AnyObject mi?
    class func sendRecommendationRequest(properties: [String: String],
                                         headers: [String: String],
                                         timeoutInterval: TimeInterval,
                                         completion: @escaping ([Any]?, VisilabsError?) -> Void) {
        
        var queryItems = [URLQueryItem]()
        for property in properties {
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }
        
        let responseParser: (Data) -> [Any]? = { data in
            var response: Any?
            do {
                response = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                VisilabsLogger.error("exception decoding api data")
            }
            return response as? [Any]
        }
        
        let resource = VisilabsNetwork.buildResource(endPoint: .target,
                                                     method: .get,
                                                     timeoutInterval: timeoutInterval,
                                                     requestBody: nil,
                                                     queryItems: queryItems,
                                                     headers: headers,
                                                     parse: responseParser)
        
        sendRecommendationRequestHandler(resource: resource, completion: { result, error in completion(result, error) })
        
    }
    
    private class func sendRecommendationRequestHandler(resource: VisilabsResource<[Any]>,
                                                        completion: @escaping ([Any]?, VisilabsError?) -> Void) {
        VisilabsNetwork.apiRequest(resource: resource,
                                   failure: { (error, _, _) in
            VisilabsLogger.error("API request to \(resource.endPoint) has failed with error \(error)")
            completion(nil, error)
        }, success: { (result, _) in
            completion(result, nil)
        })
    }
    
    // MARK: - TARGETING ACTIONS
    
    // MARK: - Geofence
    
    class func sendGeofenceRequest(properties: [String: String],
                                   headers: [String: String],
                                   timeoutInterval: TimeInterval,
                                   completion: @escaping ([[String: Any]]?, VisilabsError?) -> Void) {
        
        var queryItems = [URLQueryItem]()
        for property in properties {
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }
        
        if properties[VisilabsConstants.actKey] == VisilabsConstants.getList {
            let responseParserGetList: (Data) -> [[String: Any]]? = { data in
                var response: Any?
                do {
                    response = try JSONSerialization.jsonObject(with: data, options: [])
                } catch {
                    VisilabsLogger.error("exception decoding api data")
                }
                return response as? [[String: Any]]
            }
            let resource = VisilabsNetwork.buildResource(endPoint: .geofence,
                                                         method: .get,
                                                         timeoutInterval: timeoutInterval,
                                                         requestBody: nil,
                                                         queryItems: queryItems,
                                                         headers: headers,
                                                         parse: responseParserGetList)
            sendGeofenceRequestHandler(resource: resource, completion: { result, error in completion(result, error) })
        } else {
            let responseParserSendPush: (Data) -> String = { _ in return "" }
            let resource = VisilabsNetwork.buildResource(endPoint: .geofence,
                                                         method: .get,
                                                         timeoutInterval: timeoutInterval,
                                                         requestBody: nil,
                                                         queryItems: queryItems,
                                                         headers: headers,
                                                         parse: responseParserSendPush)
            sendGeofencePushRequestHandler(resource: resource, completion: { _, error in completion(nil, error) })
        }
    }
    
    private class func sendGeofencePushRequestHandler(resource: VisilabsResource<String>,
                                                      completion: @escaping (String?, VisilabsError?) -> Void) {
        VisilabsNetwork.apiRequest(resource: resource,
                                   failure: { (error, _, _) in
            VisilabsLogger.error("API request to \(resource.endPoint) has failed with error \(error)")
            completion(nil, error)
        }, success: { (result, _) in
            completion(result, nil)
        })
    }
    
    private class func sendGeofenceRequestHandler(resource: VisilabsResource<[[String: Any]]>,
                                                  completion: @escaping ([[String: Any]]?, VisilabsError?) -> Void) {
        VisilabsNetwork.apiRequest(resource: resource,
                                   failure: { (error, _, _) in
            VisilabsLogger.error("API request to \(resource.endPoint) has failed with error \(error)")
            completion(nil, error)
        }, success: { (result, _) in
            completion(result, nil)
        })
    }
    
    // MARK: - InAppNotification
    
    // TO_DO: completion Any mi olmalı, yoksa AnyObject mi?
    class func sendInAppNotificationRequest(properties: [String: String],
                                            headers: [String: String],
                                            timeoutInterval: TimeInterval,
                                            completion: @escaping ([[String: Any]]?) -> Void) {
        
        var queryItems = [URLQueryItem]()
        for property in properties {
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }
        
        let responseParser: (Data) -> [[String: Any]]? = { data in
            var response: Any?
            do {
                response = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                VisilabsLogger.error("exception decoding api data")
            }
            return response as? [[String: Any]]
        }
        
        let resource = VisilabsNetwork.buildResource(endPoint: .action,
                                                     method: .get,
                                                     timeoutInterval: timeoutInterval,
                                                     requestBody: nil,
                                                     queryItems: queryItems,
                                                     headers: headers,
                                                     parse: responseParser)
        
        sendInAppNotificationRequestHandler(resource: resource, completion: { result in completion(result) })
        
    }
    
    private class func sendInAppNotificationRequestHandler(resource: VisilabsResource<[[String: Any]]>,
                                                           completion: @escaping ([[String: Any]]?) -> Void) {
        VisilabsNetwork.apiRequest(resource: resource,
                                   failure: { (error, _, _) in
            VisilabsLogger.error("API request to \(resource.endPoint) has failed with error \(error)")
            completion(nil)
        }, success: { (result, _) in
            completion(result)
        })
    }
    
    // MARK: - Mobile
    
    class func sendMobileRequest(properties: [String: String],
                                 headers: [String: String],
                                 timeoutInterval: TimeInterval,
                                 completion: @escaping ([String: Any]?, VisilabsError?, String?) -> Void,
                                 guid: String? = nil) {
        
        var queryItems = [URLQueryItem]()
        for property in properties {
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }
        
        let responseParser: (Data) -> [String: Any]? = { data in
            var response: Any?
            do {
                response = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                VisilabsLogger.error("exception decoding api data")
            }
            return response as? [String: Any]
        }
        
        let resource = VisilabsNetwork.buildResource(endPoint: .mobile,
                                                     method: .get,
                                                     timeoutInterval: timeoutInterval,
                                                     requestBody: nil,
                                                     queryItems: queryItems,
                                                     headers: headers,
                                                     parse: responseParser,
                                                     guid: guid)
        
        sendMobileRequestHandler(resource: resource,
                                 completion: { result, error, guid in completion(result, error, guid)})
        
    }
    
    private class func sendMobileRequestHandler(resource: VisilabsResource<[String: Any]>,
                                                completion: @escaping ([String: Any]?,
                                                                       VisilabsError?, String?) -> Void) {
        VisilabsNetwork.apiRequest(resource: resource,
                                   failure: { (error, _, _) in
            VisilabsLogger.error("API request to \(resource.endPoint) has failed with error \(error)")
            completion(nil, error, resource.guid)
        }, success: { (result, _) in
            completion(result, nil, resource.guid)
        })
    }
    
    class func sendPromotionCodeRequest(properties: [String: String],
                                        completion: @escaping ([String: Any]?, VisilabsError?) -> Void) {
        
        let props = getDefaultQueryStringParameters().merging(properties) { (_, new) in new }
        
        var queryItems = [URLQueryItem]()
        for prop in props {
            queryItems.append(URLQueryItem(name: prop.key, value: prop.value))
        }
        
        let responseParser: (Data) -> [String: Any]? = { data in
            var response: Any?
            do {
                response = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                VisilabsLogger.error("exception decoding api data")
            }
            return response as? [String: Any]
        }
        
        let resource = VisilabsNetwork.buildResource(endPoint: .promotion,
                                                     method: .get,
                                                     timeoutInterval: Visilabs.callAPI().visilabsProfile.requestTimeoutInterval,
                                                     requestBody: nil,
                                                     queryItems: queryItems,
                                                     headers: [String: String](),
                                                     parse: responseParser)
        
        sendPromotionCodeRequestHandler(resource: resource,
                                        completion: { result, error in completion(result, error)})
        
    }
    
    private class func sendPromotionCodeRequestHandler(resource: VisilabsResource<[String: Any]>,
                                                       completion: @escaping ([String: Any]?,
                                                                              VisilabsError?) -> Void) {
        VisilabsNetwork.apiRequest(resource: resource,
                                   failure: { (error, _, _) in
            VisilabsLogger.error("API request to \(resource.endPoint) has failed with error \(error)")
            completion(nil, error)
        }, success: { (result, _) in
            completion(result, nil)
        })
    }
    
    class func sendSubsJsonRequest(properties: [String: String]) {
        
        let props = properties.merging(getDefaultQueryStringParameters()) { (_, new) in new }
        
        var queryItems = [URLQueryItem]()
        for prop in props {
            queryItems.append(URLQueryItem(name: prop.key, value: prop.value))
        }
        
        let responseParser: (Data) -> String? = { data in
            return String(data: data, encoding: .utf8)
        }
        
        let resource  = VisilabsNetwork.buildResource(endPoint: .subsjson,
                                                      method: .get,
                                                      timeoutInterval: Visilabs.callAPI().visilabsProfile.requestTimeoutInterval,
                                                      requestBody: nil,
                                                      queryItems: queryItems,
                                                      headers: [String: String]() ,
                                                      parse: responseParser,
                                                      guid: nil)
        
        VisilabsNetwork.apiRequest(resource: resource,
                                   failure: { (error, _, _) in
            VisilabsLogger.error("API request to \(resource.endPoint) has failed with error \(error)")
        }, success: { (_, _) in
            print("Successfully sent!")
        })
        
    }
    
    class func sendRemoteConfigRequest(completion: @escaping ([String]?, VisilabsError?) -> Void) {

        
        let responseParser: (Data) -> [String]? = { data in
            var response: Any?
            do {
                response = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                VisilabsLogger.error("exception decoding remote config data")
            }
            return response as? [String]
        }
        
        var headers = [String: String]()
        if let userAgent = Visilabs.callAPI().visilabsUser.userAgent {
            headers =  ["User-Agent": userAgent]
        }
        
        let resource = VisilabsNetwork.buildResource(endPoint: .remote ,
                                                     method: .get,
                                                     timeoutInterval: Visilabs.callAPI().visilabsProfile.requestTimeoutInterval,
                                                     headers: headers,
                                                     parse: responseParser)
        
        sendRemoteConfigRequestHandler(resource: resource, completion: { result, error in completion(result, error)})
        
    }
    
    private class func sendRemoteConfigRequestHandler(resource: VisilabsResource<[String]>,
                                                      completion: @escaping ([String]?,
                                                                             VisilabsError?) -> Void) {
        VisilabsNetwork.apiRequest(resource: resource,
                                   failure: { (error, _, _) in
            VisilabsLogger.error("API request to \(resource.endPoint) has failed with error \(error)")
            completion(nil, error)
        }, success: { (result, _) in
            completion(result, nil)
        })
    }
    
    private class func getDefaultQueryStringParameters() -> [String: String] {
        
        var props = [String: String]()
        
        if let vProfile = Visilabs.callAPI().visilabsProfile {
            props[VisilabsConstants.organizationIdKey] = vProfile.organizationId
            props[VisilabsConstants.profileIdKey] = vProfile.profileId
            props[VisilabsConstants.channelKey] = vProfile.channel
            props[VisilabsConstants.mobileApplicationKey] = VisilabsConstants.isTrue
            props[VisilabsConstants.apiverKey] = VisilabsConstants.ios
        }
        
        if let vUser = Visilabs.callAPI().visilabsUser {
            props[VisilabsConstants.cookieIdKey] = vUser.cookieId
            props[VisilabsConstants.exvisitorIdKey] = vUser.exVisitorId
            props[VisilabsConstants.mobileSdkVersion] = vUser.sdkVersion
            props[VisilabsConstants.mobileAppVersion] = vUser.appVersion
            props[VisilabsConstants.mobileIdKey] = vUser.identifierForAdvertising ?? ""
            props[VisilabsConstants.nrvKey] = String(vUser.nrv)
            props[VisilabsConstants.pvivKey] = String(vUser.pviv)
            props[VisilabsConstants.tvcKey] = String(vUser.tvc)
            props[VisilabsConstants.lvtKey] = vUser.lvt
        }
        return props
    }
    
}
