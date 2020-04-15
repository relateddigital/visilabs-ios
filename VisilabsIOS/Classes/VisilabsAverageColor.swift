//
//  VisilabsAverageColor.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import UIKit

extension UIImage {

    func visilabs_averageColor() -> UIColor? {
        
        
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.interpolationQuality = CGInterpolationQuality.medium
        let cgRect = CGRect(origin: CGPoint(), size: size)
        draw(in: cgRect, blendMode: .copy, alpha: 1)
        let data = ctx?.data
        
        //TODO: bunları test et
        let red = (CGFloat(data!.load(fromByteOffset: 2, as: UInt8.self) as UInt8) / CGFloat(255))
        let green = (CGFloat(data!.load(fromByteOffset: 1, as: UInt8.self) as UInt8) / CGFloat(255))
        let blue = (CGFloat(data!.load(fromByteOffset: 0, as: UInt8.self) as UInt8) / CGFloat(255))
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        UIGraphicsEndImageContext()
        return color
    }
    
}
