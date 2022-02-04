//
//  Visilabs.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.07.2020.
//

public class RelatedDigital {
    public class func callAPI() -> RelatedDigitalInstance {
        if let instance = RelatedDigitalManager.sharedInstance.getInstance() {
            return instance
        } else {
            assert(false, "You have to call createAPI before calling the callAPI.")
            return RelatedDigital.createAPI(organizationId: "", profileId: "", dataSource: "")
        }
    }

    @discardableResult
    public class func createAPI(organizationId: String,
                                profileId: String,
                                dataSource: String,
                                inAppNotificationsEnabled: Bool = false,
                                channel: String = "IOS",
                                requestTimeoutInSeconds: Int = 30,
                                geofenceEnabled: Bool = false,
                                maxGeofenceCount: Int = 20,
                                isIDFAEnabled: Bool = true,
                                loggingEnabled: Bool = false,
                                isTest:Bool = false) -> RelatedDigitalInstance {


        RelatedDigitalManager.sharedInstance.initialize(organizationId: organizationId,
                                                  profileId: profileId,
                                                  dataSource: dataSource,
                                                  inAppNotificationsEnabled: inAppNotificationsEnabled,
                                                  channel: channel,
                                                  requestTimeoutInSeconds: requestTimeoutInSeconds,
                                                  geofenceEnabled: geofenceEnabled,
                                                  maxGeofenceCount: maxGeofenceCount,
                                                  isIDFAEnabled: isIDFAEnabled,
                                                  loggingEnabled: loggingEnabled,
                                                  isTest: isTest)
    }
    
    public class func createAPI() {
        RelatedDigitalManager.sharedInstance.initialize()
    }
}
