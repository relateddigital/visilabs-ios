//
//  VisilabsSend.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.05.2020.
//

import Foundation

protocol VisilabsSendDelegate: AnyObject {
    func send(completion: (() -> Void)?)
    func updateNetworkActivityIndicator(_ isOn: Bool)
}

class RelatedDigitalSend {

    // TO_DO: bu delegate kullanılmıyor. kaldır.
    weak var delegate: VisilabsSendDelegate?

    // TO_DO: burada internet bağlantısı kontrolü yapmaya gerek var mı?
    func sendEventsQueue(_ eventsQueue: Queue, visilabsUser: VisilabsUser,
                         visilabsCookie: RelatedDigitalCookie, timeoutInterval: TimeInterval) -> RelatedDigitalCookie {
        var mutableCookie = visilabsCookie

        for counter in 0..<eventsQueue.count {
            let event = eventsQueue[counter]
            RelatedDigitalLogger.debug("Sending event")
            RelatedDigitalLogger.debug(event)
            let loggerHeaders = prepareHeaders(.logger, event: event, visilabsUser: visilabsUser,
                                               visilabsCookie: visilabsCookie)
            let realTimeHeaders = prepareHeaders(.realtime, event: event, visilabsUser: visilabsUser,
                                                 visilabsCookie: visilabsCookie)

            let loggerSemaphore = DispatchSemaphore(value: 0)
            let realTimeSemaphore = DispatchSemaphore(value: 0)
            // delegate?.updateNetworkActivityIndicator(true)
            RelatedDigitalRequest.sendEventRequest(visilabsEndpoint: .logger, properties: event,
                                             headers: loggerHeaders, timeoutInterval: timeoutInterval,
                                             completion: { [loggerSemaphore] cookies in
                                        // self.delegate?.updateNetworkActivityIndicator(false)
                                        if let cookies = cookies {
                                            for cookie in cookies {
                                                if cookie.key.contains(RelatedDigitalConstants.loadBalancePrefix,
                                                                       options: .caseInsensitive) {
                                                    mutableCookie.loggerCookieKey = cookie.key
                                                    mutableCookie.loggerCookieValue = cookie.value
                                                }
                                                if cookie.key.contains(RelatedDigitalConstants.om3Key,
                                                                       options: .caseInsensitive) {
                                                    mutableCookie.loggerOM3rdCookieValue = cookie.value
                                                }
                                            }
                                        }
                                        loggerSemaphore.signal()
            })

            RelatedDigitalRequest.sendEventRequest(visilabsEndpoint: .realtime, properties: event,
                                             headers: realTimeHeaders, timeoutInterval: timeoutInterval,
                                             completion: { [realTimeSemaphore] cookies in
                                        // self.delegate?.updateNetworkActivityIndicator(false)
                                        if let cookies = cookies {
                                            for cookie in cookies {
                                                if cookie.key.contains(RelatedDigitalConstants.loadBalancePrefix,
                                                                       options: .caseInsensitive) {
                                                    mutableCookie.realTimeCookieKey = cookie.key
                                                    mutableCookie.realTimeCookieValue = cookie.value
                                                }
                                                if cookie.key.contains(RelatedDigitalConstants.om3Key,
                                                                       options: .caseInsensitive) {
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

    private func prepareHeaders(_ visilabsEndpoint: VisilabsEndpoint, event: [String: String],
                                visilabsUser: VisilabsUser, visilabsCookie: RelatedDigitalCookie) -> [String: String] {
        var headers = [String: String]()
        headers["Referer"] = event[RelatedDigitalConstants.uriKey] ?? ""
        headers["User-Agent"] = visilabsUser.userAgent
        if let cookie = prepareCookie(visilabsEndpoint, visilabsCookie: visilabsCookie) {
            headers["Cookie"] = cookie
        }
        return headers
    }

    private func prepareCookie(_ visilabsEndpoint: VisilabsEndpoint, visilabsCookie: RelatedDigitalCookie) -> String? {
        var cookieString: String?
        if visilabsEndpoint == .logger {
            if let key = visilabsCookie.loggerCookieKey, let value = visilabsCookie.loggerCookieValue {
                cookieString = "\(key)=\(value)"
            }
            if let om3rdValue = visilabsCookie.loggerOM3rdCookieValue {
                if !cookieString.isNilOrWhiteSpace {
                    cookieString = cookieString! + ";"
                } else { // TO_DO: bu kısmı güzelleştir
                    cookieString = ""
                }
                cookieString = cookieString! + "\(RelatedDigitalConstants.om3Key)=\(om3rdValue)"
            }
        }
        if visilabsEndpoint == .realtime {
            if let key = visilabsCookie.realTimeCookieKey, let value = visilabsCookie.realTimeCookieValue {
                cookieString = "\(key)=\(value)"
            }
            if let om3rdValue = visilabsCookie.realTimeOM3rdCookieValue {
                if !cookieString.isNilOrWhiteSpace {
                    cookieString = cookieString! + ";"
                } else { // TO_DO: bu kısmı güzelleştir
                    cookieString = ""
                }
                cookieString = cookieString! + "\(RelatedDigitalConstants.om3Key)=\(om3rdValue)"
            }
        }
        return cookieString
    }
}
