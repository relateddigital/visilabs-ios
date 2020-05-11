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

    class func sendRequest(visilabsEndpoint: VisilabsEndpoint, properties: [String : String], headers: [String : String], completion: @escaping ([String: String]) -> Void) {

        var queryItems = [URLQueryItem]()
        for property in properties{
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }

        let resource = VisilabsNetwork.buildResource(endPoint:visilabsEndpoint, method: .get, requestBody: nil, queryItems: queryItems, headers: headers, parse: {data in return 0} )

        flushRequestHandler(resource: resource, completion: { success in completion(success) })
    }

    private class func flushRequestHandler(resource: VisilabsResource<[String: String]>, completion: @escaping (Bool) -> Void) {

        VisilabsNetwork.apiRequest(resource: resource,
            failure: { (reason, data, response) in
                self.networkConsecutiveFailures += 1
                self.updateRetryDelay(response)
                VisilabsLogger.warn(message: "API request to \(resource.path) has failed with reason \(reason)")
                completion(false)
            }, success: { (result, response) in
                self.networkConsecutiveFailures = 0
                self.updateRetryDelay(response)
                if result == 0 {
                    Logger.info(message: "\(base) api rejected some items")
                }
                completion(true)
            })
    }

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
 
 

}
