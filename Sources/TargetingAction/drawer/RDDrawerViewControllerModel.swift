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

        drawerModel.miniDrawerContentImage = serviceModel?.contentMinimizedImage ?? ""
        drawerModel.titleString = serviceModel?.contentMinimizedText ?? ""
        drawerModel.drawerContentImage = serviceModel?.contentMaximizedImage ?? ""
        drawerModel.waitTime = serviceModel?.waitingTime
        drawerModel.linkToGo = serviceModel?.iosLnk

        drawerModel.miniDrawerTextFont = VisilabsHelper.getFont(fontFamily: serviceModel?.contentMinimizedFontFamily, fontSize: serviceModel?.contentMinimizedTextSize, style: .title2, customFont: serviceModel?.contentMinimizedCustomFontFamilyIos)
        drawerModel.miniDrawerTextColor = UIColor(hex: serviceModel?.contentMinimizedTextColor)

        if serviceModel?.contentMinimizedTextOrientation?.lowercased() == "toptobottom" {
            drawerModel.labelType = .upToDown
        } else {
            drawerModel.labelType = .downToUp
        }

        drawerModel.miniDrawerBackgroundImage = serviceModel?.contentMinimizedBackgroundImage ?? ""
        drawerModel.miniDrawerBackgroundColor = UIColor(hex: serviceModel?.contentMinimizedBackgroundColor)

        if drawerModel.miniDrawerContentImage?.count != 0 { //contentImage remove
            drawerModel.miniDrawerBackgroundImage = serviceModel?.contentMinimizedImage ?? ""
        }
        
        if serviceModel?.contentMinimizedArrowColor?.count == 0 {
            drawerModel.arrowColor = .clear
        } else {
            drawerModel.arrowColor = UIColor(hex: serviceModel?.contentMinimizedArrowColor)
        }

        drawerModel.drawerBackgroundImage = serviceModel?.contentMaximizedBackgroundImage ?? ""
        drawerModel.drawerBackgroundColor = UIColor(hex: serviceModel?.contentMaximizedBackgroundColor)

        return drawerModel
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

    public var jsContent: String?
    public var jsonContent: String?
    
    var report: DrawerReport?
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
