//
//  SpinToWinModel.swift
//  VisilabsIOS
//
//  Created by Egemen Gulkilik on 5.03.2021.
//

import Foundation

public struct SpinToWinSliceViewModel: Codable {
    var displayName: String
    var color: String
    var code: String
    var type: String
}

public struct SpinToWinViewModel : TargetingActionViewModel, Codable {
    public var targetingActionType: TargetingActionType
    var actId: Int
    var auth: String
    var promoAuth: String
    var type: String
    var title: String
    var message: String
    var placeholder: String
    var buttonLabel: String
    var consentText: String
    var emailPermitText: String
    var successMessage: String
    var invalidEmailMessage: String
    var checkConsentMessage: String
    var promocodeTitle: String
    var copyButtonLabel: String
    var mailSubscription: Bool
    var sliceCount: String
    var slices: [SpinToWinSliceViewModel]
    var report: SpinToWinReport
    var taTemplate: String
    var img: String
    
    
    //ExtendedProps
    var displaynameTextColor: String
    var displaynameFontFamily: String
    var displaynameTextSize: String
    var titleTextColor: String
    var titleFontFamily: String
    var titleTextSize: String
    var textColor: String
    var textFontFamily: String
    var textSize: String
    var buttonColor: String
    var buttonTextColor: String
    var buttonFontFamily: String
    var buttonTextSize: String
    var promocodeTitleTextColor: String
    var promocodeTitleFontFamily: String
    var promocodeTitleTextSize: String
    var promocodeBackgroundColor: String
    var promocodeTextColor: String
    var copybuttonColor: String
    var copybuttonTextColor: String
    var copybuttonFontFamily: String
    var copybuttonTextSize: String
    var emailpermitTextSize: String
    var emailpermitTextUrl: String
    var consentTextSize: String
    var consentTextUrl: String
    var closeButtonColor: String
    var backgroundColor: String
}

public struct SpinToWinReport: Codable {
    var impression: String
    var click: String
}

