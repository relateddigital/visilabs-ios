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


extension UIBezierPath {

    ///the orientation of this triangle is "pointing" to the right.
    static func equilateralTriangle(_ sideSize: CGFloat, shiftBy shift: CGPoint = CGPoint.zero) -> UIBezierPath {

        let path = UIBezierPath()

        ///The formula for calculating the altitude which is the shortest inner distance between the tip and the opposing edge in an equilateral triangle.
        let altitude = CGFloat(sqrt(3.0) / 2.0 * sideSize)
        path.move(to: CGPoint(x: 0 + shift.x, y: 0 + shift.y))
        path.addLine(to: CGPoint(x: 0 + shift.x, y: sideSize + shift.y))
        path.addLine(to: CGPoint(x: altitude + shift.x, y: (sideSize / 2) + shift.y))
        path.close()

        return path
    }
}

extension CAShapeLayer {

    static func replayShape(_ fillColor: UIColor, triangleEdgeLength: CGFloat) -> CAShapeLayer {

        let triangle = CAShapeLayer()
        let altitude = (sqrt(3) / 2) * triangleEdgeLength
        triangle.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: altitude, height: triangleEdgeLength))
        triangle.path = UIBezierPath.equilateralTriangle(triangleEdgeLength).cgPath
        triangle.fillColor = fillColor.cgColor

        return triangle
    }

    static func playShape(_ fillColor: UIColor, triangleEdgeLength: CGFloat) -> CAShapeLayer {

        let triangle = CAShapeLayer()
        let altitude = (sqrt(3) / 2) * triangleEdgeLength
        triangle.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: altitude, height: triangleEdgeLength))
        triangle.path = UIBezierPath.equilateralTriangle(triangleEdgeLength).cgPath
        triangle.fillColor = fillColor.cgColor

        return triangle
    }

    static func pauseShape(_ fillColor: UIColor, elementSize: CGSize, elementDistance: CGFloat) -> CAShapeLayer {

        let element = CALayer()
        element.bounds.size = elementSize
        element.frame.origin = CGPoint.zero

        let secondElement = CALayer()
        secondElement.bounds.size = elementSize
        secondElement.frame.origin = CGPoint(x: elementSize.width + elementDistance, y: 0)

        [element, secondElement].forEach { $0.backgroundColor = fillColor.cgColor }

        let container = CAShapeLayer()
        container.bounds.size = CGSize(width: 2 * elementSize.width + elementDistance, height: elementSize.height)
        container.frame.origin = CGPoint.zero

        container.addSublayer(element)
        container.addSublayer(secondElement)

        return container
    }

    static func circle(_ fillColor: UIColor, diameter: CGFloat) -> CAShapeLayer {

        let circle = CAShapeLayer()
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter * 2, height: diameter * 2))
        circle.frame = frame
        circle.path = UIBezierPath(ovalIn: frame).cgPath
        circle.fillColor = fillColor.cgColor

        return circle
    }

    static func circlePlayShape(_ fillColor: UIColor, diameter: CGFloat) -> CAShapeLayer {

        let circle = CAShapeLayer()
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter))
        circle.frame = frame
        let circlePath   = UIBezierPath(ovalIn: frame)
        let trianglePath = UIBezierPath.equilateralTriangle(diameter / 2, shiftBy: CGPoint(x: diameter / 3, y: diameter / 4))

        circlePath.append(trianglePath)
        circle.path = circlePath.cgPath
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

    static func circlePlayButton(_ diameter: CGFloat) -> UIButton {

        let button = UIButton(type: .custom)
        button.frame = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))

        let circleImageNormal = CAShapeLayer.circlePlayShape(UIColor.white, diameter: diameter).toImage()
        button.setImage(circleImageNormal, for: .normal)

        let circleImageHighlighted = CAShapeLayer.circlePlayShape(UIColor.lightGray, diameter: diameter).toImage()
        button.setImage(circleImageHighlighted, for: .highlighted)

        return button
    }

    static func replayButton(width: CGFloat, height: CGFloat) -> UIButton {

        let smallerEdge = min(width, height)
        let triangleEdgeLength: CGFloat = min(smallerEdge, 20)

        let button = UIButton(type: .custom)
        button.bounds.size = CGSize(width: width, height: height)
        button.contentHorizontalAlignment = .center

        let playShapeNormal = CAShapeLayer.playShape(UIColor.red, triangleEdgeLength: triangleEdgeLength).toImage()
        button.setImage(playShapeNormal, for: .normal)

        let playShapeHighlighted = CAShapeLayer.playShape(UIColor.red.withAlphaComponent(0.7), triangleEdgeLength: triangleEdgeLength).toImage()
        button.setImage(playShapeHighlighted, for: .highlighted)

        ///the geometric center of equilateral triangle is not the same as the geometric center of its smallest bounding rect. There is some offset between the two centers to the left when the triangle points to the right. We have to shift the triangle to the right by that offset.
        let altitude = (sqrt(3) / 2) * triangleEdgeLength
        let innerCircleDiameter = (sqrt(3) / 6) * triangleEdgeLength

        button.imageEdgeInsets.left = altitude / 2 - innerCircleDiameter

        return button
    }

    static func playButton(width: CGFloat, height: CGFloat) -> UIButton {

        let smallerEdge = min(width, height)
        let triangleEdgeLength: CGFloat = min(smallerEdge, 20)

        let button = UIButton(type: .custom)
        button.bounds.size = CGSize(width: width, height: height)
        button.contentHorizontalAlignment = .center

        let playShapeNormal = CAShapeLayer.playShape(UIColor.white, triangleEdgeLength: triangleEdgeLength).toImage()
        button.setImage(playShapeNormal, for: .normal)

        let playShapeHighlighted = CAShapeLayer.playShape(UIColor.white.withAlphaComponent(0.7), triangleEdgeLength: triangleEdgeLength).toImage()
        button.setImage(playShapeHighlighted, for: .highlighted)

        ///the geometric center of equilateral triangle is not the same as the geometric center of its smallest bounding rect. There is some offset between the two centers to the left when the triangle points to the right. We have to shift the triangle to the right by that offset.
        let altitude = (sqrt(3) / 2) * triangleEdgeLength
        let innerCircleDiameter = (sqrt(3) / 6) * triangleEdgeLength

        button.imageEdgeInsets.left = altitude / 2 - innerCircleDiameter

        return button
    }

    static func pauseButton(width: CGFloat, height: CGFloat) -> UIButton {

        let button = UIButton(type: .custom)
        button.contentHorizontalAlignment = .center

        let elementHeight = min(20, height)
        let elementSize = CGSize(width: elementHeight * 0.3, height: elementHeight)
        let distance: CGFloat = elementHeight * 0.2

        let pauseImageNormal = CAShapeLayer.pauseShape(UIColor.white, elementSize: elementSize, elementDistance: distance).toImage()
        button.setImage(pauseImageNormal, for: .normal)

        let pauseImageHighlighted = CAShapeLayer.pauseShape(UIColor.white.withAlphaComponent(0.7), elementSize: elementSize, elementDistance: distance).toImage()
        button.setImage(pauseImageHighlighted, for: .highlighted)

        return button
    }

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



//TODO: GEREKSİZ SİL

import AVFoundation

extension AVPlayer {

    func isPlaying() -> Bool {

        return (self.rate != 0.0 && self.status == .readyToPlay)
    }
}


open class VideoScrubber: UIControl {

    let playButton = UIButton.playButton(width: 50, height: 40)
    let pauseButton = UIButton.pauseButton(width: 50, height: 40)
    let replayButton = UIButton.replayButton(width: 50, height: 40)

    let scrubber = Slider.createSlider(320, height: 20, pointerDiameter: 10, barHeight: 2)
    let timeLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 20)))
    var duration: TimeInterval?
    fileprivate var periodicObserver: AnyObject?
    fileprivate var stoppedSlidingTimeStamp = Date()
    
    /// The attributes dictionary used for the timeLabel
    fileprivate var timeLabelAttributes:  [NSAttributedString.Key : Any] {
        var attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]
        
        if let tintColor = tintColor {
            attributes[NSAttributedString.Key.foregroundColor] = tintColor
        }
        
        return attributes
    }

    weak var player: AVPlayer? {

        willSet {
            if let player = player {
                
                ///KVO
                player.removeObserver(self, forKeyPath: "status")
                player.removeObserver(self, forKeyPath: "rate")
                
                ///NC
                NotificationCenter.default.removeObserver(self)
                
                ///TIMER
                if let periodicObserver = self.periodicObserver {
                    
                    player.removeTimeObserver(periodicObserver)
                    self.periodicObserver = nil
                }
            }
        }

        didSet {

            if let player = player {

                ///KVO
                player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
                player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)

                ///NC
                NotificationCenter.default.addObserver(self, selector: #selector(didEndPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

                ///TIMER
                periodicObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: nil, using: { [weak self] time in
                    self?.update()
                }) as AnyObject?

                self.update()
            }
        }
    }

    override init(frame: CGRect) {

        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        setup()
    }

    deinit {

        player?.removeObserver(self, forKeyPath: "status")
        player?.removeObserver(self, forKeyPath: "rate")
        scrubber.removeObserver(self, forKeyPath: "isSliding")

        if let periodicObserver = self.periodicObserver {

            player?.removeTimeObserver(periodicObserver)
            self.periodicObserver = nil
        }
    }

    @objc func didEndPlaying() {

        self.playButton.isHidden = true
        self.pauseButton.isHidden = true
        self.replayButton.isHidden = false
    }

    func setup() {

        self.tintColor = .white
        self.clipsToBounds = true
        pauseButton.isHidden = true
        replayButton.isHidden = true

        scrubber.minimumValue = 0
        scrubber.maximumValue = 1000
        scrubber.value = 0

        timeLabel.attributedText = NSAttributedString(string: "--:--", attributes: timeLabelAttributes)
        timeLabel.textAlignment =  .center

        playButton.addTarget(self, action: #selector(play), for: UIControl.Event.touchUpInside)
        pauseButton.addTarget(self, action: #selector(pause), for: UIControl.Event.touchUpInside)
        replayButton.addTarget(self, action: #selector(replay), for: UIControl.Event.touchUpInside)
        scrubber.addTarget(self, action: #selector(updateCurrentTime), for: UIControl.Event.valueChanged)
        scrubber.addTarget(self, action: #selector(seekToTime), for: [UIControl.Event.touchUpInside, UIControl.Event.touchUpOutside])

        self.addSubviews(playButton, pauseButton, replayButton, scrubber, timeLabel)

        scrubber.addObserver(self, forKeyPath: "isSliding", options: NSKeyValueObservingOptions.new, context: nil)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        playButton.center = self.boundsCenter
        playButton.frame.origin.x = 0
        pauseButton.frame = playButton.frame
        replayButton.frame = playButton.frame

        timeLabel.center = self.boundsCenter
        timeLabel.frame.origin.x = self.bounds.maxX - timeLabel.bounds.width

        scrubber.bounds.size.width = self.bounds.width - playButton.bounds.width - timeLabel.bounds.width
        scrubber.bounds.size.height = 20
        scrubber.center = self.boundsCenter
        scrubber.frame.origin.x = playButton.frame.maxX
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == "isSliding" {

            if scrubber.isSliding == false {

                stoppedSlidingTimeStamp = Date()
            }
        }

        else if keyPath == "rate" || keyPath == "status" {

            self.update()
        }
    }

    @objc func play() {

        self.player?.play()
    }

    @objc func replay() {

        self.player?.seek(to: CMTime(value:0 , timescale: 1))
        self.player?.play()
    }

    @objc func pause() {

        self.player?.pause()
    }

    @objc func seekToTime() {

        let progress = scrubber.value / scrubber.maximumValue //naturally will be between 0 to 1

        if let player = self.player, let currentItem =  player.currentItem {

            let time = currentItem.duration.seconds * Double(progress)
            player.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        }
    }

    func update() {

        updateButtons()
        updateDuration()
        updateScrubber()
        updateCurrentTime()
    }

    func updateButtons() {

        if let player = self.player {

            self.playButton.isHidden = player.isPlaying()
            self.pauseButton.isHidden = !self.playButton.isHidden
            self.replayButton.isHidden = true
        }
    }

    func updateDuration() {

        if let duration = self.player?.currentItem?.duration {

            self.duration = (duration.isNumeric) ? duration.seconds : nil
        }
    }

    func updateScrubber() {

        guard scrubber.isSliding == false else { return }

        let timeElapsed = Date().timeIntervalSince( stoppedSlidingTimeStamp)
        guard timeElapsed > 1 else {
            return
        }

        if let player = self.player, let duration = self.duration {

            let progress = player.currentTime().seconds / duration

            UIView.animate(withDuration: 0.9, animations: { [weak self] in

                if let strongSelf = self {

                    strongSelf.scrubber.value = Float(progress) * strongSelf.scrubber.maximumValue
                }
            })
        }
    }

    @objc func updateCurrentTime() {

        if let duration = self.duration , self.duration != nil {

            let sliderProgress = scrubber.value / scrubber.maximumValue
            let currentTime = Double(sliderProgress) * duration

            let timeString = stringFromTimeInterval(currentTime as TimeInterval)

            timeLabel.attributedText = NSAttributedString(string: timeString, attributes: timeLabelAttributes)
        }
        else {
            timeLabel.attributedText = NSAttributedString(string: "--:--", attributes: timeLabelAttributes)
        }
    }

    func stringFromTimeInterval(_ interval:TimeInterval) -> String {

        let timeInterval = NSInteger(interval)

        let seconds = timeInterval % 60
        let minutes = (timeInterval / 60) % 60
        //let hours = (timeInterval / 3600)

        return NSString(format: "%0.2d:%0.2d",minutes,seconds) as String
        //return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds) as String
    }
    
    override open func tintColorDidChange() {
        timeLabel.attributedText = NSAttributedString(string: "--:--", attributes: timeLabelAttributes)
        
        let playButtonImage = playButton.imageView?.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        playButton.imageView?.tintColor = self.tintColor
        playButton.setImage(playButtonImage, for: .normal)
        
        if let playButtonImage = playButtonImage,
            let highlightImage = self.image(playButtonImage, with: self.tintColor.shadeDarker()) as UIImage? {
            playButton.setImage(highlightImage, for: .highlighted)
        }
        
        let pauseButtonImage = pauseButton.imageView?.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        pauseButton.imageView?.tintColor = self.tintColor
        pauseButton.setImage(pauseButtonImage, for: .normal)
        
        if let pauseButtonImage = pauseButtonImage,
            let highlightImage = self.image(pauseButtonImage, with: self.tintColor.shadeDarker()) as UIImage? {
            pauseButton.setImage(highlightImage, for: .highlighted)
        }
        
        let replayButtonImage = replayButton.imageView?.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        replayButton.imageView?.tintColor = self.tintColor
        replayButton.setImage(replayButtonImage, for: .normal)
        
        if let replayButtonImage = replayButtonImage,
            let highlightImage = self.image(replayButtonImage, with: self.tintColor.shadeDarker()) as UIImage? {
            replayButton.setImage(highlightImage, for: .highlighted)
        }
    }
    
    func image(_ image: UIImage, with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.clip(to: rect, mask: image.cgImage!)
        context?.fill(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let fillImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return fillImage
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
        imageView.contentMode = self.contentMode

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

    func presentImageGallery(_ gallery: VisilabsCarouselNotificationViewController, completion: (() -> Void)? = {}) {

        present(gallery, animated: false, completion: completion)
    }
}
