//
//  VisilabsUIView.swift
//  VisilabsIOS
//
//  Created by Egemen on 16.04.2020.
//

import UIKit

extension UIView {
    
    func visilabs_snapshotImage() -> UIImage? {
        var offsetHeight: CGFloat = 0.0

        //Avoid the status bar on phones running iOS < 7
        if UIDevice.current.systemVersion.compare("7.0", options: .numeric, range: nil, locale: .current) == .orderedAscending && !UIApplication.shared.isStatusBarHidden {
            offsetHeight = UIApplication.shared.statusBarFrame.size.height
        }
        var size = layer.bounds.size
        size.height -= offsetHeight
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0.0, y: -offsetHeight)
        
        if responds(to: #selector(UIView.drawHierarchy(in:afterScreenUpdates:))) {
            drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height), afterScreenUpdates: true)
        } else {
            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
            }
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image


    }

    /*
    func visilabs_snapshotForBlur() -> UIImage? {
        let image = visilabs_snapshotImage()
        // hack, helps with colors when blurring
        let imageData = image?.jpegData(compressionQuality: 1) // convert to jpeg
        if let imageData = imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
 */
    
    
}
