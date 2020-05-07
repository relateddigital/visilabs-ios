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
}

struct VisilabsResource<A> {
    let path: String
    let method: VisilabsRequestMethod
    let requestBody: Data?
    let queryItems: [URLQueryItem]?
    let headers: [String:String]
    let parse: (Data) -> A?
}

enum VisilabsReason {
    case parseError
    case noData
    case notOKStatusCode(statusCode: Int)
    case other(Error)
}

struct VisilabsBasePath {
    static var endpoints = [VisilabsEndpoint : String]()
    
    //TODO: path parametresini kaldır
    static func buildURL(base: String, path: String, queryItems: [URLQueryItem]?) -> URL? {
        guard let url = URL(string: base) else {
            return nil
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        //components?.path = path
        components?.queryItems = queryItems
        return components?.url
    }

    static func getServerURL(identifier: VisilabsEndpoint) -> String {
        return endpoints[identifier] ?? ""
    }
}

class VisilabsNetwork {
    
    class func apiRequest<A>(base: String, resource: VisilabsResource<A>, failure: @escaping (VisilabsReason, Data?, URLResponse?) -> (), success: @escaping (A, URLResponse?) -> ()) {
        guard let request = buildURLRequest(base, resource: resource) else {
            return
        }

        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else {

                if let hasError = error {
                    failure(.other(hasError), data, response)
                } else {
                    failure(.noData, data, response)
                }
                return
            }
            guard httpResponse.statusCode == 200 else {
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
    
    private class func buildURLRequest<A>(_ base: String, resource: VisilabsResource<A>) -> URLRequest? {
        guard let url = VisilabsBasePath.buildURL(base: base, path: resource.path, queryItems: resource.queryItems) else {
            return nil
        }

        VisilabsLogger.debug(message: "Fetching URL");
        VisilabsLogger.debug(message: url.absoluteURL);
        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        request.httpBody = resource.requestBody

        for (k, v) in resource.headers {
            request.setValue(v, forHTTPHeaderField: k)
        }
        return request as URLRequest
    }
    
    class func buildResource<A>(path: String, method: VisilabsRequestMethod, requestBody: Data? = nil, queryItems: [URLQueryItem]? = nil, headers: [String: String], parse: @escaping (Data) -> A?) -> VisilabsResource<A> {
        return VisilabsResource(path: path, method: method, requestBody: requestBody, queryItems: queryItems, headers: headers, parse: parse)
    }
    
}
