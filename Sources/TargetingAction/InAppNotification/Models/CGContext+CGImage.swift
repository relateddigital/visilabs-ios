//
//  CGContext+CGImage.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import UIKit

extension CGContext {
    static func imageContext(rect: CGRect, opaque: Bool) -> CGContext? {
        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, 1)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        context.translateBy(x: -rect.origin.x, y: -rect.origin.y)
        context.interpolationQuality = .default

        return context
    }

    func makeImage(with blendColor: UIColor?, blendMode: CGBlendMode, size: CGSize) -> CGImage? {
        if let color = blendColor {
            setFillColor(color.cgColor)
            setBlendMode(blendMode)
            fill(CGRect(origin: .zero, size: size))
        }

        return makeImage()
    }
}
