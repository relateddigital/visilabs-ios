//
//  InAppViewControllerFormElements.swift
//  VisilabsIOS_Example
//
//  Created by Said Alır on 13.11.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import VisilabsIOS
import Eureka
import simd

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
    
    func addSecondNotificationPickerInputRow() -> PickerInputRow<String> {
        return PickerInputRow<String>(VisilabsInAppNotification.PayloadKey.secondPopupType) {
            $0.title = "Second Popup Type"
            $0.options = secondPopupTypes
            $0.value = secondPopupTypes.first
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
    
    func addCopyCodeTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.promotionCode) {
            $0.title = "Promotion Code"
            $0.placeholder = "Promotion Code"
            $0.value = "Promotion Code"
        }
    }
    
    func addCopyCodeBackgroundColor() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.promotionBackgroundColor) {
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
        return TextRow(VisilabsInAppNotification.PayloadKey.promotionTextColor) {
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
    
    func addDelayPickerInputRow() -> PickerInputRow<Int> {
        return PickerInputRow<Int>(VisilabsInAppNotification.PayloadKey.waitingTime) {
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
    
    
    
    
    func addShowCarouselNotificationButtonRow() -> ButtonRow {
        return ButtonRow {
            $0.title = "showCarouselNotification"
        }.onCellSelection { _, _ in
            
            let carouselModel = self.createCarouselVisilabsInAppNotificationModel()
            
            self.carouselItems = [DataItem]()
            
            for carousel in carouselModel!.carouselItems! {
                
                let imageView = UIImageView()
                
                let myFetchImageBlock: FetchImageBlock = { imageCompletion in
                    if let imageUrlString = carousel.imageUrlString,  let url = URL(string: imageUrlString)
                        , let imageData: Data = try? Data(contentsOf: url) {
                        let image = UIImage(data: imageData as Data)
                        imageCompletion(image)
                    } else {
                        imageCompletion(nil)
                    }
                }
                
                let itemViewControllerBlock: ItemViewControllerBlock = { index, itemCount, fetchImageBlock, configuration, isInitialController in
                    
                    return AnimatedViewController(index: index, itemCount: itemCount, fetchImageBlock: myFetchImageBlock, configuration: configuration, isInitialController: isInitialController)
                }
                
                let galleryItem = GalleryItem.custom(fetchImageBlock: myFetchImageBlock, itemViewControllerBlock: itemViewControllerBlock)
                let label = UILabel()
                label.text = UUID.init().uuidString
                label.backgroundColor = .purple
                
                let customView = CustomView(frame: UIScreen.main.bounds, visilabsCarouselItem: carousel)
                customView.image = imageView.image
                
                let dataItem = DataItem(imageView: imageView, customView: customView, galleryItem: galleryItem)
                self.carouselItems.append(dataItem)
            }
            
            
            
            
            let displacedViewIndex = 0
            
            let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
            let headerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: self.carouselItems.count)
            let footerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: self.carouselItems.count)
            
            let galleryViewController = VisilabsCarouselNotificationViewController(startIndex: 0, itemsDataSource: self, itemsDelegate: self, displacedViewsDataSource: self, configuration: self.galleryConfiguration())
            galleryViewController.headerView = headerView
            galleryViewController.footerView = footerView
            
            galleryViewController.launchedCompletion = { print("LAUNCHED") }
            galleryViewController.closedCompletion = { print("CLOSED") }
            galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
            
            galleryViewController.landedPageAtIndexCompletion = { index in
                
                print("LANDED AT INDEX: \(index)")
                
                headerView.count = self.carouselItems.count
                headerView.currentIndex = index
                footerView.count = self.carouselItems.count
                footerView.currentIndex = index
            }
            
            self.presentImageGallery(galleryViewController)
            
            
            //self.showNotificationTapped()
        }
    }
    
    func galleryConfiguration() -> GalleryConfiguration {
        
        return [
            
            GalleryConfigurationItem.closeButtonMode(.builtIn),
            
            GalleryConfigurationItem.pagingMode(.carousel),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
            
            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(false),
            GalleryConfigurationItem.activityViewByLongPress(false),
            
            GalleryConfigurationItem.overlayColor(UIColor(white: 0.035, alpha: 1)),
            GalleryConfigurationItem.overlayColorOpacity(0.5),
            GalleryConfigurationItem.overlayBlurOpacity(0.5),
            GalleryConfigurationItem.overlayBlurStyle(UIBlurEffect.Style.light),
            
            GalleryConfigurationItem.videoControlsColor(.white),
            
            GalleryConfigurationItem.maximumZoomScale(8),
            GalleryConfigurationItem.swipeToDismissThresholdVelocity(500),
            
            GalleryConfigurationItem.doubleTapToZoomDuration(0.15),
            
            GalleryConfigurationItem.blurPresentDuration(0.5),
            GalleryConfigurationItem.blurPresentDelay(0),
            GalleryConfigurationItem.colorPresentDuration(0.25),
            GalleryConfigurationItem.colorPresentDelay(0),
            
            GalleryConfigurationItem.blurDismissDuration(0.1),
            GalleryConfigurationItem.blurDismissDelay(0.4),
            GalleryConfigurationItem.colorDismissDuration(0.45),
            GalleryConfigurationItem.colorDismissDelay(0),
            
            GalleryConfigurationItem.itemFadeDuration(0.3),
            GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.rotationDuration(0.15),
            
            GalleryConfigurationItem.displacementDuration(0.55),
            GalleryConfigurationItem.reverseDisplacementDuration(0.25),
            GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.7)),
            GalleryConfigurationItem.displacementTimingCurve(.linear),
            
            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.displacementInsetMargin(50),
            
            GalleryConfigurationItem.imageDividerWidth(CGFloat(30.0)) //TODO:egemen
        ]
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
    
    func addSecondPopupTitleTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.secondPopupTitle) {
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
            Visilabs.callAPI().customEvent("mail", properties: [String: String]())
        } else if value == "scratchToWin" {
            //            let sctw = createScratchToWinModel()
            //            Visilabs.callAPI().showTargetingAction(sctw)
        } else {
            let visilabsInAppNotification = createVisilabsInAppNotificationModel()
            Visilabs.callAPI().showNotification(visilabsInAppNotification)
        }
    }
    
    func addSecondPopupBodyTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.secondPopupBody) {
            $0.title = "Second Popup Body"
            $0.placeholder = "Second Body"
            $0.value = "Second Body"
        }
    }
    
    func addSecondMessageBodyTextSizePickerInputRow() -> PickerInputRow<Int> {
        return PickerInputRow<Int>(VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize) {
            $0.title = "Second Body Text Size"
            $0.options = []
            for counter in 1...10 {
                $0.options.append(counter)
            }
            $0.value = 2
        }
    }
    
    func addSecondButtonTextTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.secondPopupButtonText) {
            $0.title = "Second Button Text"
            $0.placeholder = "SecondButton Text"
            $0.value = "Second Test Button Text"
        }
    }
    
    func addSecondImageUrl1UrlRow() -> URLRow {
        return URLRow(VisilabsInAppNotification.PayloadKey.secondImageUrlString1) {
            $0.title = "Second Popup Image URL 1"
            $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
            $0.placeholder = "Image URL"
            $0.validationOptions = .validatesOnDemand
            let str = "https://raw.githubusercontent.com/relateddigital/visilabs-ios/master/Screenshots/attention.png"
            $0.value = URL(string: str)
        }
    }
    
    func addSecondImageUrl2UrlRow() -> URLRow {
        return URLRow(VisilabsInAppNotification.PayloadKey.secondImageUrlString2) {
            $0.title = "Second Popup Image URL 2"
            $0.add(rule: RuleURL(msg: "\($0.tag!) is not a valid url"))
            $0.placeholder = "Image URL"
            $0.validationOptions = .validatesOnDemand
            let str = "https://raw.githubusercontent.com/relateddigital/visilabs-ios/master/Screenshots/attention.png"
            $0.value = URL(string: str)
        }
    }
    
    func addSecondPopupMinTextRow() -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.secondPopupMinPoint) {
            $0.title = "Second Popup Survey Min Point"
            $0.placeholder = "2.5"
            $0.value = "2.5"
        }
    }
    
    
    func addNumberBGColor(_ colorId: String) -> TextRow {
        return TextRow(VisilabsInAppNotification.PayloadKey.numberColors + colorId) {
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
    func createVisilabsInAppNotificationModel() -> VisilabsInAppNotification {
        var tag = ""
        var rawValue = (((self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.messageType)
                          as PickerInputRow<String>?)?.value)! as String)
        let messageType = VisilabsInAppNotificationType.init(rawValue: rawValue)!
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
        
        tag = VisilabsInAppNotification.PayloadKey.customFont
        let customFont: String = ((self.form.rowBy(tag: tag) as? PickerInputRow<String>)?.value ?? "") as String
        
        tag = VisilabsInAppNotification.PayloadKey.closePopupActionType
        let closePopupActionType: String = ((self.form.rowBy(tag: tag) as? PickerInputRow<String>)?.value ?? "") as String
        
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
        
        let promotionCode = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionCode)
                             as TextRow?)!.value ?? ""
        
        let promotionTextColor = (self.form.rowBy(tag: VisilabsInAppNotification.PayloadKey.promotionTextColor)
                                  as TextRow?)!.value!  as String
        
        tag = VisilabsInAppNotification.PayloadKey.promotionBackgroundColor
        let promotionBackgroundColor = (self.form.rowBy(tag: tag)
                                        as TextRow?)!.value!  as String
        
        tag = VisilabsInAppNotification.PayloadKey.numberColors
        let numberBgColor1 = (self.form.rowBy(tag: tag+"1") as TextRow?)!.value! as String
        let numberBgColor2 = (self.form.rowBy(tag: tag+"2") as TextRow?)!.value! as String
        let numberBgColor3 = (self.form.rowBy(tag: tag+"3") as TextRow?)!.value! as String
        let numberColors = [numberBgColor1, numberBgColor2, numberBgColor3]
        
        tag = VisilabsInAppNotification.PayloadKey.waitingTime
        let waitingTime = ((self.form.rowBy(tag: tag) as PickerInputRow<Int>?)!.value!)
        
        tag = VisilabsInAppNotification.PayloadKey.secondPopupType
        rawValue = ((self.form.rowBy(tag: tag) as PickerInputRow<String>?)!.value!)
        let secondPopupType = VisilabsSecondPopupType.init(rawValue: rawValue)
        
        tag = VisilabsInAppNotification.PayloadKey.secondPopupTitle
        let secondPopupTitle = (self.form.rowBy(tag: tag) as TextRow?)!.value! as String
        
        tag = VisilabsInAppNotification.PayloadKey.secondPopupBody
        let secondBody = (self.form.rowBy(tag: tag) as TextRow?)!.value! as String
        
        tag = VisilabsInAppNotification.PayloadKey.secondPopupBodyTextSize
        let secondBodyTextSize = "\((self.form.rowBy(tag: tag) as PickerInputRow<Int>?)!.value!)"
        
        tag = VisilabsInAppNotification.PayloadKey.secondPopupButtonText
        let secondPopupButtonText = (self.form.rowBy(tag: tag) as TextRow?)!.value ?? ""
        
        tag = VisilabsInAppNotification.PayloadKey.secondImageUrlString1
        let secondImg1 = (self.form.rowBy(tag: tag) as URLRow?)?.value?.absoluteString
        
        tag = VisilabsInAppNotification.PayloadKey.secondImageUrlString2
        let secondImg2 = (self.form.rowBy(tag: tag) as URLRow?)?.value?.absoluteString
        
        tag = VisilabsInAppNotification.PayloadKey.secondPopupMinPoint
        let minPoint = (self.form.rowBy(tag: tag) as TextRow?)!.value! as String
        
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
    func createCarouselVisilabsInAppNotificationModel() -> VisilabsInAppNotification? {
        
        var carouselItems = [VisilabsCarouselItem]()
        
        let carouselItemsJson = """
[{"image":"https://imgvisilabsnet.azureedge.net/in-app-message/uploaded_images/test/112_885_161_20220204163449231.png","title":"Title","title_color":"#1b1e1f","title_font_family":"sansserif","title_custom_font_family_ios":"","title_custom_font_family_android":"","title_textsize":"4","body":"Text","body_color":"#081c2c","body_font_family":"sansserif","body_custom_font_family_ios":"","body_custom_font_family_android":"","body_textsize":"3","promocode_type":"staticcode","cid":"","promotion_code":"Copy Code","promocode_background_color":"#e7b3b3","promocode_text_color":"#ffffff","button_text":"BUTTON","button_text_color":"#ffffff","button_color":"#000000","button_font_family":"sansserif","button_custom_font_family_ios":"","button_custom_font_family_android":"","button_textsize":"3","background_image":"","background_color":"#ffffff","ios_lnk":"https://www.relateddigital.com/","android_lnk":"https://www.relateddigital.com/"},{"image":"https://imgvisilabsnet.azureedge.net/in-app-message/uploaded_images/test/112_885_161_20220204163546000.jpg","title":"Title","title_color":"#19181a","title_font_family":"sansserif","title_custom_font_family_ios":"","title_custom_font_family_android":"","title_textsize":"3","body":"Text","body_color":"#1e072b","body_font_family":"sansserif","body_custom_font_family_ios":"","body_custom_font_family_android":"","body_textsize":"3","promocode_type":"staticcode","cid":"","promotion_code":"Copy Code","promocode_background_color":"#dc1c1c","promocode_text_color":"#581180","button_text":"Button","button_text_color":"#ffffff","button_color":"#000000","button_font_family":"sansserif","button_custom_font_family_ios":"","button_custom_font_family_android":"","button_textsize":"3","background_image":"","background_color":"#ffffff","ios_lnk":"https://www.relateddigital.com/","android_lnk":"https://www.relateddigital.com/"},{"image":"https://imgvisilabsnet.azureedge.net/in-app-message/uploaded_images/test/112_885_161_20220209142156924.png","title":"Title","title_color":"#242727","title_font_family":"sansserif","title_custom_font_family_ios":"","title_custom_font_family_android":"","title_textsize":"3","body":"","body_color":"","body_font_family":"","body_custom_font_family_ios":"","body_custom_font_family_android":"","body_textsize":"","promocode_type":"","cid":"","promotion_code":"","promocode_background_color":"","promocode_text_color":"","button_text":"Button","button_text_color":"#ffffff","button_color":"#000000","button_font_family":"sansserif","button_custom_font_family_ios":"","button_custom_font_family_android":"","button_textsize":"2","background_image":"","background_color":"#ffffff","ios_lnk":"https://www.relateddigital.com/","android_lnk":"https://www.relateddigital.com/"},{"image":"","title":"Title","title_color":"#000000","title_font_family":"sansserif","title_custom_font_family_ios":"","title_custom_font_family_android":"","title_textsize":"3","body":"Text","body_color":"#000000","body_font_family":"sansserif","body_custom_font_family_ios":"","body_custom_font_family_android":"","body_textsize":"3","promocode_type":"staticcode","cid":"","promotion_code":"Copy Code","promocode_background_color":"#db1b3e","promocode_text_color":"#0e832a","button_text":"Button","button_text_color":"#ffffff","button_color":"#000000","button_font_family":"sansserif","button_custom_font_family_ios":"","button_custom_font_family_android":"","button_textsize":"3","background_image":"","background_color":"#ffffff","ios_lnk":"https://www.relateddigital.com/","android_lnk":"https://www.relateddigital.com/"}]
"""
        
        if let data = carouselItemsJson.data(using: .utf8) {
            if let carouselItemsArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                for carouselItemDic in carouselItemsArray {
                    if let carouselItem = VisilabsCarouselItem(JSONObject: carouselItemDic) {
                        carouselItems.append(carouselItem)
                    }
                }
            }
        }
        
        print("carouselItems count = \(carouselItems.count)")
        
        
        return VisilabsInAppNotification(actId: 0,
                                         type: .inappcarousel,
                                         messageTitle: "messageTitle",
                                         messageBody: "messageBody",
                                         buttonText: "buttonText",
                                         iosLink: "iosLink",
                                         imageUrlString: "imageUrlString",
                                         visitorData: nil,
                                         visitData: nil,
                                         queryString: nil,
                                         messageTitleColor: "messageTitleColor",
                                         messageTitleTextSize: nil,
                                         messageBodyColor: "messageBodyColor",
                                         messageBodyTextSize: "messageBodyTextSize",
                                         fontFamily: "fontFamily",
                                         customFont: "customFont",
                                         closePopupActionType: "closePopupActionType" ,
                                         backGround: "backGround",
                                         closeButtonColor: "closeButtonColor",
                                         buttonTextColor: "buttonTextColor",
                                         buttonColor: "buttonColor",
                                         alertType: "alertType",
                                         closeButtonText: "closeButtonText",
                                         promotionCode: "promotionCode",
                                         promotionTextColor: "promotionTextColor",
                                         promotionBackgroundColor: "promotionBackgroundColor",
                                         numberColors: nil,
                                         waitingTime: 0,
                                         secondPopupType: nil,
                                         secondPopupTitle: nil,
                                         secondPopupBody: nil,
                                         secondPopupBodyTextSize: nil,
                                         secondPopupButtonText: nil,
                                         secondImageUrlString1: nil,
                                         secondImageUrlString2: nil,
                                         secondPopupMinPoint: nil,
                                         position: .bottom,
                                         carouselItems: carouselItems)
        
    }
    
}



extension UIImageView: DisplaceableView {
    
}

extension InAppViewController: GalleryDisplacedViewsDataSource {
    
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return index < carouselItems.count ? carouselItems[index].imageView : nil
        //TODO:egemen
        //return index < carouselItems.count ? carouselItems[index].customView : nil
        
    }
}

extension InAppViewController: GalleryItemsDataSource {
    
    func itemCount() -> Int {
        
        return carouselItems.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        
        return carouselItems[index].galleryItem
    }
}

extension InAppViewController: GalleryItemsDelegate {
    
    func removeGalleryItem(at index: Int) {
        
        print("remove item at \(index)")
        
        let imageView = carouselItems[index].imageView
        imageView.removeFromSuperview()
        carouselItems.remove(at: index)
    }
}


// Some external custom UIImageView we want to show in the gallery
class FLSomeAnimatedImage: UIImageView {
}

// Extend ImageBaseController so we get all the functionality for free
class AnimatedViewController: ItemBaseController<FLSomeAnimatedImage> {
}




/*
 extension UIImageView: DisplaceableView {
 
 }
 */

class CustomView: UIView, DisplaceableView, ItemView {
    
    public var label: UILabel? {
        get {
            return nil
        }
        set {
            
        }
    }
    
    var image: UIImage? = nil
    var imageView: UIImageView!
    var visilabsCarouselItem: VisilabsCarouselItem?
    
    
    init(){
        super.init(frame: CGRect())
    }
    
    init(frame: CGRect, visilabsCarouselItem: VisilabsCarouselItem) {
        self.visilabsCarouselItem = visilabsCarouselItem
        super.init(frame: frame)
        //setupTitle()
        if let imageData = visilabsCarouselItem.image, var image = UIImage(data: imageData, scale: 1) {
            if let imageGif = UIImage.gif(data: imageData) {
                image = imageGif
            }
            setupImageView(image: image)
        }
        //setCloseButton()
        layoutContent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView(image: UIImage) {
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView.clipsToBounds = true
        imageView.image = image
        
        
        addSubview(imageView)
    }
    
    private func layoutContent() {
        self.backgroundColor = .orange
        //self.backgroundColor = visilabsCarouselItem?.backgroundColor
        //titleLabel.leading(to: self, offset: 0, relation: .equal, priority: .required)
        //titleLabel.trailing(to: self, offset: 0, relation: .equal, priority: .required)
        //titleLabel.centerX(to: self,priority: .required)
        //imageView?.topToBottom(of: self, offset: 0)
        //imageView?.leading(to: self, offset: 0, relation: .equal, priority: .required)
        //imageView?.trailing(to: self, offset: 0, relation: .equal, priority: .required)
        
        //closeButton.top(to: self, offset: -5.0)
        //closeButton.trailing(to: self, offset: -10.0)
        
        //self.window?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
        //self.window?.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        self.layoutIfNeeded()
    }
    
    
    
    
    
    
}

/*
 extension UIView: DisplaceableView {
 
 }
 */

struct DataItem {
    
    let imageView: UIImageView
    let customView: CustomView
    let galleryItem: GalleryItem
}





class CounterView: UIView {
    
    var count: Int
    let countLabel = UILabel()
    var currentIndex: Int {
        didSet {
            updateLabel()
        }
    }
    
    init(frame: CGRect, currentIndex: Int, count: Int) {
        
        self.currentIndex = currentIndex
        self.count = count
        
        super.init(frame: frame)
        
        configureLabel()
        updateLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        
        countLabel.textAlignment = .center
        self.addSubview(countLabel)
    }
    
    func updateLabel() {
        
        let stringTemplate = "%d of %d"
        let countString = String(format: stringTemplate, arguments: [currentIndex + 1, count])
        
        countLabel.attributedText = NSAttributedString(string: countString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        countLabel.frame = self.bounds
    }
}
