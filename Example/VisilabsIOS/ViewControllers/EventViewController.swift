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

enum VisilabsEventType {
    case login
    case pageView
    case productView

    case mini
    case full
}

class EventViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }
    
    private func initializeForm() {
    
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right

        }

        form +++
        
        Section("Common Events")
            
            <<< ButtonRow() {
                $0.title = "Login"
            }
            .onCellSelection { cell, row in
                self.customEvent(.login)
            }

            <<< ButtonRow() {
                $0.title = "Page View"
            }
            .onCellSelection { cell, row in
                self.customEvent(.pageView)
            }
            
            <<< ButtonRow() {
                $0.title = "Product View"
            }
            .onCellSelection { cell, row in
                self.customEvent(.productView)
            }
        
        +++ Section("In App Notification Events")
            
            <<< ButtonRow() {
                $0.title = "Mini"
            }
            .onCellSelection { cell, row in
                self.customEvent(.mini)
            }
    }
    
    private func customEvent(_ eventType: VisilabsEventType){
        switch eventType {
            case .login:
                var properties = [String:String]()
                properties["OM.sys.TokenID"] = "Token ID to use for push messages"
                properties["OM.sys.AppID"] = "App ID to use for push messages"
                Visilabs.callAPI().login(exVisitorId: "userId", properties: properties)
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
            
            
            case .mini:
                var properties = [String:String]()
                properties["OM.inapptype"] = "mini"
                Visilabs.callAPI().customEvent("InAppTest", properties: properties)
                return
            case .full:
                var properties = [String:String]()
                properties["OM.inapptype"] = "full"
                Visilabs.callAPI().customEvent("InAppTest", properties: properties)
                return
            
            default:
                return
        }
    }
    

}
