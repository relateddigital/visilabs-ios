//
//  UIViewController+Visibility.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import Foundation
import UIKit

// http://stackoverflow.com/questions/2777438/how-to-tell-if-uiviewcontrollers-view-is-visible
internal extension UIViewController {

    var isTopAndVisible: Bool {
        return isVisible && isTopViewController
    }

    var isVisible: Bool {
        if isViewLoaded {
            return view.window != nil
        }
        return false
    }

    var isTopViewController: Bool {
        if self.navigationController != nil {
            return self.navigationController?.visibleViewController === self
        } else if self.tabBarController != nil {
            return self.tabBarController?.selectedViewController == self && self.presentedViewController == nil
        } else {
            return self.presentedViewController == nil && self.isVisible
        }
    }
}
