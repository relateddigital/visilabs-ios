//
//  VisilabsPopupDialogDefaultView.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import Foundation
import UIKit

public class VisilabsPopupDialogDefaultView: UIView {

    // MARK: - VARIABLES

    internal lazy var closeButton = setCloseButton()
    internal lazy var imageView = setImageView()
    internal lazy var titleLabel = setTitleLabel()
    internal lazy var copyCodeTextButton = setCopyCodeText()
    internal lazy var copyCodeImageButton = setCopyCodeImage()
    internal lazy var messageLabel = setMessageLabel()
    internal lazy var npsView = setNpsView()

    internal lazy var emailTF = setEmailTF()
    internal lazy var firstCheckBox = setCheckbox()
    internal lazy var secondCheckBox = setCheckbox()

    internal lazy var termsButton = setTermsButton()
    internal lazy var consentButton = setConsentButton()
    
    internal lazy var resultLabel = setResultLabel()
    internal lazy var sliderStepRating = setSliderStepRating()
    internal lazy var numberRating = setNumberRating()
    internal var sctw: ScratchUIView!
    internal var sctwButton: VisilabsPopupDialogButton!
    
    var colors: [[CGColor]] = []
    var numberBgColor: UIColor = .black
    var numberBorderColor: UIColor = .white
    var selectedNumber: Int? = nil
    var expanded = false
    var delegate: VisilabsPopupDialogDefaultViewDelegate?

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
    var emailForm: MailSubscriptionViewModel?
    var scratchToWin: ScratchToWinModel?
    var consentCheckboxAdded = false
    // MARK: - CONSTRUCTOR
    init(frame: CGRect, visilabsInAppNotification: VisilabsInAppNotification?,
                        emailForm: MailSubscriptionViewModel? = nil,
                        scratchTW: ScratchToWinModel? = nil) {
        self.visilabsInAppNotification = visilabsInAppNotification
        self.emailForm = emailForm
        self.scratchToWin = scratchTW
        super.init(frame: frame)
        if self.visilabsInAppNotification != nil {
            setupViews()
        } else if self.emailForm != nil {
            setupInitialViewForEmailForm()
        } else {
            setupInitialForScratchToWin()
        }
    }
    
    func setupInitialViewForEmailForm() {
        guard let model = self.emailForm else { return }
        titleLabel.text = model.title.removeEscapingCharacters()
        titleLabel.font = model.titleFont
        titleLabel.textColor = model.titleColor

        messageLabel.text = model.message.removeEscapingCharacters()
        messageLabel.font = model.messageFont
        messageLabel.textColor = model.textColor

        closeButton.setTitleColor(model.closeButtonColor, for: .normal)
        self.backgroundColor = model.backgroundColor

        self.addSubview(imageView)
        self.addSubview(closeButton)

        var constraints = [NSLayoutConstraint]()
        imageHeightConstraint = NSLayoutConstraint(item: imageView,
            attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0, constant: 0)

        if let imageHeightConstraint = imageHeightConstraint {
            constraints.append(imageHeightConstraint)
        }

        closeButton.trailing(to: self, offset: -10.0)
        NSLayoutConstraint.activate(constraints)
        
        setupForEmailForm()
    }
    
    func setupInitialForScratchToWin() {
        guard let model = self.scratchToWin else { return }
        titleLabel.text = model.messageTitle?.removeEscapingCharacters()
        titleLabel.font = model.messageTitleFont
        titleLabel.textColor = model.messageTitleColor

        messageLabel.text = model.messageBody?.removeEscapingCharacters()
        messageLabel.font = model.messageBodyFont
        messageLabel.textColor = model.messageBodyColor

        closeButton.setTitleColor(model.closeButtonColor, for: .normal)
        self.backgroundColor = model.backGroundColor

        self.addSubview(closeButton)
        self.addSubview(titleLabel)
        self.addSubview(messageLabel)

        self.titleLabel.top(to: self, offset: 50)
        self.titleLabel.leading(to: self)
        self.titleLabel.trailing(to: self)
        self.titleLabel.height(20)
        self.messageLabel.topToBottom(of: titleLabel,offset: 10)
        self.messageLabel.leading(to: self)
        self.messageLabel.trailing(to: self)

        let frame = CGRect(x: 0, y: 0, width: 280.0, height: 50.0)
        let coupon = UIView(frame: frame)
        coupon.backgroundColor = .red

        let cpLabel = UILabel(frame: frame)
        cpLabel.text = "coupon code"
        cpLabel.textAlignment = .center
        cpLabel.textColor = .white
        coupon.addSubview(cpLabel)

        let couponImg = coupon.asImage()

        let maskView = UIView(frame: frame)
        maskView.backgroundColor = .darkGray
 
        let maskImg = maskView.asImage()
        
        self.sctw = ScratchUIView(frame: frame, couponImage: couponImg, maskImage: maskImg, scratchWidth: 20.0)
        sctw.delegate = self
        self.addSubview(sctw)

        sctw.topToBottom(of: messageLabel, offset: 20)
        sctw.leading(to: self, offset: 10)
        sctw.trailing(to: self, offset: -10)
        sctw.height(50.0)    
        
        sctwButton = VisilabsPopupDialogButton(title: "Save & Scratch",
                                               font: model.buttonTextFont,
                                               buttonTextColor: model.buttonTextColor,
                                               buttonColor: model.buttonColor, action: nil)
        sctwButton.addTarget(self, action: #selector(collapseSctw), for: .touchDown)
        
        sctw.isUserInteractionEnabled = false
        addSubview(sctwButton)
        sctwButton.height(50.0)
        sctwButton.allEdges(to: self, excluding: .top)

        addSubview(firstCheckBox)
        addSubview(secondCheckBox)
        addSubview(emailTF)
        addSubview(termsButton)
        addSubview(consentButton)

        emailTF.topToBottom(of: sctw, offset: 20)
        emailTF.leading(to: self, offset: 10)
        emailTF.trailing(to: self, offset: -10)
        emailTF.height(25)
        
        firstCheckBox.topToBottom(of: emailTF, offset: 10)
        firstCheckBox.leading(to: self, offset: 10)
        firstCheckBox.size(CGSize(width: 20, height: 20))
        termsButton.leadingToTrailing(of: firstCheckBox, offset: 10)
        termsButton.centerY(to: firstCheckBox)

        secondCheckBox.topToBottom(of: firstCheckBox, offset: 5)
        secondCheckBox.leading(to: self, offset: 10)
        secondCheckBox.size(CGSize(width: 20, height: 20))

        consentButton.leadingToTrailing(of: secondCheckBox, offset: 10)
        consentButton.centerY(to: secondCheckBox)

        termsButton.setTitle("terms button ", for: .normal)
        consentButton.setTitle("consent button", for: .normal)

        sctwButton.topToBottom(of: secondCheckBox, offset: 10)
        closeButton.trailing(to: self, offset: -10.0)
        NSLayoutConstraint.activate(constraints)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setupViews() {

        guard let notification = visilabsInAppNotification else {
            return
        }

        baseSetup(notification)

        var constraints = [NSLayoutConstraint]()

        switch notification.type {
        case .imageButton, .fullImage:
            imageView.allEdges(to: self)
        case .imageTextButton:
            setupForImageTextButton()
        case .nps:
            setupForNps()
        case .smileRating:
            setupForSmileRating()
        case .emailForm:
            setupForEmailForm()
        case .npsWithNumbers:
            setupForNpsWithNumbers()
        default:
            setupForDefault()
        }

        imageHeightConstraint = NSLayoutConstraint(item: imageView,
            attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0, constant: 0)

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

// MARK: - SliderStepDelegate
extension VisilabsPopupDialogDefaultView: SliderStepDelegate {
    func didSelectedValue(sliderStep: VisilabsSliderStep, value: Float) {
        sliderStep.value = value
    }
}

//Email form extension
extension VisilabsPopupDialogDefaultView {

    func sendEmailButtonTapped() {

    }

    @objc func termsButtonTapped(_ sender: UIButton) {
        guard let url = emailForm?.emailPermitUrl else { return }
        VisilabsInstance.sharedUIApplication()?.open(url, options: [:], completionHandler: nil)
    }
    
    @objc func copyCodeTextButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string = copyCodeTextButton.currentTitle
        VisilabsHelper.showCopiedClipboardMessage()
    }

    @objc func consentButtonTapped(_ sender: UIButton) {
        guard let url = emailForm?.consentUrl else { return }
        VisilabsInstance.sharedUIApplication()?.open(url, options: [:], completionHandler: nil)
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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                as? NSValue)?.cgRectValue {
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
                if !subview.isHidden && subview.alpha > 0
                    && subview.frame.size.width > 0
                    && subview.frame.size.height > 0 {
                    topView = subview
                }
            }
        }
        return topView
    }
    
    @objc func collapseSctw() {
        self.sctw.isUserInteractionEnabled = true
        emailTF.removeFromSuperview()
        termsButton.removeFromSuperview()
        consentButton.removeFromSuperview()
        firstCheckBox.removeFromSuperview()
        secondCheckBox.removeFromSuperview()
        sctwButton.removeFromSuperview()
        sctw.bottom(to: self, offset: -20)
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    @objc func expandSctw() {
        self.delegate?.viewExpanded()
    }
}

extension VisilabsPopupDialogDefaultView: ScratchUIViewDelegate {
    
    public func scratchMoved(_ view: ScratchUIView) {
        if !expanded && view.getScratchPercent() > 0.79 {
            expanded = true
            expandSctw()
        }
    }
}

protocol VisilabsPopupDialogDefaultViewDelegate {
    func viewExpanded()
}
