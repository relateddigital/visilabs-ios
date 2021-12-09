//
//  VisilabsStoryAction.swift
//  VisilabsIOS
//
//  Created by Egemen on 22.09.2020.
//

import UIKit

class VisilabsStoryAction {
    let actionId: Int
    let storyTemplate: VisilabsStoryTemplate
    var stories: [VisilabsStory]
    let clickQueryItems: [String: String]
    let impressionQueryItems: [String: String]
    let extendedProperties: VisilabsStoryActionExtendedProperties

    init(actionId: Int,
         storyTemplate: VisilabsStoryTemplate,
         stories: [VisilabsStory],
         clickQueryItems: [String: String],
         impressionQueryItems: [String: String],
         extendedProperties: VisilabsStoryActionExtendedProperties) {
        self.actionId = actionId
        self.storyTemplate = storyTemplate
        self.stories = [VisilabsStory]()
        for story in stories {
            story.clickQueryItems = clickQueryItems
            story.impressionQueryItems = impressionQueryItems
            self.stories.append(story)
        }
        self.clickQueryItems = clickQueryItems
        self.impressionQueryItems = impressionQueryItems
        self.extendedProperties = extendedProperties
    }
}

class VisilabsStoryActionExtendedProperties {
    var imageBorderWidth = 2  // 0,1,2,3
    var imageBorderRadius = 0.5 // "","50%","10%"
    var imageBoxShadow = false
    // var imageBoxShadow: String? // "rgba(0,0,0,0.4) 5px 5px 10px" // TO_DO: buna sonra bak
    var imageBorderColor = UIColor.clear // "#cc3a3a"
    var labelColor = UIColor.black // "#a83c3c"
    var moveShownToEnd = true
    var storyzLabelColor : String = ""
    var fontFamily : String = ""
    var customFontFamilyIos :String = ""

}
