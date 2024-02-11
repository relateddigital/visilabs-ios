import Foundation

// MARK: - BrandContainer
struct BrandContainer: Codable {
    let title: String
    let isActive: Bool
    let popularBrands: [PopularBrand]
    let report: Report

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case isActive = "IsActive"
        case popularBrands = "PopularBrands"
        case report
    }
    
    init?(responseDict: [String: Any]) {
        guard
            let title = responseDict["Title"] as? String,
            let isActive = responseDict["IsActive"] as? Bool,
            let popularBrandsDict = responseDict["PopularBrands"] as? [[String: Any]],
            let reportDict = responseDict["report"] as? [String: String],
            let report = Report(responseDict: reportDict)
        else {
            return nil
        }

        // PopularBrand tipini opsiyonel bir diziye çevir
        let popularBrands = popularBrandsDict.compactMap { PopularBrand(responseDict: $0) }

        self.title = title
        self.isActive = isActive
        self.popularBrands = popularBrands
        self.report = report
    }
}

// MARK: - PopularBrand
struct PopularBrand: Codable {
    let name: String
    let url: String?

    init(responseDict: [String: Any]) {
        self.name = responseDict["Name"] as? String ?? ""
        self.url = responseDict["Url"] as? String
    }
}

// MARK: - Report
struct Report: Codable {
    let impression, click: String

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
struct CategoryContainer: Codable {
    let title: String
    let isActive: Bool
    let popularCategories: [PopularCategory]
    let report: Report

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case isActive = "IsActive"
        case popularCategories = "PopularCategories"
        case report
    }
    
    init?(responseDict: [String: Any]) {
        guard
            let title = responseDict["Title"] as? String,
            let isActive = responseDict["IsActive"] as? Bool,
            let popularCategoriesDict = responseDict["PopularCategories"] as? [[String: Any]],
            let reportDict = responseDict["report"] as? [String: String],
            let report = Report(responseDict: reportDict)
        else {
            return nil
        }
        
        // PopularCategory tipini opsiyonel bir diziye çevir
        let popularCategories = popularCategoriesDict.compactMap { PopularCategory(responseDict: $0) }

        self.title = title
        self.isActive = isActive
        self.popularCategories = popularCategories
        self.report = report
    }

}

// MARK: - PopularCategory
struct PopularCategory: Codable {
    let name: String
    let products: [Product]
    
    init?(responseDict: [String: Any]) {
        guard
            let name = responseDict["Name"] as? String,
            let productsDict = responseDict["Products"] as? [[String: Any]]
        else {
            return nil
        }
        
        // Product tipini oluştur
        let products = productsDict.compactMap { Product(responseDict: $0) }

        self.name = name
        self.products = products
    }

}

// MARK: - Product
struct Product: Codable {
    let name, url, imageUrl, brandName: String
    let price, discountPrice: Double
    let code, currency, discountCurrency: String
    
    init?(responseDict: [String: Any]) {
        guard
            let name = responseDict["Name"] as? String,
            let url = responseDict["Url"] as? String,
            let imageUrl = responseDict["ImageUrl"] as? String,
            let brandName = responseDict["BrandName"] as? String,
            let price = responseDict["Price"] as? Double,
            let discountPrice = responseDict["DiscountPrice"] as? Double,
            let code = responseDict["Code"] as? String,
            let currency = responseDict["Currency"] as? String,
            let discountCurrency = responseDict["DiscountCurrency"] as? String
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
struct ProductAreaContainer: Codable {
    let title, preTitle: String
    let changeTitle: Bool
    let products: [Product]
    let searchResultMessage: String
    let report: Report
    
    init?(responseDict: [String: Any]) {
        guard
            let title = responseDict["Title"] as? String,
            let preTitle = responseDict["PreTitle"] as? String,
            let changeTitle = responseDict["ChangeTitle"] as? Bool,
            let productsDict = responseDict["Products"] as? [[String: Any]],
            let searchResultMessage = responseDict["SearchResultMessage"] as? String,
            let reportDict = responseDict["report"] as? [String: String],
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
struct SearchContainer: Codable {
    let title: String
    let isActive: Bool
    let searchUrlPrefix: String
    let popularSearches: [PopularSearch]
    let report: Report

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case isActive = "IsActive"
        case searchUrlPrefix = "SearchUrlPrefix"
        case popularSearches = "PopularSearches"
        case report
    }
    
    
    init?(responseDict: [String: Any]) {
        guard
            let title = responseDict["Title"] as? String,
            let isActive = responseDict["IsActive"] as? Bool,
            let searchUrlPrefix = responseDict["SearchUrlPrefix"] as? String,
            let popularSearchesDict = responseDict["PopularSearches"] as? [[String: Any]],
            let reportDict = responseDict["report"] as? [String: String],
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
struct PopularSearch: Codable {
    let name: String
    let url: String?
    
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
struct SearchStyle: Codable {
    let fontFamily, textColor, themeColor, titleColor: String
    let hoverColor, hoverTextColor: String
    let columnCount, rowCount: Int
    let querySelectorCss, titleBorderRadius, backgroundColor: String
    
    
    init?(responseDict: [String: Any]) {
        guard
            let fontFamily = responseDict["FontFamily"] as? String,
            let textColor = responseDict["TextColor"] as? String,
            let themeColor = responseDict["ThemeColor"] as? String,
            let titleColor = responseDict["TitleColor"] as? String,
            let hoverColor = responseDict["HoverColor"] as? String,
            let hoverTextColor = responseDict["HoverTextColor"] as? String,
            let columnCount = responseDict["ColumnCount"] as? Int,
            let rowCount = responseDict["RowCount"] as? Int,
            let querySelectorCss = responseDict["QuerySelectorCss"] as? String,
            let titleBorderRadius = responseDict["TitleBorderRadius"] as? String,
            let backgroundColor = responseDict["BackgroundColor"] as? String
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
struct SearchTemplate: Codable {
    let mainLayout, popularSearches, popularCategories, popularBrands: String
    let popularProducts, searchItemLayout, listItemLayout: String
    
    init?(responseDict: [String: Any]) {
        guard
            let mainLayout = responseDict["MainLayout"] as? String,
            let popularSearches = responseDict["PopularSearches"] as? String,
            let popularCategories = responseDict["PopularCategories"] as? String,
            let popularBrands = responseDict["PopularBrands"] as? String,
            let popularProducts = responseDict["PopularProducts"] as? String,
            let searchItemLayout = responseDict["SearchItemLayout"] as? String,
            let listItemLayout = responseDict["ListItemLayout"] as? String
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
    let queryselector: String?
    let customCss: String?
    let customJs: String?
    let hideSearchIfEmpty: Bool?
    let productAreaContainer: ProductAreaContainer?
    let categoryContainer: CategoryContainer?
    let brandContainer: BrandContainer?
    let searchContainer: SearchContainer?
    let searchStyle: SearchStyle?
    let searchTemplate: SearchTemplate?
    
    init(responseDict: [String: Any]) {
        self.queryselector = responseDict["Queryselector"] as? String
        self.customCss = responseDict["CustomCss"] as? String
        self.customJs = responseDict["CustomJs"] as? String
        self.hideSearchIfEmpty = responseDict["HideSearchIfEmpty"] as? Bool
        
        // Diğer yapıları burada initialize edin
        self.productAreaContainer = ProductAreaContainer(responseDict: responseDict["ProductAreaContainer"] as? [String: Any] ?? [:])
        self.categoryContainer = CategoryContainer(responseDict: responseDict["CategoryContainer"] as? [String: Any] ?? [:])
        self.brandContainer = BrandContainer(responseDict: responseDict["BrandContainer"] as? [String: Any] ?? [:])
        self.searchContainer = SearchContainer(responseDict: responseDict["SearchContainer"] as? [String: Any] ?? [:])
        self.searchStyle = SearchStyle(responseDict: responseDict["SearchStyle"] as? [String: Any] ?? [:])
        self.searchTemplate = SearchTemplate(responseDict: responseDict["SearchTemplate"] as? [String: Any] ?? [:])
    }
}
