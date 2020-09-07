//
//  VisilabsStory.swift
//  VisilabsIOS
//
//  Created by Egemen on 25.08.2020.
//

class VisilabsStory {
    internal init(title: String? = nil, smallImg: String? = nil, link: String? = nil, linkOriginal: String? = nil) {
        self.title = title
        self.smallImg = smallImg
        self.link = link
        self.linkOriginal = linkOriginal
    }
    
    let title: String?
    let smallImg: String?
    let link: String?
    let linkOriginal: String?
}
