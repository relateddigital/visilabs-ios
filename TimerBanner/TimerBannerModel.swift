//
//  TimerBannerModel.swift
//  Pods
//
//  Created by Orhun Akmil on 6.11.2025.

import Foundation

struct CountdownTimerBannerModel: TargetingActionViewModel {

    public var targetingActionType: TargetingActionType
    
    var actId: Int?
    var title: String?
    var jsContent: String?
    var jsonContent: String?
    
    var report: CountdownTimerReport?
    
    var waitingTime: Int = 0
    
    // Action data
    var scratch_color: String?
    
    var ios_lnk: String?
    var android_lnk: String?
    var img: String?
    
    var content_body: String?
    var counter_Date: String?
    var counter_Time: String?
    
    
    // Extended Props decoded (opsiyonel)
    var background_color: String?
    var counter_color: String?
    var close_button_color: String?
    var content_body_text_color: String?
    var position_on_page: String?
    var content_body_font_family : String?
    var txtStartDate: String?
    
}

public struct CountdownTimerReport: Codable {
    var impression: String?
    var click: String?
}
