//
//  VisilabsInAppNotification.swift
//  VisilabsIOS
//
//  Created by Egemen on 10.05.2020.
//

import Foundation

class VisilabsInAppNotification {
    enum PayloadKey {
        static let actId = "actid"
        static let actionData = "actiondata"
        static let messageType = "msg_type"
        static let messageTitle = "msg_title"
        static let messageBody = "msg_body"
        static let buttonText = "btn_text"
        static let iosLink = "ios_lnk"
        static let imageURLString = "img"
        static let visitorData = "visitor_data"
        static let visitData = "visit_data"
        static let queryString = "qs"
        static let messageTitleColor = "msg_title_color"
        static let messageBodyColor = "msg_body_color"
        static let messageBodyTextSize = "msg_body_textsize"
        static let fontFamily = "font_family"
        static let backGround = "background"
        static let closeButtonColor = "close_button_color"
        static let buttonTextColor = "button_text_color"
        static let buttonColor = "button_color"
    }
    
    let actId: Int
    
    init?(JSONObject: [String: Any]?) {
        guard let object = JSONObject else {
            VisilabsLogger.error(message: "notification json object should not be nil")
            return nil
        }
        
        guard let actId = object[PayloadKey.actId] as? Int, actId > 0 else {
            VisilabsLogger.error(message: "invalid notification id")
            return nil
        }
        
        
        self.actId = actId
    }
}
