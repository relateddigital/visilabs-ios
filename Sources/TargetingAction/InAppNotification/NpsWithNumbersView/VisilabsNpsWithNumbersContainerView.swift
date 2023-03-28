//
//  VisilabsNpsWithNumbersContainerView.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 28.03.2023.
//

import Foundation
import UIKit
import AVFoundation

final public class VisilabsNpsWithNumbersContainerView: UIView {
    
    var player : AVPlayer?
    
    var notification: VisilabsInAppNotification?
    
    fileprivate var button: VisilabsPopupDialogButton?
    public var collectionView: VisilabsNpsWithNumbersCollectionView!
    
    internal lazy var shadowContainer: UIView = {
        let shadowContainer = UIView(frame: .zero)
        shadowContainer.isUserInteractionEnabled = true
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        shadowContainer.backgroundColor = .yellow
        shadowContainer.clipsToBounds = false
        return shadowContainer
    }()
    
    internal lazy var buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.isUserInteractionEnabled = true
        buttonStackView.isAccessibilityElement = true
        buttonStackView.layer.isAccessibilityElement = true
        buttonStackView.backgroundColor = .clear
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 0
        return buttonStackView
    }()
    
    internal lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.buttonStackView])
        stackView.isUserInteractionEnabled = true
        stackView.isAccessibilityElement = true
        stackView.layer.isAccessibilityElement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    
    // MARK: - Constraints
    
    /// The center constraint of the shadow container
    internal var centerYConstraint: NSLayoutConstraint?
    
    // MARK: - Initializers
    
    internal init(frame: CGRect, notification: VisilabsInAppNotification) {
        super.init(frame: frame)
        self.notification = notification
        self.backgroundColor = .clear
        buttonStackView.accessibilityIdentifier = "buttonStack"
        if let backgroundColor = notification.backGroundColor {
            shadowContainer.backgroundColor = backgroundColor
        }
        buttonStackView.axis = .vertical
        
        button = VisilabsPopupDialogButton(
            title: notification.buttonText!,
            font: notification.buttonTextFont,
            buttonTextColor: notification.buttonTextColor,
            buttonColor: notification.buttonColor, action: commonButtonAction)
        button!.isEnabled = false
        button!.isUserInteractionEnabled = true
        
        collectionView = VisilabsNpsWithNumbersCollectionView(frame:.zero, inAppNotification: notification)
        stackView.insertArrangedSubview(collectionView, at: 0)
        collectionView.npsDelegate = self
        
        appendButtons()
        player = collectionView.imageView.addVideoPlayer(urlString: notification.videourl ?? "")
        
        setupViews()
        super.layoutIfNeeded()
    }
    
    func commonButtonAction() {
        guard let notification = self.notification else { return }
        var returnCallback = true
        var additionalTrackingProperties = [String: String]()
        
        if let num = collectionView.selectedNumber {
            additionalTrackingProperties["OM.s_point"] = "\(num)"
        }
        additionalTrackingProperties["OM.s_cat"] = notification.type.rawValue
        additionalTrackingProperties["OM.s_page"] = "act-\(notification.actId)"
        
        // Check if second popup coming
        var callToActionURL: URL? = notification.callToActionUrl
        /*
         self.delegate?.notificationShouldDismiss(controller: self,
         callToActionURL: callToActionURL,
         shouldTrack: true,
         additionalTrackingProperties: additionalTrackingProperties)
         */
        
        if returnCallback {
            
            if notification.buttonFunction == VisilabsConstants.copyRedirect {
                if let promoCode = notification.promotionCode {
                    UIPasteboard.general.string = promoCode
                    VisilabsHelper.showCopiedClipboardMessage()
                }
            }
            //self.inappButtonDelegate?.didTapButton(notification)
        }
    }
    
    public override func layoutSubviews() {
        
        
        
        DispatchQueue.main.async { [self] in
            collectionView.npsDelegate = self
            collectionView.isUserInteractionEnabled = true
            if notification?.videourl?.count ?? 0 > 0 {
                collectionView.imageHeightConstraint?.constant = collectionView.imageView.pv_heightForImageView(isVideoExist: true)
            } else {
                let a = collectionView.imageView.pv_heightForImageView(isVideoExist: false)
                print(a)
                collectionView.imageHeightConstraint?.constant = a // standardView.imageView.pv_heightForImageView(isVideoExist: false)
                //let a = collectionView.imageView.pv_heightForImageView(isVideoExist: false)
                //collectionView.imageHeightConstraint?.constant = a // standardView.imageView.pv_heightForImageView(isVideoExist: false)
                //collectionView.imageHeightConstraint?.isActive = true
                //collectionView.imageView.height(a)
                self.superview?.layoutSubviews()
            }
            //self.setupViews()
        }
        
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        player?.pause()
    }
    
    
    
    fileprivate func appendButtons() {
        if button == nil {
            stackView.removeArrangedSubview(buttonStackView)
        }
        button!.needsLeftSeparator = buttonStackView.axis == .horizontal
        buttonStackView.addArrangedSubview(button!)
        button!.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button!.isUserInteractionEnabled = true
        
    }
    
    
    @objc fileprivate func buttonTapped(_ button: VisilabsPopupDialogButton) {
        button.buttonAction?()
    }
    
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View setup
    
    internal func setupViews() {
        
        addSubview(shadowContainer)
        shadowContainer.addSubview(stackView)
        
        var constraints = [NSLayoutConstraint]()
        
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            //shadowContainer.width(preferredWidth)
            shadowContainer.leading(to: self, offset: 0.0, relation: .equalOrGreater, priority: .required)
            shadowContainer.trailing(to: self, offset: 0.0, relation: .equalOrLess, priority: .required)
        } else {
            //shadowContainer.width(preferredWidth, relation: .equalOrGreater)
            shadowContainer.leading(to: self, offset: 0, relation: .equal)
            shadowContainer.trailing(to: self, offset: 0, relation: .equal)
        }
        
        
        constraints += [NSLayoutConstraint(item: shadowContainer,
                                           attribute: .centerX,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .centerX,
                                           multiplier: 1,
                                           constant: 0)]
        
        centerYConstraint = NSLayoutConstraint(item: shadowContainer,
                                               attribute: .centerY,
                                               relatedBy: .equal,
                                               toItem: self,
                                               attribute: .centerY,
                                               multiplier: 1,
                                               constant: 0)
        
        if let centerYConstraint = centerYConstraint {
            constraints.append(centerYConstraint)
        }
        
        stackView.allEdges(to: shadowContainer)
        
        // Activate constraints
        NSLayoutConstraint.activate(constraints)
    }
}


extension VisilabsNpsWithNumbersContainerView: NPSDelegate {
    
    func ratingSelected() {
        if let button = button {
            button.isEnabled = true
        }
    }
    
    func ratingUnselected() {
        if let button = button {
            button.isEnabled = false
        }
    }
    
}

@objc
public protocol RDNpsWithNumbersViewURLDelegate: NSObjectProtocol {
    @objc
    func urlClicked(_ url: URL)
}

