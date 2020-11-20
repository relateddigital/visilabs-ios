//
//  MailSubscriptionModel.swift
//  VisilabsIOS
//
//  Created by Said Alır on 20.11.2020.
//

import Foundation

struct MailSubscriptionModel {
    var title: String
    var message: String
    var buttonTitle: String
    var consentText: String 
    var successMessage: String
    var invalidEmailMessage: String
    var emailPermitText: String
    var extendedProps: MailSubscriptionExtendedProps
    var checkConsentMessage: String
}

struct MailSubscriptionExtendedProps {
    var titleTextColor: String //Hex
    var titleFontFamily: String
    var titleFontSize: Int
    var textColor: String //Hex
    var textFontFamily: String
    var textSize: Int
    var buttonColor: String //Hex
    var buttonFontFamily: String
    var buttonTextSize: Int
    var emailPermitTextSize: Int
    var emailPermitURL: String
    var consentTextSize: Int
    var consentTextUrl: String
    var closeButtonColor: ButtonColor
    var backgroundColor: String //Hex
}

enum ButtonColor {
    case black
    case white
}
