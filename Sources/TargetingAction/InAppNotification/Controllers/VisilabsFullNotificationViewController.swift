//
//  VisilabsFullNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 3.06.2020.
//

import AVFoundation
import UIKit

class VisilabsFullNotificationViewController: VisilabsBaseNotificationViewController {
    var fullNotification: VisilabsInAppNotification! {
        return super.notification
    }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var inAppButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var viewMask: UIView!
    @IBOutlet var fadingView: FadingView!
    @IBOutlet var bottomImageSpacing: NSLayoutConstraint!
    @IBOutlet var copyTextButton: UIButton!
    @IBOutlet var copyImageButton: UIButton!

    @IBOutlet var buttonTopCC: NSLayoutConstraint!
    @IBOutlet var bodyButtonCC: NSLayoutConstraint!
    @IBOutlet var buttonTopNormal: NSLayoutConstraint!
    @IBOutlet var bodyButtonNormal: NSLayoutConstraint!

    let pasteboard = UIPasteboard.general
    var player: AVPlayer?

    convenience init(notification: VisilabsInAppNotification) {
        self.init(notification: notification,
                  nameOfClass: String(describing: VisilabsFullNotificationViewController.notificationXibToLoad()))
    }

    static func notificationXibToLoad() -> String {
        let xibName = String(describing: VisilabsFullNotificationViewController.self)
        guard VisilabsInstance.sharedUIApplication() != nil else {
            return xibName
        }
        return xibName
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let notificationImage = notification!.image, let image = UIImage(data: notificationImage, scale: 1) {
            if let imageGif = UIImage.gif(data: notificationImage) {
                imageView.image = imageGif
            } else {
                imageView.image = image
            }

            if let width = imageView.image?.size.width,
               width / UIScreen.main.bounds.width <= 0.6, let height = imageView.image?.size.height,
               height / UIScreen.main.bounds.height <= 0.3 {
                imageView.contentMode = UIView.ContentMode.center
            }
        } else {
            VisilabsLogger.error("notification image failed to load from data")
        }

        titleLabel.text = fullNotification.messageTitle?.removeEscapingCharacters()
        bodyLabel.text = fullNotification.messageBody?.removeEscapingCharacters()

        if let bgColor = fullNotification.backGroundColor {
            viewMask.backgroundColor = bgColor.withAlphaComponent(0.8)
        } else {
            viewMask.backgroundColor = UIColor(hex: "#000000", alpha: 0.8)
        }

        if let tColor = fullNotification.messageTitleColor {
            titleLabel.textColor = tColor
        } else {
            titleLabel.textColor = UIColor(hex: "#FFFFFF", alpha: 1)
        }

        if let bColor = fullNotification.messageBodyColor {
            bodyLabel.textColor = bColor
        } else {
            bodyLabel.textColor = UIColor(hex: "#FFFFFF", alpha: 1)
        }

        if let promoTextColor = fullNotification.promotionTextColor {
            copyTextButton.setTitleColor(promoTextColor, for: .normal)
        } else {
            copyTextButton.setTitleColor(UIColor(hex: "#FFFFFF", alpha: 1), for: .normal)
        }

        if let promoBackColor = fullNotification.promotionBackgroundColor {
            copyTextButton.backgroundColor = promoBackColor
            copyImageButton.backgroundColor = promoBackColor
        } else {
            copyTextButton.backgroundColor = UIColor(hex: "#000000", alpha: 0.8)
            copyImageButton.backgroundColor = UIColor(hex: "#000000", alpha: 0.8)
        }

        let origImage = closeButton.image(for: UIControl.State.normal)
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        closeButton.setImage(tintedImage, for: UIControl.State.normal)
        closeButton.tintColor = UIColor(hex: "#FFFFFF", alpha: 1)
        closeButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit

        setupButtonView(buttonView: inAppButton)

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            if let bgColor = fullNotification.backGroundColor {
                view.backgroundColor = bgColor.withAlphaComponent(0.6)
            } else {
                view.backgroundColor = UIColor(hex: "#000000", alpha: 0.6)
            }

            viewMask.clipsToBounds = true
            viewMask.layer.cornerRadius = 6
        }
        if let promo = fullNotification.promotionCode,
           let _ = fullNotification.promotionBackgroundColor,
           let _ = fullNotification.promotionTextColor,
           !promo.isEmptyOrWhitespace {
            buttonTopCC.isActive = true
            bodyButtonCC.isActive = true
            buttonTopNormal.isActive = false
            bodyButtonNormal.isActive = false
            copyTextButton.isHidden = false
            copyImageButton.isHidden = false
            copyTextButton.setTitle(fullNotification.promotionCode, for: .normal)

        } else {
            buttonTopCC.isActive = false
            bodyButtonCC.isActive = false
            buttonTopNormal.isActive = true
            bodyButtonNormal.isActive = true
            copyTextButton.isHidden = true
            copyImageButton.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player = imageView.addVideoPlayer(urlString: notification?.videourl ?? "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }

    @IBAction func promotionCodeCopied(_ sender: Any) {
        pasteboard.string = copyTextButton.currentTitle
        VisilabsHelper.showCopiedClipboardMessage()
    }

    func setupButtonView(buttonView: UIButton) {
        buttonView.setTitle(fullNotification.buttonText, for: UIControl.State.normal)
        buttonView.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonView.layer.cornerRadius = 20
        buttonView.layer.borderWidth = 2

        var buttonColor = UIColor.black
        if let bColor = fullNotification.buttonColor {
            buttonColor = bColor
        }

        var buttonTextColor = UIColor.white
        if let bTextColor = fullNotification.buttonTextColor {
            buttonTextColor = bTextColor
        }

        buttonView.setTitleColor(buttonTextColor, for: UIControl.State.normal)
        buttonView.setTitleColor(buttonTextColor, for: UIControl.State.highlighted)
        buttonView.setTitleColor(buttonTextColor, for: UIControl.State.selected)
        buttonView.layer.borderColor = buttonView.currentTitleColor.cgColor
        buttonView.backgroundColor = buttonColor
        buttonView.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControl.Event.touchUpInside)
        buttonView.tag = 0
    }

    override func show(animated: Bool) {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
            return
        }
        if #available(iOS 13.0, *) {
            let windowScene = sharedUIApplication
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first
            if let windowScene = windowScene as? UIWindowScene {
                window = UIWindow(frame: windowScene.coordinateSpace.bounds)
                window?.windowScene = windowScene
            }
        } else {
            window = UIWindow(frame: CGRect(x: 0,
                                            y: 0,
                                            width: UIScreen.main.bounds.size.width,
                                            height: UIScreen.main.bounds.size.height))
        }
        if let window = window {
            window.alpha = 0
            window.windowLevel = UIWindow.Level.alert
            window.rootViewController = self
            window.isHidden = false
        }

        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.alpha = 1
        }, completion: { _ in
        })
    }

    override func hide(animated: Bool, completion: @escaping () -> Void) {
        let duration = animated ? 0.25 : 0
        UIView.animate(withDuration: duration, animations: {
            self.window?.alpha = 0
        }, completion: { _ in
            self.window?.isHidden = true
            self.window?.removeFromSuperview()
            self.window = nil
            completion()
        })
    }

    // TO_DO: burada additionalTrackingProperties kısmında aksiyon id'si gönderilebilir.
    @objc func buttonTapped(_ sender: AnyObject) {
        delegate?.notificationShouldDismiss(controller: self,
                                            callToActionURL: fullNotification.callToActionUrl,
                                            shouldTrack: true,
                                            additionalTrackingProperties: nil)
    }

    @IBAction func tappedClose(_ sender: Any) {
        delegate?.notificationShouldDismiss(controller: self,
                                            callToActionURL: nil,
                                            shouldTrack: false,
                                            additionalTrackingProperties: nil)
    }

    override var shouldAutorotate: Bool {
        return false
    }
}

class FadingView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
}

class InAppButtonView: UIButton {
    var origColor: UIColor?
    var wasCalled = false
    let overlayColor = UIColor(hex: "#868686", alpha: 0.2) ?? UIColor(red: 0.525, green: 0.525, blue: 0.525, alpha: 0.2)
    override var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                if !wasCalled {
                    origColor = backgroundColor
                    if origColor == UIColor(red: 0, green: 0, blue: 0, alpha: 0) {
                        backgroundColor = overlayColor
                    } else {
                        backgroundColor = backgroundColor?.add(overlay: overlayColor)
                    }
                    wasCalled = true
                }
            case false:
                backgroundColor = origColor
                wasCalled = false
            }
        }
    }
}
