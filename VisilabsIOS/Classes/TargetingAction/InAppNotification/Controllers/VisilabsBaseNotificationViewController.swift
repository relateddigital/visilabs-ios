//
//  VisilabsBaseNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.05.2020.
//

import Foundation


protocol VisilabsNotificationViewControllerDelegate {
    @discardableResult
    func notificationShouldDismiss(controller: VisilabsBaseNotificationViewController,
                                   callToActionURL: URL?,
                                   shouldTrack: Bool,
                                   additionalTrackingProperties: [String:String]?) -> Bool
}

class VisilabsBaseNotificationViewController: UIViewController {

    var notification: VisilabsInAppNotification!
    var delegate: VisilabsNotificationViewControllerDelegate?
    var window: UIWindow?
    var panStartPoint: CGPoint!
    
    convenience init(notification: VisilabsInAppNotification, nameOfClass: String) {
        // avoiding `type(of: self)` as it doesn't work with Swift 4.0.3 compiler
        // perhaps due to `self` not being fully constructed at this point
        let bundle = Bundle(for: VisilabsBaseNotificationViewController.self)
        self.init(nibName: nameOfClass, bundle: bundle)
        self.notification = notification
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }

    func show(animated: Bool) {}
    func hide(animated: Bool, completion: @escaping () -> Void) {}
    
}


extension UIColor {

    convenience init?(hex: String?, alpha: CGFloat = 1.0) {
        
        guard let hexString = hex else {
            return nil
        }
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) { cString.removeFirst() }

        if ((cString.count) != 6) {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha)
    }
    
    convenience init?(rgbaString: String) {
        let rgbaNumbersString = rgbaString.replacingOccurrences(of: "rgba(", with: "").replacingOccurrences(of: ")", with: "")
        let rgbaParts = rgbaNumbersString.split(separator: ",")
        if rgbaParts.count == 4 {
            guard let r = Float(rgbaParts[0]), let g = Float(rgbaParts[1]), let b = Float(rgbaParts[2]), let a = Float(rgbaParts[3]) else {
               return nil
            }
            self.init(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: CGFloat(a))
            
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

        let r = fgA * fgR + (1 - fgA) * bgR
        let g = fgA * fgG + (1 - fgA) * bgG
        let b = fgA * fgB + (1 - fgA) * bgB

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
