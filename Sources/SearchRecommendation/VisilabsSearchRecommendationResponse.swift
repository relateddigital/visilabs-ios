import Foundation

// MARK: - BrandContainer
public struct BrandContainer: Codable {
    public let title: String
    public let isActive: Bool
    public let popularBrands: [PopularBrand]
    public let report: Report

    public enum CodingKeys: String, CodingKey {
        case title = "Title"
        case isActive = "IsActive"
        case popularBrands = "PopularBrands"
        case report
    }
    
    init?(responseDict: [String: Any]) {
        guard
            let title = responseDict[VisilabsConstants.Title] as? String,
            let isActive = responseDict[VisilabsConstants.IsActive] as? Bool,
            let popularBrandsDict = responseDict[VisilabsConstants.PopularBrands] as? [[String: Any]],
            let reportDict = responseDict[VisilabsConstants.report] as? [String: String],
            let report = Report(responseDict: reportDict)
        else {
            return nil
        }

        let popularBrands = popularBrandsDict.compactMap { PopularBrand(responseDict: $0) }

        self.title = title
        self.isActive = isActive
        self.popularBrands = popularBrands
        self.report = report
    }
}

// MARK: - PopularBrand
public struct PopularBrand: Codable {
    public let name: String
    public let url: String?

    init(responseDict: [String: Any]) {
        self.name = responseDict[VisilabsConstants.Name] as? String ?? ""
        self.url = responseDict[VisilabsConstants.Url] as? String
    }
}

// MARK: - Report
public struct Report: Codable {
    public let impression, click: String

    enum CodingKeys: String, CodingKey {
        case impression = "impression"
        case click = "click"
    }
    
    init?(responseDict: [String: String]) {
        guard
            let impression = responseDict["impression"],
            let click = responseDict["click"]
        else {
            return nil
        }

        self.impression = impression
        self.click = click
    }
}

// MARK: - CategoryContainer
public struct CategoryContainer: Codable {
    public let title: String
    public let isActive: Bool
    public let popularCategories: [PopularCategory]
    public let report: Report

    public enum CodingKeys: String, CodingKey {
        case title = "Title"
        case isActive = "IsActive"
        case popularCategories = "PopularCategories"
        case report
    }
    
    init?(responseDict: [String: Any]) {
        guard
            let title = responseDict[VisilabsConstants.Title] as? String,
            let isActive = responseDict[VisilabsConstants.IsActive] as? Bool,
            let popularCategoriesDict = responseDict[VisilabsConstants.PopularCategories] as? [[String: Any]],
            let reportDict = responseDict[VisilabsConstants.report] as? [String: String],
            let report = Report(responseDict: reportDict)
        else {
            return nil
        }
        
        let popularCategories = popularCategoriesDict.compactMap { PopularCategory(responseDict: $0) }

        self.title = title
        self.isActive = isActive
        self.popularCategories = popularCategories
        self.report = report
    }

}

// MARK: - PopularCategory
public struct PopularCategory: Codable {
    public let name: String
    public let products: [Product]
    
    init?(responseDict: [String: Any]) {
        guard
            let name = responseDict[VisilabsConstants.Name] as? String,
            let productsDict = responseDict[VisilabsConstants.Products] as? [[String: Any]]
        else {
            return nil
        }
        
        let products = productsDict.compactMap { Product(responseDict: $0) }

        self.name = name
        self.products = products
    }

}

// MARK: - Product
public struct Product: Codable {
    public let name, url, imageUrl, brandName: String
    public let price, discountPrice: Double
    public let code, currency, discountCurrency: String
    
    init?(responseDict: [String: Any]) {
        guard
            let name = responseDict[VisilabsConstants.Name] as? String,
            let url = responseDict[VisilabsConstants.Url] as? String,
            let imageUrl = responseDict[VisilabsConstants.ImageUrl] as? String,
            let brandName = responseDict[VisilabsConstants.BrandName] as? String,
            let price = responseDict[VisilabsConstants.Price] as? Double,
            let discountPrice = responseDict[VisilabsConstants.DiscountPrice] as? Double,
            let code = responseDict[VisilabsConstants.Code] as? String,
            let currency = responseDict[VisilabsConstants.Currency] as? String,
            let discountCurrency = responseDict[VisilabsConstants.DiscountCurrency] as? String
        else {
            return nil
        }

        self.name = name
        self.url = url
        self.imageUrl = imageUrl
        self.brandName = brandName
        self.price = price
        self.discountPrice = discountPrice
        self.code = code
        self.currency = currency
        self.discountCurrency = discountCurrency
    }
}

// MARK: - ProductAreaContainer
public struct ProductAreaContainer: Codable {
    public let title, preTitle: String
    public let changeTitle: Bool
    public let products: [Product]
    public let searchResultMessage: String
    public let report: Report
    
    init?(responseDict: [String: Any]) {
        guard
            let title = responseDict[VisilabsConstants.Title] as? String,
            let preTitle = responseDict[VisilabsConstants.PreTitle] as? String,
            let changeTitle = responseDict[VisilabsConstants.ChangeTitle] as? Bool,
            let productsDict = responseDict[VisilabsConstants.Products] as? [[String: Any]],
            let searchResultMessage = responseDict[VisilabsConstants.SearchResultMessage] as? String,
            let reportDict = responseDict[VisilabsConstants.report] as? [String: String],
            let report = Report(responseDict: reportDict)
        else {
            return nil
        }
        
        let products = productsDict.compactMap({ Product(responseDict: $0) })
        
        self.title = title
        self.preTitle = preTitle
        self.changeTitle = changeTitle
        self.products = products
        self.searchResultMessage = searchResultMessage
        self.report = report
    }
}

// MARK: - SearchContainer
public struct SearchContainer: Codable {
    public let title: String
    public let isActive: Bool
    public let searchUrlPrefix: String
    public let popularSearches: [PopularSearch]
    public let report: Report

    public enum CodingKeys: String, CodingKey {
        case title = "Title"
        case isActive = "IsActive"
        case searchUrlPrefix = "SearchUrlPrefix"
        case popularSearches = "PopularSearches"
        case report
    }
    
    
    init?(responseDict: [String: Any]) {
        guard
            let title = responseDict[VisilabsConstants.Title] as? String,
            let isActive = responseDict[VisilabsConstants.IsActive] as? Bool,
            let searchUrlPrefix = responseDict[VisilabsConstants.SearchUrlPrefix] as? String,
            let popularSearchesDict = responseDict[VisilabsConstants.PopularSearches] as? [[String: Any]],
            let reportDict = responseDict[VisilabsConstants.report] as? [String: String],
            let report = Report(responseDict: reportDict)
        else {
            return nil
        }

        let popularSearches = popularSearchesDict.compactMap({ PopularSearch(responseDict: $0) })
        
        self.title = title
        self.isActive = isActive
        self.searchUrlPrefix = searchUrlPrefix
        self.popularSearches = popularSearches
        self.report = report
    }
}

// MARK: - PopularSearch
public struct PopularSearch: Codable {
    public let name: String
    public let url: String?
    
    init?(responseDict: [String: Any]) {
        guard
            let name = responseDict["Name"] as? String,
            let url = responseDict["Url"] as? String?
        else {
            return nil
        }

        self.name = name
        self.url = url
    }
}

// MARK: - SearchStyle
public struct SearchStyle: Codable {
    public let fontFamily, textColor, themeColor, titleColor: String
    public let hoverColor, hoverTextColor: String
    public let columnCount, rowCount: Int
    public let querySelectorCss, titleBorderRadius, backgroundColor: String
    
    
    init?(responseDict: [String: Any]) {
        guard
            let fontFamily = responseDict[VisilabsConstants.FontFamily] as? String,
            let textColor = responseDict[VisilabsConstants.TextColor] as? String,
            let themeColor = responseDict[VisilabsConstants.ThemeColor] as? String,
            let titleColor = responseDict[VisilabsConstants.TitleColor] as? String,
            let hoverColor = responseDict[VisilabsConstants.HoverColor] as? String,
            let hoverTextColor = responseDict[VisilabsConstants.HoverTextColor] as? String,
            let columnCount = responseDict[VisilabsConstants.ColumnCount] as? Int,
            let rowCount = responseDict[VisilabsConstants.RowCount] as? Int,
            let querySelectorCss = responseDict[VisilabsConstants.QuerySelectorCss] as? String,
            let titleBorderRadius = responseDict[VisilabsConstants.TitleBorderRadius] as? String,
            let backgroundColor = responseDict[VisilabsConstants.BackgroundColor] as? String
        else {
            return nil
        }

        self.fontFamily = fontFamily
        self.textColor = textColor
        self.themeColor = themeColor
        self.titleColor = titleColor
        self.hoverColor = hoverColor
        self.hoverTextColor = hoverTextColor
        self.columnCount = columnCount
        self.rowCount = rowCount
        self.querySelectorCss = querySelectorCss
        self.titleBorderRadius = titleBorderRadius
        self.backgroundColor = backgroundColor
    }
}

// MARK: - SearchTemplate
public struct SearchTemplate: Codable {
    public let mainLayout, popularSearches, popularCategories, popularBrands: String
    public let popularProducts, searchItemLayout, listItemLayout: String
    
    init?(responseDict: [String: Any]) {
        guard
            let mainLayout = responseDict[VisilabsConstants.MainLayout] as? String,
            let popularSearches = responseDict[VisilabsConstants.PopularSearches] as? String,
            let popularCategories = responseDict[VisilabsConstants.PopularCategories] as? String,
            let popularBrands = responseDict[VisilabsConstants.PopularBrands] as? String,
            let popularProducts = responseDict[VisilabsConstants.PopularProducts] as? String,
            let searchItemLayout = responseDict[VisilabsConstants.SearchItemLayout] as? String,
            let listItemLayout = responseDict[VisilabsConstants.ListItemLayout] as? String
        else {
            return nil
        }

        self.mainLayout = mainLayout
        self.popularSearches = popularSearches
        self.popularCategories = popularCategories
        self.popularBrands = popularBrands
        self.popularProducts = popularProducts
        self.searchItemLayout = searchItemLayout
        self.listItemLayout = listItemLayout
    }
}

public struct VisilabsSearchRecommendationResponse {
    public let queryselector: String?
    public let customCss: String?
    public let customJs: String?
    public let hideSearchIfEmpty: Bool?
    public let productAreaContainer: ProductAreaContainer?
    public let categoryContainer: CategoryContainer?
    public let brandContainer: BrandContainer?
    public let searchContainer: SearchContainer?
    public let searchStyle: SearchStyle?
    public let searchTemplate: SearchTemplate?
    
    init(responseDict: [String: Any]) {
        self.queryselector = responseDict[VisilabsConstants.Queryselector] as? String
        self.customCss = responseDict[VisilabsConstants.CustomCss] as? String
        self.customJs = responseDict[VisilabsConstants.CustomJs] as? String
        self.hideSearchIfEmpty = responseDict[VisilabsConstants.HideSearchIfEmpty] as? Bool
        
        
        self.productAreaContainer = ProductAreaContainer(responseDict: responseDict[VisilabsConstants.ProductAreaContainer] as? [String: Any] ?? [:])
        self.categoryContainer = CategoryContainer(responseDict: responseDict[VisilabsConstants.CategoryContainer] as? [String: Any] ?? [:])
        self.brandContainer = BrandContainer(responseDict: responseDict[VisilabsConstants.BrandContainer] as? [String: Any] ?? [:])
        self.searchContainer = SearchContainer(responseDict: responseDict[VisilabsConstants.SearchContainer] as? [String: Any] ?? [:])
        self.searchStyle = SearchStyle(responseDict: responseDict[VisilabsConstants.SearchStyle] as? [String: Any] ?? [:])
        self.searchTemplate = SearchTemplate(responseDict: responseDict[VisilabsConstants.SearchTemplate] as? [String: Any] ?? [:])
    }
}
