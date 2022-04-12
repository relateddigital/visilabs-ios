//
//  visilabsSideBarViewControllerModel.swift
//  VisilabsIOS
//
//  Created by Orhun Akmil on 31.03.2022.
//

import Foundation
import UIKit

class visilabsSideBarViewControllerModel {
    
    
    func mapServiceModelToNeededModel(serviceModel : SideBarServiceModel?)  -> SideBarViewModel {
        
        var sideBarModel = SideBarViewModel()
        
        sideBarModel.actId = serviceModel?.actId
        sideBarModel.title = serviceModel?.title
        
        if serviceModel?.shape?.lowercased() == "circle" {
            sideBarModel.isCircle = true
        } else if serviceModel?.shape?.lowercased() == "roundedcorners" {
            sideBarModel.isCircle = false
        } else {
            sideBarModel.isCircle = false
            sideBarModel.cornerRadius = 0.0
        }
        
        if (serviceModel?.pos?.lowercased().contains("top") == true) {
            sideBarModel.screenYcoordinate = .top
        } else if (serviceModel?.pos?.lowercased().contains("bottom") == true) {
            sideBarModel.screenYcoordinate = .bottom
        } else {
            sideBarModel.screenYcoordinate = .middle
        }
        
        if (serviceModel?.pos?.lowercased().contains("right") == true) {
            sideBarModel.screenXcoordinate = .right
        } else {
            sideBarModel.screenXcoordinate = .left
        }
         
        sideBarModel.miniSidebarContentImage = UIImage(data: getDataOfImage(urlString: serviceModel?.contentMinimizedImage ?? ""))
        sideBarModel.titleString = serviceModel?.contentMinimizedText ?? ""
        sideBarModel.sideBarContentImage = UIImage(data: getDataOfImage(urlString: serviceModel?.contentMaximizedImage ?? ""))
        sideBarModel.waitTime = serviceModel?.waitingTime
        sideBarModel.linkToGo = serviceModel?.iosLnk
        
        sideBarModel.miniSideBarTextFont = VisilabsHelper.getFont(fontFamily: serviceModel?.contentMinimizedFontFamily, fontSize: serviceModel?.contentMinimizedTextSize, style: .title2, customFont: serviceModel?.contentMinimizedCustomFontFamilyIos)
        sideBarModel.miniSideBarTextColor = UIColor(hex: serviceModel?.contentMinimizedTextColor)
        
        if serviceModel?.contentMinimizedTextOrientation?.lowercased() == "toptobottom" {
            sideBarModel.labelType = .upToDown
        } else {
            sideBarModel.labelType = .downToUp
        }
        
        sideBarModel.miniSideBarBackgroundImage = UIImage(data: getDataOfImage(urlString: serviceModel?.contentMinimizedBackgroundImage ?? ""))
        sideBarModel.miniSideBarBackgroundColor = UIColor(hex: serviceModel?.contentMinimizedBackgroundColor)
        
        if serviceModel?.contentMinimizedArrowColor?.count == 0 {
            sideBarModel.arrowColor = .clear
        } else {
            sideBarModel.arrowColor = UIColor(hex: serviceModel?.contentMinimizedArrowColor)
        }
        
        sideBarModel.sideBarBackgroundImage = UIImage(data: getDataOfImage(urlString: serviceModel?.contentMaximizedBackgroundImage ?? ""))
        sideBarModel.sideBarBackgroundColor = UIColor(hex: serviceModel?.contentMaximizedBackgroundColor)

        return sideBarModel
    }
    
    private func getDataOfImage(urlString : String) -> Data {
        
        let image: Data? = {
            var data: Data?
            if let iUrl = URL(string: urlString)  {
                do {
                    data = try Data(contentsOf: iUrl, options: [.mappedIfSafe])
                } catch {
                    VisilabsLogger.error("image failed to load from url \(iUrl)")
                }
            }
            return data
        }()
        
        return image ?? Data()
    }
}


struct SideBarServiceModel: TargetingActionViewModel {
    
    var targetingActionType: TargetingActionType
    var actId:Int?
    var title:String?
    
    //actionData
    var shape:String?
    var pos:String?
    var contentMinimizedImage:String?
    var contentMinimizedText:String?
    var contentMaximizedImage:String?
    var waitingTime:Int?
    var iosLnk:String?
    
    //extended Props
    var contentMinimizedTextSize:String?
    var contentMinimizedTextColor:String?
    var contentMinimizedFontFamily:String?
    var contentMinimizedCustomFontFamilyIos:String?
    var contentMinimizedTextOrientation:String?
    var contentMinimizedBackgroundImage:String?
    var contentMinimizedBackgroundColor:String?
    var contentMinimizedArrowColor:String?
    var contentMaximizedBackgroundImage:String?
    var contentMaximizedBackgroundColor:String? 
}

struct SideBarViewModel {
    
    //constants and varams
    var sideBarHeight = 200.0
    var miniSideBarWidth = 40.0
    var miniSideBarWidthForCircle = 140.0
    var xCoordPaddingConstant = -25.0
    var cornerRadius = 10.0
    
    var actId:Int?
    var title:String?
    var actiontype:String?
    
    //params
    var isCircle : Bool = false
    //pos
    var screenYcoordinate : screenYcoordinate?
    var screenXcoordinate : screenXcoordinate?
    //
    var miniSidebarContentImage : UIImage?
    var titleString : String = "Label"
    var sideBarContentImage : UIImage?
    var waitTime : Int?
    var linkToGo : String?
    
    //extended Props

    var miniSideBarTextFont : UIFont?
    var miniSideBarTextColor : UIColor?
    var labelType : labelType?
    var miniSideBarBackgroundImage:UIImage?
    var miniSideBarBackgroundColor:UIColor?
    var arrowColor:UIColor?
    var sideBarBackgroundImage:UIImage?
    var sideBarBackgroundColor:UIColor?
    
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
