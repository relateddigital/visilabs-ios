//
//  VisilabsProfile.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 27.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct VisilabsProfile {
    var organizationId = "676D325830564761676D453D"
    var siteId = "356467332F6533766975593D"
    var dataSource = "visistore"
    var loggerUrl = "http://lgr.visilabs.net"
    var realTimeUrl = "http://rt.visilabs.net"
    var inAppNotificationsEnabled: Bool = true
    var channel = "IOS"
    var requestTimeoutInSeconds = 30
    var targetUrl: String? = "http://s.visilabs.net/json"
    var actionUrl: String? = "http://s.visilabs.net/actjson"
    var geofenceUrl: String? = "http://s.visilabs.net/geojson"
    var geofenceEnabled: Bool = true
    var maxGeofenceCount = 20
    var restUrl: String?
    var encryptedDataSource: String?
}
