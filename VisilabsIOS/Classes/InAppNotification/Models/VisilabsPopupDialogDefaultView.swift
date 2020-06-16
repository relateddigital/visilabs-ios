//
//  VisilabsPopupDialogDefaultView.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import Foundation
import UIKit

public class VisilabsPopupDialogDefaultView: UIView {
    
    internal lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    internal lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor(white: 0.4, alpha: 1)
        titleLabel.font = .boldSystemFont(ofSize: 14)
        return titleLabel
    }()
    
    internal lazy var messageLabel: UILabel = {
        let messageLabel = UILabel(frame: .zero)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        messageLabel.textColor = UIColor(white: 0.6, alpha: 1)
        messageLabel.font = .systemFont(ofSize: 14)
        return messageLabel
    }()
    
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
    
    internal var imageHeightConstraint: NSLayoutConstraint?
    
    /*
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
   */
    
    weak var visilabsInAppNotification: VisilabsInAppNotification?
    
    init(frame: CGRect, visilabsInAppNotification: VisilabsInAppNotification) {
        self.visilabsInAppNotification = visilabsInAppNotification
        super.init(frame: frame)
        setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setupViews() {
        
        guard let notification = visilabsInAppNotification else {
            return
        }
        
        titleLabel.text = notification.messageTitle
        titleLabel.font = notification.messageTitleFont
        messageLabel.text = notification.messageBody
        messageLabel.font = notification.messageBodyFont
        

        var views: [String: Any] = [:]
        var constraints = [NSLayoutConstraint]()
        
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        
        if notification.type == .image_button || notification.type == .full_image {
            views = ["imageView": imageView]
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]-(==0@900)-|", options: [], metrics: nil, views: views)
            
        }else if notification.type == .image_text_button {
            addSubview(titleLabel)
            addSubview(messageLabel)
            views = ["imageView": imageView, "titleLabel": titleLabel, "messageLabel": messageLabel] as [String: Any]
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[titleLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[messageLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]-(==30@900)-[titleLabel]-(==8@900)-[messageLabel]-(==30@900)-|", options: [], metrics: nil, views: views)
        }
        
        else {
            addSubview(titleLabel)
            addSubview(messageLabel)
            views = ["imageView": imageView, "titleLabel": titleLabel, "messageLabel": messageLabel] as [String: Any]
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[titleLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[messageLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]-(==30@900)-[titleLabel]-(==8@900)-[messageLabel]-(==30@900)-|", options: [], metrics: nil, views: views)
        }
        
        
        
        
        imageHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0, constant: 0)
        
        if let imageHeightConstraint = imageHeightConstraint {
            constraints.append(imageHeightConstraint)
        }

        NSLayoutConstraint.activate(constraints)
    }
}
