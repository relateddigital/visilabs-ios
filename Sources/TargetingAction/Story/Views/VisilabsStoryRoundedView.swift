//
//  VisilabsStoryRoundedView.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import UIKit

// @note:Recommended Size: CGSize(width:70,height:70)
struct Attributes {
    let borderWidth: CGFloat = 0.0 // 2.0
    let borderColor = UIColor.clear// UIColor.white
    let backgroundColor = UIColor.clear // UIColor.red // IGTheme.redOrange
    let size = CGSize(width: 68, height: 68)
    var borderRadius: Double = 0.0
}

class VisilabsStoryRoundedView: UIView {
    private var attributes: Attributes = Attributes()
    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.borderWidth = (attributes.borderWidth)
        imgView.layer.borderColor = attributes.borderColor.cgColor
        imgView.clipsToBounds = true
        return imgView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = attributes.backgroundColor
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
        backgroundColor = attributes.backgroundColor
        addSubview(imageView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height * CGFloat(attributes.borderRadius)
        imageView.frame = CGRect(x: 1, y: 1, width: (attributes.size.width)-2, height: attributes.size.height-2)
        imageView.layer.cornerRadius = imageView.frame.height * CGFloat(attributes.borderRadius)
    }
}

extension VisilabsStoryRoundedView {
    func setBorder(borderColor: UIColor, borderWidth: Int, borderRadius: Double) {
        attributes.borderRadius = borderRadius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = CGFloat(borderWidth)
        layer.cornerRadius = frame.height * CGFloat(borderRadius)
        imageView.layer.cornerRadius = imageView.frame.height * CGFloat(borderRadius)
    }
}
