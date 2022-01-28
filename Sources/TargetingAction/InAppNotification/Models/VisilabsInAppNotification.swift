//
//  VisilabsInAppNotification.swift
//  VisilabsIOS
//
//  Created by Egemen on 10.05.2020.
//

import UIKit
// swiftlint:disable type_body_length
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
        public static let messageTitleTextSize = "msg_title_textsize"
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
        public static let secondPopupType = "secondPopup_type"
        public static let secondPopupMinPoint = "secondPopup_feedbackform_minpoint"
        public static let secondPopupTitle = "secondPopup_msg_title"
        public static let secondPopupBody = "secondPopup_msg_body"
        public static let secondPopupBodyTextSize = "secondPopup_msg_body_textsize"
        public static let secondPopupButtonText = "secondPopup_btn_text"
        public static let secondImageUrlString1 = "secondPopup_image1"
        public static let secondImageUrlString2 = "secondPopup_image2"
        public static let position = "pos"
        public static let customFont = "custom_font_family_ios"
        public static let closePopupActionType = "close_event_trigger"
        public static let carouselItems = "carousel_items"
        public static let carouselImage = "image"
        public static let carouselTitle = "title"
        public static let carouselTitleColor = "title_color"
        public static let carouselTitleFontFamilyIOS = "title_custom_font_family_ios"
        public static let carouselTitleTextSize = "title_textsize"
        public static let carouselBody = "body"
        public static let carouselBodyColor = "body_color"
        public static let carouselBodyFontFamilyIOS = "body_custom_font_family_ios"
        public static let carouselBodyTextSize = "body_textsize"
        public static let carouselPromocodeType = "promocode_type"
        public static let carouselPromotionCode = "promotion_code"
        public static let carouselPromocodeBackgroundColor = "promocode_background_color"
        public static let carouselPromocodeTextColor = "promocode_text_color"
        public static let carouselButtonText = "button_text"
        public static let carouselButtonTextColor = "button_text_color"
        public static let carouselButtonColor = "button_color"
        public static let carouselButtonFontFamilyIOS = "button_custom_font_family_ios"
        public static let carouselButtonTextSize = "button_textsize"
        public static let carouselBackgroundImage = "background_image"
        public static let carouselBackgrounColor = "background_color"
        public static let carouselIOSLink = "ios_lnk"
        
    }

    let actId: Int
    let messageType: String
    let type: VisilabsInAppNotificationType
    let messageTitle: String?
    let messageBody: String?
    let buttonText: String?
    public let iosLink: String?
    let imageUrlString: String?
    let visitorData: String?
    let visitData: String?
    let queryString: String?
    let messageTitleColor: UIColor?
    let messageTitleTextSize: String?
    let messageBodyColor: UIColor?
    let messageBodyTextSize: String?
    let fontFamily: String?
    let customFont: String?
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
    let secondPopupType: VisilabsSecondPopupType?
    let secondPopupTitle: String?
    let secondPopupBody: String?
    let secondPopupBodyTextSize: String?
    let secondPopupButtonText: String?
    let secondImageUrlString1: String?
    let secondImageUrlString2: String?
    let secondPopupMinPoint: String?
    let previousPopupPoint: Double?
    let position: VisilabsHalfScreenPosition?
    let closePopupActionType: String?
    let carouselItems: String?
    let carouselImage: [String]?
    let carouselTitle: [String]?
    let carouselTitleColor: [UIColor]?
    let carouselTitleFontFamilyIOS: [String]?
    let carouselTitleTextSize: [String]?
    let carouselBody: [String]?
    let carouselBodyColor: [UIColor]?
    let carouselBodyFontFamilyIOS: [String]?
    let carouselBodyTextSize: [String]?
    let carouselPromocodeType: [String]?
    let carouselPromotionCode: [String]?
    let carouselPromocodeBackgroundColor: [UIColor]?
    let carouselPromocodeTextColor: [UIColor]?
    let carouselButtonText: [String]?
    let carouselButtonTextColor: [UIColor]?
    let carouselButtonColor: [UIColor]?
    let carouselButtonFontFamilyIOS: [String]?
    let carouselButtonTextSize: [String]?
    let carouselBackgroundImage: [String]?
    let carouselBackgrounColor: [UIColor]?
    let carouselIOSLink: [String]?

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
    /// Second Popup First Image
    var secondImageUrl1: URL?
    lazy var secondImage1: Data? = {
        var data: Data?
        if let iUrl = self.secondImageUrl1 {
            do {
                data = try Data(contentsOf: iUrl, options: [.mappedIfSafe])
            } catch {
                VisilabsLogger.error("image failed to load from url \(iUrl)")
            }
        }
        return data
    }()
    /// Second Popup Second Image
    var secondImageUrl2: URL?
    lazy var secondImage2: Data? = {
        var data: Data?
        if let iUrl = self.secondImageUrl2 {
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
    var carouselTitleFont: [UIFont] = [UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2),
                                           size: CGFloat(12))]
    var carouselBodyFont: [UIFont] = [UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body),
                                          size: CGFloat(8))]
    var carouselButtonFont: [UIFont] = [UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body),
                                            size: CGFloat(8))]

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
                messageTitleTextSize: String?,
                messageBodyColor: String?,
                messageBodyTextSize: String?,
                fontFamily: String?,
                customFont: String?,
                closePopupActionType:String?,
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
                waitingTime: Int?,
                secondPopupType: VisilabsSecondPopupType?,
                secondPopupTitle: String?,
                secondPopupBody: String?,
                secondPopupBodyTextSize: String?,
                secondPopupButtonText: String?,
                secondImageUrlString1: String?,
                secondImageUrlString2: String?,
                secondPopupMinPoint: String?,
                previousPopupPoint: Double? = nil,
                position: VisilabsHalfScreenPosition?,
                carouselItems: String?,
                carouselImage: [String]?,
                carouselTitle: [String]?,
                carouselTitleColor: [String]?,
                carouselTitleFontFamilyIOS: [String]?,
                carouselTitleTextSize: [String]?,
                carouselBody: [String]?,
                carouselBodyColor: [String]?,
                carouselBodyFontFamilyIOS: [String]?,
                carouselBodyTextSize: [String]?,
                carouselPromocodeType: [String]?,
                carouselPromotionCode: [String]?,
                carouselPromocodeBackgroundColor: [String]?,
                carouselPromocodeTextColor: [String]?,
                carouselButtonText: [String]?,
                carouselButtonTextColor: [String]?,
                carouselButtonColor: [String]?,
                carouselButtonFontFamilyIOS: [String]?,
                carouselButtonTextSize: [String]?,
                carouselBackgroundImage: [String]?,
                carouselBackgrounColor: [String]?,
                carouselIOSLink: [String]?
    )
    {

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
        self.messageTitleTextSize = messageTitleTextSize
        self.messageBodyColor = UIColor(hex: messageBodyColor)
        self.messageBodyTextSize = messageBodyTextSize
        self.fontFamily = fontFamily
        self.customFont = customFont
        self.closePopupActionType = closePopupActionType
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
        self.secondPopupType = secondPopupType
        self.secondPopupTitle = secondPopupTitle
        self.secondPopupBody = secondPopupBody
        self.secondPopupBodyTextSize = secondPopupBodyTextSize
        self.secondPopupButtonText = secondPopupButtonText
        self.secondImageUrlString1 = secondImageUrlString1
        self.secondImageUrlString2 = secondImageUrlString2
        self.secondPopupMinPoint = secondPopupMinPoint
        if !secondImageUrlString1.isNilOrWhiteSpace {
            self.secondImageUrl1 = VisilabsInAppNotification.getImageUrl(secondImageUrlString1!, type: self.type)
        }
        if !secondImageUrlString2.isNilOrWhiteSpace {
            self.secondImageUrl2 = VisilabsInAppNotification.getImageUrl(secondImageUrlString2!, type: self.type)
        }
        self.previousPopupPoint = previousPopupPoint
        self.position = position
        self.carouselImage = carouselImage
        self.carouselTitle = carouselTitle
        self.carouselTitleColor = VisilabsHelper.convertColorArray(carouselTitleColor)
        self.carouselTitleFontFamilyIOS = carouselTitleFontFamilyIOS
        self.carouselTitleTextSize = carouselTitleTextSize
        self.carouselBody = carouselBody
        self.carouselBodyColor = VisilabsHelper.convertColorArray(carouselBodyColor)
        self.carouselBodyFontFamilyIOS = carouselBodyFontFamilyIOS
        self.carouselBodyTextSize = carouselBodyTextSize
        self.carouselPromocodeType = carouselPromocodeType
        self.carouselPromotionCode = carouselPromotionCode
        self.carouselPromocodeBackgroundColor = VisilabsHelper.convertColorArray(carouselPromocodeBackgroundColor)
        self.carouselPromocodeTextColor = VisilabsHelper.convertColorArray(carouselPromocodeTextColor)
        self.carouselButtonText = carouselButtonText
        self.carouselButtonTextColor = VisilabsHelper.convertColorArray(carouselButtonTextColor)
        self.carouselButtonColor = VisilabsHelper.convertColorArray(carouselButtonColor)
        self.carouselButtonFontFamilyIOS = carouselButtonFontFamilyIOS
        self.carouselButtonTextSize = carouselButtonTextSize
        self.carouselBackgroundImage = carouselBackgroundImage
        self.carouselBackgrounColor = VisilabsHelper.convertColorArray(carouselBackgrounColor)
        self.carouselIOSLink = carouselIOSLink
        
        setFonts()
    }
    
    // swiftlint:disable function_body_length disable cyclomatic_complexity
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
        
        guard let carouselItems = actionData[PayloadKey.carouselItems] as? [String: Any?] else {
            VisilabsLogger.error("invalid \(PayloadKey.carouselItems)")
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
        let messageBodyTextSize = actionData[PayloadKey.messageBodyTextSize] as? String
        self.messageBodyTextSize = messageBodyTextSize
        self.messageTitleTextSize = actionData[PayloadKey.messageTitleTextSize] as? String ?? messageBodyTextSize
        self.fontFamily = actionData[PayloadKey.fontFamily] as? String
        self.customFont = actionData[PayloadKey.customFont] as? String
        self.closePopupActionType = actionData[PayloadKey.closePopupActionType] as? String
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

        // Second Popup Variables
        if let secondType = actionData[PayloadKey.secondPopupType] as? String {
            self.secondPopupType = VisilabsSecondPopupType.init(rawValue: secondType)
        } else {
            self.secondPopupType = nil
        }
        self.secondPopupTitle = actionData[PayloadKey.secondPopupTitle] as? String
        self.secondPopupBody = actionData[PayloadKey.secondPopupBody] as? String
        self.secondPopupBodyTextSize = actionData[PayloadKey.secondPopupBodyTextSize] as? String
        self.secondPopupButtonText = actionData[PayloadKey.secondPopupButtonText] as? String
        self.secondImageUrlString1 = actionData[PayloadKey.secondImageUrlString1] as? String
        self.secondImageUrlString2 = actionData[PayloadKey.secondImageUrlString2] as? String
        if !secondImageUrlString1.isNilOrWhiteSpace {
            self.secondImageUrl1 = VisilabsInAppNotification.getImageUrl(imageUrlString!, type: self.type)
        }
        if !secondImageUrlString2.isNilOrWhiteSpace {
            self.secondImageUrl2 = VisilabsInAppNotification.getImageUrl(imageUrlString!, type: self.type)
        }
        self.secondPopupMinPoint = actionData[PayloadKey.secondPopupMinPoint] as? String
        self.previousPopupPoint = nil
        
        if let positionString = actionData[PayloadKey.position] as? String
            , let position = VisilabsHalfScreenPosition.init(rawValue: positionString) {
            self.position = position
        } else {
            self.position = .bottom
        }
        self.carouselImage = carouselItems[PayloadKey.carouselImage] as? [String]
        self.carouselTitle = carouselItems[PayloadKey.carouselTitle] as? [String]
        self.carouselTitleColor = carouselItems[PayloadKey.carouselTitleColor] as? [UIColor]
        self.carouselTitleFontFamilyIOS = carouselItems[PayloadKey.carouselTitleFontFamilyIOS] as? [String]
        self.carouselTitleTextSize = carouselItems[PayloadKey.carouselTitleTextSize] as? [String]
        self.carouselBody = carouselItems[PayloadKey.carouselBody] as? [String]
        self.carouselBodyColor = carouselItems[PayloadKey.carouselBodyColor] as? [UIColor]
        self.carouselBodyFontFamilyIOS = carouselItems[PayloadKey.carouselBodyFontFamilyIOS] as? [String]
        self.carouselBodyTextSize = carouselItems[PayloadKey.carouselBodyTextSize] as? [String]
        self.carouselPromocodeType = carouselItems[PayloadKey.carouselPromocodeType] as? [String]
        self.carouselPromotionCode = carouselItems[PayloadKey.carouselPromotionCode] as? [String]
        self.carouselPromocodeBackgroundColor = carouselItems[PayloadKey.carouselPromocodeBackgroundColor] as? [UIColor]
        self.carouselPromocodeTextColor = carouselItems[PayloadKey.carouselPromocodeTextColor] as? [UIColor]
        self.carouselButtonText = carouselItems[PayloadKey.carouselButtonText] as? [String]
        self.carouselButtonTextColor = carouselItems[PayloadKey.carouselButtonTextColor] as? [UIColor]
        self.carouselButtonColor = carouselItems[PayloadKey.carouselButtonColor] as? [UIColor]
        self.carouselButtonFontFamilyIOS = carouselItems[PayloadKey.carouselButtonFontFamilyIOS] as? [String]
        self.carouselButtonTextSize = carouselItems[PayloadKey.carouselButtonTextSize] as? [String]
        self.carouselBackgroundImage = carouselItems[PayloadKey.carouselBackgroundImage] as? [String]
        self.carouselBackgrounColor = carouselItems[PayloadKey.carouselBackgrounColor] as? [UIColor]
        self.carouselIOSLink = carouselItems[PayloadKey.carouselIOSLink] as? [String]
        
        
        setFonts()
    }

    private func setFonts() {
        self.messageTitleFont = VisilabsInAppNotification.getFont(fontFamily: self.fontFamily,
                                                                  fontSize: self.messageTitleTextSize,
                                                                  style: .title2, customFont: self.customFont)
        self.messageBodyFont = VisilabsInAppNotification.getFont(fontFamily: self.fontFamily,
                                                                 fontSize: self.messageBodyTextSize,
                                                                 style: .body, customFont: self.customFont)
        self.buttonTextFont = VisilabsInAppNotification.getFont(fontFamily: self.fontFamily,
                                                                fontSize: self.messageBodyTextSize,
                                                                style: .title2, customFont: self.customFont)
    }

    static func getFont(fontFamily: String?, fontSize: String?, style: UIFont.TextStyle,customFont:String? = "") -> UIFont {
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

            if let uiCustomFont = UIFont(name: customFont ?? "", size: CGFloat(size)) {
                return uiCustomFont
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
