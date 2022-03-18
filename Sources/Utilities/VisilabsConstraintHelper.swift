//
//  VisilabsConstraintHelper.swift
//  constraintApp
//
//  Created by Said Alır on 15.10.2020.
//

import Foundation
import UIKit

//TODO: public'i kaldır
public extension Constrainable {

    // MARK: - SIZE FUNCTIONS
    @discardableResult
    internal func size(_ size: CGSize,
              relation: ConstraintRelation = .equal,
              priority: LayoutPriority = .required,
              isActive: Bool = true) -> Constraints {
        prepareForLayout()

        let constraints = [
            width(size.width, relation: relation, priority: priority, isActive: isActive),
            height(size.height, relation: relation, priority: priority, isActive: isActive)
        ]

        return constraints
    }

    @discardableResult
    func size(to view: Constrainable,
              multiplier: CGFloat = 1,
              insets: CGSize = .zero,
              relation: ConstraintRelation = .equal,
              priority: LayoutPriority = .required,
              isActive: Bool = true) -> Constraints {
        prepareForLayout()

        let constraints = [
            width(to: view, multiplier: multiplier,
                  offset: insets.width,
                  relation: relation,
                  priority: priority,
                  isActive: isActive),

            height(to: view,
                   multiplier: multiplier,
                   offset: insets.height,
                   relation: relation,
                   priority: priority,
                   isActive: isActive)
        ]

        return constraints
    }

    @discardableResult
    func width(_ width: CGFloat,
               relation: ConstraintRelation = .equal,
               priority: LayoutPriority = .required,
               isActive: Bool = true) -> Constraint {
        prepareForLayout()

        switch relation {
        case .equal: return widthAnchor.constraint(equalToConstant: width).with(priority).set(isActive)
        case .equalOrLess: return widthAnchor.constraint(lessThanOrEqualToConstant: width).with(priority).set(isActive)
        case .equalOrGreater:
            return widthAnchor.constraint(greaterThanOrEqualToConstant: width).with(priority).set(isActive)
        }
    }

    @discardableResult
    func width(to view: Constrainable,
               _ dimension: NSLayoutDimension? = nil,
               multiplier: CGFloat = 1,
               offset: CGFloat = 0,
               relation: ConstraintRelation = .equal,
               priority: LayoutPriority = .required,
               isActive: Bool = true) -> Constraint {
        prepareForLayout()

        switch relation {
        case .equal:
            return widthAnchor.constraint(equalTo: dimension ?? view.widthAnchor,
                                          multiplier: multiplier, constant: offset).with(priority).set(isActive)
        case .equalOrLess:
            return widthAnchor.constraint(lessThanOrEqualTo: dimension ?? view.widthAnchor,
                                          multiplier: multiplier, constant: offset).with(priority).set(isActive)
        case .equalOrGreater:
            return widthAnchor.constraint(greaterThanOrEqualTo: dimension ?? view.widthAnchor,
                                          multiplier: multiplier, constant: offset).with(priority).set(isActive)
        }
    }

    @discardableResult
        func height(_ height: CGFloat,
                    relation: ConstraintRelation = .equal,
                    priority: LayoutPriority = .required,
                    isActive: Bool = true) -> Constraint {
            prepareForLayout()

            switch relation {
            case .equal:
                return heightAnchor.constraint(equalToConstant: height).with(priority).set(isActive)
            case .equalOrLess:
                return heightAnchor.constraint(lessThanOrEqualToConstant: height).with(priority).set(isActive)
            case .equalOrGreater:
                return heightAnchor.constraint(greaterThanOrEqualToConstant: height).with(priority).set(isActive)
            }
        }

        @discardableResult
        func height(to view: Constrainable,
                    _ dimension: NSLayoutDimension? = nil,
                    multiplier: CGFloat = 1,
                    offset: CGFloat = 0,
                    relation: ConstraintRelation = .equal,
                    priority: LayoutPriority = .required,
                    isActive: Bool = true) -> Constraint {
            prepareForLayout()

            switch relation {
            case .equal:
                return heightAnchor.constraint(equalTo: dimension ?? view.heightAnchor,
                                               multiplier: multiplier,
                                               constant: offset).with(priority).set(isActive)
            case .equalOrLess:
                return heightAnchor.constraint(lessThanOrEqualTo: dimension ?? view.heightAnchor,
                                               multiplier: multiplier,
                                               constant: offset).with(priority).set(isActive)
            case .equalOrGreater:
                return heightAnchor.constraint(greaterThanOrEqualTo: dimension ?? view.heightAnchor,
                                               multiplier: multiplier,
                                               constant: offset).with(priority).set(isActive)
            }
        }

    // MARK: - LEADING/TRAILING FUNCTIONS
    @discardableResult
    func leading(to view: Constrainable,
                    _ anchor: NSLayoutXAxisAnchor? = nil,
                    offset: CGFloat = 0,
                    relation: ConstraintRelation = .equal,
                    priority: LayoutPriority = .required,
                    isActive: Bool = true) -> Constraint {
           prepareForLayout()

           switch relation {
           case .equal:
            return leadingAnchor.constraint(equalTo: anchor ?? view.leadingAnchor,
                                            constant: offset).with(priority).set(isActive)
           case .equalOrLess:
            return leadingAnchor.constraint(lessThanOrEqualTo: anchor ?? view.leadingAnchor,
                                            constant: offset).with(priority).set(isActive)
           case .equalOrGreater:
            return leadingAnchor.constraint(greaterThanOrEqualTo: anchor ?? view.leadingAnchor,
                                            constant: offset).with(priority).set(isActive)
           }
       }

    //TODO: public'i kaldır
    @discardableResult
    func trailing(to view: Constrainable,
                      _ anchor: NSLayoutXAxisAnchor? = nil,
                      offset: CGFloat = 0,
                      relation: ConstraintRelation = .equal,
                      priority: LayoutPriority = .required,
                      isActive: Bool = true) -> Constraint {
            prepareForLayout()

            switch relation {
            case .equal:
                return trailingAnchor.constraint(equalTo: anchor ?? view.trailingAnchor,
                                                 constant: offset).with(priority).set(isActive)
            case .equalOrLess:
                return trailingAnchor.constraint(lessThanOrEqualTo: anchor ?? view.trailingAnchor,
                                                 constant: offset).with(priority).set(isActive)
            case .equalOrGreater:
                return trailingAnchor.constraint(greaterThanOrEqualTo: anchor ?? view.trailingAnchor,
                                                 constant: offset).with(priority).set(isActive)
            }
        }

    @discardableResult
        func trailingToLeading(of view: Constrainable,
                               offset: CGFloat = 0,
                               relation: ConstraintRelation = .equal,
                               priority: LayoutPriority = .required,
                               isActive: Bool = true) -> Constraint {
            prepareForLayout()

            return trailing(to: view,
                            view.leadingAnchor,
                            offset: offset,
                            relation: relation,
                            priority: priority,
                            isActive: isActive)
        }

    @discardableResult
        func leadingToTrailing(of view: Constrainable,
                               offset: CGFloat = 0,
                               relation: ConstraintRelation = .equal,
                               priority: LayoutPriority = .required,
                               isActive: Bool = true) -> Constraint {
            prepareForLayout()
            return leading(to: view,
                           view.trailingAnchor,
                           offset: offset,
                           relation: relation,
                           priority: priority,
                           isActive: isActive)
        }

    // MARK: - TOP AND BOTTOM
    @discardableResult
        func top(to view: Constrainable,
                 _ anchor: NSLayoutYAxisAnchor? = nil,
                 offset: CGFloat = 0,
                 relation: ConstraintRelation = .equal,
                 priority: LayoutPriority = .required,
                 isActive: Bool = true) -> Constraint {
            prepareForLayout()

            switch relation {
            case .equal:
                return topAnchor.constraint(equalTo: anchor ?? view.topAnchor,
                                            constant: offset).with(priority).set(isActive)
            case .equalOrLess:
                return topAnchor.constraint(lessThanOrEqualTo: anchor ?? view.topAnchor,
                                            constant: offset).with(priority).set(isActive)
            case .equalOrGreater:
                return topAnchor.constraint(greaterThanOrEqualTo: anchor ?? view.topAnchor,
                                            constant: offset).with(priority).set(isActive)
            }
        }

    @discardableResult
       func bottom(to view: Constrainable,
                   _ anchor: NSLayoutYAxisAnchor? = nil,
                   offset: CGFloat = 0,
                   relation: ConstraintRelation = .equal,
                   priority: LayoutPriority = .required,
                   isActive: Bool = true) -> Constraint {
           prepareForLayout()

           switch relation {
           case .equal:
            return bottomAnchor.constraint(equalTo: anchor ?? view.bottomAnchor,
                                           constant: offset).with(priority).set(isActive)
           case .equalOrLess:
            return bottomAnchor.constraint(lessThanOrEqualTo: anchor ?? view.bottomAnchor,
                                           constant: offset).with(priority).set(isActive)
           case .equalOrGreater:
            return bottomAnchor.constraint(greaterThanOrEqualTo: anchor ?? view.bottomAnchor,
                                           constant: offset).with(priority).set(isActive)
           }
       }

    @discardableResult
        func bottomToTop(of view: Constrainable,
                         offset: CGFloat = 0,
                         relation: ConstraintRelation = .equal,
                         priority: LayoutPriority = .required,
                         isActive: Bool = true) -> Constraint {
            prepareForLayout()
            return bottom(to: view,
                          view.topAnchor,
                          offset: offset,
                          relation: relation, priority: priority, isActive: isActive)
        }

    @discardableResult
        func topToBottom(of view: Constrainable,
                         offset: CGFloat = 0,
                         relation: ConstraintRelation = .equal,
                         priority: LayoutPriority = .required,
                         isActive: Bool = true) -> Constraint {
            prepareForLayout()
            return top(to: view,
                       view.bottomAnchor,
                       offset: offset,
                       relation: relation,
                       priority: priority,
                       isActive: isActive)
        }

    // MARK: - ALIGNMENT
    @discardableResult
    func centerX(to view: Constrainable,
                 _ anchor: NSLayoutXAxisAnchor? = nil,
                 multiplier: CGFloat = 1,
                 offset: CGFloat = 0,
                 priority: LayoutPriority = .required,
                 isActive: Bool = true) -> Constraint {
            prepareForLayout()

            let constraint: Constraint

            if let anchor = anchor {
                constraint = centerXAnchor.constraint(equalTo: anchor, constant: offset).with(priority)
            } else {
                constraint = NSLayoutConstraint(item: self,
                                                attribute: .centerX,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .centerX,
                                                multiplier: multiplier,
                                                constant: offset).with(priority)
            }

            constraint.isActive = isActive
            return constraint
        }

    @discardableResult
    func centerY(to view: Constrainable,
                 _ anchor: NSLayoutYAxisAnchor? = nil,
                 multiplier: CGFloat = 1,
                 offset: CGFloat = 0,
                 priority: LayoutPriority = .required,
                 isActive: Bool = true) -> Constraint {
        prepareForLayout()

        let constraint: Constraint

        if let anchor = anchor {
            constraint = centerYAnchor.constraint(equalTo: anchor, constant: offset).with(priority)
        } else {
            constraint = NSLayoutConstraint(item: self,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .centerY,
                                            multiplier: multiplier,
                                            constant: offset).with(priority)
        }

        constraint.isActive = isActive
        return constraint
    }

    @discardableResult
    func center(in view: Constrainable,
                offset: CGPoint = .zero,
                priority: LayoutPriority = .required,
                isActive: Bool = true) -> Constraints {
        prepareForLayout()

        let constraints = [
            centerX(to: view, offset: offset.x, priority: priority, isActive: isActive),
            centerY(to: view, offset: offset.y, priority: priority, isActive: isActive)
        ]

        return constraints
    }

//    Wrapper
    func allEdges(to view: Constrainable, excluding: Edge? = nil) {
        prepareForLayout()

        if excluding != .top {
            top(to: view)
        }

        if excluding != .bottom {
            bottom(to: view)
        }

        if excluding != . leading {
            leading(to: view)
        }

        if excluding != .trailing {
            trailing(to: view)
        }
    }

}
