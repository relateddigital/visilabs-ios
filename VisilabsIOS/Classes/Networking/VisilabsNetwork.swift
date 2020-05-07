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
    
}
