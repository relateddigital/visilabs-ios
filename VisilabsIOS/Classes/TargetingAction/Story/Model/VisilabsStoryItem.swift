//
//  VisilabsStoryItem.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.10.2020.
//

import Foundation

public enum MimeType: String {
    case photo
    case video
    case unknown
}
public class VisilabsStoryItem: Codable {
    public let internalIdentifier: String
    public let mimeType: String
    public let lastUpdated: String
    public let url: String
    public var displayTime = 3 // TODO:
    public let targetUrl: String // TODO:
    //TODO: buna bizde gerek yok sanırım
    // Store the deleted snaps id in NSUserDefaults, so that when app get relaunch deleted snaps will not display.
    public var isDeleted: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: internalIdentifier)
        }
        get{
            return UserDefaults.standard.value(forKey: internalIdentifier) != nil
        }
    }
    public var kind: MimeType {
        switch mimeType {
            case MimeType.photo.rawValue:
                return MimeType.photo
            case MimeType.video.rawValue:
                return MimeType.video
            default:
                return MimeType.unknown
        }
    }
    
    init (fileType: String, displayTime: Int, fileSrc: String, targetUrl: String) {
        self.mimeType = fileType
        self.displayTime = displayTime // TODO:
        self.url = fileSrc // TODO:
        self.targetUrl = targetUrl
        self.lastUpdated = ""
        self.internalIdentifier = UUID().uuidString // TODO:
    }
    
    enum CodingKeys: String, CodingKey {
        case internalIdentifier = "id"
        case mimeType = "mime_type"
        case lastUpdated = "last_updated"
        case url = "url"
        case displayTime = "displayTime"
        case targetUrl = "targetUrl"
    }
}
