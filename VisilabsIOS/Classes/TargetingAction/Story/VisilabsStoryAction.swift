//
//  VisilabsStoryAction.swift
//  VisilabsIOS
//
//  Created by Egemen on 22.09.2020.
//

import Foundation

class VisilabsStoryAction {
    let actionId: Int
    let storyTemplate: VisilabsStoryTemplate
    let stories: [VisilabsStory]
    let clickQueryString: String
    init(actionId: Int, storyTemplate: VisilabsStoryTemplate, stories: [VisilabsStory], clickQueryString: String) {
        self.actionId = actionId
        self.storyTemplate = storyTemplate
        self.stories = stories
        self.clickQueryString = clickQueryString
    }
}

class VisilabsStoryActionExtendedProperties {
    
}
