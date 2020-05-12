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

}
