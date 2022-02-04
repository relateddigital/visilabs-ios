//
//  VisilabsEvent.swift
//  VisilabsIOS
//
//  Created by Egemen on 7.05.2020.
//

import Foundation

class RelatedDigitalEvent {
    
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
        
        if let cookieId = props[RelatedDigitalConstants.cookieIdKey] {
            if vUser.cookieId != cookieId {
                clearUserParameters = true
            }
            vUser.cookieId = cookieId
            props.removeValue(forKey: RelatedDigitalConstants.cookieIdKey)
        }
        
        if let exVisitorId = props[RelatedDigitalConstants.exvisitorIdKey] {
            if vUser.exVisitorId != exVisitorId {
                clearUserParameters = true
            }
            if vUser.exVisitorId != nil && vUser.exVisitorId != exVisitorId {
                // TO_DO: burada cookieId generate etmek doğru mu tekrar kontrol et
                vUser.cookieId = RelatedDigitalHelper.generateCookieId()
            }
            vUser.exVisitorId = exVisitorId
            props.removeValue(forKey: RelatedDigitalConstants.exvisitorIdKey)
        }
        
        if let tokenId = props[RelatedDigitalConstants.tokenIdKey] {
            vUser.tokenId = tokenId
            props.removeValue(forKey: RelatedDigitalConstants.tokenIdKey)
        }
        
        if let appId = props[RelatedDigitalConstants.appidKey] {
            vUser.appId = appId
            props.removeValue(forKey: RelatedDigitalConstants.appidKey)
        }
        
        // TO_DO: Dışarıdan mobile ad id gelince neden siliyoruz?
        if props.keys.contains(RelatedDigitalConstants.mobileIdKey) {
            props.removeValue(forKey: RelatedDigitalConstants.mobileIdKey)
        }
        
        if props.keys.contains(RelatedDigitalConstants.apiverKey) {
            props.removeValue(forKey: RelatedDigitalConstants.apiverKey)
        }
        
        if props.keys.contains(RelatedDigitalConstants.channelKey) {
            chan = props[RelatedDigitalConstants.channelKey]!
            props.removeValue(forKey: RelatedDigitalConstants.channelKey)
        }
        
        props[RelatedDigitalConstants.organizationIdKey] = self.visilabsProfile.organizationId
        props[RelatedDigitalConstants.profileIdKey] = self.visilabsProfile.profileId
        props[RelatedDigitalConstants.cookieIdKey] = vUser.cookieId ?? ""
        props[RelatedDigitalConstants.channelKey] = chan
        if let pageNm = pageName {
            props[RelatedDigitalConstants.uriKey] = pageNm
        }
        props[RelatedDigitalConstants.mobileApplicationKey] = RelatedDigitalConstants.isTrue
        props[RelatedDigitalConstants.mobileIdKey] = vUser.identifierForAdvertising ?? ""
        props[RelatedDigitalConstants.apiverKey] = RelatedDigitalConstants.ios
        props[RelatedDigitalConstants.mobileSdkVersion] = vUser.sdkVersion
        props[RelatedDigitalConstants.mobileAppVersion] = vUser.appVersion
        
        props[RelatedDigitalConstants.nrvKey] = String(vUser.nrv)
        props[RelatedDigitalConstants.pvivKey] = String(vUser.pviv)
        props[RelatedDigitalConstants.tvcKey] = String(vUser.tvc)
        props[RelatedDigitalConstants.lvtKey] = vUser.lvt
        
        if !vUser.exVisitorId.isNilOrWhiteSpace {
            props[RelatedDigitalConstants.exvisitorIdKey] = vUser.exVisitorId
        }
        
        if !vUser.tokenId.isNilOrWhiteSpace {
            props[RelatedDigitalConstants.tokenIdKey] = vUser.tokenId
        }
        
        if !vUser.appId.isNilOrWhiteSpace {
            props[RelatedDigitalConstants.appidKey] = vUser.appId
        }
        
        props[RelatedDigitalConstants.datKey] = String(actualTimeOfevent)
        
        var eQueue = eventsQueue
        
        eQueue.append(props)
        if eQueue.count > RelatedDigitalConstants.queueSize {
            eQueue.remove(at: 0)
        }
        
        return (eQueue, vUser, clearUserParameters, chan)
    }
    
    private func updateSessionParameters(pageName: String?, visilabsUser: VisilabsUser) -> VisilabsUser {
        var vUser = visilabsUser
        let dateNowString = RelatedDigitalHelper.formatDate(Date())
        if let lastEventTimeString = visilabsUser.lastEventTime {
            if isPreviousSessionOver(lastEventTimeString: lastEventTimeString, dateNowString: dateNowString) {
                vUser.pviv = 1
                vUser.tvc = vUser.tvc + 1
                if pageName != RelatedDigitalConstants.omEvtGif {
                    vUser.lastEventTime = dateNowString
                    vUser.lvt = dateNowString
                }
            } else {
                if pageName != RelatedDigitalConstants.omEvtGif {
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
        if let lastEventTime = RelatedDigitalHelper.parseDate(lastEventTimeString), let dateNow = RelatedDigitalHelper.parseDate(dateNowString) {
            if Int(dateNow.timeIntervalSince1970) - Int(lastEventTime.timeIntervalSince1970) > (60 * 30) {
                return true
            }
        }
        return false
    }
    
}
