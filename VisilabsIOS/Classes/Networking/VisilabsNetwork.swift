//
//  VisilabsNetwork.swift
//  VisilabsIOS
//
//  Created by Egemen on 4.05.2020.
//

import Foundation

enum VisilabsRequestMethod: String {
    case get = "get"
    case post = "post"
}

enum VisilabsEndpoint {
    case logger
    case realtime
    case target
    case action
    case geofence
    case mobile
}

struct VisilabsResource<A> {
    let endPoint: VisilabsEndpoint
    let method: VisilabsRequestMethod
    let timeoutInterval: TimeInterval
    let requestBody: Data?
    let queryItems: [URLQueryItem]?
    let headers: [String:String]
    let parse: (Data) -> A?
}

public enum VisilabsReason {
    case parseError
    case noData
    case notOKStatusCode(statusCode: Int)
    case other(Error)
}

struct VisilabsBasePath {
    static var endpoints = [VisilabsEndpoint : String]()
    
    //TODO: path parametresini kaldır
    static func buildURL(visilabsEndpoint: VisilabsEndpoint, queryItems: [URLQueryItem]?) -> URL? {
        guard let endpoint = endpoints[visilabsEndpoint], let url = URL(string: endpoint) else {
            return nil
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        //components?.path = path
        components?.queryItems = queryItems
        return components?.url
    }

    static func getEndpoint(visilabsEndpoint: VisilabsEndpoint) -> String {
        return endpoints[visilabsEndpoint] ?? ""
    }
}

class VisilabsNetwork {
    
    class func apiRequest<A>(resource: VisilabsResource<A>, failure: @escaping (VisilabsReason, Data?, URLResponse?) -> (), success: @escaping (A, URLResponse?) -> ()) {
        guard let request = buildURLRequest(resource: resource) else {
            return
        }

        
        //TODO: burada cookie'leri düzgün handle edecek bir yöntem bul.
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else {

                if let hasError = error {
                    failure(.other(hasError), data, response)
                } else {
                    failure(.noData, data, response)
                }
                return
            }
            
            //TODO: buraya 201'i de ekleyebiliriz, visilabs sunucuları 201(created) de dönebiliyor. 304(Not modified)
            guard httpResponse.statusCode == 200/*OK*/ else {
                failure(.notOKStatusCode(statusCode: httpResponse.statusCode), data, response)
                return
            }
            guard let responseData = data else {
                failure(.noData, data, response)
                return
            }
            guard let result = resource.parse(responseData) else {
                failure(.parseError, data, response)
                return
            }

            success(result, response)
        }.resume()
    }
    
    private class func buildURLRequest<A>(resource: VisilabsResource<A>) -> URLRequest? {
        guard let url = VisilabsBasePath.buildURL(visilabsEndpoint: resource.endPoint, queryItems: resource.queryItems) else {
            return nil
        }

        VisilabsLogger.debug(message: "Fetching URL");
        VisilabsLogger.debug(message: url.absoluteURL);
        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        request.httpBody = resource.requestBody
        //TODO: timeoutInterval dışarıdan alınacak
        request.timeoutInterval = 60

        for (k, v) in resource.headers {
            request.setValue(v, forHTTPHeaderField: k)
        }
        return request as URLRequest
    }
    
    class func buildResource<A>(endPoint: VisilabsEndpoint, method: VisilabsRequestMethod, timeoutInterval:TimeInterval, requestBody: Data? = nil, queryItems: [URLQueryItem]? = nil, headers: [String: String], parse: @escaping (Data) -> A?) -> VisilabsResource<A> {
        return VisilabsResource(endPoint: endPoint, method: method, timeoutInterval: timeoutInterval, requestBody: requestBody, queryItems: queryItems, headers: headers, parse: parse)
    }
    
}
