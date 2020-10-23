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
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.contentHorizontalAlignment = .right
        closeButton.clipsToBounds = false
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.setTitle("×", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 35.0, weight: .regular)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
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
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(white: 0.4, alpha: 1)
        titleLabel.font = .boldSystemFont(ofSize: 14)
        return titleLabel
    }()
    
    internal lazy var messageLabel: UILabel = {
        let messageLabel = UILabel(frame: .zero)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
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
        settings.disablePanGestures = true
        let npsView = CosmosView(settings: settings)
        npsView.translatesAutoresizingMaskIntoConstraints = false
        npsView.rating = 0.0
        return npsView
    }()
    
    internal lazy var emailTF: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .natural
        textField.font = .systemFont(ofSize: 14)
//        textField.backgroundColor = UIColor(hex: "38baa4")
        textField.textColor = .white
        textField.placeholder = "E-posta adresinizi giriniz."
        textField.borderStyle = .line
        textField.delegate = self
        return textField
    }()
    
    internal lazy var checkbox: Checkbox = {
        let check = Checkbox(frame: .zero)
        check.checkmarkStyle = .tick
        check.borderStyle = .square
        check.uncheckedBorderColor = .white
        check.checkedBorderColor = .white
        check.checkmarkColor = .white
        return check
    }()
    
    internal lazy var termsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        //geçici
        label.text = "Kullanım koşullarını okuldum ve kabul ediyorum."
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    internal lazy var resultLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .natural
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private func getUIImage(named: String) -> UIImage?{
        let bundle = Bundle(identifier: "com.relateddigital.visilabs")
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
        sliderStepRating.value = 1
        sliderStepRating.trackColor = .clear
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
        get { return closeButton.currentTitleColor }
        set { closeButton.setTitleColor(newValue, for: .normal) }
    }
    
    internal var imageHeightConstraint: NSLayoutConstraint?
    
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
        
        if let closeButtonColor = notification.closeButtonColor{
            closeButton.setTitleColor(closeButtonColor, for: .normal)
        }
        
        var constraints = [NSLayoutConstraint]()

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addSubview(closeButton)
        
        
        
        if notification.type == .image_button || notification.type == .full_image {
            imageView.allEdges(to: self)
            
        } else if notification.type == .image_text_button {
            addSubview(titleLabel)
            addSubview(messageLabel)
            imageView.allEdges(to: self, excluding: .bottom)
            titleLabel.topToBottom(of: imageView, offset: 10.0)
            messageLabel.topToBottom(of: titleLabel, offset: 8.0)
            messageLabel.bottom(to: self, offset: -10.0)
            titleLabel.centerX(to: self)
            messageLabel.centerX(to: self)

        } else if notification.type == .nps {
            addSubview(titleLabel)
            addSubview(messageLabel)
            addSubview(npsView)
            
            imageView.allEdges(to: self, excluding: .bottom)
            titleLabel.topToBottom(of: imageView, offset: 10.0)
            messageLabel.topToBottom(of: titleLabel, offset: 8.0)
            npsView.topToBottom(of: messageLabel, offset: 10.0)
            npsView.bottom(to: self, offset: -10.0)
            titleLabel.centerX(to: self)
            messageLabel.centerX(to: self)
            npsView.centerX(to: self)
            
        } else if notification.type == .smile_rating {
            addSubview(titleLabel)
            addSubview(messageLabel)
            addSubview(sliderStepRating)
            
            imageView.allEdges(to: self, excluding: .bottom)
            titleLabel.topToBottom(of: imageView, offset: 10.0)
            messageLabel.topToBottom(of: titleLabel, offset: 8.0)
            sliderStepRating.topToBottom(of: messageLabel, offset: 10.0)
            sliderStepRating.bottom(to: self, offset: -30.0)
            
            titleLabel.centerX(to: self)
            messageLabel.centerX(to: self)
            sliderStepRating.centerX(to: self)
            
            sliderStepRating.leading(to: self, offset: 20.0)
            sliderStepRating.trailing(to: self, offset: -20.0)
            
        } else if notification.type == .email_form {
            imageView.removeFromSuperview()
            addSubview(titleLabel)
            addSubview(messageLabel)
            addSubview(emailTF)
            addSubview(termsLabel)
            addSubview(checkbox)
            addSubview(self.resultLabel)
            
            resultLabel.isHidden = true
            messageLabel.textAlignment = .natural
            titleLabel.top(to: self, offset: 50)
            messageLabel.topToBottom(of: titleLabel, offset: 10)
            emailTF.topToBottom(of: messageLabel, offset: 20)
            checkbox.topToBottom(of: emailTF, offset: 20)
            termsLabel.centerY(to: checkbox)
            resultLabel.topToBottom(of: checkbox, offset: 10.0)
            checkbox.bottom(to: self, offset: -80)
            
            checkbox.size(CGSize(width: 20, height: 20))
        
            checkbox.leading(to: self, offset: 20)
            termsLabel.leadingToTrailing(of: checkbox, offset: 10)
            titleLabel.leading(to: self, offset: 20)
            messageLabel.leading(to: titleLabel)
            messageLabel.trailing(to: self, offset: -20)
            emailTF.leading(to: self, offset: 20)
            emailTF.trailing(to: self, offset: -20.0)
            resultLabel.leading(to: self.checkbox)

            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
            self.addGestureRecognizer(tapGesture)
            
        
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
        } else {
            addSubview(titleLabel)
            addSubview(messageLabel)
            
            imageView.allEdges(to: self, excluding: .bottom)
            titleLabel.topToBottom(of: imageView, offset: 8.0)
            messageLabel.topToBottom(of: titleLabel, offset: 8.0)
            messageLabel.bottom(to: self, offset: -10.0)
        }
        
        imageHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0, constant: 0)
        
        if let imageHeightConstraint = imageHeightConstraint {
            constraints.append(imageHeightConstraint)
        }
        
        closeButton.trailing(to: self, offset: -10.0)
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        emailTF.resignFirstResponder()
    }
    
}

//MARK:- SliderStepDelegate
extension VisilabsPopupDialogDefaultView: SliderStepDelegate {
    func didSelectedValue(sliderStep: VisilabsSliderStep, value: Float) {
        sliderStep.value = value
    }
}

//Email form extension
extension VisilabsPopupDialogDefaultView {
    
    func sendEmailButtonTapped() {
        
        guard let notification = visilabsInAppNotification else { return }
        DispatchQueue.main.async {
            if self.checkbox.isChecked {
                self.resultLabel.text = notification.successMessage
                self.resultLabel.textColor = .green
            } else {
                self.resultLabel.text = notification.failMessage
                self.resultLabel.textColor = .red
            }
            self.resultLabel.isHidden = false
        }
    }
}


extension VisilabsPopupDialogDefaultView: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTF.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if let view = getTopView() {
                if view.frame.origin.y == 0 {
                    view.frame.origin.y -= keyboardSize.height
                }
            }
            
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let view = getTopView() {
            if view.frame.origin.y != 0 {
                view.frame.origin.y = 0
            }
        }
    }
    
    func getTopView() -> UIView? {
        var topView: UIView?
        let window = UIApplication.shared.keyWindow
        if window != nil {
            for subview in window?.subviews ?? [] {
                if !subview.isHidden && subview.alpha > 0 && subview.frame.size.width > 0 && subview.frame.size.height > 0 {
                    topView = subview
                }
            }
        }
        return topView
    }
}


