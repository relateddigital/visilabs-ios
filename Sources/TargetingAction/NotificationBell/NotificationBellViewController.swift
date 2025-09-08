//
//  NotificationBellViewController.swift
//  CleanyModal
//
//  Created by Orhun Akmil on 8.09.2025.
//

import Foundation



class NotificationBellViewController : VisilabsBaseNotificationViewController
{
    
    
    var model = NotificationBellModel()
    var report: NotificationBellReport?

    public init(model:NotificationBellModel?) {
        super.init(nibName: nil, bundle: nil)
        self.model = model!
        self.report = model?.report
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

    
    

