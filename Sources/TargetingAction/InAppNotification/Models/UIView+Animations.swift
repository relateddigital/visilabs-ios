//
//  UIView+Animations.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import UIKit

internal enum AnimationDirection {
    case `in` // swiftlint:disable:this identifier_name
    case out
}

internal extension UIView {

    var fadeKey: String { return "FadeAnimation" }

    func pv_fade(_ direction: AnimationDirection, _ value: Float, duration: CFTimeInterval = 0.08) {
        layer.removeAnimation(forKey: fadeKey)
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = duration
        animation.fromValue = layer.presentation()?.opacity
        layer.opacity = value
        animation.fillMode = CAMediaTimingFillMode.forwards
        layer.add(animation, forKey: fadeKey)
    }

    func pv_layoutIfNeededAnimated(duration: CFTimeInterval = 0.08) {
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
