//
//  VisilabsParameter.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

import Foundation

class VisilabsParameter{
    var key: String?
    var storeKey: String?
    var count: NSNumber?
    var relatedKeys: [AnyHashable]?

    init(key: String?, storeKey: String?, count: NSNumber?, relatedKeys: [AnyHashable]?) {
        self.relatedKeys = [AnyHashable]()
        if relatedKeys != nil {
            self.relatedKeys = relatedKeys
        }
        self.key = key
        self.storeKey = storeKey
        self.count = count
    }
}
