![IVisilabs Logo](/Screenshots/visilabs.png)


[![Build Status](https://travis-ci.org/relateddigital/visilabs-ios.svg)](https://travis-ci.org/relateddigital/visilabs-ios)
[![Version](https://img.shields.io/cocoapods/v/VisilabsIOS.svg?style=flat)](https://cocoapods.org/pods/VisilabsIOS)
[![License](https://img.shields.io/cocoapods/l/VisilabsIOS.svg?style=flat)](https://cocoapods.org/pods/VisilabsIOS)
[![Platform](https://img.shields.io/cocoapods/p/VisilabsIOS.svg?style=flat)](https://cocoapods.org/pods/VisilabsIOS)


# Table of Contents

- [Introduction](#introduction)
- [Example](#Example)
- [Installation](#Installation)
- [Usage](#Usage)
    - [Initializing](#Initializing)
        - [Initial Parameters](#Initial-Parameters])
        - [Debugging](#Debugging)
    - [Data Collection](#Data-Collection)
    - [Targeting Actions](#Targeting-Actions)
        - [In-App Messaging](#In-App-Messaging)
        - [Favorite Attribute Actions](#Favorite-Attribute-Actions)
        - [Geofencing](#Geofencing)
    - [Recommendation](#Recommendation)


# Introduction

This library is the official Swift SDK of Visilabs for native IOS projects. The library is written with Swift 5 and minimum deployment target is 10.

If you are using a lower version of Swift or minimum deployment target of your project is lower than 10, we recommend using **[Objective-C Library](https://github.com/visilabs/Visilabs-IOS )**.

# Example

To run the example project, clone the repo, and run `pod install` from the Example directory.

# Installation

VisilabsIOS is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'VisilabsIOS'
```

# Usage


## Initializing

Import VisilabsIOS in AppDelegate.swift and call  `createAPI` method within  `application:didFinishLaunchingWithOptions:`  method.

The code below is a sample initialization of Visilabs library.

```swift
import VisilabsIOS

func application(_ application: UIApplication, didFinishLaunchingWithOptions 
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Visilabs.createAPI(organizationId: "YOUR_ORGANIZATION_ID", profileId: "YOUR_PROFILE_ID"
        , dataSource: "YOUR_DATASOURCE", inAppNotificationsEnabled: false, channel: "IOS"
        , requestTimeoutInSeconds: 30, geofenceEnabled: false, maxGeofenceCount: 20)
        return true
    }                                        
```



### Initial Parameters

* **Mandatory Parameters**
    * **organizationId** : The ID of your organization. The value of this parameter could be obtained by https://intelligence.relateddigital.com/#Management/UserManagement/Profiles and selecting relevant profile.
    * **profileId** : The ID of the profile you want to integrate. The value of this parameter could be obtained by https://intelligence.relateddigital.com/#Management/UserManagement/Profiles and selecting relevant profile.
    * **dataSource** : The data source of the profile you want to integrate. The value of this parameter could be obtained by https://intelligence.relateddigital.com/#Management/UserManagement/Profiles and selecting relevant profile.
* **Optional Parameters**
    * **inAppNotificationsEnabled** : Default value is **false**. If you want to use in app notification feature of **Visilabs** you need to set the value to **true**. If you are not using in app notification feature of **Visilabs**, we recommend that you leave this value to **false** in terms of performance because in each event request, another request is sent to check whether there exists a notification for the relevant event.
    * **channel** : Default value is **"IOS"**. If you want to categorize the events of your IOS application under another different channel name in the **Analytics** section of the admin panel you may change this value.
    * **requestTimeoutInSeconds** : Default value is **30**. The request timeout value in seconds to send data to **Visilabs** servers and receive data from.
    * **geofenceEnabled** : Default value is **false**. If you want to use geofencing feature of **Visilabs** you need to set the value to **true**. If you are not using geofencing feature of **Visilabs**, we recommend that you leave this value to **false** in terms of performance and user experience because region monitoring would increase the battery consumption of your application and prompt users a popup dialog to allow location tracking.
    * **maxGeofenceCount** : Default value is **20**. **Apple** prevents any single application from monitoring more than 20 regions simultaneously. Visilabs can use all these slots. However if you need some of these slots for another use you can set this parameter to a value lower than **20**. Setting a value higher than 20 would not affect the maximum number of regions to be monitored. 


![Image of Profiles](/Screenshots/profiles-page.png)

![Image of Profile](/Screenshots/profile-page.png)


### Debugging

You can turn on logging by setting `loggingEnabled` property to `true`. If enabled the

```swift
Visilabs.callAPI().loggingEnabled = true                                      
```

The default protocol for requests to **Visilabs** servers is `https`. If you want to debug your requests more easily, you can change your protocol by setting `insecureProtocol` property to `true`. 

```swift
Visilabs.callAPI().insecureProtocol = true                                      
```

## Data Collection

Vislabs uses events to collect data from IOS applications. The developer needs to implement the methods provided by SDK. `customEvent`  is a generic method to track user events. `customEvent`  takes 2 parameters: pageName and properties.

* **pageName** : The current page of your application. If your event is not related to a page view, you should pass a value related to the event. If you pass an empty **String** the event would be considered invalid and discarded.
* **properties** : A collection of key/value pairs related to the event. If your event does not have additional data apart from page name, passing an empty dictionary acceptable.

In SDK, apart from `customEvent`, there are 2 other methods to collect data: `login` and `signUp`.  As in the `customEvent` method, the `login` and `signUp` methods also take a mandatory and an optional parameter. The first parameter is `exVisitorId`  which uniquely identifies the user and can not be empty. The second parameter `properties`  is optional and passsing an empty dictionary also valid.

Some of the most common events:

### Sign Up

```swift
Visilabs.callAPI().signUp(exVisitorId: "userId")
```

Moreover, you can pass additional information to the optional parameter `properties` when user signs up. The following example shows the call of `signUp` method with properties which includes `OM.sys.TokenID` and `OM.sys.AppID` parameters. `OM.sys.TokenID` and `OM.sys.AppID` are required to send push notifications and `OM.sys.AppID` parameter can be obtained by RMC web panel. 
//TODO: burada OM.sys.AppID'nin nasıl alınabileceğini daha detaylı açıkla.

```swift
var properties = [String:String]()
properties["OM.sys.TokenID"] = "F7C5231053E6EC543B8930FB440752E2FE41B2CFC2AA8F4E9C4843D347E6A847" // Token ID to use for push messages
properties["OM.sys.AppID"] = "VisilabsIOSExample" //App ID to use for push messages
Visilabs.callAPI().signUp(exVisitorId: "userId", properties: properties)
```

### Login

Like `signUp` method  `login` method can be called with or without optional parameter `properties`.


```swift
Visilabs.callAPI().login(exVisitorId: "userId")
```

```swift
var properties = [String:String]()
properties["OM.sys.TokenID"] = "F7C5231053E6EC543B8930FB440752E2FE41B2CFC2AA8F4E9C4843D347E6A847" // Token ID to use for push messages
properties["OM.sys.AppID"] = "VisilabsIOSExample" //App ID to use for push messages
Visilabs.callAPI().login(exVisitorId: "userId", properties: properties)
```

Moreover you can add user segment parameters  to `properties`.

```swift
var properties = [String:String]()
properties["OM.vseg1"] = "seg1val" // Visitor Segment 1
properties["OM.vseg2"] = "seg2val" // Visitor Segment 2
properties["OM.vseg3"] = "seg3val" // Visitor Segment 3
properties["OM.vseg4"] = "seg4val" // Visitor Segment 4
properties["OM.vseg5"] = "seg5val" // Visitor Segment 5
properties["OM.bd"] = "1977-03-15" // Birthday
properties["OM.gn"] = "f" // Gender
properties["OM.loc"] = "Bursa" // Location
Visilabs.callAPI().login(exVisitorId: "userId", properties: properties)
```

#### Page View

Use the following implementation of `customEvent`  method to record the page name the visitor is currently viewing. You may add extra parameters to properties dictionary or you may leave it empty.

```swift
Visilabs.callAPI().customEvent("Frequently Asked Questions" /*Page Name*/, properties: [String:String]())
```

#### Product View

Use the following implementation of `customEvent`  when the user displays a product in the mobile app.

```swift
var properties = [String:String]()
properties["OM.pv"] = "12345" // Product Code
properties["OM.pn"] = "USB Charger" // Product Name
properties["OM.ppr"] = 125.49" // Product Price
properties["OM.pv.1"] = "Sample Brand" // Product Brand
properties["OM.inv"] = "5" // Number of items in stock
Visilabs.callAPI().customEvent("Product View", properties: properties)
```

#### Add to Cart

Use the following implementation of `customEvent`  when the user adds items to the cart or removes.

```swift
var properties = [String:String]()
properties["OM.pbid"] = "bid-12345678" // Basket ID
properties["OM.pb"] = "12345;23456" // Product1 Code;Product2 Code
properties["OM.pu"] = "3;1" // Product1 Quantity;Product2 Quantity
properties["OM.ppr"] = "376.47;23.50" // Product1 Price*Product1 Quantity;Product2 Price*Product2 Quantity
Visilabs.callAPI().customEvent("Cart", properties: properties)
```

#### Product Purchase

Use the following implementation of `customEvent` when the user buys one or more items.

```swift
var properties = [String:String]()
properties["OM.tid"] = "oid-12345678" // Order ID/Transaction ID
properties["OM.pp"] = "12345;23456" // Product1 Code;Product2 Code
properties["OM.pu"] = "3;1" // Product1 Quantity;Product2 Quantity
properties["OM.ppr"] = "376.47;23.50" // Product1 Price*Product1 Quantity;Product2 Price*Product2 Quantity
Visilabs.callAPI().customEvent("Purchase", properties: properties)
```

#### Product Category Page View

When the user views a category list page, use the following implementation of `customEvent`.

```swift
var properties = [String:String]()
properties["OM.clist"] = "c-14" // Category Code/Category ID
Visilabs.callAPI().customEvent("Category View", properties: properties)
```

#### In App Search

If the mobile app has a search functionality available, use the following implementation of `customEvent`.

```swift
var properties = [String:String]()
properties["OM.OSS"] = "USB" // Search Keyword
properties["OM.OSSR"] = "61" // Number of Search Results
Visilabs.callAPI().customEvent("In App Search", properties: properties)
```

#### Banner Click

You can monitor banner click data using the following implementation of `customEvent`.

```swift
var properties = [String:String]()
properties["OM.OSB"] = "b-666" // Banner Name/Banner Code
Visilabs.callAPI().customEvent("Banner Click", properties: properties)
```

#### Add To Favorites

When the user adds a product to their favorites, use the following implementation of `customEvent`.

```swift
var properties = [String:String]()
properties["OM.pf"] = "12345" // Product Code
properties["OM.pfu"] = "1"
properties["OM.ppr"] = 125.49" // Product Price
Visilabs.callAPI().customEvent("Add To Favorites", properties: properties)
```

#### Remove from Favorites

When the user removes a product from their favorites, use the following implementation of `customEvent`.

```swift
var properties = [String:String]()
properties["OM.pf"] = "12345" // Product Code
properties["OM.pfu"] = "-1"
properties["OM.ppr"] = 125.49" // Product Price
Visilabs.callAPI().customEvent("Add To Favorites", properties: properties)
```

#### Sending Campaign Parameters

After launching the application by clicking on a push message, use the following implementation of `customEvent`.

```swift
var properties = [String:String]()
properties["utm_source"] = "euromsg" // utm_source value in the payload of push notification
properties["utm_medium"] = "push" // utm_medium value in the payload of push notification
properties["utm_campaign"] = "euromsg campaign" // utm_campaign value in the payload of push notification
Visilabs.callAPI().customEvent("Login", properties: properties)
```

#### Push Message Token Registration

Visilabs needs to receive token to send push messages to users. The token value generated by APNS will be the value of the `OM.sys.TokenID` key. The value of the `OM.sys.AppID`  could be obtained by RMC administration panel. Follow the link https://intelligence.relateddigital.com/a02/index#/Push/AppList and select the relevant push application. The value of  `App Alias` refers to `OM.sys.AppID`. If you have problems, please contact RMC support team. 

```swift
var properties = [String:String]()
properties["OM.sys.TokenID"] = "F7C5231053E6EC543B8930FB440752E2FE41B2CFC2AA8F4E9C4843D347E6A847" // Token ID to use for push messages
properties["OM.sys.AppID"] = "VisilabsIOSExample" //App ID to use for push messages
Visilabs.callAPI().customEvent("RegisterToken", properties: properties)
```

![Image of IOS Application Page](/Screenshots/ios-application-page.png)

## Targeting Actions

### In-App Messaging

**In-app messages** are notifications to your users when they are directly active in your mobile app. To enable **In-App Messaging** feature you need to set the value of `inAppNotificationsEnabled` parameter when calling  `createAPI` to initialize the SDK.

```swift
import VisilabsIOS

func application(_ application: UIApplication, didFinishLaunchingWithOptions 
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Visilabs.createAPI(organizationId: "YOUR_ORGANIZATION_ID", profileId: "YOUR_PROFILE_ID"
        , dataSource: "YOUR_DATASOURCE", inAppNotificationsEnabled: true, channel: "IOS"
        , requestTimeoutInSeconds: 30, geofenceEnabled: false, maxGeofenceCount: 20)
        return true
    }                                        
```

### Favorite Attribute Actions

### Geofencing


## Recommendation


Product recommendations are handled by the **recommend** method of SDK. You have to pass 3 mandatory arguments which are **zoneId**, **productCode** and **completion** to **recommend** method.

**completion** parameter is a closure expression which takes an **VisilabsRecommendationResponse** instance as input and returns nothing. The structure of **VisilabsRecommendationResponse** is shown below:

```swift
public class VisilabsRecommendationResponse {
    public var products: [VisilabsProduct]
    public var error: VisilabsReason?
    
    internal init(products: [VisilabsProduct], error: VisilabsReason? = nil) {
        self.products = products
        self.error = error
    }
}
```
**VisilabsProduct** class has the following properties:

| Property      | Type |
| ----------- | ----------- |
| code      | String       |
| title   | String        |
| img   | String        |
| dest_url   | String        |
| brand   | String        |
| price   | Double        |
| dprice   | Double        |
| cur   | String        |
| dcur   | String        |
| freeshipping   | Bool        |
| samedayshipping   | Bool        |
| rating   | Int        |
| comment   | Int        |
| discount   | Double        |
| attr1   | String        |
| attr2   | String        |
| attr3   | String        |
| attr4   | String        |
| attr5   | String        |



If recommended products exist for given arguments in **completion** method you need to handle the array of products. 

```swift
Visilabs.callAPI().recommend(zoneID: "6", productCode: "pc", filters: filters, properties: properties, completion: { response in
    if let error = response.error{
        
    }else{
        for product in response.products{
            print(product)
        }
    }
})
```







## Author

developer@relateddigital.com

