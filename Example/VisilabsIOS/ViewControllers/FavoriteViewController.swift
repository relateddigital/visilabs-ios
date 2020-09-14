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
        
    }
    
    private func getFavoriteAttributeActions(){
        Visilabs.callAPI().getFavoriteAttributeActions { (response) in
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
