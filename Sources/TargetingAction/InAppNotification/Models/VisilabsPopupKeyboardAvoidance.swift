//
//  VisilabsPopupKeyboardAvoidance.swift
//  VisilabsIOS
//

import Foundation
import UIKit

/// A popup container that can be lifted vertically to stay clear of the keyboard.
internal protocol VisilabsPopupKeyboardAvoidingContainer: AnyObject {
    var centerYConstraint: NSLayoutConstraint? { get }
    /// The card that holds the popup content, i.e. the part that must stay visible.
    var keyboardAvoidingCard: UIView { get }
    var containerView: UIView { get }
}

extension VisilabsPopupKeyboardAvoidingContainer where Self: UIView {
    var containerView: UIView { self }
}

extension VisilabsPopupDialogContainerView: VisilabsPopupKeyboardAvoidingContainer {
    var keyboardAvoidingCard: UIView { shadowContainer }
}

extension VisilabsNpsWithNumbersContainerView: VisilabsPopupKeyboardAvoidingContainer {
    var keyboardAvoidingCard: UIView { shadowContainer }
}

internal enum VisilabsPopupKeyboardAvoidance {

    /// Breathing room between the bottom of the popup and the top of the keyboard.
    private static let keyboardGap: CGFloat = 12.0
    /// Minimum space kept between the top of the popup and the top of the safe area.
    private static let minimumTopInset: CGFloat = 8.0

    /// The `centerY` offset needed to keep the popup just above the keyboard.
    ///
    /// Returns the smallest lift that clears the keyboard rather than the full keyboard
    /// height, and never lifts the popup past the top of the safe area, so a popup that is
    /// taller than the space above the keyboard stays put instead of running off screen.
    static func offset(forKeyboardFrame keyboardFrame: CGRect,
                       container: VisilabsPopupKeyboardAvoidingContainer?) -> CGFloat {
        guard let container = container else { return 0 }
        let containerView = container.containerView
        // The popup can change size right before the keyboard appears, e.g. when an NPS
        // popup advances to its feedback page, so measure against settled layout.
        containerView.layoutIfNeeded()
        let cardHeight = container.keyboardAvoidingCard.bounds.height
        guard containerView.bounds.height > 0, cardHeight > 0 else { return 0 }

        // The keyboard frame is reported in screen coordinates.
        let keyboardTop = containerView.convert(keyboardFrame, from: nil).minY

        // Resting geometry, independent of any offset currently applied.
        let restingTop = (containerView.bounds.height - cardHeight) / 2.0
        let restingBottom = restingTop + cardHeight

        let overlap = restingBottom + keyboardGap - keyboardTop
        guard overlap > 0 else { return 0 }

        let availableLift = restingTop - containerView.safeAreaInsets.top - minimumTopInset
        guard availableLift > 0 else { return 0 }

        return -min(overlap, availableLift)
    }

    /// Matches the keyboard's own animation so the popup moves in step with it.
    static func animate(_ view: UIView, userInfo: [AnyHashable: Any]?) {
        let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let curve = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
            ?? Int(UIView.AnimationCurve.easeInOut.rawValue)
        let options = UIView.AnimationOptions(rawValue: UInt(curve) << 16)

        UIView.animate(withDuration: duration, delay: 0,
                       options: [options, .beginFromCurrentState],
                       animations: { view.layoutIfNeeded() })
    }
}
