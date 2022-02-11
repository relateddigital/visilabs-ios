//
//  GalleryUtilityFunctions.swift
//  VisilabsIOS
//
//  Created by Egemen Gülkılık on 8.02.2022.
//

import UIKit

// the transform needed to rotate a view that matches device screen orientation to match window orientation.
func windowRotationTransform() -> CGAffineTransform {
    let angleInDegrees = rotationAngleToMatchDeviceOrientation(UIDevice.current.orientation)
    let angleInRadians = degreesToRadians(angleInDegrees)
    return CGAffineTransform(rotationAngle: angleInRadians)
}

// the transform needed to rotate a view that matches window orientation to match devices screen orientation.
func deviceRotationTransform() -> CGAffineTransform {
    let angleInDegrees = rotationAngleToMatchDeviceOrientation(UIDevice.current.orientation)
    let angleInRadians = degreesToRadians(angleInDegrees)
    return CGAffineTransform(rotationAngle: -angleInRadians)
}

func degreesToRadians(_ degree: CGFloat) -> CGFloat {
    return CGFloat(Double.pi) * degree / 180
}

private func rotationAngleToMatchDeviceOrientation(_ orientation: UIDeviceOrientation) -> CGFloat {
    var desiredRotationAngle: CGFloat = 0
    switch orientation {
    case .landscapeLeft:                    desiredRotationAngle = 90
    case .landscapeRight:                   desiredRotationAngle = -90
    case .portraitUpsideDown:               desiredRotationAngle = 180
    default:                                desiredRotationAngle = 0
    }
    return desiredRotationAngle
}

func rotationAdjustedBounds() -> CGRect {
    let applicationWindow = UIApplication.shared.delegate?.window?.flatMap { $0 }
    guard let window = applicationWindow else { return UIScreen.main.bounds }
    if UIApplication.isPortraitOnly {
        return (UIDevice.current.orientation.isLandscape) ? CGRect(origin: CGPoint.zero, size: window.bounds.size.inverted()): window.bounds
    }
    return window.bounds
}
