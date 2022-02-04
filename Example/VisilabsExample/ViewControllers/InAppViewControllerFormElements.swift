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
        return PickerInputRow<String>(RelatedDigitalInAppNotification.PayloadKey.messageType) {
            $0.title = "Type"
            $0.options = notificationTypes
            $0.value = notificationTypes.first
        }.cellUpdate { _, _ in
            self.showHiddenRows()
        }
    }

    func addSecondNotificationPickerInputRow() -> PickerInputRow<String> {
        return PickerInputRow<String>(RelatedDigitalInAppNotification.PayloadKey.secondPopupType) {
            $0.title = "Second Popup Type"
            $0.options = secondPopupTypes
            $0.value = secondPopupTypes.first
        }
    }

    func addMessageTitleTextRow() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.messageTitle) {
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
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.messageBody) {
            $0.title = "Body"
            $0.placeholder = "Body"
            $0.value = "Test Body"
        }
    }

    func addButtonTextTextRow() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.buttonText) {
            $0.title = "Button Text"
            $0.placeholder = "Button Text"
            $0.value = "Test Button Text"
        }
    }

    func addCopyCodeTextRow() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.promotionCode) {
            $0.title = "Promotion Code"
            $0.placeholder = "Promotion Code"
            $0.value = "Promotion Code"
        }
    }

    func addCopyCodeBackgroundColor() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.promotionBackgroundColor) {
            $0.title = "Promotion Code Background Color"
            $0.value = "#ffffff"
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

    func addCopyCodeTextColor() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.promotionTextColor) {
            $0.title = "Promotion Code Text Color"
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

    func addIosLinkUrlRow() -> URLRow {
        return URLRow(RelatedDigitalInAppNotification.PayloadKey.iosLink) {
            $0.title = "IOS Link"
            $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
            $0.placeholder = "IOS Link"
            $0.validationOptions = .validatesOnDemand
            $0.value = URL(string: "https://www.relateddigital.com")
        }
    }

    func addImageUrlUrlRow() -> URLRow {
        return URLRow(RelatedDigitalInAppNotification.PayloadKey.imageUrlString) {
            $0.title = "Image URL"
            $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
            $0.placeholder = "Image URL"
            $0.validationOptions = .validatesOnDemand
            let str = "https://raw.githubusercontent.com/relateddigital/visilabs-ios/master/Screenshots/attention.png"
            $0.value = URL(string: str)
        }
    }

    func addDelayPickerInputRow() -> PickerInputRow<Int> {
        return PickerInputRow<Int>(RelatedDigitalInAppNotification.PayloadKey.waitingTime) {
            $0.title = "Waiting Time"
            $0.options = []
            for counter in 0...60 {
                $0.options.append(counter)
            }
            $0.value = 0
        }
    }

    func addMiniIconPickerInputRow() -> PickerInputRow<String> {
        return PickerInputRow<String>("miniIcon") {
            $0.title = "Mini Icon"
            $0.options = InAppHelper.miniIcons
            $0.value = InAppHelper.miniIcons.first!
        }.cellSetup { cell, _ in
            cell.imageView?.image = InAppHelper.miniIconImages.first?.value
        }.cellUpdate { cell, row in
            cell.imageView?.image = InAppHelper.miniIconImages[row.value!]
        }
    }

    func addMessageTitleColorRow() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.messageTitleColor) {
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
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.messageBodyColor) {
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
        return PickerInputRow<Int>(RelatedDigitalInAppNotification.PayloadKey.messageBodyTextSize) {
            $0.title = "Text Size"
            $0.options = []
            for counter in 1...10 {
                $0.options.append(counter)
            }
            $0.value = 2
        }
    }

    func addFontFamilyPickerInputRow() -> PickerInputRow<String> {
        return PickerInputRow<String>(RelatedDigitalInAppNotification.PayloadKey.fontFamily) {
            $0.title = "Font Family"
            $0.options = fonts
            $0.value = "DefaultFont"
        }
    }

    func addBackgroundColorRow() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.backGround) {
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
        return PickerInputRow<String>(RelatedDigitalInAppNotification.PayloadKey.closeButtonColor) {
            $0.title = "Close Button Color"
            $0.options = closeButtonColors
            $0.value = "white"
        }
    }

    func addButtonTextColorTextRow() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.buttonTextColor) {
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
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.buttonColor) {
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
    
    
    
    func addShowCountDownTimerButtonRow() -> ButtonRow {
        return ButtonRow {
            $0.title = "showCountDownTimer"
        }.onCellSelection { _, _ in
            let model = CountdownModel(title: "Fırsatı kaçırma",
                                       subtitle: "bla bla bla bla",
                                       buttonText: "Button'a bas",
                                       coupon: nil,
                                       finalDate: 1625097600,
                                       bgColor: .blue,
                                       titleColor: .white,
                                       subtitleColor: .gray,
                                       buttonColor: .red,
                                       buttonTextColor: .white,
                                       couponColor: nil,
                                       couponBgColor: nil,
                                       titleFont: .boldSystemFont(ofSize: 18),
                                       subtitleFont: .italicSystemFont(ofSize: 15),
                                       buttonFont: .systemFont(ofSize: 14),
                                       couponFont: nil,
                                       location: .bottom,
                                       timerType: .DHMS,
                                       closeButtonColor: .white)
            let vc = CountdownTimerViewController(model: model)
            vc.showNow(animated: true)
        }
    }
    
    
    /*
    func addShowSocialPoofButtonRow() -> ButtonRow {
        return ButtonRow {
            $0.title = "showSocialPoof"
        }.onCellSelection { _, _ in
            let model = VisilabsProductStatNotifierViewModel(text: "soctext", number: "5", location: .bottom, duration: .sec10, backgroundColor: .yellow
                                         , textColor: .brown, numberColor: .green, textFont: .boldSystemFont(ofSize: 18)
                                         , numberFont: .italicSystemFont(ofSize: 15), closeButtonColor: .white)
            let vc = SocialProofViewController(model: model)
            vc.showNow(animated: true)
        }
    }
     */
    
    func addShowHalfScreenButtonRow() -> ButtonRow {
        return ButtonRow {
            $0.title = "showHalfScreen"
        }.onCellSelection { _, _ in
            let model = HalfScreenModel(text: "tttt", location: .bottom, duration: 10, backgroundColor: .green, textColor: .brown, textFont: .boldSystemFont(ofSize: 18),  closeButtonColor: .white)
            let vc = HalfScreenViewController(model: model)
            vc.showNow(animated: true)
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
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.closeButtonText) {
            $0.title = "Close Button Text"
            $0.placeholder = "Close"
            $0.value = "Close"
        }
    }

    func addAlertTypePickerInputRow() -> PickerInputRow<String> {
        return PickerInputRow<String>(RelatedDigitalInAppNotification.PayloadKey.alertType) {
            $0.title = "Alert Type"
            $0.options = ["NativeAlert", "ActionSheet"]
            $0.value = "NativeAlert"
        }
    }
    
    func addSecondPopupTitleTextRow() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.secondPopupTitle) {
            $0.title = "Second Popup Title"
            $0.placeholder = "Second Title"
            $0.value = "Second Title"
        }
    }

    func showNotificationTapped() {
        //dummyFunc()
        //return

//        let vc = ShakeToWinViewController()
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)

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
            RelatedDigital.callAPI().customEvent("mail", properties: [String: String]())
        } else if value == "scratchToWin" {
//            let sctw = createScratchToWinModel()
//            Visilabs.callAPI().showTargetingAction(sctw)
        } else {
            let visilabsInAppNotification = createVisilabsInAppNotificationModel()
            RelatedDigital.callAPI().showNotification(visilabsInAppNotification)
        }
    }

    func addSecondPopupBodyTextRow() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.secondPopupBody) {
            $0.title = "Second Popup Body"
            $0.placeholder = "Second Body"
            $0.value = "Second Body"
        }
    }

    func addSecondMessageBodyTextSizePickerInputRow() -> PickerInputRow<Int> {
        return PickerInputRow<Int>(RelatedDigitalInAppNotification.PayloadKey.secondPopupBodyTextSize) {
            $0.title = "Second Body Text Size"
            $0.options = []
            for counter in 1...10 {
                $0.options.append(counter)
            }
            $0.value = 2
        }
    }

    func addSecondButtonTextTextRow() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.secondPopupButtonText) {
            $0.title = "Second Button Text"
            $0.placeholder = "SecondButton Text"
            $0.value = "Second Test Button Text"
        }
    }
    
    func addSecondImageUrl1UrlRow() -> URLRow {
        return URLRow(RelatedDigitalInAppNotification.PayloadKey.secondImageUrlString1) {
            $0.title = "Second Popup Image URL 1"
            $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
            $0.placeholder = "Image URL"
            $0.validationOptions = .validatesOnDemand
            let str = "https://raw.githubusercontent.com/relateddigital/visilabs-ios/master/Screenshots/attention.png"
            $0.value = URL(string: str)
        }
    }

    func addSecondImageUrl2UrlRow() -> URLRow {
        return URLRow(RelatedDigitalInAppNotification.PayloadKey.secondImageUrlString2) {
            $0.title = "Second Popup Image URL 2"
            $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
            $0.placeholder = "Image URL"
            $0.validationOptions = .validatesOnDemand
            let str = "https://raw.githubusercontent.com/relateddigital/visilabs-ios/master/Screenshots/attention.png"
            $0.value = URL(string: str)
        }
    }

    func addSecondPopupMinTextRow() -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.secondPopupMinPoint) {
            $0.title = "Second Popup Survey Min Point"
            $0.placeholder = "2.5"
            $0.value = "2.5"
        }
    }


    func addNumberBGColor(_ colorId: String) -> TextRow {
        return TextRow(RelatedDigitalInAppNotification.PayloadKey.numberColors + colorId) {
            $0.title = "Number Background Color" + colorId
            $0.value = ""
            $0.placeholder = "#000000"
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
    //swiftlint:disable function_body_length
    func createVisilabsInAppNotificationModel() -> RelatedDigitalInAppNotification {
        var tag = ""
        var rawValue = (((self.form.rowBy(tag: RelatedDigitalInAppNotification.PayloadKey.messageType)
                            as PickerInputRow<String>?)?.value)! as String)
        let messageType = RelatedDigitalInAppNotificationType.init(rawValue: rawValue)!
        let messageTitle: String = (self.form.rowBy(tag: RelatedDigitalInAppNotification.PayloadKey.messageTitle)
                                        as TextRow?)!.value ?? ""
        let messageBody: String = (self.form.rowBy(tag: RelatedDigitalInAppNotification.PayloadKey.messageBody)
                                    as TextRow?)!.value ?? ""
        let buttonText = (self.form.rowBy(tag: RelatedDigitalInAppNotification.PayloadKey.buttonText)
                            as TextRow?)!.value ?? ""
        let iosLink = (self.form.rowBy(tag: RelatedDigitalInAppNotification.PayloadKey.iosLink)
                        as URLRow?)?.value?.absoluteString
        let messageTitleColor = (self.form.rowBy(tag: RelatedDigitalInAppNotification.PayloadKey.messageTitleColor)
                                    as TextRow?)!.value!  as String
        let messageBodyColor = (self.form.rowBy(tag: RelatedDigitalInAppNotification.PayloadKey.messageBodyColor)
                                    as TextRow?)!.value!  as String

        tag = RelatedDigitalInAppNotification.PayloadKey.messageBodyTextSize
        let messageBodyTextSize = "\((self.form.rowBy(tag: tag) as PickerInputRow<Int>?)!.value!)"

        tag = RelatedDigitalInAppNotification.PayloadKey.fontFamily
        let fontFamily: String = ((self.form.rowBy(tag: tag) as? PickerInputRow<String>)?.value ?? "") as String
        
        tag = RelatedDigitalInAppNotification.PayloadKey.customFont
        let customFont: String = ((self.form.rowBy(tag: tag) as? PickerInputRow<String>)?.value ?? "") as String
        
        tag = RelatedDigitalInAppNotification.PayloadKey.closePopupActionType
        let closePopupActionType: String = ((self.form.rowBy(tag: tag) as? PickerInputRow<String>)?.value ?? "") as String

        tag = RelatedDigitalInAppNotification.PayloadKey.backGround
        let backGround = ((self.form.rowBy(tag: tag) as? TextRow)?.value ?? "") as String

        tag = RelatedDigitalInAppNotification.PayloadKey.closeButtonColor
        let closeButtonColor: String = ((self.form.rowBy(tag: tag) as? PickerInputRow<String>)?.value ?? "") as String

        tag = RelatedDigitalInAppNotification.PayloadKey.buttonTextColor
        let buttonTextColor = (self.form.rowBy(tag: tag) as TextRow?)!.value!  as String

        tag = RelatedDigitalInAppNotification.PayloadKey.buttonColor
        let buttonColor = (self.form.rowBy(tag: tag) as TextRow?)!.value!  as String

        let miniIcon = (self.form.rowBy(tag: "miniIcon") as PickerInputRow<String>?)!.value!  as String

        var imageUrlString: String? = ""
        if messageType == .mini {
            imageUrlString = InAppHelper.miniIconUrlFormat.replacingOccurrences(of: "#", with: miniIcon)
        } else {
            tag = RelatedDigitalInAppNotification.PayloadKey.imageUrlString
            imageUrlString = (self.form.rowBy(tag: tag) as URLRow?)?.value?.absoluteString
        }

        tag = RelatedDigitalInAppNotification.PayloadKey.closeButtonText
        let closeButtonText = (self.form.rowBy(tag: tag) as TextRow?)!.value! as String

        tag = RelatedDigitalInAppNotification.PayloadKey.alertType
        let alertType = ((self.form.rowBy(tag: tag) as? PickerInputRow<String>)?.value ?? "") as String

        let promotionCode = (self.form.rowBy(tag: RelatedDigitalInAppNotification.PayloadKey.promotionCode)
                                as TextRow?)!.value ?? ""

        let promotionTextColor = (self.form.rowBy(tag: RelatedDigitalInAppNotification.PayloadKey.promotionTextColor)
                                    as TextRow?)!.value!  as String

        tag = RelatedDigitalInAppNotification.PayloadKey.promotionBackgroundColor
        let promotionBackgroundColor = (self.form.rowBy(tag: tag)
                                            as TextRow?)!.value!  as String

        tag = RelatedDigitalInAppNotification.PayloadKey.numberColors
        let numberBgColor1 = (self.form.rowBy(tag: tag+"1") as TextRow?)!.value! as String
        let numberBgColor2 = (self.form.rowBy(tag: tag+"2") as TextRow?)!.value! as String
        let numberBgColor3 = (self.form.rowBy(tag: tag+"3") as TextRow?)!.value! as String
        let numberColors = [numberBgColor1, numberBgColor2, numberBgColor3]

        tag = RelatedDigitalInAppNotification.PayloadKey.waitingTime
        let waitingTime = ((self.form.rowBy(tag: tag) as PickerInputRow<Int>?)!.value!)

        tag = RelatedDigitalInAppNotification.PayloadKey.secondPopupType
        rawValue = ((self.form.rowBy(tag: tag) as PickerInputRow<String>?)!.value!)
        let secondPopupType = VisilabsSecondPopupType.init(rawValue: rawValue)

        tag = RelatedDigitalInAppNotification.PayloadKey.secondPopupTitle
        let secondPopupTitle = (self.form.rowBy(tag: tag) as TextRow?)!.value! as String

        tag = RelatedDigitalInAppNotification.PayloadKey.secondPopupBody
        let secondBody = (self.form.rowBy(tag: tag) as TextRow?)!.value! as String

        tag = RelatedDigitalInAppNotification.PayloadKey.secondPopupBodyTextSize
        let secondBodyTextSize = "\((self.form.rowBy(tag: tag) as PickerInputRow<Int>?)!.value!)"

        tag = RelatedDigitalInAppNotification.PayloadKey.secondPopupButtonText
        let secondPopupButtonText = (self.form.rowBy(tag: tag) as TextRow?)!.value ?? ""

        tag = RelatedDigitalInAppNotification.PayloadKey.secondImageUrlString1
        let secondImg1 = (self.form.rowBy(tag: tag) as URLRow?)?.value?.absoluteString

        tag = RelatedDigitalInAppNotification.PayloadKey.secondImageUrlString2
        let secondImg2 = (self.form.rowBy(tag: tag) as URLRow?)?.value?.absoluteString

        tag = RelatedDigitalInAppNotification.PayloadKey.secondPopupMinPoint
        let minPoint = (self.form.rowBy(tag: tag) as TextRow?)!.value! as String

        return RelatedDigitalInAppNotification(actId: 0,
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
                                         messageTitleTextSize: nil,
                                         messageBodyColor: messageBodyColor,
                                         messageBodyTextSize: messageBodyTextSize,
                                         fontFamily: fontFamily,
                                         customFont: customFont,
                                         closePopupActionType: closePopupActionType ,
                                         backGround: backGround,
                                         closeButtonColor: closeButtonColor,
                                         buttonTextColor: buttonTextColor,
                                         buttonColor: buttonColor,
                                         alertType: alertType,
                                         closeButtonText: closeButtonText,
                                         promotionCode: promotionCode,
                                         promotionTextColor: promotionTextColor,
                                         promotionBackgroundColor: promotionBackgroundColor,
                                         numberColors: numberColors,
                                         waitingTime: waitingTime,
                                         secondPopupType: secondPopupType,
                                         secondPopupTitle: secondPopupTitle,
                                         secondPopupBody: secondBody,
                                         secondPopupBodyTextSize: secondBodyTextSize,
                                         secondPopupButtonText: secondPopupButtonText,
                                         secondImageUrlString1: secondImg1,
                                         secondImageUrlString2: secondImg2,
                                         secondPopupMinPoint: minPoint,
                                         position: .bottom)
    }

    //swiftlint:disable function_body_length
    func createScratchToWinModel() -> ScratchToWinModel? {
        
        return nil
    }

}
