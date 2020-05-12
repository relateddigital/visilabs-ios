//
//  VisilabsInAppNotificationRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.05.2020.
//

import Foundation

class VisilabsInAppNotificationRequest: VisilabsNetwork {
    
    //TODO: completion Any mi olmalı, yoksa AnyObject mi?
    class func sendRequest(properties: [String : String], headers: [String : String], timeoutInterval: TimeInterval, completion: @escaping (VisilabsInAppNotificationResponse?) -> Void) {
        var queryItems = [URLQueryItem]()
        for property in properties{
            queryItems.append(URLQueryItem(name: property.key, value: property.value))
        }
    }
}
