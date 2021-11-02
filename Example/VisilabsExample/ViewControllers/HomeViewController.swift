//
//  HomeViewController.swift
//  VisilabsIOS
//
//  Created by egemen@visilabs.com on 03/30/2020.
//  Copyright (c) 2020 egemen@visilabs.com. All rights reserved.
//

import VisilabsIOS
import Eureka
import Euromsg

class HomeViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        Visilabs.createAPI()
        goToTabBarController()
    }
 */

    fileprivate func addClearButtonRow() -> ButtonRow {
        return ButtonRow {
            $0.title = "clear"
            $0.disabled = true
        }
    }

    fileprivate func addLabelRow() -> LabelRow {
        return LabelRow {
            $0.title = "not implemented yet"
            $0.disabled = true
        }
    }

    fileprivate func configureEuromessage() {
        Euromsg.configure(appAlias: visilabsProfile.appAlias, enableLog: false)
        Euromsg.registerForPushNotifications()
        Euromsg.askForNotificationPermission()
        Euromsg.setEuroUserId(userKey: visilabsProfile.userKey)
        Euromsg.setEmail(email: visilabsProfile.userEmail, permission: true)
        Euromsg.setPushNotification(permission: true)
    }

    fileprivate func addCreateApiButtonRow() -> ButtonRow {
        return ButtonRow {
            $0.title = "createAPI"
        }.onCellSelection { _, _ in
            let errors = self.form.validate()
            print("Form erros count: \(errors.count), and errors : \(errors)")
            if errors.count > 0 {
                return
            }
            let orgIdRow: TextRow? = self.form.rowBy(tag: "orgId")
            let profileIdRow: TextRow? = self.form.rowBy(tag: "profileId")
            let dataSourceRow: TextRow? = self.form.rowBy(tag: "dataSource")
            let inAppNotificationsEnabledRow: SwitchRow? = self.form.rowBy(tag: "inAppNotificationsEnabled")
            let channelRow: TextRow? = self.form.rowBy(tag: "channel")
            let requestTimeoutInSecondsRow: PickerInputRow<Int>? = self.form.rowBy(tag: "requestTimeoutInSeconds")
            let geofenceEnabledRow: SwitchRow? = self.form.rowBy(tag: "geofenceEnabled")
            let idfaRow: SwitchRow? = self.form.rowBy(tag: "isIDFAEnabled")
            let maxGeofenceCountRow: PickerInputRow<Int>? = self.form.rowBy(tag: "maxGeofenceCount")
            let appAliasRow: TextRow? = self.form.rowBy(tag: "appAlias")
            visilabsProfile.organizationId = orgIdRow!.value!
            visilabsProfile.profileId = profileIdRow!.value!
            visilabsProfile.dataSource = dataSourceRow!.value!
            visilabsProfile.geofenceEnabled = geofenceEnabledRow?.value ?? false
            visilabsProfile.isIDFAEnabled = idfaRow?.value ?? false
            visilabsProfile.channel = channelRow!.value!
            visilabsProfile.requestTimeoutInSeconds = requestTimeoutInSecondsRow!.value!
            visilabsProfile.inAppNotificationsEnabled = inAppNotificationsEnabledRow?.value ?? false
            visilabsProfile.maxGeofenceCount = maxGeofenceCountRow?.value ?? 20
            visilabsProfile.appAlias = appAliasRow?.value ?? "VisilabsIOSExample"
            DataManager.saveVisilabsProfile(visilabsProfile)
            Visilabs.createAPI(organizationId: visilabsProfile.organizationId, profileId: visilabsProfile.profileId,
                               dataSource: visilabsProfile.dataSource,
                               inAppNotificationsEnabled: visilabsProfile.inAppNotificationsEnabled,
                               channel: visilabsProfile.channel,
                               requestTimeoutInSeconds: visilabsProfile.requestTimeoutInSeconds,
                               geofenceEnabled: visilabsProfile.geofenceEnabled,
                               maxGeofenceCount: visilabsProfile.maxGeofenceCount,
                               isIDFAEnabled: visilabsProfile.isIDFAEnabled,
                               loggingEnabled: true)
            Visilabs.callAPI().useInsecureProtocol = false
            self.configureEuromessage()
            self.goToTabBarController()
        }
    }

    fileprivate func addAppAliasTextRow() -> TextRow {
        return TextRow("appAlias") {
            $0.title = "appAlias"
            $0.placeholder = "appAlias"
            $0.value = visilabsProfile.appAlias
        }
    }

    fileprivate func addGeofencePickerInputRow() -> PickerInputRow<Int> {
        return PickerInputRow<Int>("maxGeofenceCount") {
            $0.title = "maxGeofenceCount"
            $0.options = []
            for counter in 0...20 {
                $0.options.append(counter)
            }
            $0.value = visilabsProfile.maxGeofenceCount
        }
    }

    fileprivate func addGeofenceSwitchRow() -> SwitchRow {
        return SwitchRow("geofenceEnabled") {
            $0.title = "geofenceEnabled"
            $0.value = visilabsProfile.geofenceEnabled
        }
    }

    func addIDFASwitchRow() -> SwitchRow {
        return SwitchRow("isIDFAEnabled") {
            $0.title = "isIDFAEnabled"
            $0.value = visilabsProfile.isIDFAEnabled
        }
    }

    fileprivate func addRequestTimeoutPickerInputRow() -> PickerInputRow<Int> {
        return PickerInputRow<Int>("requestTimeoutInSeconds") {
            $0.title = "requestTimeoutInSeconds"
            $0.options = []
            for counter in 10...60 {
                $0.options.append(counter)
            }
            $0.value = visilabsProfile.requestTimeoutInSeconds
        }
    }

    fileprivate func addChannelTextRow() -> TextRow {
        return TextRow("channel") {
            $0.title = "channel"
            $0.placeholder = "channel"
            $0.value = visilabsProfile.channel
        }
    }

    fileprivate func addInAppNotificationSwitchRow() -> SwitchRow {
        return SwitchRow("inAppNotificationsEnabled") {
            $0.title = "inAppNotificationsEnabled"
            $0.value = visilabsProfile.inAppNotificationsEnabled
        }
    }

    fileprivate func addDataSourceTextRow() -> TextRow {
        return TextRow("dataSource") {
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
                    let labelRow = LabelRow {
                        $0.title = validationMsg
                        $0.cell.height = { 30 }
                    }
                    let indexPath = row.indexPath!.row + index + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
            }
        }
    }

    fileprivate func addProfileIdTextRow() -> TextRow {
        return TextRow("profileId") {
            $0.title = "profileId"
            $0.add(rule: RuleRequired(msg: "\($0.tag!) required"))
            $0.placeholder = "profileId"
            $0.value = visilabsProfile.profileId
        }.onRowValidationChanged { cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                for (index, validationMsg) in row.validationErrors.map({ $0.msg }).enumerated() {
                    let labelRow = LabelRow {
                        $0.title = validationMsg
                        $0.cell.height = { 30 }
                    }
                    let indexPath = row.indexPath!.row + index + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
            }
        }
    }

    fileprivate func addOrganizationIdTextRow() -> TextRow {
        return TextRow("orgId") {
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
                    let labelRow = LabelRow {
                        $0.title = validationMsg
                        $0.cell.height = { 30 }
                    }
                    let indexPath = row.indexPath!.row + index + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
            }
        }
    }

    private func initializeForm() {

        LabelRow.defaultCellUpdate = { cell, _ in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right

        }

        form +++

            Section("createAPI")
            <<< addOrganizationIdTextRow()
            <<< addProfileIdTextRow()
            <<< addDataSourceTextRow()
            <<< addInAppNotificationSwitchRow()
            <<< addChannelTextRow()
            <<< addRequestTimeoutPickerInputRow()
            <<< addGeofenceSwitchRow()
            <<< addGeofencePickerInputRow()
            <<< addAppAliasTextRow()
            <<< addIDFASwitchRow()

            +++ Section()
            <<< addCreateApiButtonRow()

            +++ Section("Clear All User Data")
            <<< addLabelRow()
            <<< addClearButtonRow()
        
    }

    func goToTabBarController() {
        if let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "tabbarcontroller") {
           self.view.window?.rootViewController = tabBarVC
        }
    }
}
