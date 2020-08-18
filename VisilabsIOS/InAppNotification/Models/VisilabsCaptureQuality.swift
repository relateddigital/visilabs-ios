//
//  VisilabsCaptureQuality.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

//TODO: bu enum kaldırılabilir. sadece medium kullanılıyor.
public enum VisilabsCaptureQuality {
    case `default`
    case low
    case medium
    case high

    var imageScale: CGFloat {
        switch self {
        case .default, .high:
            return 0
        case .low, .medium:
            return  1
        }
    }

    var interpolationQuality: CGInterpolationQuality {
        switch self {
        case .default, .low:
            return .none
        case .medium, .high:
            return .default
        }
    }
}
