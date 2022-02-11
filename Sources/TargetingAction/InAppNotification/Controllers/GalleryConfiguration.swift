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

/// Represents various possible layouts for the header
public enum HeaderLayout {
    case pinLeft(MarginTop, MarginLeft)
    case pinRight(MarginTop, MarginRight)
    case pinBoth(MarginTop, MarginLeft, MarginRight)
    case center(MarginTop)
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

public enum GalleryPagingMode {

    case standard /// Allows paging through images from 0 to N, when first or last image reached ,horizontal swipe to dismiss kicks in.
    case carousel /// Pages through images from 0 to N and the again 0 to N in a loop, works both directions.
}

public enum GalleryDisplacementStyle {

    case normal
    case springBounce(CGFloat) ///
}

public enum GalleryPresentationStyle {
    case fade
    case displacement
}

public struct GallerySwipeToDismissMode: OptionSet {

    public init(rawValue: Int) { self.rawValue = rawValue }
    public let rawValue: Int

    public static let never      = GallerySwipeToDismissMode(rawValue: 0)
    public static let horizontal = GallerySwipeToDismissMode(rawValue: 1 << 0)
    public static let vertical   = GallerySwipeToDismissMode(rawValue: 1 << 1)
    public static let always: GallerySwipeToDismissMode = [ .horizontal, .vertical ]
}

