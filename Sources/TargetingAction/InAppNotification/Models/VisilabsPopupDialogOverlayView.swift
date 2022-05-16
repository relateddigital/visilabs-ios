//
//  VisilabsPopupDialogOverlayView.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import UIKit
// import DynamicBlurView

/// The (blurred) overlay view below the popup dialog
final public class VisilabsPopupDialogOverlayView: UIView {

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


class VisilabsBlurView: UIView {

    var blurPresentDuration: TimeInterval = 0.5
    var blurPresentDelay: TimeInterval = 0

    var colorPresentDuration: TimeInterval = 0.25
    var colorPresentDelay: TimeInterval = 0

    var blurTargetOpacity: CGFloat = 1
    var colorTargetOpacity: CGFloat = 1

    var overlayColor = UIColor.black {
        didSet { colorView.backgroundColor = overlayColor }
    }

    let blurringViewContainer = UIView()
    let blurringView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let colorView = UIView()

    convenience init() {

        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        blurringViewContainer.alpha = 0

        colorView.backgroundColor = overlayColor
        colorView.alpha = 0

        self.addSubview(blurringViewContainer)
        blurringViewContainer.addSubview(blurringView)
        self.addSubview(colorView)
    }

    @available (iOS, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        blurringViewContainer.frame = self.bounds
        blurringView.frame = blurringViewContainer.bounds
        colorView.frame = self.bounds
    }

    func present() {

        UIView.animate(withDuration: blurPresentDuration, delay: blurPresentDelay, options: .curveLinear, animations: { [weak self] in

            self?.blurringViewContainer.alpha = self!.blurTargetOpacity

            }, completion: nil)

        UIView.animate(withDuration: colorPresentDuration, delay: colorPresentDelay, options: .curveLinear, animations: { [weak self] in

            self?.colorView.alpha = self!.colorTargetOpacity

            }, completion: nil)
    }

}
