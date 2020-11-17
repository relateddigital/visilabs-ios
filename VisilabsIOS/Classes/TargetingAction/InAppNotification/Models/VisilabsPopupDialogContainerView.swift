//
//  VisilabsPopupDialogContainerView.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import Foundation
import UIKit

/// The main view of the popup dialog
final public class VisilabsPopupDialogContainerView: UIView {

    // MARK: - Appearance

    /// The background color of the popup dialog
    override public dynamic var backgroundColor: UIColor? {
        get { return container.backgroundColor }
        set { container.backgroundColor = newValue }
    }

    /// The corner radius of the popup view
    @objc public dynamic var cornerRadius: Float {
        get { return Float(shadowContainer.layer.cornerRadius) }
        set {
            let radius = CGFloat(newValue)
            shadowContainer.layer.cornerRadius = radius
            container.layer.cornerRadius = radius
        }
    }

    // MARK: Shadow related

    /// Enable / disable shadow rendering of the container
    @objc public dynamic var shadowEnabled: Bool {
        get { return shadowContainer.layer.shadowRadius > 0 }
        set { shadowContainer.layer.shadowRadius = newValue ? shadowRadius : 0 }
    }

    /// Color of the container shadow
    @objc public dynamic var shadowColor: UIColor? {
        get {
            guard let color = shadowContainer.layer.shadowColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set { shadowContainer.layer.shadowColor = newValue?.cgColor }
    }

    /// Radius of the container shadow
    @objc public dynamic var shadowRadius: CGFloat {
        get { return shadowContainer.layer.shadowRadius }
        set { shadowContainer.layer.shadowRadius = newValue }
    }

    /// Opacity of the the container shadow
    @objc public dynamic var shadowOpacity: Float {
        get { return shadowContainer.layer.shadowOpacity }
        set { shadowContainer.layer.shadowOpacity = newValue }
    }

    /// Offset of the the container shadow
    @objc public dynamic var shadowOffset: CGSize {
        get { return shadowContainer.layer.shadowOffset }
        set { shadowContainer.layer.shadowOffset = newValue }
    }

    /// Path of the the container shadow
    @objc public dynamic var shadowPath: CGPath? {
        get { return shadowContainer.layer.shadowPath}
        set { shadowContainer.layer.shadowPath = newValue }
    }

    // MARK: - Views

    /// The shadow container is the basic view of the PopupDialog
    /// As it does not clip subviews, a shadow can be applied to it
    internal lazy var shadowContainer: UIView = {
        let shadowContainer = UIView(frame: .zero)
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        shadowContainer.backgroundColor = UIColor.clear
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowRadius = 5
        shadowContainer.layer.shadowOpacity = 0.4
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowContainer.layer.cornerRadius = 4
        return shadowContainer
    }()

    /// The container view is a child of shadowContainer and contains
    /// all other views. It clips to bounds so cornerRadius can be set
    internal lazy var container: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white
        container.clipsToBounds = true
        container.layer.cornerRadius = 4
        return container
    }()

    // The container stack view for buttons
    internal lazy var buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 0
        return buttonStackView
    }()

    // The main stack view, containing all relevant views
    internal lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.buttonStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    // The preferred width for iPads
    fileprivate let preferredWidth: CGFloat

    // MARK: - Constraints

    /// The center constraint of the shadow container
    internal var centerYConstraint: NSLayoutConstraint?

    // MARK: - Initializers

    internal init(frame: CGRect, preferredWidth: CGFloat) {
        self.preferredWidth = preferredWidth
        super.init(frame: frame)
        setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    internal func setupViews() {

        // Add views
        addSubview(shadowContainer)
        shadowContainer.addSubview(container)
        container.addSubview(stackView)

        // Layout views
        var constraints = [NSLayoutConstraint]()

        // Shadow container constraints
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            shadowContainer.width(preferredWidth)
            shadowContainer.leading(to: self, offset: 40.0, relation: .equalOrGreater, priority: .required)
            shadowContainer.trailing(to: self, offset: -40.0, relation: .equalOrLess, priority: .required)
        } else {
            shadowContainer.width(300, relation: .equalOrGreater)
            shadowContainer.width(340, relation: .equalOrLess)
            shadowContainer.leading(to: self, offset: 10, relation: .equalOrGreater)
            shadowContainer.trailing(to: self, offset: -10, relation: .equalOrLess)
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

        container.allEdges(to: shadowContainer)
        stackView.allEdges(to: container)

        // Activate constraints
        NSLayoutConstraint.activate(constraints)
    }
}
