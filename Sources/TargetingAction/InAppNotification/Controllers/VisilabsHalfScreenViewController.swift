//
//  VisilabsHalfScreenViewController.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 10.11.2021.
//

import UIKit


//messageTitle,img

class VisilabsHalfScreenViewController: VisilabsBaseNotificationViewController {

    var halfScreenNotification: VisilabsInAppNotification! {
        return super.notification
    }
    
    var visilabsHalfScreenView: VisilabsHalfScreenView!

    var isDismissing = false
    var canPan = true
    var position: CGPoint!

    init(notification: VisilabsInAppNotification) {
        super.init(nibName: nil, bundle: nil)
        self.notification = notification
        visilabsHalfScreenView = VisilabsHalfScreenView(frame: UIScreen.main.bounds, notification: halfScreenNotification)
        view = visilabsHalfScreenView
        //view.updateConstraints()
        
        //print(view.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    public override func loadView() {
        //visilabsHalfScreenView = VisilabsHalfScreenView(frame: UIScreen.main.bounds, notification: halfScreenNotification)
        //view = visilabsHalfScreenView
    }
    
    
    /*
    override func viewDidLayoutSubviews() {
        //self.window?.layer.position = CGPoint(x: 0, y: visilabsHalfScreenView.imageView.frame.height + visilabsHalfScreenView.titleLabel.frame.height)
        self.position = self.window?.layer.position
        print("self.position: \(self.position)")
        return
        
        var a = visilabsHalfScreenView.bounds
        print(a)
        print("visilabsHalfScreenView.height: \(visilabsHalfScreenView.height)")
        print("visilabsHalfScreenView.width: \(visilabsHalfScreenView.width)")
        print("view.frame.height: \(visilabsHalfScreenView.frame.height)")
        print("view.frame.width: \(visilabsHalfScreenView.frame.width)")
        
        let height = visilabsHalfScreenView.imageView.frame.height + visilabsHalfScreenView.titleLabel.frame.height
        print("height: \(height)")
        
        
        print("visilabsHalfScreenView.imageView.frame.height: \(visilabsHalfScreenView.imageView.frame.height)")
        print("visilabsHalfScreenView.titleLabel.frame.height: \(visilabsHalfScreenView.titleLabel.frame.height)")

        window?.removeFromSuperview()
        
        self.position = self.window?.layer.position
        
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
         
        let frame = CGRect(origin: CGPoint(x: 0, y: bounds.size.height)
                           , size: CGSize(width: view.frame.width, height: height))

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
            //window?.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height), size: CGSize(width: view.frame.width, height: view.frame.height))
        }

        
        if let window = window {
            window.windowLevel = UIWindow.Level.alert
            window.clipsToBounds = false // true
            window.rootViewController = self
            window.isHidden = false
        }

        self.position = self.window?.layer.position
    }
     */


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
        
        let bottomInset = VisilabsHelper.getsafeAreaInsets().bottom
        let height = visilabsHalfScreenView.imageView.frame.height + visilabsHalfScreenView.titleLabel.frame.height
        print("height: \(height)")
        
        
        
        let frame: CGRect
        if sharedUIApplication.statusBarOrientation.isPortrait && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            //frame = CGRect(origin: CGPoint(x: 0, y: bounds.size.height), size: CGSize(width: bounds.size.width, height:300))
            //frame = CGRect(origin: CGPoint(x: 0, y: bounds.size.height), size: CGSize(width: 0, height: 0))
            frame = CGRect(origin: CGPoint(x: 0, y: bounds.size.height - (height + bottomInset)), size: CGSize(width: bounds.size.width, height: height))
            
            /*
            frame = CGRect(x: VisilabsInAppNotificationsConstants.miniSidePadding,
                           y: bounds.size.height,
                           width: bounds.size.width - (VisilabsInAppNotificationsConstants.miniSidePadding * 2),
                           height: VisilabsInAppNotificationsConstants.miniInAppHeight)
             */
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
                //window = UIWindow()
                window?.windowScene = windowScene
            }
        } else {
            window = UIWindow(frame: frame)
            //window = UIWindow()
        }

        
        if let window = window {
            window.windowLevel = UIWindow.Level.alert
            window.clipsToBounds = false // true
            window.rootViewController = self
            window.isHidden = false
        }
        
        //window?.height(100)

        //self.window?.frame.origin.y = -height
        //self.window?.frame.origin.y = -height
        self.position = self.window?.layer.position
        
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
                                                callToActionURL: halfScreenNotification.callToActionUrl,
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
                                                        callToActionURL: halfScreenNotification.callToActionUrl,
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
        coordinator.animate(alongsideTransition: { (_) in
            let frame: CGRect
            if  UIDevice.current.orientation.isPortrait && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                frame = CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.size.height), size: CGSize(width: UIScreen.main.bounds.size.width, height:200))
                
                /*
                frame = CGRect(x: VisilabsInAppNotificationsConstants.miniSidePadding, y: UIScreen.main.bounds.size.height -
                                (VisilabsInAppNotificationsConstants.miniInAppHeight + VisilabsInAppNotificationsConstants.miniBottomPadding),
                               width: UIScreen.main.bounds.size.width -
                                (VisilabsInAppNotificationsConstants.miniSidePadding * 2),
                               height: 100)
                 */
                
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
