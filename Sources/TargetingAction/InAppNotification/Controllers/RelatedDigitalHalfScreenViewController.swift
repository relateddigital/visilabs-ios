//
//  VisilabsHalfScreenViewController.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 10.11.2021.
//

import UIKit

class RelatedDigitalHalfScreenViewController: RelatedDigitalBaseNotificationViewController {

    var halfScreenNotification: RelatedDigitalInAppNotification! {
        return super.notification
    }
    
    var visilabsHalfScreenView: RelatedDigitalHalfScreenView!
    var halfScreenHeight = 0.0
    
    var isDismissing = false
    var position: CGPoint!

    init(notification: RelatedDigitalInAppNotification) {
        super.init(nibName: nil, bundle: nil)
        self.notification = notification
        visilabsHalfScreenView = RelatedDigitalHalfScreenView(frame: UIScreen.main.bounds, notification: halfScreenNotification)
        view = visilabsHalfScreenView
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        visilabsHalfScreenView.addGestureRecognizer(tapGesture)
        
        let closeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped(tapGestureRecognizer:)))
        visilabsHalfScreenView.closeButton.isUserInteractionEnabled = true
        visilabsHalfScreenView.closeButton.addGestureRecognizer(closeTapGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func didTap(gesture: UITapGestureRecognizer) {
        if !isDismissing && gesture.state == UIGestureRecognizer.State.ended {
            delegate?.notificationShouldDismiss(controller: self,
                                                callToActionURL: halfScreenNotification.callToActionUrl,
                                                shouldTrack: true,
                                                additionalTrackingProperties: nil)
        }
    }
    
    @objc func closeButtonTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        dismiss(animated: true) {
            self.delegate?.notificationShouldDismiss(controller: self,
                                                     callToActionURL: nil,
                                                     shouldTrack: false,
                                                     additionalTrackingProperties: nil)
        }
    }

    override func show(animated: Bool) {
        guard let sharedUIApplication = RelatedDigitalInstance.sharedUIApplication() else {
            return
        }
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
        
        let bottomInset = Double(RelatedDigitalHelper.getSafeAreaInsets().bottom)
        let topInset = Double(RelatedDigitalHelper.getSafeAreaInsets().top)
        halfScreenHeight = Double(visilabsHalfScreenView.imageView.frame.height) + Double(visilabsHalfScreenView.titleLabel.frame.height)
        
        let frameY = halfScreenNotification.position == .bottom ? Double(bounds.size.height) - (halfScreenHeight + bottomInset) : topInset
        
        
        let frame = CGRect(origin: CGPoint(x: 0, y: CGFloat(frameY)), size: CGSize(width: bounds.size.width, height: CGFloat(halfScreenHeight)))
        
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
            window.clipsToBounds = false // true
            window.rootViewController = self
            window.isHidden = false
        }
        self.position = self.window?.layer.position
    }
    

    
    override func hide(animated: Bool, completion: @escaping () -> Void) {
        if !isDismissing {
            isDismissing = true
            let duration = animated ? 0.5 : 0
            
            UIView.animate(withDuration: duration, animations: {
                
                var originY = 0.0
                if self.halfScreenNotification.position == .bottom {
                    originY = self.halfScreenHeight + Double(RelatedDigitalHelper.getSafeAreaInsets().bottom)
                } else {
                    originY = -(self.halfScreenHeight + Double(RelatedDigitalHelper.getSafeAreaInsets().top))
                }
                
                self.window?.frame.origin.y += CGFloat(originY)
                }, completion: { _ in
                    self.window?.isHidden = true
                    self.window?.removeFromSuperview()
                    self.window = nil
                    completion()
            })
        }
    }

}
