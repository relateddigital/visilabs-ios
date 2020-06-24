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
    
    
    private func initializeForm() {
        form +++
        Section("Recommendation".uppercased(with: Locale(identifier: "en_US")))
            
        <<< IntRow("zoneId") {
            $0.title = "Zone ID"
            $0.add(rule: RuleRequired())
            $0.add(rule: RuleGreaterThan(min: 0))
            $0.value = 1
        }
        
        <<< TextRow("productCode") {
            $0.title = "Product Code"
            $0.add(rule: RuleRequired())
            $0.placeholder = "Product Code"
            $0.value = "asd-123"
        }
        
        +++ Section()
            
        <<< LabelRow() {
            $0.title = "not implemented yet"
            $0.disabled = true
        }
            
        <<< ButtonRow() {
            $0.title = "recommend"
            $0.disabled = true
        }
    }

}

