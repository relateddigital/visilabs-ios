<p align="center">
  <a target="_blank" rel="noopener noreferrer" href="https://github.com/relateddigital/visilabs-android"><img src="https://github.com/relateddigital/visilabs-android/blob/master/app/visilabs.png" alt="Visilabs Android Library" width="500" style="max-width:100%;"></a>
</p>

# Visilabs iOS
The Visilabs iOS SDK is a Swift implementation of a iOS client for Visilabs.

## Installation
Add the line below to your Pod file.
```swift
pod 'Visilabs'
```
Then go to the path of your project file from the terminal and run the ```pod install``` command.

### Visilabs SDK Setup
Open ```AppDelegate.swift```<br />
Add Visilabs using the line below <br />
```import Visilabs``` <br />
Then write the following line in the didFinishLaunchingWithOptions function. Note: This code is for the standard Visilabs Setup. If you want to use features such as in-app and geofence, please check <a href="https://relateddigital.atlassian.net/wiki/spaces/KB/pages/428966373/iOS+-+Initialization" target="_blank">our document here.</a> <br />
```
Visilabs.createAPI("YOUR_ORGANIZATION_ID", withSiteID:"YOUR_SITE_ID", 
withSegmentURL: "http://lgr.visilabs.net", withDataSource: "YOUR_DATASOURCE", 
withRealTimeURL: "http://rt.visilabs.net", withChannel: "IOS", withRequestTimeout:30,
withTargetURL:"http://s.visilabs.net/json",withActionURL: "http://s.visilabs.net/actjson")
```
You need to get the three paramaters from RMC web panel.

organizationID siteID datasource


### Licences


 - [Related Digital ](https://www.relateddigital.com/)
 - [Visilabs ](http://visilabs.com/)
