//
//  VisilabsLogger.swift
//  VisilabsIOS
//
//  Created by Egemen on 3.05.2020.
//

import Foundation
import os.log

enum VisilabsLogLevel: String {
    case debug = "▪️"
    case info = "🔷"
    case warning = "🔶"
    case error = "❌"
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

class VisilabsPrintLogging: VisilabsLogging {
    func addMessage(message: VisilabsLogMessage) {
        let msg = "[Visilabs(\(message.level.rawValue))  - \(message.file) - func \(message.function)] : \(message.text)"
        os_log("%@", type: .debug, msg)
    }
}

class VisilabsLogger {
    private static let readWriteLock: VisilabsReadWriteLock = VisilabsReadWriteLock(label: "visilabsLoggerLock")
    private static var enabledLevels = Set<VisilabsLogLevel>()
    private static var loggers = [VisilabsLogging]()

    class func addLogging(_ logging: VisilabsLogging) {
        readWriteLock.write {
            loggers.append(logging)
        }
    }

    class func enableLevels(_ levels: [VisilabsLogLevel]) {
        readWriteLock.write {
            for level in levels {
                enabledLevels.insert(level)
            }
        }
    }

    class func disableLevels(_ levels: [VisilabsLogLevel]) {
        readWriteLock.write {
            for level in levels {
                enabledLevels.remove(level)
            }
        }
    }

    class func debug(_ message: @autoclosure() -> Any, _ path: String = #file, _ function: String = #function) {
       var enabledLevels = Set<VisilabsLogLevel>()
       readWriteLock.read {
           enabledLevels = self.enabledLevels
       }
       guard enabledLevels.contains(.debug) else { return }
       forwardLogMessage(VisilabsLogMessage(path: path, function: function, text: "\(message())", level: .debug))
   }

    class func info(_ message: @autoclosure() -> Any, _ path: String = #file, _ function: String = #function) {
       var enabledLevels = Set<VisilabsLogLevel>()
       readWriteLock.read {
           enabledLevels = self.enabledLevels
       }
       guard enabledLevels.contains(.info) else { return }
       forwardLogMessage(VisilabsLogMessage(path: path, function: function, text: "\(message())", level: .info))
   }

    class func warn(_ message: @autoclosure() -> Any, _ path: String = #file, _ function: String = #function) {
       var enabledLevels = Set<VisilabsLogLevel>()
       readWriteLock.read {
           enabledLevels = self.enabledLevels
       }
       guard enabledLevels.contains(.warning) else { return }
       forwardLogMessage(VisilabsLogMessage(path: path, function: function, text: "\(message())", level: .warning))
   }

   class func error(_ message: @autoclosure() -> Any, _ path: String = #file, _ function: String = #function) {
       var enabledLevels = Set<VisilabsLogLevel>()
       readWriteLock.read {
           enabledLevels = self.enabledLevels
       }
       guard enabledLevels.contains(.error) else { return }
       forwardLogMessage(VisilabsLogMessage(path: path, function: function, text: "\(message())", level: .error))
   }

    class private func forwardLogMessage(_ message: VisilabsLogMessage) {
        var loggers = [VisilabsLogging]()
        readWriteLock.read {
            loggers = self.loggers
        }
        loggers.forEach { $0.addMessage(message: message) }
    }

}
