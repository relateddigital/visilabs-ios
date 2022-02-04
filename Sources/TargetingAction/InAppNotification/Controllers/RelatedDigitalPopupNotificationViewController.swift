//
//  VisilabsPopupNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import Foundation
import UIKit

class RelatedDigitalPopupNotificationViewController: RelatedDigitalBaseNotificationViewController {
    /// First init flag
    fileprivate var initialized = false
    weak var visilabsInAppNotification: RelatedDigitalInAppNotification?

    /// StatusBar display related
    fileprivate let hideStatusBar: Bool
    fileprivate var statusBarShouldBeHidden: Bool = false

    /// Width for iPad displays
    fileprivate let preferredWidth: CGFloat

    /// The completion handler
    fileprivate var completion: (() -> Void)?

    /// The custom transition presentation manager
    fileprivate var presentationManager: RelatedDigitalPresentationManager!

    /// Interactor class for pan gesture dismissal
    fileprivate lazy var interactor = RelatedDigitalInteractiveTransition()

    /// Returns the controllers view
    internal var popupContainerView: RelatedDigitalPopupDialogContainerView {
        return view as! RelatedDigitalPopupDialogContainerView // swiftlint:disable:this force_cast
    }

    /// The set of buttons
    fileprivate var buttons = [RelatedDigitalPopupDialogButton]()

    fileprivate var closeButton: UIButton!

    // MARK: Public

    /// The content view of the popup dialog
    public var viewController: RelatedDigitalDefaultPopupNotificationViewController

    // MARK: - Initializers

    override func hide(animated: Bool, completion: @escaping () -> Void) {
        dismiss(animated: true)
        completion()
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        dismiss(animated: true) {
            self.delegate?.notificationShouldDismiss(controller: self,
                                                     callToActionURL: self.notification?.callToActionUrl,
                                                     shouldTrack: true,
                                                     additionalTrackingProperties: nil)
        }
    }
    @objc func closeButtonTapped(tapGestureRecognizer: UITapGestureRecognizer) {
    
        if let closeButtonActionType = visilabsInAppNotification?.closePopupActionType {
            if closeButtonActionType == "closebutton" || closeButtonActionType == "all"  {
                dismiss(animated: true) {
                    self.delegate?.notificationShouldDismiss(controller: self,
                                                             callToActionURL: nil,
                                                             shouldTrack: false,
                                                             additionalTrackingProperties: nil)
                }
            }
        } else {
            dismiss(animated: true) {
                self.delegate?.notificationShouldDismiss(controller: self,
                                                         callToActionURL: nil,
                                                         shouldTrack: false,
                                                         additionalTrackingProperties: nil)
            }
        }
    }

    func changeCloseButtonConstraints() {

    }

    fileprivate func initForInAppNotification(_ viewController: RelatedDigitalDefaultPopupNotificationViewController) {
        guard let notification = self.notification else { return }
        if notification.type == .secondNps {
            let button = RelatedDigitalPopupDialogButton(title: notification.buttonText!,
                                                   font: notification.buttonTextFont,
                                                   buttonTextColor: notification.buttonTextColor,
                                                   buttonColor: notification.buttonColor,
                                                   action: openSecondPopup)
            button.isEnabled = false
            addButton(button)
        } else if notification.type != .fullImage && notification.type != .imageButtonImage {

            let button = RelatedDigitalPopupDialogButton(title: notification.buttonText!,
                                                   font: notification.buttonTextFont,
                                                   buttonTextColor: notification.buttonTextColor,
                                                   buttonColor: notification.buttonColor, action: commonButtonAction)
            if notification.type == .npsWithNumbers ||
                notification.type == .nps {
                button.isEnabled = false
            }
            addButton(button)
        } else {
            if notification.type != .imageButtonImage {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                  action: #selector(imageTapped(tapGestureRecognizer:)))
                viewController.standardView.imageView.isUserInteractionEnabled = true
                viewController.standardView.imageView.addGestureRecognizer(tapGestureRecognizer)
            }
        }
    }

    func commonButtonAction() {
        guard let notification = self.notification else { return }
        var returnCallback = true
        var additionalTrackingProperties = [String: String]()
        if notification.type == .smileRating {
            additionalTrackingProperties["OM.s_point"]
                = String(Int(viewController.standardView.sliderStepRating.value))
            additionalTrackingProperties["OM.s_cat"] = notification.type.rawValue
            additionalTrackingProperties["OM.s_page"] = "act-\(notification.actId)"
        } else if notification.type == .nps {
            additionalTrackingProperties["OM.s_point"]
                = String(viewController.standardView.npsView.rating).replacingOccurrences(of: ",",
                                                                                          with: ".")
            additionalTrackingProperties["OM.s_cat"] = notification.type.rawValue
            additionalTrackingProperties["OM.s_page"] = "act-\(notification.actId)"
        } else if notification.type == .npsWithNumbers {
            if let num = viewController.standardView.selectedNumber {
                additionalTrackingProperties["OM.s_point"] = "\(num)"
            }
            additionalTrackingProperties["OM.s_cat"] = notification.type.rawValue
            additionalTrackingProperties["OM.s_page"] = "act-\(notification.actId)"
        } else if notification.previousPopupPoint != nil {
            additionalTrackingProperties["OM.s_point"] = String(notification.previousPopupPoint ?? 0.0)
            additionalTrackingProperties["OM.s_cat"] = "nps_with_secondpopup"
            additionalTrackingProperties["OM.s_feed"]  = viewController.standardView.feedbackTF.text ?? ""
            additionalTrackingProperties["OM.s_page"] = "act-\(notification.actId)"
        } else if notification.type == .secondNps { // works iff second popup wont show
            let threshold = Double(self.notification?.secondPopupMinPoint ?? "3.0") ?? 3.0
            let userRating = viewController.standardView.npsView.rating
            if userRating >= threshold {
                additionalTrackingProperties["OM.s_point"] = String(notification.previousPopupPoint ?? 0.0)
                additionalTrackingProperties["OM.s_cat"] = notification.type.rawValue
                additionalTrackingProperties["OM.s_page"] = "act-\(notification.actId)"
            }
        }
        // Check if second popup coming
        var callToActionURL: URL? = notification.callToActionUrl
        if notification.type == .secondNps {
            callToActionURL = nil
            returnCallback = false
        }
        self.delegate?.notificationShouldDismiss(controller: self,
                                                 callToActionURL: callToActionURL,
                                                 shouldTrack: true,
                                                 additionalTrackingProperties: additionalTrackingProperties)
        
        if returnCallback {
            self.inappButtonDelegate?.didTapButton(notification)
        }
    }

    fileprivate func initForEmailForm(_ viewController: RelatedDigitalDefaultPopupNotificationViewController) {
        guard let mailForm = self.mailForm else { return }

        let button = RelatedDigitalPopupDialogButton(title: mailForm.buttonTitle,
                                                font: mailForm.buttonFont,
                                                   buttonTextColor: mailForm.buttonTextColor,
                                                   buttonColor: mailForm.buttonColor, action: nil)
        addButton(button)

    }

    fileprivate func initForScratchToWin(_ viewController: RelatedDigitalDefaultPopupNotificationViewController) {
        viewController.standardView.delegate = self
    }

    public convenience init(notification: RelatedDigitalInAppNotification? = nil,
                            mailForm: MailSubscriptionViewModel? = nil,
                            scratchToWin: ScratchToWinModel? = nil) {

        let viewController = RelatedDigitalDefaultPopupNotificationViewController(visilabsInAppNotification: notification,
                                                                            emailForm: mailForm,
                                                                            scratchToWin: scratchToWin)
        self.init(notification: notification,
                  mailForm: mailForm,
                  scratchToWin: scratchToWin,
                  viewController: viewController,
                  buttonAlignment: .vertical,
                  transitionStyle: .zoomIn,
                  preferredWidth: 580,
                  tapGestureDismissal: false,
                  panGestureDismissal: false,
                  hideStatusBar: false)
        initForInAppNotification(viewController)
        initForEmailForm(viewController)
        initForScratchToWin(viewController)
        self.visilabsInAppNotification = notification
        let closeTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                        action: #selector(closeButtonTapped(tapGestureRecognizer:)))
        viewController.standardView.closeButton.isUserInteractionEnabled = true
        viewController.standardView.closeButton.addGestureRecognizer(closeTapGestureRecognizer)
        viewController.standardView.imgButtonDelegate = self
        viewController.standardView.npsDelegate = self
    }

    /*!
     Creates a popup dialog containing a custom view

     - parameter viewController:   A custom view controller to be displayed
     - parameter buttonAlignment:  The dialog button alignment
     - parameter transitionStyle:  The dialog transition style
     - parameter preferredWidth:   The preferred width for iPad screens
     - parameter tapGestureDismissal: Indicates if dialog can be dismissed via tap gesture
     - parameter panGestureDismissal: Indicates if dialog can be dismissed via pan gesture
     - parameter hideStatusBar:    Whether to hide the status bar on PopupDialog presentation
     - parameter completion:       Completion block invoked when dialog was dismissed

     - returns: Popup dialog with a custom view controller
     */
    public init(
        notification: RelatedDigitalInAppNotification?,
        mailForm: MailSubscriptionViewModel?,
        scratchToWin: ScratchToWinModel?,
        viewController: UIViewController,
        buttonAlignment: NSLayoutConstraint.Axis = .vertical,
        transitionStyle: PopupDialogTransitionStyle = .bounceUp,
        preferredWidth: CGFloat = 340,
        tapGestureDismissal: Bool = true,
        panGestureDismissal: Bool = true,
        hideStatusBar: Bool = false,
        completion: (() -> Void)? = nil) {

        self.viewController = viewController as? RelatedDigitalDefaultPopupNotificationViewController
            ?? RelatedDigitalDefaultPopupNotificationViewController()
        self.preferredWidth = preferredWidth
        self.hideStatusBar = hideStatusBar
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        self.notification = notification
        self.mailForm = mailForm
        self.scratchToWin = scratchToWin
        // Init the presentation manager
        presentationManager = RelatedDigitalPresentationManager(transitionStyle: transitionStyle, interactor: interactor)
        popupContainerView.buttonStackView.accessibilityIdentifier = "buttonStack"

        // Assign the interactor view controller
        interactor.viewController = self

        // Define presentation styles
        transitioningDelegate = presentationManager
        modalPresentationStyle = .custom

        // StatusBar setup
        modalPresentationCapturesStatusBarAppearance = true

        // Add our custom view to the container
        addChild(viewController)
        popupContainerView.stackView.insertArrangedSubview(viewController.view, at: 0)
        popupContainerView.buttonStackView.axis = buttonAlignment
        viewController.didMove(toParent: self)

        // Allow for dialog dismissal on background tap
        if tapGestureDismissal {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tapRecognizer.cancelsTouchesInView = false
            popupContainerView.addGestureRecognizer(tapRecognizer)
        }
        // Allow for dialog dismissal on dialog pan gesture
        if panGestureDismissal {
            let panRecognizer = UIPanGestureRecognizer(target: interactor,
                                                       action: #selector(RelatedDigitalInteractiveTransition.handlePan))
            panRecognizer.cancelsTouchesInView = false
            popupContainerView.stackView.addGestureRecognizer(panRecognizer)
        }
        
        // addCloseButton()
    }

    func openSecondPopup() {
        commonButtonAction()
        guard let type = self.notification?.secondPopupType else { return }
        var not: RelatedDigitalInAppNotification?
        switch type {
        case .feedback:
            let threshold = Double(self.notification?.secondPopupMinPoint ?? "3.0") ?? 3.0
            let userRating = viewController.standardView.npsView.rating
            if userRating < threshold {
                not = createSecondPopup()
            }
        default:
            not = createSecondPopup()
        }
        if let n = not {
            RelatedDigital.callAPI().showNotification(n)
        }
    }

    // Init with coder not implemented
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    /// Replaces controller view with popup view
    public override func loadView() {
        view = RelatedDigitalPopupDialogContainerView(frame: UIScreen.main.bounds, preferredWidth: preferredWidth)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()

        guard !initialized else { return }
        appendButtons()
        initialized = true
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        statusBarShouldBeHidden = hideStatusBar
        UIView.animate(withDuration: 0.15) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }

    deinit {
        completion?()
        completion = nil
    }

    // MARK: - Dismissal related

    @objc fileprivate func handleTap(_ sender: UITapGestureRecognizer) {
        // Make sure it's not a tap on the dialog but the background
        let point = sender.location(in: popupContainerView.stackView)
        guard !popupContainerView.stackView.point(inside: point, with: nil) else { return }
        dismiss()
    }

    /*!
     Dismisses the popup dialog
     */
    @objc public func dismiss(_ completion: (() -> Void)? = nil) {
        dismiss(animated: true) {
            completion?()
        }
    }

    // MARK: - Button related

    /*!
     Appends the buttons added to the popup dialog
     to the placeholder stack view
     */
    fileprivate func appendButtons() {
        // Add action to buttons
        let stackView = popupContainerView.stackView
        let buttonStackView = popupContainerView.buttonStackView
        if buttons.isEmpty {
            stackView.removeArrangedSubview(popupContainerView.buttonStackView)
        }

        for (index, button) in buttons.enumerated() {
            button.needsLeftSeparator = buttonStackView.axis == .horizontal && index > 0
            buttonStackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    }

    /*!
     Adds a single PopupDialogButton to the Popup dialog
     - parameter button: A PopupDialogButton instance
     */
    @objc public func addButton(_ button: RelatedDigitalPopupDialogButton) {
        buttons.append(button)
    }

    /*!
     Adds an array of PopupDialogButtons to the Popup dialog
     - parameter buttons: A list of PopupDialogButton instances
     */
    @objc public func addButtons(_ buttons: [RelatedDigitalPopupDialogButton]) {
        self.buttons += buttons
    }

    /// Calls the action closure of the button instance tapped
    @objc fileprivate func buttonTapped(_ button: RelatedDigitalPopupDialogButton) {
        if self.mailForm != nil {
            let defaultView = viewController.standardView
            let first = defaultView.firstCheckBox.isChecked
            var second = true
            if defaultView.consentCheckboxAdded {
                second = defaultView.secondCheckBox.isChecked
            }
            let mail = defaultView.emailTF.text ?? ""

            DispatchQueue.main.async {
                if !RelatedDigitalHelper.checkEmail(email: mail) {// If mail is not valid
                    defaultView.resultLabel.text = self.mailForm?.invalidEmailMessage
                    defaultView.resultLabel.isHidden = false
                } else if first && second {// Mail valid and checkbox are checked
                    defaultView.resultLabel.text = self.mailForm?.successMessage ?? "Succesful!"
                    defaultView.resultLabel.textColor = .systemGreen
                    defaultView.resultLabel.isHidden = false
                    RelatedDigital.callAPI().subscribeMail(click: self.mailForm!.report.click,
                                                     actid: "\(self.mailForm!.actId)",
                                                     auth: self.mailForm!.auth,
                                                     mail: mail)
                    self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: false, additionalTrackingProperties: [String: String]())
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.dismiss()
                    }
                } else {// Mail is valid checkboxes are not checked
                    defaultView.resultLabel.text = self.mailForm?.checkConsentMessage ?? ""
                    defaultView.resultLabel.isHidden = false
                }
            }
        } else if button.dismissOnTap {
            dismiss({ button.buttonAction?() })
        } else {
            button.buttonAction?()
        }
    }

    /*!
     Simulates a button tap for the given index
     Makes testing a breeze
     - parameter index: The index of the button to tap
     */
    public func tapButtonWithIndex(_ index: Int) {
        let button = buttons[index]
        button.buttonAction?()
    }

    // MARK: - StatusBar display related

    public override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    /*
     convenience init(notification: VisilabsInAppNotification) {
         self.init(notification: notification,
     nameOfClass: String(describing: VisilabsPopupNotificationViewController.self))
     }
     */
}

// MARK: - View proxy values

extension RelatedDigitalPopupNotificationViewController {
    /// The button alignment of the alert dialog
    @objc public var buttonAlignment: NSLayoutConstraint.Axis {
        get {
            return popupContainerView.buttonStackView.axis
        }
        set {
            popupContainerView.buttonStackView.axis = newValue
            popupContainerView.pv_layoutIfNeededAnimated()
        }
    }

    /// The transition style
    @objc public var transitionStyle: PopupDialogTransitionStyle {
        get { return presentationManager.transitionStyle }
        set { presentationManager.transitionStyle = newValue }
    }
}

/// This extension is designed to handle dialog positioning
/// if a keyboard is displayed while the popup is on top
internal extension RelatedDigitalPopupNotificationViewController {
    // MARK: - Keyboard & orientation observers

    /*! Add obserservers for UIKeyboard notifications */
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    /*! Remove observers */
    func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
    }

    // MARK: - Actions

    /*!
     Listen to orientation changes
     - parameter notification: NSNotification
     */
    @objc fileprivate func orientationChanged(_ notification: Notification) {

    }
    // Creates a second popup with first popup properties
    func createSecondPopup() -> RelatedDigitalInAppNotification? {
        if let not = self.notification {
            let point = viewController.standardView.npsView.rating
            var promo: String?
            if not.secondPopupType == .imageTextButton {
                promo = not.promotionCode
            }
            var closeButtonColor = "FFFFFF"
            if not.closeButtonColor == .black {
                closeButtonColor = "000000"
            }
            // Convert Second Type To First
            var type: RelatedDigitalInAppNotificationType = .imageTextButton
            switch not.secondPopupType {
            case .feedback:
                type = .feedbackForm
            case .imageButtonImage:
                type = .imageButtonImage
            default:
                type = .imageTextButton
            }
            return RelatedDigitalInAppNotification(actId: not.actId, type: type, messageTitle: not.secondPopupTitle, messageBody: not.secondPopupBody, buttonText: not.secondPopupButtonText, iosLink: not.iosLink, imageUrlString: not.secondImageUrlString1, visitorData: not.visitorData, visitData: not.visitData, queryString: not.queryString, messageTitleColor: not.messageTitleColor?.toHexString(), messageTitleTextSize: not.secondPopupBodyTextSize, messageBodyColor: not.messageBodyColor?.toHexString(), messageBodyTextSize: not.secondPopupBodyTextSize, fontFamily: not.fontFamily, customFont: not.customFont, closePopupActionType: not.closePopupActionType, backGround: not.backGroundColor?.toHexString(), closeButtonColor: closeButtonColor, buttonTextColor: not.buttonTextColor?.toHexString(), buttonColor: not.buttonColor?.toHexString(), alertType: "", closeButtonText: not.closeButtonText, promotionCode: promo, promotionTextColor: not.promotionTextColor?.toHexString(), promotionBackgroundColor: not.promotionBackgroundColor?.toHexString(), numberColors: nil, waitingTime: 0, secondPopupType: nil, secondPopupTitle: nil, secondPopupBody: nil, secondPopupBodyTextSize: nil, secondPopupButtonText: nil, secondImageUrlString1: nil, secondImageUrlString2: not.secondImageUrlString2, secondPopupMinPoint: nil, previousPopupPoint: point, position: .bottom)
        }
        return nil
    }

}
extension RelatedDigitalPopupNotificationViewController: ImageButtonImageDelegate {
    func imageButtonTapped() {
        self.commonButtonAction()
    }
}

extension UIColor {
    func toHexString() -> String {
        let components = self.cgColor.components
        guard let c = components, c.count > 3 else {
            return "FFFFFF"
        }
        let red: CGFloat = components?[0] ?? 0.0
        let green: CGFloat = components?[1] ?? 0.0
        let blue: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX",
                                    lroundf(Float(red * 255)),
                                    lroundf(Float(green * 255)),
                                    lroundf(Float(blue * 255)))
        return hexString
    }
}

extension RelatedDigitalPopupNotificationViewController: VisilabsPopupDialogDefaultViewDelegate {
    func viewExpanded() {
        guard let scratchTW = self.scratchToWin else { return }
        let button = RelatedDigitalPopupDialogButton(title: scratchTW.copyButtonText ?? "",
                                               font: scratchTW.copyButtonTextFont ?? .systemFont(ofSize: 20 ),
                                                   buttonTextColor: scratchTW.copyButtonTextColor,
                                                   buttonColor: scratchTW.copyButtonColor,
                                                   action: nil)
        addButton(button)
        appendButtons()

    }

    func dismissSctw() {
        guard let _ = self.scratchToWin else { return }
        self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: nil, shouldTrack: true, additionalTrackingProperties: nil)
    }
}

extension RelatedDigitalPopupNotificationViewController: NPSDelegate {
    
    func ratingSelected() {
        guard let button = self.buttons.first else { return }
        button.isEnabled = true
    }
    
    func ratingUnselected() {
        guard let button = self.buttons.first else { return }
        button.isEnabled = false
    }
    
    
}
