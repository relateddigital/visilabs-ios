//
//  FavoriteViewController.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 25.08.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Eureka
import UIKit
import VisilabsIOS

class FavoriteViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }
    
    private func initializeForm() {
        form +++
            Section("Favorite Attribute Actions".uppercased(with: Locale(identifier: "en_US")))
            +++
            ButtonRow {
                $0.title = "getFavoriteAttributeActions"
            }.onCellSelection { _, _ in
                self.getFavoriteAttributeActions()
            }
    }



    private func getFavoriteAttributeActions() {
        RelatedDigital.callAPI().getFavoriteAttributeActions { (response) in
            if let error = response.error {
                print(error)
            } else {
                if let favoriteBrands = response.favorites[.brand] {
                    for brand in favoriteBrands {
                        print(brand)
                    }
                }
                if let favoriteCategories = response.favorites[.category] {
                    for category in favoriteCategories {
                        print(category)
                    }
                }
            }
        }
    }

    private func getFavoriteAttributeActions2() {
        RelatedDigital.callAPI().getFavoriteAttributeActions(actionId: 188) { (response) in
            if let error = response.error {
                print(error)
            } else {
                if let favoriteBrands = response.favorites[.brand] {
                    for brand in favoriteBrands {
                        print(brand)
                    }
                }
                if let favoriteCategories = response.favorites[.category] {
                    for category in favoriteCategories {
                        print(category)
                    }
                }
            }
        }
    }

}
