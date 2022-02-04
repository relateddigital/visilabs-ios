//
//  VisilabsPopupDialogOverlayView.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import UIKit
// import DynamicBlurView

/// The (blurred) overlay view below the popup dialog
final public class RelatedDigitalPopupDialogOverlayView: UIView {

    // MARK: - Views

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
        addSubview(overlay)
    }
}
