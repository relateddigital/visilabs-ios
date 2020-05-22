//
//  VisilabsInAppNotificationInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 10.05.2020.
//

import Foundation

struct VisilabsInAppNotificationResponse {
    var inAppNotifications: [VisilabsInAppNotification]

    init() {
        inAppNotifications = []
    }
}


class VisilabsInAppNotificationInstance {
    let lock: VisilabsReadWriteLock
    var decideFetched = false
    var notificationsInstance: VisilabsInAppNotifications
    
    var inAppDelegate: VisilabsInAppNotificationsDelegate? {
        set {
            notificationsInstance.delegate = newValue
        }
        get {
            return notificationsInstance.delegate
        }
    }
    
    required init(lock: VisilabsReadWriteLock) {
        self.lock = lock
        self.notificationsInstance = VisilabsInAppNotifications(lock: self.lock)
    }
    
    
    func checkInAppNotification(properties: [String:String], visilabsUser: VisilabsUser, timeoutInterval: TimeInterval, completion: @escaping ((_ response: VisilabsInAppNotificationResponse?) -> Void)){
        var visilabsInAppNotificationResponse = VisilabsInAppNotificationResponse()
        let semaphore = DispatchSemaphore(value: 0)
        let headers = prepareHeaders(visilabsUser)
        
        VisilabsInAppNotificationRequest.sendRequest(properties: properties, headers: headers, timeoutInterval: timeoutInterval, completion: { [weak self] visilabsInAppNotificationResult in
            guard let self = self else {
                return
            }
            guard let result = visilabsInAppNotificationResult else {
                semaphore.signal()
                completion(nil)
                return
            }
            
            //TODO: burada actiontype kontrolü de yapılabilir.
            var parsedNotifications = [VisilabsInAppNotification]()
            for rawNotif in result{
                if let actionData = rawNotif["actiondata"] as? [String : Any] {
                    if let typeString = actionData["msg_type"] as? String, let type = VisilabsInAppNotificationType(rawValue: typeString), let notification = VisilabsInAppNotification(JSONObject: rawNotif) {
                        parsedNotifications.append(notification)
                    }
                }
            }
            
            self.notificationsInstance.inAppNotifications = parsedNotifications
            visilabsInAppNotificationResponse.inAppNotifications = parsedNotifications
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    private func prepareHeaders(_ visilabsUser: VisilabsUser) -> [String:String] {
        var headers = [String:String]()
        headers["User-Agent"] = visilabsUser.userAgent
        return headers
    }
    
}