//
//  VisilabsProductStatNotifierViewModel.swift
//  VisilabsIOS
//
//  Created by Said Alır on 21.02.2021.
//

import UIKit

public struct VisilabsProductStatNotifierViewModel: TargetingActionViewModel {
    public var targetingActionType: TargetingActionType
    var content: String
    var timeout: String
    var position: VisilabsProductStatNotifierPosition
    var bgcolor: String
    var threshold: Int
    var showclosebtn: Bool
    var content_text_color: String
    var content_font_family: String
    var content_text_size: String
    var contentcount_text_color: String
    var contentcount_text_size: String
    var closeButtonColor: String
    
    func getContentFont() -> UIFont {
        return VisilabsInAppNotification.getFont(fontFamily: content_font_family, fontSize: content_text_size, style: .title2)
    }
    
    func getContentCountFont() -> UIFont {
        return VisilabsInAppNotification.getFont(fontFamily: content_font_family, fontSize: contentcount_text_size, style: .title2)
    }
    
    func getAttributedString() -> NSAttributedString? {
        let aString = NSMutableAttributedString(string: content)
        aString.addAttribute(.font, value: self.getContentFont(), range: NSRange(location: 0, length: content.count))
        if let contentColor = UIColor(hex: self.content_text_color) {
            aString.addAttribute(.foregroundColor, value: contentColor, range: NSRange(location: 0, length: content.count))
        }
        if let regex = try? NSRegularExpression(pattern: "\\D+", options: .caseInsensitive) {
            let range = NSRange(location: 0, length: content.count)
            let num = regex.stringByReplacingMatches(in: content, options: [], range: range, withTemplate: "")
            if let rangeOfNum = content.range(of: (num)) {
                let startPos = content.distance(from: content.startIndex, to: rangeOfNum.lowerBound)
                let endPos = content.distance(from: content.startIndex, to: rangeOfNum.upperBound)
                if (endPos - startPos) == num.count {
                    aString.addAttribute(.font, value: self.getContentCountFont(), range: NSRange(location: startPos, length: num.count))
                    if let contentCountTextColor = UIColor(hex: self.contentcount_text_color) {
                        aString.addAttribute(.foregroundColor, value: contentCountTextColor, range: NSRange(location: startPos, length: num.count))
                    }
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        return aString
    }
}
