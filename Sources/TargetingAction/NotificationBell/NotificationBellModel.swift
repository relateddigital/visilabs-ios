//
//  NotificationBellModel.swift
//  CleanyModal
//
//  Created by Orhun Akmil on 8.09.2025.
//

import Foundation



struct NotificationBellModel : TargetingActionViewModel 
{
    
    public var targetingActionType: TargetingActionType = .notificationBell
    var actId:Int?
    var title:String?
    var jsContent: String?
    var jsonContent: String?
    
    var notifTitle:String?

    var report: NotificationBellReport?
    
    var waitingTime: Int = 0

    
    var bellElems : [bellElement]? = [bellElement]()
    var bellIcon : String?
    var bellAnimation : String?

    //extended Props
    var background_color:String?
    var font_family:String?
    var title_text_color:String?
    var title_text_size:String?
    
    var text_text_color:String?
    var text_text_size:String?

    
}


public struct NotificationBellReport: Codable {
    var impression: String
    var click: String
}


public struct bellElement {
    
    var text: String?
    var ios_lnk : String?
    
}
