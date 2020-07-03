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
    
    public enum PayloadKey {
        public static let code = "code"
        public static let title = "title"
        public static let img = "img"
        public static let dest_url = "dest_url"
        public static let brand = "brand"
        public static let price = "price"
        public static let dprice = "dprice"
        public static let cur = "cur"
        public static let dcur = "dcur"
        public static let freeshipping = "freeshipping"
        public static let samedayshipping = "samedayshipping"
        public static let rating = "rating"
        public static let comment = "comment"
        public static let discount = "discount"
        public static let attr1 = "attr1"
        public static let attr2 = "attr2"
        public static let attr3 = "attr3"
        public static let attr4 = "attr4"
        public static let attr5 = "attr5"
    }
    
    public var code: String
    public var title: String
    public var img: String
    public var dest_url: String
    public var brand: String
    public var price: Double = 0.0
    public var dprice: Double = 0.0
    public var cur: String
    public var dcur: String
    public var freeshipping: Bool = false
    public var samedayshipping: Bool  = false
    public var rating: Int = 0
    public var comment: Int = 0
    public var discount: Double = 0.0
    public var attr1: String
    public var attr2: String
    public var attr3: String
    public var attr4: String
    public var attr5: String
    
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
    
    internal init?(JSONObject: [String: Any?]?) {
        
        guard let object = JSONObject else {
            VisilabsLogger.error(message: "product json object should not be nil")
            return nil
        }
        
        guard let code = object[PayloadKey.code] as? String else {
            VisilabsLogger.error(message: "invalid \(PayloadKey.code)")
            return nil
        }

        self.code = code
        self.title = object[PayloadKey.title] as? String ?? ""
        self.img = object[PayloadKey.img] as? String ?? ""
        self.dest_url = object[PayloadKey.dest_url] as? String ?? ""
        self.brand = object[PayloadKey.brand] as? String ?? ""
        self.price = object[PayloadKey.price] as? Double ?? 0.0
        self.dprice = object[PayloadKey.dprice] as? Double ?? 0.0
        self.cur = object[PayloadKey.cur] as? String ?? ""
        self.dcur = object[PayloadKey.dcur] as? String ?? ""
        self.freeshipping = object[PayloadKey.freeshipping] as? Bool ?? false
        self.samedayshipping = object[PayloadKey.samedayshipping] as? Bool ?? false
        self.rating = object[PayloadKey.rating] as? Int ?? 0
        self.comment = object[PayloadKey.comment] as? Int ?? 0
        self.discount = object[PayloadKey.discount] as? Double ?? 0.0
        self.attr1 = object[PayloadKey.attr1] as? String ?? ""
        self.attr2 = object[PayloadKey.attr2] as? String ?? ""
        self.attr3 = object[PayloadKey.attr3] as? String ?? ""
        self.attr4 = object[PayloadKey.attr4] as? String ?? ""
        self.attr5 = object[PayloadKey.attr5] as? String ?? ""
    }
}

public class VisilabsRecommendationResponse {
    public var products: [VisilabsProduct]
    public var error: VisilabsReason?
    
    internal init(products: [VisilabsProduct], error: VisilabsReason? = nil) {
        self.products = products
        self.error = error
    }
}
