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
        public static let buttonFunction = "button_function"
        public static let imageUrlString = "img"
        public static let visitorData = "visitor_data"
        public static let visitData = "visit_data"
        public static let queryString = "qs"
        public static let messageTitleColor = "msg_title_color"
        public static let messageTitleBackgroundColor = "msg_title_backgroundcolor"
        public static let messageTitleTextSize = "msg_title_textsize"
        public static let messageBodyColor = "msg_body_color"
        public static let messageBodyBackgroundColor = "msg_body_backgroundcolor"
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
        public static let videourl = "videourl"
        public static let secondPopupVideourl1 = "secondPopup_videourl1"
        public static let secondPopupVideourl2 = "secondPopup_videourl2"
    }

    let actId: Int
    let messageType: String
    let type: VisilabsInAppNotificationType
    let messageTitle: String?
    let messageBody: String?
    let buttonText: String?
    public let iosLink: String?
    let buttonFunction: String?
    let imageUrlString: String?
    let visitorData: String?
    let visitData: String?
    let queryString: String?
    let messageTitleColor: UIColor?
    let messageTitleBackgroundColor: UIColor?
    let messageTitleTextSize: String?
    let messageBodyColor: UIColor?
    let messageBodyBackgroundColor: UIColor?
    let messageBodyTextSize: String?
    let fontFamily: String?
    let customFont: String?
    public let backGroundColor: UIColor?
    var closeButtonColor: UIColor?
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
    public var carouselItems: [VisilabsCarouselItem] = [VisilabsCarouselItem]()
    let videourl: String?
    let secondPopupVideourl1: String?
    let secondPopupVideourl2: String?

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

    public init(actId: Int,
                type: VisilabsInAppNotificationType,
                messageTitle: String?,
                messageBody: String?,
                buttonText: String?,
                iosLink: String?,
                buttonFunction: String?,
                imageUrlString: String?,
                visitorData: String?,
                visitData: String?,
                queryString: String?,
                messageTitleColor: String?,
                messageTitleBackgroundColor: String?,
                messageTitleTextSize: String?,
                messageBodyColor: String?,
                messageBodyBackgroundColor: String?,
                messageBodyTextSize: String?,
                fontFamily: String?,
                customFont: String?,
                closePopupActionType: String?,
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
                carouselItems: [VisilabsCarouselItem]? = nil,
                videourl: String?,
                secondPopupVideourl1: String?,
                secondPopupVideourl2: String?) {
        self.actId = actId
        messageType = type.rawValue
        self.type = type
        self.messageTitle = messageTitle
        self.messageBody = messageBody
        self.buttonText = buttonText
        self.iosLink = iosLink
        self.buttonFunction = buttonFunction
        self.imageUrlString = imageUrlString
        self.visitorData = visitorData
        self.visitData = visitData
        self.queryString = queryString
        self.messageTitleColor = UIColor(hex: messageTitleColor)
        self.messageTitleBackgroundColor = UIColor(hex: messageTitleBackgroundColor)
        self.messageTitleTextSize = messageTitleTextSize
        self.messageBodyColor = UIColor(hex: messageBodyColor)
        self.messageBodyBackgroundColor = UIColor(hex: messageBodyBackgroundColor)
        self.messageBodyTextSize = messageBodyTextSize
        self.fontFamily = fontFamily
        self.customFont = customFont
        self.closePopupActionType = closePopupActionType
        backGroundColor = UIColor(hex: backGround)
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
            imageUrl = VisilabsHelper.getImageUrl(imageUrlString!, type: self.type)
        }

        var callToActionUrl: URL?
        if let buttonFunction = buttonFunction {
            if buttonFunction == "link" || buttonFunction == "" {
                if let urlString = iosLink {
                    callToActionUrl = URL(string: urlString)
                }
            } else if buttonFunction == "redirect" {
                callToActionUrl = URL(string: "redirect")
            }
        } else {
            if let urlString = iosLink {
                callToActionUrl = URL(string: urlString)
            }
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
            secondImageUrl1 = VisilabsHelper.getImageUrl(secondImageUrlString1!, type: self.type)
        }
        if !secondImageUrlString2.isNilOrWhiteSpace {
            secondImageUrl2 = VisilabsHelper.getImageUrl(secondImageUrlString2!, type: self.type)
        }
        self.previousPopupPoint = previousPopupPoint
        self.position = position
        if let carouselItems = carouselItems {
            self.carouselItems = carouselItems
        }

        self.videourl = videourl
        self.secondPopupVideourl1 = secondPopupVideourl1
        self.secondPopupVideourl2 = secondPopupVideourl2
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

        guard let messageType = actionData[PayloadKey.messageType] as? String,
              let type = VisilabsInAppNotificationType(rawValue: messageType) else {
            VisilabsLogger.error("invalid \(PayloadKey.messageType)")
            return nil
        }

        self.actId = actId
        self.messageType = messageType
        self.type = type
        messageTitle = actionData[PayloadKey.messageTitle] as? String
        messageBody = actionData[PayloadKey.messageBody] as? String
        buttonText = actionData[PayloadKey.buttonText] as? String
        iosLink = actionData[PayloadKey.iosLink] as? String
        buttonFunction = actionData[PayloadKey.buttonFunction] as? String
        imageUrlString = actionData[PayloadKey.imageUrlString] as? String
        visitorData = actionData[PayloadKey.visitorData] as? String
        visitData = actionData[PayloadKey.visitData] as? String
        queryString = actionData[PayloadKey.queryString] as? String
        messageTitleColor = UIColor(hex: actionData[PayloadKey.messageTitleColor] as? String)
        messageTitleBackgroundColor = UIColor(hex: actionData[PayloadKey.messageTitleBackgroundColor] as? String)
        messageBodyColor = UIColor(hex: actionData[PayloadKey.messageBodyColor] as? String)
        messageBodyBackgroundColor = UIColor(hex: actionData[PayloadKey.messageBodyBackgroundColor] as? String)
        messageBodyTextSize = actionData[PayloadKey.messageBodyTextSize] as? String
        messageTitleTextSize = actionData[PayloadKey.messageTitleTextSize] as? String ?? messageBodyTextSize
        fontFamily = actionData[PayloadKey.fontFamily] as? String
        customFont = actionData[PayloadKey.customFont] as? String
        closePopupActionType = actionData[PayloadKey.closePopupActionType] as? String
        backGroundColor = UIColor(hex: actionData[PayloadKey.backGround] as? String)
        promotionCode = actionData[PayloadKey.promotionCode] as? String
        promotionTextColor = UIColor(hex: actionData[PayloadKey.promotionTextColor] as? String)
        promotionBackgroundColor = UIColor(hex: actionData[PayloadKey.promotionBackgroundColor] as? String)
        var closeButtonColor: UIColor?
        if let cBColor = actionData[PayloadKey.closeButtonColor] as? String {
            if cBColor.lowercased() == "white" {
                closeButtonColor = UIColor.white
            } else if cBColor.lowercased() == "black" {
                closeButtonColor = UIColor.black
            } else {
                closeButtonColor = UIColor(hex: cBColor)
            }
        } else {
            closeButtonColor = nil
        }
        self.closeButtonColor = closeButtonColor

        buttonTextColor = UIColor(hex: actionData[PayloadKey.buttonTextColor] as? String)
        buttonColor = UIColor(hex: actionData[PayloadKey.buttonColor] as? String)

        if !imageUrlString.isNilOrWhiteSpace {
            imageUrl = VisilabsHelper.getImageUrl(imageUrlString!, type: self.type)
        }

        var callToActionUrl: URL?
        if let buttonFunction = buttonFunction {
            if buttonFunction == "link" || buttonFunction == "" {
                if let urlString = iosLink {
                    callToActionUrl = URL(string: urlString)
                }
            } else if buttonFunction == "redirect" {
                callToActionUrl = URL(string: "redirect")
            }
        } else {
            if let urlString = iosLink {
                callToActionUrl = URL(string: urlString)
            }
        }

        self.callToActionUrl = callToActionUrl
        alertType = actionData[PayloadKey.alertType] as? String
        closeButtonText = actionData[PayloadKey.closeButtonText] as? String
        if let numColors = actionData[PayloadKey.numberColors] as? [String]? {
            numberColors = VisilabsHelper.convertColorArray(numColors)
        } else {
            numberColors = nil
        }
        waitingTime = actionData[PayloadKey.waitingTime] as? Int

        // Second Popup Variables
        if let secondType = actionData[PayloadKey.secondPopupType] as? String {
            secondPopupType = VisilabsSecondPopupType(rawValue: secondType)
        } else {
            secondPopupType = nil
        }
        secondPopupTitle = actionData[PayloadKey.secondPopupTitle] as? String
        secondPopupBody = actionData[PayloadKey.secondPopupBody] as? String
        secondPopupBodyTextSize = actionData[PayloadKey.secondPopupBodyTextSize] as? String
        secondPopupButtonText = actionData[PayloadKey.secondPopupButtonText] as? String
        secondImageUrlString1 = actionData[PayloadKey.secondImageUrlString1] as? String
        secondImageUrlString2 = actionData[PayloadKey.secondImageUrlString2] as? String
        if !secondImageUrlString1.isNilOrWhiteSpace {
            secondImageUrl1 = VisilabsHelper.getImageUrl(imageUrlString!, type: self.type)
        }
        if !secondImageUrlString2.isNilOrWhiteSpace {
            secondImageUrl2 = VisilabsHelper.getImageUrl(imageUrlString!, type: self.type)
        }
        videourl = actionData[PayloadKey.videourl] as? String
        secondPopupVideourl1 = actionData[PayloadKey.secondPopupVideourl1] as? String
        secondPopupVideourl2 = actionData[PayloadKey.secondPopupVideourl2] as? String
        secondPopupMinPoint = actionData[PayloadKey.secondPopupMinPoint] as? String
        previousPopupPoint = nil

        if let positionString = actionData[PayloadKey.position] as? String
            , let position = VisilabsHalfScreenPosition(rawValue: positionString) {
            self.position = position
        } else {
            position = .bottom
        }

        var carouselItems = [VisilabsCarouselItem]()

        if let carouselItemObjects = actionData[PayloadKey.carouselItems] as? [[String: Any]] {
            for carouselItemObject in carouselItemObjects {
                if let carouselItem = VisilabsCarouselItem(JSONObject: carouselItemObject) {
                    carouselItems.append(carouselItem)
                }
            }
        }

        self.carouselItems = carouselItems.map { (item) -> VisilabsCarouselItem in
            item.closeButtonColor = closeButtonColor
            return item
        }

        setFonts()
    }

    private func setFonts() {
        messageTitleFont = VisilabsHelper.getFont(fontFamily: fontFamily,
                                                  fontSize: messageTitleTextSize,
                                                  style: .title2, customFont: customFont)
        messageBodyFont = VisilabsHelper.getFont(fontFamily: fontFamily,
                                                 fontSize: messageBodyTextSize,
                                                 style: .body, customFont: customFont)
        buttonTextFont = VisilabsHelper.getFont(fontFamily: fontFamily,
                                                fontSize: messageBodyTextSize,
                                                style: .title2, customFont: customFont)
    }
}
