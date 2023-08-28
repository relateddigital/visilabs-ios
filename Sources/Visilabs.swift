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
            return Visilabs.createAPI(organizationId: "", profileId: "", dataSource: "")
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
                                askLocationPermmissionAtStart: Bool = true,
                                maxGeofenceCount: Int = 20,
                                isIDFAEnabled: Bool = true,
                                loggingEnabled: Bool = false,
                                sdkType: String = "native",
                                isTest:Bool = false) -> VisilabsInstance {


        VisilabsManager.sharedInstance.initialize(organizationId: organizationId,
                                                  profileId: profileId,
                                                  dataSource: dataSource,
                                                  inAppNotificationsEnabled: inAppNotificationsEnabled,
                                                  channel: channel,
                                                  requestTimeoutInSeconds: requestTimeoutInSeconds,
                                                  geofenceEnabled: geofenceEnabled,
                                                  askLocationPermmissionAtStart: askLocationPermmissionAtStart,
                                                  maxGeofenceCount: maxGeofenceCount,
                                                  isIDFAEnabled: isIDFAEnabled,
                                                  loggingEnabled: loggingEnabled,
                                                  sdkType: sdkType,
                                                  isTest: isTest)
    }
    
    public class func createAPI() {
        VisilabsManager.sharedInstance.initialize()
    }
    
    public class func initializeCalled() -> Bool {
        return VisilabsManager.initializeCalled
    }
    
    public static func getBannerView(properties: [String:String],completion: @escaping (BannerView?) -> Void) {
        VisilabsManager.sharedInstance.getBannerView(properties: properties) { bannerView in
            completion(bannerView)
        }
    }
    
}
