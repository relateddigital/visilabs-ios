//
//  VisilabsStoryActionResponse.swift
//  VisilabsIOS
//
//  Created by Egemen on 25.08.2020.
//

enum VisilabsStoryTemplate : String {
    case StoryLookingBanners = "story_looking_banners"
    case SkinBased = "skin_based"
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
