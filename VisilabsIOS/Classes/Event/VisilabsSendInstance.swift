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


//TODO: lock kullanılımıyor sanki, kaldırılabilir
class VisilabsSendInstance: AppLifecycle {
    
    //TODO: bu delegate kullanılmıyor. kaldır.
    var delegate: VisilabsSendDelegate?
    
    
    //TODO: burada internet bağlantısı kontrolü yapmaya gerek var mı?
    func sendEventsQueue(_ eventsQueue: Queue, visilabsUser: VisilabsUser, visilabsCookie: VisilabsCookie, timeoutInterval: TimeInterval) -> VisilabsCookie {
        var mutableCookie = visilabsCookie
        
        for i in 0..<eventsQueue.count {
            let event = eventsQueue[i]
            VisilabsLogger.debug(message: "Sending event")
            VisilabsLogger.debug(message: event)
            let loggerHeaders = prepareHeaders(.logger, event: event, visilabsUser: visilabsUser, visilabsCookie: visilabsCookie)
            let realTimeHeaders = prepareHeaders(.realtime, event: event, visilabsUser: visilabsUser, visilabsCookie: visilabsCookie)
            
            let loggerSemaphore = DispatchSemaphore(value: 0)
            let realTimeSemaphore = DispatchSemaphore(value: 0)
            //delegate?.updateNetworkActivityIndicator(true)
            VisilabsRequest.sendEventRequest(visilabsEndpoint : .logger, properties: event, headers: loggerHeaders, timeoutInterval: timeoutInterval, completion: { [loggerSemaphore] cookies in
                                        //self.delegate?.updateNetworkActivityIndicator(false)
                                        if let cookies = cookies {
                                            for cookie in cookies {
                                                if cookie.key.contains(VisilabsConstants.LOAD_BALANCE_PREFIX, options: .caseInsensitive){
                                                    mutableCookie.loggerCookieKey = cookie.key
                                                    mutableCookie.loggerCookieValue = cookie.value
                                                }
                                                if cookie.key.contains(VisilabsConstants.OM_3_KEY, options: .caseInsensitive){
                                                    mutableCookie.loggerOM3rdCookieValue = cookie.value
                                                }
                                            }
                                        }
                                        loggerSemaphore.signal()
            })
            
            VisilabsRequest.sendEventRequest(visilabsEndpoint : .realtime, properties: event, headers: realTimeHeaders, timeoutInterval: timeoutInterval, completion: { [realTimeSemaphore] cookies in
                                        //self.delegate?.updateNetworkActivityIndicator(false)
                                        if let cookies = cookies {
                                            for cookie in cookies {
                                                if cookie.key.contains(VisilabsConstants.LOAD_BALANCE_PREFIX, options: .caseInsensitive){
                                                    mutableCookie.realTimeCookieKey = cookie.key
                                                    mutableCookie.realTimeCookieValue = cookie.value
                                                }
                                                if cookie.key.contains(VisilabsConstants.OM_3_KEY, options: .caseInsensitive){
                                                    mutableCookie.realTimeOM3rdCookieValue = cookie.value
                                                }
                                            }
                                        }
                                        realTimeSemaphore.signal()
            })
            
            _ = loggerSemaphore.wait(timeout: DispatchTime.distantFuture)
            _ = realTimeSemaphore.wait(timeout: DispatchTime.distantFuture)
        }
        
        return mutableCookie
    }
    
    private func prepareHeaders(_ visilabsEndpoint: VisilabsEndpoint, event: [String:String], visilabsUser: VisilabsUser, visilabsCookie: VisilabsCookie) -> [String:String] {
        var headers = [String:String]()
        headers["Referer"] = event[VisilabsConstants.URI_KEY] ?? ""
        headers["User-Agent"] = visilabsUser.userAgent
        if let cookie = prepareCookie(visilabsEndpoint, visilabsCookie: visilabsCookie){
            headers["Cookie"] = cookie
        }
        return headers
    }
    
    private func prepareCookie(_ visilabsEndpoint: VisilabsEndpoint, visilabsCookie: VisilabsCookie) -> String? {
        var cookieString :String?
        if visilabsEndpoint == .logger{
            if let key = visilabsCookie.loggerCookieKey, let value = visilabsCookie.loggerCookieValue{
                cookieString = "\(key)=\(value)"
            }
            if let om3rdValue = visilabsCookie.loggerOM3rdCookieValue{
                if !cookieString.isNilOrWhiteSpace {
                    cookieString = cookieString! + ";"
                }else{ //TODO: bu kısmı güzelleştir
                    cookieString = ""
                }
                cookieString = cookieString! + "\(VisilabsConstants.OM_3_KEY)=\(om3rdValue)"
            }
        }
        if visilabsEndpoint == .realtime{
            if let key = visilabsCookie.realTimeCookieKey, let value = visilabsCookie.realTimeCookieValue{
                cookieString = "\(key)=\(value)"
            }
            if let om3rdValue = visilabsCookie.realTimeOM3rdCookieValue{
                if !cookieString.isNilOrWhiteSpace {
                    cookieString = cookieString! + ";"
                }else{ //TODO: bu kısmı güzelleştir
                    cookieString = ""
                }
                cookieString = cookieString! + "\(VisilabsConstants.OM_3_KEY)=\(om3rdValue)"
            }
        }
        return cookieString
    }
    
    /*
    func flushQueueInBatches(_ queue: Queue) -> Queue {
        var mutableQueue = queue
        while !mutableQueue.isEmpty {
            var shouldContinue = false
            let batchSize = min(mutableQueue.count, APIConstants.batchSize)
            let range = 0..<batchSize
            let batch = Array(mutableQueue[range])
            // Log data payload sent
            VisilabsLogger.debug(message: "Sending batch of data")
            VisilabsLogger.debug(message: batch as Any)
            let requestData = JSONHandler.encodeAPIData(batch)
            if let requestData = requestData {
                let semaphore = DispatchSemaphore(value: 0)
                delegate?.updateNetworkActivityIndicator(true)
                var shadowQueue = mutableQueue
                loggerRequest.sendRequest(requestData,
                                         type: type,
                                         useIP: useIPAddressForGeoLocation,
                                         completion: { [weak self, semaphore, range] success in
                                            guard let self = self else { return }
                                            self.delegate?.updateNetworkActivityIndicator(false)
                                            if success {
                                                if let lastIndex = range.last, shadowQueue.count - 1 > lastIndex {
                                                    shadowQueue.removeSubrange(range)
                                                } else {
                                                    shadowQueue.removeAll()
                                                }
                                            }
                                            shouldContinue = success
                                            semaphore.signal()
                })
                _ = semaphore.wait(timeout: DispatchTime.distantFuture)
                mutableQueue = shadowQueue
            }

            if !shouldContinue {
                break
            }
        }
        return mutableQueue
    }
    */
    
    
    // MARK: - Lifecycle
    func applicationDidBecomeActive() {
        //startFlushTimer()
    }

    func applicationWillResignActive() {
        //stopFlushTimer()
    }
}
