//
//  VisilabsInAppNotificationRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.05.2020.
//

import Foundation
/*
class VisilabsInAppNotificationRequest: VisilabsNetwork {
    
    //TODO: completion Any mi olmalı, yoksa AnyObject mi?
    class func sendRequest(properties: [String : String], headers: [String : String], timeoutInterval: TimeInterval, completion: @escaping ([[String: Any]]?) -> Void) {
        var queryItems = [URLQueryItem]()
        for property in properties{
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }
        
        let responseParser: (Data) -> [[String: Any]]? = { data in
            var response: Any? = nil
            do {
                response = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                VisilabsLogger.warn(message: "exception decoding api data")
            }
            return response as? [[String: Any]]
        }
        
        let resource = VisilabsNetwork.buildResource(endPoint: .action, method: .get, timeoutInterval: timeoutInterval, requestBody: nil, queryItems: queryItems, headers: headers, parse: responseParser )
        
        sendRequestHandler(resource: resource, completion: { result in completion(result) })
        
    }
    
    private class func sendRequestHandler(resource: VisilabsResource<[[String: Any]]>, completion: @escaping ([[String: Any]]?) -> Void) {
        VisilabsNetwork.apiRequest(resource: resource,
            failure: { (reason, data, response) in
                VisilabsLogger.warn(message: "API request to \(resource.endPoint) has failed with reason \(reason)")
                completion(nil)
            }, success: { (result, response) in
                completion(result)
            })
    }
}
*/
