//
//  VisilabsInAppNotification.swift
//  VisilabsIOS
//
//  Created by Egemen on 10.05.2020.
//

import Foundation

public class VisilabsInAppNotification {
    
    
    
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
    
    let actId: Int
    let messageType: String
    let type: VisilabsInAppNotificationType
    let messageTitle: String?
    let messageBody: String?
    let buttonText: String?
    let iosLink: String?
    let imageUrlString: String?
    let visitorData: String?
    let visitData: String?
    let queryString: String?
    let messageTitleColor: String?
    let messageBodyColor: String?
    let messageBodyTextSize: String?
    let fontFamily: String?
    let backGroundColor: String?
    let closeButtonColor: String?
    let buttonTextColor: String?
    let buttonColor: String?
    
    var imageUrl: URL?
    lazy var image: Data? = {
        var data: Data?
        if let iUrl = self.imageUrl {
            do {
                data = try Data(contentsOf: iUrl, options: [.mappedIfSafe])
            } catch {
                VisilabsLogger.error(message: "image failed to load from url \(iUrl)")
            }
        }
        return data
    }()
    
    let callToActionUrl: URL?
    
    public init(actId: Int, type: VisilabsInAppNotificationType, messageTitle: String?, messageBody: String?, buttonText: String?, iosLink: String?, imageUrlString: String?, visitorData: String?, visitData: String?, queryString: String?, messageTitleColor: String?, messageBodyColor: String?, messageBodyTextSize: String?, fontFamily: String?, backGround: String?, closeButtonColor: String?, buttonTextColor: String?, buttonColor: String?) {
        self.actId = actId
        self.messageType = type.rawValue
        self.type = type
        self.messageTitle = messageTitle
        self.messageBody = messageBody
        self.buttonText = buttonText
        self.iosLink = iosLink
        self.imageUrlString = imageUrlString
        self.visitorData = visitorData
        self.visitData = visitData
        self.queryString = queryString
        self.messageTitleColor = messageTitleColor
        self.messageBodyColor = messageBodyColor
        self.messageBodyTextSize = messageBodyTextSize
        self.fontFamily = fontFamily
        self.backGroundColor = backGround
        self.closeButtonColor = closeButtonColor
        self.buttonTextColor = buttonTextColor
        self.buttonColor = buttonColor
        
        if !imageUrlString.isNilOrWhiteSpace {
            self.imageUrl = VisilabsInAppNotification.getImageUrl(imageUrlString!, type: self.type)
        }
        
        var callToActionUrl: URL?
        if let urlString = self.iosLink {
            callToActionUrl = URL(string: urlString)
        }
        self.callToActionUrl = callToActionUrl
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
        self.imageUrlString = actionData[PayloadKey.imageUrlString] as? String
        self.visitorData = actionData[PayloadKey.visitorData] as? String
        self.visitData = actionData[PayloadKey.visitData] as? String
        self.queryString = actionData[PayloadKey.queryString] as? String
        self.messageTitleColor = actionData[PayloadKey.messageTitleColor] as? String
        self.messageBodyColor = actionData[PayloadKey.messageBodyColor] as? String
        self.messageBodyTextSize = actionData[PayloadKey.messageBodyTextSize] as? String
        self.fontFamily = actionData[PayloadKey.fontFamily] as? String
        self.backGroundColor = actionData[PayloadKey.backGround] as? String
        self.closeButtonColor = actionData[PayloadKey.closeButtonColor] as? String
        self.buttonTextColor = actionData[PayloadKey.buttonTextColor] as? String
        self.buttonColor = actionData[PayloadKey.buttonColor] as? String
        
        if !imageUrlString.isNilOrWhiteSpace {
            self.imageUrl = VisilabsInAppNotification.getImageUrl(imageUrlString!, type: self.type)
        }
        
        var callToActionUrl: URL?
        if let urlString = self.iosLink {
            callToActionUrl = URL(string: urlString)
        }
        self.callToActionUrl = callToActionUrl
    }
    
    private static func getImageUrl(_ imageUrlString: String, type: VisilabsInAppNotificationType) -> URL? {
        var imageUrl : URL?
        var urlString = imageUrlString
        if type == .mini{
            urlString = imageUrlString.getUrlWithoutExtension() + "@2x." + imageUrlString.getUrlExtension()
        }
        if let escapedImageUrlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            , let imageUrlComponents = URLComponents(string: escapedImageUrlString)
            , let imageUrlParsed = imageUrlComponents.url{
            imageUrl = imageUrlParsed
        }
        return imageUrl
    }
}
