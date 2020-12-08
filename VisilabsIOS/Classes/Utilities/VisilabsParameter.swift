//
//  VisilabsParameter.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

import Foundation

class VisilabsParameter {
    var key: String
    var storeKey: String
    var count: UInt8
    var relatedKeys: [String]?

    init(key: String, storeKey: String, count: UInt8, relatedKeys: [String]?) {
        self.key = key
        self.storeKey = storeKey
        self.count = count
        self.relatedKeys = relatedKeys
    }
}
