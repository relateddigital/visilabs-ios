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
    var miniNotificationPresentationTime = 6.0
    var currentlyShowingNotification: VisilabsInAppNotification?
    var currentlyShowingTargetingAction: TargetingActionViewModel?
    weak var delegate: VisilabsInAppNotificationsDelegate?
    weak var inappButtonDelegate: VisilabsInappButtonDelegate?
    weak var currentViewController: UIViewController?

    init(lock: VisilabsReadWriteLock) {
        self.lock = lock
    }

    func showNotification(_ notification: VisilabsInAppNotification) {
        let notification = notification
        let delayTime = notification.waitingTime ?? 0
        DispatchQueue.main.async {
            self.currentViewController = VisilabsHelper.getRootViewController()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(delayTime), execute: {
            if self.currentlyShowingNotification != nil || self.currentlyShowingTargetingAction != nil {
                VisilabsLogger.warn("already showing an in-app notification")
            } else {
                if notification.waitingTime ?? 0 == 0 || self.currentViewController == VisilabsHelper.getRootViewController() {
                    var shownNotification = false
                    switch notification.type {
                    case .mini:
                        shownNotification = self.showMiniNotification(notification)
                    case .full:
                        shownNotification = self.showFullNotification(notification)
                    case .halfScreenImage:
                        shownNotification = self.showHalfScreenNotification(notification)
                    case .inappcarousel:
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
                } else if model.targetingActionType == .scratchToWin, let sctw = model as? ScratchToWinModel {
                    if self.showScratchToWin(sctw) {
                        self.markTargetingActionShown(model: sctw)
                    }
                } else if model.targetingActionType == .productStatNotifier, let psn = model as? VisilabsProductStatNotifierViewModel {
                    if self.showProductStatNotifier(psn) {
                        self.markTargetingActionShown(model: psn)
                    }
                } else if model.targetingActionType == .drawer, let drawer = model as? SideBarServiceModel {
                    if self.showDrawer(model: drawer) {
                        self.markTargetingActionShown(model: drawer)
                    }
                }
            }
        }
    }

    func showProductStatNotifier(_ model: VisilabsProductStatNotifierViewModel) -> Bool {
        let productStatNotifierVC = VisilabsProductStatNotifierViewController(productStatNotifier: model)
        productStatNotifierVC.delegate = self
        productStatNotifierVC.show(animated: true)
        return true
    }

    func showHalfScreenNotification(_ notification: VisilabsInAppNotification) -> Bool {
        let halfScreenNotificationVC = VisilabsHalfScreenViewController(notification: notification)
        halfScreenNotificationVC.delegate = self
        halfScreenNotificationVC.show(animated: true)
        return true
    }

    func showDrawer(model: SideBarServiceModel) -> Bool {
        let sideBarViewController = visilabsSideBarViewController(model: model)
        sideBarViewController.delegate = self
        sideBarViewController.show(animated: true)
        return true
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

    func showAlert(_ notification: VisilabsInAppNotification) {
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
            VisilabsInstance.sharedUIApplication()?.open(url, options: [:], completionHandler: nil)
            self.inappButtonDelegate?.didTapButton(notification)
        }

        let closeText = notification.closeButtonText ?? "Close"
        let close = UIAlertAction(title: closeText, style: .destructive) { _ in
            print("dismiss tapped")
        }

        alertController.addAction(action)
        alertController.addAction(close)

        if let root = VisilabsHelper.getRootViewController() {
            if UIDevice.current.userInterfaceIdiom == .pad, style == .actionSheet {
                alertController.popoverPresentationController?.sourceView = root.view
                alertController.popoverPresentationController?.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.maxY, width: 0, height: 0)
            }
            root.present(alertController, animated: true, completion: alertDismiss)
        }
    }

    func showCarousel(_ notification: VisilabsInAppNotification) -> Bool {
        if notification.carouselItems.count < 2 {
            VisilabsLogger.error("Carousel Item Count is less than 2.")
            return false
        }
        let vc = VisilabsCarouselNotificationViewController(startIndex: 0, notification: notification)
        vc.visilabsDelegate = self
        vc.launchedCompletion = { VisilabsLogger.info("Carousel Launched") }
        vc.closedCompletion = {
            VisilabsLogger.info("Carousel Closed")
            vc.visilabsDelegate?.notificationShouldDismiss(controller: vc, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: nil)
        }
        vc.landedPageAtIndexCompletion = { index in
            print("LANDED AT INDEX: \(index)")
        }

        if let rootViewController = VisilabsHelper.getRootViewController() {
            rootViewController.presentCarouselNotification(vc)
            return true
        } else {
            return false
        }
    }

    func showSpinToWin(_ model: SpinToWinViewModel) -> Bool {
        let spinToWinVC = SpinToWinViewController(model)
        spinToWinVC.delegate = self
        spinToWinVC.show(animated: true)
        return true
    }

    func showPopUp(_ notification: VisilabsInAppNotification) -> Bool {
        let popUpVC = VisilabsPopupNotificationViewController(notification: notification)
        popUpVC.delegate = self
        popUpVC.inappButtonDelegate = self.inappButtonDelegate
        popUpVC.show(animated: false)
        return true
    }

    func showMailPopup(_ model: MailSubscriptionViewModel) -> Bool {
        let popUpVC = VisilabsPopupNotificationViewController(mailForm: model)
        popUpVC.delegate = self
        popUpVC.show(animated: false)
        return true
    }

    func showScratchToWin(_ model: ScratchToWinModel) -> Bool {
        let popUpVC = VisilabsPopupNotificationViewController(scratchToWin: model)
        popUpVC.delegate = self
        popUpVC.inappButtonDelegate = inappButtonDelegate
        popUpVC.show(animated: false)
        return true
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
    func notificationShouldDismiss(controller: VisilabsBaseViewProtocol,
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
                if callToActionURL.absoluteString == "redirect" {
                    if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
                        completionBlock()
                    }
                } else {
                    let app = VisilabsInstance.sharedUIApplication()
                    app?.performSelector(onMainThread: NSSelectorFromString("openURL:"), with: callToActionURL, waitUntilDone: true)
                    completionBlock()
                }
            }
        } else {
            controller.hide(animated: true, completion: completionBlock)
        }
        return true
    }

    func alertDismiss() {
        currentlyShowingNotification = nil
        currentlyShowingTargetingAction = nil
    }
}
