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
    init(actionId: Int, storyTemplate: VisilabsStoryTemplate, stories: [VisilabsStory]) {
        self.actionId = actionId
        self.storyTemplate = storyTemplate
        self.stories = stories
    }
}
