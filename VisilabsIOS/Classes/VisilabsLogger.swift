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

struct VisilabsLogMessage {
    /// The file where this log message was created
    let file: String

    /// The function where this log message was created
    let function: String

    /// The text of the log message
    let text: String

    /// The level of the log message
    let level: VisilabsLogLevel

    init(path: String, function: String, text: String, level: VisilabsLogLevel) {
        if let file = path.components(separatedBy: "/").last {
            self.file = file
        } else {
            self.file = path
        }
        self.function = function
        self.text = text
        self.level = level
    }
}

protocol VisilabsLogging {
    func addMessage(message: VisilabsLogMessage)
}

/// Simply formats and prints the object by calling `print`
class VisilabsPrintLogging: VisilabsLogging {
    func addMessage(message: VisilabsLogMessage) {
        print("[Visilabs - \(message.file) - func \(message.function)] (\(message.level.rawValue)) - \(message.text)")
    }
}

/// Simply formats and prints the object by calling `debugPrint`, this makes things a bit easier if you
/// need to print data that may be quoted for instance.
class VisilabsPrintDebugLogging: VisilabsLogging {
    func addMessage(message: VisilabsLogMessage) {
        debugPrint("[Visilabs - \(message.file) - func \(message.function)] (\(message.level.rawValue)) - \(message.text)")
    }
}

class VisilabsLogger{
    private static let readWriteLock: VisilabsReadWriteLock = VisilabsReadWriteLock(label: "visilabsLoggerLock")
    private static var enabledLevels = Set<VisilabsLogLevel>()
    private static var loggers = [VisilabsLogging]()
}
