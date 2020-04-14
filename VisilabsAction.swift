//
//  VisilabsAction.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

import Foundation

/**
Base class for all API request classes
*/

class VisilabsAction{
    var args: [AnyHashable : Any]?
    var headers: [AnyHashable : Any]?
    var async = false
    var httpClient: VisilabsHttpClient?
}
