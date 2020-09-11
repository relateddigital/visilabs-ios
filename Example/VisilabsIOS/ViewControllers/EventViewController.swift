//
//  EventViewController.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 22.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Eureka
import CleanyModal
import VisilabsIOS
import Euromsg

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
    case addToFavorites = "Add to Favorites"
    case removeFromFavorites = "Remove from Favorites"
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
        section.append(TextRow("exVisitorId") {
            $0.title = "exVisitorId"
            $0.value = visilabsProfile.userKey
            $0.cell.textField.autocapitalizationType = .none
        })
        section.append(TextRow("email") {
            $0.title = "email"
            $0.value = visilabsProfile.userEmail
            $0.cell.textField.autocapitalizationType = .none
        })
        
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
    
    private func showModal(title: String, message: String){
        let styleSettings = CleanyAlertConfig.getDefaultStyleSettings()
        styleSettings[.cornerRadius] = 18
        let alertViewController = CleanyAlertViewController(title: title, message: message, preferredStyle: .alert, styleSettings: styleSettings)
        alertViewController.addAction(title: "Dismiss", style: .default)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    private func getRandomProductValues() -> (productCode1: Int, productCode2: Int, productPrice1: Double, productPrice2: Double, productQuantity1: Int, productQuantity2: Int, inventory: Int, basketID: Int, orderID: Int, categoryId: Int, numberOfSearchResults: Int, bannerCode: Int) {
        let randomProductCode1 = Int.random(min: 1, max: 1000)
        let randomProductCode2 = Int.random(min: 1, max: 1000, except: [randomProductCode1])
        let randomProductPrice1 = Double.random(in: 10..<10000)
        let randomProductPrice2 = Double.random(in: 10..<10000)
        let randomProductQuantity1 = Int.random(min: 1, max: 10)
        let randomProductQuantity2 = Int.random(min: 1, max: 10)
        let randomInventory = Int.random(min: 1, max: 100)
        let randomBasketID = Int.random(min: 1, max: 10000)
        let randomOrderID = Int.random(min: 1, max: 10000)
        let randomCategoryID = Int.random(min: 1, max: 100)
        let randomNumberOfSearchResults = Int.random(min: 1, max: 100)
        let randomBannerCode = Int.random(min: 1, max: 100)
        return (randomProductCode1, randomProductCode2, randomProductPrice1, randomProductPrice2, randomProductQuantity1, randomProductQuantity2, randomInventory, randomBasketID, randomOrderID, randomCategoryID, randomNumberOfSearchResults, randomBannerCode)
    }
    
    //TODO: favorites'lerde price göndermek gerekiyor mu?
    private func customEvent(_ eventType: VisilabsEventType){
        let exVisitorId: String = ((self.form.rowBy(tag: "exVisitorId") as TextRow?)!.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email: String = ((self.form.rowBy(tag: "email") as TextRow?)!.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var properties = [String:String]()
        let randomValues = getRandomProductValues()
        switch eventType {
        case .login, .signUp:
            properties["OM.sys.TokenID"] = visilabsProfile.appToken //"Token ID to use for push messages"
            properties["OM.sys.AppID"] = visilabsProfile.appAlias // "App ID to use for push messages"
            if exVisitorId.isEmpty {
                self.showModal(title: "Warning", message: "exVisitorId can not be empty")
                return
            } else {
                visilabsProfile.userKey = exVisitorId
                visilabsProfile.userEmail = email
                DataManager.saveVisilabsProfile(visilabsProfile)
                if eventType == .login {
                    Visilabs.callAPI().login(exVisitorId: visilabsProfile.userKey, properties: properties)
                }
                if eventType == .signUp {
                    Visilabs.callAPI().signUp(exVisitorId: visilabsProfile.userKey, properties: properties)
                }
                Euromsg.setEuroUserId(userKey: visilabsProfile.userKey)
                Euromsg.setEmail(email: visilabsProfile.userEmail, permission: true)
                return
            }
        case .pageView:
            Visilabs.callAPI().customEvent("Page Name", properties: [String:String]())
            return
        case .productView:
            properties["OM.pv"] = "\(randomValues.productCode1)" // Product Code
            properties["OM.pn"] = "Name-\(randomValues.productCode1)" //Product Name
            properties["OM.ppr"] = randomValues.productPrice1.formatPrice() // Product Price
            properties["OM.pv.1"] = "Brand" //Product Brand
            properties["OM.inv"] = "\(randomValues.inventory)" //Number of items in stock
            Visilabs.callAPI().customEvent("Product View", properties: properties)
            return
        case .productAddToCart:
            properties["OM.pbid"] = "\(randomValues.basketID)" // Basket ID
            properties["OM.pb"] = "\(randomValues.productCode1);\(randomValues.productCode2)" //Product1 Code;Product2 Code
            properties["OM.pu"] = "\(randomValues.productQuantity1);\(randomValues.productQuantity2)" // Product1 Quantity;Product2 Quantity
            properties["OM.ppr"] = "\((randomValues.productPrice1 * Double(randomValues.productQuantity1)).formatPrice());\((randomValues.productPrice2 * Double(randomValues.productQuantity2)).formatPrice())" // Product1 Price*Product1 Quantity;Product2 Price*Product2 Quantity
            Visilabs.callAPI().customEvent("Cart", properties: properties)
            return
        case .productPurchase:
            properties["OM.tid"] = "\(randomValues.orderID)" // Order ID
            properties["OM.pp"] = "\(randomValues.productCode1);\(randomValues.productCode2)" //Product1 Code;Product2 Code
            properties["OM.pu"] = "\(randomValues.productQuantity1);\(randomValues.productQuantity2)" // Product1 Quantity;Product2 Quantity
            properties["OM.ppr"] = "\((randomValues.productPrice1 * Double(randomValues.productQuantity1)).formatPrice());\((randomValues.productPrice2 * Double(randomValues.productQuantity2)).formatPrice())" // Product1 Price*Product1 Quantity;Product2 Price*Product2 Quantity
            Visilabs.callAPI().customEvent("Purchase", properties: properties)
            return
        case .productCategoryPageView:
            properties["OM.clist"] = "\(randomValues.categoryId)" // Category Code/Category ID
            Visilabs.callAPI().customEvent("Category View", properties: properties)
            return
        case .inAppSearch:
            properties["OM.OSS"] = "laptop" // Search Keyword
            properties["OM.OSSR"] = "\(randomValues.numberOfSearchResults)" // Number of Search Results
            Visilabs.callAPI().customEvent("In App Search", properties: properties)
            return
        case .bannerClick:
            properties["OM.OSB"] = "\(randomValues.bannerCode)" // Banner Name/Banner Code
            Visilabs.callAPI().customEvent("Banner Click", properties: properties)
            return
        case .addToFavorites:
            properties["OM.pf"] = "\(randomValues.productCode1)" // Product Code
            properties["OM.pfu"] = "1"
            properties["OM.ppr"] = randomValues.productPrice1.formatPrice() // Product Price
            Visilabs.callAPI().customEvent("Add To Favorites", properties: properties)
            return
        case .removeFromFavorites:
            properties["OM.pf"] = "\(randomValues.productCode1)" // Product Code
            properties["OM.pfu"] = "-1"
            properties["OM.ppr"] = randomValues.productPrice1.formatPrice() // Product Price
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
