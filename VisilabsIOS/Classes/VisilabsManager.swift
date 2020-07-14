//
//  VisilabsManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.07.2020.
//

class VisilabsManager {
    static let sharedInstance = VisilabsManager()
    private var instance: VisilabsInstance?

    init() {
        VisilabsLogger.addLogging(VisilabsPrintLogging())
    }

    func initialize(organizationId: String, siteId: String, loggerUrl: String, dataSource: String, realTimeUrl: String, channel: String, requestTimeoutInSeconds: Int, targetUrl: String?, actionUrl: String?, geofenceUrl: String?, geofenceEnabled: Bool, maxGeofenceCount: Int, restUrl: String?, encryptedDataSource: String?) -> VisilabsInstance {
        let instance = VisilabsInstance(organizationId: organizationId, siteId: siteId, loggerUrl: loggerUrl, dataSource: dataSource, realTimeUrl: realTimeUrl, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, targetUrl: targetUrl
                                        , actionUrl: actionUrl, geofenceUrl: geofenceUrl, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount, restUrl: restUrl, encryptedDataSource: encryptedDataSource)
        self.instance = instance
        return instance
    }

    func getInstance() -> VisilabsInstance? {
        return instance
    }
}
