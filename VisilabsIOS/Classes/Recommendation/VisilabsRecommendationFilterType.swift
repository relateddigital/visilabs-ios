//
//  VisilabsRecommendationFilterType.swift
//  VisilabsIOS
//
//  Created by Egemen on 29.06.2020.
//

public class VisilabsRecommendationFilterType {
    static let equals = 0
    static let notEquals = 1
    static let like = 2, include = 2
    static let notLike = 3, exclude = 3
    static let greaterThan = 4
    static let lessThan = 5
    static let greaterOrEquals = 6
    static let lessOrEquals = 7
}

public enum VisilabsProductAttribute: String {
    case title
    case img
    case code
    case target
    case dest_url
    case brand
    case price
    case dprice
    case cur
    case rating
    case comment
    case freeshipping
    case samedayshipping
    case attr1
    case attr2
    case attr3
    case attr4
    case attr5
}
