//
//  VisilabsHalfScreenView.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 10.11.2021.
//

import Foundation
import UIKit

class VisilabsHalfScreenView: UIView {
    
    var notification: VisilabsInAppNotification
    var titleLabel: UILabel!
    var imageView: UIImageView!
    var closeButton: UIButton!
    
    init(frame: CGRect, notification: VisilabsInAppNotification) {
        self.notification = notification
        super.init(frame: frame)
        setupTitle()
        if let imageData = notification.image, let image = UIImage(data: imageData, scale: 1) {
            setupImageView(image: image)
        }
        setCloseButton()
        layoutContent()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTitle() {
        titleLabel = UILabel()
        titleLabel.text = notification.messageTitle //TODO: AÇ SONRA
        titleLabel.font = notification.messageTitleFont
        titleLabel.textColor = notification.messageTitleColor
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
    }
    
    private func setupImageView(image: UIImage) {
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = image
        addSubview(imageView)
    }
    
    private func setCloseButton() {
        closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.contentHorizontalAlignment = .right
        closeButton.clipsToBounds = false
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.setTitle("×", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 35.0, weight: .regular)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        if let closeButtonColor = notification.closeButtonColor {
            closeButton.setTitleColor(closeButtonColor, for: .normal)
        }
        addSubview(closeButton)
    }
    
    private func layoutContent() {
        self.backgroundColor = notification.backGroundColor
        titleLabel.leading(to: self, offset: 0, relation: .equal, priority: .required)
        titleLabel.trailing(to: self, offset: 0, relation: .equal, priority: .required)
        titleLabel.centerX(to: self,priority: .required)
        if titleLabel.text.isNilOrWhiteSpace {
            titleLabel.height(0)
            titleLabel.isHidden = true
        } else {
            titleLabel.height(titleLabel.intrinsicContentSize.height + 10)
        }
        imageView?.topToBottom(of: self.titleLabel, offset: 0)
        imageView?.leading(to: self, offset: 0, relation: .equal, priority: .required)
        imageView?.trailing(to: self, offset: 0, relation: .equal, priority: .required)
        
        closeButton.top(to: self, offset: -5.0)
        closeButton.trailing(to: self, offset: -10.0)
        
        self.window?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
        self.window?.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    
    
    
}


//entry
//
//auxLabel: nil, auxiliaryContent: nil
//message:



//name:nil
//windowLevel:normal
//position:top
//precedence:override(prority:500, dropEnqueuedEntries:false)
//displayDuration:infinite
//popBehavior: animated
//positionConstraints: rotation:(isEnabled: true, supportedInterfaceOrientations: standard), keyboardRelation: unbind
//        maxSize(width:intrinsic, height: intrinsic), verticalOffset = 0, safeArea = overridden
//screenInteraction: defaultAction: forward, customTapActions = 0 values {}
//entryInteraction = {defaultAction = dismissEntry customTapActions = 0 values {} }
//scroll = disabled
//hapticFeedbackType = none
//lifecycleEvents: hepsi nil
//displayMode = inferred
// entryBackground : color
// screenBackground = clear
//shadow = none
//roundCorners = none
//statusBar = inferred
//entranceAnimation: {translate = some {duration = 0.29999999999999999 delay = 0 anchorPosition = automatic spring = nil} scale = nil fade = nil}
//exitAnimation = {translate = some { duration = 0.29999999999999999 delay = 0 anchorPosition = automatic spring = nil} scale = nil fade = nil }
//popBehavior:animated { animated = { animation = { translate = some { duration = 0.29999999999999999 delay = 0 anchorPosition = automaticspring = nil}
//    scale = nil fade = nil } } }



