//
//  visilabsSideBarViewControllerModel.swift
//  VisilabsIOS
//
//  Created by Orhun Akmil on 31.03.2022.
//

import Foundation


class visilabsSideBarViewControllerModel {
    
    
    func mapServiceModelToNeededModel(serviceModel : SideBarViewModel?)  -> SideBarModel {
        
        var sideBarModel = SideBarModel()
        
        sideBarModel.actId = serviceModel?.actId
        sideBarModel.title = serviceModel?.title
        sideBarModel.actiontype = serviceModel?.actiontype
        
        if serviceModel?.shape == "circle" {
            sideBarModel.isCircle = true
        }
        
        if ((serviceModel?.pos?.contains("top")) != nil) {
            sideBarModel.screenYcoordinate = .top
        } else if ((serviceModel?.pos?.contains("middle")) != nil) {
            sideBarModel.screenYcoordinate = .middle
        }  else if ((serviceModel?.pos?.contains("bottom")) != nil) {
            sideBarModel.screenYcoordinate = .bottom
        }
        
        if ((serviceModel?.pos?.contains("Right")) != nil) {
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
        
        if serviceModel?.contentMinimizedTextOrientation == "" {
            sideBarModel.labelType = .downToUp
        } else {
            sideBarModel.labelType = .upToDown
        }
        
        
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


struct SideBarViewModel {
    
    var actId:Int?
    var title:String?
    var actiontype:String?
    
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

struct SideBarModel {
    
    //constants and varams
    var sideBarHeight = 200.0
    var miniSideBarWidth = 40.0
    var miniSideBarWidthForCircle = 140.0
    var xCoordPaddingConstant = -25.0
    
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
    var labelType : labelType?
    var miniSideBarBackgroundImage:UIImage?
    var miniSideBarBackgroundColor:String?
    var arrowColor:String?
    var sideBarBackgroundImage:String?
    var sideBarBackgroundColor:String?
    
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
