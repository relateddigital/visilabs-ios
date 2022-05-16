//
//  VisilabsStoryItem.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.10.2020.
//

import UIKit

enum MimeType: String {
    case photo
    case video
    case unknown
}
class VisilabsStoryItem {
    let mimeType: String
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

    init (fileType: String, displayTime: Int, fileSrc: String,
          targetUrl: String, buttonText: String, buttonTextColor: UIColor,
          buttonColor: UIColor) {
        self.mimeType = fileType
        self.displayTime = displayTime // TO_DO:
        self.url = fileSrc // TO_DO:
        self.targetUrl = targetUrl
        self.buttonText = buttonText
        self.buttonTextColor = buttonTextColor
        self.buttonColor = buttonColor
    }
}
