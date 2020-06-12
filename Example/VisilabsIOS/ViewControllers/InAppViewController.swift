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
    
    
    private func showHideRows(){
        let messageTypeRow: PickerInputRow<String>? = self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageType)
        if let messageType: String = messageTypeRow?.value{
            if let visilabsInAppNotificationType = VisilabsInAppNotificationType.init(rawValue: messageType){
                switch visilabsInAppNotificationType {
                case .mini:
                    return
                default:
                    return
                }
            }
        }
    }
    
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
            
        Section("Test In App Notification")
            
        <<< PickerInputRow<String>(VisilabsInAppNotification.PayloadKey.messageType){
            $0.title = "Type"
            $0.options = notificationTypes
            $0.value = notificationTypes.first
        }.cellUpdate { cell, row in
            self.showHideRows()
        }
        
        <<< TextRow(VisilabsInAppNotification.PayloadKey.messageTitle) {
            $0.add(rule: RuleRequired())
            $0.title = "Title"
            $0.placeholder = "Title"
            $0.value = "Test Title"
            $0.validationOptions = .validatesOnDemand
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

        <<< URLRow(VisilabsInAppNotification.PayloadKey.iosLink) {
            $0.title = "IOS Link"
            $0.add(rule: RuleURL())
            $0.placeholder = "IOS Link"
            $0.validationOptions = .validatesOnDemand
            $0.value = URL(string: "https://www.google.com")
        }
        
        <<< URLRow(VisilabsInAppNotification.PayloadKey.imageUrlString) {
        $0.title = "Image URL"
        $0.add(rule: RuleURL())
        $0.placeholder = "Image URL"
        $0.validationOptions = .validatesOnDemand
        $0.value = URL(string: "https://www.google.com/ex.gif")
        }
         
    
        +++ Section()
        <<< ButtonRow() {
            $0.title = "showNotification"
        }
        .onCellSelection { cell, row in
            
            var errors = self.form.validate()

            /*
            let orgIdRow: TextRow? = self.form.rowBy(tag: "orgId")
            let siteIdRow: TextRow? = self.form.rowBy(tag: "siteId")
            let loggerUrlRow: URLRow? = self.form.rowBy(tag: "loggerUrl")
            let dataSourceRow: TextRow? = self.form.rowBy(tag: "dataSource")
            let realTimeUrlRow: URLRow? = self.form.rowBy(tag: "realTimeUrl")
            let channelRow: TextRow? = self.form.rowBy(tag: "channel")
            let requestTimeoutInSecondsRow: PickerInputRow<Int>? = self.form.rowBy(tag: "requestTimeoutInSeconds")
            let targetUrlRow: URLRow? = self.form.rowBy(tag: "targetUrl")
            let actionUrlRow: URLRow? = self.form.rowBy(tag: "actionUrl")
            let geofenceUrlRow: URLRow? = self.form.rowBy(tag: "geofenceUrl")
            let geofenceEnabledRow: SwitchRow? = self.form.rowBy(tag: "geofenceEnabled")
            let maxGeofenceCountRow: PickerInputRow<Int>? = self.form.rowBy(tag: "maxGeofenceCount")
            let restUrlRow: URLRow? = self.form.rowBy(tag: "restUrl")
            let encryptedDataSourceRow: TextRow? = self.form.rowBy(tag: "encryptedDataSource")
            
            let orgId: String? = orgIdRow?.value
            let siteId: String? = siteIdRow?.value
            let loggerUrl: String? = loggerUrlRow?.value?.absoluteString
            let dataSource: String? = dataSourceRow?.value
            let realTimeUrl: String? = realTimeUrlRow?.value?.absoluteString
            let channel: String? = channelRow?.value
            let requestTimeoutInSeconds: Int? = requestTimeoutInSecondsRow?.value
            let targetUrl: String? = targetUrlRow?.value?.absoluteString
            let actionUrl: String? = actionUrlRow?.value?.absoluteString
            let geofenceUrl: String? = geofenceUrlRow?.value?.absoluteString
            let geofenceEnabled: Bool? = geofenceEnabledRow?.value
            let maxGeofenceCount: Int? = maxGeofenceCountRow?.value
            let restUrl: String? = restUrlRow?.value?.absoluteString
            let encryptedDataSource: String? = encryptedDataSourceRow?.value
            */
            
        }
        
    }
    

}
