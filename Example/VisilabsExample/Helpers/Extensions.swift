//
//  Extensions.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 22.06.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension Int {

    static func random(min: Int, max: Int, except: [Int] = [Int]()) -> Int {
        var randomNumber: Int
        repeat {
            randomNumber = Int.random(in: min..<(max+1))
        } while except.contains(randomNumber)
        return randomNumber
    }
}

extension Double {

    static let numberFormatter: NumberFormatter = {
      let formatter = NumberFormatter()
      formatter.decimalSeparator = "."
      formatter.maximumFractionDigits = 2
      return formatter
    }()

    func formatPrice() -> String {
        return Double.numberFormatter.string(from: NSNumber(value: self)) ?? "1.00"
    }
}

extension UIColor {

    convenience init?(hex: String?, alpha: CGFloat = 1.0) {

        guard let hexString = hex else {
            return nil
        }
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.removeFirst()
        }

        if (cString.count) != 6 {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha)
    }

    func toHexString() -> String {
        let components = self.cgColor.components
        let red: CGFloat = components?[0] ?? 0.0
        let green: CGFloat = components?[1] ?? 0.0
        let blue: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX",
                                    lroundf(Float(red * 255)),
                                    lroundf(Float(green * 255)),
                                    lroundf(Float(blue * 255)))
        print(hexString)
        return hexString
    }
}
