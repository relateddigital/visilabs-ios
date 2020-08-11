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

    func initialize(organizationId: String, siteId: String, dataSource: String, channel: String, requestTimeoutInSeconds: Int, geofenceEnabled: Bool, maxGeofenceCount: Int, restUrl: String?, encryptedDataSource: String?) -> VisilabsInstance {
        let instance = VisilabsInstance(organizationId: organizationId, siteId: siteId, dataSource: dataSource, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds
            , geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount, restUrl: restUrl, encryptedDataSource: encryptedDataSource)
        self.instance = instance
        return instance
    }

    func getInstance() -> VisilabsInstance? {
        return instance
    }
}
