//
//  VisilabsSendInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.05.2020.
//

import Foundation

protocol VisilabsSendDelegate {
    func send(completion: (() -> Void)?)
    func updateNetworkActivityIndicator(_ on: Bool)
}

class VisilabsSendInstance: AppLifecycle {
    
    
    
    
    
    // MARK: - Lifecycle
    func applicationDidBecomeActive() {
        //startFlushTimer()
    }

    func applicationWillResignActive() {
        //stopFlushTimer()
    }
}
