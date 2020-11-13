//
//  VisilabsInAppNotificationTest.swift
//  VisilabsIOS_Tests
//
//  Created by Egemen on 7.07.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import VisilabsIOS

public enum PayloadKey {
    public static let actId = "actid"
    public static let actionData = "actiondata"
    public static let messageType = "msg_type"
    public static let messageTitle = "msg_title"
    public static let messageBody = "msg_body"
    public static let buttonText = "btn_text"
    public static let iosLink = "ios_lnk"
    public static let imageUrlString = "img"
    public static let visitorData = "visitor_data"
    public static let visitData = "visit_data"
    public static let queryString = "qs"
    public static let messageTitleColor = "msg_title_color"
    public static let messageBodyColor = "msg_body_color"
    public static let messageBodyTextSize = "msg_body_textsize"
    public static let fontFamily = "font_family"
    public static let backGround = "background"
    public static let closeButtonColor = "close_button_color"
    public static let buttonTextColor = "button_text_color"
    public static let buttonColor = "button_color"
}

class VisilabsInAppNotificationTest: XCTestCase {

    func testInAppNotificationInitReturnNilIfActIdEqualsZero() {
        // 1. given
        var jsonObject = [String: Any]()
        jsonObject[VisilabsInAppNotification.PayloadKey.actId] = 0
        // 2. when
        let visilabsInAppNotification = VisilabsInAppNotification(JSONObject: jsonObject)
        // 3. then
        XCTAssertNil(visilabsInAppNotification, "VisilabsInAppNotification init invalid act id returns non-nil.")
    }

    func testInAppNotificationInitReturnNilIfMessageTypeNotValid() {
        var jsonObject = [String: Any]()
        jsonObject[VisilabsInAppNotification.PayloadKey.messageType] = "InvalidType"
        let visilabsInAppNotification = VisilabsInAppNotification(JSONObject: jsonObject)
        XCTAssertNil(visilabsInAppNotification, "VisilabsInAppNotification init invalid act id returns non-nil.")
    }
}
