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

}
