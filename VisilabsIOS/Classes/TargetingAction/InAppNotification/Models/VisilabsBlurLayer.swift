//
//  VisilabsBlurLayer.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import UIKit

private extension CGRect {
    func rectangle(_ size: CGSize) -> CGRect {
        let xPoint = origin.x / size.width
        let yPoint = origin.y / size.height
        let width = size.width / size.width
        let height = size.height / size.height
        return CGRect(x: xPoint, y: yPoint, width: width, height: height)
    }
}

class VisilabsBlurLayer: CALayer {
    private static let blurRadiusKey = "blurRadius"
    private static let blurLayoutKey = "blurLayout"
    @NSManaged var blurRadius: CGFloat
    @NSManaged private var blurLayout: CGFloat

    private var fromBlurRadius: CGFloat?
    var presentationRadius: CGFloat {
        if let radius = fromBlurRadius {
            if let layer = presentation() {
                return layer.blurRadius
            } else {
                return radius
            }
        } else {
            return blurRadius
        }
    }

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == blurRadiusKey || key == blurLayoutKey {
            return true
        }
        return super.needsDisplay(forKey: key)
    }

    open override func action(forKey event: String) -> CAAction? {
        if event == VisilabsBlurLayer.blurRadiusKey {
            fromBlurRadius = nil

            if let action = super.action(forKey: "opacity") as? CABasicAnimation {
                fromBlurRadius = (presentation() ?? self).blurRadius

                action.keyPath = event
                action.fromValue = fromBlurRadius
                return action
            }
        }

        if event == VisilabsBlurLayer.blurLayoutKey, let action = super.action(forKey: "opacity") as? CABasicAnimation {
            action.keyPath = event
            action.fromValue = 0
            action.toValue = 1
            return action
        }

        return super.action(forKey: event)
    }
}

extension VisilabsBlurLayer {
    func draw(_ image: UIImage, fixes isFixes: Bool, baseLayer: CALayer?) {
        contents = image.cgImage
        contentsScale = image.scale

        if isFixes, let blurLayer = presentation() {
            contentsRect = blurLayer.convert(blurLayer.bounds, to: baseLayer).rectangle(image.size)
        }
    }

    func refresh() {
        fromBlurRadius = nil
    }

    func animate() {
        UIView.performWithoutAnimation {
            blurLayout = 0
        }
        blurLayout = 1
    }

    func render(in context: CGContext, for layer: CALayer) {
        let layers = hideOverlappingLayers(layer.sublayers)
        layer.render(in: context)
        layers.forEach {
            $0.isHidden = false
        }
    }

    private func hideOverlappingLayers(_ layers: [CALayer]?) -> [CALayer] {
        var hiddenLayers: [CALayer] = []
        guard let layers = layers else {
            return hiddenLayers
        }

        for layer in layers.reversed() {
            if isHang(to: layer) {
                return hiddenLayers + hideOverlappingLayers(layer.sublayers)
            }
            if layer.isHidden == false {
                layer.isHidden = true
                hiddenLayers.append(layer)
            }
            if layer == self {
                return hiddenLayers
            }
        }
        return hiddenLayers
    }

    private func isHang(to target: CALayer) -> Bool {
        var layer = superlayer
        while layer != nil {
            if layer == target {
                return true
            }
            layer = layer?.superlayer
        }
        return false
    }
}
