//
//  InAppHelper.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 24.06.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class InAppHelper {
    
    typealias imageHandler = (UIImage) -> Void
    
    static let miniIconUrlFormat = "https://img.visilabs.net/in-app-message/icons/icon_#.png"
    static let miniIcons = ["alert", "bell", "chat", "checkmark", "coin", "download", "flag", "gear", "heart", "megaphone", "phone", "pricetag", "refresh", "rocket", "star", "trophy", "vip"]
    
    static func downloadMiniIconImagesAndSave() {
        for miniIcon in miniIcons {
            var miniIconUrl = URL(fileURLWithPath: miniIconUrlFormat.replacingOccurrences(of: "#", with: miniIcon))
        }
    }
    
    
    static func downloadImage(url: URL, completion: imageHandler = { _ in }){
        let dataTask = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let data = data {
                if let image = UIImage(data: data) {
                    let heightInPoints = image.size.height
                    let heightInPixels = heightInPoints * image.scale
                    let widthInPoints = image.size.width
                    let widthInPixels = widthInPoints * image.scale
                }
            }
        }
        dataTask.resume()
    }
    

    static func saveImage(imageName: String, image: UIImage) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
        
    }
    
    static func loadImageFromDiskWith(fileName: String) -> UIImage? {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }
        
        return nil
    }
}
