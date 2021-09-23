//
//  VisilabsRemoteConfig.swift
//  VisilabsIOS
//
//  Created by Umut Can ALPARSLAN on 17.09.2021.
//

import Foundation
import UIKit

public class VisilabsRemoteConfig {
    static let isBlocked = false
    
    static func remoteRequest() {
        let remoteTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            VisilabsRequest.sendRemoteConfigRequest(properties: [String: String](), headers: [String: String](), timeoutInterval: Visilabs.callAPI().visilabsProfile.requestTimeoutInterval) { (result: [String: Any]?, error: VisilabsError?) in
                if error == nil, let res = result {
                    print("Response: \(res)") //TODO: Dönecek sonuca göre isBlocked true veya false olacak
                }
            }
        }
    }
}
