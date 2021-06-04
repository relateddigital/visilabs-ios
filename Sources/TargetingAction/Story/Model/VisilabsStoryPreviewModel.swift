//
//  VisilabsStoryPreviewModel.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.10.2020.
//

import Foundation

class VisilabsStoryPreviewModel: NSObject {

    // MARK: - iVars
    let stories: [VisilabsStory]
    let handPickedStoryIndex: Int //starts with(i)

    // MARK: - Init method
    init(_ stories: [VisilabsStory], _ handPickedStoryIndex: Int) {
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
    }

    // MARK: - Functions
    func numberOfItemsInSection(_ section: Int) -> Int {
            return stories.count
    }
    func cellForItemAtIndexPath(_ indexPath: IndexPath) -> VisilabsStory? {
        if indexPath.item < stories.count {
            return stories[indexPath.item]
        } else {
            fatalError("Stories Index mis-matched :(")
        }
    }
}
