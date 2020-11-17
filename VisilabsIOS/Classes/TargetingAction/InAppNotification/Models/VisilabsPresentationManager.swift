//
//  VisilabsPresentationManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import Foundation
import UIKit

final internal class VisilabsPresentationManager: NSObject, UIViewControllerTransitioningDelegate {

    var transitionStyle: PopupDialogTransitionStyle
    var interactor: VisilabsInteractiveTransition

    init(transitionStyle: PopupDialogTransitionStyle, interactor: VisilabsInteractiveTransition) {
        self.transitionStyle = transitionStyle
        self.interactor = interactor
        super.init()
    }

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = VisilabsPresentationController(presentedViewController: presented,
                                                                    presenting: source)
        return presentationController
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        var transition: VisilabsTransitionAnimator
        switch transitionStyle {
        case .bounceUp:
            transition = BounceUpTransition(direction: .in)
        case .bounceDown:
            transition = BounceDownTransition(direction: .in)
        case .zoomIn:
            transition = ZoomTransition(direction: .in)
        case .fadeIn:
            transition = FadeTransition(direction: .in)
        }

        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if interactor.hasStarted || interactor.shouldFinish {
            return DismissInteractiveTransition()
        }

        var transition: VisilabsTransitionAnimator
        switch transitionStyle {
        case .bounceUp:
            transition = BounceUpTransition(direction: .out)
        case .bounceDown:
            transition = BounceDownTransition(direction: .out)
        case .zoomIn:
            transition = ZoomTransition(direction: .out)
        case .fadeIn:
            transition = FadeTransition(direction: .out)
        }

        return transition
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
