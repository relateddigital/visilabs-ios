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
    /**
     The shorthand four-digit hexadecimal representation of color with alpha.
     #RGBA defines to the color #AARRGGBB.

     - parameter MPHex: hexadecimal value.
     */
    public convenience init(MPHex: UInt) {
        let divisor = CGFloat(255)
        let alpha   = CGFloat((MPHex & 0xFF000000) >> 24) / divisor
        let red     = CGFloat((MPHex & 0x00FF0000) >> 16) / divisor
        let green   = CGFloat((MPHex & 0x0000FF00) >>  8) / divisor
        let blue    = CGFloat( MPHex & 0x000000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public convenience init(hex: String, alpha: CGFloat = 1.0) {
      var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

      if (cString.hasPrefix("#")) { cString.removeFirst() }

      if ((cString.count) != 6) {
        self.init(hex: "000000") // return black color for wrong hex input
        return
      }

      var rgbValue: UInt64 = 0
      Scanner(string: cString).scanHexInt64(&rgbValue)

      self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha)
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
