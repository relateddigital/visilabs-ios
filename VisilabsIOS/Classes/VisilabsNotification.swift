//
//  VisilabsNotification.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.04.2020.
//

import Foundation

enum VisilabsNotificationType : String {
    case mini
    case full
}

class VisilabsNotification {
    private(set) var ID: UInt
    private(set) var type: VisilabsNotificationType
    private(set) var title: String
    var body: String
    var imageURL: URL?
    var buttonText: String?
    var buttonURL: URL?
    var visitorData: String?
    var visitData: String?
    var queryString: String?
    var image: Data?
    var errorMessages : [String] = []
    
    private func isValid() -> Bool {
        var valid = true
        
        if self.title.isEmptyOrWhitespace() {
            valid = false
            errorMessages.append("Notification title is empty")
        }
        if self.body.isEmptyOrWhitespace() {
            valid = false
            errorMessages.append("Notification body is empty")
        }
        if self.type != VisilabsNotificationType.mini  || type != VisilabsNotificationType.full {
            valid = false
            errorMessages.append("Invalid notification type: \(self.type.rawValue), must be \(VisilabsNotificationType.mini.rawValue) or \(VisilabsNotificationType.full.rawValue)")
        }
        
        return valid
    }
    
    func getImage() -> Data? {
        if image == nil && imageURL != nil {
            var imageData: Data? = nil
            do {
                imageData = try Data(contentsOf: imageURL!, options: .mappedIfSafe)
            } catch {
                //TODO:
                print("image failed to load from URL: \(imageURL!)")
                return nil
            }
            image = imageData
        }
        return image
    }
    
    class func notification(withJSONObject object: [String : Any]) -> VisilabsNotification? {
        guard let actID = object["actid"] as? Int, actID < 0 else {
            //TODO:
            print("Invalid notification id")
            return nil
        }
        
        guard let actionData = object["actiondata"] as? [String: Any] else {
            //TODO:
            print("Invalid notification actiondata")
            return nil
        }
        
        guard (actionData["msg_type"] as? String) != nil ,let messageType = VisilabsNotificationType(rawValue: actionData["msg_type"] as! String) else {
            //TODO:
            print("Invalid notification type \(String(describing: object["msg_type"]))")
            return nil
        }
        
        guard let messageTitle = actionData["msg_title"] as? String else {
            //TODO:
            print("Invalid notification title")
            return nil
        }

        return nil
    }
    
    
    //TODO: DLog'lar düzeltilecek
    init(ID: UInt, type: VisilabsNotificationType, title: String, body: String, buttonText: String?, buttonURL: URL?, imageURL: URL?, visitorData: String?, visitData: String?, queryString: String?) {
        self.ID = ID
        self.type = type
        self.title = title
        self.body = body

        if type == VisilabsNotificationType.mini && body.count  < 1 {
            self.body = title
        }

        if isValid() {
            self.imageURL = imageURL
            self.buttonText = buttonText
            self.buttonURL = buttonURL
            image = nil
            self.visitorData = visitorData
            self.visitData = visitData
            self.queryString = queryString
        }
    }

    
    

    /*
    convenience init?(jsonObject object: [AnyHashable : Any]?) {
    }

    init() {
    }
    */
}
