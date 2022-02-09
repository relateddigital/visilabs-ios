//
//  InAppViewController.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 22.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import VisilabsIOS
import Eureka

//swiftlint:disable type_body_length
class InAppViewController: FormViewController {

    
    var carouselItems: [DataItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }

    var notificationTypes = [String]()
    var secondPopupTypes = [String]()
    let fonts = ["Monospace", "sansserif", "serif", "DefaultFont"]
    let closeButtonColors = ["black", "white"]

    func initializeForm() {
        //change when added new inapp type
        for counter in 0..<13 {
            notificationTypes.append(VisilabsInAppNotificationType.allCases[counter].rawValue)
        }

        for type in VisilabsSecondPopupType.allCases {
            secondPopupTypes.append(type.rawValue)
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
            <<< addCopyCodeTextRow()
            <<< addCopyCodeTextColor()
            <<< addCopyCodeBackgroundColor()
            <<< addIosLinkUrlRow()
            <<< addImageUrlUrlRow()
            <<< addDelayPickerInputRow()
            <<< addMiniIconPickerInputRow()
            <<< addMessageTitleColorRow()
            <<< addMessageBodyColorRow()
            <<< addMessageBodyTextSizePickerInputRow()
            <<< addFontFamilyPickerInputRow()
            <<< addBackgroundColorRow()
            <<< addCloseButtonColorPickerInputRow()
            <<< addButtonTextColorTextRow()
            <<< addButtonColorTextRow()
            <<< addAlertTypePickerInputRow()
            <<< addCloseButtonTextTextRow()
            <<< addNumberBGColor("1")
            <<< addNumberBGColor("2")
            <<< addNumberBGColor("3")
            <<< addSecondNotificationPickerInputRow()
            <<< addSecondPopupTitleTextRow()
            <<< addSecondPopupBodyTextRow()
            <<< addSecondMessageBodyTextSizePickerInputRow()
            <<< addSecondButtonTextTextRow()
            <<< addSecondImageUrl1UrlRow()
            <<< addSecondImageUrl2UrlRow()
            <<< addSecondPopupMinTextRow()

        +++ Section()

            <<< addShowNotificationButtonRow()
            <<< addShowCarouselNotificationButtonRow()

        showHiddenRows()
    }

    func showHiddenRows() {
        let tag = VisilabsInAppNotification.PayloadKey.messageType
        let rawValue = (self.form.rowBy(tag: tag) as PickerInputRow<String>?)!.value! as String
        let messageType = VisilabsInAppNotificationType.init(rawValue: rawValue)!
        switch messageType {
        case .mini:
            setFormRowsForMini()
        case .full, .imageTextButton, .inappcarousel:
            setFormRowsForDefault()
        case .nps, .smileRating:
            setFormRowsForPromoCode()
        case .npsWithNumbers:
            setFormRowsForNpsWithNumbers()
        case.fullImage:
            setFormRowsForFullImage()
        case.imageButton:
            setFormRowsForImageButton()
        case .alert:
            setRowsForAlert()
        case .scratchToWin:
            setRowsForScratchToWin()
        case .emailForm:
            setFormRowsForEmail()
        case .secondNps, .feedbackForm, .imageButtonImage:
            setFormRowsForSecondPopup()
        case .spintowin:
            setFormRowsForEmail()
        case .halfScreenImage:
            setFormRowsForEmail()
        case .productStatNotifier:
            break
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
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.alertType)?.hidden = true
        self.form.rowBy(tag: "miniIcon")?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionCode)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionBackgroundColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionTextColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"1")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"2")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"3")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupType)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupTitle)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBody)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString1)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString2)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupMinPoint)?.hidden = true
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
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.alertType)?.hidden = true
        self.form.rowBy(tag: "miniIcon")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionCode)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionBackgroundColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionTextColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"1")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"2")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"3")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupType)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBody)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString1)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString2)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupMinPoint)?.hidden = true
    }

    func setFormRowsForPromoCode() {
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
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.alertType)?.hidden = true
        self.form.rowBy(tag: "miniIcon")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionCode)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionBackgroundColor)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionTextColor)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"1")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"2")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"3")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupType)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBody)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString1)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString2)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupMinPoint)?.hidden = true
    }

    func setFormRowsForSecondPopup() {
        setFormRowsForPromoCode()
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupType)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupTitle)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBody)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupButtonText)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString1)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString2)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupMinPoint)?.hidden = false
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
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.alertType)?.hidden = true
        self.form.rowBy(tag: "miniIcon")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionCode)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionBackgroundColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionTextColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"1")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"2")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"3")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupType)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBody)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString1)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString2)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupMinPoint)?.hidden = true
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
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.alertType)?.hidden = true
        self.form.rowBy(tag: "miniIcon")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionCode)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionBackgroundColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionTextColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"1")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"2")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"3")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupType)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBody)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString1)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString2)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupMinPoint)?.hidden = true
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
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.alertType)?.hidden = true
        self.form.rowBy(tag: "miniIcon")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionCode)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionBackgroundColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionTextColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"1")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"2")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"3")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupType)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBody)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString1)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString2)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupMinPoint)?.hidden = true
    }

    func setRowsForAlert() {
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitle)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBody)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonText)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.imageUrlString)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageTitleColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageBodyTextSize)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.fontFamily)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.backGround)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonTextColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.buttonColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonText)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.alertType)?.hidden = false
        self.form.rowBy(tag: "miniIcon")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionCode)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionBackgroundColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionTextColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"1")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"2")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"3")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupType)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBody)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString1)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString2)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupMinPoint)?.hidden = true
    }

    func setFormRowsForNpsWithNumbers() {
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
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.alertType)?.hidden = true
        self.form.rowBy(tag: "miniIcon")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionCode)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionBackgroundColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionTextColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"1")?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"2")?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"3")?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupType)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBody)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString1)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondImageUrlString2)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.secondPopupMinPoint)?.hidden = true
    }

    func setRowsForScratchToWin() {
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
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.closeButtonText)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.alertType)?.hidden = true
        self.form.rowBy(tag: "miniIcon")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionCode)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionBackgroundColor)?.hidden = false
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionTextColor)?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"1")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"2")?.hidden = true
        self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.numberColors+"3")?.hidden = true
    }
}
