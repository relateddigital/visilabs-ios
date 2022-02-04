//
//  VisilabsRemoteConfig.swift
//  VisilabsIOS
//
//  Created by Umut Can ALPARSLAN on 17.09.2021.
//

import Foundation
import UIKit

public class RelatedDigitalRemoteConfig {
    
    var profileId: String
    var firstTime = true
    var lastCheckTime = Date()
    var timer: Timer?
    private var remoteConfigFetchTimeInterval: TimeInterval
    
    init(profileId: String) {
        self.profileId = profileId
        self.remoteConfigFetchTimeInterval = RelatedDigitalConstants.remoteConfigFetchTimeInterval
        RelatedDigitalPersistence.saveBlock(false)
        startRemoteConfigTimer()
    }
    
    @objc func checkRemoteConfig() {
        if !firstTime, Date().addingTimeInterval(-self.remoteConfigFetchTimeInterval) < lastCheckTime {
            return
        }
        firstTime = false
        RelatedDigitalLogger.info("Sending RemoteConfigRequest")
        RelatedDigitalRequest.sendRemoteConfigRequest { sIdArr, err in
            if let err = err {
                RelatedDigitalLogger.error("checkRemoteConfig: Error \(err)")
                RelatedDigitalPersistence.saveBlock(false)
            }
            if let sIdArr = sIdArr {
                RelatedDigitalLogger.info("Blocked profiles: \(sIdArr)")
                if sIdArr.contains(self.profileId) {
                    RelatedDigitalPersistence.saveBlock(true)
                } else {
                    RelatedDigitalPersistence.saveBlock(false)
                }
            }
            self.lastCheckTime = Date()
            self.startRemoteConfigTimer()
        }
    }
    
    func startRemoteConfigTimer() {
        stopRemoteConfigTimer()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let ti = self.firstTime ? TimeInterval(1) : self.remoteConfigFetchTimeInterval
            self.timer = Timer.scheduledTimer(timeInterval: ti,
                                              target: self,
                                              selector: #selector(self.checkRemoteConfig),
                                              userInfo: nil,
                                              repeats: false)
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
