//
//  VisilabsMiniNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 13.05.2020.
//

import UIKit

class VisilabsMiniNotificationViewController: VisilabsBaseNotificationViewController {
    var miniNotification: VisilabsInAppNotification! {
        return super.notification
    }

    @IBOutlet var circleLabel: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    var isDismissing = false
    var canPan = true
    var position: CGPoint!

    convenience init(notification: VisilabsInAppNotification) {
        self.init(notification: notification,
                  nameOfClass: String(describing: VisilabsMiniNotificationViewController.self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = notification!.messageTitle
        titleLabel.font = notification!.messageTitleFont
        if let image = notification!.image {
            imageView.image = UIImage.gif(data: image)
        }

        view.backgroundColor = UIColor(hex: "#000000", alpha: 0.8)
        titleLabel.textColor = UIColor.white
        imageView.tintColor = UIColor.white

        circleLabel.backgroundColor = UIColor(hex: "#000000", alpha: 0)
        circleLabel.layer.cornerRadius = circleLabel.frame.size.width / 2
        circleLabel.clipsToBounds = false // TO_DO: burası true olsa ne olur
        circleLabel.layer.borderWidth = 2.0
        circleLabel.layer.borderColor = UIColor.white.cgColor

        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        window?.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(gesture:)))
        window?.addGestureRecognizer(panGesture)
    }

    fileprivate func setWindowAndAddAnimation(_ animated: Bool) {
        if let window = window {
            window.windowLevel = UIWindow.Level.alert
            window.clipsToBounds = true
            window.rootViewController = self
            window.layer.cornerRadius = 6

            // TO_DO: bunları default set ediyorum doğru mudur?
            window.layer.borderColor = UIColor.white.cgColor
            window.layer.borderWidth = 1
            window.isHidden = false
        }

        let duration = animated ? 0.1 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.frame.origin.y -= (VisilabsInAppNotificationsConstants.miniInAppHeight
                + VisilabsInAppNotificationsConstants.miniBottomPadding)
            self.canPan = true
        }, completion: { _ in
            self.position = self.window?.layer.position
        })
    }

    override func show(animated: Bool) {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
            return
        }
        canPan = false
        var bounds: CGRect
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first
            guard let scene = windowScene as? UIWindowScene else { return }
            bounds = scene.coordinateSpace.bounds
        } else {
            bounds = UIScreen.main.bounds
        }
        let frame: CGRect
        if sharedUIApplication.statusBarOrientation.isPortrait
            && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            frame = CGRect(x: VisilabsInAppNotificationsConstants.miniSidePadding,
                           y: bounds.size.height,
                           width: bounds.size.width - (VisilabsInAppNotificationsConstants.miniSidePadding * 2),
                           height: VisilabsInAppNotificationsConstants.miniInAppHeight)
        } else { // Is iPad or Landscape mode
            frame = CGRect(x: bounds.size.width / 4,
                           y: bounds.size.height,
                           width: bounds.size.width / 2,
                           height: VisilabsInAppNotificationsConstants.miniInAppHeight)
        }
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first
            if let windowScene = windowScene as? UIWindowScene {
                window = UIWindow(frame: frame)
                window?.windowScene = windowScene
            }
        } else {
            window = UIWindow(frame: frame)
        }

        setWindowAndAddAnimation(animated)
    }

    override func hide(animated: Bool, completion: @escaping () -> Void) {
        if !isDismissing {
            canPan = false
            isDismissing = true
            let duration = animated ? 0.5 : 0
            UIView.animate(withDuration: duration, animations: {
                self.window?.frame.origin.y += (VisilabsInAppNotificationsConstants.miniInAppHeight
                    + VisilabsInAppNotificationsConstants.miniBottomPadding)
            }, completion: { _ in
                self.window?.isHidden = true
                self.window?.removeFromSuperview()
                self.window = nil
                completion()
            })
        }
    }

    @objc func didTap(gesture: UITapGestureRecognizer) {
        if !isDismissing && gesture.state == UIGestureRecognizer.State.ended {
            delegate?.notificationShouldDismiss(controller: self,
                                                callToActionURL: miniNotification.callToActionUrl,
                                                shouldTrack: true,
                                                additionalTrackingProperties: nil)
        }
    }

    @objc func didPan(gesture: UIPanGestureRecognizer) {
        if canPan, let window = window {
            switch gesture.state {
            case UIGestureRecognizer.State.began:
                panStartPoint = gesture.location(in: VisilabsInstance.sharedUIApplication()?.keyWindow)
            case UIGestureRecognizer.State.changed:
                var position = gesture.location(in: VisilabsInstance.sharedUIApplication()?.keyWindow)
                let diffY = position.y - panStartPoint.y
                position.y = max(position.y, position.y + diffY)
                window.layer.position = CGPoint(x: window.layer.position.x, y: position.y)
            case UIGestureRecognizer.State.ended, UIGestureRecognizer.State.cancelled:
                if window.layer.position.y > position.y + (VisilabsInAppNotificationsConstants.miniInAppHeight / 2) {
                    delegate?.notificationShouldDismiss(controller: self,
                                                        callToActionURL: miniNotification.callToActionUrl,
                                                        shouldTrack: false,
                                                        additionalTrackingProperties: nil)
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        window.layer.position = self.position
                    })
                }
            default:
                break
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard VisilabsInstance.sharedUIApplication() != nil else {
            return
        }
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            let frame: CGRect
            if UIDevice.current.orientation.isPortrait
                && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
                frame = CGRect(x: VisilabsInAppNotificationsConstants.miniSidePadding,
                               y: UIScreen.main.bounds.size.height -
                                   (VisilabsInAppNotificationsConstants.miniInAppHeight
                                       + VisilabsInAppNotificationsConstants.miniBottomPadding),
                               width: UIScreen.main.bounds.size.width -
                                   (VisilabsInAppNotificationsConstants.miniSidePadding * 2),
                               height: VisilabsInAppNotificationsConstants.miniInAppHeight)
            } else { // Is iPad or Landscape mode
                frame = CGRect(x: UIScreen.main.bounds.size.width / 4,
                               y: UIScreen.main.bounds.size.height -
                                   (VisilabsInAppNotificationsConstants.miniInAppHeight
                                       + VisilabsInAppNotificationsConstants.miniBottomPadding),
                               width: UIScreen.main.bounds.size.width / 2,
                               height: VisilabsInAppNotificationsConstants.miniInAppHeight)
            }
            self.window?.frame = frame

        }, completion: nil)
    }
}
