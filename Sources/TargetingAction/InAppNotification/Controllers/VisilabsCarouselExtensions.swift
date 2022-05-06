//
//  VisilabsCarouselExtensions.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 8.02.2022.
//

import UIKit

extension UIApplication {

    static var applicationWindow: UIWindow {
        return UIApplication.shared.keyWindow!
    }

    static var isPortraitOnly: Bool {
        let orientations = UIApplication.shared.supportedInterfaceOrientations(for: nil)
        return !(orientations.contains(.landscapeLeft) || orientations.contains(.landscapeRight) || orientations.contains(.landscape))
    }
}

extension UIView {

    public var boundsCenter: CGPoint {
        return CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
    }

}

extension UIColor {
    
    open func shadeDarker() -> UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let variance: CGFloat = 0.4
        let newR = CGFloat.maximum(r * variance, 0.0),
        newG = CGFloat.maximum(g * variance, 0.0),
        newB = CGFloat.maximum(b * variance, 0.0)
        
        return UIColor(red: newR, green: newG, blue: newB, alpha: 1.0)
    }
    
}

import CoreGraphics

extension CGSize {
    func inverted() -> CGSize {
        return CGSize(width: self.height, height: self.width)
    }
}


public extension UIScreen {
    class var hasNotch: Bool {
        // This will of course fail if Apple produces an notchless iPhone with these dimensions,
        // but is the simplest detection mechanism so far.
        return main.nativeBounds.size == CGSize(width: 1125, height: 2436)
    }
}

extension DisplaceableView {
    func getView() -> UIView {
        let view = VisilabsCarouselItemView(frame: .zero, visilabsCarouselItem: self.visilabsCarouselItem)
        view.bounds = self.bounds
        view.center = self.center
        return view
    }
}

extension DisplaceableView {
    func frameInCoordinatesOfScreen() -> CGRect {
        return UIView().convert(self.bounds, to: UIScreen.main.coordinateSpace)
    }
}

public extension UIViewController {
    func presentCarouselNotification(_ gallery: VisilabsCarouselNotificationViewController, completion: (() -> Void)? = {}) {
        present(gallery, animated: false, completion: completion)
    }
}
