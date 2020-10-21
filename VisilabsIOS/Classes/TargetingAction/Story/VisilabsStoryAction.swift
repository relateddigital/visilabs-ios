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
    let extendedProperties: VisilabsStoryActionExtendedProperties
    init(actionId: Int, storyTemplate: VisilabsStoryTemplate, stories: [VisilabsStory], clickQueryString: String, extendedProperties: VisilabsStoryActionExtendedProperties) {
        self.actionId = actionId
        self.storyTemplate = storyTemplate
        self.stories = stories
        self.clickQueryString = clickQueryString
        self.extendedProperties = extendedProperties
    }
}

class VisilabsStoryActionExtendedProperties {
    var imageBorderWidth = 2  //0,1,2,3
    var imageBorderRadius = 0.5 //"","50%","10%"
    var imageBoxShadow = false
    //var imageBoxShadow: String? // "rgba(0,0,0,0.4) 5px 5px 10px" // TODO: buna sonra bak
    var imageBorderColor = UIColor.clear //"#cc3a3a"
    var labelColor = UIColor.black //"#a83c3c"
}
