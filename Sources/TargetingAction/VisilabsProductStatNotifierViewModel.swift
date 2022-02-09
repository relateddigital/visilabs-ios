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
    var threshold: Int // TODO: kullanmayalım
    var showclosebtn: Bool
    var content_text_color: String
    var content_font_family: String
    var content_text_size: String
    var contentcount_text_color: String
    var contentcount_text_size: String
    var closeButtonColor: String
    var contentCount = 0  // TODO: kullanmayalım
    var attributedString: NSAttributedString? = nil
    
    func getContentFont() -> UIFont {
        return VisilabsHelper.getFont(fontFamily: content_font_family, fontSize: content_text_size, style: .title2)
    }
    
    func getContentCountFont() -> UIFont {
        return VisilabsHelper.getFont(fontFamily: content_font_family, fontSize: contentcount_text_size, style: .title2)
    }
    
    mutating func setAttributedString() {
        if let regex = try? NSRegularExpression(pattern: "<COUNT>(.+?)</COUNT>", options: .dotMatchesLineSeparators) {
            let results = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            if results.isEmpty {
                if content.contains("<COUNT>"){
                    VisilabsLogger.error("Product stat notifier: Could not parse the number!")
                    return
                } else {
                    let aString = NSMutableAttributedString(string: content)
                    aString.addAttribute(.font, value: self.getContentFont(), range: NSRange(location: 0, length: content.count))
                    if let contentColor = UIColor(hex: self.content_text_color) {
                        aString.addAttribute(.foregroundColor, value: contentColor, range: NSRange(location: 0, length: content.count))
                    }
                    attributedString = aString
                    VisilabsLogger.warn("Product stat notifier: Tag COUNT is not used!");
                }
            } else {
                var currentIndex = 0
                let aString = NSMutableAttributedString()
                for result in results {
                    let contentString = content[content.index(content.startIndex, offsetBy: currentIndex)..<content.index(content.startIndex, offsetBy: result.range.lowerBound)]
                    let aContentString = NSMutableAttributedString(string: String(contentString))
                    aContentString.addAttribute(.font, value: self.getContentFont(), range: NSRange(location: 0, length: contentString.count))
                    if let contentColor = UIColor(hex: self.content_text_color) {
                        aContentString.addAttribute(.foregroundColor, value: contentColor, range: NSRange(location: 0, length: contentString.count))
                    }
                    let numberSubString = content[content.index(content.startIndex, offsetBy: result.range.lowerBound)..<content.index(content.startIndex, offsetBy: result.range.upperBound)]
                    let numberString = numberSubString.replacingOccurrences(of: "<COUNT>", with: "").replacingOccurrences(of: "</COUNT>", with: "")
                    let aNumberString = NSMutableAttributedString(string: String(numberString))
                    aNumberString.addAttribute(.font, value: self.getContentCountFont(), range: NSRange(location: 0, length: numberString.count))
                    if let numberColor = UIColor(hex: self.contentcount_text_color) {
                        aNumberString.addAttribute(.foregroundColor, value: numberColor, range: NSRange(location: 0, length: numberString.count))
                    }
                    aString.append(aContentString)
                    if let _ = Int(numberString) {
                        aString.append(aNumberString)
                    }
                    currentIndex = result.range.upperBound
                }
                let contentString = content[content.index(content.startIndex, offsetBy: currentIndex)..<content.index(content.startIndex, offsetBy: content.count)]
                let aContentString = NSMutableAttributedString(string: String(contentString))
                aContentString.addAttribute(.font, value: self.getContentFont(), range: NSRange(location: 0, length: contentString.count))
                if let contentColor = UIColor(hex: self.content_text_color) {
                    aContentString.addAttribute(.foregroundColor, value: contentColor, range: NSRange(location: 0, length: contentString.count))
                }
                aString.append(aContentString)
                attributedString = aString
            }
        }
    }
    
    
}
