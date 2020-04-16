//
//  VisilabsTargetRequest.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.04.2020.
//

import Foundation

class VisilabsTargetRequest: VisilabsAction {
    var zoneID: String?
    var productCode: String?
    var properties: [AnyHashable : Any]?
    var filters: [VisilabsTargetFilter]?
}
