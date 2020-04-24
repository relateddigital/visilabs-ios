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
    case image_text_button
    case full_image
    case nps
    case image_button
    case smile_rating
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
    
    var messageTitleColor : String?
    var messageBodyColor : String?
    var messageBodyTextSize : String?
    var fontFamily : String?
    var backGround : String?
    var closeButtonColor : String?
    var buttonTextColor : String?
    var buttonColor : String?
    
    private func isValid() -> Bool {
        var valid = true
        
        if self.title.isEmptyOrWhitespace {
            valid = false
            errorMessages.append("Notification title is empty")
        }
        if self.body.isEmptyOrWhitespace {
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
        guard let actID = object["actid"] as? UInt else {
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
        
        guard let messageBody = actionData["msg_body"] as? String else {
            //TODO:
            print("Invalid notification body")
            return nil
        }
        
        guard let buttonText = actionData["btn_text"] as? String else {
            //TODO:
            print("Invalid notification cta")
            return nil
        }
        
        var buttonURL: URL? = nil
        let URLString = actionData["ios_lnk"] as? String
        if URLString != nil {
            buttonURL = URL(string: URLString!)
            if buttonURL == nil {
                print("invalid notification URL: \(URLString!)")
                return nil
            }
        }
        
        var imageURL: URL? = nil
        let imageURLString = actionData["img"] as? String
        if imageURLString != nil {
            
            let escapedUrl = imageURLString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            imageURL = URL(string: escapedUrl ?? "")
            if imageURL == nil {
                print("Invalid notification image URL: \(imageURLString!)")
                return nil
            }

            var imagePath = imageURL?.path
            if messageType == VisilabsNotificationType.mini {
                let imageName = URL(fileURLWithPath: imagePath ?? "").deletingPathExtension().absoluteString
                let `extension` = URL(fileURLWithPath: imagePath ?? "").pathExtension
                imagePath = URL(fileURLWithPath: imageName + ("@2x")).appendingPathExtension(`extension` ?? "").absoluteString
            }


            imagePath = (imagePath as NSString?)?.addingPercentEscapes(using: NSString.EncodingConversionOptions.externalRepresentation.rawValue)
            
            var urlComponents = URLComponents()
            urlComponents.scheme = imageURL?.scheme ?? ""
            urlComponents.host = imageURL?.host
            urlComponents.path = imagePath ?? ""

            //TODO: check
            imageURL = urlComponents.url
            
            if imageURL == nil {
                print("Invalid notification image URL: \(imageURLString!)")
                return nil
            }
        }
        
        guard let visitorData = actionData["visitor_data"] as? String else {
            //TODO:
            print("Invalid notification visitorData: \(String(describing: actionData["visitor_data"]))")
            return nil
        }
        
        guard let visitData = actionData["visit_data"] as? String else {
            //TODO:
            print("Invalid notification visitData: \(String(describing: actionData["visit_data"]))")
            return nil
        }
        
        guard let queryString = actionData["qs"] as? String else {
            //TODO:
            print("Invalid notification queryString: \(String(describing: actionData["qs"]))")
            return nil
        }
        
        //TODO: yeni properties
        /*
         msg_title_color = actionData.getString("msg_title_color");
         msg_body_color = actionData.getString("msg_body_color");
         msg_body_textsize = actionData.getString("msg_body_textsize");
         font_family = actionData.getString("font_family");
         background = actionData.getString("background");
         close_button_color = actionData.getString("close_button_color");
         button_text_color = actionData.getString("button_text_color");
         button_color = actionData.getString("button_color");
         
         */

        return VisilabsNotification(ID: actID, type: messageType, title: messageTitle, body: messageBody, buttonText: buttonText, buttonURL: buttonURL, imageURL: imageURL, visitorData: visitorData, visitData: visitData, queryString: queryString)
    }
    
    
    //TODO: DLog'lar düzeltilecek
    private init(ID: UInt, type: VisilabsNotificationType, title: String, body: String, buttonText: String?, buttonURL: URL?, imageURL: URL?, visitorData: String?, visitData: String?, queryString: String?) {
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
