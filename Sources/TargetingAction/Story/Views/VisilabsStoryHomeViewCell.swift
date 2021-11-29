//
//  VisilabsStoryHomeViewCell.swift
//  VisilabsIOS
//
//  Created by Egemen on 22.09.2020.
//

import UIKit

class VisilabsStoryHomeViewCell: UICollectionViewCell {

    func setAsLoadingCell() {
        self.profileNameLabel.text = "Loading"
        self.profileImageView.imageView.image = VisilabsHelper.getUIImage(named: "loading")
    }

    func setProperties(_ properties: VisilabsStoryActionExtendedProperties, _ actId: Int) {
        self.profileNameLabel.textColor = properties.labelColor
        var shown = false
        // check story has shown
        if let shownStories = UserDefaults.standard.dictionary(forKey: VisilabsConstants.shownStories) as? [String: [String]] {
            if let shownStoriesWithAction = shownStories["\(actId)"], shownStoriesWithAction.contains(self.story?.title ?? "-") {
                shown = true
            }
        }

        let borderColor = shown ? UIColor.gray : properties.imageBorderColor

        self.profileImageView.setBorder(borderColor: borderColor,
                                        borderWidth: properties.imageBorderWidth,
                                        borderRadius: properties.imageBorderRadius)
        if properties.imageBoxShadow {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.5
            self.layer.shadowOffset = CGSize(width: 5, height: 5)
            self.layer.shadowRadius = 10
        }
    }
    
    func setStoryTitleLabelProperties(fontFamily: String?, fontSize: String?, style: UIFont.TextStyle,customFont:String? = "",labelColor:String?,labelStory:UILabel?) {
        
        var size = style == .title2 ? 12 : 8
        if let fSize = fontSize, let siz = Int(fSize), siz > 0 {
            size += siz
        }
        if let color = labelColor {
            labelStory?.textColor = UIColor(hex: color)
        } else {
            labelStory?.textColor = .black
        }
        var finalFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: style),
                               size: CGFloat(size))
        if let font = fontFamily {
            if #available(iOS 13.0, *) {
                var systemDesign: UIFontDescriptor.SystemDesign  = .default
                if font.lowercased() == "serif" || font.lowercased() == "sansserif" {
                    systemDesign = .serif
                } else if font.lowercased() == "monospace" {
                    systemDesign = .monospaced
                }
                if let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
                    .withDesign(systemDesign) {
                    finalFont = UIFont(descriptor: fontDescriptor, size: CGFloat(size))
                }
            } else {
                if font.lowercased() == "serif" || font.lowercased() == "sansserif" {
                    let fontName = style == .title2 ? "GillSans-Bold": "GillSans"
                    finalFont = UIFont(name: fontName, size: CGFloat(size))!
                } else if font.lowercased() == "monospace" {
                    let fontName = style == .title2 ? "CourierNewPS-BoldMT": "CourierNewPSMT"
                    finalFont = UIFont(name: fontName, size: CGFloat(size))!
                }
            }

            if let uiCustomFont = UIFont(name: customFont ?? "", size: CGFloat(size)) {
                labelStory?.font = uiCustomFont
                return
            }
       }
        labelStory?.font = finalFont
    }

    // MARK: - Public iVars
    var story: VisilabsStory? {
        didSet {
            self.profileNameLabel.text = story?.title
            if let picture = story?.smallImg {
                self.profileImageView.imageView.setImage(url: picture)
            }
        }
    }

    // MARK: - Private ivars
    private let profileImageView: VisilabsStoryRoundedView = {
        let roundedView = VisilabsStoryRoundedView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        return roundedView
    }()

    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    // MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private functions
    private func loadUIElements() {
        addSubview(profileImageView)
        addSubview(profileNameLabel)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 68),
            profileImageView.heightAnchor.constraint(equalToConstant: 68),
            profileImageView.igTopAnchor.constraint(equalTo: self.igTopAnchor, constant: 8),
            profileImageView.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor)])

        NSLayoutConstraint.activate([
            profileNameLabel.igLeftAnchor.constraint(equalTo: self.igLeftAnchor),
            profileNameLabel.igRightAnchor.constraint(equalTo: self.igRightAnchor),
            profileNameLabel.igTopAnchor.constraint(equalTo: self.profileImageView.igBottomAnchor, constant: 2),
            profileNameLabel.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor),
            self.igBottomAnchor.constraint(equalTo: profileNameLabel.igBottomAnchor, constant: 8)])

        layoutIfNeeded()
    }
}
