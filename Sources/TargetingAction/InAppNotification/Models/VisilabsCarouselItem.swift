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
    }
    
    let imageUrlString: String?
    let title: String?
    let titleColor: UIColor?
    let titleFontFamily: String?
    
    public init(imageUrlString: String?, title: String?, titleColor: String?, titleFontFamily: String?) {
        self.imageUrlString = imageUrlString
        self.title = title
        self.titleColor = UIColor(hex: titleColor)
        self.titleFontFamily = titleFontFamily
    }
    
    // swiftlint:disable function_body_length disable cyclomatic_complexity
    init?(JSONObject: [String: Any]?) {
        guard let object = JSONObject else {
            VisilabsLogger.error("carouselitem json object should not be nil")
            return nil
        }
        
        self.imageUrlString = object[PayloadKey.imageUrlString] as? String
        self.title = object[PayloadKey.title] as? String
        self.titleColor = UIColor(hex: object[PayloadKey.titleColor] as? String)
        self.titleFontFamily = object[PayloadKey.titleFontFamily] as? String
    }
}


