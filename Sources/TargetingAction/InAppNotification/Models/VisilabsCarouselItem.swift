//
//  VisilabsCarouselItem.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 2.02.2022.
//

import UIKit

// swiftlint:disable type_body_length
public class VisilabsCarouselItem {
    
    public enum PayloadKey {
        public static let imageUrlString = "image"
        public static let title = "title"
        public static let titleColor = "title_color"
        public static let titleFontFamily = "title_font_family"
        public static let title_custom_font_family_ios = "title_custom_font_family_ios"
        public static let title_textsize = "title_textsize"
        public static let body = "body"
        public static let body_color = "body_color"
        public static let body_font_family = "body_font_family"
        public static let body_custom_font_family_ios = "body_custom_font_family_ios"
        public static let body_textsize = "body_textsize"
        public static let promocode_type = "promocode_type"
        public static let promotion_code = "promotion_code"
        public static let promocode_background_color = "promocode_background_color"
        public static let promocode_text_color = "promocode_text_color"
        public static let button_text = "button_text"
        public static let button_text_color = "button_text_color"
        public static let button_color = "button_color"
        public static let button_font_family = "button_font_family"
        public static let button_custom_font_family_ios = "button_custom_font_family_ios"
        public static let button_textsize = "button_textsize"
        public static let background_image = "background_image"
        public static let background_color = "background_color"
        public static let ios_lnk = "ios_lnk"
        public static let close_button_color = "close_button_color"
    }
    
    public let imageUrlString: String?
    public let title: String?
    public let titleColor: UIColor?
    public let titleFontFamily: String?
    public let titleCustomFontFamily: String?
    public let titleTextsize: String?
    public let body: String?
    public let bodyColor: UIColor?
    public let bodyFontFamily: String?
    public let bodyCustomFontFamily: String?
    public let bodyTextsize: String?
    public let promocodeType: String?
    public let promotionCode: String?
    public let promocodeBackgroundColor: UIColor?
    public let promocodeTextColor: UIColor?
    public let buttonText: String?
    public let buttonTextColor: UIColor?
    public let buttonColor: UIColor?
    public let buttonFontFamily: String?
    public let buttonCustomFontFamily: String?
    public let buttonTextsize: String?
    public let backgroundImage: String?
    public let backgroundColor: UIColor?
    public let link: String?
    public var closeButtonColor: UIColor?
    
    var titleFont: UIFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2), size: CGFloat(12))
    var bodyFont: UIFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body), size: CGFloat(8))
    var buttonFont: UIFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body), size: CGFloat(8))
    
    
    var imageUrl: URL? = nil
    public lazy var image: Data? = {
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
    
    
    public var fetchImageBlock: FetchImageBlock? = nil
    
    
    public init(imageUrlString: String?, title: String?, titleColor: String?, titleFontFamily: String?, titleCustomFontFamily: String?
                ,titleTextsize: String?, body: String?, bodyColor: UIColor?, bodyFontFamily: String?, bodyCustomFontFamily: String?
                ,bodyTextsize: String?, promocodeType: String?, promotionCode: String?, promocodeBackgroundColor: UIColor?
                ,promocodeTextColor: UIColor?, buttonText: String?, buttonTextColor: UIColor?, buttonColor: UIColor?
                ,buttonFontFamily: String?, buttonCustomFontFamily: String?, buttonTextsize: String?, backgroundImage: String?
                ,backgroundColor: UIColor?, link: String?, closeButtonColor: UIColor?) {
        self.imageUrlString = imageUrlString
        self.title = title
        self.titleColor = UIColor(hex: titleColor)
        self.titleFontFamily = titleFontFamily
        self.titleCustomFontFamily = titleCustomFontFamily
        self.titleTextsize = titleTextsize
        self.body = body
        self.bodyColor = bodyColor
        self.bodyFontFamily = bodyFontFamily
        self.bodyCustomFontFamily = bodyCustomFontFamily
        self.bodyTextsize = bodyTextsize
        self.promocodeType = promocodeType
        self.promotionCode = promotionCode
        self.promocodeBackgroundColor = promocodeBackgroundColor
        self.promocodeTextColor = promocodeTextColor
        self.buttonText = buttonText
        self.buttonTextColor = buttonTextColor
        self.buttonColor = buttonColor
        self.buttonFontFamily = buttonFontFamily
        self.buttonCustomFontFamily = buttonCustomFontFamily
        self.buttonTextsize = buttonTextsize
        self.backgroundImage = backgroundImage
        self.backgroundColor = backgroundColor
        self.link = link
        
        if !imageUrlString.isNilOrWhiteSpace {
            self.imageUrl = VisilabsHelper.getImageUrl(imageUrlString!, type: .inappcarousel)
        }
        self.closeButtonColor = closeButtonColor
        
        self.setFonts()
        
        self.fetchImageBlock = { imageCompletion in
            if let imageUrlString = self.imageUrlString,  let url = URL(string: imageUrlString)
                , let imageData: Data = try? Data(contentsOf: url) {
                let image = UIImage(data: imageData as Data)
                imageCompletion(image, self)
            } else {
                imageCompletion(nil, self)
            }
        }
        
    }
    
    // swiftlint:disable function_body_length disable cyclomatic_complexity
    public init?(JSONObject: [String: Any]?) {
        guard let object = JSONObject else {
            VisilabsLogger.error("carouselitem json object should not be nil")
            return nil
        }
        
        self.imageUrlString = object[PayloadKey.imageUrlString] as? String
        self.title = object[PayloadKey.title] as? String
        self.titleColor = UIColor(hex: object[PayloadKey.titleColor] as? String)
        self.titleFontFamily = object[PayloadKey.titleFontFamily] as? String
        self.titleCustomFontFamily = object[PayloadKey.title_custom_font_family_ios] as? String
        self.titleTextsize = object[PayloadKey.title_textsize] as? String
        self.body = object[PayloadKey.body] as? String
        self.bodyColor = UIColor(hex: object[PayloadKey.body_color] as? String)
        self.bodyFontFamily = object[PayloadKey.body_font_family] as? String
        self.bodyCustomFontFamily = object[PayloadKey.body_custom_font_family_ios] as? String
        self.bodyTextsize = object[PayloadKey.body_textsize] as? String
        self.promocodeType = object[PayloadKey.promocode_type] as? String
        self.promotionCode = object[PayloadKey.promotion_code] as? String
        self.promocodeBackgroundColor = UIColor(hex: object[PayloadKey.promocode_background_color] as? String)
        self.promocodeTextColor = UIColor(hex: object[PayloadKey.promocode_text_color] as? String)
        self.buttonText = object[PayloadKey.button_text] as? String
        self.buttonTextColor = UIColor(hex: object[PayloadKey.button_text_color] as? String)
        self.buttonColor = UIColor(hex: object[PayloadKey.button_color] as? String)
        self.buttonFontFamily = object[PayloadKey.button_font_family] as? String
        self.buttonCustomFontFamily = object[PayloadKey.button_custom_font_family_ios] as? String
        self.buttonTextsize = object[PayloadKey.button_textsize] as? String
        self.backgroundImage = object[PayloadKey.background_image] as? String
        self.backgroundColor = UIColor(hex: object[PayloadKey.background_color] as? String)
        self.link = object[PayloadKey.ios_lnk] as? String
        
        if !imageUrlString.isNilOrWhiteSpace {
            self.imageUrl = VisilabsHelper.getImageUrl(imageUrlString!, type: .inappcarousel)
        }
        self.closeButtonColor = UIColor(hex: object[PayloadKey.close_button_color] as? String)
        
        self.titleFont = VisilabsHelper.getFont(fontFamily: self.titleFontFamily, fontSize: self.titleTextsize
                                                , style: .title2, customFont: self.titleCustomFontFamily)
        self.bodyFont = VisilabsHelper.getFont(fontFamily: self.bodyFontFamily, fontSize: self.bodyTextsize
                                               , style: .body, customFont: self.bodyCustomFontFamily)
        self.buttonFont = VisilabsHelper.getFont(fontFamily: self.buttonFontFamily, fontSize: self.buttonTextsize
                                                 , style: .title2, customFont: self.buttonCustomFontFamily)
        
        self.setFonts()
        
        self.fetchImageBlock = { imageCompletion in
            if let imageUrlString = self.imageUrlString,  let url = URL(string: imageUrlString)
                , let imageData: Data = try? Data(contentsOf: url) {
                let image = UIImage(data: imageData as Data)
                imageCompletion(image, self)
            } else {
                imageCompletion(nil, self)
            }
        }
        
    }

    
    private func setFonts() {
        self.titleFont = VisilabsHelper.getFont(fontFamily: self.titleFontFamily, fontSize: self.titleTextsize
                                                , style: .title2, customFont: self.titleCustomFontFamily)
        self.bodyFont = VisilabsHelper.getFont(fontFamily: self.bodyFontFamily, fontSize: self.bodyTextsize
                                               , style: .body, customFont: self.bodyCustomFontFamily)
        self.buttonFont = VisilabsHelper.getFont(fontFamily: self.buttonFontFamily, fontSize: self.buttonTextsize
                                                 , style: .title2, customFont: self.buttonCustomFontFamily)
    }
    
    
}

