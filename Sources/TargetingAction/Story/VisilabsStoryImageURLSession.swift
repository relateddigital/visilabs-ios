//
//  VisilabsStoryImageURLSession.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import UIKit

class VisilabsStoryImageURLSession: URLSession {
    static let `default` = VisilabsStoryImageURLSession()
    private(set) var dataTasks: [URLSessionDataTask] = []
}

extension VisilabsStoryImageURLSession {
    
    func downloadImage(using urlString: String, completionBlock: @escaping ImageResponse) {
        guard let url = URL(string: urlString) else {
            return completionBlock(.failure(VisilabsStoryImageError.invalidImageURL))
        }
        dataTasks.append(VisilabsStoryImageURLSession.shared.dataTask(with: url, completionHandler: {(data, _, error) in
            if let result = data, error == nil, let imageToCache = UIImage(data: result) {
                VisilabsStoryImageCache.shared.setObject(imageToCache, forKey: url.absoluteString as AnyObject)
                completionBlock(.success(imageToCache))
            } else {
                return completionBlock(.failure(error ?? VisilabsStoryImageError.downloadError))
            }
        }))
        dataTasks.last?.resume()
    }
    
}
