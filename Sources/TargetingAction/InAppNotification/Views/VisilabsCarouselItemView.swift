//
//  VisilabsCarouselItemView.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 10.02.2022.
//

import Foundation
import UIKit

public class VisilabsCarouselItemView: UIView, DisplaceableView {
    
    public var image: UIImage?
    

    // MARK: - VARIABLES
    internal lazy var closeButton = setCloseButton()
    internal lazy var imageView = setImageView()
    internal lazy var titleLabel = setTitleLabel()
    internal lazy var copyCodeTextButton = setCopyCodeText()
    internal lazy var copyCodeImageButton = setCopyCodeImage()
    internal lazy var messageLabel = setMessageLabel()
    internal lazy var button = setButton()



    internal lazy var resultLabel = setResultLabel()

    internal lazy var imageButton = setImageButton()

    var colors: [[CGColor]] = []
    var numberBgColor: UIColor = .black
    var numberBorderColor: UIColor = .white
    var selectedNumber: Int?
    var expanded = false
    var sctwMail: String = ""

    
    @objc public dynamic var titleFont: UIFont {
        get { return titleLabel.font }
        set { titleLabel.font = newValue }
    }
    

    @objc public dynamic var titleColor: UIColor? {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }

    @objc public dynamic var titleTextAlignment: NSTextAlignment {
        get { return titleLabel.textAlignment }
        set { titleLabel.textAlignment = newValue }
    }

    @objc public dynamic var messageFont: UIFont {
        get { return messageLabel.font }
        set { messageLabel.font = newValue }
    }

    @objc public dynamic var messageColor: UIColor? {
        get { return messageLabel.textColor }
        set { messageLabel.textColor = newValue}
    }

    @objc public dynamic var messageTextAlignment: NSTextAlignment {
        get { return messageLabel.textAlignment }
        set { messageLabel.textAlignment = newValue }
    }

    @objc public dynamic var closeButtonColor: UIColor? {
        get { return closeButton.currentTitleColor }
        set { closeButton.setTitleColor(newValue, for: .normal) }
    }

    internal var imageHeightConstraint: NSLayoutConstraint?

    weak var visilabsCarouselItem: VisilabsCarouselItem?
    var consentCheckboxAdded = false
    weak var imgButtonDelegate: ImageButtonImageDelegate?
    weak var delegate: VisilabsPopupDialogDefaultViewDelegate?
    
    // MARK: - CONSTRUCTOR
    public init(frame: CGRect, visilabsCarouselItem: VisilabsCarouselItem?) {
        self.visilabsCarouselItem = visilabsCarouselItem
        super.init(frame: frame)
        if self.visilabsCarouselItem != nil {
            setupViews()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setupViews() {
        guard let carouselItem = visilabsCarouselItem else {
            return
        }

        setup(carouselItem)
        
        var constraints = [NSLayoutConstraint]()

        imageHeightConstraint = NSLayoutConstraint(item: imageView,
            attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0, constant: 0)

        if let imageHeightConstraint = imageHeightConstraint {
            constraints.append(imageHeightConstraint)
        }

        closeButton.trailing(to: self, offset: -10.0)
        NSLayoutConstraint.activate(constraints)
    }

}

// MARK: - SliderStepDelegate
extension VisilabsCarouselItemView: SliderStepDelegate {
    func didSelectedValue(sliderStep: VisilabsSliderStep, value: Float) {
        sliderStep.value = value
    }
}

// Email form extension
extension VisilabsCarouselItemView {

    @objc func copyCodeTextButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string = copyCodeTextButton.currentTitle
        VisilabsHelper.showCopiedClipboardMessage()
    }
}

extension VisilabsCarouselItemView {
    
    internal func setButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .center
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 35.0, weight: .regular)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }

    internal func setCloseButton() -> UIButton {
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.contentHorizontalAlignment = .right
        closeButton.clipsToBounds = false
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.setTitle("×", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 35.0, weight: .regular)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        return closeButton
    }

    internal func setImageView() -> UIImageView {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    internal func setTitleLabel() -> UILabel {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(white: 0.4, alpha: 1)
        titleLabel.font = .boldSystemFont(ofSize: 14)
        return titleLabel
    }

    internal func setCopyCodeText() -> UIButton {
        let copyCodeText = UIButton(frame: .zero)
        copyCodeText.translatesAutoresizingMaskIntoConstraints = false
        copyCodeText.setTitle(self.visilabsCarouselItem?.promotionCode, for: .normal)
        copyCodeText.backgroundColor = self.visilabsCarouselItem?.promocodeBackgroundColor
        copyCodeText.setTitleColor(self.visilabsCarouselItem?.promocodeTextColor, for: .normal)
        copyCodeText.addTarget(self, action: #selector(copyCodeTextButtonTapped(_:)), for: .touchUpInside)
        copyCodeText.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .regular)
        return copyCodeText
    }

    internal func setCopyCodeImage() -> UIButton {
        let copyCodeImage = UIButton(frame: .zero)
        let copyIconImage = VisilabsHelper.getUIImage(named: "RelatedCopyButton")
        copyCodeImage.setImage(copyIconImage, for: .normal)
        copyCodeImage.translatesAutoresizingMaskIntoConstraints = false
        copyCodeImage.backgroundColor = self.visilabsCarouselItem?.promocodeBackgroundColor
        copyCodeImage.addTarget(self, action: #selector(copyCodeTextButtonTapped(_:)), for: .touchUpInside)
        return copyCodeImage
    }

    internal func setMessageLabel() -> UILabel {
        let messageLabel = UILabel(frame: .zero)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = UIColor(white: 0.6, alpha: 1)
        messageLabel.font = .systemFont(ofSize: 14)
        return messageLabel
    }

    internal func setResultLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.textAlignment = .natural
        label.font = .systemFont(ofSize: 10)
        label.textColor = .red
        return label
    }

    internal func setImageButton() -> UIButton {
        let button = UIButton(frame: .zero)
        button.backgroundColor = self.visilabsCarouselItem?.buttonColor ?? .black
        button.setTitle(self.visilabsCarouselItem?.buttonText, for: .normal)
        button.setTitleColor(self.visilabsCarouselItem?.buttonTextColor, for: .normal)
        button.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
        return button
    }

    @objc func imageButtonTapped() {
        print("image button tapped.. should dismiss")
        self.imgButtonDelegate?.imageButtonTapped()
    }


    private func getUIImage(named: String) -> UIImage? {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: type(of: self))
        #endif
        return UIImage(named: named, in: bundle, compatibleWith: nil)!.resized(withPercentage: CGFloat(0.75))
    }

    internal func setup(_ carouselItem: VisilabsCarouselItem) {
        if let bgColor = carouselItem.backgroundColor {
            self.backgroundColor = bgColor
        }

        titleLabel.text = carouselItem.title?.removeEscapingCharacters()
        titleLabel.font = carouselItem.titleFont
        if let titleColor = carouselItem.titleColor {
            titleLabel.textColor = titleColor
        }
        messageLabel.text = carouselItem.body?.removeEscapingCharacters()
        messageLabel.font = carouselItem.bodyFont
        if let bodyColor = carouselItem.bodyColor {
            messageLabel.textColor = bodyColor
        }
        
        button.setTitle(carouselItem.buttonText?.removeEscapingCharacters(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = carouselItem.buttonFont
        if let buttonTextColor = carouselItem.buttonTextColor {
            button.setTitleColor(buttonTextColor, for: .normal)
        }
        if let buttonColor = carouselItem.buttonColor {
            button.backgroundColor = buttonColor
        }
        
        

        if let closeButtonColor = carouselItem.closeButtonColor {
            closeButton.setTitleColor(closeButtonColor, for: .normal)
        }

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addSubview(closeButton)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(button)
        
        imageView.allEdges(to: self, excluding: .bottom)
        titleLabel.topToBottom(of: imageView, offset: 10.0)
        messageLabel.topToBottom(of: titleLabel, offset: 8.0)
        
        addSubview(copyCodeTextButton)
        addSubview(copyCodeImageButton)
        

        if let promo = self.visilabsCarouselItem?.promotionCode,
           let _ = self.visilabsCarouselItem?.promocodeBackgroundColor,
           let _ = self.visilabsCarouselItem?.promocodeTextColor,
           !promo.isEmpty {
            copyCodeTextButton.topToBottom(of: messageLabel, offset: 10.0)
            copyCodeTextButton.bottom(to: self, offset: 0.0)
            copyCodeImageButton.topToBottom(of: messageLabel, offset: 10.0)
            copyCodeImageButton.bottom(to: copyCodeTextButton)
            copyCodeTextButton.leading(to: self)
            copyCodeImageButton.width(50.0)
            copyCodeImageButton.trailing(to: self)
            copyCodeTextButton.trailingToLeading(of: copyCodeImageButton, offset: 20.0)
            
        } else {
            copyCodeTextButton.topToBottom(of: messageLabel, offset: 10.0)
            copyCodeTextButton.bottom(to: self, offset: 0.0)
            copyCodeImageButton.topToBottom(of: messageLabel, offset: 10.0)
            copyCodeImageButton.bottom(to: copyCodeTextButton)
            copyCodeTextButton.leading(to: self)
            copyCodeImageButton.width(50.0)
            copyCodeImageButton.trailing(to: self)
            copyCodeTextButton.trailingToLeading(of: copyCodeImageButton, offset: 20.0)
            copyCodeTextButton.isHidden = true
            copyCodeImageButton.isHidden = true
            messageLabel.bottom(to: self, offset: -10)
        }
        
        button.topToBottom(of: copyCodeTextButton, offset: 5.0)

        titleLabel.centerX(to: self)
        messageLabel.centerX(to: self)
        button.centerX(to: self)
    }



}


public class CounterView: UIView {
    
    public var count: Int
    let countLabel = UILabel()
    public var currentIndex: Int {
        didSet {
            updateLabel()
        }
    }
    
    public init(frame: CGRect, currentIndex: Int, count: Int) {
        self.currentIndex = currentIndex
        self.count = count
        super.init(frame: frame)
        configureLabel()
        updateLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        countLabel.textAlignment = .center
        self.addSubview(countLabel)
    }
    
    func updateLabel() {
        let stringTemplate = "%d of %d"
        let countString = String(format: stringTemplate, arguments: [currentIndex + 1, count])
        countLabel.attributedText = NSAttributedString(string: countString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        countLabel.frame = self.bounds
    }
}

