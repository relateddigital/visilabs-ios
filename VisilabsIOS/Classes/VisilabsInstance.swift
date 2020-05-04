//
//  VisilabsInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 4.05.2020.
//

import Foundation

class VisilabsInstance: CustomDebugStringConvertible {
    
    var organizationId = ""
    var siteId = ""
    
    public var debugDescription: String {
        return "Visilabs(siteId : \(siteId) organizationId: \(organizationId)"
    }
    
    public var loggingEnabled: Bool = false {
        didSet {
            if loggingEnabled {
                VisilabsLogger.enableLevel(.debug)
                VisilabsLogger.enableLevel(.info)
                VisilabsLogger.enableLevel(.warning)
                VisilabsLogger.enableLevel(.error)
                VisilabsLogger.info(message: "Visilabs Logging Enabled")
            } else {
                VisilabsLogger.info(message: "Visilabs Logging Disabled")
                VisilabsLogger.disableLevel(.debug)
                VisilabsLogger.disableLevel(.info)
                VisilabsLogger.disableLevel(.warning)
                VisilabsLogger.disableLevel(.error)
            }
        }
    }
    
}

class VisilabsManager {
    
    static let sharedInstance = VisilabsManager()
    private var instance: VisilabsInstance?
    
    init() {
        VisilabsLogger.addLogging(VisilabsPrintLogging())
    }
    
    func initialize(organizationID: String, siteID: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String = "IOS", requestTimeoutInSeconds: Int = 60, targetURL: String? = nil, actionURL: String? = nil, geofenceURL: String? = nil, geofenceEnabled: Bool = false, maxGeofenceCount: Int = 20, restURL: String? = nil, encryptedDataSource: String? = nil) -> VisilabsInstance?{
        return nil
    }
    
    func getInstance() -> VisilabsInstance? {
        return instance
    }
}
