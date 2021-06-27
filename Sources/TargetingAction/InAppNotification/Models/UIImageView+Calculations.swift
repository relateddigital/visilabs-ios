//
//  UIImageView+Calculations.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

import UIKit

extension UIImageView {
    func pv_heightForImageView() -> CGFloat {
        guard let image = image, image.size.height > 0 else {
            return 0.0
        }
        let width = bounds.size.width
        let ratio = image.size.height / image.size.width
        return width * ratio
    }
    
    func pv_widthForImageView() -> CGFloat {
        guard let image = image, image.size.width > 0 else {
            return 0.0
        }
        let height = bounds.size.height
        let ratio = image.size.height / image.size.width
        return height * ratio
    }
}
