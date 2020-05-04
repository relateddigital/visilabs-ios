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

public class VisilabsAction{
    
    
    var siteID : String
    var organizationID : String
    var cookieID : String?
    var exVisitorID : String?
    var tokenID : String?
    var appID : String?
    
    
    /// The HTTP request method
    var requestMethod: String
    
    /// The HTTP headers of the request
    var headers: [String : Any]
    
    /// Set/Get the parameters for the API request.
    /// - Returns: Returns the parameters.
    var args: [String : Any]
    
    
    
    var async : Bool = false
    
    var httpClient: VisilabsHttpClient
    
    
    /// The timeout value of the request  Default to 30 seconds
    var requestTimeout: TimeInterval
    
    /// The response delegate for this request.
    weak var delegate: VisilabsResponseDelegate?
    
    /// How long the response should be cached for. The response won't be cached if it's not set.
    var cacheTimeout : TimeInterval
    
    /// The relative path of the API request
    /// - Returns: The API request's relative path
    var path: String?
    
    
    internal init(siteID: String, organizationID: String, cookieID: String?, exVisitorID: String?, tokenID: String?, appID: String?, requestMethod: String = "GET", headers: [String : Any] = [ : ], args: [String : Any]  = [ : ]) {
        self.siteID = siteID
        self.organizationID = organizationID
        self.cookieID = cookieID
        self.exVisitorID = exVisitorID
        self.tokenID = tokenID
        self.appID = appID
        self.requestMethod = requestMethod
        self.headers = headers
        self.args = [String : Any]()
        httpClient = VisilabsHttpClient()
        requestTimeout = 30
        cacheTimeout = 0
    }
    
    

    /// Get the parameters for the API request as NSString.
    /// - Returns: Returns the parameters as string.
    func argsAsString() -> String? {
        return args.jsonString()
    }
    
    /// Get the URL of the API request
    /// - Returns: Returns the URL

    func buildURL() -> URL? {
        return nil
    }
    
    /// Excute the API request synchronously with the given success and failure
    /// blocks.
    /// @warning This will block the application's main UI thread
    /// - Parameters:
    ///   - sucornil: The block to be executed if the request is successful. If it's
    /// nil, the delegate's [VisilabsResponseDelegate requestDidSucceedWithResponse:] will be
    /// exectued.
    ///   - failornil: The block to be executed if the request is failed. If it's nil,
    /// the delegate's [VisilabsResponseDelegate requestDidFailWithResponse:] will be
    /// exectued.
    /// - seealso: VisilabsResponseDelegate

    func exec(withSuccess sucornil: @escaping (_ success: VisilabsResponse?) -> Void, andFailure failornil: @escaping (_ failed: VisilabsResponse?) -> Void) {
        exec(false, withSuccess: sucornil, andFailure: failornil)
    }
    
    /// Excute the API request asynchronously with the given success and failure
    /// blocks.
    /// This is the recommended way to execute the request.
    /// - Parameters:
    ///   - sucornil: The block to be executed if the request is successful. If it's
    /// nil, the delegate's [VisilabsResponseDelegate requestDidSucceedWithResponse:] will be
    /// exectued.
    ///   - failornil: The block to be executed if the request is failed. If it's nil,
    /// the delegate's [VisilabsResponseDelegate requestDidFailWithResponse:] will be
    /// exectued.
    /// - seealso: VisilabsResponseDelegate

    func execAsync(withSuccess sucornil: @escaping (_ success: VisilabsResponse?) -> Void, andFailure failornil: @escaping (_ failed: VisilabsResponse?) -> Void) {
        exec(true, withSuccess: sucornil, andFailure: failornil)
    }

    
    private func exec(_ pAsync: Bool, withSuccess sucornil: @escaping (_ success: VisilabsResponse?) -> Void, andFailure failornil: @escaping (_ failed: VisilabsResponse?) -> Void) {
        async = pAsync
        httpClient.sendRequest(self, andSuccess: sucornil, andFailure: failornil)
    }
    
    

}
