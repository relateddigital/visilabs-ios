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

//TODO: public'i kaldır
public typealias LayoutPriority = UILayoutPriority

internal typealias EdgeInsets = UIEdgeInsets

//TODO: public'i kaldır
public typealias Constraint = NSLayoutConstraint

//TODO: public'i kaldır
public typealias Constraints = [Constraint]

extension UIView: Constrainable {

    //TODO: public'i kaldır
    @discardableResult
    public func prepareForLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

extension LayoutGuide: Constrainable {
    //TODO: public'i kaldır
    @discardableResult
    public func prepareForLayout() -> Self { return self }
}

//TODO: public'i kaldır
public protocol Constrainable {
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

//TODO: public'i kaldır
public enum Edge {
    case top
    case leading
    case trailing
    case bottom
}
