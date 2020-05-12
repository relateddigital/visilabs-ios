//
//  VisilabsInAppNotificationRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.05.2020.
//

import Foundation

class VisilabsInAppNotificationRequest: VisilabsNetwork {
    
    //TODO: completion Any mi olmalı, yoksa AnyObject mi?
    func sendRequest(properties: [String : String], headers: [String : String], timeoutInterval: TimeInterval, completion: @escaping ([Any?]?) -> Void) {
        
    }
}
