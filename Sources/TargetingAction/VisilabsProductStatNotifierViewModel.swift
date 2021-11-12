//
//  VisilabsProductStatNotifierViewModel.swift
//  VisilabsIOS
//
//  Created by Said Alır on 21.02.2021.
//

import UIKit

public struct VisilabsProductStatNotifierViewModel: TargetingActionViewModel {
    public var targetingActionType: TargetingActionType
    var content: String
    var timeout: String
    var position: VisilabsProductStatNotifierPosition
    var bgcolor: String
    var threshold: Int
    var showclosebtn: Bool
    var content_text_color: String
    var content_font_family: String
    var content_text_size: String
    var contentcount_text_color: String
    var contentcount_text_size: String
    var closeButtonColor: String
    
    func getContentFont() -> UIFont {
        return VisilabsInAppNotification.getFont(fontFamily: content_font_family, fontSize: content_text_size, style: .title2)
    }
    
    func getContentCountFont() -> UIFont {
        return VisilabsInAppNotification.getFont(fontFamily: content_font_family, fontSize: contentcount_text_size, style: .title2)
    }
}
