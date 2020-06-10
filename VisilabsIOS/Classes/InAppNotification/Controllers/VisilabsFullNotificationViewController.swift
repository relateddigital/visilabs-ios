//
//  VisilabsFullNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 3.06.2020.
//

import Foundation

class VisilabsFullNotificationViewController: VisilabsBaseNotificationViewController {

    var fullNotification: VisilabsInAppNotification! {
        get {
            return super.notification
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var isDismissing = false
    var canPan = true
    var position: CGPoint!

    convenience init(notification: VisilabsInAppNotification) {
        self.init(notification: notification, nameOfClass: String(describing: VisilabsMiniNotificationViewController.self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = notification.messageTitle
        if let image = notification.image {
            imageView.image = UIImage(data: image)
        }

        //TODO: bunları default set ediyorum doğru mudur?
        view.backgroundColor = UIColor(MPHex: 3858759680)
        titleLabel.textColor = UIColor(MPHex: 4294967295)
        imageView.tintColor = UIColor(MPHex: 4294967295)
        
        //view.backgroundColor = UIColor(MPHex: miniNotification.backgroundColor)
        //bodyLabel.textColor = UIColor(MPHex: miniNotification.bodyColor)
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        //imageView.tintColor = UIColor(MPHex: miniNotification.imageTintColor)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        window?.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(gesture:)))
        window?.addGestureRecognizer(panGesture)
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
            && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
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

        if let window = window {
            window.windowLevel = UIWindow.Level.alert
            window.clipsToBounds = true
            window.rootViewController = self
            window.layer.cornerRadius = 6
            
            //TODO: bunları default set ediyorum doğru mudur?
            window.layer.borderColor = UIColor(MPHex: 4294967295).cgColor
            //window.layer.borderColor = UIColor(MPHex: miniNotification.borderColor).cgColor
            window.layer.borderWidth = 1
            window.isHidden = false
        }

        let duration = animated ? 0.1 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.frame.origin.y -= (VisilabsInAppNotificationsConstants.miniInAppHeight + VisilabsInAppNotificationsConstants.miniBottomPadding)
            self.canPan = true
            }, completion: { _ in
                self.position = self.window?.layer.position
        })
    }

    override func hide(animated: Bool, completion: @escaping () -> Void) {
        if !isDismissing {
            canPan = false
            isDismissing = true
            let duration = animated ? 0.5 : 0
            UIView.animate(withDuration: duration, animations: {
                self.window?.frame.origin.y += (VisilabsInAppNotificationsConstants.miniInAppHeight + VisilabsInAppNotificationsConstants.miniBottomPadding)
                }, completion: { _ in
                    self.window?.isHidden = true
                    self.window?.removeFromSuperview()
                    self.window = nil
                    completion()
            })
        }
    }

    @objc func didTap(gesture: UITapGestureRecognizer) {
        
    }

    @objc func didPan(gesture: UIPanGestureRecognizer) {
        
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard VisilabsInstance.sharedUIApplication() != nil else {
            return
        }
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (ctx) in
            let frame: CGRect
            if  UIDevice.current.orientation.isPortrait
                && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                frame = CGRect(x: VisilabsInAppNotificationsConstants.miniSidePadding,
                               y: UIScreen.main.bounds.size.height -
                                (VisilabsInAppNotificationsConstants.miniInAppHeight + VisilabsInAppNotificationsConstants.miniBottomPadding),
                               width: UIScreen.main.bounds.size.width -
                                (VisilabsInAppNotificationsConstants.miniSidePadding * 2),
                               height: VisilabsInAppNotificationsConstants.miniInAppHeight)
            } else { // Is iPad or Landscape mode
                frame = CGRect(x: UIScreen.main.bounds.size.width / 4,
                               y: UIScreen.main.bounds.size.height -
                                (VisilabsInAppNotificationsConstants.miniInAppHeight + VisilabsInAppNotificationsConstants.miniBottomPadding),
                               width: UIScreen.main.bounds.size.width / 2,
                               height: VisilabsInAppNotificationsConstants.miniInAppHeight)
            }
            self.window?.frame = frame

            }, completion: nil)
    }
}
