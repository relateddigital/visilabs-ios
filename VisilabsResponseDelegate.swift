//
//  VisilabsResponseDelegate.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

/**
The delegate class to process the response data. If callback blocks are not
used in the API requests, this protocol should be implemented and assigned to
an instance of VisilabsAction
*/

protocol VisilabsResponseDelegate : AnyObject {
    /// Executed if the request is successful
    /// - Parameter res: The response object
    func requestDidSucceed(with res: VisilabsResponse?)
    /// Executed if the request is failed
    /// - Parameter res: The response object
    func requestDidFail(with res: VisilabsResponse?)
}
