![IVisilabs Logo](/Screenshots/visilabs.png)

[![Actions Status](https://github.com/relateddigital/visilabs-ios/workflows/CI/badge.svg)](https://github.com/relateddigital/visilabs-ios/actions)
[![Version](https://img.shields.io/cocoapods/v/VisilabsIOS.svg?style=flat)](https://cocoapods.org/pods/VisilabsIOS)
[![License](https://img.shields.io/cocoapods/l/VisilabsIOS.svg?style=flat)](https://cocoapods.org/pods/VisilabsIOS)
[![Platform](https://img.shields.io/cocoapods/p/VisilabsIOS.svg?style=flat)](https://cocoapods.org/pods/VisilabsIOS)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)



# Table of Contents

- [Introduction](#introduction)
- [Example](#Example)
- [Installation](#Installation)
- [Usage](#Usage)
    - [Initializing](#Initializing)
        - [Initial Parameters](#Initial-Parameters)
        - [Debugging](#Debugging)
    - [Data Collection](#Data-Collection)
    - [Targeting Actions](#Targeting-Actions)
        - [In-App Messaging](#In-App-Messaging)
        - [Favorite Attribute Actions](#Favorite-Attribute-Actions)
        - [Story Actions](#Story-Actions)
        - [Geofencing](#Geofencing)
        - [Mail Subscription Form](#Mail-Subscription-Form)
        - [Spin To Win](#Spin-To-Win)
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

Import VisilabsIOS in AppDelegate.swift and call `createAPI` method within `application:didFinishLaunchingWithOptions:` method.

The code below is a sample initialization of Visilabs library.

```swift
import VisilabsIOS

func application(_ application: UIApplication, didFinishLaunchingWithOptions 
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Visilabs.createAPI(organizationId: "YOUR_ORGANIZATION_ID", profileId: "YOUR_PROFILE_ID"
        , dataSource: "YOUR_DATASOURCE", inAppNotificationsEnabled: false, channel: "IOS"
        , requestTimeoutInSeconds: 30, geofenceEnabled: false, maxGeofenceCount: 20, isIDFAEnabled: true)
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
    * **isIDFAEnabled**: Default value is ***true***. After iOS 14, if you want to use _AdvertisingTrackingID_ you should request a permission from end user. If this parameter is true, then you should add _NSUserTrackingUsageDescription_ key into your *Info.plist* with proper description. As soon as you call `createAPI`, a dialog to request permission from end user will open and according to choice of the user, the value of _AdvertisingTrackingID_ will be sent to **Visilabs** servers. If you want to show your prompt at another time instead of when the app is opened you need to set the value **isIDFAEnabled** to ***false*** and call the public `requestIDFA` function whenever you want to show prompt. [Click here for detailed information](https://developer.apple.com/documentation/bundleresources/information_property_list/nsusertrackingusagedescription)


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

Also you can send properties without setting page name.

```swift
var properties = [String:String]()
properties["utm_source"] = "euromsg" // utm_source value in the payload of push notification
properties["utm_medium"] = "push" // utm_medium value in the payload of push notification
properties["utm_campaign"] = "euromsg campaign" // utm_campaign value in the payload of push notification
Visilabs.callAPI().sendCampaignParameters(properties: properties)
```

#### Push Message Token Registration

Visilabs needs to receive token to send push messages to users. The token value generated by APNS will be the value of the `OM.sys.TokenID` key. The value of the `OM.sys.AppID`  could be obtained by RMC administration panel. Follow the link https://intelligence.relateddigital.com/a02/index#/Push/AppList and select the relevant push application. The value of  `App Alias` refers to `OM.sys.AppID`. If you have problems, please contact RMC support team. 

```swift
var properties = [String:String]()
properties["OM.sys.TokenID"] = "F7C5231053E6EC543B8930FB440752E2FE41B2CFC2AA8F4E9C4843D347E6A847" // Token ID to use for push messages
properties["OM.sys.AppID"] = "VisilabsIOSExample" //App ID to use for push messages
Visilabs.callAPI().customEvent("RegisterToken", properties: properties)
```

![IOS Application Page](/Screenshots/ios-application-page.png)

### Request and Send IDFA

You can call the `requestIDFA` function whenever you want to show `App Tracking Transparency` prompt to request **IDFA** and send the value to **Visilabs** servers.

```swift
Visilabs.callAPI().requestIDFA()
```

### Sending Location Status Information

You can call the `sendLocationPermission` method to to send the location permission status of your users to **Visilabs** servers and use this information on the panel later.

```swift
Visilabs.callAPI().sendLocationPermission()
```

This information is sent with the `OM.locpermit` parameter and can take one of the following 3 values:

* "always" : Location permission is obtained while the application is open and closed.
* "appopen" : Location permission is only obtained when the app is open.
* "none" : Location permission is not obtained.


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

The existence of a relevant **in-app message** for an event controlled by after each `customEvent` call. You can create and customize your **in-app messages** on https://intelligence.relateddigital.com/#Target/TargetingAction/TAList page of RMC administration panel.

There are 9 types of **in-app messages**:


|               Pop-up - Image, Header, Text & Button              | Mini-icon&text                                                             | Full Screen-image                                                |
|:----------------------------------------------------------------:|----------------------------------------------------------------------------|------------------------------------------------------------------|
| ![full](/Screenshots/InAppNotification/full.png)                 | ![mini](/Screenshots/InAppNotification/mini.png)                           | ![full_image](/Screenshots/InAppNotification/full_image.png)     |
| Full Screen-image&button                                         | Pop-up - Image, Header, Text & Button                                      |                              Pop-up-Survey                       |
| ![image_button](/Screenshots/InAppNotification/image_button.png) | ![image_text_button](/Screenshots/InAppNotification/image_text_button.png) | ![smile_rating](/Screenshots/InAppNotification/smile_rating.png) |
| Pop-up - NPS with Text & Button                                  | Native Alert & Actionsheet                                                 |  NPS with numbers                                                   |
| ![nps](/Screenshots/InAppNotification/nps.png)                   | ![nps_with_numbers](/Screenshots/InAppNotification/alert.png)   | ![nps_with_numbers](/Screenshots/InAppNotification/nps_with_numbers.png) |


If you want to manage the links you add for in-app messages yourself, you can follow the step below.

First you have to call the delegate method

```swift
Visilabs.callAPI().inappButtonDelegate = self                                 
```

Then you have to add the extension and you can delete the print codes and write your own codes.

```swift
extension EventViewController: VisilabsInappButtonDelegate {
    func didTapButton(_ notification: VisilabsInAppNotification) {
        print("notification did tapped...")
        print(notification)
    }
}
```

### Favorite Attribute Actions

You can access favorite attributes of the **Targeting Actions** of type **Favorite Attribute Action**  that you defined from the  https://intelligence.relateddigital.com/#Target/TargetingAction/TAList/ section on the **RMC** panel via the mobile application as follows.

```swift
Visilabs.callAPI().getFavoriteAttributeActions { (response) in
    if let error = response.error {
        print(error)
    } else {
        if let favoriteBrands = response.favorites[.brand] {
            for brand in favoriteBrands {
                print(brand)
            }
        }
        if let favoriteCategories = response.favorites[.category] {
            for category in favoriteCategories {
                print(category)
            }
        }
    }
}
```

You can also access favorite attributes of a particular **Targeting Action** by specifying the **ID**.

![Favorite Attribute Action](/Screenshots/favorite-attribute-action-page.png)

```swift
Visilabs.callAPI().getFavoriteAttributeActions(actionId: 188) { (response) in
    if let error = response.error {
        print(error)
    } else {
        if let favoriteBrands = response.favorites[.brand] {
            for brand in favoriteBrands {
                print(brand)
            }
        }
        if let favoriteCategories = response.favorites[.category] {
            for category in favoriteCategories {
                print(category)
            }
        }
    }
}
```

`favorites` property of `response` object is a dictionary which has an `enum` as key and an `array` of `String`s as value.  The cases of `VisilabsFavoriteAttribute`  `enum` are the followings:

```swift
public enum VisilabsFavoriteAttribute: String {
    case ageGroup
    case attr1
    case attr2
    case attr3
    case attr4
    case attr5
    case attr6
    case attr7
    case attr8
    case attr9
    case attr10
    case brand
    case category
    case color
    case gender
    case material
    case title
}
```

### Story Actions

Story actions allow you to add widgets similar to "Instagram Story" list view on your iOS devices. `getStoryView` method returns an instance of `VisilabsStoryHomeView` which is a subclass of `UIView`.

```swift
let storyView = Visilabs.callAPI().getStoryView()
view.addSubview(storyHomeView)
```

You can also access a story action by specifying the **ID** of the **Targeting Action**.

```swift
let storyView = Visilabs.callAPI().getStoryView(actionId: 67)
view.addSubview(storyHomeView)
```

If you add a clickable URL, framework handle to open it on browser (or direct by deeplink). However, if you want to handle by yourself, extend your class that conforms VisilabsStoryURLDelegate, as following;

```swift
extension StoryViewController: VisilabsStoryURLDelegate {
    func urlClicked(_ url: URL) {
        //TO DO
    }
}
```
After you add this, you can set urlDelegate self.

```swift
let storyView = Visilabs.callAPI().getStoryView(actionId: 67, urlDelegate: self)
view.addSubview(storyHomeView)
```
If you set delegate, then clickable URL will not be handled by SDK!

There is also an asynchronous version of `getStoryView` method called `getStoryViewAsync` which takes an completionHandler that receives an optional `VisilabsStoryHomeView` object. If there is no Story Action matching your criteria completionHandler returns `nil`.

```swift
Visilabs.callAPI().getStoryViewAsync(actionId: 55){ storyHomeView in
    if let storyHomeView = storyHomeView {
        
    } else {
        print("There is no story action matching your criteria.")
    }
}
````


### Geofencing

To enable location services in your application first of all you need to add the following keys to your `Info.plist` file.

* NSLocationAlwaysAndWhenInUseUsageDescription
* NSLocationWhenInUseUsageDescription

An example implementation of these permissions as follows:

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need access to your location for better user experience.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need access to your location for better user experience.</string>
```

You also need to add the following keys under `UIBackgroundModes` in your `Info.plist` file to monitor regions, refresh region list and receive push notifications.

```xml
<array>
    <string>fetch</string>
    <string>location</string>
    <string>remote-notification</string>
</array>
```

When initializing **Visilabs** SDK you need to set `geofenceEnabled` parameter of `createAPI` method to `true`. You may also change the `maxGeofenceCount` to a value lower than 20. **Apple** prevents any single application from monitoring more than 20 regions simultaneously. Visilabs can use all these slots.

```swift
import VisilabsIOS

func application(_ application: UIApplication, didFinishLaunchingWithOptions 
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Visilabs.createAPI(organizationId: "YOUR_ORGANIZATION_ID", profileId: "YOUR_PROFILE_ID"
        , dataSource: "YOUR_DATASOURCE", inAppNotificationsEnabled: false, channel: "IOS"
        , requestTimeoutInSeconds: 30, geofenceEnabled: true, maxGeofenceCount: 20)
        return true
    }                                        
```

### Mail Subscription Form

After form is created at **RMC** panel, likewise **in-app message**, existence of mail subscription form is controlled by after each `customEvent` call. It is shown as follows;

![mail-subscription-form](/Screenshots/InAppNotification/mail-subscription-form.png)

### Spin To Win

After form is created at **RMC** panel, likewise **in-app message**, existence of spin to win is controlled by after each `customEvent` call. It opens a WebViewController. It is shown as follows;

|               Spin to Win Full                                   |                        Spin to Win Half                                    |
|:----------------------------------------------------------------:|----------------------------------------------------------------------------|
| ![spin-to-win-full](/Screenshots/spin_to_win_full_en.jpeg)          | ![spin-to-win-half](/Screenshots/spin_to_win_half_en.jpeg)                    |



## Recommendation


Product recommendations are handled by the `recommend` method of SDK. You have to pass 3 mandatory arguments which are `zoneId`, `productCode` and `completion` to `recommend` method.

`completion` parameter is a closure expression which takes an `VisilabsRecommendationResponse` instance as input and returns nothing. The structure of `VisilabsRecommendationResponse` is shown below:

```swift
public class VisilabsRecommendationResponse {
    public var products: [VisilabsProduct]
    public var error: VisilabsError?
    public var widgetTitle: String = ""
    
    internal init(products: [VisilabsProduct], widgetTitle: String = "", error: VisilabsError? = nil) {
        self.products = products
        self.widgetTitle = widgetTitle
        self.error = error
    }
}
```
`VisilabsProduct` class has the following properties:

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



If recommended products exist for given arguments in `completion` method you need to handle the array of products. 

```swift
Visilabs.callAPI().recommend(zoneID: "6", productCode: "pc", filters: []){ response in
    if let error = response.error {
        print(error)
    }else{
        print("Recommended Products")
        for product in response.products{
            print("product code: \(product.code) title: \(product.title)")
        }
    }
}
```

You may also pass an array of filters to `recommend` method. For example the following implementation returns only the products which contains **laptop** in the title.

```swift
var filters = [VisilabsRecommendationFilter]()
let filter = VisilabsRecommendationFilter(attribute: .PRODUCTNAME, filterType: .like, value: "laptop")
filters.append(filter)
Visilabs.callAPI().recommend(zoneID: "6", productCode: "pc", filters: filters){ response in
    if let error = response.error{
        print(error)
    }else{
        print("Widget Title: \(response.widgetTitle)")
        print("Recommended Products")
        for product in response.products{
            print("product code: \(product.code) title: \(product.title)")
        }
    }
}
```

`VisilabsProductFilterAttribute` enum has the following cases and sample values:

| case      | example |
| ----------- | ----------- |
| PRODUCTNAME      | ""       |
| COLOR   | "blue"        |
| AGEGROUP   | "18-40"        |
| BRAND   | "visilabs"        |
| CATEGORY   | "145"        |
| GENDER   | "f"        |
| MATERIAL   | "wood"        |
| ATTRIBUTE1   | "attr1value"        |
| ATTRIBUTE2   | "attr2value"          |
| ATTRIBUTE3   | "attr3value"          |
| ATTRIBUTE4   | "attr4value"          |
| ATTRIBUTE5   | "attr5value"          |
| SHIPPINGONSAMEDAY   | "1"        |
| FREESHIPPING   | "1"         |
| ISDISCOUNTED   | "1"         |


#### Report Recommendation Clicks

To report the clicks of widget recommendations you need to call the `trackRecommendationClick` method with the `qs` property of `Product` object.

```swift
Visilabs.callAPI().trackRecommendationClick(qs: product.qs)
```


## Author

developer@relateddigital.com

