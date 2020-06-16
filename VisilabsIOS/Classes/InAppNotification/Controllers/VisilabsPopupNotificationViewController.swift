//
//  VisilabsPopupNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import Foundation
import UIKit

class VisilabsPopupNotificationViewController: VisilabsBaseNotificationViewController {
    
    /// First init flag
    fileprivate var initialized = false
    
    /// StatusBar display related
    fileprivate let hideStatusBar: Bool
    fileprivate var statusBarShouldBeHidden: Bool = false
    
    /// Width for iPad displays
    fileprivate let preferredWidth: CGFloat

    /// The completion handler
    fileprivate var completion: (() -> Void)?
    
    /// The custom transition presentation manager
    fileprivate var presentationManager: VisilabsPresentationManager!

    /// Interactor class for pan gesture dismissal
    fileprivate lazy var interactor = VisilabsInteractiveTransition()

    /// Returns the controllers view
    internal var popupContainerView: VisilabsPopupDialogContainerView {
        return view as! VisilabsPopupDialogContainerView // swiftlint:disable:this force_cast
    }
    
    /// The set of buttons
    fileprivate var buttons = [VisilabsPopupDialogButton]()

    /// Whether keyboard has shifted view
    internal var keyboardShown = false

    /// Keyboard height
    internal var keyboardHeight: CGFloat?

    // MARK: Public

    /// The content view of the popup dialog
    public var viewController: UIViewController

    /// Whether or not to shift view for keyboard display
    public var keyboardShiftsView = true
    
    // MARK: - Initializers
    
    
    override func hide(animated: Bool, completion: @escaping () -> Void) {
        completion()
    }
 
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        self.dismiss(animated: true) {
            self.delegate?.notificationShouldDismiss(controller: self, callToActionURL: self.notification.callToActionUrl, shouldTrack: true, additionalTrackingProperties: nil)
        }
    }

    public convenience init(notification: VisilabsInAppNotification) {
        
        let viewController = VisilabsDefaultPopupNotificationViewController(visilabsInAppNotification: notification)
        self.init(viewController: viewController, buttonAlignment: .vertical, transitionStyle: .zoomIn, preferredWidth: 580, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false)
        super.notification = notification
        if notification.type != .full_image {
            let button = VisilabsPopupDialogButton(title: notification.buttonText!, font: notification.buttonTextFont, action: {self.delegate?.notificationShouldDismiss(controller: self,
                callToActionURL: notification.callToActionUrl,
                shouldTrack: true,
                additionalTrackingProperties: nil)})
            addButton(button)
        }else {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            self.popupContainerView.stackView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        /*
        if notification.type == .image_button {
            let viewController = VisilabsDefaultPopupNotificationViewController(visilabsInAppNotificationType: notification.type)
            if let image = notification.image {
                viewController.image = UIImage(data: image)
            }
            self.init(viewController: viewController, buttonAlignment: .vertical, transitionStyle: .zoomIn, preferredWidth: 580, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false)
            let button = VisilabsPopupDialogButton(title: notification.buttonText!, action: nil)
            addButton(button)
            
        }else if notification.type == .image_text_button {
            let viewController = VisilabsDefaultPopupNotificationViewController(visilabsInAppNotificationType: notification.type)
            if let image = notification.image {
                viewController.image = UIImage(data: image)
            }
            self.init(viewController: viewController, buttonAlignment: .vertical, transitionStyle: .zoomIn, preferredWidth: 580, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false)
            let button = VisilabsPopupDialogButton(title: notification.buttonText!, action: nil)
            addButton(button)
            
        }
        
        else{
            self.init(viewController: VisilabsDefaultPopupNotificationViewController(),
            buttonAlignment: .vertical,
            transitionStyle: .zoomIn,
            preferredWidth: 580,
            tapGestureDismissal: false,
            panGestureDismissal: false,
            hideStatusBar: false)
        }
 */
        
        /*
        if notification.type == .nps {
            viewController
        }
        
        
        else{
            var viewController = VisilabsDefaultPopupNotificationViewController()
            viewController.titleText   = notification.messageTitle
            viewController.messageText = notification.messageTitle
            viewController.image       = image
        }
         */
        
        
    }
    
    
    /*!
     Creates a standard popup dialog with title, message and image field

     - parameter title:            The dialog title
     - parameter message:          The dialog message
     - parameter image:            The dialog image
     - parameter buttonAlignment:  The dialog button alignment
     - parameter transitionStyle:  The dialog transition style
     - parameter preferredWidth:   The preferred width for iPad screens
     - parameter tapGestureDismissal: Indicates if dialog can be dismissed via tap gesture
     - parameter panGestureDismissal: Indicates if dialog can be dismissed via pan gesture
     - parameter hideStatusBar:    Whether to hide the status bar on PopupDialog presentation
     - parameter completion:       Completion block invoked when dialog was dismissed

     - returns: Popup dialog default style
     */
    /*
    @objc public convenience init(
                title: String?,
                message: String?,
                image: UIImage? = nil,
                buttonAlignment: NSLayoutConstraint.Axis = .vertical,
                transitionStyle: PopupDialogTransitionStyle = .bounceUp,
                preferredWidth: CGFloat = 340,
                tapGestureDismissal: Bool = true,
                panGestureDismissal: Bool = true,
                hideStatusBar: Bool = false,
                completion: (() -> Void)? = nil) {

        // Create and configure the standard popup dialog view
        let viewController = VisilabsDefaultPopupNotificationViewController()
        viewController.titleText   = title
        viewController.messageText = message
        viewController.image       = image

        // Call designated initializer
        self.init(viewController: viewController,
                  buttonAlignment: buttonAlignment,
                  transitionStyle: transitionStyle,
                  preferredWidth: preferredWidth,
                  tapGestureDismissal: tapGestureDismissal,
                  panGestureDismissal: panGestureDismissal,
                  hideStatusBar: hideStatusBar,
                  completion: completion)
    }
    */

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
    @objc public init(
        viewController: UIViewController,
        buttonAlignment: NSLayoutConstraint.Axis = .vertical,
        transitionStyle: PopupDialogTransitionStyle = .bounceUp,
        preferredWidth: CGFloat = 340,
        tapGestureDismissal: Bool = true,
        panGestureDismissal: Bool = true,
        hideStatusBar: Bool = false,
        completion: (() -> Void)? = nil) {

        self.viewController = viewController
        self.preferredWidth = preferredWidth
        self.hideStatusBar = hideStatusBar
        self.completion = completion
        super.init(nibName: nil, bundle: nil)

        // Init the presentation manager
        presentationManager = VisilabsPresentationManager(transitionStyle: transitionStyle, interactor: interactor)

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
            let panRecognizer = UIPanGestureRecognizer(target: interactor, action: #selector(VisilabsInteractiveTransition.handlePan))
            panRecognizer.cancelsTouchesInView = false
            popupContainerView.stackView.addGestureRecognizer(panRecognizer)
        }
    }

    // Init with coder not implemented
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    /// Replaces controller view with popup view
    public override func loadView() {
        view = VisilabsPopupDialogContainerView(frame: UIScreen.main.bounds, preferredWidth: preferredWidth)
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
        self.dismiss(animated: true) {
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
    @objc public func addButton(_ button: VisilabsPopupDialogButton) {
        buttons.append(button)
    }

    /*!
     Adds an array of PopupDialogButtons to the Popup dialog
     - parameter buttons: A list of PopupDialogButton instances
     */
    @objc public func addButtons(_ buttons: [VisilabsPopupDialogButton]) {
        self.buttons += buttons
    }

    /// Calls the action closure of the button instance tapped
    @objc fileprivate func buttonTapped(_ button: VisilabsPopupDialogButton) {
        if button.dismissOnTap {
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
        self.init(notification: notification, nameOfClass: String(describing: VisilabsPopupNotificationViewController.self))
    }
    */
    
    
}

// MARK: - View proxy values

extension VisilabsPopupNotificationViewController {

    /// The button alignment of the alert dialog
    @objc public var buttonAlignment: NSLayoutConstraint.Axis {
        get {
            return popupContainerView.buttonStackView.axis
        }
        set {
            popupContainerView.buttonStackView .axis = newValue
            popupContainerView.pv_layoutIfNeededAnimated()
        }
    }

    /// The transition style
    @objc public var transitionStyle: PopupDialogTransitionStyle {
        get { return presentationManager.transitionStyle }
        set { presentationManager.transitionStyle = newValue }
    }
}

// MARK: - Shake

extension VisilabsPopupNotificationViewController {
    
    /// Performs a shake animation on the dialog
    @objc public func shake() {
        popupContainerView.pv_shake()
    }
}

/// This extension is designed to handle dialog positioning
/// if a keyboard is displayed while the popup is on top
internal extension VisilabsPopupNotificationViewController {

    // MARK: - Keyboard & orientation observers

    /*! Add obserservers for UIKeyboard notifications */
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged),
                                                         name: UIDevice.orientationDidChangeNotification,
                                                         object: nil)

        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(keyboardWillShow),
                                                         name: UIResponder.keyboardWillShowNotification,
                                                         object: nil)

        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(keyboardWillHide),
                                                         name: UIResponder.keyboardWillHideNotification,
                                                         object: nil)

        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(keyboardWillChangeFrame),
                                                         name: UIResponder.keyboardWillChangeFrameNotification,
                                                         object: nil)
    }

    /*! Remove observers */
    func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                            name: UIDevice.orientationDidChangeNotification,
                                                            object: nil)

        NotificationCenter.default.removeObserver(self,
                                                            name: UIResponder.keyboardWillShowNotification,
                                                            object: nil)

        NotificationCenter.default.removeObserver(self,
                                                            name: UIResponder.keyboardWillHideNotification,
                                                            object: nil)

        NotificationCenter.default.removeObserver(self,
                                                            name: UIResponder.keyboardWillChangeFrameNotification,
                                                            object: nil)
    }

    // MARK: - Actions

    /*!
     Keyboard will show notification listener
     - parameter notification: NSNotification
     */
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        guard isTopAndVisible else { return }
        keyboardShown = true
        centerPopup()
    }

    /*!
     Keyboard will hide notification listener
     - parameter notification: NSNotification
     */
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        guard isTopAndVisible else { return }
        keyboardShown = false
        centerPopup()
    }

    /*!
     Keyboard will change frame notification listener
     - parameter notification: NSNotification
     */
    @objc fileprivate func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardRect = (notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        keyboardHeight = keyboardRect.cgRectValue.height
    }

    /*!
     Listen to orientation changes
     - parameter notification: NSNotification
     */
    @objc fileprivate func orientationChanged(_ notification: Notification) {
        if keyboardShown { centerPopup() }
    }

    fileprivate func centerPopup() {

        // Make sure keyboard should reposition on keayboard notifications
        guard keyboardShiftsView else { return }

        // Make sure a valid keyboard height is available
        guard let keyboardHeight = keyboardHeight else { return }

        // Calculate new center of shadow background
        let popupCenter =  keyboardShown ? keyboardHeight / -2 : 0

        // Reposition and animate
        popupContainerView.centerYConstraint?.constant = popupCenter
        popupContainerView.pv_layoutIfNeededAnimated()
    }
}
