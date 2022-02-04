//
//  CarouselViewModel.swift
//  VisilabsIOS
//
//  Created by Said Alır on 31.03.2021.
//

import UIKit

class CarouselViewModel {
    
    var image: UIImage?
    var title: String?
    var titleFont: UIFont?
    var titleColor: UIColor?
    var message: String?
    var messageFont: UIFont?
    var messageColor: UIColor?
    var buttonText: String?
    var buttonFont: UIFont?
    var buttonTextColor: UIColor?
    var backgroundColor: UIColor?
    var buttonBgColor: UIColor?
    var buttonLink: URL?
    
    init(image: Data?,
         title: String?,
         titleTextSize: String?,
         titleTextColor: String?,
         titleFontFamily: String?,
         message: String?,
         messageTextSize: String?,
         messageTextColor: String?,
         messageFontFamily: String?,
         buttonText: String?,
         buttonTextColor: String?,
         buttonTextSize: String?,
         buttonFontFamily: String?,
         buttonBackgroundColor: String?,
         backgroundColor: String?,
         link: String?) {

        if let img = image {
            self.image = UIImage(data: img)
        }
        
        self.title = title
        self.titleFont = RelatedDigitalInAppNotification.getFont(fontFamily: titleFontFamily, fontSize: titleTextSize, style: .title2)
        self.messageFont = RelatedDigitalInAppNotification.getFont(fontFamily: messageFontFamily, fontSize: messageTextSize, style: .body)
        self.buttonFont = RelatedDigitalInAppNotification.getFont(fontFamily: buttonFontFamily, fontSize: buttonTextSize, style: .title2)
        self.titleColor = UIColor(hex: titleTextColor)
        self.messageColor = UIColor(hex: messageTextColor)
        self.buttonTextColor = UIColor(hex: buttonTextColor)
        self.backgroundColor = UIColor(hex: backgroundColor)
        self.buttonBgColor = UIColor(hex: buttonBackgroundColor)
        if let url = link {
            self.buttonLink = URL(string: url)
        } else {
            self.buttonLink = nil
        }
    }
    
}
