//
//  VisilabsColor.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import UIKit



extension UIColor {
    
    class func visilabs_applicationPrimaryColor() -> UIColor? {
        var color: UIColor? = nil
        
        // First try and find the color of the UINavigationBar of the top UINavigationController that is showing now.
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        var topNavigationController: UINavigationController? = nil
        
        repeat {
            if (rootViewController is UINavigationController) {
                topNavigationController = rootViewController as? UINavigationController
            } else if rootViewController?.navigationController != nil {
                topNavigationController = rootViewController?.navigationController
            }
        } while (rootViewController == rootViewController?.presentedViewController)
        
        if topNavigationController != nil {
            if (topNavigationController!.navigationBar.responds(to: #selector(getter: UINavigationBar.barTintColor))) {
                color = topNavigationController?.navigationBar.barTintColor
            } else {
                color = topNavigationController?.navigationBar.tintColor
            }
        }
        
        // Then try and use the UINavigationBar default color for the app
        if color != nil && UINavigationBar.appearance().responds(to: #selector(getter: UINavigationBar.barTintColor)) {
            color = UINavigationBar.appearance().barTintColor
        }

        // Or the UITabBar default color
        if color != nil && UITabBar.appearance().responds(to: #selector(getter: UINavigationBar.barTintColor)) {
            color = UITabBar.appearance().barTintColor
        }
        
        return color
    }
    
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
        var (h, s, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            newColor = UIColor(hue: h, saturation: saturation, brightness: b, alpha: a)
        }
        return newColor
    }
}
