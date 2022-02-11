//
//  UIImage+Blur.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import UIKit

public extension UIImage {
    
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = false) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    convenience init?(systemItem sysItem: UIBarButtonItem.SystemItem,
                      renderingMode: UIImage.RenderingMode = .automatic) {
        guard let sysImage = UIImage.imageFromSystemItem(sysItem, renderingMode: renderingMode)?.cgImage else {
            return nil
        }
        self.init(cgImage: sysImage)
    }
    
    private class func imageFromSystemItem(_ systemItem: UIBarButtonItem.SystemItem,
                                           renderingMode: UIImage.RenderingMode = .automatic) -> UIImage? {
        
        let tempItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
        
        // add to toolbar and render it
        let bar = UIToolbar()
        bar.setItems([tempItem], animated: false)
        bar.snapshotView(afterScreenUpdates: true)
        
        // got image from real uibutton
        guard let itemView = tempItem.value(forKey: "view") as? UIView else {
            return nil
        }
        
        for view in itemView.subviews where view is UIButton {
            guard let button = view as? UIButton else {
                return nil
            }
            let image = button.imageView!.image!
            image.withRenderingMode(renderingMode)
            return image
        }
        
        return nil
    }
}
