//
//  VisilabsRemoteConfig.swift
//  VisilabsIOS
//
//  Created by Umut Can ALPARSLAN on 17.09.2021.
//

import Foundation
import UIKit


protocol VisilabsRemoteConfigDelegate {
    func flush(completion: (() -> Void)?)
}

public class VisilabsRemoteConfig: VisilabsAppLifecycle {
    //tatic let isBlocked = false
    
    
    /*
    static func remoteRequest() {
        let remoteTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            VisilabsRequest.sendRemoteConfigRequest(properties: [String: String](), headers: [String: String](), timeoutInterval: Visilabs.callAPI().visilabsProfile.requestTimeoutInterval) { (result: [String: Any]?, error: VisilabsError?) in
                if error == nil, let res = result {
                    print("Response: \(res)") //TODO: Dönecek sonuca göre isBlocked true veya false olacak
                }
            }
        }
    }
     */
    
    
    var timer: Timer?
    var delegate: VisilabsRemoteConfigDelegate?
    private let remoteConfigIntervalReadWriteLock: DispatchQueue
    private var remoteConfigFetchTimeInterval: Double
    
    init(remoteConfigFetchTimeInterval: Double) {
        self.remoteConfigFetchTimeInterval = remoteConfigFetchTimeInterval
        remoteConfigIntervalReadWriteLock = DispatchQueue(label: "com.relateddigital.remote_configinterval.lock", qos: .utility, attributes: .concurrent)
        startRemoteConfigTimer()
    }
    
    

    
    @objc func flushSelector() {
        delegate?.flush(completion: nil)
    }
    
    
    func startRemoteConfigTimer() {
        stopRemoteConfigTimer()
        if remoteConfigFetchTimeInterval > 0 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.timer = Timer.scheduledTimer(timeInterval: self.remoteConfigFetchTimeInterval,
                                                     target: self,
                                                     selector: #selector(self.flushSelector),
                                                     userInfo: nil,
                                                     repeats: true)
            }
        }
    }
    
    func stopRemoteConfigTimer() {
        if let timer = timer {
            DispatchQueue.main.async { [weak self, timer] in
                timer.invalidate()
                self?.timer = nil
            }
        }
    }
    
    
    func applicationDidBecomeActive() {
        startRemoteConfigTimer()
    }

    func applicationWillResignActive() {
        stopRemoteConfigTimer()
    }
    
}
