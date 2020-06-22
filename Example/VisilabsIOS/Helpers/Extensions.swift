//
//  Extensions.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 22.06.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init?(hex: String?, alpha: CGFloat = 1.0) {
        
        guard let hexString = hex else {
            return nil
        }
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) { cString.removeFirst() }

        if ((cString.count) != 6) {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha)
    }
    
}
