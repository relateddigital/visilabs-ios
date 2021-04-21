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
    var currentlyShowingTargetingAction: TargetingActionViewModel?
    weak var delegate: VisilabsInAppNotificationsDelegate?
    weak var currentViewController: UIViewController?

    init(lock: VisilabsReadWriteLock) {
        self.lock = lock
    }

    func showNotification(_ notification: VisilabsInAppNotification) {
        let notification = notification
        let delayTime = notification.waitingTime ?? 0
        DispatchQueue.main.async {
            self.currentViewController = self.getRootViewController()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(delayTime), execute: {
            if self.currentlyShowingNotification != nil || self.currentlyShowingTargetingAction != nil {
                VisilabsLogger.warn("already showing an in-app notification")
            } else {
                if (notification.waitingTime ?? 0 == 0 || self.currentViewController == self.getRootViewController()) {
                    var shownNotification = false
                    switch notification.type {
                    case .mini:
                        shownNotification = self.showMiniNotification(notification)
                    case .full:
                        shownNotification = self.showFullNotification(notification)
                    case .alert:
                        shownNotification = true
                        self.showAlert(notification)
                    default:
                        shownNotification = self.showPopUp(notification)
                    }

                    if shownNotification {
                        self.markNotificationShown(notification: notification)
                        self.delegate?.notificationDidShow(notification)
                    }
                }
            }
        })
    }

    func showTargetingAction(_ model: TargetingActionViewModel) {
        DispatchQueue.main.async {
            if self.currentlyShowingNotification != nil || self.currentlyShowingTargetingAction != nil {
                VisilabsLogger.warn("already showing an notification")
            } else {
                if model.targetingActionType == .mailSubscriptionForm, let mailSubscriptionForm = model as? MailSubscriptionViewModel {
                    if self.showMailPopup(mailSubscriptionForm) {
                        self.markTargetingActionShown(model: mailSubscriptionForm)
                    }
                } else if model.targetingActionType == .spinToWin, let spinToWin = model as? SpinToWinViewModel {
                    if self.showSpinToWin(spinToWin) {
                        self.markTargetingActionShown(model: spinToWin)
                    }
                }
            }
        }
    }

    /*
        func showMailSubscriptionForm(_ model: MailSubscriptionViewModel) {
            DispatchQueue.main.async {
                if self.currentlyShowingNotification != nil
                    || self.currentlyShowingTargetingAction != nil {
                    VisilabsLogger.warn("already showing an notification")
                } else {
                    var shown = false
                    shown = self.showMailPopup(model)
                    if shown {
                        self.markMailFormShown(model: model)
                    }
                }
            }
        }
     */

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

    func showAlert(_ notification: VisilabsInAppNotification) {
        let title = notification.messageTitle?.removeEscapingCharacters()
        let message = notification.messageBody?.removeEscapingCharacters()
        let style: UIAlertController.Style = notification.alertType?.lowercased() ?? "" == "actionsheet" ? .actionSheet : .alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)

        let buttonTxt = notification.buttonText
        let urlStr = notification.iosLink ?? ""
        let action = UIAlertAction(title: buttonTxt, style: .default) { _ in
            guard let url = URL(string: urlStr) else {
                return
            }
            VisilabsInstance.sharedUIApplication()?.open(url, options: [:], completionHandler: nil)
        }

        let closeText = notification.closeButtonText ?? "Close"
        let close = UIAlertAction(title: closeText, style: .destructive) { _ in
            print("dismiss tapped")
        }

        alert.addAction(action)
        alert.addAction(close)

        if let root = getRootViewController() {
            root.present(alert, animated: true, completion: alertDismiss)
        }
    }

    // TO_DO: bu gerekmeyecek sanırım
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
        if let rootViewController = sharedUIApplication.keyWindow?.rootViewController {
            return getVisibleViewController(rootViewController)
        }
        return nil
    }

    private func getVisibleViewController(_ vc: UIViewController?) -> UIViewController? {
        if vc is UINavigationController {
            return getVisibleViewController((vc as? UINavigationController)?.visibleViewController)
        } else if vc is UITabBarController {
            return getVisibleViewController((vc as? UITabBarController)?.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return getVisibleViewController(pvc.presentedViewController)
            } else {
                return vc
            }
        }
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

    func showMailPopup(_ model: MailSubscriptionViewModel) -> Bool {
        let controller = VisilabsPopupNotificationViewController(mailForm: model)
        controller.delegate = self

        if let rootViewController = getRootViewController() {
            rootViewController.present(controller, animated: false, completion: nil)
            return true
        } else {
            return false
        }
    }

    func showSpinToWin(_ model: SpinToWinViewModel) -> Bool {
        let controller = SpinToWinViewController(model)
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        if let rootViewController = getRootViewController() {
            rootViewController.present(controller, animated: true, completion: nil)
            return true
        }
        return false
    }

    func markNotificationShown(notification: VisilabsInAppNotification) {
        lock.write {
            VisilabsLogger.info("marking notification as seen: \(notification.actId)")
            currentlyShowingNotification = notification
            // TO_DO: burada customEvent request'i atılmalı
        }
    }

    func markTargetingActionShown(model: TargetingActionViewModel) {
        lock.write {
            self.currentlyShowingTargetingAction = model
        }
    }

    @discardableResult
    func notificationShouldDismiss(controller: VisilabsBaseNotificationViewController,
                                   callToActionURL: URL?, shouldTrack: Bool,
                                   additionalTrackingProperties: [String: String]?) -> Bool {
        if currentlyShowingNotification?.actId != controller.notification?.actId {
            return false
        }

        let completionBlock = {
            if shouldTrack {
                var properties = additionalTrackingProperties ?? [String: String]()
                if additionalTrackingProperties != nil {
                    properties["OM.s_point"] = additionalTrackingProperties!["OM.s_point"]
                    properties["OM.s_cat"] = additionalTrackingProperties!["OM.s_cat"]
                    properties["OM.s_page"] = additionalTrackingProperties!["OM.s_page"]
                }
                if controller.notification != nil {
                    self.delegate?.trackNotification(controller.notification!, event: "event", properties: properties)
                }
            }
            self.currentlyShowingNotification = nil
            self.currentlyShowingTargetingAction = nil
        }

        if let callToActionURL = callToActionURL {
            controller.hide(animated: true) {
                let app = VisilabsInstance.sharedUIApplication()
                app?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: callToActionURL, waitUntilDone: true)
                completionBlock()
            }
        } else {
            controller.hide(animated: true, completion: completionBlock)
        }

        return true
    }

    func mailFormShouldDismiss(controller: VisilabsBaseNotificationViewController, click: String) {
    }

    func alertDismiss() {
        currentlyShowingNotification = nil
        currentlyShowingTargetingAction = nil
    }
}
