//
//  VisilabsDynamicBlurView.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import UIKit
import QuartzCore
import CoreGraphics

extension CGRect {
    func rectangle(_ s: CGSize) -> CGRect {
        CGRect(
            x: origin.x / s.width,
            y: origin.y / s.height,
            width: size.width / s.width,
            height: size.height / s.height
        )
    }
}

extension CALayer {
    func convertRect(to layer: CALayer?) -> CGRect {
        convert(bounds, to: layer)
    }
}

open class VisilabsDynamicBlurView: UIView {
    open override class var layerClass: AnyClass {
        VisilabsBlurLayer.self
    }

    private var blurLayer: VisilabsBlurLayer {
        layer as! VisilabsBlurLayer
    }

    private var staticImage: UIImage?
    private var displayLink: CADisplayLink? {
        didSet {
            oldValue?.invalidate()
        }
    }

    private var renderingTarget: UIView? {
        window != nil
            ? (isDeepRendering ? window : superview)
            : nil
    }

    private var relativeLayerRect: CGRect {
        blurLayer.current.convertRect(to: renderingTarget?.layer)
    }

    /// Radius of blur.
    open var blurRadius: CGFloat {
        get { blurLayer.blurRadius }
        set { blurLayer.blurRadius = newValue }
    }

    /// Default is none.
    open var trackingMode: VisilabsTrackingMode = .none {
        didSet {
            if trackingMode != oldValue {
                linkForDisplay()
            }
        }
    }

    /// Blend color.
    open var blendColor: UIColor?

    /// Blend mode.
    open var blendMode: CGBlendMode = .plusLighter

    /// Default is 3.
    open var iterations = 3

    /// If the view want to render beyond the layer, should be true.
    open var isDeepRendering = false

    /// When none of tracking mode, it can change the radius of blur with the ratio. Should set from 0 to 1.
    open var blurRatio: CGFloat = 1 {
        didSet {
            if oldValue != blurRatio, let blurredImage = staticImage.flatMap(imageBlurred) {
                blurLayer.draw(blurredImage)
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = false
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        if trackingMode == .none {
            renderingTarget?.layoutIfNeeded()
            staticImage = currentImage()
        }
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview == nil {
            displayLink = nil
        } else {
            linkForDisplay()
        }
    }

    func imageBlurred(_ image: UIImage) -> UIImage? {
        image.blurred(
            radius: blurLayer.currentBlurRadius,
            iterations: iterations,
            ratio: blurRatio,
            blendColor: blendColor,
            blendMode: blendMode
        )
    }

    func currentImage() -> UIImage? {
        renderingTarget.flatMap { view in
            blurLayer.snapshotImageBelowLayer(view.layer, in: isDeepRendering ? view.bounds : relativeLayerRect)
        }
    }
}

extension VisilabsDynamicBlurView {
    open override func display(_ layer: CALayer) {
        if let blurredImage = (staticImage ?? currentImage()).flatMap(imageBlurred) {
            blurLayer.draw(blurredImage)

            if isDeepRendering {
                blurLayer.contentsRect = relativeLayerRect.rectangle(blurredImage.size)
            }
        }
    }
}

extension VisilabsDynamicBlurView {
    private func linkForDisplay() {
        displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(VisilabsDynamicBlurView.displayDidRefresh(_:)))
        displayLink?.add(to: .main, forMode: RunLoop.Mode(rawValue: trackingMode.description))
    }

    @objc private func displayDidRefresh(_ displayLink: CADisplayLink) {
        display(layer)
    }
}

extension VisilabsDynamicBlurView {
    /// Remove cache of blur image then get it again.
    open func refresh() {
        blurLayer.refresh()
        staticImage = nil
        blurRatio = 1
        display(layer)
    }

    /// Remove cache of blur image.
    open func remove() {
        blurLayer.refresh()
        staticImage = nil
        blurRatio = 1
        layer.contents = nil
    }

    /// Should use when needs to change layout with animation when is set none of tracking mode.
    public func animate() {
        blurLayer.animate()
    }
}
