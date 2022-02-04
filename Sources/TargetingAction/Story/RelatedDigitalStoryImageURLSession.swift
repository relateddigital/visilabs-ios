//
//  VisilabsStoryImageURLSession.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import UIKit

class RelatedDigitalStoryImageURLSession: URLSession {
    static let `default` = RelatedDigitalStoryImageURLSession()
    private(set) var dataTasks: [URLSessionDataTask] = []
}
extension RelatedDigitalStoryImageURLSession {
    func cancelAllPendingTasks() {
        dataTasks.forEach({
            if $0.state != .completed {
                $0.cancel()
            }
        })
    }

    func downloadImage(using urlString: String, completionBlock: @escaping ImageResponse) {
        guard let url = URL(string: urlString) else {
            return completionBlock(.failure(RelatedDigitalStoryImageError.invalidImageURL))
        }
        dataTasks.append(RelatedDigitalStoryImageURLSession.shared.dataTask(with: url, completionHandler: {(data, _, error) in
            if let result = data, error == nil, let imageToCache = UIImage(data: result) {
                RelatedDigitalStoryImageCache.shared.setObject(imageToCache, forKey: url.absoluteString as AnyObject)
                completionBlock(.success(imageToCache))
            } else {
                return completionBlock(.failure(error ?? RelatedDigitalStoryImageError.downloadError))
            }
        }))
        dataTasks.last?.resume()
    }
}
