//
//  VisilabsInAppNotificationInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 10.05.2020.
//

import Foundation

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


class VisilabsInAppNotificationInstance {
    
    
}
