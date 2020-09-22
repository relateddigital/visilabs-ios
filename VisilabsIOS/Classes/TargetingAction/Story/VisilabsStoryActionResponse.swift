//
//  VisilabsStoryActionResponse.swift
//  VisilabsIOS
//
//  Created by Egemen on 25.08.2020.
//

enum VisilabsStoryTemplate : String {
    case StoryLookingBanners = "story_looking_banners"
}

class VisilabsStoryActionResponse {
    public var storyActions: [VisilabsStoryAction]
    public var error: VisilabsError?
    
    internal init(storyActions: [VisilabsStoryAction], error: VisilabsError? = nil) {
        self.storyActions = storyActions
        self.error = error
    }
}
