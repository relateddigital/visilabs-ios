//
//  VisilabsEventTests.swift
//  VisilabsIOS_Tests
//
//  Created by Egemen on 7.07.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import VisilabsIOS


class VisilabsEventTests: VisilabsBaseTests {
    
    func testExVisitorId() {
        var properties = [String: String]()
        properties[VisilabsConfig.EXVISITORID_KEY] = "TestVisitor"
        visilabs.customEvent("TestEvent", properties: properties)
        
        
        
    }
    
}
