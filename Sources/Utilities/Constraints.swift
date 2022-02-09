//
//  Constraints.swift
//  VisilabsIOS
//
//  Created by Said Alır on 15.10.2020.
//

import Foundation
import UIKit

//TODO: public'i kaldır
public enum ConstraintRelation: Int {
    case equal = 0
    case equalOrLess = -1
    case equalOrGreater = 1
}

internal extension Collection where Iterator.Element == Constraint {

    func activate() {

        if let constraints = self as? Constraints {
            Constraint.activate(constraints)
        }
    }

    func deActivate() {

        if let constraints = self as? Constraints {
            Constraint.deactivate(constraints)
        }
    }
}

internal extension Constraint {
    @objc
    func with(_ priority: LayoutPriority) -> Self {
        self.priority = priority
        return self
    }

    func set(_ active: Bool) -> Self {
        isActive = active
        return self
    }
}
