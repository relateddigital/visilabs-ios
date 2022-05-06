//
//  InAppHelper.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 24.06.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class InAppHelper {
        
    static let miniIconUrlFormat = "https://img.visilabs.net/in-app-message/icons/icon_#.png"
    static let miniIcons = ["alert", "bell", "chat", "checkmark", "coin", "download", "flag",
                            "gear", "heart", "megaphone", "phone", "pricetag", "refresh",
                            "rocket", "star", "trophy", "vip"]
    static var miniIconImages = [String: UIImage]()
    
    static func downloadMiniIconImagesAndSave() {
        for miniIcon in miniIcons {
            if let miniIconUrl = URL(string: miniIconUrlFormat.replacingOccurrences(of: "#", with: miniIcon)) {
                downloadImage(miniIconUrl, iconName: miniIcon)
            }
        }
    }
    
    static func downloadImage(_ url: URL, iconName: String? = nil) {
        let dataTask = URLSession.shared.dataTask(with: url) {(data, _, _) in
            if let data = data {
                if let image = UIImage(data: data), let iName = iconName  {
                    miniIconImages[iName] = image
                }
            }
        }
        dataTask.resume()
    }
    
}
