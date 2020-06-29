//
//  HomeViewController.swift
//  VisilabsIOS
//
//  Created by egemen@visilabs.com on 03/30/2020.
//  Copyright (c) 2020 egemen@visilabs.com. All rights reserved.
//

import VisilabsIOS
import Eureka


class HomeViewController: FormViewController {

    var visilabsProfile = VisilabsProfile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }
    
    private func initializeForm() {
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right

        }

        form +++
            
            Section("createAPI")

            <<< TextRow("orgId") {
                $0.title = "orgId"
                $0.add(rule: RuleRequired(msg: "\($0.tag!) required"))
                $0.placeholder = "orgId"
                $0.value = visilabsProfile.organizationId
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

            <<< TextRow("siteId") {
                $0.title = "siteId"
                $0.add(rule: RuleRequired(msg: "\($0.tag!) required"))
                $0.placeholder = "siteId"
                $0.value = visilabsProfile.siteId
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
            
            <<< TextRow("dataSource") {
                $0.title = "dataSource"
                $0.add(rule: RuleRequired(msg: "\($0.tag!) required"))
                $0.placeholder = "dataSource"
                $0.value = visilabsProfile.dataSource
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
            
            <<< URLRow("loggerUrl") {
                $0.title = "loggerUrl"
                $0.add(rule: RuleRequired(msg: "\($0.tag!) required"))
                $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
                $0.placeholder = "loggerUrl"
                $0.validationOptions = .validatesOnChange
                $0.value = URL(string: visilabsProfile.loggerUrl)
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
            
            <<< URLRow("realTimeUrl") {
                $0.title = "realTimeUrl"
                $0.add(rule: RuleRequired(msg: "\($0.tag!) required"))
                $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
                $0.placeholder = "realTimeUrl"
                $0.validationOptions = .validatesOnChange
                $0.value = URL(string: visilabsProfile.realTimeUrl)
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
            
            <<< TextRow("channel") {
                $0.title = "channel"
                $0.placeholder = "channel"
                $0.value = visilabsProfile.channel
            }
            
            <<< PickerInputRow<Int>("requestTimeoutInSeconds"){
                $0.title = "requestTimeoutInSeconds"
                $0.options = []
                for i in 10...60{
                    $0.options.append(i)
                }
                $0.value = visilabsProfile.requestTimeoutInSeconds
            }
            
            <<< URLRow("targetUrl") {
                $0.title = "targetUrl"
                $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
                $0.placeholder = "targetUrl"
                if let turl = visilabsProfile.targetUrl {
                    $0.value = URL(string: turl)
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
            
            <<< URLRow("actionUrl") {
                $0.title = "actionUrl"
                $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
                $0.placeholder = "actionUrl"
                if let aurl = visilabsProfile.actionUrl {
                    $0.value = URL(string: aurl)
                }
            }
            
            <<< URLRow("geofenceUrl") {
                $0.title = "geofenceUrl"
                $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
                $0.placeholder = "geofenceUrl"
                if let gurl = visilabsProfile.geofenceUrl {
                    $0.value = URL(string: gurl)
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
            
            <<< SwitchRow("geofenceEnabled") {
                $0.title = "geofenceEnabled"
                $0.value = visilabsProfile.geofenceEnabled
            }
                
            <<< PickerInputRow<Int>("maxGeofenceCount"){
                $0.title = "maxGeofenceCount"
                $0.options = []
                for i in 0...20{
                    $0.options.append(i)
                }
                $0.value = visilabsProfile.maxGeofenceCount
            }
            
            <<< URLRow("restUrl") {
                $0.title = "restUrl"
                $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
                $0.placeholder = "restUrl"
                if let rurl = visilabsProfile.restUrl {
                    $0.value = URL(string: rurl)
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
            
            <<< TextRow("encryptedDataSource") {
                $0.title = "encryptedDataSource"
                $0.placeholder = "encryptedDataSource"
                $0.value = visilabsProfile.encryptedDataSource
            }
        
            +++ Section()
            <<< ButtonRow() {
                $0.title = "createAPI"
            }
            .onCellSelection { cell, row in
                
                
                let errors = self.form.validate()
                print("Form erros count: \(errors.count)")
                for error in errors {
                    print(error.msg)
                }
                if errors.count > 0 {
                    return
                }
                
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
                let geofenceEnabled: Bool = geofenceEnabledRow?.value ?? false
                let maxGeofenceCount: Int = maxGeofenceCountRow?.value ?? 20
                let restUrl: String? = restUrlRow?.value?.absoluteString
                let encryptedDataSource: String? = encryptedDataSourceRow?.value
                Visilabs.createAPI(organizationId: orgId!, siteId: siteId!, loggerUrl: loggerUrl!, dataSource: dataSource!, realTimeUrl: realTimeUrl!, channel: channel ?? "IOS", requestTimeoutInSeconds: requestTimeoutInSeconds!, targetUrl: targetUrl, actionUrl: actionUrl, geofenceUrl: geofenceUrl, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount, restUrl: restUrl, encryptedDataSource: encryptedDataSource)
                Visilabs.callAPI().loggingEnabled = true
                
                
                self.goToTabBarController()
                //row.section?.form?.validate()
            }
        
            +++ Section("Clear All User Data")
            <<< LabelRow() {
                $0.title = "not implemented yet"
                $0.disabled = true
            }
            <<< ButtonRow() {
                $0.title = "clear"
                $0.disabled = true
            }
            .onCellSelection { cell, row in }
    }
    
    func checkInputValues(){
        
    }
    
    func goToTabBarController() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "tabbarcontroller") {
           self.view.window?.rootViewController = vc
        }
    }
}
