<p align="center">
  <a target="_blank" rel="noopener noreferrer" href="https://github.com/relateddigital/visilabs-android"><img src="https://github.com/relateddigital/visilabs-android/blob/master/app/visilabs.png" alt="Visilabs Android Library" width="500" style="max-width:100%;"></a>
</p>

# VisilabsIOS

[![CI Status](https://img.shields.io/travis/egemen@visilabs.com/VisilabsIOS.svg?style=flat)](https://travis-ci.org/egemen@visilabs.com/VisilabsIOS)
[![Version](https://img.shields.io/cocoapods/v/VisilabsIOS.svg?style=flat)](https://cocoapods.org/pods/VisilabsIOS)
[![License](https://img.shields.io/cocoapods/l/VisilabsIOS.svg?style=flat)](https://cocoapods.org/pods/VisilabsIOS)
[![Platform](https://img.shields.io/cocoapods/p/VisilabsIOS.svg?style=flat)](https://cocoapods.org/pods/VisilabsIOS)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

VisilabsIOS is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'VisilabsIOS'
```

Then go to the path of your project file from the terminal and run the ```pod install``` command.

## Initializing
Open ```AppDelegate.swift```<br />

Add Visilabs using the line below <br />

```import VisilabsIOS``` <br />

Depending on your needs you can initialize Visilabs with various number of parameters. 

In simplest form Visilabs IOS SDK could be initialized with 6 mandatory parameters. If you initialize Visilabs IOS SDK this way, only event logging functionalities would be available. The following example shows this initialization. 

```swift
Visilabs.createAPI(organizationId: "YOUR_ORGANIZATION_ID", siteId: "YOUR_SITE_ID"
, loggerUrl: "http://lgr.visilabs.net", dataSource: "YOUR_DATASOURCE"
, realTimeUrl: "http://rt.visilabs.net", channel: "IOS")
```

If you want to use recommendation module you need to add targetUrl parameter and use createAPI method as shown below:

```swift
Visilabs.createAPI(organizationId: "YOUR_ORGANIZATION_ID", siteId: "YOUR_SITE_ID"
, loggerUrl: "http://lgr.visilabs.net", dataSource: "YOUR_DATASOURCE"
, realTimeUrl: "http://rt.visilabs.net", channel: "IOS", targetUrl: "http://s.visilabs.net/json")
```



Then write the following line in the didFinishLaunchingWithOptions function. Note: This code is for the standard Visilabs Setup. If you want to use features such as in-app and geofence, please check <a href="https://relateddigital.atlassian.net/wiki/spaces/KB/pages/428966373/iOS+-+Initialization" target="_blank">our document here.</a> <br />

```swift
Visilabs.createAPI("YOUR_ORGANIZATION_ID", withSiteID:"YOUR_SITE_ID", 
withSegmentURL: "http://lgr.visilabs.net", withDataSource: "YOUR_DATASOURCE", 
withRealTimeURL: "http://rt.visilabs.net", withChannel: "IOS", withRequestTimeout:30,
withTargetURL:"http://s.visilabs.net/json",withActionURL: "http://s.visilabs.net/actjson")
```

You need to get the three paramaters from RMC web panel.
organizationID siteID datasource

## Author

egemen@visilabs.com, egemengulkilik@gmail.com, umutcan.alparslan@euromsg.com

## License

VisilabsIOS is available under the MIT license. See the LICENSE file for more info.
 - [Related Digital ](https://www.relateddigital.com/)
 - [Visilabs ](http://visilabs.com/)
