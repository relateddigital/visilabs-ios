//
//  VisilabsProfile.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 27.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct VisilabsProfile: Codable {
    var organizationId = "676D325830564761676D453D"
    var profileId = "356467332F6533766975593D"
    var dataSource = "visistore"
    var inAppNotificationsEnabled: Bool = true
    var channel = "IOS"
    var requestTimeoutInSeconds = 30
    var geofenceEnabled: Bool = true
    var maxGeofenceCount = 20
    var appAlias = "VisilabsIOSExample"
    var appToken = ""
    var userKey = "userKey"
    var userEmail = "user@mail.com"
    var isIDFAEnabled = true
}
