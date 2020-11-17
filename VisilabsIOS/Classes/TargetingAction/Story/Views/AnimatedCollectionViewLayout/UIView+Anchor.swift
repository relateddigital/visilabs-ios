//
//  UIView+Anchor.swift
//  AnimatedCollectionViewLayout
//
//  Created by Jin Wang on 8/2/17.
//  Copyright © 2017 Uthoft. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func keepCenterAndApplyAnchorPoint(_ point: CGPoint) {

        guard layer.anchorPoint != point else { return }

        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var newPos = layer.position
        newPos.x -= oldPoint.x
        newPos.x += newPoint.x

        newPos.y -= oldPoint.y
        newPos.y += newPoint.y

        layer.position = newPos
        layer.anchorPoint = point
    }
}
