//
//  VisilabsLogger.swift
//  VisilabsIOS
//
//  Created by Egemen on 3.05.2020.
//

import Foundation

enum VisilabsLogLevel: String {
    /// Logging displays *all* logs and additional debug information that may be useful to a developer
    case debug

    /// Logging displays *all* logs (**except** debug)
    case info

    /// Logging displays *only* warnings and above
    case warning

    /// Logging displays *only* errors and above
    case error
}

class VisilabsLogger{
    private static var enabledLevels = Set<VisilabsLogLevel>()
    
}
