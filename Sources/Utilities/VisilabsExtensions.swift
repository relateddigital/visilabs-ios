//
//  VisilabsExtensions.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.04.2020.
//

import UIKit

/**
JSON convenient categories on NSString
*/
extension String {

    func contains(_ string: String, options: String.CompareOptions) -> Bool {
        let rng = (self as NSString).range(of: string, options: options)
        return rng.location != NSNotFound
    }

    func contains(_ string: String) -> Bool {
        return contains(string, options: [])
    }

    func urlDecode() -> String {
        return self.removingPercentEncoding ?? ""
    }

    func convertJsonStringToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }

    var isEmptyOrWhitespace: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func getUrlWithoutExtension() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().absoluteString
    }

    func getUrlExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}

extension Optional where Wrapped == String {

    var isNilOrWhiteSpace: Bool {
        return self?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
    }

}

extension Optional where Wrapped == [String] {
    mutating func mergeStringArray(_ newArray: [String]) {
        self = self ?? [String]()
        for newArrayElement in newArray {
            if !self!.contains(newArrayElement) {
                self!.append(newArrayElement)
            }
        }
    }
}

extension Int {
    var toFloat: CGFloat {
        return CGFloat(self)
    }
}



extension UIImageView {
    
    func setImage(withUrl urlString : URL?) {
        if let url = urlString {
            self.image = nil

            // if not, download image from url
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }

                DispatchQueue.main.async {
                    if let image = UIImage.gif(data: data!) {
                        self.image = image
                        if self.superview is VisilabsNpsWithNumbersCollectionView {
                            let viewPop = self.superview as! VisilabsNpsWithNumbersCollectionView
                            let height = viewPop.imageView.pv_heightForImageView(isVideoExist: false)
                            viewPop.imageHeightConstraint?.constant = height
                            //viewPop.imageView.height(height)
                            //viewPop.imageView.height(400, relation: .equalOrLess)
                            //viewPop.imageView.width(UIScreen.main.bounds.width, relation: .equalOrLess)
                            self.layoutIfNeeded()
                        }
                        
                    }
                }

            }).resume()
        }
    }
}
