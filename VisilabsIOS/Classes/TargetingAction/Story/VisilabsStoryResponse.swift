//
//  VisilabsStoryResponse.swift
//  VisilabsIOS
//
//  Created by Egemen on 25.08.2020.
//

enum VisilabsStoryTemplate : String {
    case StoryLookingBanners
}

class VisilabsStoryResponse {
    public var stories: [VisilabsStory]
    public var error: VisilabsReason?
    public var storyTemplate: VisilabsStoryTemplate
    public var storyExtendedProperties: VisilabsStoryExtendedProperties
    
    internal init(storyTemplate: VisilabsStoryTemplate, stories: [VisilabsStory], storyExtendedProperties: VisilabsStoryExtendedProperties, error: VisilabsReason? = nil) {
        self.storyTemplate = storyTemplate
        self.stories = stories
        self.storyExtendedProperties = storyExtendedProperties
        self.error = error
    }
}
