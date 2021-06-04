//
//  VisilabsInAppNotification.swift
//  VisilabsIOS
//
//  Created by Egemen on 10.05.2020.
//

import UIKit
//swiftlint:disable type_body_length
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
        public static let alertType = "alert_type"
        public static let closeButtonText = "close_button_text"
        public static let promotionCode = "promotion_code"
        public static let promotionTextColor = "promocode_text_color"
        public static let promotionBackgroundColor = "promocode_background_color"
        public static let numberColors = "number_colors"
        public static let waitingTime = "waiting_time"
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
    let messageTitleColor: UIColor?
    let messageBodyColor: UIColor?
    let messageBodyTextSize: String?
    let fontFamily: String?
    let backGroundColor: UIColor?
    let closeButtonColor: UIColor?
    let buttonTextColor: UIColor?
    let buttonColor: UIColor?
    let alertType: String?
    let closeButtonText: String?
    let promotionCode: String?
    let promotionTextColor: UIColor?
    let promotionBackgroundColor: UIColor?
    let numberColors: [UIColor]?
    let waitingTime: Int?
    
    var imageUrl: URL?
    lazy var image: Data? = {
        var data: Data?
        if let iUrl = self.imageUrl {
            do {
                data = try Data(contentsOf: iUrl, options: [.mappedIfSafe])
            } catch {
                VisilabsLogger.error("image failed to load from url \(iUrl)")
            }
        }
        return data
    }()

    let callToActionUrl: URL?
    var messageTitleFont: UIFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2),
                                          size: CGFloat(12))
    var messageBodyFont: UIFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body),
                                         size: CGFloat(8))
    var buttonTextFont: UIFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body),
                                        size: CGFloat(8))

    public init(actId: Int,
                type: VisilabsInAppNotificationType,
                messageTitle: String?,
                messageBody: String?,
                buttonText: String?,
                iosLink: String?,
                imageUrlString: String?,
                visitorData: String?,
                visitData: String?,
                queryString: String?,
                messageTitleColor: String?,
                messageBodyColor: String?,
                messageBodyTextSize: String?,
                fontFamily: String?,
                backGround: String?,
                closeButtonColor: String?,
                buttonTextColor: String?,
                buttonColor: String?,
                alertType: String?,
                closeButtonText: String?,
                promotionCode: String?,
                promotionTextColor: String?,
                promotionBackgroundColor: String?,
                numberColors: [String]?,
                waitingTime: Int?) {
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
        self.messageTitleColor =  UIColor(hex: messageTitleColor)
        self.messageBodyColor = UIColor(hex: messageBodyColor)
        self.messageBodyTextSize = messageBodyTextSize
        self.fontFamily = fontFamily
        self.backGroundColor = UIColor(hex: backGround)
        if let cBColor = closeButtonColor {
            if cBColor.lowercased() == "white" {
                self.closeButtonColor = UIColor.white
            } else if cBColor.lowercased() == "black" {
                self.closeButtonColor = UIColor.black
            } else {
                self.closeButtonColor = UIColor(hex: cBColor)
            }
        } else {
            self.closeButtonColor = nil
        }
        self.buttonTextColor = UIColor(hex: buttonTextColor)
        self.buttonColor = UIColor(hex: buttonColor)
        if !imageUrlString.isNilOrWhiteSpace {
            self.imageUrl = VisilabsInAppNotification.getImageUrl(imageUrlString!, type: self.type)
        }

        var callToActionUrl: URL?
        if let urlString = self.iosLink {
            callToActionUrl = URL(string: urlString)
        }
        self.callToActionUrl = callToActionUrl
        self.alertType = alertType
        self.closeButtonText = closeButtonText
        self.promotionCode = promotionCode
        self.promotionTextColor = UIColor(hex: promotionTextColor)
        self.promotionBackgroundColor = UIColor(hex: promotionBackgroundColor)
        self.numberColors = VisilabsHelper.convertColorArray(numberColors)
        self.waitingTime = waitingTime
        setFonts()
    }

    //swiftlint:disable function_body_length
    init?(JSONObject: [String: Any]?) {
        guard let object = JSONObject else {
            VisilabsLogger.error("notification json object should not be nil")
            return nil
        }

        guard let actId = object[PayloadKey.actId] as? Int, actId > 0 else {
            VisilabsLogger.error("invalid \(PayloadKey.actId)")
            return nil
        }

        guard let actionData = object[PayloadKey.actionData] as? [String: Any?] else {
            VisilabsLogger.error("invalid \(PayloadKey.actionData)")
            return nil
        }

        guard let messageType = actionData[PayloadKey.messageType] as? String,
              let type = VisilabsInAppNotificationType(rawValue: messageType) else {
            VisilabsLogger.error("invalid \(PayloadKey.messageType)")
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
        self.messageTitleColor = UIColor(hex: actionData[PayloadKey.messageTitleColor] as? String)
        self.messageBodyColor = UIColor(hex: actionData[PayloadKey.messageBodyColor] as? String)
        self.messageBodyTextSize = actionData[PayloadKey.messageBodyTextSize] as? String
        self.fontFamily = actionData[PayloadKey.fontFamily] as? String
        self.backGroundColor = UIColor(hex: actionData[PayloadKey.backGround] as? String)
        self.promotionCode = actionData[PayloadKey.promotionCode] as? String
        self.promotionTextColor = UIColor(hex: actionData[PayloadKey.promotionTextColor] as? String)
        self.promotionBackgroundColor = UIColor(hex: actionData[PayloadKey.promotionBackgroundColor] as? String)
        if let cBColor = actionData[PayloadKey.closeButtonColor] as? String {
            if cBColor.lowercased() == "white" {
                self.closeButtonColor = UIColor.white
            } else if cBColor.lowercased() == "black" {
                self.closeButtonColor = UIColor.black
            } else {
                self.closeButtonColor = UIColor(hex: cBColor)
            }
        } else {
            self.closeButtonColor = nil
        }

        self.buttonTextColor = UIColor(hex: actionData[PayloadKey.buttonTextColor] as? String)
        self.buttonColor = UIColor(hex: actionData[PayloadKey.buttonColor] as? String)

        if !imageUrlString.isNilOrWhiteSpace {
            self.imageUrl = VisilabsInAppNotification.getImageUrl(imageUrlString!, type: self.type)
        }

        var callToActionUrl: URL?
        if let urlString = self.iosLink {
            callToActionUrl = URL(string: urlString)
        }
        self.callToActionUrl = callToActionUrl
        self.alertType = actionData[PayloadKey.alertType] as? String
        self.closeButtonText = actionData[PayloadKey.closeButtonText] as? String
        if let numColors = actionData[PayloadKey.numberColors] as? [String]? {
            self.numberColors = VisilabsHelper.convertColorArray(numColors)
        } else {
            self.numberColors = nil
        }
        self.waitingTime = actionData[PayloadKey.waitingTime] as? Int
        setFonts()
    }

    private func setFonts() {
        self.messageTitleFont = VisilabsInAppNotification.getFont(fontFamily: self.fontFamily,
                                                                  fontSize: self.messageBodyTextSize,
                                                                  style: .title2)
        self.messageBodyFont = VisilabsInAppNotification.getFont(fontFamily: self.fontFamily,
                                                                 fontSize: self.messageBodyTextSize,
                                                                 style: .body)
        self.buttonTextFont = VisilabsInAppNotification.getFont(fontFamily: self.fontFamily,
                                                                fontSize: self.messageBodyTextSize,
                                                                style: .title2)
    }

    static func getFont(fontFamily: String?, fontSize: String?, style: UIFont.TextStyle) -> UIFont {
        var size = style == .title2 ? 12 : 8
        if let fSize = fontSize, let siz = Int(fSize), siz > 0 {
            size += siz
        }
        var finalFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: style),
                               size: CGFloat(size))
        if let font = fontFamily {
            if #available(iOS 13.0, *) {
                var systemDesign: UIFontDescriptor.SystemDesign  = .default
                if font.lowercased() == "serif" || font.lowercased() == "sansserif" {
                    systemDesign = .serif
                } else if font.lowercased() == "monospace" {
                    systemDesign = .monospaced
                }
                if let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
                    .withDesign(systemDesign) {
                    finalFont = UIFont(descriptor: fontDescriptor, size: CGFloat(size))
                }
            } else {
                if font.lowercased() == "serif" || font.lowercased() == "sansserif" {
                    let fontName = style == .title2 ? "GillSans-Bold": "GillSans"
                    finalFont = UIFont(name: fontName, size: CGFloat(size))!
                } else if font.lowercased() == "monospace" {
                    let fontName = style == .title2 ? "CourierNewPS-BoldMT": "CourierNewPSMT"
                    finalFont = UIFont(name: fontName, size: CGFloat(size))!
                }
            }
        }
        return finalFont
    }

    private static func getImageUrl(_ imageUrlString: String, type: VisilabsInAppNotificationType) -> URL? {
        var imageUrl: URL?
        var urlString = imageUrlString
        if type == .mini {
            urlString = imageUrlString.getUrlWithoutExtension() + "@2x." + imageUrlString.getUrlExtension()
        }
        if let escapedImageUrlString = urlString.addingPercentEncoding(withAllowedCharacters:
                                                                     NSCharacterSet.urlQueryAllowed),
           let imageUrlComponents = URLComponents(string: escapedImageUrlString),
           let imageUrlParsed = imageUrlComponents.url {
            imageUrl = imageUrlParsed
        }
        return imageUrl
    }
}
