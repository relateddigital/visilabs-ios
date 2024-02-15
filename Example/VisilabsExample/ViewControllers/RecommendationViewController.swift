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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }
    var filtersSection = Section("FILTERS")
    var filterSections: [Section] = []
    
    private func initializeForm() {
        form +++
        Section("Recommendation".uppercased(with: Locale(identifier: "en_US")))
        <<< ButtonRow {
            $0.title = "Test"
        }.onCellSelection { _, _ in
            var properties = [String: String]()
            properties["prop1"] = "prop1val"
            properties["prop1"] = "prop2val"
            var filters = [VisilabsRecommendationFilter]()
            filters.append(VisilabsRecommendationFilter(attribute:.PRODUCTNAME , filterType: .like, value: "a"))
            
            filters.append(VisilabsRecommendationFilter(attribute:.PRODUCTCODE,
                                                        filterType: .equals,
                                                        value: "000000300079892,000000400206545,000000400210042"))
            
            //filters.append(VisilabsRecommendationFilter(attribute: .PRODUCTNAME, filterType: .like, value: "laptop"))
            
            Visilabs.callAPI().recommend(zoneID: "1", productCode: "",
                                         filters: filters,
                                         properties: properties) { response in
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
        
        <<< ButtonRow {
            $0.title = "Searchrecommendation"
            $0.disabled = false
        }.onCellSelection { _, _ in
            self.searchRecocemmendation()
        }
    }
    
    private func searchRecocemmendation() {
        Visilabs.callAPI().searcRecommendation(keyword: "", searchType: "web") { response in
            print(response)
        }
    }
    
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
    
}
