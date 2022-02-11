//
//  VisilabsCarouselExtensions.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 8.02.2022.
//

import UIKit

extension UIApplication {

    static var applicationWindow: UIWindow {
        return UIApplication.shared.keyWindow!
    }

    static var isPortraitOnly: Bool {
        let orientations = UIApplication.shared.supportedInterfaceOrientations(for: nil)
        return !(orientations.contains(.landscapeLeft) || orientations.contains(.landscapeRight) || orientations.contains(.landscape))
    }
}

extension UIView {

    public var boundsCenter: CGPoint {

        return CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
    }

    func frame(inCoordinatesOfView parentView: UIView) -> CGRect {

        let frameInWindow = UIApplication.applicationWindow.convert(self.bounds, from: self)
        return parentView.convert(frameInWindow, from: UIApplication.applicationWindow)
    }

    func addSubviews(_ subviews: UIView...) {

        for view in subviews { self.addSubview(view) }
    }

    static func animateWithDuration(_ duration: TimeInterval, delay: TimeInterval, animations: @escaping () -> Void) {

        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions(), animations: animations, completion: nil)
    }

    static func animateWithDuration(_ duration: TimeInterval, delay: TimeInterval, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {

        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions(), animations: animations, completion: completion)
    }
}

extension UIColor {
    
    open func shadeDarker() -> UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let variance: CGFloat = 0.4
        let newR = CGFloat.maximum(r * variance, 0.0),
        newG = CGFloat.maximum(g * variance, 0.0),
        newB = CGFloat.maximum(b * variance, 0.0)
        
        return UIColor(red: newR, green: newG, blue: newB, alpha: 1.0)
    }
    
}

extension CALayer {

    func toImage() -> UIImage {

        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        self.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}


extension CAShapeLayer {

    static func circle(_ fillColor: UIColor, diameter: CGFloat) -> CAShapeLayer {
        let circle = CAShapeLayer()
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter * 2, height: diameter * 2))
        circle.frame = frame
        circle.path = UIBezierPath(ovalIn: frame).cgPath
        circle.fillColor = fillColor.cgColor
        return circle
    }

    static func closeShape(edgeLength: CGFloat) -> CAShapeLayer {

        let container = CAShapeLayer()
        container.bounds.size = CGSize(width: edgeLength + 4, height: edgeLength + 4)
        container.frame.origin = CGPoint.zero

        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: edgeLength, y: edgeLength))
        linePath.move(to: CGPoint(x: 0, y: edgeLength))
        linePath.addLine(to: CGPoint(x: edgeLength, y: 0))

        let elementBorder = CAShapeLayer()
        elementBorder.bounds.size = CGSize(width: edgeLength, height: edgeLength)
        elementBorder.position = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
        elementBorder.lineCap = CAShapeLayerLineCap.round
        elementBorder.path = linePath.cgPath
        elementBorder.strokeColor = UIColor.darkGray.cgColor
        elementBorder.lineWidth = 2.5

        let elementFill = CAShapeLayer()
        elementFill.bounds.size = CGSize(width: edgeLength, height: edgeLength)
        elementFill.position = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
        elementFill.lineCap = CAShapeLayerLineCap.round
        elementFill.path = linePath.cgPath
        elementFill.strokeColor = UIColor.white.cgColor
        elementFill.lineWidth = 2

        container.addSublayer(elementBorder)
        container.addSublayer(elementFill)

        return container
    }
}


extension UIButton {

    static func closeButton() -> UIButton {

        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        button.setImage(CAShapeLayer.closeShape(edgeLength: 15).toImage(), for: .normal)

        return button
    }

    static func thumbnailsButton() -> UIButton {

        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 50)))
        button.setTitle("See All", for: .normal)
        //button.titleLabel?.textColor = UIColor.redColor()

        return button
    }

    static func deleteButton() -> UIButton {

        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 50)))
        button.setTitle("Delete", for: .normal)

        return button
    }
}

//TODO: BAK TEKRAR
class Slider: UISlider {

    @objc dynamic var isSliding: Bool = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        isSliding = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        isSliding = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        isSliding = false
    }
}

extension Slider {

    static func createSlider(_ width: CGFloat, height: CGFloat, pointerDiameter: CGFloat, barHeight: CGFloat) -> Slider {

        let slider = Slider(frame: CGRect(x: 0, y: 0, width: width, height: height))

        slider.setThumbImage(CAShapeLayer.circle(UIColor.white, diameter: pointerDiameter).toImage(), for: UIControl.State())

        let tileImageFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: barHeight))

        let minTrackImage = CALayer()
        minTrackImage.backgroundColor = UIColor.white.cgColor
        minTrackImage.frame = tileImageFrame

        let maxTrackImage = CALayer()
        maxTrackImage.backgroundColor = UIColor.darkGray.cgColor
        maxTrackImage.frame = tileImageFrame

        slider.setMinimumTrackImage(minTrackImage.toImage(), for: UIControl.State())
        slider.setMaximumTrackImage(maxTrackImage.toImage(), for: UIControl.State())

        return slider
    }
    
    override func tintColorDidChange() {
        self.minimumTrackTintColor = self.tintColor
        self.maximumTrackTintColor = self.tintColor.shadeDarker()
        
        // Correct way would be setting self.thumbTintColor however this has a bug which changes the thumbImage frame
        let image = self.currentThumbImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.setThumbImage(image, for: UIControl.State.normal)
    }
}

import CoreGraphics

extension CGPoint {

    func inverted() -> CGPoint {

        return CGPoint(x: self.y, y: self.x)
    }
}

enum Direction {
    case left, right, up, down, none
}

enum Orientation {
    case vertical, horizontal, none
}

///Movement can be expressed as a vector in 2D coordinate space where the implied unit is 1 second and the vector point from 0,0 to an actual CGPoint value represents direction and speed. Then we can calculate convenient properties describing the nature of movement.
extension CGPoint {

    var direction: Direction {

        guard !(self.x == 0 && self.y == 0) else { return .none }

        if (abs(self.x) > abs(self.y) && self.x > 0) {

            return .right
        }
        else if (abs(self.x) > abs(self.y) && self.x <= 0) {

            return .left
        }

        else if (abs(self.x) <= abs(self.y) && self.y > 0) {

            return .up
        }

        else if (abs(self.x) <= abs(self.y) && self.y <= 0) {

            return .down
        }

        else {

            return .none
        }
    }

    var orientation: Orientation {

        guard self.direction != .none else { return .none }

        if self.direction == .left || self.direction == .right {
            return .horizontal
        }
        else {
            return .vertical
        }
    }
}


extension CGSize {

    func inverted() -> CGSize {

        return CGSize(width: self.height, height: self.width)
    }
}


public extension UIScreen {
    class var hasNotch: Bool {
        // This will of course fail if Apple produces an notchless iPhone with these dimensions,
        // but is the simplest detection mechanism so far.
        return main.nativeBounds.size == CGSize(width: 1125, height: 2436)
    }
}

extension DisplaceableView {

    func imageView() -> UIImageView {

        let imageView = UIImageView(image: self.image)
        imageView.bounds = self.bounds
        imageView.center = self.center
        //TODO: egemen
        //imageView.contentMode = self.contentMode

        return imageView
    }
}

extension DisplaceableView {
    func frameInCoordinatesOfScreen() -> CGRect {
        return UIView().convert(self.bounds, to: UIScreen.main.coordinateSpace)
    }
}


extension Bool {

    mutating func flip() {

        self = !self
    }
}

public extension UIViewController {
    func presentCarouselNotification(_ gallery: VisilabsCarouselNotificationViewController, completion: (() -> Void)? = {}) {
        present(gallery, animated: false, completion: completion)
    }
}
