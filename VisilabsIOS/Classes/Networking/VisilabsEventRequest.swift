//
//  VisilabsEventRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 7.05.2020.
//

import Foundation

class VisilabsEventRequest: VisilabsNetwork {

    var networkRequestsAllowedAfterTime = 0.0
    var networkConsecutiveFailures = 0

    class func sendRequest(visilabsEndpoint: VisilabsEndpoint, properties: [String : String], headers: [String : String], timeoutInterval: TimeInterval, completion: @escaping ([String : String]?) -> Void) {

        var queryItems = [URLQueryItem]()
        for property in properties{
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }

        let resource = VisilabsNetwork.buildResource(endPoint:visilabsEndpoint, method: .get, timeoutInterval: timeoutInterval, requestBody: nil, queryItems: queryItems, headers: headers, parse: {data in return true} )

        sendRequestHandler(resource: resource, completion: { success in completion(success) })
    }

    private class func sendRequestHandler(resource: VisilabsResource<Bool>, completion: @escaping ([String : String]?) -> Void) {

        VisilabsNetwork.apiRequest(resource: resource,
            failure: { (reason, data, response) in
                
                //self.networkConsecutiveFailures += 1
                //self.updateRetryDelay(response)
                var requestUrl = VisilabsBasePath.getEndpoint(visilabsEndpoint: resource.endPoint)
                if let httpResponse = response as? HTTPURLResponse {
                    if let url = httpResponse.url{
                        requestUrl = url.absoluteString
                    }
                }
                VisilabsLogger.warn(message: "API request to \(requestUrl) has failed with reason \(reason)")
                completion(nil)
            }, success: { (result, response) in
                
                if let httpResponse = response as? HTTPURLResponse, let url = httpResponse.url {
                    VisilabsLogger.info(message: "\(url.absoluteString) request sent successfully")
                    let cookies = getCookies(url)
                    completion(cookies)
                }else{
                    VisilabsLogger.warn(message: "\(VisilabsBasePath.getEndpoint(visilabsEndpoint: resource.endPoint)) can not convert to HTTPURLResponse")
                    completion(nil)
                }
                
            })
    }
    
    private class func getCookies(_ url: URL) -> [String : String]{
        var cookieKeyValues = [String : String]()
        for cookie in VisilabsHelper.readCookie(url){
            if cookie.name.contains(VisilabsConfig.LOAD_BALANCE_PREFIX, options: .caseInsensitive){
                cookieKeyValues[cookie.name] = cookie.value
            }
            if cookie.name.contains(VisilabsConfig.OM_3_KEY, options: .caseInsensitive){
                cookieKeyValues[cookie.name] = cookie.value
            }
        }
        return cookieKeyValues
    }
}
