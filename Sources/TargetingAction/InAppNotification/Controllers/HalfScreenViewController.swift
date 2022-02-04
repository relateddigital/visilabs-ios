//
//  HalfScreenViewController.swift
//  VisilabsIOS
//
//  Created by Egemen Gulkilik on 28.09.2021.
//

import UIKit

public enum HalfScreenLocation: String {
    case top
    case bottom
}

public class HalfScreenModel {
    
    public init(text: String,
                location: HalfScreenLocation,
                duration: Int,
                backgroundColor: UIColor,
                textColor: UIColor,
                textFont: UIFont,
                closeButtonColor: ButtonColor? = nil) {
        
        self.text = text
        self.location = location
        self.duration = duration
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.textFont = textFont
        self.closeButtonColor = closeButtonColor
    }
    
    var text: String
    var location: HalfScreenLocation
    var duration = 10 //seconds
    var backgroundColor: UIColor
    var textColor: UIColor
    var textFont: UIFont
    var closeButtonColor: ButtonColor? = nil
    
}

public class HalfScreenViewController: UIViewController {

    var model: HalfScreenModel?

    //@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    //@IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var position: CGPoint?
    var window: UIWindow?

    public init(model: HalfScreenModel) {
        let bundle = Bundle(for: HalfScreenModel.self)
        super.init(nibName: HalfScreenViewController.xibName(), bundle: bundle)
        self.model = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        guard let m = self.model else { return }
        self.textLabel.text = m.text
        self.textLabel.font = m.textFont
        self.textLabel.textColor = m.textColor
        
        if m.location == .top {
            //self.bottomConstraint.isActive = false
            //self.topConstraint.isActive =  true
            //NSLayoutConstraint.activate([topConstraint])
            //NSLayoutConstraint.deactivate([bottomConstraint])
        }
        
        
        //dismissWithDelay(m.duration)
        
        /*
        if m.duration != .infinite {
            dismissWithDelay(m.duration.rawValue)
        }
         */
        
        if let bColor = m.closeButtonColor {
            self.closeButton.isHidden = false
            if bColor == .white {
                let img = RelatedDigitalHelper.getUIImage(named: "VisilabsCloseButton")
                self.closeButton.setImage(img, for: .normal)
            }
        }
        
        self.holderView.backgroundColor = m.backgroundColor
        self.imageView.setImage(url: "https://brtk.net/wp-content/uploads/2021/08/28/30agustossss.jpg?ver=cf14dae8e18a0da9aee40b2c8f3f2b39")
    }
    
    public func showNow(animated: Bool) {
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
        let frame: CGRect
        var preferredY = bounds.size.height
        if self.model?.location == HalfScreenLocation.top {
            preferredY = 65
        }
        if sharedUIApplication.statusBarOrientation.isPortrait
            && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            frame = CGRect(x: 0,
                           y: preferredY,
                           width: bounds.size.width,
                           height: 75)
        } else { // Is iPad or Landscape mode
            frame = CGRect(x: bounds.size.width / 4,
                           y: preferredY,
                           width: bounds.size.width / 2,
                           height: 75)
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
    
    fileprivate func setWindowAndAddAnimation(_ animated: Bool) {
        if let window = window {
            window.windowLevel = UIWindow.Level.alert
            window.clipsToBounds = true
            window.rootViewController = self
            window.isHidden = false
        }

        let duration = animated ? 0.1 : 0
        UIView.animate(withDuration: duration, animations: {
            //self.window?.frame.origin.y -= 75
            self.window?.frame.origin.y -= 0
        }, completion: { _ in
            self.position = self.window?.layer.position
        })
    }
    
    func hide(animated: Bool, completion: @escaping () -> Void) {
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
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.hide(animated: true) {
            
        }
        self.dismiss(animated: true, completion: nil)
    }

    func dismissWithDelay(_ duration: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration)) {
            self.hide(animated: true) {
                
            }
            self.dismiss(animated: true, completion: nil)
        }
    }

    static func xibName() -> String {
        let xibName = String(describing: HalfScreenViewController.self)
        guard RelatedDigitalInstance.sharedUIApplication() != nil else {
            return xibName
        }
        return xibName
    }

}

