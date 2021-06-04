//
//  ConstraintAbstraction.swift
//  VisilabsIOS
//
//  Created by Said Alır on 15.10.2020.
//

import Foundation
import UIKit

internal typealias LayoutGuide = UILayoutGuide
internal typealias ConstraintAxis = NSLayoutConstraint.Axis
internal typealias LayoutPriority = UILayoutPriority

internal typealias EdgeInsets = UIEdgeInsets

internal typealias Constraint = NSLayoutConstraint
internal typealias Constraints = [Constraint]

extension UIView: Constrainable {

    @discardableResult
    internal func prepareForLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

extension LayoutGuide: Constrainable {
    @discardableResult
    internal func prepareForLayout() -> Self { return self }
}

internal protocol Constrainable {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }

    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }

    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }

    @discardableResult
    func prepareForLayout() -> Self
}

internal enum Edge {
    case top
    case leading
    case trailing
    case bottom
}
