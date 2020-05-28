//
//  VisilabsInAppNotification.swift
//  VisilabsIOS
//
//  Created by Egemen on 10.05.2020.
//

import Foundation

public class VisilabsInAppNotification {
    
    
    
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
    let messageType: String
    let type: VisilabsInAppNotificationType
    let messageTitle: String?
    let messageBody: String?
    let buttonText: String?
    let iosLink: String?
    let imageURLString: String?
    let visitorData: String?
    let visitData: String?
    let queryString: String?
    let messageTitleColor: String?
    let messageBodyColor: String?
    let messageBodyTextSize: String?
    let fontFamily: String?
    let backGround: String?
    let closeButtonColor: String?
    let buttonTextColor: String?
    let buttonColor: String?
    
    var imageURL: URL?
    lazy var image: Data? = {
        var data: Data?
        if let iUrl = self.imageURL {
            do {
                data = try Data(contentsOf: iUrl, options: [.mappedIfSafe])
            } catch {
                VisilabsLogger.error(message: "image failed to load from url \(iUrl)")
            }
        }
        return data
    }()
    
    let callToActionURL: URL?
    
    public init(actId: Int, type: VisilabsInAppNotificationType, messageTitle: String?, messageBody: String?, buttonText: String?, iosLink: String?, imageURLString: String?, visitorData: String?, visitData: String?, queryString: String?, messageTitleColor: String?, messageBodyColor: String?, messageBodyTextSize: String?, fontFamily: String?, backGround: String?, closeButtonColor: String?, buttonTextColor: String?, buttonColor: String?) {
        self.actId = actId
        self.messageType = type.rawValue
        self.type = type
        self.messageTitle = messageTitle
        self.messageBody = messageBody
        self.buttonText = buttonText
        self.iosLink = iosLink
        self.imageURLString = imageURLString
        self.visitorData = visitorData
        self.visitData = visitData
        self.queryString = queryString
        self.messageTitleColor = messageTitleColor
        self.messageBodyColor = messageBodyColor
        self.messageBodyTextSize = messageBodyTextSize
        self.fontFamily = fontFamily
        self.backGround = backGround
        self.closeButtonColor = closeButtonColor
        self.buttonTextColor = buttonTextColor
        self.buttonColor = buttonColor
        
        if let imageURLString = imageURLString
            , let escapedImageURLString = imageURLString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            , let imageURLComponents = URLComponents(string: escapedImageURLString)
            , let imageURLParsed = imageURLComponents.url{
            self.imageURL = imageURLParsed
        }
        
        var callToActionURL: URL?
        if let URLString = self.iosLink {
            callToActionURL = URL(string: URLString)
        }

        self.callToActionURL = callToActionURL
    }
    
    init?(JSONObject: [String: Any]?) {
        guard let object = JSONObject else {
            VisilabsLogger.error(message: "notification json object should not be nil")
            return nil
        }
        
        guard let actId = object[PayloadKey.actId] as? Int, actId > 0 else {
            VisilabsLogger.error(message: "invalid \(PayloadKey.actId)")
            return nil
        }
        
        guard let actionData = object[PayloadKey.actionData] as? [String: Any?] else {
            VisilabsLogger.error(message: "invalid \(PayloadKey.actionData)")
            return nil
        }
        
        guard let messageType = actionData[PayloadKey.messageType] as? String, let type = VisilabsInAppNotificationType(rawValue: messageType) else {
            VisilabsLogger.error(message: "invalid \(PayloadKey.messageType)")
            return nil
        }
        
        self.actId = actId
        self.messageType = messageType
        self.type = type
        self.messageTitle = actionData[PayloadKey.messageTitle] as? String
        self.messageBody = actionData[PayloadKey.messageBody] as? String
        self.buttonText = actionData[PayloadKey.buttonText] as? String
        self.iosLink = actionData[PayloadKey.iosLink] as? String
        self.imageURLString = actionData[PayloadKey.imageURLString] as? String
        self.visitorData = actionData[PayloadKey.visitorData] as? String
        self.visitData = actionData[PayloadKey.visitData] as? String
        self.queryString = actionData[PayloadKey.queryString] as? String
        self.messageTitleColor = actionData[PayloadKey.messageTitleColor] as? String
        self.messageBodyColor = actionData[PayloadKey.messageBodyColor] as? String
        self.messageBodyTextSize = actionData[PayloadKey.messageBodyTextSize] as? String
        self.fontFamily = actionData[PayloadKey.fontFamily] as? String
        self.backGround = actionData[PayloadKey.backGround] as? String
        self.closeButtonColor = actionData[PayloadKey.closeButtonColor] as? String
        self.buttonTextColor = actionData[PayloadKey.buttonTextColor] as? String
        self.buttonColor = actionData[PayloadKey.buttonColor] as? String
        
        if let imageURLString = imageURLString
            , let escapedImageURLString = imageURLString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            , let imageURLComponents = URLComponents(string: escapedImageURLString)
            , let imageURLParsed = imageURLComponents.url{
            self.imageURL = imageURLParsed
        }
        
        var callToActionURL: URL?
        if let URLString = self.iosLink {
            callToActionURL = URL(string: URLString)
        }

        self.callToActionURL = callToActionURL
    }
}
