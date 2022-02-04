//
//  VisilabsStoryActionResponse.swift
//  VisilabsIOS
//
//  Created by Egemen on 25.08.2020.
//

enum RelatedDigitalStoryTemplate: String {
    case storyLookingBanners = "story_looking_banners"
    case skinBased = "skin_based"
}

class RelatedDigitalStoryActionResponse {
    public var storyActions: [RelatedDigitalStoryAction]
    public var error: VisilabsError?
    var guid: String?

    internal init(storyActions: [RelatedDigitalStoryAction], error: VisilabsError? = nil, guid: String?) {
        self.storyActions = storyActions
        self.error = error
        self.guid = guid
    }
}
