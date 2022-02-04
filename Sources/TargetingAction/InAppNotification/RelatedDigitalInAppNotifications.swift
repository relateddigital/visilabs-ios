//
//  VisilabsInAppNotifications.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.05.2020.
//

import Foundation
import UIKit

protocol RelatedDigitalInAppNotificationsDelegate: AnyObject {
    func notificationDidShow(_ notification: RelatedDigitalInAppNotification)
    func trackNotification(_ notification: RelatedDigitalInAppNotification, event: String, properties: [String: String])
}

class RelatedDigitalInAppNotifications: RelatedDigitalNotificationViewControllerDelegate  {
    let lock: RelatedDigitalReadWriteLock
    var checkForNotificationOnActive = true
    var showNotificationOnActive = true
    var miniNotificationPresentationTime = 6.0
    var shownNotifications = Set<Int>()
    var inAppNotification: RelatedDigitalInAppNotification?
    var currentlyShowingNotification: RelatedDigitalInAppNotification?
    var currentlyShowingTargetingAction: TargetingActionViewModel?
    weak var delegate: RelatedDigitalInAppNotificationsDelegate?
    weak var inappButtonDelegate: VisilabsInappButtonDelegate?
    weak var currentViewController: UIViewController?
    
    init(lock: RelatedDigitalReadWriteLock) {
        self.lock = lock
    }
    
    func showNotification(_ notification: RelatedDigitalInAppNotification) {
        let notification = notification
        let delayTime = notification.waitingTime ?? 0
        DispatchQueue.main.async {
            self.currentViewController = RelatedDigitalHelper.getRootViewController()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(delayTime), execute: {
            if self.currentlyShowingNotification != nil || self.currentlyShowingTargetingAction != nil {
                RelatedDigitalLogger.warn("already showing an in-app notification")
            } else {
                if notification.waitingTime ?? 0 == 0 || self.currentViewController == RelatedDigitalHelper.getRootViewController() {
                    var shownNotification = false
                    switch notification.type {
                    case .mini:
                        shownNotification = self.showMiniNotification(notification)
                    case .full:
                        shownNotification = self.showFullNotification(notification)
                    case .halfScreenImage:
                        shownNotification = self.showHalfScreenNotification(notification)
                    case .carousel:
                        shownNotification = self.showCarousel(notification)
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
                RelatedDigitalLogger.warn("already showing an notification")
            } else {
                if model.targetingActionType == .mailSubscriptionForm, let mailSubscriptionForm = model as? MailSubscriptionViewModel {
                    if self.showMailPopup(mailSubscriptionForm) {
                        self.markTargetingActionShown(model: mailSubscriptionForm)
                    }
                } else if model.targetingActionType == .spinToWin, let spinToWin = model as? SpinToWinViewModel {
                    if self.showSpinToWin(spinToWin) {
                        self.markTargetingActionShown(model: spinToWin)
                    }
                } else if model.targetingActionType == .scratchToWin, let sctw = model as? ScratchToWinModel {
                    if self.showScratchToWin(sctw) {
                        self.markTargetingActionShown(model: sctw)
                    }
                } else if model.targetingActionType == .productStatNotifier, let psn = model as? RelatedDigitalProductStatNotifierViewModel {
                    if self.showProductStatNotifier(psn) {
                        self.markTargetingActionShown(model: psn)
                    }
                }
            }
        }
    }
    
    func showProductStatNotifier(_ model: RelatedDigitalProductStatNotifierViewModel) -> Bool {
        let productStatNotifierVC = RelatedDigitalProductStatNotifierViewController(productStatNotifier: model)
        productStatNotifierVC.delegate = self
        productStatNotifierVC.show(animated: true)
        return true
    }
    
    func showHalfScreenNotification(_ notification: RelatedDigitalInAppNotification) -> Bool {
        let halfScreenNotificationVC = RelatedDigitalHalfScreenViewController(notification: notification)
        halfScreenNotificationVC.delegate = self
        halfScreenNotificationVC.show(animated: true)
        return true
    }
    
    func showMiniNotification(_ notification: RelatedDigitalInAppNotification) -> Bool {
        let miniNotificationVC = RelatedDigitalMiniNotificationViewController(notification: notification)
        miniNotificationVC.delegate = self
        miniNotificationVC.show(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + miniNotificationPresentationTime) {
            self.notificationShouldDismiss(controller: miniNotificationVC, callToActionURL: nil,
                                           shouldTrack: false, additionalTrackingProperties: nil)
        }
        return true
    }
    
    func showFullNotification(_ notification: RelatedDigitalInAppNotification) -> Bool {
        let fullNotificationVC = RelatedDigitalFullNotificationViewController(notification: notification)
        fullNotificationVC.delegate = self
        fullNotificationVC.show(animated: true)
        return true
    }
    
    func showCarousel(_ notification: RelatedDigitalInAppNotification) -> Bool {
        let carousel = RelatedDigitalCarouselNotificationViewController(notification: notification)
        carousel.delegate = self
        carousel.show(animated: true)
        return true
    }
    
    func showAlert(_ notification: RelatedDigitalInAppNotification) {
        let title = notification.messageTitle?.removeEscapingCharacters()
        let message = notification.messageBody?.removeEscapingCharacters()
        let style: UIAlertController.Style = notification.alertType?.lowercased() ?? "" == "actionsheet" ? .actionSheet : .alert
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let buttonTxt = notification.buttonText
        let urlStr = notification.iosLink ?? ""
        let action = UIAlertAction(title: buttonTxt, style: .default) { _ in
            guard let url = URL(string: urlStr) else {
                return
            }
            RelatedDigitalInstance.sharedUIApplication()?.open(url, options: [:], completionHandler: nil)
            self.inappButtonDelegate?.didTapButton(notification)
        }
        
        let closeText = notification.closeButtonText ?? "Close"
        let close = UIAlertAction(title: closeText, style: .destructive) { _ in
            print("dismiss tapped")
        }
        
        alertController.addAction(action)
        alertController.addAction(close)
        
        if let root = RelatedDigitalHelper.getRootViewController() {
            
            if UIDevice.current.userInterfaceIdiom == .pad, style == .actionSheet {
                alertController.popoverPresentationController?.sourceView = root.view
                alertController.popoverPresentationController?.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.maxY, width: 0, height: 0)
            }
            
            
            root.present(alertController, animated: true, completion: alertDismiss)
        }
    }
    
    
    
    func showPopUp(_ notification: RelatedDigitalInAppNotification) -> Bool {
        let controller = RelatedDigitalPopupNotificationViewController(notification: notification)
        controller.delegate = self
        controller.inappButtonDelegate = self.inappButtonDelegate
        
        if let rootViewController = RelatedDigitalHelper.getRootViewController() {
            rootViewController.present(controller, animated: false, completion: nil)
            return true
        } else {
            return false
        }
    }
    
    func showMailPopup(_ model: MailSubscriptionViewModel) -> Bool {
        let controller = RelatedDigitalPopupNotificationViewController(mailForm: model)
        controller.delegate = self
        
        if let rootViewController = RelatedDigitalHelper.getRootViewController() {
            rootViewController.present(controller, animated: false, completion: nil)
            return true
        } else {
            return false
        }
    }
    
    func showScratchToWin(_ model: ScratchToWinModel) -> Bool {
        let controller = RelatedDigitalPopupNotificationViewController(scratchToWin: model)
        controller.delegate = self
        if let rootViewController = RelatedDigitalHelper.getRootViewController() {
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
        if let rootViewController = RelatedDigitalHelper.getRootViewController() {
            rootViewController.present(controller, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    func markNotificationShown(notification: RelatedDigitalInAppNotification) {
        lock.write {
            RelatedDigitalLogger.info("marking notification as seen: \(notification.actId)")
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
    func notificationShouldDismiss(controller: RelatedDigitalBaseNotificationViewController,
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
                let app = RelatedDigitalInstance.sharedUIApplication()
                app?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: callToActionURL, waitUntilDone: true)
                completionBlock()
            }
        } else {
            controller.hide(animated: true, completion: completionBlock)
        }
        
        return true
    }
    
    func mailFormShouldDismiss(controller: RelatedDigitalBaseNotificationViewController, click: String) {
        
    }
    
    func alertDismiss() {
        currentlyShowingNotification = nil
        currentlyShowingTargetingAction = nil
    }
    
}
