//
//  VisilabsColor.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import Foundation




extension UIColor {
    
    
    class func visilabs_lightEffect() -> UIColor? {
        return UIColor(white: 1.0, alpha: 0.3)
    }

    class func visilabs_extraLightEffect() -> UIColor? {
        return UIColor(white: 0.97, alpha: 0.82)
    }

    class func visilabs_darkEffect() -> UIColor? {
        return UIColor(white: 0.11, alpha: 0.73)
    }

    func withSaturationComponent(_ saturation: CGFloat) -> UIColor? {
        var newColor: UIColor?
        var h, s, b, a: CGFloat
        if getHue(UnsafeMutablePointer<CGFloat>(mutating: &h), saturation: UnsafeMutablePointer<CGFloat>(mutating: &s), brightness: UnsafeMutablePointer<CGFloat>(mutating: &b), alpha: UnsafeMutablePointer<CGFloat>(mutating: &a)) {
            newColor = UIColor(hue: h, saturation: saturation, brightness: b, alpha: a)
        }
        return newColor
    }
}
