//
//  VisilabsStoryImageError.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import Foundation

public enum RelatedDigitalStoryImageError: Error, CustomStringConvertible {

    case invalidImageURL
    case downloadError

    public var description: String {
        switch self {
        case .invalidImageURL: return "Invalid Image URL"
        case .downloadError: return "Unable to download image"
        }
    }
}
