//
//  VisilabsInAppNotifications.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.05.2020.
//

import Foundation
import UIKit

protocol VisilabsInAppNotificationsDelegate {
    func notificationDidShow(_ notification: VisilabsInAppNotification)
    func trackNotification(_ notification: VisilabsInAppNotification, event: String, properties: [String:String]?)
}

enum VisilabsInAppNotificationType : String {
    case mini = "mini"
    case full = "full"
    case image_text_button = "image_text_button"
    case full_image = "full_image"
    case nps = "nps"
    case image_button = "image_button"
    case smile_rating = "smile_rating"
    case unknown = "unknown"
}

class VisilabsInAppNotifications : VisilabsNotificationViewControllerDelegate {
    let lock: VisilabsReadWriteLock
    
    
    
    var delegate: VisilabsInAppNotificationsDelegate?
    
    init(lock: VisilabsReadWriteLock) {
        self.lock = lock
    }
    
    func notificationShouldDismiss(controller: VisilabsBaseNotificationViewController,
                                      callToActionURL: URL?,
                                      shouldTrack: Bool,
                                      additionalTrackingProperties: [String:String]?) -> Bool{
        return true
    }
}





