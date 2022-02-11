//
//  VisilabsBaseNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.05.2020.
//

import UIKit

public protocol VisilabsNotificationViewControllerDelegate: AnyObject {
    @discardableResult
    func notificationShouldDismiss(controller: VisilabsBaseViewProtocol,
                                   callToActionURL: URL?,
                                   shouldTrack: Bool,
                                   additionalTrackingProperties: [String: String]?) -> Bool
    
}


public protocol VisilabsBaseViewProtocol {
    var notification: VisilabsInAppNotification? { get set }
    func hide(animated: Bool, completion: @escaping () -> Void)
}

public class VisilabsBasePageViewController: UIPageViewController, VisilabsBaseViewProtocol {
    public func hide(animated: Bool, completion: @escaping () -> Void) {
        
    }
    
    weak var visilabsDelegate: VisilabsNotificationViewControllerDelegate?
    public var notification: VisilabsInAppNotification? = nil
}

public class VisilabsBaseNotificationViewController: UIViewController, VisilabsBaseViewProtocol {
    
    public var notification: VisilabsInAppNotification?
    var mailForm: MailSubscriptionViewModel?
    var scratchToWin: ScratchToWinModel?
    var spinToWin: SpinToWinViewModel?
    var productStatNotifier: VisilabsProductStatNotifierViewModel?
    
    weak var delegate: VisilabsNotificationViewControllerDelegate?
    weak var inappButtonDelegate: VisilabsInappButtonDelegate?
    var window: UIWindow?
    var panStartPoint: CGPoint!
    
    convenience init(notification: VisilabsInAppNotification, nameOfClass: String) {
        
#if SWIFT_PACKAGE
        let bundle = Bundle.module
#else
        let bundle = Bundle(for: type(of: self))
#endif
        self.init(nibName: nameOfClass, bundle: bundle)
        self.notification = notification
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    func show(animated: Bool) {}
    public func hide(animated: Bool, completion: @escaping () -> Void) {}
    
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.mailForm != nil || self.spinToWin != nil {
            return
        }
        
        
        if let notification = self.notification, VisilabsConstants.backgroundClickCloseDisabledInAppNotificationTypes.contains(notification.type) {
            return
        }
        
        let touch = touches.first
        if !(touch?.view is VisilabsPopupDialogDefaultView)
            && !(touch?.view is CosmosView) &&
            !(touch?.view is UIImageView) &&
            !(touch?.view is ScratchUIView) &&
            !(touch?.view?.accessibilityIdentifier == "buttonStack") {
            
            if let notification = notification, notification.closePopupActionType == "closebutton" {
                return
            }
            
            self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: true, additionalTrackingProperties: nil)
        } else {
            //            Dont dismiss on tap
        }
    }
}

extension UIColor {
    
    convenience init?(hex: String?, alpha: CGFloat = 1.0) {
        
        guard let hexString = hex else {
            return nil
        }
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") { cString.removeFirst() }
        
        if cString.count != 6 && cString.count != 8 {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        if cString.count == 6 {
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: alpha)
        } else {
            let alpha = CGFloat((rgbValue & 0xff000000) >> 24) / 255
            let red = CGFloat((rgbValue & 0x00ff0000) >> 16) / 255
            let green = CGFloat((rgbValue & 0x0000ff00) >> 8) / 255
            let blue = CGFloat(rgbValue & 0x000000ff) / 255
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    convenience init?(rgbaString: String) {
        let rgbaNumbersString = rgbaString.replacingOccurrences(of: "rgba(", with: "")
            .replacingOccurrences(of: ")", with: "")
        let rgbaParts = rgbaNumbersString.split(separator: ",")
        if rgbaParts.count == 4 {
            guard let red = Float(rgbaParts[0]),
                  let green = Float(rgbaParts[1]),
                  let blue = Float(rgbaParts[2]),
                  let alpha = Float(rgbaParts[3]) else {
                      return nil
                  }
            self.init(red: CGFloat(red / 255.0),
                      green: CGFloat(green / 255.0),
                      blue: CGFloat(blue / 255.0),
                      alpha: CGFloat(alpha))
            
        } else {
            return nil
        }
    }
    
    /**
     Add two colors together
     */
    func add(overlay: UIColor) -> UIColor {
        var bgR: CGFloat = 0
        var bgG: CGFloat = 0
        var bgB: CGFloat = 0
        var bgA: CGFloat = 0
        
        var fgR: CGFloat = 0
        var fgG: CGFloat = 0
        var fgB: CGFloat = 0
        var fgA: CGFloat = 0
        
        self.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
        overlay.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)
        
        let red = fgA * fgR + (1 - fgA) * bgR
        let green = fgA * fgG + (1 - fgA) * bgG
        let blue = fgA * fgB + (1 - fgA) * bgB
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
