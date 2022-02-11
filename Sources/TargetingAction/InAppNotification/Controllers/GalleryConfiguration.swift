//
//  GalleryConfiguration.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 8.02.2022.
//


import UIKit

public typealias MarginLeft = CGFloat
public typealias MarginRight = CGFloat
public typealias MarginTop = CGFloat
public typealias MarginBottom = CGFloat

/// Represents possible layouts for the close button
public enum ButtonLayout {
    case pinLeft(MarginTop, MarginLeft)
    case pinRight(MarginTop, MarginRight)
}


/// Represents various possible layouts for the footer
public enum FooterLayout {
    case pinLeft(MarginBottom, MarginLeft)
    case pinRight(MarginBottom, MarginRight)
    case pinBoth(MarginBottom, MarginLeft, MarginRight)
    case center(MarginBottom)
}

public enum GalleryRotationMode {
    ///Gallery will rotate to orientations supported in the application.
    case applicationBased
    ///Gallery will rotate regardless of the rotation setting in the application.
    case always
}

public enum ButtonMode {
    case none
    case builtIn /// Standard Close or Thumbnails button.
    case custom(UIButton)
}

public enum GalleryDisplacementStyle {
    case normal
    case springBounce(CGFloat) ///
}
