//
//  VisilabsRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 6.08.2020.
//

import Foundation

class VisilabsRequest {

    // MARK: - Event

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

    // MARK: - Recommendation

    //TO_DO: completion Any mi olmalı, yoksa AnyObject mi?
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

    // MARK: - InAppNotification

    //TO_DO: completion Any mi olmalı, yoksa AnyObject mi?
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

    // MARK: - Geofence

    //https://s.visilabs.net/geojson?OM.oid=676D325830564761676D453D&OM
    //.siteID=356467332F6533766975593D&OM.cookieID=B220EC66-A746-4130-93FD-53543055E406&OM
    //.exVisitorID=ogun.ozturk%40euromsg.com&act=getlist
    //[{"actid":145,"trgevt":"OnEnter","dis":0,"geo":
    //[{"id":4,"lat":41.0236665831979,"long":29.1222883408907,"rds":290.9502}]}]
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

    // MARK: - Mobile
    //https://s.visilabs.net/mobile?OM.oid=676D325830564761676D453D&OM
    //.siteID=356467332F6533766975593D&OM.cookieID=B220EC66-A746-4130-93FD-53543055E406&OM
    //.exVisitorID=ogun.ozturk%40euromsg.com&action_id=188&action_type=FavoriteAttributeAction&OM.apiver=IOS
    //{"capping":"{\"data\":{}}","VERSION":1,"FavoriteAttributeAction":[{"actid":188,"title":"fav-test",
    //"actiontype":"FavoriteAttributeAction","actiondata":{"attributes":["category","brand"],
    //"favorites":{"category":["6","8","2"],"brand":["Kozmo","Luxury Room","OFS"]}}}]}
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
    
    class func sendSubsJsonRequest(properties: [String: String],
                                   headers: [String: String],
                                   timeOutInterval: TimeInterval,
                                   guid: String? = nil) {
        var queryItems = [URLQueryItem]()
        for property in properties {
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }
        
        let responseParser: (Data) -> String? = { data in
            return String(data: data, encoding: .utf8)
        }
        
        let resource  = VisilabsNetwork.buildResource(endPoint: .subsjson,
                                                      method: .get,
                                                      timeoutInterval: timeOutInterval,
                                                      requestBody: nil,
                                                      queryItems: queryItems,
                                                      headers: headers,
                                                      parse: responseParser,
                                                      guid: guid)
        
        VisilabsNetwork.apiRequest(resource: resource,
            failure: { (error, _, _) in
                VisilabsLogger.error("API request to \(resource.endPoint) has failed with error \(error)")
            }, success: { (_, _) in
                print("Successfully sent!")
            })

        
    }
    
    //TODO: implement send subsjsonRequest

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
}
