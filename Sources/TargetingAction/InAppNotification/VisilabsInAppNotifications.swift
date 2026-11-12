//
//  VisilabsInAppNotifications.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.05.2020.
//

import Foundation
import UIKit
import StoreKit

protocol VisilabsInAppNotificationsDelegate: AnyObject {
    func notificationDidShow(_ notification: VisilabsInAppNotification)
    func trackNotification(_ notification: VisilabsInAppNotification, event: String, properties: [String: String])
}

private class ScheduledNotificationItem {
    let notification: VisilabsInAppNotification
    var workItem: DispatchWorkItem?
    let scheduledDate: Date
    let delayTime: TimeInterval

    init(notification: VisilabsInAppNotification, workItem: DispatchWorkItem? = nil, scheduledDate: Date = Date(), delayTime: TimeInterval) {
        self.notification = notification
        self.workItem = workItem
        self.scheduledDate = scheduledDate
        self.delayTime = delayTime
    }
}

class VisilabsInAppNotifications: VisilabsNotificationViewControllerDelegate {
    let lock: VisilabsReadWriteLock
    var miniNotificationPresentationTime = 6.0
    var currentlyShowingNotification: VisilabsInAppNotification?
    var currentlyShowingTargetingAction: TargetingActionViewModel?
    weak var delegate: VisilabsInAppNotificationsDelegate?
    weak var inappButtonDelegate: VisilabsInappButtonDelegate?
    weak var drawerUrlDelegate: RDDrawerURLDelegate?
    private var pendingNotifications: [VisilabsInAppNotification] = []
    private var scheduledNotificationIds: Set<Int> = []
    private var scheduledNotifications: [Int: ScheduledNotificationItem] = [:]
    private var recentlyShownNotificationIds: [Int: Date] = [:]
    private let deduplicationTimeInterval: TimeInterval = 30.0
    private let maxNotificationRetries = 10
    private var lastDismissedTime: Date?
    private let chainedDismissThreshold: TimeInterval = 5.0
    private let fastTrackTransitionDelay: TimeInterval = 0.3

    init(lock: VisilabsReadWriteLock) {
        self.lock = lock
    }

    func showNotification(_ notification: VisilabsInAppNotification) {
        let actId = notification.actId

        var isAlreadyShowing = false
        var isAlreadyPending = false
        var isAlreadyScheduled = false
        var isRecentlyShown = false

        lock.write {
            let now = Date()
            self.recentlyShownNotificationIds = self.recentlyShownNotificationIds.filter { now.timeIntervalSince($0.value) < self.deduplicationTimeInterval }

            if self.currentlyShowingNotification?.actId == actId || self.currentlyShowingTargetingAction?.actIdValue == actId {
                isAlreadyShowing = true
            }
            if self.pendingNotifications.contains(where: { $0.actId == actId }) {
                isAlreadyPending = true
            }
            if self.scheduledNotificationIds.contains(actId) {
                isAlreadyScheduled = true
            }
            if self.recentlyShownNotificationIds[actId] != nil {
                isRecentlyShown = true
            }

            if !isAlreadyShowing && !isAlreadyPending && !isAlreadyScheduled && !isRecentlyShown {
                self.scheduledNotificationIds.insert(actId)
            }
        }

        if isAlreadyShowing {
            VisilabsLogger.info("Notification \(actId) is already currently showing. Dropping duplicate.")
            return
        }
        if isAlreadyPending {
            VisilabsLogger.info("Notification \(actId) is already in pending queue. Dropping duplicate.")
            return
        }
        if isAlreadyScheduled {
            VisilabsLogger.info("Notification \(actId) is already scheduled to show. Dropping duplicate.")
            return
        }
        if isRecentlyShown {
            VisilabsLogger.info("Notification \(actId) was shown recently (< \(deduplicationTimeInterval)s ago). Dropping duplicate.")
            return
        }

        let delayTime = notification.waitingTime ?? 0

        // Check if this notification arrived as part of a chained flow right after a previous dismissal
        var shouldFastTrack = false
        lock.read {
            if let lastDismiss = self.lastDismissedTime, Date().timeIntervalSince(lastDismiss) < self.chainedDismissThreshold {
                shouldFastTrack = true
            }
        }

        if shouldFastTrack {
            VisilabsLogger.info("Notification \(actId) arrived shortly after previous dismiss (< \(chainedDismissThreshold)s). Fast-tracking display (in \(fastTrackTransitionDelay)s) instead of waiting \(delayTime)s.")
            lock.write {
                self.lastDismissedTime = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + fastTrackTransitionDelay) { [weak self] in
                self?.lock.write {
                    self?.scheduledNotificationIds.remove(actId)
                    self?.scheduledNotifications.removeValue(forKey: actId)
                }
                self?.attemptToShowNotification(notification, retryCount: 0)
            }
            return
        }

        VisilabsLogger.info("showNotification scheduled with waitingTime: \(delayTime)s for actId: \(actId)")

        if delayTime > 0 {
            let scheduledItem = ScheduledNotificationItem(notification: notification, delayTime: TimeInterval(delayTime))

            let workItem = DispatchWorkItem { [weak self] in
                self?.lock.write {
                    self?.scheduledNotifications.removeValue(forKey: actId)
                    self?.scheduledNotificationIds.remove(actId)
                }
                self?.attemptToShowNotification(notification, retryCount: 0)
            }
            scheduledItem.workItem = workItem

            lock.write {
                self.scheduledNotifications[actId] = scheduledItem
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(delayTime), execute: workItem)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.lock.write {
                    self?.scheduledNotificationIds.remove(actId)
                    self?.scheduledNotifications.removeValue(forKey: actId)
                }
                self?.attemptToShowNotification(notification, retryCount: 0)
            }
        }
    }

    private func attemptToShowNotification(_ notification: VisilabsInAppNotification, retryCount: Int = 0) {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication(),
              sharedUIApplication.applicationState != .background else {
            VisilabsLogger.warn("Application is in background, adding notification \(notification.actId) to pending queue.")
            queuePendingNotification(notification)
            return
        }

        var isBusy = false
        var isAlreadyShowingThis = false
        lock.read {
            if self.currentlyShowingNotification?.actId == notification.actId || self.currentlyShowingTargetingAction?.actIdValue == notification.actId {
                isAlreadyShowingThis = true
            }
            isBusy = (self.currentlyShowingNotification != nil || self.currentlyShowingTargetingAction != nil)
        }

        if isAlreadyShowingThis {
            VisilabsLogger.info("Notification \(notification.actId) is already on screen. Dropping duplicate.")
            return
        }

        if isBusy {
            if retryCount < maxNotificationRetries {
                VisilabsLogger.info("Another in-app or action is currently showing. Retrying in 0.5s... (attempt \(retryCount + 1)/\(maxNotificationRetries))")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.attemptToShowNotification(notification, retryCount: retryCount + 1)
                }
            } else {
                VisilabsLogger.info("Max retries reached while waiting. Adding notification \(notification.actId) to pending queue.")
                queuePendingNotification(notification)
            }
            return
        }

        guard let rootViewController = VisilabsHelper.getRootViewController() else {
            VisilabsLogger.warn("No active visible view controller found to present notification \(notification.actId). Retrying in 0.5s...")
            if retryCount < maxNotificationRetries {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.attemptToShowNotification(notification, retryCount: retryCount + 1)
                }
            }
            return
        }

        if rootViewController.isBeingDismissed {
            VisilabsLogger.info("Current view controller is being dismissed, waiting 0.3s before presenting notification \(notification.actId).")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.attemptToShowNotification(notification, retryCount: retryCount + 1)
            }
            return
        }

        presentNotification(notification)
    }

    private func presentNotification(_ notification: VisilabsInAppNotification) {
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
        case .carouselFullscreen:
            shownNotification = self.showCarouselFullscreen(notification)
        case .fullscreenPopup:
            shownNotification = self.showFullscreenPopup(notification)
        case .alert:
            shownNotification = true
            self.showAlert(notification)
        default:
            shownNotification = self.showPopUp(notification)
        }

        if shownNotification {
            self.markNotificationShown(notification: notification)
            self.delegate?.notificationDidShow(notification)
            self.lock.write {
                self.recentlyShownNotificationIds[notification.actId] = Date()
            }
        } else {
            VisilabsLogger.error("Failed to present notification \(notification.actId).")
        }
    }

    private func queuePendingNotification(_ notification: VisilabsInAppNotification) {
        lock.write {
            if self.currentlyShowingNotification?.actId == notification.actId {
                VisilabsLogger.info("Notification \(notification.actId) is already currently showing. Not queuing duplicate.")
                return
            }
            if !self.pendingNotifications.contains(where: { $0.actId == notification.actId }) {
                self.pendingNotifications.append(notification)
                VisilabsLogger.info("Notification \(notification.actId) added to pending queue (size: \(self.pendingNotifications.count)).")
            }
        }
    }

    private func getEffectiveDelay(for delaySeconds: Int) -> Double {
        var shouldFastTrack = false
        lock.read {
            if let lastDismiss = self.lastDismissedTime, Date().timeIntervalSince(lastDismiss) < self.chainedDismissThreshold {
                shouldFastTrack = true
            }
        }
        if shouldFastTrack {
            lock.write {
                self.lastDismissedTime = nil
            }
            VisilabsLogger.info("Action arrived shortly after previous dismiss (< \(chainedDismissThreshold)s). Fast-tracking (\(fastTrackTransitionDelay)s) instead of waiting \(delaySeconds)s.")
            return fastTrackTransitionDelay
        }
        return Double(delaySeconds)
    }

    private func showNextPendingNotificationIfAny() {
        var scheduledToFastTrack: VisilabsInAppNotification?

        lock.write {
            let now = Date()
            self.pendingNotifications.removeAll { notif in
                if let lastShown = self.recentlyShownNotificationIds[notif.actId], now.timeIntervalSince(lastShown) < self.deduplicationTimeInterval {
                    VisilabsLogger.info("Removing recently shown notification \(notif.actId) from pending queue.")
                    return true
                }
                return false
            }

            // If there is any notification waiting on a waitingTime timer, fast-track the earliest scheduled one
            // because the previous popup/action has been dismissed.
            if let firstScheduled = self.scheduledNotifications.values.sorted(by: { $0.scheduledDate < $1.scheduledDate }).first {
                firstScheduled.workItem?.cancel()
                self.scheduledNotifications.removeValue(forKey: firstScheduled.notification.actId)
                self.scheduledNotificationIds.remove(firstScheduled.notification.actId)
                scheduledToFastTrack = firstScheduled.notification
            }
        }

        if let fastTrackNotif = scheduledToFastTrack {
            var isRecentlyShown = false
            lock.read {
                if let lastShown = self.recentlyShownNotificationIds[fastTrackNotif.actId],
                   Date().timeIntervalSince(lastShown) < self.deduplicationTimeInterval {
                    isRecentlyShown = true
                }
            }
            if isRecentlyShown {
                VisilabsLogger.info("Fast-tracked notification \(fastTrackNotif.actId) was shown recently. Dropping duplicate.")
                showNextPendingNotificationIfAny()
                return
            }

            VisilabsLogger.info("Previous popup dismissed. Fast-tracking scheduled notification \(fastTrackNotif.actId) in \(fastTrackTransitionDelay)s.")
            DispatchQueue.main.asyncAfter(deadline: .now() + fastTrackTransitionDelay) { [weak self] in
                self?.attemptToShowNotification(fastTrackNotif, retryCount: 0)
            }
            return
        }

        var nextNotif: VisilabsInAppNotification?
        lock.write {
            if !self.pendingNotifications.isEmpty {
                nextNotif = self.pendingNotifications.removeFirst()
            }
        }
        if let next = nextNotif {
            VisilabsLogger.info("Triggering next pending notification: \(next.actId)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.attemptToShowNotification(next, retryCount: 0)
            }
        }
    }

    func showTargetingAction(_ model: TargetingActionViewModel) {
        if let actId = model.actIdValue {
            var isAlreadyShowing = false
            var isAlreadyPending = false
            var isAlreadyScheduled = false
            var isRecentlyShown = false

            lock.write {
                let now = Date()
                self.recentlyShownNotificationIds = self.recentlyShownNotificationIds.filter { now.timeIntervalSince($0.value) < self.deduplicationTimeInterval }

                if self.currentlyShowingNotification?.actId == actId || self.currentlyShowingTargetingAction?.actIdValue == actId {
                    isAlreadyShowing = true
                }
                if self.pendingNotifications.contains(where: { $0.actId == actId }) {
                    isAlreadyPending = true
                }
                if self.scheduledNotificationIds.contains(actId) {
                    isAlreadyScheduled = true
                }
                if self.recentlyShownNotificationIds[actId] != nil {
                    isRecentlyShown = true
                }

                if !isAlreadyShowing && !isAlreadyPending && !isAlreadyScheduled && !isRecentlyShown {
                    self.scheduledNotificationIds.insert(actId)
                }
            }

            if isAlreadyShowing {
                VisilabsLogger.info("Targeting action \(actId) is already currently showing. Dropping duplicate.")
                return
            }
            if isAlreadyPending {
                VisilabsLogger.info("Targeting action \(actId) is already in pending queue. Dropping duplicate.")
                return
            }
            if isAlreadyScheduled {
                VisilabsLogger.info("Targeting action \(actId) is already scheduled to show. Dropping duplicate.")
                return
            }
            if isRecentlyShown {
                VisilabsLogger.info("Targeting action \(actId) was shown recently (< \(deduplicationTimeInterval)s ago). Dropping duplicate.")
                return
            }
        }

        DispatchQueue.main.async {
            if self.currentlyShowingNotification != nil || self.currentlyShowingTargetingAction != nil {
                VisilabsLogger.warn("already showing an notification")
                if let actId = model.actIdValue {
                    self.lock.write {
                        self.scheduledNotificationIds.remove(actId)
                    }
                }
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
                } else if model.targetingActionType == .drawer, let drawer = model as? DrawerServiceModel {
                    if self.showDrawer(model: drawer) {
                        //self.markTargetingActionShown(model: drawer)
                    }
                } else if model.targetingActionType == .MultipleChoiceSurvey, let poll = model as? PollModel {
                    if self.showPoll(model: poll) {
                        self.markTargetingActionShown(model: poll)
                    }
                } else if model.targetingActionType == .CountdownTimerBanner, let timerBanner = model as? CountdownTimerBannerModel {
                    if self.showTimerBanner(model: timerBanner) {
                        self.markTargetingActionShown(model: timerBanner)
                    }
                } else if model.targetingActionType == .mobileCustomActions, let customWebview = model as? CustomWebViewModel {
                    if self.showCustomWebview(model: customWebview) {
                        self.markTargetingActionShown(model: customWebview)
                    }
                }else if model.targetingActionType == .notificationBell, let notifBell = model as? NotificationBellModel {
                    if self.showNotificationBell(model: notifBell) {
                        self.markTargetingActionShown(model: notifBell)
                    }
                }
                  else if model.targetingActionType == .apprating {
                    self.showInappRating()
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

    func showDrawer(model: DrawerServiceModel) -> Bool {
        let sideBarViewController = RDDrawerViewController(model: model)
        sideBarViewController.delegate = self
        sideBarViewController.urlDelegate = self.drawerUrlDelegate
        sideBarViewController.show(animated: true)
        return true
    }
    
    
    func showPoll(model: PollModel) -> Bool {
        let delay = getEffectiveDelay(for: model.waitingTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            let pollVC = PollViewController(model)
            pollVC.delegate = self
            pollVC.show(animated: true)
        })
        return true
    }
    
    
    func showTimerBanner(model: CountdownTimerBannerModel) -> Bool {
        // Geri sayım süresi dolmuşsa banner hiç gösterilmez.
        if CountdownTimerBannerViewController.isExpired(model: model) {
            return false
        }
        let delay = getEffectiveDelay(for: model.waitingTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            // Bekleme süresi içinde süre dolmuş olabilir; tekrar kontrol et.
            if CountdownTimerBannerViewController.isExpired(model: model) {
                return
            }
            let tBannerVC = CountdownTimerBannerViewController(model: model)
            tBannerVC.delegate = self
            tBannerVC.show(animated: true)

        })
        return true
    }
    
    func showNotificationBell(model: NotificationBellModel) -> Bool {
        let delay = getEffectiveDelay(for: model.waitingTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            let notifBell = NotificationBellViewController(model: model)
            notifBell.delegate = self
            notifBell.show(animated: true)
        })
        return true
    }
    
    func showCustomWebview(model: CustomWebViewModel) -> Bool {
        let delay = getEffectiveDelay(for: model.waitingTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            let customWebviewVC = CustomWebViewController(model)
            customWebviewVC.delegate = self
            customWebviewVC.show(animated: true)
        })
        return true
    }
    
    func showInappRating() {
        DispatchQueue.main.async  {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
    }

    func showMiniNotification(_ notification: VisilabsInAppNotification) -> Bool {
        let miniNotificationVC = VisilabsMiniNotificationViewController(notification: notification)
        miniNotificationVC.delegate = self
        miniNotificationVC.show(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(notification.duration ?? 6)) {
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
                self.alertDismiss()
                return
            }
            if Visilabs.callAPI().shouldOpenInAppURLInSDK(url, notification: notification) {
                VisilabsInstance.sharedUIApplication()?.open(url, options: [:], completionHandler: nil)
            }
            self.inappButtonDelegate?.didTapButton(notification)
            self.alertDismiss()
        }

        let closeText = notification.closeButtonText ?? "Close"
        let close = UIAlertAction(title: closeText, style: .destructive) { _ in
            print("dismiss tapped")
            self.alertDismiss()
        }

        alertController.addAction(action)
        alertController.addAction(close)

        if let root = VisilabsHelper.getRootViewController() {
            if UIDevice.current.userInterfaceIdiom == .pad, style == .actionSheet {
                alertController.popoverPresentationController?.sourceView = root.view
                alertController.popoverPresentationController?.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.maxY, width: 0, height: 0)
            }
            root.present(alertController, animated: true, completion: nil)
        }
    }

    func showCarouselFullscreen(_ notification: VisilabsInAppNotification) -> Bool {
        let items = Array(notification.carouselItems.prefix(5))
        guard !items.isEmpty else {
            VisilabsLogger.error("carousel_fullscreen requires at least one carousel item.")
            return false
        }
        let vc = VisilabsCarouselFullscreenViewController(notification: notification, carouselItems: items)
        vc.delegate = self
        vc.onButtonTap = { [weak self] notif, link, button, index in
            self?.inappButtonDelegate?.didTapCarouselFullscreenButton(notif, link: link, button: button, carouselItemIndex: index)
        }
        vc.show(animated: true)
        return true
    }

    func showFullscreenPopup(_ notification: VisilabsInAppNotification) -> Bool {
        let vc = VisilabsFullscreenPopupViewController(notification: notification)
        vc.delegate = self
        vc.inappButtonDelegate = self.inappButtonDelegate
        vc.show(animated: true)
        return true
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
        let delay = getEffectiveDelay(for: model.waitingTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            let spinToWinVC = SpinToWinViewController(model)
            spinToWinVC.delegate = self
            spinToWinVC.show(animated: true)
        })
        
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
        let delay = getEffectiveDelay(for: model.waitingTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            let popUpVC = VisilabsPopupNotificationViewController(scratchToWin: model)
            popUpVC.delegate = self
            popUpVC.inappButtonDelegate = self.inappButtonDelegate
            popUpVC.show(animated: false)
            Visilabs.callAPI().trackScratchToWinImpression(report: model.report)
        })

        return true
    }

    func markNotificationShown(notification: VisilabsInAppNotification) {
        lock.write {
            VisilabsLogger.info("marking notification as seen: \(notification.actId)")
            currentlyShowingNotification = notification
            self.scheduledNotificationIds.remove(notification.actId)
            self.scheduledNotifications.removeValue(forKey: notification.actId)
            // TO_DO: burada customEvent request'i atılmalı
        }
    }

    func markTargetingActionShown(model: TargetingActionViewModel) {
        lock.write {
            self.currentlyShowingTargetingAction = model
            if let actId = model.actIdValue {
                self.scheduledNotificationIds.remove(actId)
                self.scheduledNotifications.removeValue(forKey: actId)
                self.recentlyShownNotificationIds[actId] = Date()
                VisilabsLogger.info("marking targeting action as seen: \(actId)")
            }
        }
    }

    @discardableResult
    func notificationShouldDismiss(controller: VisilabsBaseViewProtocol,
                                   callToActionURL: URL?, shouldTrack: Bool,
                                   additionalTrackingProperties: [String: String]?) -> Bool {
        if let currentNotif = currentlyShowingNotification, let controllerNotif = controller.notification {
            if currentNotif.actId != controllerNotif.actId {
                return false
            }
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

            self.lock.write {
                self.currentlyShowingNotification = nil
                self.currentlyShowingTargetingAction = nil
                self.lastDismissedTime = Date()
            }
            self.showNextPendingNotificationIfAny()
        }

        if let callToActionURL = callToActionURL {
            controller.hide(animated: true) {
                if callToActionURL.absoluteString == "redirect" {
                    if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
                        completionBlock()
                    }
                } else {
                    if Visilabs.callAPI().shouldOpenInAppURLInSDK(callToActionURL, notification: controller.notification) {
                        UIApplication.shared.open(callToActionURL as URL, options: [:],completionHandler: nil)
                    }
                    completionBlock()
                }
            }
        } else {
            controller.hide(animated: true, completion: completionBlock)
        }
        return true
    }

    func trackNotification(controller: VisilabsBaseViewProtocol, event: String, properties: [String: String]?) {
        if let notification = controller.notification {
            var finalProperties = properties ?? [String: String]()
            let actId = notification.actId
            finalProperties["OM.s_page"] = "act-\(actId)"
            self.delegate?.trackNotification(notification, event: event, properties: finalProperties)
        }
    }

    func alertDismiss() {
        lock.write {
            currentlyShowingNotification = nil
            currentlyShowingTargetingAction = nil
            lastDismissedTime = Date()
        }
        showNextPendingNotificationIfAny()
    }
}

extension TargetingActionViewModel {
    var actIdValue: Int? {
        if let m = self as? SpinToWinViewModel { return m.actId }
        if let m = self as? ScratchToWinModel { return m.actId }
        if let m = self as? MailSubscriptionViewModel { return m.actId }
        if let m = self as? PollModel { return m.actId }
        if let m = self as? CountdownTimerBannerModel { return m.actId }
        if let m = self as? DrawerServiceModel { return m.actId }
        if let m = self as? CustomWebViewModel { return m.actId }
        if let m = self as? NotificationBellModel { return m.actId }
        if let m = self as? InappReviewModel { return m.actId }
        return nil
    }
}
