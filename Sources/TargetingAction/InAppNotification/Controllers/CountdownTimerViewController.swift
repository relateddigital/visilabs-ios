//
//  CountdownTimerViewController.swift
//  VisilabsIOS
//
//  Created by Said Alır on 28.06.2021.


import UIKit

public class CountdownTimerViewController: UIViewController {

    var model: CountdownModel?

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainButtonTrailing: NSLayoutConstraint!
    @IBOutlet weak var mainButtonCenter: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var countdownTypeLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var couponCodeButton: UIButton!
    
    var diff: Int = 0
    var position: CGPoint?
    var window: UIWindow?
    var timeStr: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.countdownLabel.text = self.timeStr
            }
        }
    }
    
    var timer: Timer?

    public init(model: CountdownModel) {
        let bundle = Bundle(for: CountdownTimerViewController.self)
        super.init(nibName: CountdownTimerViewController.xibName(), bundle: bundle)
        self.model = model
        let now = Date().timeIntervalSince1970
        self.diff = model.finalDate - Int(now)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc func fireTimer() {
        guard let m = self.model else {
            self.timer?.invalidate()
            return
        }
        self.timeStr = CountdownModel.convertDateIntoTimeLabel(date: m.finalDate, type: m.timerType)
    }
    func configure() {
        guard let m = self.model else { return }
        self.titleLabel.text = m.title
        self.subtitleLabel.text = m.subtitle
        self.mainButton.setTitle(m.buttonText, for: .normal)
    
        self.titleLabel.font = m.titleFont
        self.subtitleLabel.font = m.subtitleFont
        self.mainButton.titleLabel?.font = m.buttonFont
        
        self.titleLabel.textColor = m.titleColor
        self.subtitleLabel.textColor = m.subtitleColor
        self.mainButton.titleLabel?.textColor = m.buttonTextColor
        self.mainButton.backgroundColor = m.buttonColor
        self.view.backgroundColor = m.backgroundColor
        
        self.countdownLabel.text = CountdownModel.convertDateIntoTimeLabel(date: m.finalDate, type: m.timerType)
        self.countdownTypeLabel.text = m.timerType.rawValue
        
        mainButtonTrailing.isActive = false
        mainButtonCenter.isActive = true
        couponCodeButton.isHidden = true
        if let couponCode = m.couponCode,
           let cColor = m.couponColor,
           let cbgColor = m.couponBgColor,
           let cFont = m.couponFont {
            self.couponCodeButton.backgroundColor = cbgColor
            self.couponCodeButton.titleLabel?.text = couponCode
            self.couponCodeButton.titleLabel?.textColor = cColor
            self.couponCodeButton.titleLabel?.font = cFont
            mainButtonCenter.isActive = false
            mainButtonTrailing.isActive = true
            couponCodeButton.isHidden = false

        }

        self.mainButton.constraints.activate()
        self.couponCodeButton.constraints.activate()
        
        closeButton.setImage(getUIImage(named: "VisilabsCloseButton"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        if m.closeButtonColor == .black {
            closeButton.setImage(getUIImage(named: "VisilabsCloseButtonBlack"), for: .normal)
        }

        if m.location == .bottom {
            bottomConstraint.isActive = true
            topConstraint.isActive = false
        } else {
            bottomConstraint.isActive = false
            topConstraint.isActive = true
        }
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

        preferredY = preferredY * 0.8
        
        if self.model?.location ?? .top == .top {
            preferredY = 84
        }
        
        if sharedUIApplication.statusBarOrientation.isPortrait
            && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            frame = CGRect(x: 0,
                           y: preferredY,
                           width: bounds.size.width,
                           height: 250)
        } else { // Is iPad or Landscape mode
            frame = CGRect(x: bounds.size.width / 4,
                           y: preferredY,
                           width: bounds.size.width / 2,
                           height: 250)
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
        let xibName = String(describing: CountdownTimerViewController.self)
        guard RelatedDigitalInstance.sharedUIApplication() != nil else {
            return xibName
        }
        return xibName
    }
    
    func getUIImage(named: String) -> UIImage? {
        let bundle = Bundle(identifier: "com.relateddigital.visilabs")
        return UIImage(named: named, in: bundle, compatibleWith: nil)!.resized(withPercentage: CGFloat(0.75))
    }

}
