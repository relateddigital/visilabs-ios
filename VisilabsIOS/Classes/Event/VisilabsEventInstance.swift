//
//  VisilabsEventInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 7.05.2020.
//

import Foundation

class VisilabsEventInstance {
    let organizationId: String
    let siteId: String
    
    //TODO: lock kullanılmıyor kaldırılabilir
    let lock: VisilabsReadWriteLock

    init(organizationId: String, siteId: String, lock: VisilabsReadWriteLock) {
        self.organizationId = organizationId
        self.siteId = siteId
        self.lock = lock
    }
    
    func customEvent(pageName: String, properties: [String:String], eventsQueue: Queue, visilabsUser: VisilabsUser, channel: String) -> (eventsQueque: Queue, visilabsUser: VisilabsUser, clearUserParameters: Bool, channel: String) {
        var props = properties
        var vUser = visilabsUser
        var chan = channel
        var clearUserParameters = false
        let actualTimeOfevent = Int(Date().timeIntervalSince1970)
        
        if let cookieId = props[VisilabsConstants.COOKIEID_KEY] {
            if vUser.cookieId != cookieId {
                clearUserParameters = true
            }
            vUser.cookieId = cookieId
            props.removeValue(forKey: VisilabsConstants.COOKIEID_KEY)
        }
        
        if let exVisitorId = props[VisilabsConstants.EXVISITORID_KEY] {
            if vUser.exVisitorId != exVisitorId {
                clearUserParameters = true
            }
            if vUser.exVisitorId != nil && vUser.exVisitorId != exVisitorId {
                //TODO: burada cookieId generate etmek doğru mu tekrar kontrol et
                vUser.cookieId = VisilabsHelper.generateCookieId()
            }
            vUser.exVisitorId = exVisitorId
            props.removeValue(forKey: VisilabsConstants.EXVISITORID_KEY)
        }
        
        if let tokenId = props[VisilabsConstants.TOKENID_KEY] {
            vUser.tokenId = tokenId
            props.removeValue(forKey: VisilabsConstants.TOKENID_KEY)
        }
        
        if let appId = props[VisilabsConstants.APPID_KEY]{
            vUser.appId = appId
            props.removeValue(forKey: VisilabsConstants.APPID_KEY)
        }
        
        //TODO: Dışarıdan mobile ad id gelince neden siliyoruz?
        if props.keys.contains(VisilabsConstants.MOBILEADID_KEY) {
            props.removeValue(forKey: VisilabsConstants.MOBILEADID_KEY)
        }
        
        if props.keys.contains(VisilabsConstants.APIVER_KEY) {
            props.removeValue(forKey: VisilabsConstants.APIVER_KEY)
        }
        
        if props.keys.contains(VisilabsConstants.CHANNEL_KEY) {
            chan = props[VisilabsConstants.CHANNEL_KEY]!
            props.removeValue(forKey: VisilabsConstants.CHANNEL_KEY)
        }
        
        props[VisilabsConstants.ORGANIZATIONID_KEY] = self.organizationId
        props[VisilabsConstants.PROFILEID_KEY] = self.siteId
        props[VisilabsConstants.COOKIEID_KEY] = vUser.cookieId ?? ""
        props[VisilabsConstants.CHANNEL_KEY] = chan
        props[VisilabsConstants.URI_KEY] = pageName
        props[VisilabsConstants.MOBILEAPPLICATION_KEY] = VisilabsConstants.TRUE
        props[VisilabsConstants.MOBILEADID_KEY] = vUser.identifierForAdvertising ?? ""
        props[VisilabsConstants.APIVER_KEY] = VisilabsConstants.IOS
        
        if !vUser.exVisitorId.isNilOrWhiteSpace {
            props[VisilabsConstants.EXVISITORID_KEY] = vUser.exVisitorId
        }
        
        if !vUser.tokenId.isNilOrWhiteSpace{
            props[VisilabsConstants.TOKENID_KEY] = vUser.tokenId
        }
        
        if !vUser.appId.isNilOrWhiteSpace{
            props[VisilabsConstants.APPID_KEY] = vUser.appId
        }
        
        props[VisilabsConstants.DAT_KEY] = String(actualTimeOfevent)
        

        var eQueue = eventsQueue
        
        eQueue.append(props)
        if eQueue.count > VisilabsConstants.QUEUE_SIZE {
            eQueue.remove(at: 0)
        }
        //TODO: VisilabsPersistentTargetManager.saveParameters dışarıda yapılacak
        
        return (eQueue, vUser, clearUserParameters, chan)
    }

}
