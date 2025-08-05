//
//  PollModel.swift
//  CleanyModal
//
//  Created by Orhun Akmil on 30.07.2025.
//

import Foundation


struct PollModel: TargetingActionViewModel, Codable {
    
    var targetingActionType: TargetingActionType
    var actId: Int? = 0
    var title = String()
    var auth = String()
    var fontFiles: [String] = []
    public var jsContent: String?
    public var jsonContent: String?
    
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
    var report: PollReport? = PollReport()
    var bannercodeShouldShow : Bool?
    var waitingTime: Int = 0

}

public struct PollReport: Codable {
    var impression: String?
    var click: String?
}
