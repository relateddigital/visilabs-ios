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
    case productAddToCart = "Product Add to Cart"
    case productPurchase = "Product Purchase"
    case productCategoryPageView = "Product Category Page View"
    case inAppSearch = "In App Search"
    case bannerClick = "Banner Click"
    case addToFavourites = "Add to Favourites"
    case removeFromFavourites = "Remove from Favourites"
    case sendingCampaignParameters = "Sending Campaign Parameters"
    case pushMessage = "Push Message"
}

class EventViewController: FormViewController {
    
    let inAppNotificationIds = ["mini": 139, "full": 140, "image_text_button": 153, "full_image": 154, "nps": 155, "image_button": 156, "smile_rating": 157]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }

    private func initializeForm() {
        form
        +++ getCommonEventsSection()
        +++ getInAppSection()
    }
    
    
    private func getCommonEventsSection() -> Section{
        let section = Section("Common Events".uppercased(with: Locale(identifier: "en_US")))
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
        let section = Section("In App Notification Types".uppercased(with: Locale(identifier: "en_US")))
        for visilabsInAppNotificationType in VisilabsInAppNotificationType.allCases {
            section.append(ButtonRow() {
                $0.title = visilabsInAppNotificationType.rawValue + " ID: " + String(inAppNotificationIds[visilabsInAppNotificationType.rawValue]!)
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
        var properties = [String:String]()
        switch eventType {
        case .login:
            properties["OM.sys.TokenID"] = visilabsProfile.appToken //"Token ID to use for push messages"
            properties["OM.sys.AppID"] = visilabsProfile.appAlias // "App ID to use for push messages"
            Visilabs.callAPI().login(exVisitorId: "egemen@visilab.com", properties: properties)
            return
        case .signUp:
            properties["OM.sys.TokenID"] = visilabsProfile.appToken //"Token ID to use for push messages"
            properties["OM.sys.AppID"] = visilabsProfile.appAlias //"App ID to use for push messages"
            Visilabs.callAPI().signUp(exVisitorId: "egemen@visilab.com", properties: properties)
            return
        case .pageView:
            Visilabs.callAPI().customEvent("Page Name", properties: [String:String]())
            return
        case .productView:
            properties["OM.pv"] = "Product Code"
            properties["OM.pn"] = "Product Name"
            properties["OM.ppr"] = "Product Price"
            properties["OM.pv.1"] = "Product Brand"
            properties["OM.ppr"] = "Product Price"
            properties["OM.inv"] = "Number of items in stock"
            Visilabs.callAPI().customEvent("Product View", properties: properties)
            return
        case .productAddToCart:
            properties["OM.pbid"] = "Basket ID"
            properties["OM.pb"] = "Product1 Code;Product2 Code"
            properties["OM.pu"] = "Product1 Quantity;Product2 Quantity"
            properties["OM.ppr"] = "Product1 Price*Product1 Quantity;Product2 Price*Product2 Quantity"
            Visilabs.callAPI().customEvent("Cart", properties: properties)
            return
        case .productPurchase:
            properties["OM.tid"] = "Order ID"
            properties["OM.pp"] = "Product1 Code;Product2 Code"
            properties["OM.pu"] = "Product1 Quantity;Product2 Quantity"
            properties["OM.ppr"] = "Product1 Price*Product1 Quantity;Product2 Price*Product2 Quantity"
            Visilabs.callAPI().customEvent("Purchase", properties: properties)
            return
        case .productCategoryPageView:
            properties["OM.clist"] = "Category Code/Category ID"
            Visilabs.callAPI().customEvent("Category View", properties: properties)
            return
        case .inAppSearch:
            properties["OM.oss"] = "Search Keyword"
            properties["OM.ossr"] = "Number of Search Results"
            Visilabs.callAPI().customEvent("In App Search", properties: properties)
            return
        case .bannerClick:
            properties["OM.OSB"] = "Banner Name/Banner Code"
            Visilabs.callAPI().customEvent("Banner Click", properties: properties)
            return
        case .addToFavourites:
            properties["OM.pf"] = "Product Code"
            properties["OM.pfu"] = "1"
            properties["OM.ppr"] = "Product Price"
            Visilabs.callAPI().customEvent("Add To Favorites", properties: properties)
            return
        case .removeFromFavourites:
            properties["OM.pf"] = "Product Code"
            properties["OM.pfu"] = "-1"
            properties["OM.ppr"] = "Product Price"
            Visilabs.callAPI().customEvent("Add To Favorites", properties: properties)
            return
        case .sendingCampaignParameters:
            properties["utm_source"] = "euromsg"
            properties["utm_medium"] = "push"
            properties["utm_campaign"] = "euromsg campaign"
            Visilabs.callAPI().customEvent("Login Page", properties: properties)
            return
        case .pushMessage:
            properties["OM.sys.TokenID"] = visilabsProfile.appToken //"Token ID to use for push messages"
            properties["OM.sys.AppID"] = visilabsProfile.appAlias // "App ID to use for push messages"
            Visilabs.callAPI().customEvent("RegisterToken", properties: properties)
            return
        }
        
    }
    

}
