//
//  VisilabsSnap.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.10.2020.
//

import Foundation

public enum MimeType: String {
    case image
    case video
    case unknown
}
public class VisilabsSnap: Codable {
    public let internalIdentifier: String
    public let mimeType: String
    public let lastUpdated: String
    public let url: String
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
            case MimeType.image.rawValue:
                return MimeType.image
            case MimeType.video.rawValue:
                return MimeType.video
            default:
                return MimeType.unknown
        }
    }
    enum CodingKeys: String, CodingKey {
        case internalIdentifier = "id"
        case mimeType = "mime_type"
        case lastUpdated = "last_updated"
        case url = "url"
    }
}
