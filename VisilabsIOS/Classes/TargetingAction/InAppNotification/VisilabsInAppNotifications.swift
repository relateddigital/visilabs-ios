//
//  VisilabsInAppNotifications.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.05.2020.
//

import Foundation
import UIKit

protocol VisilabsInAppNotificationsDelegate: AnyObject {
    func notificationDidShow(_ notification: VisilabsInAppNotification)
    func trackNotification(_ notification: VisilabsInAppNotification, event: String, properties: [String: String])
}

class VisilabsInAppNotifications: VisilabsNotificationViewControllerDelegate {
    let lock: VisilabsReadWriteLock
    var checkForNotificationOnActive = true
    var showNotificationOnActive = true
    var miniNotificationPresentationTime = 6.0
    var shownNotifications = Set<Int>()
    // var triggeredNotifications = [VisilabsInAppNotification]()
    // var inAppNotifications = [VisilabsInAppNotification]()
    var inAppNotification: VisilabsInAppNotification?
    var currentlyShowingNotification: VisilabsInAppNotification?
    weak var delegate: VisilabsInAppNotificationsDelegate?

    init(lock: VisilabsReadWriteLock) {
        self.lock = lock
    }

    func showNotification(_ notification: VisilabsInAppNotification) {
        let notification = notification

        DispatchQueue.main.async {
            if self.currentlyShowingNotification != nil {
                VisilabsLogger.warn("already showing an in-app notification")
            } else {
                var shownNotification = false
                switch notification.type {
                case .mini:
                    shownNotification = self.showMiniNotification(notification)
                case .full:
                    shownNotification = self.showFullNotification(notification)
                default:
                    shownNotification = self.showPopUp(notification)
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
            self.notificationShouldDismiss(controller: miniNotificationVC, callToActionURL: nil,
                                           shouldTrack: false, additionalTrackingProperties: nil)
        }
        return true
    }

    func showFullNotification(_ notification: VisilabsInAppNotification) -> Bool {
        let fullNotificationVC = VisilabsFullNotificationViewController(notification: notification)
        fullNotificationVC.delegate = self
        fullNotificationVC.show(animated: true)
        return true
    }

    // TODO: bu gerekmeyecek sanırım
    func getTopView() -> UIView? {
        var topView: UIView?
        let window = UIApplication.shared.keyWindow
        if window != nil {
            for subview in window?.subviews ?? [] {
                if !subview.isHidden && subview.alpha > 0
                    && subview.frame.size.width > 0
                    && subview.frame.size.height > 0 {
                    topView = subview
                }
            }
        }
        return topView
    }

    func getRootViewController() -> UIViewController? {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
            return nil
        }
        for window in sharedUIApplication.windows {
            if window.isKeyWindow {
                return window.rootViewController
            }
        }

        return nil
    }

    func showPopUp(_ notification: VisilabsInAppNotification) -> Bool {
        let controller = VisilabsPopupNotificationViewController(notification: notification)
        controller.delegate = self

        if let rootViewController = getRootViewController() {
            rootViewController.present(controller, animated: false, completion: nil)
            return true
        } else {
            return false
        }
    }

    func markNotificationShown(notification: VisilabsInAppNotification) {
        lock.write {
            VisilabsLogger.info("marking notification as seen: \(notification.actId)")
            currentlyShowingNotification = notification
            // TODO: burada customEvent request'i atılmalı
        }
    }

    @discardableResult
    func notificationShouldDismiss(controller: VisilabsBaseNotificationViewController,
                                   callToActionURL: URL?, shouldTrack: Bool,
                                   additionalTrackingProperties: [String: String]?) -> Bool {
        if currentlyShowingNotification?.actId != controller.notification.actId {
            return false
        }

        let completionBlock = {
            if shouldTrack {
                var properties = additionalTrackingProperties
                if (callToActionURL?.absoluteString) != nil {
                    if properties == nil {
                        properties = [:]
                    }
                }
                if additionalTrackingProperties != nil {
                    properties!["OM.s_point"] = additionalTrackingProperties!["OM.s_point"]
                    properties!["OM.s_cat"] = additionalTrackingProperties!["OM.s_cat"]
                    properties!["OM.s_page"] = additionalTrackingProperties!["OM.s_page"]
                }
                self.delegate?.trackNotification(controller.notification, event: "event", properties: properties!)
            }
            self.currentlyShowingNotification = nil
        }

        if let callToActionURL = callToActionURL {
            controller.hide(animated: true) {
                let app = VisilabsInstance.sharedUIApplication()
                app?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: callToActionURL,
                                     waitUntilDone: true)
                completionBlock()
            }
        } else {
            controller.hide(animated: true, completion: completionBlock)
        }

        return true
    }
}
