//
//  VisilabsNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.04.2020.
//

import Foundation

class VisilabsCircleLayer: CALayer {
    var circlePadding: CGFloat = 0.0
    
    static func layer() -> VisilabsCircleLayer? {
        let cl = super.init() as? VisilabsCircleLayer
        cl?.circlePadding = 2.5
        return cl
    }
    
    override func draw(in ctx: CGContext?) {
        let edge: CGFloat = 1.5 //the distance from the edge so we don't get clipped.
        ctx?.setAllowsAntialiasing(true)
        ctx?.setShouldAntialias(true)

        let thePath = CGMutablePath()
        ctx?.setStrokeColor(UIColor.white.cgColor)
        thePath.addArc(center: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: min(frame.size.width, frame.size.height) / 2.0 - (2 * edge), startAngle: CGFloat(Float(-Float.pi)), endAngle: CGFloat(Float(Float.pi)), clockwise: true, transform: .identity)

        ctx?.beginPath()
        ctx?.addPath(thePath)

        ctx?.setLineWidth(1.5)
        ctx?.strokePath()
    }
}


class VisilabsElasticEaseOutAnimation: CAKeyframeAnimation {
    init(startValue start: CGRect, endValue end: CGRect, andDuration duration: Double) {
        super.init()
        self.duration = duration
        values = generateValues(from: start, to: end)
    }

    func generateValues(from start: CGRect, to end: CGRect) -> [AnyHashable]? {
        let steps = Int(ceil(60 * duration)) + 2
        var valueArray = [AnyHashable](repeating: 0, count: steps)
        let increment = 1.0 / Double(steps - 1)
        var t = 0.0
        let range = CGRect(x: end.origin.x - start.origin.x, y: end.origin.y - start.origin.y, width: end.size.width - start.size.width, height: end.size.height - start.size.height)


        for _ in 0..<steps {
            let v = Float(-(pow(M_E, -8 * t) * cos(12 * t))) + 1 // Cosine wave with exponential decay

            let value = CGRect(x: start.origin.x + CGFloat(v) * range.origin.x, y: start.origin.y + CGFloat(v) * range.origin.y, width: start.size.width + CGFloat(v) * range.size.width, height: start.size.height + CGFloat(v) * range.size.height)

            valueArray.append(NSValue(cgRect: value))
            t += increment
        }

        return valueArray
    }
    
    
    //TODO: buna gerek var mı?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class VisilabsGradientMaskLayer: CAGradientLayer {
    override func draw(in ctx: CGContext?) {

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let components: [CGFloat] = [1.0, 1.0, 1.0, 1.0, 1.0, 0.9, 1.0, 0.0]

        let locations: [CGFloat] = [0.0, 0.7, 0.8, 1.0]

        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 7)
        ctx?.drawLinearGradient(gradient!, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 5.0, y: bounds.size.height), options: CGGradientDrawingOptions(rawValue: 0))


        let bits = Int(abs(bounds.size.width)) * Int(abs(bounds.size.height))
        
        //TODO: BURADA KALDIM
        /*
        let rgba = UnsafePointer<Int8>(Int8(malloc(bits)))
        srand(124)

        for i in 0..<bits {
            rgba[i] = arc4random() % 8
        }

        let noise = CGContext(data: rgba, width: Int(fabs(bounds.size.width)), height: Int(fabs(bounds.size.height)), bitsPerComponent: 8, bytesPerRow: Int(fabs(bounds.size.width)), space: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.alphaOnly.rawValue))
        let image = noise?.makeImage()

        if let ctx = ctx {
            ctx.setBlendMode(.sourceOut)
        }
        ctx?.draw(in: image, image: bounds)

        CGImageRelease(image)
        CGContextRelease(noise)
        free(rgba)
 */
    }

    
}

class VisilabsAlphaMaskView: UIView {
    var maskLayer: CAGradientLayer?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
            maskLayer = VisilabsGradientMaskLayer()
            layer.mask = maskLayer
            isOpaque = false
            maskLayer?.isOpaque = false
            maskLayer?.needsDisplayOnBoundsChange = true
            maskLayer?.setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer?.frame = bounds
    }
}

class VisilabsBgRadialGradientView: UIView {
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let circleSize = CGSize(width: center.y * 2.0, height: center.y * 2.0)
        let circleFrame = CGRect(x: center.x - center.y, y: 0.0, width: circleSize.width, height: circleSize.height)

        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()

        let colorRef = UIColor(red: 24.0 / 255.0, green: 24.0 / 255.0, blue: 31.0 / 255.0, alpha: 0.94).cgColor
        ctx?.setFillColor(colorRef)
        ctx?.fill(bounds)

        if let ctx = ctx {
            ctx.setBlendMode(.copy)
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let comps : [CGFloat] = [96.0 / 255.0, 96.0 / 255.0, 124.0 / 255.0, 0.94, 72.0 / 255.0, 72.0 / 255.0, 93.0 / 255.0, 0.94, 24.0 / 255.0, 24.0 / 255.0, 31.0 / 255.0, 0.94, 24.0 / 255.0, 24.0 / 255.0, 31.0 / 255.0, 0.94]
        let locs : [CGFloat] = [0.0, 0.1, 0.75, 1.0]
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: comps, locations: locs, count: 4)

        ctx?.addEllipse(in: circleFrame)
        ctx?.clip()

        if let ctx = ctx, let gradient = gradient {
            ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: circleSize.width / 2.0, options: .drawsAfterEndLocation)
        }

        ctx?.restoreGState()
    }
}

class VisilabsActionButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
            layer.backgroundColor = UIColor(red: 43.0 / 255.0, green: 43.0 / 255.0, blue: 52.0 / 255.0, alpha: 1.0).cgColor
            layer.cornerRadius = 17.0
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 2.0
    }

    func setHighlighted(_ highlighted: Bool) {
        if highlighted {
            layer.borderColor = UIColor.gray.cgColor
        } else {
            layer.borderColor = UIColor.white.cgColor
        }
        super.isHighlighted = highlighted
    }
}



class VisilabsNotificationViewController: UIViewController {
    var notification: VisilabsNotification?
    weak var delegate: VisilabsNotificationViewControllerDelegate?

    func hide(withAnimation animated: Bool, completion: @escaping () -> Void) {
        return
    }
}



class VisilabsFullNotificationViewController: VisilabsNotificationViewController {
    private var viewStart = CGPoint.zero
    private var touching = false
    var backgroundImage: UIImage?
}

class VisilabsMiniNotificationViewController: VisilabsNotificationViewController {
    var backgroundColor: UIColor?

    func showWithAnimation() {
    }
}

protocol VisilabsNotificationViewControllerDelegate: NSObjectProtocol {
    func notificationController(_ controller: VisilabsNotificationViewController?, wasDismissedWithStatus status: Bool)
}
