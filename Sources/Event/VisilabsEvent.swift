//
//  VisilabsEvent.swift
//  VisilabsIOS
//
//  Created by Egemen on 7.05.2020.
//

import Foundation

class VisilabsEvent {
    
    let visilabsProfile: VisilabsProfile
    
    init(visilabsProfile: VisilabsProfile) {
        self.visilabsProfile = visilabsProfile
    }
    
    // swiftlint:disable large_tuple function_body_length cyclomatic_complexity
    func customEvent(pageName: String? = nil,
                     properties: [String: String],
                     eventsQueue: Queue,
                     visilabsUser: VisilabsUser,
                     channel: String) -> (eventsQueque: Queue,
                                          visilabsUser: VisilabsUser,
                                          clearUserParameters: Bool,
                                          channel: String) {
        var props = properties
        var vUser = updateSessionParameters(pageName: pageName, visilabsUser: visilabsUser)
        var chan = channel
        var clearUserParameters = false
        let actualTimeOfevent = Int(Date().timeIntervalSince1970)
        
        if let cookieId = props[VisilabsConstants.cookieIdKey] {
            if vUser.cookieId != cookieId {
                clearUserParameters = true
            }
            vUser.cookieId = cookieId
            props.removeValue(forKey: VisilabsConstants.cookieIdKey)
        }
        
        if let exVisitorId = props[VisilabsConstants.exvisitorIdKey] {
            if vUser.exVisitorId != exVisitorId {
                clearUserParameters = true
            }
            if vUser.exVisitorId != nil && vUser.exVisitorId != exVisitorId {
                // TO_DO: burada cookieId generate etmek doğru mu tekrar kontrol et
                vUser.cookieId = VisilabsHelper.generateCookieId()
            }
            vUser.exVisitorId = exVisitorId
            props.removeValue(forKey: VisilabsConstants.exvisitorIdKey)
        }
        
        if let tokenId = props[VisilabsConstants.tokenIdKey] {
            vUser.tokenId = tokenId
            props.removeValue(forKey: VisilabsConstants.tokenIdKey)
        }
        
        if let appId = props[VisilabsConstants.appidKey] {
            vUser.appId = appId
            props.removeValue(forKey: VisilabsConstants.appidKey)
        }
        
        // TO_DO: Dışarıdan mobile ad id gelince neden siliyoruz?
        if props.keys.contains(VisilabsConstants.mobileIdKey) {
            props.removeValue(forKey: VisilabsConstants.mobileIdKey)
        }
        
        if props.keys.contains(VisilabsConstants.apiverKey) {
            props.removeValue(forKey: VisilabsConstants.apiverKey)
        }
        
        if props.keys.contains(VisilabsConstants.channelKey) {
            chan = props[VisilabsConstants.channelKey]!
            props.removeValue(forKey: VisilabsConstants.channelKey)
        }
        
        props[VisilabsConstants.organizationIdKey] = self.visilabsProfile.organizationId
        props[VisilabsConstants.profileIdKey] = self.visilabsProfile.profileId
        props[VisilabsConstants.cookieIdKey] = vUser.cookieId ?? ""
        props[VisilabsConstants.channelKey] = chan
        if let pageNm = pageName {
            props[VisilabsConstants.uriKey] = pageNm
        }
        props[VisilabsConstants.mobileApplicationKey] = VisilabsConstants.isTrue
        props[VisilabsConstants.mobileIdKey] = vUser.identifierForAdvertising ?? ""
        props[VisilabsConstants.apiverKey] = VisilabsConstants.ios
        props[VisilabsConstants.mobileSdkVersion] = vUser.sdkVersion
        props[VisilabsConstants.mobileAppVersion] = vUser.appVersion
        
        props[VisilabsConstants.nrvKey] = String(vUser.nrv)
        props[VisilabsConstants.pvivKey] = String(vUser.pviv)
        props[VisilabsConstants.tvcKey] = String(vUser.tvc)
        props[VisilabsConstants.lvtKey] = vUser.lvt
        
        if !vUser.exVisitorId.isNilOrWhiteSpace {
            props[VisilabsConstants.exvisitorIdKey] = vUser.exVisitorId
        }
        
        if !vUser.tokenId.isNilOrWhiteSpace {
            props[VisilabsConstants.tokenIdKey] = vUser.tokenId
        }
        
        if !vUser.appId.isNilOrWhiteSpace {
            props[VisilabsConstants.appidKey] = vUser.appId
        }
        
        props[VisilabsConstants.datKey] = String(actualTimeOfevent)
        
        var eQueue = eventsQueue
        
        eQueue.append(props)
        if eQueue.count > VisilabsConstants.queueSize {
            eQueue.remove(at: 0)
        }
        
        return (eQueue, vUser, clearUserParameters, chan)
    }
    
    private func updateSessionParameters(pageName: String?, visilabsUser: VisilabsUser) -> VisilabsUser {
        var vUser = visilabsUser
        let dateNowString = VisilabsHelper.formatDate(Date())
        if let lastEventTimeString = visilabsUser.lastEventTime {
            if isPreviousSessionOver(lastEventTimeString: lastEventTimeString, dateNowString: dateNowString) {
                vUser.pviv = 1
                vUser.tvc = vUser.tvc + 1
                if pageName != VisilabsConstants.omEvtGif {
                    vUser.lastEventTime = dateNowString
                    vUser.lvt = dateNowString
                }
            } else {
                if pageName != VisilabsConstants.omEvtGif {
                    vUser.pviv = vUser.pviv + 1
                    vUser.lastEventTime = dateNowString
                }
            }
            vUser.nrv = vUser.tvc > 1 ? 0 : 1
        } else {
            vUser.lastEventTime = dateNowString
            vUser.nrv = 1
            vUser.pviv = 1
            vUser.tvc = 1
            vUser.lvt = dateNowString
        }
        return vUser
    }
    
    private func isPreviousSessionOver(lastEventTimeString: String, dateNowString: String) -> Bool {
        if let lastEventTime = VisilabsHelper.parseDate(lastEventTimeString), let dateNow = VisilabsHelper.parseDate(dateNowString) {
            if Int(dateNow.timeIntervalSince1970) - Int(lastEventTime.timeIntervalSince1970) > (60 * 30) {
                return true
            }
        }
        return false
    }
    
}
