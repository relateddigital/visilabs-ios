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

class VisilabsPrintLogging: VisilabsLogging {
    func addMessage(message: VisilabsLogMessage) {
        let msg = "[Visilabs(\(message.level.rawValue)) - \(VisilabsHelper.formatDate(Date()))" +
            " - \(message.file) - func \(message.function)] : \(message.text)"
        print(msg)
    }
}

class VisilabsPrintDebugLogging: VisilabsLogging {
    func addMessage(message: VisilabsLogMessage) {
        let msg = "[Visilabs(\(message.level.rawValue)) - \(VisilabsHelper.formatDate(Date()))" +
            " - \(message.file) - func \(message.function)] : \(message.text)"
        debugPrint(msg)
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

    class func enableLevel(_ level: VisilabsLogLevel) {
        readWriteLock.write {
            enabledLevels.insert(level)
        }
    }

    class func disableLevel(_ level: VisilabsLogLevel) {
        readWriteLock.write {
            enabledLevels.remove(level)
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
