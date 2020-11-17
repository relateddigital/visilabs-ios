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

    func customEvent(pageName: String, properties: [String: String], eventsQueue: Queue, visilabsUser: VisilabsUser, channel: String) -> (eventsQueque: Queue, visilabsUser: VisilabsUser, clearUserParameters: Bool, channel: String) {
        var props = properties
        var vUser = visilabsUser
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
                //TODO: burada cookieId generate etmek doğru mu tekrar kontrol et
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

        //TODO: Dışarıdan mobile ad id gelince neden siliyoruz?
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
        props[VisilabsConstants.uriKey] = pageName
        props[VisilabsConstants.mobileApplicationKey] = VisilabsConstants.isTrue
        props[VisilabsConstants.mobileIdKey] = vUser.identifierForAdvertising ?? ""
        props[VisilabsConstants.apiverKey] = VisilabsConstants.ios

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
        //TODO: VisilabsPersistentTargetManager.saveParameters dışarıda yapılacak

        return (eQueue, vUser, clearUserParameters, chan)
    }

}
