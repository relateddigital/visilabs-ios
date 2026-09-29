//
//  VisilabsHalfScreenView.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 10.11.2021.
//

import Foundation
import UIKit

class VisilabsHalfScreenView: UIView {
    
    static let closeButtonExtraSpace: CGFloat = 40.0
    
    var notification: VisilabsInAppNotification
    var containerView: UIView!
    var titleLabel: UILabel!
    var imageView: UIImageView!
    var closeButton: UIButton!
    
    var promotionContainer: UIView?
    var promotionCodeLabel: UILabel?
    var copyButton: UIButton?
    
    init(frame: CGRect, notification: VisilabsInAppNotification) {
        self.notification = notification
        super.init(frame: frame)
        setupContainer()
        setupTitle()
        if let imageData = notification.image, var image = UIImage(data: imageData, scale: 1) {
            if let imageGif = UIImage.gif(data: imageData) {
                image = imageGif
            }
            setupImageView(image: image)
        }
        setupPromotionCode()
        setCloseButton()
        layoutContent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContainer() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = false
        addSubview(containerView)
    }
    
    private func setupTitle() {
        titleLabel = UILabel()
        titleLabel.text = notification.messageTitle
        titleLabel.font = notification.messageTitleFont
        titleLabel.textColor = notification.messageTitleColor
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
    }
    
    private func setupImageView(image: UIImage) {
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = image
        containerView.addSubview(imageView)
        
        if image.size.width > 0 {
            let ratio = image.size.height / image.size.width
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio).isActive = true
        }
    }
    
    private func setupPromotionCode() {
        guard let promoCode = notification.promotionCode, !promoCode.isEmpty else { return }
        
        promotionContainer = UIView()
        promotionContainer?.translatesAutoresizingMaskIntoConstraints = false
        promotionContainer?.backgroundColor = .clear
        containerView.addSubview(promotionContainer!)
        
        promotionCodeLabel = UILabel()
        promotionCodeLabel?.text = promoCode
        promotionCodeLabel?.font = notification.messageTitleFont
        promotionCodeLabel?.textColor = notification.promotionTextColor ?? notification.messageTitleColor
        promotionCodeLabel?.textAlignment = .center
        promotionCodeLabel?.translatesAutoresizingMaskIntoConstraints = false
        promotionContainer?.addSubview(promotionCodeLabel!)
        
        copyButton = UIButton()
        copyButton?.translatesAutoresizingMaskIntoConstraints = false
        let copyIcon = VisilabsHelper.getUIImage(named: "RelatedCopyButton")
        copyButton?.setImage(copyIcon, for: .normal)
        copyButton?.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        promotionContainer?.addSubview(copyButton!)
    }
    
    private func setCloseButton() {
        closeButton = UIButton(type: .custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 15.0
        closeButton.layer.borderWidth = 0.5
        closeButton.setTitle("×", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 20.0, weight: .bold)
        closeButton.contentHorizontalAlignment = .center
        closeButton.contentVerticalAlignment = .center
        closeButton.titleEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 1, right: 0)
        
        setupCloseButtonColors()
        addSubview(closeButton)
    }
    
    private func setupCloseButtonColors() {
        let isWhite = isWhiteColor(notification.closeButtonColor)
        if isWhite {
            closeButton.backgroundColor = .black
            closeButton.setTitleColor(.white, for: .normal)
            closeButton.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        } else {
            closeButton.backgroundColor = .white
            closeButton.setTitleColor(notification.closeButtonColor ?? .black, for: .normal)
            closeButton.layer.borderColor = UIColor.black.withAlphaComponent(0.15).cgColor
        }
    }
    
    private func isWhiteColor(_ color: UIColor?) -> Bool {
        guard let color = color else { return false }
        var white: CGFloat = 0
        var alpha: CGFloat = 0
        if color.getWhite(&white, alpha: &alpha) {
            return white >= 0.95
        }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &alpha) {
            return r >= 0.95 && g >= 0.95 && b >= 0.95
        }
        return false
    }
    
    private func layoutContent() {
        self.backgroundColor = .clear
        containerView.backgroundColor = notification.backGroundColor
        
        containerView.leading(to: self, offset: 0, relation: .equal, priority: .required)
        containerView.trailing(to: self, offset: 0, relation: .equal, priority: .required)
        
        if notification.position == .top {
            containerView.top(to: self, offset: 0, relation: .equal, priority: .required)
            containerView.bottom(to: self, offset: -VisilabsHalfScreenView.closeButtonExtraSpace, relation: .equal, priority: .required)
            
            closeButton.top(to: containerView, containerView.bottomAnchor, offset: 6.0)
            closeButton.trailing(to: self, offset: -16.0)
        } else {
            containerView.bottom(to: self, offset: 0, relation: .equal, priority: .required)
            containerView.top(to: self, offset: VisilabsHalfScreenView.closeButtonExtraSpace, relation: .equal, priority: .required)
            
            closeButton.bottom(to: containerView, containerView.topAnchor, offset: -6.0)
            closeButton.trailing(to: self, offset: -16.0)
        }
        
        closeButton.width(30.0)
        closeButton.height(30.0)
        
        titleLabel.top(to: containerView, offset: 0)
        titleLabel.leading(to: containerView, offset: 0, relation: .equal, priority: .required)
        titleLabel.trailing(to: containerView, offset: 0, relation: .equal, priority: .required)
        titleLabel.centerX(to: containerView, priority: .required)
        
        if let imageView = imageView {
            imageView.topToBottom(of: self.titleLabel, offset: 0)
            imageView.leading(to: containerView, offset: 0, relation: .equal, priority: .required)
            imageView.trailing(to: containerView, offset: 0, relation: .equal, priority: .required)
        }
        
        if let promotionContainer = promotionContainer {
            if let imageView = imageView {
                promotionContainer.topToBottom(of: imageView, offset: 0)
            } else {
                promotionContainer.topToBottom(of: titleLabel, offset: 0)
            }
            promotionContainer.leading(to: containerView, offset: 0, relation: .equal, priority: .required)
            promotionContainer.trailing(to: containerView, offset: 0, relation: .equal, priority: .required)
            
            promotionCodeLabel?.center(in: promotionContainer)
            
            copyButton?.centerY(to: promotionContainer)
            copyButton?.trailing(to: promotionContainer, offset: -20)
            copyButton?.width(30)
            copyButton?.height(30)
        }
        
        self.layoutIfNeeded()
    }
    
    @objc func copyButtonTapped(_ sender: UIButton) {
        if let code = promotionCodeLabel?.text {
            UIPasteboard.general.string = code
            VisilabsHelper.showCopiedClipboardMessage()
            VisilabsHelper.setCopyButtonFeedback(button: sender)
        }
    }
    
    override func layoutSubviews() {
        if titleLabel.text.isNilOrWhiteSpace {
            titleLabel.height(0)
            titleLabel.isHidden = true
        } else {
            titleLabel.height(titleLabel.intrinsicContentSize.height + 20)
        }
        
        if let promotionContainer = promotionContainer, let promotionCodeLabel = promotionCodeLabel {
            if promotionCodeLabel.text.isNilOrWhiteSpace {
                promotionContainer.height(0)
                promotionContainer.isHidden = true
            } else {
                let promoHeight = promotionCodeLabel.intrinsicContentSize.height + 20
                promotionContainer.height(promoHeight)
            }
        }
        
        super.layoutSubviews()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let pointInContainer = containerView.convert(point, from: self)
        if containerView.point(inside: pointInContainer, with: event) {
            return true
        }
        let pointInClose = closeButton.convert(point, from: self)
        let closeTouchBounds = closeButton.bounds.insetBy(dx: -10, dy: -10)
        if closeTouchBounds.contains(pointInClose) {
            return true
        }
        return false
    }
}
