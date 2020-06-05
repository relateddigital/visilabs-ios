//
//  EventViewController.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 22.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Eureka


import UIKit
import VisilabsIOS

enum VisilabsEventType : String, CaseIterable {
    case login = "Login"
    case signUp  = "Sign Up"
    case pageView = "Page View"
    case productView = "Product View"
}

class EventViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }
    
    
    
    
    private func initializeForm() {
    
        /*
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right

        }
*/
        form
        
        +++ getCommonEventsSection()
        
        +++ getInAppSection()
        
    }
    
    
    private func getCommonEventsSection() -> Section{
        let section = Section("Common Events")
        for eventType in VisilabsEventType.allCases {
            section.append(ButtonRow() {
                $0.title = eventType.rawValue
            }
            .onCellSelection { cell, row in
                self.customEvent(eventType)
            })
        }
        return section
    }
    
    private func  getInAppSection() -> Section{
        let section = Section("In App Notification Types")
        for visilabsInAppNotificationType in VisilabsInAppNotificationType.allCases {
            section.append(ButtonRow() {
                $0.title = visilabsInAppNotificationType.rawValue
            }
            .onCellSelection { cell, row in
                self.inAppEvent(visilabsInAppNotificationType)
            })
        }
        return section
    }
    
    private func inAppEvent(_ visilabsInAppNotificationType: VisilabsInAppNotificationType){
        var properties = [String:String]()
        properties["OM.inapptype"] = visilabsInAppNotificationType.rawValue
        Visilabs.callAPI().customEvent("InAppTest", properties: properties)
    }
    
    
    private func customEvent(_ eventType: VisilabsEventType){
        switch eventType {
        case .login:
            var properties = [String:String]()
            properties["OM.sys.TokenID"] = "Token ID to use for push messages"
            properties["OM.sys.AppID"] = "App ID to use for push messages"
            Visilabs.callAPI().login(exVisitorId: "userId", properties: properties)
            return
        case .signUp:
            var properties = [String:String]()
            properties["OM.sys.TokenID"] = "Token ID to use for push messages"
            properties["OM.sys.AppID"] = "App ID to use for push messages"
            Visilabs.callAPI().signUp(exVisitorId: "userId", properties: properties)
            return
        case .pageView:
            Visilabs.callAPI().customEvent("Page Name", properties: [String:String]())
            return
        case .productView:
            var properties = [String:String]()
            properties["OM.pv"] = "Product Code"
            properties["OM.pn"] = "Product Name"
            properties["OM.ppr"] = "Product Price"
            properties["OM.pv.1"] = "Product Brand"
            properties["OM.ppr"] = "Product Price"
            properties["OM.inv"] = "Number of items in stock"
            Visilabs.callAPI().customEvent("Product View", properties: properties)
            return
        default:
            return
        }
    }
    

}
