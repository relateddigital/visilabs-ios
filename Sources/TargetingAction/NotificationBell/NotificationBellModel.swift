//
//  NotificationBellModel.swift
//  CleanyModal
//
//  Created by Orhun Akmil on 8.09.2025.
//

import Foundation



public struct NotificationBellModel : TargetingActionViewModel
{
    
    public var targetingActionType: TargetingActionType = .notificationBell
    public var actId:Int?
    public var title:String?
    public var jsContent: String?
    public var jsonContent: String?
    
    public var notifTitle:String?

    public var report: NotificationBellReport?
    
    public var waitingTime: Int = 0

    
    public var bellElems : [bellElement]? = [bellElement]()
    public var bellIcon : String?
    public var bellAnimation : String?

    //extended Props
    public var background_color:String?
    public var font_family:String?
    public var title_text_color:String?
    public var title_text_size:String?
    
    public var text_text_color:String?
    public var text_text_size:String?
    
    public var iosLink: String?
}


public struct NotificationBellReport: Codable {
    public var impression: String
    public var click: String
}


public struct bellElement {
    public var text: String?
    public var ios_lnk : String?
}
