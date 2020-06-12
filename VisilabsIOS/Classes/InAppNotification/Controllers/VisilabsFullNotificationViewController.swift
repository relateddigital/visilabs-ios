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
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var inAppButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var viewMask: UIView!
    @IBOutlet weak var fadingView: FadingView!
    @IBOutlet weak var bottomImageSpacing: NSLayoutConstraint!
    
    convenience init(notification: VisilabsInAppNotification) {
        self.init(notification: notification, nameOfClass: String(describing: VisilabsFullNotificationViewController.notificationXibToLoad()))
    }
    
    static func notificationXibToLoad() -> String {
        var xibName = String(describing: VisilabsFullNotificationViewController.self)
        guard VisilabsInstance.sharedUIApplication() != nil else {
            return xibName
        }
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            if UIDevice.current.orientation.isLandscape {
                xibName += "~iphonelandscape"
            } else {
                xibName += "~iphoneportrait"
            }
        } else {
            xibName += "~ipad"
        }

        return xibName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let notificationImage = notification.image, let image = UIImage(data: notificationImage, scale: 2) {
            imageView.image = image
            if let width = imageView.image?.size.width, width / UIScreen.main.bounds.width <= 0.6, let height = imageView.image?.size.height,
                height / UIScreen.main.bounds.height <= 0.3 {
                imageView.contentMode = UIView.ContentMode.center
            }
        } else {
            VisilabsLogger.error(message: "notification image failed to load from data")
        }

        /*
        if fullNotification.messageTitle == nil || fullNotification.messageBody == nil {
            NSLayoutConstraint(item: titleLabel!,
                               attribute: NSLayoutConstraint.Attribute.height,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: nil,
                               attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: bodyLabel!,
                               attribute: NSLayoutConstraint.Attribute.height,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: nil,
                               attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                               multiplier: 1,
                               constant: 0).isActive = true
        } else {
            titleLabel.text = fullNotification.messageTitle
            bodyLabel.text = fullNotification.messageBody
        }
 */

        
        titleLabel.text = fullNotification.messageTitle
        bodyLabel.text = fullNotification.messageBody
        
        if let bgColor = fullNotification.backGroundColor {
            viewMask.backgroundColor = UIColor(hex: bgColor, alpha: 0.8)
        }else{
            viewMask.backgroundColor = UIColor(hex: "#000000", alpha: 0.8)
        }
        
        if let tColor = fullNotification.messageTitleColor {
            titleLabel.textColor = UIColor(hex: tColor, alpha: 1)
        }else{
            titleLabel.textColor = UIColor(hex: "#FFFFFF", alpha: 1)
        }
        
        if let bColor = fullNotification.messageBodyColor {
            bodyLabel.textColor = UIColor(hex: bColor, alpha: 1)
        }else{
            bodyLabel.textColor = UIColor(hex: "#FFFFFF", alpha: 1)
        }

        let origImage = closeButton.image(for: UIControl.State.normal)
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        closeButton.setImage(tintedImage, for: UIControl.State.normal)
        closeButton.tintColor = UIColor(hex: "#FFFFFF", alpha: 1)
        closeButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit

        
        setupButtonView(buttonView: inAppButton)
        
        /*
        if takeoverNotification.buttons.count >= 1 {
            setupButtonView(buttonView: firstButton, buttonModel: takeoverNotification.buttons[0], index: 0)
            if takeoverNotification.buttons.count == 2 {
                setupButtonView(buttonView: secondButton, buttonModel: takeoverNotification.buttons[1], index: 1)
            } else {
                NSLayoutConstraint(item: secondButtonContainer!,
                                   attribute: NSLayoutConstraint.Attribute.width,
                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: nil,
                                   attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                   multiplier: 1,
                                   constant: 0).isActive = true
            }
        }


        if !takeoverNotification.shouldFadeImage {
            if bottomImageSpacing != nil {
                bottomImageSpacing.constant = 30
            }
            fadingView.layer.mask = nil
        }
  */

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            
            if let bgColor = fullNotification.backGroundColor {
                self.view.backgroundColor = UIColor(hex: bgColor, alpha: 0.6)
            }else{
                self.view.backgroundColor = UIColor(hex: "#000000", alpha: 0.6)
            }
            
            //self.view.backgroundColor = UIColor(hex: "#000000", alpha: 0.8)
            //self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0.8)
            viewMask.clipsToBounds = true
            viewMask.layer.cornerRadius = 6
        }

    }
    
    func setupButtonView(buttonView: UIButton) {
        buttonView.setTitle(fullNotification.buttonText, for: UIControl.State.normal)
        buttonView.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonView.layer.cornerRadius = 20
        buttonView.layer.borderWidth = 2
        
        var buttonColor = UIColor.black
        if let bColor = fullNotification.buttonColor{
            buttonColor = UIColor(hex: bColor)
        }
        
        var buttonTextColor = UIColor.white
        if let bColor = fullNotification.buttonTextColor{
            buttonTextColor = UIColor(hex: bColor)
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

    
    //TODO: burada additionalTrackingProperties kısmında aksiyon id'si gönderilebilir.
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
    var gradientMask: CAGradientLayer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gradientMask = CAGradientLayer()
        layer.mask = gradientMask
        gradientMask.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        gradientMask.locations = [0, 0.4, 0.9, 1]
        gradientMask.startPoint = CGPoint(x: 0, y: 0)
        gradientMask.endPoint = CGPoint(x: 0, y: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientMask.frame = bounds
    }
}

class InAppButtonView: UIButton {
    var origColor: UIColor?
    var wasCalled = false
    let overlayColor = UIColor(MPHex: 0x33868686)
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
