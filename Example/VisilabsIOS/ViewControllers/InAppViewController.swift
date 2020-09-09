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
        
        Visilabs.callAPI().getFavoriteAttributeActions(actionId: 1) { (visilabsFavoritesResponse) in
            if visilabsFavoritesResponse.error != nil {
                
                return
            }else{
                if let brands = visilabsFavoritesResponse.favorites[.brand]{
                    for brand in brands{
                        print(brand)
                    }
                }
                if let attr1s = visilabsFavoritesResponse.favorites[.attr1]{
                    for attr in attr1s{
                        print(attr)
                    }
                }
                if let categories = visilabsFavoritesResponse.favorites[.category]{
                    for category in categories{
                        print(category)
                    }
                }
            }
        }
        
    }
    
    var notificationTypes = [String]()
    let fonts = ["Monospace", "sansserif", "serif", "DefaultFont"]
    let closeButtonColors = ["black", "white"]
    
    private func showHideRows(){
        let messageType = VisilabsInAppNotificationType.init(rawValue: (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageType) as PickerInputRow<String>?)!.value! as String)!
        switch messageType {
        case .mini:
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBody)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonText)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.imageUrlString)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyColor)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitleColor)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyTextSize)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.fontFamily)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.backGround)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonColor)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonTextColor)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonColor)?.hidden = true
            self.form.rowBy(tag: "miniIcon")?.hidden = false
            break
        case .full, .image_text_button, .smile_rating, .nps:
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBody)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonText)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.imageUrlString)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyColor)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitleColor)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyTextSize)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.fontFamily)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.backGround)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonColor)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonTextColor)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonColor)?.hidden = true
            self.form.rowBy(tag: "miniIcon")?.hidden = true
            break
        case.full_image:
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBody)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonText)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.imageUrlString)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyColor)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitleColor)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyTextSize)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.fontFamily)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.backGround)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonColor)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonTextColor)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonColor)?.hidden = true
            self.form.rowBy(tag: "miniIcon")?.hidden = true
            break
        case.image_button:
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBody)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonText)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.imageUrlString)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyColor)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitleColor)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyTextSize)?.hidden = true
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.fontFamily)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.backGround)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonColor)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonTextColor)?.hidden = false
            self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonColor)?.hidden = true
            self.form.rowBy(tag: "miniIcon")?.hidden = true
            break
        }
        
        self.form.allRows.forEach { (row) in
            row.evaluateHidden()
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
            
        Section("Test In App Notification".uppercased(with: Locale(identifier: "en_US")))
            
        <<< PickerInputRow<String>(VisilabsInAppNotification.PayloadKey.messageType){
            $0.title = "Type"
            $0.options = notificationTypes
            $0.value = notificationTypes.first
        }.cellUpdate { cell, row in
            self.showHideRows()
        }
        
        <<< TextRow(VisilabsInAppNotification.PayloadKey.messageTitle) {
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
            $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
            $0.placeholder = "IOS Link"
            $0.validationOptions = .validatesOnDemand
            $0.value = URL(string: "https://www.google.com")
        }
        
        <<< URLRow(VisilabsInAppNotification.PayloadKey.imageUrlString) {
            $0.title = "Image URL"
            $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
            $0.placeholder = "Image URL"
            $0.validationOptions = .validatesOnDemand
            $0.value = URL(string: "https://x6k7p6q7.rocketcdn.me/wp-content/uploads/2019/02/Ways-You-Can-Draw-Attention-to-New-Products.png")
        }
            
        <<< PickerInputRow<String>("miniIcon"){
            $0.title = "Mini Icon"
            $0.options = InAppHelper.miniIcons
            $0.value = InAppHelper.miniIcons.first!
        }.cellSetup { cell, row in
            cell.imageView?.image = InAppHelper.miniIconImages.first!.value
        }.cellUpdate { cell, row in
            cell.imageView?.image = InAppHelper.miniIconImages[row.value!]
        }
            
            
         
            
        <<< TextRow(VisilabsInAppNotification.PayloadKey.messageTitleColor) {
            $0.title = "Message Title Color"
            $0.value = "#000000"
            $0.disabled = true
        }.onCellSelection { cell, row in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "modalview") as! ModalViewController
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            if let selectedColor = UIColor(hex: row.value){
                vc.selectedColor = selectedColor
            }
            vc.headerText = row.title!
            vc.textRow = row
            self.present(vc, animated: true, completion: nil)
        }
            
        <<< TextRow(VisilabsInAppNotification.PayloadKey.messageBodyColor) {
            $0.title = "Message Body Color"
            $0.value = "#000000"
            $0.disabled = true
        }.onCellSelection { cell, row in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "modalview") as! ModalViewController
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            if let selectedColor = UIColor(hex: row.value){
                vc.selectedColor = selectedColor
            }
            vc.headerText = row.title!
            vc.textRow = row
            self.present(vc, animated: true, completion: nil)
        }
            
        <<< PickerInputRow<Int>(VisilabsInAppNotification.PayloadKey.messageBodyTextSize){
            $0.title = "Text Size"
            $0.options = []
            for i in 1...10{
                $0.options.append(i)
            }
            $0.value = 2
        }
        
        <<< PickerInputRow<String>(VisilabsInAppNotification.PayloadKey.fontFamily){
            $0.title = "Font Family"
            $0.options = fonts
            $0.value = "DefaultFont"
        }
            
        <<< TextRow(VisilabsInAppNotification.PayloadKey.backGround) {
            $0.title = "Background Color"
            $0.value = "#A7A7A7"
            $0.disabled = true
        }.onCellSelection { cell, row in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "modalview") as! ModalViewController
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            if let selectedColor = UIColor(hex: row.value){
                vc.selectedColor = selectedColor
            }
            vc.headerText = row.title!
            vc.textRow = row
            self.present(vc, animated: true, completion: nil)
        }
            
        <<< PickerInputRow<String>(VisilabsInAppNotification.PayloadKey.closeButtonColor){
            $0.title = "Close Button Color"
            $0.options = closeButtonColors
            $0.value = "white"
        }
        
        <<< TextRow(VisilabsInAppNotification.PayloadKey.buttonTextColor) {
            $0.title = "Button Text Color"
            $0.value = "#FFFFFF"
            $0.disabled = true
        }.onCellSelection { cell, row in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "modalview") as! ModalViewController
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            if let selectedColor = UIColor(hex: row.value){
                vc.selectedColor = selectedColor
            }
            vc.headerText = row.title!
            vc.textRow = row
            self.present(vc, animated: true, completion: nil)
        }
            
        <<< TextRow(VisilabsInAppNotification.PayloadKey.buttonColor) {
            $0.title = "Button Color"
            $0.value = "#000000"
            $0.disabled = true
        }.onCellSelection { cell, row in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "modalview") as! ModalViewController
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            if let selectedColor = UIColor(hex: row.value){
                vc.selectedColor = selectedColor
            }
            vc.headerText = row.title!
            vc.textRow = row
            self.present(vc, animated: true, completion: nil)
        }
            

    
        +++ Section()
            
        <<< ButtonRow() {
            $0.title = "showNotification"
        }
        .onCellSelection { cell, row in
            
            let errors = self.form.validate(includeHidden: false, includeDisabled: false, quietly: false)
            print("Form erros count: \(errors.count)")
            for error in errors {
                print(error.msg)
            }
            if errors.count > 0 {
                return
            }
            
            let messageType = VisilabsInAppNotificationType.init(rawValue: (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageType) as PickerInputRow<String>?)!.value! as String)!
            let messageTitle: String = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitle) as TextRow?)!.value ?? ""
            let messageBody: String = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBody) as TextRow?)!.value ?? ""
            let buttonText = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonText) as TextRow?)!.value ?? ""
            let iosLink = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.iosLink) as URLRow?)?.value?.absoluteString
            let messageTitleColor = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitleColor) as TextRow?)!.value!  as String
            let messageBodyColor = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyColor) as TextRow?)!.value!  as String
            let messageBodyTextSize = "\((self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyTextSize) as PickerInputRow<Int>?)!.value!)"
            let fontFamily: String = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.fontFamily) as! PickerInputRow<String>).value! as String
            let backGround = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.backGround) as TextRow?)!.value!  as String
            let closeButtonColor: String = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonColor) as! PickerInputRow<String>).value! as String
            let buttonTextColor = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonTextColor) as TextRow?)!.value!  as String
            let buttonColor = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonColor) as TextRow?)!.value!  as String
            let miniIcon = (self.form.rowBy(tag: "miniIcon") as PickerInputRow<String>?)!.value!  as String
            var imageUrlString :String? = ""
            
            if messageType == .mini {
                imageUrlString = InAppHelper.miniIconUrlFormat.replacingOccurrences(of: "#", with: miniIcon)
            }else {
                imageUrlString = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.imageUrlString) as URLRow?)?.value?.absoluteString
            }

            let visilabsInAppNotification = VisilabsInAppNotification(actId: 0, type: messageType, messageTitle: messageTitle, messageBody: messageBody, buttonText: buttonText, iosLink: iosLink, imageUrlString: imageUrlString, visitorData: nil, visitData: nil, queryString: nil, messageTitleColor: messageTitleColor, messageBodyColor: messageBodyColor, messageBodyTextSize: messageBodyTextSize, fontFamily: fontFamily, backGround: backGround, closeButtonColor: closeButtonColor, buttonTextColor: buttonTextColor, buttonColor: buttonColor)

            Visilabs.callAPI().showNotification(visilabsInAppNotification)
        }
        showHideRows()
    }
}
