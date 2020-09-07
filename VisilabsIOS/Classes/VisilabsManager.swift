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

    func initialize(organizationId: String, profileId: String, dataSource: String, inAppNotificationsEnabled: Bool, channel: String, requestTimeoutInSeconds: Int, geofenceEnabled: Bool, maxGeofenceCount: Int) -> VisilabsInstance {
        let instance = VisilabsInstance(organizationId: organizationId, profileId: profileId, dataSource: dataSource, inAppNotificationsEnabled: inAppNotificationsEnabled, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount)
        self.instance = instance
        return instance
    }

    func getInstance() -> VisilabsInstance? {
        return instance
    }
}
