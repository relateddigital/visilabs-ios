//
//  InappReviewModel.swift
//  VisilabsIOS
//
//  Created by Orhun Akmil on 8.03.2024.
//

import Foundation


struct InappReviewModel : TargetingActionViewModel, Codable {
   
    var targetingActionType: TargetingActionType
    var auth: String?
    var actId: Int?
    var type: String?
    var title: String?
    var jsContent: String?
    var jsonContent: String?
    
}
