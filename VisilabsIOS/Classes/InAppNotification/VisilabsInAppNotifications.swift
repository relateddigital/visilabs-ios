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
    //case unknown = "unknown"
}

class VisilabsInAppNotifications : VisilabsNotificationViewControllerDelegate {
    let lock: VisilabsReadWriteLock
    var checkForNotificationOnActive = true
    var showNotificationOnActive = true
    var miniNotificationPresentationTime = 6.0
    var shownNotifications = Set<Int>()
    var triggeredNotifications = [VisilabsInAppNotification]()
    var inAppNotifications = [VisilabsInAppNotification]()
    var currentlyShowingNotification: VisilabsInAppNotification?
    var delegate: VisilabsInAppNotificationsDelegate?
    
    init(lock: VisilabsReadWriteLock) {
        self.lock = lock
    }
    
    func showNotification( _ notification: VisilabsInAppNotification) {
        let notification = notification
        
        DispatchQueue.main.async {
            if self.currentlyShowingNotification != nil {
                VisilabsLogger.warn(message: "already showing an in-app notification")
            } else {
                var shownNotification = false
                if notification.type == .mini {
                    shownNotification = self.showMiniNotification(notification)
                }
                if shownNotification {
                    self.markNotificationShown(notification: notification)
                    self.delegate?.notificationDidShow(notification)
                }
            }
        }
    }
    
    func showMiniNotification(_ notification: VisilabsInAppNotification) -> Bool {
        let miniNotificationVC = VisilabsMiniNotificationViewController(notification: notification)
        miniNotificationVC.delegate = self
        miniNotificationVC.show(animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + miniNotificationPresentationTime) {
            self.notificationShouldDismiss(controller: miniNotificationVC, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: nil)
        }
        return true
    }
    
    func markNotificationShown(notification: VisilabsInAppNotification) {
        self.lock.write {
            VisilabsLogger.info(message: "marking notification as seen: \(notification.actId)")
            currentlyShowingNotification = notification
            //TODO: burada customEvent request'i atılmalı
        }
    }
    
    @discardableResult
    func notificationShouldDismiss(controller: VisilabsBaseNotificationViewController, callToActionURL: URL?, shouldTrack: Bool, additionalTrackingProperties: [String:String]?) -> Bool{
        if currentlyShowingNotification?.actId != controller.notification.actId {
            return false
        }
        
        let completionBlock = {
            if shouldTrack {
                var properties = additionalTrackingProperties
                if let urlString = callToActionURL?.absoluteString {
                    if properties == nil {
                        properties = [:]
                    }
                    properties!["url"] = urlString
                }
                self.delegate?.trackNotification(controller.notification, event: "$campaign_open", properties: properties)
            }
            self.currentlyShowingNotification = nil
        }
        
        if let callToActionURL = callToActionURL {
            controller.hide(animated: true) {
                VisilabsLogger.info(message: "opening CTA URL: \(callToActionURL)")
                VisilabsInstance.sharedUIApplication()?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: callToActionURL, waitUntilDone: true)
                completionBlock()
            }
        } else {
            controller.hide(animated: true, completion: completionBlock)
        }
        
        return true
    }
}





