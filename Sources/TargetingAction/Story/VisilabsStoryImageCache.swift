//
//  VisilabsStoryImageCache.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import Foundation

private let oneHundredMB = 1024 * 1024 * 100

class VisilabsStoryImageCache: NSCache<AnyObject, AnyObject> {
    static let shared = VisilabsStoryImageCache()
    private override init() {
        super.init()
        self.setMaximumLimit()
    }
}

extension VisilabsStoryImageCache {
    func setMaximumLimit(size: Int = oneHundredMB) {
        totalCostLimit = size
    }
}
