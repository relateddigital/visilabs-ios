//
//  VisilabsRemoteConfig.swift
//  VisilabsIOS
//
//  Created by Umut Can ALPARSLAN on 17.09.2021.
//

import Foundation
import UIKit

public class VisilabsRemoteConfig {
    
    var profileId: String
    var firstTime = true
    var lastCheckTime = Date()
    var timer: Timer?
    private let remoteConfigIntervalReadWriteLock: DispatchQueue
    private var remoteConfigFetchTimeInterval: TimeInterval
    
    init(profileId: String) {
        self.profileId = profileId
        self.remoteConfigFetchTimeInterval = VisilabsConstants.remoteConfigFetchTimeInterval
        remoteConfigIntervalReadWriteLock = DispatchQueue(label: "com.relateddigital.remote_configinterval.lock", qos: .utility, attributes: .concurrent)
        VisilabsPersistence.saveBlock(false)
        if firstTime {
            checkRemoteConfig()
        }
        startRemoteConfigTimer()
    }
    
    @objc func checkRemoteConfig() {
        
        if !firstTime, Date().addingTimeInterval(-self.remoteConfigFetchTimeInterval) > lastCheckTime {
            return
        }
        
        firstTime = false
        VisilabsRequest.sendRemoteConfigRequest { sIdArr, err in
            if let err = err {
                VisilabsLogger.error("remoteConfigSelector: Error \(err)")
                VisilabsPersistence.saveBlock(false)
            }
            if let sIdArr = sIdArr {
                if sIdArr.contains(self.profileId) {
                    VisilabsPersistence.saveBlock(true)
                } else {
                    VisilabsPersistence.saveBlock(false)
                }
            }
            self.lastCheckTime = Date()
        }
    }
    
    
    func startRemoteConfigTimer() {
        stopRemoteConfigTimer()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.timer = Timer.scheduledTimer(timeInterval: self.remoteConfigFetchTimeInterval,
                                              target: self,
                                              selector: #selector(self.checkRemoteConfig),
                                              userInfo: nil,
                                              repeats: true)
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
