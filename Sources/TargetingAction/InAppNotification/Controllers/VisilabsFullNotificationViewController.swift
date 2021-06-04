//
//  VisilabsFullNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 3.06.2020.
//

import UIKit

class VisilabsFullNotificationViewController: VisilabsBaseNotificationViewController {

    var fullNotification: VisilabsInAppNotification! {
        return super.notification
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var inAppButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var viewMask: UIView!
    @IBOutlet weak var fadingView: FadingView!
    @IBOutlet weak var bottomImageSpacing: NSLayoutConstraint!
    @IBOutlet weak var copyTextButton: UIButton!
    @IBOutlet weak var copyImageButton: UIButton!
    
    @IBOutlet weak var buttonTopCC: NSLayoutConstraint!
    @IBOutlet weak var bodyButtonCC: NSLayoutConstraint!
    @IBOutlet weak var buttonTopNormal: NSLayoutConstraint!
    @IBOutlet weak var bodyButtonNormal: NSLayoutConstraint!
    
    var isCopyEnabled = true
    let pasteboard = UIPasteboard.general

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
            imageView.image = image
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
                self.view.backgroundColor = bgColor.withAlphaComponent(0.6)
            } else {
                self.view.backgroundColor = UIColor(hex: "#000000", alpha: 0.6)
            }

            viewMask.clipsToBounds = true
            viewMask.layer.cornerRadius = 6
        }
        if let promo = self.fullNotification.promotionCode,
           let _ = self.fullNotification.promotionBackgroundColor,
           let _ = self.fullNotification.promotionTextColor,
           !promo.isEmptyOrWhitespace {
            self.buttonTopCC.isActive = true
            self.bodyButtonCC.isActive = true
            self.buttonTopNormal.isActive = false
            self.bodyButtonNormal.isActive = false
            self.copyTextButton.isHidden = false
            self.copyImageButton.isHidden = false
            self.copyTextButton.setTitle(fullNotification.promotionCode, for: .normal)
            
        } else {
            self.buttonTopCC.isActive = false
            self.bodyButtonCC.isActive = false
            self.buttonTopNormal.isActive = true
            self.bodyButtonNormal.isActive = true
            self.copyTextButton.isHidden = true
            self.copyImageButton.isHidden = true
        }
        
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

    //TO_DO: burada additionalTrackingProperties kısmında aksiyon id'si gönderilebilir.
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
        self.backgroundColor = UIColor.clear
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
