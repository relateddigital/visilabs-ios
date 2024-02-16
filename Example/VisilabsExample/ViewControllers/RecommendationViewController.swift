//
//  RecommendationViewController.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 24.06.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Eureka
import UIKit
import VisilabsIOS

class RecommendationViewController: FormViewController {
    
    public enum Containers: String, CaseIterable {
        case productAreaContainer = "ProductAreaContainer"
        case categoryContainer = "CategoryContainer"
        case brandContainer = "BrandContainer"
        case searchContainer = "SearchContainer"
    }
    
    var searchResults = [String: Report]()
    let searchRecommendationSection = Section("Search Recommendation".uppercased(with: Locale(identifier: "en_US")))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }
    
    private func initializeForm() {
        form +++ Section("Recommendation".uppercased(with: Locale(identifier: "en_US")))
        <<< ButtonRow {
            $0.title = "Test"
        }.onCellSelection { _, _ in
            var properties = [String: String]()
            properties["prop1"] = "prop1val"
            properties["prop1"] = "prop2val"
            var filters = [VisilabsRecommendationFilter]()
            filters.append(
                VisilabsRecommendationFilter(attribute: .PRODUCTNAME, filterType: .like, value: "a"))
            
            filters.append(
                VisilabsRecommendationFilter(
                    attribute: .PRODUCTCODE,
                    filterType: .equals,
                    value: "000000300079892,000000400206545,000000400210042"))
            
            //filters.append(VisilabsRecommendationFilter(attribute: .PRODUCTNAME, filterType: .like, value: "laptop"))
            
            Visilabs.callAPI().recommend(
                zoneID: "1", productCode: "",
                filters: filters,
                properties: properties
            ) { response in
                if let error = response.error {
                    print(error)
                } else {
                    print("Widget Title: \(response.widgetTitle)")
                    var counter = 0
                    for product in response.products {
                        print("Product Title: \(product.title)")
                        print("Product qs: \(product.qs)")
                        if counter == 0 {
                            Visilabs.callAPI().trackRecommendationClick(qs: product.qs)
                        }
                        counter = counter + 1
                    }
                }
            }
        }
        <<< IntRow("zoneId") {
            $0.title = "Zone ID"
            $0.add(rule: RuleRequired(msg: "\($0.tag!) required"))
            $0.add(rule: RuleGreaterThan(min: 0, msg: "\($0.tag!) must be greater than 0"))
            $0.value = 1
        }
        <<< TextRow("productCode") {
            $0.title = "Product Code"
            $0.add(rule: RuleRequired(msg: "\($0.tag!) required"))
            $0.placeholder = "Product Code"
            $0.value = "asd-123"
        }
        
        form +++ searchRecommendationSection
        <<< TextRow("keyword") {
            $0.title = "Keyword"
            $0.add(rule: RuleRequired(msg: "\($0.tag!) required"))
            $0.placeholder = "Keyword"
            $0.value = ""
        }
        <<< TextRow("searchType") {
            $0.title = "Search Type"
            $0.placeholder = "Search Type"
            $0.value = "web"
        }
        <<< PickerInputRow<String>("container") {
            let containers = Containers.allCases.map { container in
                container.rawValue
            }
            $0.title = "Container"
            $0.options = containers
            $0.value = containers.first
        }
        
        
        <<< ButtonRow {
            $0.title = "Search"
        }.onCellSelection { _, _ in
            var keyword: String = ""
            var searchType: String = ""
            var container: Containers = .productAreaContainer
            if let keywordTextRow = self.form.rowBy(tag: "keyword") as TextRow? {
                keyword = (keywordTextRow.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let searchTypeTextRow = self.form.rowBy(tag: "searchType") as TextRow? {
                searchType = (searchTypeTextRow.value ?? "").trimmingCharacters(
                    in: .whitespacesAndNewlines)
            }
            
            if let containerPickerInputRow = self.form.rowBy(tag: "container") as? PickerInputRow<String> {
                container = Containers(rawValue: containerPickerInputRow.value ?? "") ?? .productAreaContainer
           }
            
            Visilabs.callAPI().searcRecommendation(keyword: keyword, searchType: searchType) {
                response in
                
                DispatchQueue.main.async {
                    self.displaySearchRecommendationResults(response: response, container: container)
                }
                print(response)
            }
            
        }
        
    }
    
    private func displaySearchRecommendationResults(response: VisilabsSearchRecommendationResponse, container: Containers) {
        
        searchRecommendationSection.removeAll(where: { row in row.tag?.hasPrefix("searchResult") ?? false })
        searchResults = [:]
        
        switch container {
        case .productAreaContainer:
             response.productAreaContainer?.products.forEach({ product in
                searchResults[product.name] = response.productAreaContainer?.report
            })
        case .categoryContainer:
            response.categoryContainer?.popularCategories.forEach({ popularCategory in
                searchResults[popularCategory.name] = response.categoryContainer?.report
            })
        case .brandContainer:
            response.brandContainer?.popularBrands.forEach({ popularBrand in
                searchResults[popularBrand.name] = response.brandContainer?.report
            })
        case .searchContainer:
            response.searchContainer?.popularSearches.forEach({ popularSearch in
                searchResults[popularSearch.name] = response.searchContainer?.report
            })
        }
        
        
        searchResults.enumerated().forEach { index, searchResult in
            searchRecommendationSection.append(ButtonRow("searchResult-\(index)") {
                $0.tag = "searchResult-\(index)"
                $0.title = searchResult.key
                $0.value = searchResult.key
                $0.cell.height = { CGFloat(30.0) }
                $0.cell.textLabel?.font = .systemFont(ofSize: 10)
            }.onCellSelection { _, labelRow in
                
                if let report = self.searchResults[labelRow.value ?? ""] {
                    Visilabs.callAPI().trackSearchRecommendationClick(searchReport: report)

                }

                
            })
        }
        
        
    }
    
}


/*
 //var filtersSection = Section("FILTERS")
 //var filterSections: [Section] = []
 
 +++ filtersSection
 <<< ButtonRow {
 $0.title = "Add Filter"
 }.onCellSelection { _, _ in
 self.addFilterSection()
 }
 
 +++ Section()
 <<< LabelRow {
 $0.title = "not implemented yet"
 //            $0.cell.contentView.backgroundColor = .white
 //            $0.cell.backgroundColor = .white
 //            $0.cell.textLabel?.textColor = .black
 //            $0.cell.textLabel?.textAlignment = .left
 $0.disabled = true
 }
 <<< ButtonRow {
 $0.title = "recommend"
 $0.disabled = true
 }
 */

/*
 private func addFilterSection() {
 let filterSection = Section("FILTER \(filterSections.count + 1)") { section in
 section.header = {
 var header = HeaderFooterView<UIView>(.callback({
 let view = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
 view.text = "╳"
 view.textAlignment = .right
 view.font = .systemFont(ofSize: 20.0, weight: .bold)
 view.textColor = .red
 let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.filtersSection,
 action: #selector(self.removeSection))
 view.addGestureRecognizer(tap)
 return view
 }))
 header.height = { 50 }
 return header
 }()
 }
 filterSections.append(filterSection)
 //print(filtersSection.index)
 form.insert(filterSection, at: filtersSection.index! + filterSections.count)
 }
 
 @objc func removeSection() {
 //        filterSections.remove(at: filtersSection.index! + filtersSection.count)
 filtersSection.remove(at: filtersSection.index! + filtersSection.count)
 }
 */
