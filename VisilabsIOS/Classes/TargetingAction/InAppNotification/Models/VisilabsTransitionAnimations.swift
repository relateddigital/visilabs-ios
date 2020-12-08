//
//  VisilabsTransitionAnimations.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import Foundation
import UIKit

/*!
 Presentation transition styles for the popup dialog

 - BounceUp:   Dialog bounces in from bottom and is dismissed to bottom
 - BounceDown: Dialog bounces in from top and is dismissed to top
 - ZoomIn:     Dialog zooms in and is dismissed by zooming out
 - FadeIn:     Dialog fades in and is dismissed by fading out
 */
@objc public enum PopupDialogTransitionStyle: Int {
    case bounceUp
    case bounceDown
    case zoomIn
    case fadeIn
}

/// Dialog bounces in from bottom and is dismissed to bottom
final internal class BounceUpTransition: VisilabsTransitionAnimator {

    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .in:
            toViewController.view.bounds.origin = CGPoint(x: 0, y: -from.view.bounds.size.height)
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0,
                           options: [.curveEaseOut], animations: { [weak self] in
                guard let self = self else { return }
                self.toViewController.view.bounds = self.from.view.bounds
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                guard let self = self else { return }
                self.from.view.bounds.origin = CGPoint(x: 0, y: -self.from.view.bounds.size.height)
                self.from.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

/// Dialog bounces in from top and is dismissed to top
final internal class BounceDownTransition: VisilabsTransitionAnimator {

    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .in:
            toViewController.view.bounds.origin = CGPoint(x: 0, y: from.view.bounds.size.height)
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0,
                           options: [.curveEaseOut], animations: { [weak self] in
                guard let self = self else { return }
                self.toViewController.view.bounds = self.from.view.bounds
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                guard let self = self else { return }
                self.from.view.bounds.origin = CGPoint(x: 0, y: self.from.view.bounds.size.height)
                self.from.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

/// Dialog zooms in and is dismissed by zooming out
final internal class ZoomTransition: VisilabsTransitionAnimator {

    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .in:
            toViewController.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0,
                           options: [.curveEaseOut], animations: { [weak self] in
                guard let self = self else { return }
                self.toViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                guard let self = self else { return }
                self.from.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.from.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

/// Dialog fades in and is dismissed by fading out
final internal class FadeTransition: VisilabsTransitionAnimator {

    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .in:
            toViewController.view.alpha = 0
            UIView.animate(withDuration: 0.6, delay: 0.0, options: [.curveEaseOut],
            animations: { [weak self] in
                guard let self = self else { return }
                self.toViewController.view.alpha = 1
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                guard let self = self else { return }
                self.from.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

/// Used for the always drop out animation with pan gesture dismissal
final internal class DismissInteractiveTransition: VisilabsTransitionAnimator {

    init() {
        super.init(inDuration: 0.22, outDuration: 0.32, direction: .out)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)
        UIView.animate(withDuration: outDuration, delay: 0.0, options: [.beginFromCurrentState],
                       animations: { [weak self] in
            guard let self = self else { return }
            self.from.view.bounds.origin = CGPoint(x: 0, y: -self.from.view.bounds.size.height)
            self.from.view.alpha = 0.0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
