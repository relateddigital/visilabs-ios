//
//  SocialProofViewController.swift
//  VisilabsIOS
//
//  Created by Said Alır on 19.02.2021.
//

import UIKit

public class SocialProofViewController: UIViewController {

    var model: SocialProofModel?

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberText: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    var position: CGPoint?
    var window: UIWindow?

    public init(model: SocialProofModel) {
        let bundle = Bundle(for: SocialProofViewController.self)
        super.init(nibName: SocialProofViewController.xibName(), bundle: bundle)
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
        self.numberText.text = m.number
        self.textLabel.text = m.text
        self.numberText.font = m.numberFont
        self.textLabel.font = m.textFont
        self.numberText.textColor = m.numberColor
        self.textLabel.textColor = m.textColor
        
        if m.location == .top {
            self.bottomConstraint.isActive = false
            self.topConstraint.isActive =  true
            NSLayoutConstraint.activate([topConstraint])
            NSLayoutConstraint.deactivate([bottomConstraint])
        }
        
        if m.duration != .infinite {
            dismissWithDelay(m.duration.rawValue)
        }
        
        if let bColor = m.closeButtonColor {
            self.closeButton.isHidden = false
            if bColor == .white {
                let img = VisilabsHelper.getUIImage(named: "VisilabsCloseButton")
                self.closeButton.setImage(img, for: .normal)
            }
        }
        
        self.holderView.backgroundColor = m.backgroundColor
    }
    
    public func showNow(animated: Bool) {
        guard let sharedUIApplication = VisilabsInstance.sharedUIApplication() else {
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
        if self.model?.location == SocialProofLocation.top {
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
            self.window?.frame.origin.y -= 75
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
        let xibName = String(describing: SocialProofViewController.self)
        guard VisilabsInstance.sharedUIApplication() != nil else {
            return xibName
        }
        return xibName
    }

}
