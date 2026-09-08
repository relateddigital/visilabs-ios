//
//  visilabsSideBarViewControllerModel.swift
//  VisilabsIOS
//
//  Created by Orhun Akmil on 31.03.2022.
//

import Foundation
import UIKit

class RDDrawerViewControllerModel {

    func mapServiceModelToNeededModel(serviceModel: DrawerServiceModel?) -> DrawerViewModel {

        var drawerModel = DrawerViewModel()

        drawerModel.actId = serviceModel?.actId
        drawerModel.title = serviceModel?.title
        
        drawerModel.staticcode = serviceModel?.staticcode

        if serviceModel?.shape?.lowercased() == "circle" {
            drawerModel.isCircle = true
        } else if serviceModel?.shape?.lowercased() == "roundedcorners" {
            drawerModel.isCircle = false
        } else {
            drawerModel.isCircle = false
            drawerModel.cornerRadius = 0.0
        }

        if serviceModel?.pos?.lowercased().contains("top") == true {
            drawerModel.screenYcoordinate = .top
        } else if serviceModel?.pos?.lowercased().contains("bottom") == true {
            drawerModel.screenYcoordinate = .bottom
        } else {
            drawerModel.screenYcoordinate = .middle
        }

        if serviceModel?.pos?.lowercased().contains("right") == true {
            drawerModel.screenXcoordinate = .right
        } else {
            drawerModel.screenXcoordinate = .left
        }

        drawerModel.waitTime = serviceModel?.waitingTime
        drawerModel.linkToGo = serviceModel?.iosLnk

        drawerModel.items = mapItems(serviceModel: serviceModel)

        // The flat properties describe the first item and are kept so that the
        // one-time layout configuration keeps working for both single and multi item setups.
        if let firstItem = drawerModel.items.first {
            drawerModel.miniDrawerContentImage = firstItem.miniDrawerContentImage
            drawerModel.titleString = firstItem.titleString
            drawerModel.drawerContentImage = firstItem.drawerContentImage
            drawerModel.miniDrawerTextFont = firstItem.miniDrawerTextFont
            drawerModel.miniDrawerTextColor = firstItem.miniDrawerTextColor
            drawerModel.labelType = firstItem.labelType
            drawerModel.miniDrawerBackgroundImage = firstItem.miniDrawerBackgroundImage
            drawerModel.miniDrawerBackgroundColor = firstItem.miniDrawerBackgroundColor
            drawerModel.arrowColor = firstItem.arrowColor
            drawerModel.drawerBackgroundImage = firstItem.drawerBackgroundImage
            drawerModel.drawerBackgroundColor = firstItem.drawerBackgroundColor
        }

        return drawerModel
    }

    /// Builds the item list from `content_minimized_items`. When the panel sends no item
    /// array the legacy single item fields are used to synthesize one item.
    private func mapItems(serviceModel: DrawerServiceModel?) -> [DrawerItemViewModel] {
        guard let serviceModel = serviceModel else { return [DrawerItemViewModel()] }

        let itemServiceModels: [DrawerItemServiceModel]
        if serviceModel.items.isEmpty {
            itemServiceModels = [DrawerItemServiceModel(legacy: serviceModel)]
        } else {
            itemServiceModels = serviceModel.items
        }

        return itemServiceModels.map { mapItem($0, fallback: serviceModel) }
    }

    private func mapItem(_ item: DrawerItemServiceModel, fallback serviceModel: DrawerServiceModel) -> DrawerItemViewModel {
        var itemModel = DrawerItemViewModel()

        // Older payloads only carry one link and promo code on the action data, so an item
        // without its own values keeps using those.
        let itemLink = item.iosLnk ?? ""
        itemModel.linkToGo = itemLink.isEmpty ? (serviceModel.iosLnk ?? "") : itemLink
        let itemStaticcode = item.staticcode ?? ""
        itemModel.staticcode = itemStaticcode.isEmpty ? (serviceModel.staticcode ?? "") : itemStaticcode

        itemModel.miniDrawerContentImage = item.contentMinimizedImage ?? ""
        itemModel.titleString = item.contentMinimizedText ?? ""
        itemModel.drawerContentImage = item.contentMaximizedImage ?? ""

        itemModel.miniDrawerTextFont = VisilabsHelper.getFont(fontFamily: item.contentMinimizedFontFamily, fontSize: item.contentMinimizedTextSize, style: .title2, customFont: item.contentMinimizedCustomFontFamilyIos)
        itemModel.miniDrawerTextColor = UIColor(hex: item.contentMinimizedTextColor)

        if item.contentMinimizedTextOrientation?.lowercased() == "toptobottom" {
            itemModel.labelType = .upToDown
        } else {
            itemModel.labelType = .downToUp
        }

        itemModel.miniDrawerBackgroundImage = item.contentMinimizedBackgroundImage ?? ""
        itemModel.miniDrawerBackgroundColor = UIColor(hex: item.contentMinimizedBackgroundColor)

        if !itemModel.miniDrawerContentImage.isEmpty { //contentImage remove
            itemModel.miniDrawerBackgroundImage = item.contentMinimizedImage ?? ""
        }

        if item.contentMinimizedArrowColor?.isEmpty ?? true {
            itemModel.arrowColor = .clear
        } else {
            itemModel.arrowColor = UIColor(hex: item.contentMinimizedArrowColor)
        }

        itemModel.drawerBackgroundImage = item.contentMaximizedBackgroundImage ?? ""
        itemModel.drawerBackgroundColor = UIColor(hex: item.contentMaximizedBackgroundColor)

        return itemModel
    }
}

struct DrawerServiceModel: TargetingActionViewModel {

    var targetingActionType: TargetingActionType
    var actId: Int?
    var title: String?

    // actionData
    var shape: String?
    var pos: String?
    var contentMinimizedImage: String?
    var contentMinimizedText: String?
    var contentMaximizedImage: String?
    var waitingTime: Int?
    var iosLnk: String?
    var staticcode: String?

    // extended Props
    var contentMinimizedTextSize: String?
    var contentMinimizedTextColor: String?
    var contentMinimizedFontFamily: String?
    var contentMinimizedCustomFontFamilyIos: String?
    var contentMinimizedTextOrientation: String?
    var contentMinimizedBackgroundImage: String?
    var contentMinimizedBackgroundColor: String?
    var contentMinimizedArrowColor: String?
    var contentMaximizedBackgroundImage: String?
    var contentMaximizedBackgroundColor: String?

    /// `content_minimized_items` of the extended props. Empty when the panel sends the legacy single item payload.
    var items: [DrawerItemServiceModel] = []

    public var jsContent: String?
    public var jsonContent: String?
    
    var report: DrawerReport?
}

struct DrawerItemServiceModel {

    var iosLnk: String?
    var staticcode: String?
    var contentMinimizedImage: String?
    var contentMinimizedText: String?
    var contentMinimizedTextSize: String?
    var contentMinimizedTextColor: String?
    var contentMinimizedFontFamily: String?
    var contentMinimizedCustomFontFamilyIos: String?
    var contentMinimizedTextOrientation: String?
    var contentMinimizedBackgroundImage: String?
    var contentMinimizedBackgroundColor: String?
    var contentMinimizedArrowColor: String?
    var contentMaximizedImage: String?
    var contentMaximizedBackgroundImage: String?
    var contentMaximizedBackgroundColor: String?

    init() { }

    /// Mirrors the legacy single item payload, where the item fields live directly on the action data and extended props.
    init(legacy serviceModel: DrawerServiceModel) {
        iosLnk = serviceModel.iosLnk
        staticcode = serviceModel.staticcode
        contentMinimizedImage = serviceModel.contentMinimizedImage
        contentMinimizedText = serviceModel.contentMinimizedText
        contentMinimizedTextSize = serviceModel.contentMinimizedTextSize
        contentMinimizedTextColor = serviceModel.contentMinimizedTextColor
        contentMinimizedFontFamily = serviceModel.contentMinimizedFontFamily
        contentMinimizedCustomFontFamilyIos = serviceModel.contentMinimizedCustomFontFamilyIos
        contentMinimizedTextOrientation = serviceModel.contentMinimizedTextOrientation
        contentMinimizedBackgroundImage = serviceModel.contentMinimizedBackgroundImage
        contentMinimizedBackgroundColor = serviceModel.contentMinimizedBackgroundColor
        contentMinimizedArrowColor = serviceModel.contentMinimizedArrowColor
        contentMaximizedImage = serviceModel.contentMaximizedImage
        contentMaximizedBackgroundImage = serviceModel.contentMaximizedBackgroundImage
        contentMaximizedBackgroundColor = serviceModel.contentMaximizedBackgroundColor
    }
}

public struct DrawerReport: Codable {
    var impression: String
    var click: String
}

struct DrawerViewModel {

    // constants and varams
    var drawerHeight = 250.0
    var miniDrawerWidth = 50.0
    var miniDrawerWidthForCircle = 140.0
    var xCoordPaddingConstant = -25.0
    var cornerRadius = 10.0
    var autoScrollInterval = 5.0

    var actId: Int?
    var title: String?
    var actiontype: String?

    // params
    var isCircle: Bool = false
    // pos
    var screenYcoordinate: screenYcoordinate?
    var screenXcoordinate: screenXcoordinate?
    //
    var miniDrawerContentImage: String?
    var titleString: String = "Label"
    var drawerContentImage: String?
    var waitTime: Int?
    var linkToGo: String?
    var staticcode: String?

    // extended Props

    var miniDrawerTextFont: UIFont?
    var miniDrawerTextColor: UIColor?
    var labelType: labelType?
    var miniDrawerBackgroundImage: String?
    var miniDrawerBackgroundColor: UIColor?
    var arrowColor: UIColor?
    var drawerBackgroundImage: String?
    var drawerBackgroundColor: UIColor?

    /// Always holds at least one item. Legacy payloads produce a single item list.
    var items: [DrawerItemViewModel] = []

}

struct DrawerItemViewModel {

    /// Link and promo code of this item. Falls back to the action data values when the
    /// panel does not send them per item.
    var linkToGo: String = ""
    var staticcode: String = ""

    var miniDrawerContentImage: String = ""
    var titleString: String = ""
    var drawerContentImage: String = ""

    var miniDrawerTextFont: UIFont?
    var miniDrawerTextColor: UIColor?
    var labelType: labelType = .downToUp
    var miniDrawerBackgroundImage: String = ""
    var miniDrawerBackgroundColor: UIColor?
    var arrowColor: UIColor?
    var drawerBackgroundImage: String = ""
    var drawerBackgroundColor: UIColor?

}

public enum screenYcoordinate {
    case top
    case middle
    case bottom
}

public enum screenXcoordinate {
    case right
    case left
}

public enum labelType {
    case downToUp
    case upToDown
}
