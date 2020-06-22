//
//  VisilabsPopupDialogDefaultView.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import Foundation
import UIKit

public class VisilabsPopupDialogDefaultView: UIView {
    
    internal lazy var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.contentHorizontalAlignment = .right
        closeButton.clipsToBounds = true
        if let closeImage = UIImage(systemItem: UIBarButtonItem.SystemItem.stop) {
            closeButton.setImage(closeImage, for: .normal)
            closeButton.tintColor = UIColor.white
            closeButton.setTitleColor(UIColor.white, for: .normal)
        }
        return closeButton
    }()
    

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
    
    internal lazy var npsView: CosmosView = {
        var settings = CosmosSettings()
        settings.filledColor = UIColor.systemYellow
        settings.emptyColor = UIColor.white
        settings.filledBorderColor = UIColor.white
        settings.emptyBorderColor = UIColor.systemYellow
        settings.fillMode = .half
        settings.starSize = 40.0
        let npsView = CosmosView(settings: settings)
        npsView.translatesAutoresizingMaskIntoConstraints = false
        return npsView
    }()
    
    let bundle = Bundle(identifier: "com.relateddigital.visilabs")
    private func getUIImage(named: String) -> UIImage?{
        return UIImage(named: named, in : bundle, compatibleWith: nil)!.resized(withPercentage: CGFloat(0.75))
    }
    
    
    internal lazy var sliderStepRating: VisilabsSliderStep = {
        var sliderStepRating = VisilabsSliderStep()
        

        sliderStepRating.stepImages =   [getUIImage(named:"terrible")!, getUIImage(named:"bad")!, getUIImage(named:"okay")!, getUIImage(named:"good")!,getUIImage(named:"great")!, ]
        sliderStepRating.tickImages = [getUIImage(named:"unTerrible")!, getUIImage(named:"unBad")!, getUIImage(named:"unOkay")!, getUIImage(named:"unGood")!,getUIImage(named:"unGreat")!, ]
        
        
        sliderStepRating.tickTitles = ["Berbat", "Kötü", "Normal", "İyi", "Harika"]
        
        
        sliderStepRating.minimumValue = 1
        sliderStepRating.maximumValue = Float(sliderStepRating.stepImages!.count) + sliderStepRating.minimumValue - 1.0
        sliderStepRating.stepTickColor = UIColor.clear
        sliderStepRating.stepTickWidth = 20
        sliderStepRating.stepTickHeight = 20
        sliderStepRating.trackHeight = 2
        sliderStepRating.value = 5
        sliderStepRating.trackColor = #colorLiteral(red: 0.9371728301, green: 0.9373074174, blue: 0.9371433258, alpha: 1)
        sliderStepRating.enableTap = true
        sliderStepRating.sliderStepDelegate = self
        sliderStepRating.translatesAutoresizingMaskIntoConstraints = false
        
        sliderStepRating.contentMode = .redraw //enable redraw on rotation (calls setNeedsDisplay)
        
        if sliderStepRating.enableTap {
            let tap = UITapGestureRecognizer(target: sliderStepRating, action: #selector(VisilabsSliderStep.sliderTapped(_:)))
            self.addGestureRecognizer(tap)
        }
        
        sliderStepRating.addTarget(sliderStepRating, action: #selector(VisilabsSliderStep.movingSliderStepValue), for: .valueChanged)
        sliderStepRating.addTarget(sliderStepRating, action: #selector(VisilabsSliderStep.didMoveSliderStepValue), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return sliderStepRating
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
    
    
    @objc public dynamic var closeButtonColor: UIColor? {
        get { return closeButton.tintColor }
        set { closeButton.tintColor = newValue }
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
        
        if let bgColor = notification.backGroundColor {
            self.backgroundColor = bgColor
        }
        
        
        titleLabel.text = notification.messageTitle
        titleLabel.font = notification.messageTitleFont
        if let titleColor = notification.messageTitleColor {
            titleLabel.textColor = titleColor
        }
        messageLabel.text = notification.messageBody
        messageLabel.font = notification.messageBodyFont
        if let bodyColor = notification.messageBodyColor {
            messageLabel.textColor = bodyColor
        }
        

        var views: [String: Any] = [:]
        var constraints = [NSLayoutConstraint]()
        
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(closeButton)

        
        if notification.type == .image_button || notification.type == .full_image {
            views = ["imageView": imageView, "closeButton": closeButton]
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[closeButton]-(==10@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==40@900)-[imageView]-(==40@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==10@900)-[closeButton]-(==20@900)-[imageView]-(==40@900)-|", options: [], metrics: nil, views: views)
            
        }else if notification.type == .image_text_button {
            addSubview(titleLabel)
            addSubview(messageLabel)
            views = ["imageView": imageView, "titleLabel": titleLabel, "messageLabel": messageLabel,"closeButton": closeButton] as [String: Any]
            //constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==40@950)-[imageView]-(==40@950)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[closeButton]-(==10@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==40@900)-[imageView]-(==40@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[titleLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[messageLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==10@900)-[closeButton]-(==20@900)-[imageView]-(==30@900)-[titleLabel]-(==8@900)-[messageLabel]-(==30@900)-|", options: [], metrics: nil, views: views)
        } else if notification.type == .nps {
            addSubview(titleLabel)
            addSubview(messageLabel)
            addSubview(npsView)
            
            
            views = ["imageView": imageView, "titleLabel": titleLabel, "messageLabel": messageLabel, "npsView" : npsView, "closeButton": closeButton] as [String: Any]
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[closeButton]-(==10@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==40@900)-[imageView]-(==40@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[titleLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[messageLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
            // TODO: burada sabit 60 vermek yerine hesaplanabilir.
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==60@900)-[npsView]-(==60@900)-|", options: .alignAllCenterX, metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==10@900)-[closeButton]-(==20@900)-[imageView]-(==30@900)-[titleLabel]-(==8@900)-[messageLabel]-(==30@900)-[npsView]-(==30@900)-|", options: [], metrics: nil, views: views)
        } else if notification.type == .smile_rating {
                addSubview(titleLabel)
                addSubview(messageLabel)
                addSubview(sliderStepRating)
                
                
                views = ["imageView": imageView, "titleLabel": titleLabel, "messageLabel": messageLabel, "sliderStepRating" : sliderStepRating, "closeButton": closeButton] as [String: Any]
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[closeButton]-(==10@900)-|", options: [], metrics: nil, views: views)
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==40@900)-[imageView]-(==40@900)-|", options: [], metrics: nil, views: views)
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[titleLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[messageLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
                // TODO: burada sabit 60 vermek yerine hesaplanabilir.
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[sliderStepRating]-(==20@900)-|", options: .alignAllCenterX, metrics: nil, views: views)
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==10@900)-[closeButton]-(==20@900)-[imageView]-(==30@900)-[titleLabel]-(==8@900)-[messageLabel]-(==30@900)-[sliderStepRating]-(==30@900)-|", options: [], metrics: nil, views: views)
 
        }
        
        else {
            addSubview(titleLabel)
            addSubview(messageLabel)
            views = ["imageView": imageView, "titleLabel": titleLabel, "messageLabel": messageLabel, "closeButton": closeButton] as [String: Any]
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[closeButton]-(==10@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==40@900)-[imageView]-(==40@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[titleLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==20@900)-[messageLabel]-(==20@900)-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==10@900)-[closeButton]-(==20@900)-[imageView]-[titleLabel]-(==8@900)-[messageLabel]-(==30@900)-|", options: [], metrics: nil, views: views)
        }
        
        
        imageHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0, constant: 0)
        
        if let imageHeightConstraint = imageHeightConstraint {
            constraints.append(imageHeightConstraint)
        }

        NSLayoutConstraint.activate(constraints)

    }
}

//MARK:- SliderStepDelegate
extension VisilabsPopupDialogDefaultView: SliderStepDelegate {
    func didSelectedValue(sliderStep: VisilabsSliderStep, value: Float) {
        print(Int(value))
    }
}
