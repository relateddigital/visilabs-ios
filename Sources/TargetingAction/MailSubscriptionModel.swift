//
//  MailSubscriptionModel.swift
//  VisilabsIOS
//
//  Created by Said Alır on 20.11.2020.
//

import UIKit

public struct MailSubscriptionModel {
    var auth: String
    var title: String
    var message: String
    var actid: Int
    var type: String
    var placeholder: String
    var buttonTitle: String
    var consentText: String?
    var successMessage: String
    var invalidEmailMessage: String
    var emailPermitText: String
    var extendedProps: MailSubscriptionExtendedProps
    var checkConsentMessage: String
    var report: TargetingActionReport
}

public struct MailSubscriptionExtendedProps {
    var titleTextColor: String
    var titleFontFamily: String
    var titleTextSize: String
    var textColor: String
    var textFontFamily: String
    var textSize: String
    var buttonColor: String
    var buttonTextColor: String
    var buttonTextSize: String
    var buttonFontFamily: String
    var emailPermitTextSize: String
    var emailPermitTextUrl: String
    var consentTextSize: String
    var consentTextUrl: String
    var closeButtonColor: ButtonColor
    var backgroundColor: String
    
    var titleCustomFontFamilyIos: String
    var textCustomFontFamilyIos: String
    var buttonCustomFontFamilyIos: String
}

public enum ButtonColor: String {
    case black
    case white
}

public struct MailSubscriptionViewModel: TargetingActionViewModel {
    public var targetingActionType: TargetingActionType
    var auth: String
    var actId: Int
    var type: String
    var title: String
    var message: String
    var placeholder: String
    var buttonTitle: String
    var consentText: ParsedPermissionString?
    var permitText: ParsedPermissionString
    var successMessage: String
    var invalidEmailMessage: String
    var checkConsentMessage: String
    var titleFont: UIFont
    var messageFont: UIFont
    var buttonFont: UIFont
    var buttonTextColor: UIColor
    var buttonColor: UIColor
    var emailPermitUrl: URL?
    var consentUrl: URL?
    var closeButtonColor: UIColor
    var titleColor: UIColor
    var textColor: UIColor
    var backgroundColor: UIColor
    var permitTextSize: Int
    var consentTextSize: Int
    var report: TargetingActionReport
}

public struct TargetingActionReport {
    var impression: String
    var click: String
}
