//
//  ChooseFavoriteModel.swift
//  RelatedDigitalIOS
//
//  Created by Orhun Akmil on 18.07.2024.
//

import UIKit



struct CustomWebViewModel: TargetingActionViewModel, Codable {
    
    var targetingActionType: TargetingActionType = .mobileCustomActions
    var actId: Int? = 0
    var title = String()
    var auth = String()
    var fontFiles: [String] = []
    public var jsContent: String?
    public var jsonContent: String?
    public var htmlContent: String? //html

    
    //prome banner params
    var custom_font_family_ios = String()
    var promocode_banner_button_label = String()
    var promocode_banner_text = String()
    var promocode_banner_text_color = String()
    var promocode_banner_background_color = String()
    var copybutton_color = String()
    var copybutton_text_color = String()
    var copybutton_text_size = String()
    var close_button_color = String()
    var font_family = String()
    //
    
    
    var position = String()
    var width = Float()
    var height = Float()
    var closeButtonColor = String()
    var borderRadius = Float()
    var waitingTime: Int = 0

    
    
    
    
    var report: CustomWebViewReport? = CustomWebViewReport()
    var bannercodeShouldShow : Bool?

    
}


public struct CustomWebViewReport: Codable {
    var impression: String?
    var click: String?
}
