//
//  VisilabsBaseTests.swift
//  VisilabsIOS_Tests
//
//  Created by Egemen on 7.07.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import VisilabsIOS

class VisilabsBaseTests: XCTestCase {

    var visilabs: VisilabsInstance!

    override func setUp() {
        print("Visilabs test setup starting")
        super.setUp()
        visilabs = Visilabs.createAPI(organizationId: "",
                                      profileId: "",
                                      dataSource: "",
                                      channel: "",
                                      requestTimeoutInSeconds: 0,
                                      geofenceEnabled: false,
                                      maxGeofenceCount: 0)
        print("Visilabs test setup finished")
    }

    override func tearDown() {
        super.tearDown()
    }
}
