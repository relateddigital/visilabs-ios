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
            } else {
                if let brands = visilabsFavoritesResponse.favorites[.brand] {
                    for brand in brands {
                        print(brand)
                    }
                }
                if let attr1s = visilabsFavoritesResponse.favorites[.attr1] {
                    for attr in attr1s {
                        print(attr)
                    }
                }
                if let categories = visilabsFavoritesResponse.favorites[.category] {
                    for category in categories {
                        print(category)
                    }
                }
            }
        }

    }

    var notificationTypes = [String]()
    let fonts = ["Monospace", "sansserif", "serif", "DefaultFont"]
    let closeButtonColors = ["black", "white"]

    func initializeForm() {

        VisilabsInAppNotificationType.allCases.forEach {
            notificationTypes.append($0.rawValue)
        }

        LabelRow.defaultCellUpdate = { cell, _ in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }

        form +++

        Section("Test In App Notification".uppercased(with: Locale(identifier: "en_US")))

            <<< addNotificationTypePickerInputRow()
            <<< addMessageTitleTextRow()
            <<< addMessageBodyTextRow()
            <<< addButtonTextTextRow()
            <<< addIosLinkUrlRow()
            <<< addImageUrlUrlRow()
            <<< addMiniIconPickerInputRow()
            <<< addMessageTitleColorRow()
            <<< addMessageBodyColorRow()
            <<< addMessageBodyTextSizePickerInputRow()
            <<< addFontFamilyPickerInputRow()
            <<< addBackgroundColorRow()
            <<< addCloseButtonColorPickerInputRow()
            <<< addButtonTextColorTextRow()
            <<< addButtonColorTextRow()

        +++ Section()

            <<< addShowNotificationButtonRow()

        showHiddenRows()
    }

    func showHiddenRows() {
        let tag = VisilabsInAppNotification.PayloadKey.messageType
        let rawValue = (self.form.rowBy(tag: tag) as PickerInputRow<String>?)!.value! as String
        let messageType = VisilabsInAppNotificationType.init(rawValue: rawValue)!
        switch messageType {
        case .mini:
            setFormRowsForMini()
        case .full, .imageTextButton, .smileRating, .nps:
            setFormRowsForDefault()
        case.fullImage:
            setFormRowsForFullImage()
        case.imageButton:
            setFormRowsForImageButton()
        case .emailForm:
            setFormRowsForEmail()
        }
        self.form.allRows.forEach { (row) in
            row.evaluateHidden()
        }
    }

    func setFormRowsForMini() {
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitle)?.hidden = false
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
    }
    /**
            Use for full, image text button, smile rating and nps
     */
    func setFormRowsForDefault() {
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitle)?.hidden = false
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
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonColor)?.hidden = false
        self.form.rowBy(tag: "miniIcon")?.hidden = true
    }

    func setFormRowsForFullImage() {
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitle)?.hidden = true
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
    }

    func setFormRowsForImageButton() {
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitle)?.hidden = true
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
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonColor)?.hidden = false

        self.form.rowBy(tag: "miniIcon")?.hidden = true
    }

    func setFormRowsForEmail() {
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitle)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBody)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonText)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.imageUrlString)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyColor)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitleColor)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyTextSize)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.fontFamily)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.backGround)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonColor)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonTextColor)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonColor)?.hidden = false
        self.form.rowBy(tag: "miniIcon")?.hidden = true
    }
}
