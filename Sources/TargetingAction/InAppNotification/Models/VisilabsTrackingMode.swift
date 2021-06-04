//
//  VisilabsTrackingMode.swift
//  VisilabsIOS
//
//  Created by Egemen on 12.06.2020.
//

import Foundation

public enum VisilabsTrackingMode: CustomStringConvertible {
    case tracking
    case common
    case none

    public var description: String {
        switch self {
        case .tracking:
            return RunLoop.Mode.tracking.rawValue
        case .common:
            return RunLoop.Mode.common.rawValue
        case .none:
            return ""
        }
    }
}
