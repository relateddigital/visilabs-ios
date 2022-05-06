//
//  VisilabsCarouselItemView.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 10.02.2022.
//

import UIKit

public class VisilabsCarouselItemView: UIView, DisplaceableView {

    // MARK: - VARIABLES
    internal lazy var closeButton = setCloseButton()
    internal lazy var imageView = setImageView()
    internal lazy var titleLabel = setTitleLabel()
    internal lazy var copyCodeTextButton = setCopyCodeText()
    internal lazy var copyCodeImageButton = setCopyCodeImage()
    internal lazy var messageLabel = setMessageLabel()
    internal lazy var button = setButton()
    
    
    public var footerView: UIPageControl?


    
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

    public weak var visilabsCarouselItem: VisilabsCarouselItem?
    
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
        button.titleLabel?.numberOfLines = 0
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
    
    internal func setMessageLabel() -> UILabel {
        let messageLabel = UILabel(frame: .zero)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = UIColor(white: 0.6, alpha: 1)
        messageLabel.font = .systemFont(ofSize: 14)
        return messageLabel
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

    internal func setup(_ carouselItem: VisilabsCarouselItem) {

        if let closeButtonColor = carouselItem.closeButtonColor {
            closeButton.setTitleColor(closeButtonColor, for: .normal)
        }

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addSubview(closeButton)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(copyCodeTextButton)
        addSubview(copyCodeImageButton)
        addSubview(button)
        
        
        if carouselItem.title.isNilOrWhiteSpace {
            titleLabel.isHidden = true
        } else {
            titleLabel.isHidden = false
            titleLabel.text = carouselItem.title?.removeEscapingCharacters()
            titleLabel.font = carouselItem.titleFont
            if let titleColor = carouselItem.titleColor {
                titleLabel.textColor = titleColor
            }
        }
        
        if carouselItem.body.isNilOrWhiteSpace {
            messageLabel.isHidden = true
        } else {
            messageLabel.isHidden = false
            messageLabel.text = carouselItem.body?.removeEscapingCharacters()
            messageLabel.font = carouselItem.bodyFont
            if let bodyColor = carouselItem.bodyColor {
                messageLabel.textColor = bodyColor
            }
        }
        
        if carouselItem.buttonText.isNilOrWhiteSpace {
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            button.height(0.0)
            button.isHidden = true
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
            button.isHidden = false
            button.setTitle(carouselItem.buttonText?.removeEscapingCharacters(), for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleLabel?.font = carouselItem.buttonFont
            if let buttonTextColor = carouselItem.buttonTextColor {
                button.setTitleColor(buttonTextColor, for: .normal)
            }
            if let buttonColor = carouselItem.buttonColor {
                button.backgroundColor = buttonColor
            }
        }
        

        if let promo = self.visilabsCarouselItem?.promotionCode,
           let _ = self.visilabsCarouselItem?.promocodeBackgroundColor,
           let _ = self.visilabsCarouselItem?.promocodeTextColor,
           !promo.isEmpty {
            copyCodeTextButton.isHidden = false
            copyCodeImageButton.isHidden = false
        } else {
            copyCodeTextButton.isHidden = true
            copyCodeImageButton.isHidden = true
        }
        

        imageView.allEdges(to: self, excluding: .bottom)
        titleLabel.topToBottom(of: imageView, offset: titleLabel.isHidden ? 0.0: 10.0)
        messageLabel.topToBottom(of: titleLabel, offset: messageLabel.isHidden ? 0.0: 8.0)
        copyCodeTextButton.topToBottom(of: messageLabel, offset: copyCodeTextButton.isHidden ? 0.0 : 10.0)
        copyCodeImageButton.topToBottom(of: messageLabel, offset: copyCodeTextButton.isHidden ? 0.0 : 10.0)
        copyCodeImageButton.bottom(to: copyCodeTextButton)
        copyCodeTextButton.leading(to: self, offset: 10.0)
        copyCodeImageButton.width(50.0)
        copyCodeImageButton.trailing(to: self, offset: -10.0)
        copyCodeTextButton.trailingToLeading(of: copyCodeImageButton, offset: 20.0)
        button.topToBottom(of: copyCodeTextButton, offset: button.isHidden ? 0.0 :  5.0)
        button.bottom(to: self, offset: -30.0)
        
        
        titleLabel.centerX(to: self)
        messageLabel.centerX(to: self)
        button.centerX(to: self)
        

        self.backgroundColor = .white
        
        if let bgColor = carouselItem.backgroundColor {
            self.backgroundColor = bgColor
        }
  
    }

}
