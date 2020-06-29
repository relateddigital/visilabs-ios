//
//  VisilabsRecommendationFilterType.swift
//  VisilabsIOS
//
//  Created by Egemen on 29.06.2020.
//

public enum VisilabsRecommendationFilterType: Int {
    case equals = 0
    case notEquals = 1
    case like = 2
    case notLike = 3
    case greaterThan = 4
    case lessThan = 5
    case greaterOrEquals = 6
    case lessOrEquals = 7
    
    static let include = like
    static let exclude = notLike
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

public class VisilabsRecommendationFilter {
    var attribute: VisilabsProductAttribute
    var filterType: VisilabsRecommendationFilterType
    var value: String
    
    init(attribute: VisilabsProductAttribute, filterType: VisilabsRecommendationFilterType, value: String){
        self.attribute = attribute
        self.filterType = filterType
        self.value = value
    }
}
