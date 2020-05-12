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
    let visilabsInAppNotificationRequest: VisilabsInAppNotificationRequest
    let lock: VisilabsReadWriteLock
    var notificationsInstance: VisilabsInAppNotifications
    
    required init(basePathIdentifier: String, lock: VisilabsReadWriteLock) {
        self.visilabsInAppNotificationRequest = VisilabsInAppNotificationRequest()
        self.lock = lock
        self.notificationsInstance = VisilabsInAppNotifications(lock: self.lock)
    }
    
}
