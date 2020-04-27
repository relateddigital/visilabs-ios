//
//  VisilabsHttpClient.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

import Foundation

enum VisilabsSDKNetworkErrorType : Int {
    case visilabsSDKNetworkOfflineErrorType = 1
}

class VisilabsHttpClient {
    private var successHandler: ((_ resp: VisilabsResponse?) -> Void)
    private var failureHandler: ((_ resp: VisilabsResponse?) -> Void)
    private var session: URLSession

    init() {
        session = URLSession(configuration: URLSessionConfiguration.default)
        successHandler = { (resp: VisilabsResponse?) in }
        failureHandler = { (resp: VisilabsResponse?) in }
    }
    
    private func request(_ visilabsAction: VisilabsAction, with url: URL) -> URLRequest {
        var request: URLRequest
        if visilabsAction.cacheTimeout > 0 {
            request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: visilabsAction.cacheTimeout)
        } else {
            request = URLRequest(url: url)
        }
        request.httpMethod = visilabsAction.requestMethod

        if Visilabs.callAPI()?.userAgent != nil {
            request.setValue(Visilabs.callAPI()?.userAgent, forHTTPHeaderField: "User-Agent")
        }
        return request
    }
    
    //TODO:buradaki forced unwrap'leri kontrol et
    func sendRequest(_ visilabsAction: VisilabsAction, andSuccess sucornil: @escaping (_ success: VisilabsResponse?) -> Void, andFailure failornil: @escaping (_ failed: VisilabsResponse?) -> Void) {

        successHandler = sucornil
        failureHandler = failornil

        let apicall = visilabsAction.buildURL()

        if Visilabs.callAPI() == nil || !Visilabs.callAPI()!.isOnline {
            let res = VisilabsResponse()
            if apicall != nil {
                res.targetURL = apicall!.absoluteString
            }
            res.error = NSError(domain: "VisilabsHttpClient", code: VisilabsSDKNetworkErrorType.visilabsSDKNetworkOfflineErrorType.rawValue, userInfo: ["error": "offline"])
            fail(with: res, andAction: visilabsAction)
            return
        }
        
        var brequest = request(visilabsAction, with: apicall!)
        brequest.timeoutInterval = visilabsAction.requestTimeout
        
        let task = session.dataTask(with: brequest, completionHandler: { data, response, error in
            var encodingType: String.Encoding = .utf8
            if let encodingName = response?.textEncodingName {
                encodingType = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString?)))
            }
            let reponseAsRawString = String(bytes: data!, encoding: encodingType)
            let statusCode = Int((response as? HTTPURLResponse)?.statusCode ?? 0)
            
            DispatchQueue.main.async(execute: {
                if error != nil {
                    //TODO:error işini handle et
                    //DLog(@"Error %@", error.description);
                    let visilabsResponse = VisilabsResponse()
                    if apicall != nil {
                        visilabsResponse.targetURL = apicall!.absoluteString
                    }
                    visilabsResponse.rawResponseAsString = reponseAsRawString
                    visilabsResponse.rawResponse = data
                    visilabsResponse.error = error
                    self.fail(with: visilabsResponse, andAction: visilabsAction)
                    return
                }
                let visilabsResponse = VisilabsResponse()
                visilabsResponse.responseStatusCode = Int((response as? HTTPURLResponse)?.statusCode ?? 0)
                visilabsResponse.rawResponseAsString = reponseAsRawString
                visilabsResponse.rawResponse = data
                
                if apicall != nil {
                    visilabsResponse.targetURL = apicall!.absoluteString
                }
                visilabsResponse.parseResponseData(data)
                
                do {
                    if statusCode == 200 {
                        try self.success(with: visilabsResponse, andAction: visilabsAction)
                        return
                    }
                } catch {
                    print("Invalid Selection.")
                }

                var msg = visilabsResponse.parsedResponse!["msg"] as? String
                if nil == msg {
                    msg = visilabsResponse.parsedResponse!["message"] as? String
                    if nil == msg {
                        msg = reponseAsRawString
                    }
                }
                let err = NSError(domain: "VisilabsHTTPRequestErrorDomain", code: statusCode, userInfo: [
                    NSLocalizedDescriptionKey: msg ?? ""
                ])
                visilabsResponse.error = err
                self.fail(with: visilabsResponse, andAction: visilabsAction)


            })
        
        })
        task.resume()
    }
    
    private func success(with visilabsRes: VisilabsResponse?, andAction action: VisilabsAction?) {
        
        return successHandler(visilabsRes)
        
        /* TODO: buranın dolması gerekiyor mu kontrol et
        let sucSel = #selector(requestDidSucceed(withResponse:))
        if action?.delegate != nil && action?.delegate.responds(to: sucSel) ?? false {
            (action?.delegate as? VisilabsAction)?.performSelector(onMainThread: sucSel, with: visilabsRes, waitUntilDone: true)
        }
         */
    }
    
    private func fail(with visilabsRes: VisilabsResponse?, andAction action: VisilabsAction?) {
        return failureHandler(visilabsRes)

        /* TODO: buranın dolması gerekiyor mu kontrol et
        let delFailSel = #selector(requestDidFail(withResponse:))
        if action?.delegate != nil && action?.delegate.responds(to: delFailSel) ?? false {
            (action?.delegate as? VisilabsAction)?.performSelector(onMainThread: delFailSel, with: visilabsRes, waitUntilDone: true)
        }
         */
    }
    
    
}
