//
//  VisilabsStoryPreviewModel.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.10.2020.
//

import Foundation

class RelatedDigitalStoryPreviewModel: NSObject {

    // MARK: - iVars
    let stories: [RelatedDigitalStory]
    let handPickedStoryIndex: Int // starts with(i)

    // MARK: - Init method
    init(_ stories: [RelatedDigitalStory], _ handPickedStoryIndex: Int) {
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
    }

    // MARK: - Functions
    func numberOfItemsInSection(_ section: Int) -> Int {
            return stories.count
    }
    func cellForItemAtIndexPath(_ indexPath: IndexPath) -> RelatedDigitalStory? {
        if indexPath.item < stories.count {
            return stories[indexPath.item]
        } else {
            fatalError("Stories Index mis-matched :(")
        }
    }
}
