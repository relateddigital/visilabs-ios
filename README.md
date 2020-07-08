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

If you want to use target module and use in-app-messages you need to add actionUrl parameter and use createAPI method as shown below:

```swift
Visilabs.createAPI(organizationId: "YOUR_ORGANIZATION_ID", siteId: "YOUR_SITE_ID"
, loggerUrl: "http://lgr.visilabs.net", dataSource: "YOUR_DATASOURCE"
, realTimeUrl: "http://rt.visilabs.net", channel: "IOS", actionUrl: "http://s.visilabs.net/actjson")
```

If you want to use geofence module  you need to add geofenceUrl, geofenceEnabled and maxGeofenceCount parameter. maxGeofenceCount parameter indicates the maximum number of geographic areas which SDK can track. By default IOS is able track 20 geofences, but if you need to restrict maximum number of geofences you can define a number less than 20 to maxGeofenceCount parameter.

```swift
Visilabs.createAPI(organizationId: "YOUR_ORGANIZATION_ID", siteId: "YOUR_SITE_ID"
, loggerUrl: "http://lgr.visilabs.net", dataSource: "YOUR_DATASOURCE"
, realTimeUrl: "http://rt.visilabs.net", channel: "IOS", geofenceUrl: "http://s.visilabs.net/geojson"
, geofenceEnabled: true, maxGeofenceCount: 20)
```

If you are using all of the modules described above you can call createAPI method with all parameters mentioned above.

```swift
Visilabs.createAPI(organizationId: "YOUR_ORGANIZATION_ID", siteId: "YOUR_SITE_ID"
, loggerUrl: "http://lgr.visilabs.net", dataSource: "YOUR_DATASOURCE"
, realTimeUrl: "http://rt.visilabs.net", channel: "IOS", targetUrl: "http://s.visilabs.net/json"
, actionUrl: "http://s.visilabs.net/actjson", geofenceUrl: "http://s.visilabs.net/geojson"
, geofenceEnabled: true, maxGeofenceCount: 20)
```

Initialization method  createAPI should be called in the didFinishLaunchingWithOptions method of AppDelegate class. Required parameters organizationId, siteId and dataSource is obtained by RMC web panel. 








## Author

egemen@visilabs.com, egemengulkilik@gmail.com, umutcan.alparslan@euromsg.com

## License

VisilabsIOS is available under the MIT license. See the LICENSE file for more info.
 - [Related Digital ](https://www.relateddigital.com/)
 - [Visilabs ](http://visilabs.com/)
