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

    class func sendRequest(visilabsEndpoint: VisilabsEndpoint, properties: [String : String], headers: [String : String], completion: @escaping ([String : String]?) -> Void) {

        var queryItems = [URLQueryItem]()
        for property in properties{
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }

        let resource = VisilabsNetwork.buildResource(endPoint:visilabsEndpoint, method: .get, requestBody: nil, queryItems: queryItems, headers: headers, parse: {data in return true} )

        flushRequestHandler(resource: resource, completion: { success in completion(success) })
    }

    private class func flushRequestHandler(resource: VisilabsResource<Bool>, completion: @escaping ([String : String]?) -> Void) {

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
                    var cookies = getCookies(httpResponse.allHeaderFields["Set-Cookie"])
                    completion(cookies)
                }else{
                    VisilabsLogger.warn(message: "\(VisilabsBasePath.getEndpoint(visilabsEndpoint: resource.endPoint)) can not convert to HTTPURLResponse")
                    completion(nil)
                }
                
                //self.networkConsecutiveFailures = 0
                //self.updateRetryDelay(response)
               
                
            })
    }
    
    private class func getCookies(_ cookieValue: Any?) -> [String : String]{
        var cookieKeyValues = [String : String]()
        if let cookieString = cookieValue as? String {
            let cookies = cookieString.split(separator: ";")
            for cookie in cookies{
                let cookieParts = cookie.split(separator: "=")
                if cookieParts.count == 2 {
                    
                }
            }
        }
        return cookieKeyValues
    }

    /*
    private class func updateRetryDelay(_ response: URLResponse?) {
        var retryTime = 0.0
        let retryHeader = (response as? HTTPURLResponse)?.allHeaderFields["Retry-After"] as? String
        if let retryHeader = retryHeader, let retryHeaderParsed = (Double(retryHeader)) {
            retryTime = retryHeaderParsed
        }

        if networkConsecutiveFailures >= APIConstants.failuresTillBackoff {
            retryTime = max(retryTime,
                            retryBackOffTimeWithConsecutiveFailures(networkConsecutiveFailures))
        }
        let retryDate = Date(timeIntervalSinceNow: retryTime)
        networkRequestsAllowedAfterTime = retryDate.timeIntervalSince1970
    }

    private func retryBackOffTimeWithConsecutiveFailures(_ failureCount: Int) -> TimeInterval {
        let time = pow(2.0, Double(failureCount) - 1) * 60 + Double(arc4random_uniform(30))
        return min(max(APIConstants.minRetryBackoff, time),
                   APIConstants.maxRetryBackoff)
    }

    func requestNotAllowed() -> Bool {
        return Date().timeIntervalSince1970 < networkRequestsAllowedAfterTime
    }
 */
 
 

}
