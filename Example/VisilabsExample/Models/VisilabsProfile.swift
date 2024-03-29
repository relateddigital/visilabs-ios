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
    var askLocationPermmissionAtStart: Bool = false
    var maxGeofenceCount = 20
    var appAlias = "VisilabsIOSExample"
    var appToken = ""
    var userKey = "userKey"
    var userEmail = "user@mail.com"
    var isIDFAEnabled = true
    var organizationTestId = "394A48556A2F76466136733D"
    var profileTestId = "75763259366A3345686E303D"
    var IsTest: Bool = false

}
