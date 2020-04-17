//
//  VisilabsNotification.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.04.2020.
//

import Foundation

let VisilabsNotificationTypeMini: String? = nil
let VisilabsNotificationTypeFull: String? = nil

class VisilabsNotification {
    private(set) var anId = 0
    var type: String?
    var title: String?
    var body: String?
    var imageURL: URL?
    var buttonText: String?
    var buttonURL: URL?
    var visitorData: String?
    var visitData: String?
    var queryString: String?
    var image: Data?

    /*
    convenience init?(jsonObject object: [AnyHashable : Any]?) {
    }

    init() {
    }
    */
}
