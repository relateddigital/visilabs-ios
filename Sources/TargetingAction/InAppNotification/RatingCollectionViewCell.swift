//
//  RatingCollectionViewCell.swift
//  VisilabsIOS
//
//  Created by Said Alır on 15.01.2021.
//

import UIKit

class RatingCollectionViewCell: UICollectionViewCell {

    let ratingLabel: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    var rating: Int = 0 {
        didSet {
            self.ratingLabel.text = "\(rating)"
        }
    }
    var borderColor: UIColor = .white

    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.contentView.layer.borderColor = borderColor.cgColor
                self.contentView.layer.borderWidth = 1.8
            } else {
                self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.contentView.layer.borderWidth = 0.0
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(ratingLabel)
        ratingLabel.allEdges(to: contentView)
        contentView.layer.roundCorners(radius: contentView.frame.width / 2)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setGradient(colors: [CGColor]) {
        DispatchQueue.main.async {
            self.contentView.addGradientBackground(colors: colors)
        }
    }

    func setBackgroundColor(_ color: UIColor) {
        DispatchQueue.main.async {
            self.contentView.backgroundColor = color
        }
    }

}

extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }

    func addGradientBackground(colors: [CGColor]) {
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.name = "gradient"
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }

    static func getGradientColorArray(_ color1: UIColor, _ color2: UIColor) -> [[CGColor]] {

        var colors: [[CGColor]] = []
        var oldColor = color1

        let c1R = color1.rgba.red * 255
        let c1G = color1.rgba.green * 255
        let c1B = color1.rgba.blue * 255

        let c2R = color2.rgba.red * 255
        let c2G = color2.rgba.green * 255
        let c2B = color2.rgba.blue * 255

        let newR = c1R + ((c2R - c1R) / 10)
        let newG = c1G + ((c2G - c1G) / 10)
        let newB = c1B + ((c2B - c1B) / 10)

        let newColor = UIColor(red: newR/255, green: newG/255, blue: newB/255, alpha: 1.0)

        colors.append([oldColor.cgColor, newColor.cgColor])

        for i in 0 ..< 8 {

            let newR = c1R + ((c2R - c1R) / 10) * CGFloat(i+1)
            let newG = c1G + ((c2G - c1G) / 10) * CGFloat(i+1)
            let newB = c1B + ((c2B - c1B) / 10) * CGFloat(i+1)

            let newColor = UIColor(red: newR/255, green: newG/255, blue: newB/255, alpha: 1.0)

            colors.append([oldColor.cgColor, newColor.cgColor])

            oldColor = newColor
        }

        colors.append([oldColor.cgColor, color2.cgColor])

        return colors
    }

    static func getGradientColorArray(_ color1: UIColor, _ color2: UIColor, _ color3: UIColor) -> [[CGColor]] {

        var colors: [[CGColor]] = []
        var oldColor = color1

        let c1R = color1.rgba.red * 255
        let c1G = color1.rgba.green * 255
        let c1B = color1.rgba.blue * 255

        let c2R = color2.rgba.red * 255
        let c2G = color2.rgba.green * 255
        let c2B = color2.rgba.blue * 255

        let c3R = color3.rgba.red * 255
        let c3G = color3.rgba.green * 255
        let c3B = color3.rgba.blue * 255

        for i in 0 ..< 4 {

            let newR = c1R + ((c2R - c1R) / 5) * CGFloat(i+1)
            let newG = c1G + ((c2G - c1G) / 5) * CGFloat(i+1)
            let newB = c1B + ((c2B - c1B) / 5) * CGFloat(i+1)

            let newColor = UIColor(red: newR/255, green: newG/255, blue: newB/255, alpha: 1.0)

            colors.append([oldColor.cgColor, newColor.cgColor])
            oldColor = newColor
        }

        colors.append([oldColor.cgColor, color2.cgColor])

        for i in 0 ..< 4 {

            let newR = c2R + ((c3R - c2R) / 5) * CGFloat(i+1)
            let newG = c2G + ((c3G - c2G) / 5) * CGFloat(i+1)
            let newB = c2B + ((c3B - c2B) / 5) * CGFloat(i+1)

            let newColor = UIColor(red: newR/255, green: newG/255, blue: newB/255, alpha: 1.0)

            colors.append([oldColor.cgColor, newColor.cgColor])

            oldColor = newColor
        }

        colors.append([oldColor.cgColor, color3.cgColor])

        return colors
    }
}

extension CALayer {

    func roundCorners(radius: CGFloat) {
        self.cornerRadius = radius
        if shadowOpacity != 0 {
            addShadowWithRoundedCorners()
        }
    }

    private func addShadowWithRoundedCorners() {
        if let contents = self.contents {
            masksToBounds = false
            sublayers?.filter { $0.frame.equalTo(self.bounds) }
                .forEach { $0.roundCorners(radius: self.cornerRadius) }
            self.contents = nil
            if let sublayer = sublayers?.first, sublayer.name == "said" {
                sublayer.removeFromSuperlayer()
            }
            let contentLayer = CALayer()
            contentLayer.name = "said"
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            insertSublayer(contentLayer, at: 0)
        }
    }
}
