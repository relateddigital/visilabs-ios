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

            <<< TextRow() {
                $0.title = "orgId"
                $0.add(rule: RuleRequired())
                $0.placeholder = "orgId"
                $0.value = visilabsProfile.organizationId
            }

            <<< TextRow() {
                $0.title = "siteId"
                $0.add(rule: RuleRequired())
                $0.placeholder = "siteId"
                $0.value = visilabsProfile.siteId
            }
            
            <<< TextRow() {
                $0.title = "dataSource"
                $0.add(rule: RuleRequired())
                $0.placeholder = "dataSource"
                $0.value = visilabsProfile.dataSource
            }
            
            <<< URLRow() {
                $0.title = "loggerUrl"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleURL())
                $0.placeholder = "loggerUrl"
                $0.validationOptions = .validatesOnChange
                $0.value = URL(string: visilabsProfile.loggerUrl)
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
            
            <<< URLRow() {
                $0.title = "realTimeUrl"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleURL())
                $0.placeholder = "realTimeUrl"
                $0.validationOptions = .validatesOnChange
                $0.value = URL(string: visilabsProfile.realTimeUrl)
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
            
            <<< TextRow() {
                $0.title = "channel"
                $0.placeholder = "channel"
                $0.value = visilabsProfile.channel
            }
            
            <<< PickerInputRow<Int>("requestTimeoutInSeconds"){
                $0.title = "requestTimeoutInSeconds"
                $0.options = []
                for i in 1...60{
                    $0.options.append(i)
                }
                $0.value = visilabsProfile.requestTimeoutInSeconds
            }
            
            <<< URLRow() {
                $0.title = "targetUrl"
                $0.add(rule: RuleURL())
                $0.placeholder = "targetUrl"
                if let turl = visilabsProfile.targetUrl {
                    $0.value = URL(string: turl)
                }
            }
            
            <<< URLRow() {
                $0.title = "actionUrl"
                $0.add(rule: RuleURL())
                $0.placeholder = "actionUrl"
                if let aurl = visilabsProfile.actionUrl {
                    $0.value = URL(string: aurl)
                }
            }
            
            <<< URLRow() {
                $0.title = "geofenceUrl"
                $0.add(rule: RuleURL())
                $0.placeholder = "geofenceUrl"
                if let gurl = visilabsProfile.geofenceUrl {
                    $0.value = URL(string: gurl)
                }
            }
            
            <<< SwitchRow() {
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
            
            <<< URLRow() {
                $0.title = "restUrl"
                $0.add(rule: RuleURL())
                $0.placeholder = "restUrl"
                if let rurl = visilabsProfile.restUrl {
                    $0.value = URL(string: rurl)
                }
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
            
            <<< TextRow() {
                $0.title = "encryptedDataSource"
                $0.placeholder = "encryptedDataSource"
                $0.value = visilabsProfile.encryptedDataSource
            }
        
            +++ Section()
            <<< ButtonRow() {
                $0.title = "createAPI"
            }
            .onCellSelection { cell, row in
                self.goToTabBarController()
                //row.section?.form?.validate()
            }
        
        
            +++ Section("Clear All User Data")
    }
    
    func goToTabBarController() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "tabbarcontroller") {
           self.view.window?.rootViewController = vc
        }
    }

    
}

