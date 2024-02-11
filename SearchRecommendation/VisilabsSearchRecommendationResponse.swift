//
//  VisilabsSearchRecommendationResponse.swift
//  CleanyModal
//
//  Created by Orhun Akmil on 9.02.2024.
//

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
}

// MARK: - PopularBrand
struct PopularBrand: Codable {
}

// MARK: - Report
struct Report: Codable {
    let impression, click: String

    enum CodingKeys: String, CodingKey {
        case impression = "impression"
        case click = "click"
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
}

// MARK: - PopularCategory
struct PopularCategory: Codable {
    let name: String
    let products: [Product]
}

// MARK: - Product
struct Product: Codable {
    let name, url, imageUrl, brandName: String
    let price, discountPrice: Double
    let code, currency, discountCurrency: String
}

// MARK: - ProductAreaContainer
struct ProductAreaContainer: Codable {
    let title, preTitle: String
    let changeTitle: Bool
    let products: [Product]
    let searchResultMessage: String
    let report: Report
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
}

// MARK: - PopularSearch
struct PopularSearch: Codable {
    let name: String
    let url: String?
}

// MARK: - SearchStyle
struct SearchStyle: Codable {
    let fontFamily, textColor, themeColor, titleColor: String
    let hoverColor, hoverTextColor: String
    let columnCount, rowCount: Int
    let querySelectorCss, titleBorderRadius, backgroundColor: String
}

// MARK: - SearchTemplate
struct SearchTemplate: Codable {
    let mainLayout, popularSearches, popularCategories, popularBrands: String
    let popularProducts, searchItemLayout, listItemLayout: String
}


public struct VisilabsSearchRecommendationResponse {
    
    
    let queryselector: String? = nil
    let customCss: String? = nil
    let customJs: String? = nil
    let hideSearchIfEmpty: Bool? = nil
    let productAreaContainer: ProductAreaContainer? = nil
    let categoryContainer: CategoryContainer? = nil
    let brandContainer: BrandContainer? = nil
    let searchContainer: SearchContainer? = nil
    let searchStyle: SearchStyle? = nil
    let searchTemplate: SearchTemplate? = nil
    
}
