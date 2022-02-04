//
//  VisilabsStory.swift
//  VisilabsIOS
//
//  Created by Egemen on 25.08.2020.
//

import Foundation

class RelatedDigitalStory {
    internal init(title: String? = nil, smallImg: String? = nil,
                  link: String? = nil, items: [RelatedDigitalStoryItem]? = nil, actid: Int) {
        self.title = title
        self.smallImg = smallImg
        self.link = link
        if let items = items {
            self.items = items
        } else {
            self.items = [RelatedDigitalStoryItem]()
        }
        self.internalIdentifier = UUID().uuidString
        self.actid = actid
    }
    let title: String?
    let smallImg: String?
    let link: String?
    let items: [RelatedDigitalStoryItem]
    let internalIdentifier: String
    var lastPlayedSnapIndex = 0
    var isCompletelyVisible = false
    var isCancelledAbruptly = false
    var clickQueryItems = [String: String]()
    var impressionQueryItems = [String: String]()
    var actid: Int
}

extension RelatedDigitalStory: Equatable {
    public static func == (lhs: RelatedDigitalStory, rhs: RelatedDigitalStory) -> Bool {
        return lhs.internalIdentifier == rhs.internalIdentifier
    }
}
