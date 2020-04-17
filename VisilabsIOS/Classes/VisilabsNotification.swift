//
//  VisilabsNotification.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.04.2020.
//

import Foundation

let VisilabsNotificationTypeMini: String? = nil
let VisilabsNotificationTypeFull: String? = nil

class VisilabsNotification {
    private(set) var ID: UInt
    private(set) var type: String
    private(set) var title: String
    var body: String
    var imageURL: URL?
    var buttonText: String?
    var buttonURL: URL?
    var visitorData: String?
    var visitData: String?
    var queryString: String?
    var image: Data?
    
    
    
    
    //TODO: DLog'lar düzeltilecek
    init(ID: UInt, type: String, title: String, body: String, buttonText: String?, buttonURL: URL?, imageURL: URL?, visitorData: String?, visitData: String?, queryString: String?) {
        self.ID = ID
        self.type = type
        self.title = title
        self.body = body
        var valid = true

        if title.isEmpty {
            valid = false
            //DLog("Notification title nil or empty: %@", title)
        }

        if body.isEmpty {
            valid = false
            //DLog("Notification body nil or empty: %@", body)
        }

        if !((type == VisilabsNotificationTypeFull) || (type == VisilabsNotificationTypeMini)) {
            valid = false
            //DLog("Invalid notification type: %@, must be %@ or %@", type, VisilabsNotificationTypeMini, VisilabsNotificationTypeFull)
        }

        if (type == VisilabsNotificationTypeMini) && body.count  < 1 {
            body = title ?? ""
        }

        if valid {
            _ID = ID
            self.type = type
            self.title = title
            self.body = body
            self.imageURL = imageURL
            self.buttonText = buttonText
            self.buttonURL = buttonURL
            image = nil
            self.visitorData = visitorData
            self.visitData = visitData
            self.queryString = queryString
        } else {
            self = nil
        }
    }

    
    

    /*
    convenience init?(jsonObject object: [AnyHashable : Any]?) {
    }

    init() {
    }
    */
}
