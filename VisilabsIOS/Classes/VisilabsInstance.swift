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
    var dataSource = ""
    var channel = ""
    
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
    
    init(organizationId: String, siteId: String, loggerURL: String, dataSource: String, realTimeURL: String, channel: String, requestTimeoutInSeconds: Int, restURL: String?, encryptedDataSource: String?, targetURL: String?, actionURL: String?, geofenceURL: String?, geofenceEnabled: Bool, maxGeofenceCount: Int) {
        self.organizationId = organizationId
        self.siteId = siteId
        self.dataSource = dataSource
        self.channel = channel
        VisilabsBasePath.endpoints[.logger] = loggerURL
        VisilabsBasePath.endpoints[.realtime] = realTimeURL
        VisilabsBasePath.endpoints[.target] = targetURL
        VisilabsBasePath.endpoints[.action] = actionURL
        VisilabsBasePath.endpoints[.geofence] = geofenceURL
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
