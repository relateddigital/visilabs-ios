//
//  VisilabsPresentationController.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import Foundation
import UIKit

final internal class VisilabsPresentationController: UIPresentationController {

    private lazy var overlay: VisilabsPopupDialogOverlayView = {
        return VisilabsPopupDialogOverlayView(frame: .zero)
    }()

    override func presentationTransitionWillBegin() {

        guard let containerView = containerView else { return }

        overlay.frame = containerView.bounds
        containerView.insertSubview(overlay, at: 0)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.overlay.alpha = 1.0
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.overlay.alpha = 0.0
        }, completion: nil)
    }

    override func containerViewWillLayoutSubviews() {
        guard let presentedView = presentedView else { return }
        presentedView.frame = frameOfPresentedViewInContainerView
    }

}
