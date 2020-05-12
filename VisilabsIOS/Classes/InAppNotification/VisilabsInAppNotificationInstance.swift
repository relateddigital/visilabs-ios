//
//  VisilabsInAppNotificationInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 10.05.2020.
//

import Foundation

struct VisilabsInAppNotificationResponse {
    var notifications: [VisilabsInAppNotification]

    init() {
        notifications = []
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
        var headers = [String:String]()
        
        VisilabsInAppNotificationRequest.sendRequest(properties: properties, headers: headers, timeoutInterval: timeoutInterval, completion: { [weak self] visilabsInAppNotificationResponse in
            return
        })
    }
    
}
