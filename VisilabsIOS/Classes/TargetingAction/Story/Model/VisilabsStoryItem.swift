//
//  VisilabsStoryItem.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.10.2020.
//

import Foundation

enum MimeType: String {
    case photo
    case video
    case unknown
}
class VisilabsStoryItem {
    let internalIdentifier: String
    let mimeType: String
    let lastUpdated: String
    let url: String
    let displayTime: Int
    let targetUrl: String
    let buttonText: String
    let buttonTextColor: UIColor
    let buttonColor: UIColor
    var kind: MimeType {
        switch mimeType {
            case MimeType.photo.rawValue:
                return MimeType.photo
            case MimeType.video.rawValue:
                return MimeType.video
            default:
                return MimeType.unknown
        }
    }
    
    init (fileType: String, displayTime: Int, fileSrc: String, targetUrl: String, buttonText: String, buttonTextColor: UIColor, buttonColor: UIColor) {
        self.mimeType = fileType
        self.displayTime = displayTime // TODO:
        self.url = fileSrc // TODO:
        self.targetUrl = targetUrl
        self.buttonText = buttonText
        self.lastUpdated = "" //TODO kalkacak
        self.internalIdentifier = UUID().uuidString
        self.buttonTextColor = buttonTextColor
        self.buttonColor = buttonColor
    }
}
