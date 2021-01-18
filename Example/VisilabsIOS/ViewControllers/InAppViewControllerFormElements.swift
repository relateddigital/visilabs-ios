//
//  InAppViewControllerFormElements.swift
//  VisilabsIOS_Example
//
//  Created by Said Alır on 13.11.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import VisilabsIOS
import Eureka

/**
        This extension is written to handle form elements functions
 */
extension InAppViewController {

      func addNotificationTypePickerInputRow() -> PickerInputRow<String> {
        return PickerInputRow<String>(VisilabsInAppNotification.PayloadKey.messageType) {
            $0.title = "Type"
            $0.options = notificationTypes
            $0.value = notificationTypes.first
        }.cellUpdate { _, _ in
            self.showHiddenRows()
        }
    }

      func addMessageTitleTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.messageTitle) {
            $0.add(rule: RuleRequired(msg: "\($0.tag!) required"))
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

      func addMessageBodyTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.messageBody) {
            $0.title = "Body"
            $0.placeholder = "Body"
            $0.value = "Test Body"
        }
    }

      func addButtonTextTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.buttonText) {
            $0.title = "Button Text"
            $0.placeholder = "Button Text"
            $0.value = "Test Button Text"
        }
    }

      func addIosLinkUrlRow() -> URLRow {
        return URLRow(VisilabsInAppNotification.PayloadKey.iosLink) {
            $0.title = "IOS Link"
            $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
            $0.placeholder = "IOS Link"
            $0.validationOptions = .validatesOnDemand
            $0.value = URL(string: "https://www.relateddigital.com")
        }
    }

      func addImageUrlUrlRow() -> URLRow {
        return URLRow(VisilabsInAppNotification.PayloadKey.imageUrlString) {
            $0.title = "Image URL"
            $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
            $0.placeholder = "Image URL"
            $0.validationOptions = .validatesOnDemand
            let str = "https://raw.githubusercontent.com/relateddigital/visilabs-ios/master/Screenshots/attention.png"
            $0.value = URL(string: str)
        }
    }

      func addMiniIconPickerInputRow() -> PickerInputRow<String> {
        return PickerInputRow<String>("miniIcon") {
            $0.title = "Mini Icon"
            $0.options = InAppHelper.miniIcons
            $0.value = InAppHelper.miniIcons.first!
        }.cellSetup { cell, _ in
            cell.imageView?.image = InAppHelper.miniIconImages.first!.value
        }.cellUpdate { cell, row in
            cell.imageView?.image = InAppHelper.miniIconImages[row.value!]
        }
    }

      func addMessageTitleColorRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.messageTitleColor) {
            $0.title = "Message Title Color"
            $0.value = "#000000"
            $0.disabled = true
        }.onCellSelection { _, row in
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "modalview")
            guard let modalVC = viewController as? ModalViewController else {
                return
            }
            modalVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            modalVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            if let selectedColor = UIColor(hex: row.value) {
                modalVC.selectedColor = selectedColor
            }
            modalVC.headerText = row.title!
            modalVC.textRow = row
            self.present(modalVC, animated: true, completion: nil)
        }
    }

      func addMessageBodyColorRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.messageBodyColor) {
            $0.title = "Message Body Color"
            $0.value = "#000000"
            $0.disabled = true
        }.onCellSelection { _, row in
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "modalview")
            guard let modalVC = viewController as? ModalViewController else {
                return
            }
            modalVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            modalVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            if let selectedColor = UIColor(hex: row.value) {
                modalVC.selectedColor = selectedColor
            }
            modalVC.headerText = row.title ?? ""
            modalVC.textRow = row
            self.present(modalVC, animated: true, completion: nil)
        }
    }

      func addMessageBodyTextSizePickerInputRow() -> PickerInputRow<Int> {
        return PickerInputRow<Int>(VisilabsInAppNotification.PayloadKey.messageBodyTextSize) {
            $0.title = "Text Size"
            $0.options = []
            for counter in 1...10 {
                $0.options.append(counter)
            }
            $0.value = 2
        }
    }

      func addFontFamilyPickerInputRow() -> PickerInputRow<String> {
        return PickerInputRow<String>(VisilabsInAppNotification.PayloadKey.fontFamily) {
            $0.title = "Font Family"
            $0.options = fonts
            $0.value = "DefaultFont"
        }
    }

      func addBackgroundColorRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.backGround) {
            $0.title = "Background Color"
            $0.value = "#A7A7A7"
            $0.disabled = true
        }.onCellSelection { _, row in
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "modalview")
            guard let modalVC = viewController as? ModalViewController else {
                return
            }
            modalVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            modalVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            if let selectedColor = UIColor(hex: row.value) {
                modalVC.selectedColor = selectedColor
            }
            modalVC.headerText = row.title!
            modalVC.textRow = row
            self.present(modalVC, animated: true, completion: nil)
        }
    }

      func addCloseButtonColorPickerInputRow() -> PickerInputRow<String> {
        return PickerInputRow<String>(VisilabsInAppNotification.PayloadKey.closeButtonColor) {
            $0.title = "Close Button Color"
            $0.options = closeButtonColors
            $0.value = "white"
        }
    }

      func addButtonTextColorTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.buttonTextColor) {
            $0.title = "Button Text Color"
            $0.value = "#FFFFFF"
            $0.disabled = true
        }.onCellSelection { _, row in
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "modalview")
            guard let modalVC = viewController as? ModalViewController else {
                return
            }
            modalVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            modalVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            if let selectedColor = UIColor(hex: row.value) {
                modalVC.selectedColor = selectedColor
            }
            modalVC.headerText = row.title!
            modalVC.textRow = row
            self.present(modalVC, animated: true, completion: nil)
        }
    }

      func addButtonColorTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.buttonColor) {
            $0.title = "Button Color"
            $0.value = "#000000"
            $0.disabled = true
        }.onCellSelection { _, row in
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "modalview")
            guard let modalVC = viewController as? ModalViewController else {
                return
            }
            modalVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            modalVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            if let selectedColor = UIColor(hex: row.value) {
                modalVC.selectedColor = selectedColor
            }
            modalVC.headerText = row.title!
            modalVC.textRow = row
            self.present(modalVC, animated: true, completion: nil)
        }
    }

    func addShowNotificationButtonRow() -> ButtonRow {
        return ButtonRow {
            $0.title = "showNotification"
        }.onCellSelection { _, _ in
            self.showNotificationTapped()
        }
    }
    func addCloseButtonTextTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.closeButtonText) {
            $0.title = "Close Button Text"
            $0.placeholder = "Close"
            $0.value = "Close"
        }
    }
    
    func addAlertTypePickerInputRow() -> PickerInputRow<String> {
        return PickerInputRow<String>(VisilabsInAppNotification.PayloadKey.alertType) {
            $0.title = "Alert Type"
            $0.options = ["NativeAlert", "ActionSheet"]
            $0.value = "NativeAlert"
        }
    }

    func showNotificationTapped() {

        let errors = self.form.validate(includeHidden: false, includeDisabled: false, quietly: false)
        print("Form erros count: \(errors.count)")
        for error in errors {
            print(error.msg)
        }
        if errors.count > 0 {
            return
        }
        let value = "\(((self.form.rowBy(tag: "msg_type") as? PickerInputRow<String>))?.value ?? "")"
        if value == "emailForm" {
            Visilabs.callAPI().customEvent("mail", properties: [String: String]())
        } else {
            let visilabsInAppNotification = createVisilabsInAppNotificationModel()
            Visilabs.callAPI().showNotification(visilabsInAppNotification)
        }
    }
    //swiftlint:disable function_body_length
    func createVisilabsInAppNotificationModel() -> VisilabsInAppNotification {
        var tag = ""
        let rawValue = self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageType) as PickerInputRow<String>?
        let messageType = VisilabsInAppNotificationType.init(rawValue: rawValue!.value! as String)!
        let messageTitle: String = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitle)
                                        as TextRow?)!.value ?? ""
        let messageBody: String = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBody)
                                    as TextRow?)!.value ?? ""
        let buttonText = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonText)
                            as TextRow?)!.value ?? ""
        let iosLink = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.iosLink)
                        as URLRow?)?.value?.absoluteString
        let messageTitleColor = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitleColor)
                                    as TextRow?)!.value!  as String
        let messageBodyColor = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyColor)
                                    as TextRow?)!.value!  as String

        tag = VisilabsInAppNotification.PayloadKey.messageBodyTextSize
        let messageBodyTextSize = "\((self.form.rowBy(tag: tag) as PickerInputRow<Int>?)!.value!)"

        tag = VisilabsInAppNotification.PayloadKey.fontFamily
        let fontFamily: String = ((self.form.rowBy(tag: tag) as? PickerInputRow<String>)?.value ?? "") as String

        tag = VisilabsInAppNotification.PayloadKey.backGround
        let backGround = ((self.form.rowBy(tag: tag) as? TextRow)?.value ?? "") as String

        tag = VisilabsInAppNotification.PayloadKey.closeButtonColor
        let closeButtonColor: String = ((self.form.rowBy(tag: tag) as? PickerInputRow<String>)?.value ?? "") as String

        tag = VisilabsInAppNotification.PayloadKey.buttonTextColor
        let buttonTextColor = (self.form.rowBy(tag: tag) as TextRow?)!.value!  as String

        tag = VisilabsInAppNotification.PayloadKey.buttonColor
        let buttonColor = (self.form.rowBy(tag: tag) as TextRow?)!.value!  as String

        let miniIcon = (self.form.rowBy(tag: "miniIcon") as PickerInputRow<String>?)!.value!  as String

        var imageUrlString: String? = ""
        if messageType == .mini {
            imageUrlString = InAppHelper.miniIconUrlFormat.replacingOccurrences(of: "#", with: miniIcon)
        } else {
            tag = VisilabsInAppNotification.PayloadKey.imageUrlString
            imageUrlString = (self.form.rowBy(tag: tag) as URLRow?)?.value?.absoluteString
        }

        tag = VisilabsInAppNotification.PayloadKey.closeButtonText
        let closeButtonText = (self.form.rowBy(tag: tag) as TextRow?)!.value! as String

        tag = VisilabsInAppNotification.PayloadKey.alertType
        let alertType = ((self.form.rowBy(tag: tag) as? PickerInputRow<String>)?.value ?? "") as String

        return VisilabsInAppNotification(actId: 0,
                                        type: messageType,
                                        messageTitle: messageTitle,
                                        messageBody: messageBody,
                                        buttonText: buttonText,
                                        iosLink: iosLink,
                                        imageUrlString: imageUrlString,
                                        visitorData: nil,
                                        visitData: nil,
                                        queryString: nil,
                                        messageTitleColor: messageTitleColor,
                                        messageBodyColor: messageBodyColor,
                                        messageBodyTextSize: messageBodyTextSize,
                                        fontFamily: fontFamily,
                                        backGround: backGround,
                                        closeButtonColor: closeButtonColor,
                                        buttonTextColor: buttonTextColor,
                                        buttonColor: buttonColor,
                                        alertType: alertType,
                                        closeButtonText: closeButtonText)
    }
}
