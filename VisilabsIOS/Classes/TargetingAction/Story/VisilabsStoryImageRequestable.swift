//
//  VisilabsStoryImageRequestable.swift
//  VisilabsIOS
//
//  Created by Egemen on 28.09.2020.
//

import Foundation
import UIKit

public enum VisilabsStoryImageResult<V, E> {
    case success(V)
    case failure(E)
}

public typealias ImageResponse = (VisilabsStoryImageResult<UIImage, Error>) -> Void

protocol VisilabsStoryImageRequestable {
    func setImage(urlString: String, placeHolderImage: UIImage?, completionBlock: ImageResponse?)
}

extension VisilabsStoryImageRequestable where Self: UIImageView {

    func setImage(urlString: String, placeHolderImage: UIImage? = nil, completionBlock: ImageResponse?) {

        self.image = (placeHolderImage != nil) ? placeHolderImage! : nil
        self.showActivityIndicator()

        if let cachedImage = VisilabsStoryImageCache.shared.object(forKey: urlString as AnyObject) as? UIImage {
            self.hideActivityIndicator()
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            guard let completion = completionBlock else { return }
            return completion(.success(cachedImage))
        }else {
            VisilabsStoryImageURLSession.default.downloadImage(using: urlString) { [weak self] (response) in
                guard let strongSelf = self else { return }
                strongSelf.hideActivityIndicator()
                switch response {
                case .success(let image):
                    DispatchQueue.main.async {
                        strongSelf.image = image
                    }
                    guard let completion = completionBlock else { return }
                    return completion(.success(image))
                case .failure(let error):
                    guard let completion = completionBlock else { return }
                    return completion(.failure(error))
                }
            }
        }
    }
}
