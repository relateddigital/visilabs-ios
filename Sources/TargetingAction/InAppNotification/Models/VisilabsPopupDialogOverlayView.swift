//
//  VisilabsPopupDialogOverlayView.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import UIKit
//import DynamicBlurView

/// The (blurred) overlay view below the popup dialog
final public class VisilabsPopupDialogOverlayView: UIView {

    // MARK: - Appearance

    /// Turns the blur of the overlay view on or off
    @objc public dynamic var blurEnabled: Bool {
        get { return !blurView.isHidden }
        set { blurView.isHidden = !newValue }
    }

    /// The blur radius of the overlay view
    @objc public dynamic var blurRadius: CGFloat {
        get { return blurView.blurRadius }
        set { blurView.blurRadius = newValue }
    }

    /// Whether the blur view should allow for
    /// live rendering of the background
    @objc public dynamic var liveBlurEnabled: Bool {
        get { return blurView.trackingMode == .common }
        set {
            if newValue {
                blurView.trackingMode = .common
            } else {
                blurView.trackingMode = .none
            }
        }
    }

    /// The background color of the overlay view
    @objc public dynamic var color: UIColor? {
        get { return overlay.backgroundColor }
        set { overlay.backgroundColor = newValue }
    }

    /// The opacity of the overlay view
    @objc public dynamic var opacity: CGFloat {
        get { return overlay.alpha }
        set { overlay.alpha = newValue }
    }

    // MARK: - Views

    internal lazy var blurView: VisilabsDynamicBlurView = {
        let blurView = VisilabsDynamicBlurView(frame: .zero)
        blurView.blurRadius = 8
        blurView.trackingMode = .none
        blurView.isDeepRendering = true
        blurView.tintColor = .clear
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return blurView
    }()

    internal lazy var overlay: UIView = {
        let overlay = UIView(frame: .zero)
        overlay.backgroundColor = .black
        overlay.alpha = 0.7
        overlay.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return overlay
    }()

    // MARK: - Inititalizers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    fileprivate func setupView() {

        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backgroundColor = .clear
        alpha = 0

        addSubview(blurView)
        addSubview(overlay)
    }

}

// MARK: - Deprecated

extension VisilabsPopupDialogOverlayView {

    /// Whether the blur view should allow for
    /// dynamic rendering of the background
    //swiftlint:disable line_length
    @available(*, deprecated, message: "liveBlur has been deprecated and will be removed with future versions of PopupDialog. Please use isLiveBlurEnabled instead.")
    @objc public dynamic var liveBlur: Bool {
        get { return liveBlurEnabled }
        set { liveBlurEnabled = newValue }
    }

}
