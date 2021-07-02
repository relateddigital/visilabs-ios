//
//  CountdownTimerModel.swift
//  VisilabsIOS
//
//  Created by Said Alır on 28.06.2021.
//

import UIKit

public class CountdownModel {
    
    //String variables
    var title: String
    var subtitle: String
    var buttonText: String
    var couponCode: String?
    
    //This is epoch time of final date
    var finalDate: Int
    
    //Colors
    var backgroundColor: UIColor
    var titleColor: UIColor
    var subtitleColor: UIColor
    var buttonColor: UIColor
    var buttonTextColor: UIColor
    var couponColor: UIColor?
    var couponBgColor: UIColor?
    
    //Fonts
    var titleFont: UIFont
    var subtitleFont: UIFont
    var buttonFont: UIFont
    var couponFont: UIFont?
    
    //Enums
    var location: CountdownLocation
    var timerType: CountdownTimerType
    var closeButtonColor: ButtonColor = .white
   
    private static let MINUTE: Int = 60
    private static let HOUR: Int = MINUTE * 60
    private static let DAY: Int = HOUR * 24
    private static let WEEK: Int = DAY * 7
    
    //This init func can be overload to convert backends respond
    public init(title: String,
                subtitle: String,
                buttonText: String,
                coupon: String?,
                finalDate: Int,
                bgColor: UIColor,
                titleColor: UIColor,
                subtitleColor: UIColor,
                buttonColor: UIColor,
                buttonTextColor: UIColor,
                couponColor: UIColor?,
                couponBgColor: UIColor?,
                titleFont: UIFont,
                subtitleFont: UIFont,
                buttonFont: UIFont,
                couponFont: UIFont?,
                location: CountdownLocation,
                timerType: CountdownTimerType,
                closeButtonColor: ButtonColor) {
        self.title = title
        self.subtitle = subtitle
        self.buttonText = buttonText
        self.couponCode = coupon
        self.finalDate = finalDate
        self.backgroundColor = bgColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.buttonColor = buttonColor
        self.buttonTextColor = buttonTextColor
        self.couponColor = couponColor
        self.couponBgColor = couponBgColor
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.buttonFont = buttonFont
        self.couponFont = couponFont
        self.location = location
        self.timerType = timerType
        self.closeButtonColor = closeButtonColor
    
    }
    
    public static func convertDateIntoTimeLabel(date: Int, type: CountdownTimerType) -> String {
        let now = Date().timeIntervalSince1970
        var diff = date - Int(now)
        switch type {
        case .D:
            var days = 0
            (diff, days) = CountdownModel.initDays(diff: diff)
            return "\(days)"
        case .DHM:
            var m: Int?
            var h: Int?
            var d = 0
            (diff, d) = CountdownModel.initDays(diff: diff)
            (diff, h) = CountdownModel.initHours(diff: diff, type: type)
            (diff, m) = CountdownModel.initMinutes(diff: diff, type: type)
            return "\(d) : \(h ?? 0) : \(m ?? 0)"
        case .DHMS:
            var m: Int?
            var h: Int?
            var d = 0
            (diff, d) = CountdownModel.initDays(diff: diff)
            (diff, h) = CountdownModel.initHours(diff: diff, type: type)
            (diff, m) = CountdownModel.initMinutes(diff: diff, type: type)
            return "\(d) : \(h ?? 0) : \(m ?? 0) : \(diff)"
        case .WDHMS:
            var m: Int?
            var h: Int?
            var d = 0
            var w: Int?
            (diff, w) = CountdownModel.initWeeks(diff: diff, type: type)
            (diff, d) = CountdownModel.initDays(diff: diff)
            (diff, h) = CountdownModel.initHours(diff: diff, type: type)
            (diff, m) = CountdownModel.initMinutes(diff: diff, type: type)
            return "\(String(describing: w)) : \(d) : \(h ?? 0) : \(m ?? 0) : \(diff)"
        }
    }
    
    //This helper functions can be refactor by higher order function
    private static func initWeeks(diff: Int, type: CountdownTimerType) -> (Int, Int?) {
        if type != .WDHMS {
            return (diff, nil)
        }
        var weeks = 0
        if diff < WEEK {
            return (diff, weeks)
        } else {
            var newDiff = diff
            weeks = Int(diff / WEEK)
            newDiff = diff - (weeks*WEEK)
            return(newDiff, weeks)
        }
    }
    
    private static func initDays(diff: Int) -> (Int, Int) {
        if diff < DAY {
            return (diff, 0)
        } else {
            var days = 0
            var newDiff = diff
            days = Int(diff / DAY)
            newDiff = diff - (days*DAY)
            return(newDiff, days)
        }
    }
    
    private static func initHours(diff: Int, type: CountdownTimerType) -> (Int, Int?) {
        if type == .D {
            return (diff, nil)
        }
        var hours = 0
        if diff < HOUR {
            return (diff, hours)
        } else {
            var newDiff = diff
            hours = Int(diff / HOUR)
            newDiff = diff - (hours*HOUR)
            return(newDiff, hours)
        }
    }
    
    private static func initMinutes(diff: Int, type: CountdownTimerType) -> (Int, Int?) {
        if type == .D {
            return (diff, nil)
        }
        var minutes = 0
        if diff < MINUTE {
            return (diff, minutes)
        } else {
            var newDiff = diff
            minutes = Int(diff / MINUTE)
            newDiff = diff - (minutes*MINUTE)
            return(newDiff, minutes)
        }
    }
    
}


public enum CountdownLocation: String {
    case top
    case bottom
}


//Convert to turkish!!!
public enum CountdownTimerType: String {
    case WDHMS = "Week / Days / Hours / Minutes / Seconds"
    case DHMS = "Days / Hours / Minutes / Seconds"
    case DHM = "Days / Hours / Minutes"
    case D = "Days"
}

