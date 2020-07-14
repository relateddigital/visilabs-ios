//
//  Visilabs.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.07.2020.
//

public class Visilabs {
    public class func callAPI() -> VisilabsInstance {
        if let instance = VisilabsManager.sharedInstance.getInstance() {
            return instance
        } else {
            assert(false, "You have to call createAPI before calling the callAPI.")
            return Visilabs.createAPI(organizationId: "", siteId: "", loggerUrl: "", dataSource: "", realTimeUrl: "")
        }
    }

    @discardableResult
    public class func createAPI(organizationId: String, siteId: String, loggerUrl: String, dataSource: String, realTimeUrl: String, channel: String = "IOS", requestTimeoutInSeconds: Int = 60, targetUrl: String? = nil, actionUrl: String? = nil, geofenceUrl: String? = nil, geofenceEnabled: Bool = false, maxGeofenceCount: Int = 20, restUrl: String? = nil, encryptedDataSource: String? = nil) -> VisilabsInstance {
        VisilabsManager.sharedInstance.initialize(organizationId: organizationId, siteId: siteId, loggerUrl: loggerUrl, dataSource: dataSource, realTimeUrl: realTimeUrl, channel: channel, requestTimeoutInSeconds: requestTimeoutInSeconds, targetUrl: targetUrl
                                                  , actionUrl: actionUrl, geofenceUrl: geofenceUrl, geofenceEnabled: geofenceEnabled, maxGeofenceCount: maxGeofenceCount, restUrl: restUrl, encryptedDataSource: encryptedDataSource)
    }
}
