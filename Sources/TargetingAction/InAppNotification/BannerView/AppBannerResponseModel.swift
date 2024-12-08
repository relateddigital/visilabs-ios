//
//  AppBannerResponseModel.swift
//  RelatedDigitalIOS
//
//  Created by Orhun Akmil on 1.11.2022.
//

import Foundation

class AppBannerResponseModel {
    public var app_banners: [AppBannerModel]
    public var transition: String
    public var error: VisilabsError?
    public var height : Int?
    public var width : Int?

    internal init(app_banners: [AppBannerModel], error: VisilabsError? = nil, transition: String,height : Int? = nil, width : Int? = nil) {
        self.app_banners = app_banners
        self.transition = transition
        self.error = error
        self.height = height
        self.width = width
    }
}

struct AppBannerModel {

    let img: String?
    let ios_lnk: String?

}
