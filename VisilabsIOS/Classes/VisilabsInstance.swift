//
//  VisilabsInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 4.05.2020.
//

import Foundation
import SystemConfiguration

class Visilabs2 {
    
    public class func callAPI() -> VisilabsInstance {
        if let instance = VisilabsManager.sharedInstance.getInstance() {
            return instance
        } else {
            assert(false, "You have to call createAPI before calling the callAPI.")
            return Visilabs2.createAPI(organizationId: "", siteId: "", loggerUrl: "", dataSource: "", realTimeUrl: "")
        }
    }
    
    @discardableResult
    public class func createAPI(organizationId: String, siteId: String, loggerUrl: String, dataSource: String, realTimeUrl: String, channel: String = "IOS", requestTimeoutInSeconds: Int = 60, targetUrl: String? = nil, actionUrl: String? = nil, geofenceUrl: String? = nil, geofenceEnabled: Bool = false, maxGeofenceCount: Int = 20, restUrl: String? = nil, encryptedDataSource: String? = nil) -> VisilabsInstance {
        VisilabsManager.sharedInstance.initialize(organizationId: organizationId, siteId: siteId, loggerUrl: loggerUrl, dataSource: dataSource, realTimeUrl: realTimeUrl, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, targetUrl: targetUrl
        , actionUrl: actionUrl, geofenceUrl: geofenceUrl, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount, restUrl: restUrl, encryptedDataSource: encryptedDataSource)
    }
}

class VisilabsInstance: CustomDebugStringConvertible {
    
    var organizationId = ""
    var siteId = ""
    var dataSource = ""
    var channel = ""
    var requestTimeoutInSeconds : Int
    var geofenceEnabled = false
    var maxGeofenceCount : Int
    var restUrl : String?
    var encryptedDataSource : String?
    
    //TODO: www.relateddigital.com ı değiştirmeli miyim?
    static let reachability = SCNetworkReachabilityCreateWithName(nil, "www.relateddigital.com")
    
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
    
    init(organizationId: String, siteId: String, loggerUrl: String, dataSource: String, realTimeUrl: String, channel: String, requestTimeoutInSeconds: Int, targetUrl: String?, actionUrl: String?, geofenceUrl: String?, geofenceEnabled: Bool, maxGeofenceCount: Int, restUrl: String?, encryptedDataSource: String?) {
        self.organizationId = organizationId
        self.siteId = siteId
        self.dataSource = dataSource
        self.channel = channel
        self.requestTimeoutInSeconds = requestTimeoutInSeconds
        self.geofenceEnabled = geofenceEnabled
        self.maxGeofenceCount = (maxGeofenceCount < 0 && maxGeofenceCount > 20) ? 20 : maxGeofenceCount
        self.restUrl = restUrl
        self.encryptedDataSource = encryptedDataSource
        VisilabsBasePath.endpoints[.logger] = loggerUrl
        VisilabsBasePath.endpoints[.realtime] = realTimeUrl
        VisilabsBasePath.endpoints[.target] = targetUrl
        VisilabsBasePath.endpoints[.action] = actionUrl
        VisilabsBasePath.endpoints[.geofence] = geofenceUrl
    }
    
}

class VisilabsManager {
    
    static let sharedInstance = VisilabsManager()
    private var instance: VisilabsInstance?
    
    init() {
        VisilabsLogger.addLogging(VisilabsPrintLogging())
    }
    
    func initialize(organizationId: String, siteId: String, loggerUrl: String, dataSource: String, realTimeUrl: String, channel: String = "IOS", requestTimeoutInSeconds: Int = 60, targetUrl: String? = nil, actionUrl: String? = nil, geofenceUrl: String? = nil, geofenceEnabled: Bool = false, maxGeofenceCount: Int = 20, restUrl: String? = nil, encryptedDataSource: String? = nil) -> VisilabsInstance {
        return VisilabsInstance(organizationId: organizationId, siteId: siteId, loggerUrl: loggerUrl, dataSource: dataSource, realTimeUrl: realTimeUrl, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, targetUrl: targetUrl
        , actionUrl: actionUrl, geofenceUrl: geofenceUrl, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount, restUrl: restUrl, encryptedDataSource: encryptedDataSource)
    }
    
    func getInstance() -> VisilabsInstance? {
        return instance
    }
}
