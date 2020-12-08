//
//  VisilabsStoryActionResponse.swift
//  VisilabsIOS
//
//  Created by Egemen on 25.08.2020.
//

enum VisilabsStoryTemplate: String {
    case storyLookingBanners = "story_looking_banners"
    case skinBased = "skin_based"
}

class VisilabsStoryActionResponse {
    public var storyActions: [VisilabsStoryAction]
    public var error: VisilabsError?
    var guid: String?

    internal init(storyActions: [VisilabsStoryAction], error: VisilabsError? = nil, guid: String?) {
        self.storyActions = storyActions
        self.error = error
        self.guid = guid
    }
}
