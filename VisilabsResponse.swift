//
//  VisilabsResponse.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

import Foundation

class VisilabsResponse {
    /// Get the generated target URL as NSString
    var targetURL: String?
    /// Get the response as NSArray    //egemen
    var responseArray: [AnyHashable]?
    /// Get the raw response data
    var rawResponse: Data?
    /// Get the raw response data as NSString
    var rawResponseAsString: String?
    /// Get the response data as NSDictionary
    var parsedResponse: [AnyHashable : Any]?
    /// Get the response's status code
    var responseStatusCode:Int = 0
    /// Get the error of the response
    var error: Error?

    /// Parse the response string (JSON format)
    /// - Parameter res: The response string
    func parseResponseString(_ res: String?) {
        parsedResponse = res?.objectFromJSONString() as [AnyHashable : Any]?
    }

    /// Parse the response data (JSON format)
    /// - Parameter data: The response data
    func parseResponseData(_ data: Data?) {
        parsedResponse = data?.objectFromJSONData()
        responseArray = data?.objectFromJSONData()
    }
}
