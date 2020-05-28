//
//  InAppViewController.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 22.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import VisilabsIOS
import Eureka

class InAppViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }
    
    var notificationTypes = [String]()
    
    private func initializeForm() {
        
        
        VisilabsInAppNotificationType.allCases.forEach {
            notificationTypes.append($0.rawValue)
        }
        
    
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right

        }

        form +++
            
        Section("Test In App Message")
            <<< PickerInputRow<String>(VisilabsInAppNotification.PayloadKey.messageType){
            $0.title = "Type"
            $0.options = notificationTypes
            $0.value = notificationTypes.first
        }
        
        <<< TextRow(VisilabsInAppNotification.PayloadKey.messageTitle) {
            $0.title = "Title"
            $0.placeholder = "Title"
            $0.value = "Test Title"
        }
        
        <<< TextRow(VisilabsInAppNotification.PayloadKey.messageBody) {
            $0.title = "Body"
            $0.placeholder = "Body"
            $0.value = "Test Body"
        }
        
            <<< TextRow(VisilabsInAppNotification.PayloadKey.buttonText) {
            $0.title = "Button Text"
            $0.placeholder = "Button Text"
            $0.value = "Test Button Text"
        }

        <<< URLRow("ios_lnk") {
            $0.title = "ioslink"
            $0.add(rule: RuleURL())
            $0.placeholder = "ioslink"
            $0.validationOptions = .validatesOnChange
            $0.value = URL(string: "https://www.google.com")
        }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
        }.onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = validationMsg
                            $0.cell.height = { 30 }
                        }
                        let indexPath = row.indexPath!.row + index + 1
                        row.section?.insert(labelRow, at: indexPath)
                    }
                }
        }
    
    }
    

}
