//
//  VisilabsTransitionAnimator.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import Foundation
import UIKit

/// Base class for custom transition animations
internal class VisilabsTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var toViewController: UIViewController!
    var from: UIViewController!
    let inDuration: TimeInterval
    let outDuration: TimeInterval
    let direction: AnimationDirection

    init(inDuration: TimeInterval, outDuration: TimeInterval, direction: AnimationDirection) {
        self.inDuration = inDuration
        self.outDuration = outDuration
        self.direction = direction
        super.init()
    }

    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return direction == .in ? inDuration : outDuration
    }

    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch direction {
        case .in:
            guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
                let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else {
                return

            }

            self.toViewController = toVC
            self.from = from

            let container = transitionContext.containerView
            container.addSubview(toVC.view)
        case .out:
            guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
                let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
                return
            }

            self.toViewController = toVC
            self.from = from
        }
    }
}
