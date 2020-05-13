//
//  VisilabsBaseNotificationViewController.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.05.2020.
//

import Foundation


protocol VisilabsNotificationViewControllerDelegate {
    @discardableResult
    func notificationShouldDismiss(controller: VisilabsBaseNotificationViewController,
                                   callToActionURL: URL?,
                                   shouldTrack: Bool,
                                   additionalTrackingProperties: [String:String]?) -> Bool
}



class VisilabsBaseNotificationViewController: UIViewController {

    var notification: VisilabsInAppNotification!
    var delegate: VisilabsNotificationViewControllerDelegate?
    var window: UIWindow?
    var panStartPoint: CGPoint!
    
    convenience init(notification: VisilabsInAppNotification, nameOfClass: String) {
        // avoiding `type(of: self)` as it doesn't work with Swift 4.0.3 compiler
        // perhaps due to `self` not being fully constructed at this point
        let bundle = Bundle(for: VisilabsBaseNotificationViewController.self)
        self.init(nibName: nameOfClass, bundle: bundle)
        self.notification = notification
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }

    func show(animated: Bool) {}
    func hide(animated: Bool, completion: @escaping () -> Void) {}
    
}
