//
//  SocialProofModel.swift
//  VisilabsIOS
//
//  Created by Said Alır on 21.02.2021.
//

import Foundation

public class SocialProofModel {
    
    public init(text: String,
                number: String,
                location: SocialProofLocation,
                duration: SocialProofDuration,
                backgroundColor: UIColor,
                textColor: UIColor,
                numberColor: UIColor,
                textFont: UIFont,
                numberFont: UIFont,
                closeButtonColor: ButtonColor? = nil) {
        
        self.text = text
        self.number = number
        self.location = location
        self.duration = duration
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.numberColor = numberColor
        self.textFont = textFont
        self.numberFont = numberFont
        self.closeButtonColor = closeButtonColor
    }
    
    var text: String
    var number: String //How many people bought (or viewed)
    var location: SocialProofLocation
    var duration: SocialProofDuration
    var backgroundColor: UIColor
    var textColor: UIColor
    var numberColor: UIColor
    var textFont: UIFont
    var numberFont: UIFont
    var closeButtonColor: ButtonColor? = nil
    
}


public enum SocialProofLocation: String {
    case top
    case bottom
}


/// In seconds
public enum SocialProofDuration: Int {
    case sec5 = 5
    case sec10 = 10
    case sec15 = 15
    case sec20 = 20
    case sec30 = 30
    case sec40 = 40
    case min1 = 60
    case min2 = 120
    case infinite = 0
}
