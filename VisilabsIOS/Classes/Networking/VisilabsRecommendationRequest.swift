//
//  VisilabsRecommendationRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 30.06.2020.
//

import Foundation

/*
class VisilabsRecommendationRequest {
    
    //TODO: completion Any mi olmalı, yoksa AnyObject mi?
    class func sendRequest(properties: [String : String], headers: [String : String], timeoutInterval: TimeInterval, completion: @escaping ([Any]?, VisilabsReason?) -> Void) {
        var queryItems = [URLQueryItem]()
        for property in properties{
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }
        
        let responseParser: (Data) -> [Any]? = { data in
            var response: Any? = nil
            do {
                response = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                VisilabsLogger.warn(message: "exception decoding api data")
            }
            return response as? [Any]
        }
        
        let resource = VisilabsNetwork.buildResource(endPoint: .target, method: .get, timeoutInterval: timeoutInterval, requestBody: nil, queryItems: queryItems, headers: headers, parse: responseParser )
        
        sendRequestHandler(resource: resource, completion: { result, reason in completion(result, reason) })
        
    }
    
    private class func sendRequestHandler(resource: VisilabsResource<[Any]>, completion: @escaping ([Any]?, VisilabsReason?) -> Void) {
        VisilabsNetwork.apiRequest(resource: resource,
            failure: { (reason, data, response) in
                VisilabsLogger.warn(message: "API request to \(resource.endPoint) has failed with reason \(reason)")
                completion(nil, reason)
            }, success: { (result, response) in
                completion(result, nil)
            })
    }
}
*/
