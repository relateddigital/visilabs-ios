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

public class VisilabsProduct {
    var code: String
    var title: String
    var img: String
    var dest_url: String
    var brand: String
    var price: Double
    var dprice: Double
    var cur: String
    var dcur: String
    var freeshipping: Bool
    var samedayshipping: Bool
    var rating: Int
    var comment: Int
    var discount: Double
    var attr1: String
    var attr2: String
    var attr3: String
    var attr4: String
    var attr5: String
    
    internal init(code: String, title: String, img: String, dest_url: String, brand: String, price: Double, dprice: Double, cur: String, dcur: String, freeshipping: Bool, samedayshipping: Bool, rating: Int, comment: Int, discount: Double, attr1: String, attr2: String, attr3: String, attr4: String, attr5: String) {
        self.code = code
        self.title = title
        self.img = img
        self.dest_url = dest_url
        self.brand = brand
        self.price = price
        self.dprice = dprice
        self.cur = cur
        self.dcur = dcur
        self.freeshipping = freeshipping
        self.samedayshipping = samedayshipping
        self.rating = rating
        self.comment = comment
        self.discount = discount
        self.attr1 = attr1
        self.attr2 = attr2
        self.attr3 = attr3
        self.attr4 = attr4
        self.attr5 = attr5
    }
}
