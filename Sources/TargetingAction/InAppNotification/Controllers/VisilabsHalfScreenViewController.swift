//
//  VisilabsHalfScreenViewController.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 10.11.2021.
//

import AVFoundation
import UIKit
import WebKit

final class HalfScreenPassthroughWindow: UIWindow {
    var hitCheckViews: (() -> [UIView])?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let views = hitCheckViews?() else { return super.point(inside: point, with: event) }
        for view in views {
            let localPoint = view.convert(point, from: self)
            if view is UIButton {
                let hitBounds = view.bounds.insetBy(dx: -10, dy: -10)
                if hitBounds.contains(localPoint) {
                    return true
                }
            } else if view.point(inside: localPoint, with: event) {
                return true
            }
        }
        return false
    }
}

class VisilabsHalfScreenViewController: VisilabsBaseNotificationViewController {
    var halfScreenNotification: VisilabsInAppNotification! {
        return super.notification
    }

    var player: AVPlayer?
    var webPlayer : WKWebView?
    var visilabsHalfScreenView: VisilabsHalfScreenView!
    var halfScreenHeight = 0.0

    var isDismissing = false

    init(notification: VisilabsInAppNotification) {
        super.init(nibName: nil, bundle: nil)
        self.notification = notification
        visilabsHalfScreenView = VisilabsHalfScreenView(frame: UIScreen.main.bounds, notification: halfScreenNotification)
        view = visilabsHalfScreenView

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        visilabsHalfScreenView.containerView.addGestureRecognizer(tapGesture)

        let closeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped(tapGestureRecognizer:)))
        visilabsHalfScreenView.closeButton.isUserInteractionEnabled = true
        visilabsHalfScreenView.closeButton.addGestureRecognizer(closeTapGestureRecognizer)
        visilabsHalfScreenView.closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player = visilabsHalfScreenView.imageView?.addVideoPlayer(urlString: notification?.videourl ?? "")
        webPlayer = visilabsHalfScreenView.imageView?.addYoutubeVideoPlayer(urlString: notification?.videourl ?? "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        webPlayer?.stopPlayer()
    }

    @objc func didTap(gesture: UITapGestureRecognizer) {
        if !isDismissing && gesture.state == UIGestureRecognizer.State.ended {
            delegate?.notificationShouldDismiss(controller: self,
                                                callToActionURL: halfScreenNotification.callToActionUrl,
                                                shouldTrack: true,
                                                additionalTrackingProperties: nil)
        }
    }

    @objc func closeButtonPressed() {
        closeButtonTapped(tapGestureRecognizer: UITapGestureRecognizer())
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
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
            return
        }
        var bounds: CGRect
        var targetWindowScene: UIWindowScene?
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first as? UIWindowScene
            targetWindowScene = windowScene
            bounds = windowScene?.coordinateSpace.bounds ?? UIScreen.main.bounds
        } else {
            bounds = UIScreen.main.bounds
        }

        let bottomInset = Double(VisilabsHelper.getSafeAreaInsets().bottom)
        let topInset = Double(VisilabsHelper.getSafeAreaInsets().top)
        
        var promoHeight: Double = 0.0
        if let promoContainer = visilabsHalfScreenView.promotionContainer, !promoContainer.isHidden {
            promoHeight = Double(promoContainer.frame.height)
            if promoHeight == 0.0, let promoLabel = visilabsHalfScreenView.promotionCodeLabel {
                let labelHeight = promoLabel.intrinsicContentSize.height
                if labelHeight > 0 {
                    promoHeight = Double(labelHeight) + 20.0
                }
            }
        }
        
        let imgHeight = Double(visilabsHalfScreenView.imageView?.frame.height ?? 0)
        let titleHeight = Double(visilabsHalfScreenView.titleLabel.frame.height)
        halfScreenHeight = imgHeight + titleHeight + promoHeight

        let extraSpace = Double(VisilabsHalfScreenView.closeButtonExtraSpace)
        let totalHeight = halfScreenHeight + extraSpace
        let isBottom = halfScreenNotification.position == .bottom

        let frameY: Double
        if isBottom {
            frameY = Double(bounds.size.height) - (halfScreenHeight + bottomInset) - extraSpace
        } else {
            frameY = topInset
        }

        let frame = CGRect(origin: CGPoint(x: 0, y: CGFloat(frameY)), size: CGSize(width: bounds.size.width, height: CGFloat(totalHeight)))

        let passthroughWindow = HalfScreenPassthroughWindow(frame: frame)
        if #available(iOS 13.0, *), let scene = targetWindowScene {
            passthroughWindow.windowScene = scene
        }
        passthroughWindow.hitCheckViews = { [weak self] in
            guard let self = self, let halfView = self.visilabsHalfScreenView else { return [] }
            return [halfView.containerView, halfView.closeButton]
        }
        window = passthroughWindow

        if let window = window {
            window.windowLevel = UIWindow.Level.alert
            window.clipsToBounds = false
            window.rootViewController = self
            window.isHidden = false
        }
    }

    override func hide(animated: Bool, completion: @escaping () -> Void) {
        if !isDismissing {
            isDismissing = true
            let duration = animated ? 0.5 : 0

            UIView.animate(withDuration: duration, animations: {
                var originY = 0.0
                let extraSpace = Double(VisilabsHalfScreenView.closeButtonExtraSpace)
                if self.halfScreenNotification.position == .bottom {
                    originY = self.halfScreenHeight + extraSpace + Double(VisilabsHelper.getSafeAreaInsets().bottom)
                } else {
                    originY = -(self.halfScreenHeight + extraSpace + Double(VisilabsHelper.getSafeAreaInsets().top))
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
