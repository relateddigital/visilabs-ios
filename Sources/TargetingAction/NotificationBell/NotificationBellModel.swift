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
    
    var report: NotificationBellReport?
    
    var waitingTime: Int = 0

    
    var bellElems : [bellElement]?
    var bellIcon : String?
    var bellAnimation : String?

    //extended Props
    var contentMinimizedTextSize:String?
    var contentMinimizedTextColor:String?
    var contentMinimizedFontFamily:String?
    var contentMinimizedCustomFontFamilyIos:String?
    var contentMinimizedTextOrientation:String?
    var contentMinimizedBackgroundImage:String?
    var contentMinimizedBackgroundColor:String?
    var contentMinimizedArrowColor:String?
    var contentMaximizedBackgroundImage:String?
    var contentMaximizedBackgroundColor:String?
    
    
}


public struct NotificationBellReport: Codable {
    var impression: String
    var click: String
}


public struct bellElement {
    
    var text: String?
    var ios_lnk : String?
    
}
