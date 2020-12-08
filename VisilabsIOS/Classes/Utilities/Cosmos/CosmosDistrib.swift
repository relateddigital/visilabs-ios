//
//  CosmosDistrib.swift
//  VisilabsIOS
//
//  Created by Egemen on 8.06.2020.
//

// Star rating control written in Swift for iOS and tvOS.
// https://github.com/evgenyneu/Cosmos
import Foundation

/**

Defines how the star is filled when the rating is not an integer number.
 For example, if rating is 4.6 and the fill more is Half, the star will appear to be half filled.

*/
public enum StarFillMode: Int {
  /// Show only fully filled stars. For example, fourth star will be empty for 3.2.
  case full = 0

  /// Show fully filled and half-filled stars. For example, fourth star will be half filled for 3.6.
  case half = 1

  /// Fill star according to decimal rating. For example, fourth star will be 20% filled for 3.2.
  case precise = 2
}

// ----------------------------
//
// CosmosLayerHelper.swift
//
// ----------------------------

import UIKit

/// Helper class for creating CALayer objects.
class CosmosLayerHelper {
  /**

  Creates a text layer for the given text string and font.
  
  - parameter text: The text shown in the layer.
  - parameter font: The text font. It is also used to calculate the layer bounds.
  - parameter color: Text color.
  
  - returns: New text layer.
  
  */
  class func createTextLayer(_ text: String, font: UIFont, color: UIColor) -> CATextLayer {
    let size = NSString(string: text).size(withAttributes: [NSAttributedString.Key.font: font])

    let layer = CATextLayer()
    layer.bounds = CGRect(origin: CGPoint(), size: size)
    layer.anchorPoint = CGPoint()

    layer.string = text
    layer.font = CGFont(font.fontName as CFString)
    layer.fontSize = font.pointSize
    layer.foregroundColor = color.cgColor
    layer.contentsScale = UIScreen.main.scale

    return layer
  }
}

// ----------------------------
//
// CosmosTouchTarget.swift
//
// ----------------------------

/**

Helper function to make sure bounds are big enought to be used as touch target.
The function is used in pointInside(point: CGPoint, withEvent event: UIEvent?) of UIImageView.

*/
struct CosmosTouchTarget {
  static func optimize(_ bounds: CGRect) -> CGRect {
    let recommendedHitSize: CGFloat = 44

    var hitWidthIncrease: CGFloat = recommendedHitSize - bounds.width
    var hitHeightIncrease: CGFloat = recommendedHitSize - bounds.height

    if hitWidthIncrease < 0 { hitWidthIncrease = 0 }
    if hitHeightIncrease < 0 { hitHeightIncrease = 0 }

    let extendedBounds: CGRect = bounds.insetBy(dx: -hitWidthIncrease / 2,
      dy: -hitHeightIncrease / 2)

    return extendedBounds
  }
}

// ----------------------------
//
// RightToLeft.swift
//
// ----------------------------
/**
 
 Helper functions for dealing with right-to-left languages.
 
 */
struct RightToLeft {
  static func isRightToLeft(_ view: UIView) -> Bool {
    if #available(iOS 9.0, *) {
      return UIView.userInterfaceLayoutDirection(
        for: view.semanticContentAttribute) == .rightToLeft
    } else {
      return false
    }
  }
}
