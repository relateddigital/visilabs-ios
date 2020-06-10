//
//  VisilabsPopupNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import Foundation


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
    
    
    
    
    
    
    convenience init(notification: VisilabsInAppNotification) {
        self.init(notification: notification, nameOfClass: String(describing: VisilabsPopupNotificationViewController.self))
    }
}
