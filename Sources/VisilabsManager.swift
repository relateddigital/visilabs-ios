//
//  VisilabsManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.07.2020.
//

class VisilabsManager {
    
    static var initializeCalled = false;
    static let sharedInstance = VisilabsManager()
    private var instance: VisilabsInstance?
    
    init() {
        VisilabsLogger.addLogging(VisilabsPrintLogging())
    }
    // swiftlint:disable function_parameter_count
    func initialize(organizationId: String,
                    profileId: String,
                    dataSource: String,
                    inAppNotificationsEnabled: Bool,
                    channel: String,
                    requestTimeoutInSeconds: Int,
                    geofenceEnabled: Bool,
                    askLocationPermmissionAtStart: Bool,
                    maxGeofenceCount: Int,
                    isIDFAEnabled: Bool,
                    loggingEnabled: Bool,
                    isTest: Bool) -> VisilabsInstance {
        VisilabsManager.initializeCalled = true
        setTest(test: isTest)
        let instance = VisilabsInstance(organizationId: organizationId,
                                        profileId: profileId,
                                        dataSource: dataSource,
                                        inAppNotificationsEnabled: inAppNotificationsEnabled,
                                        channel: channel,
                                        requestTimeoutInSeconds: requestTimeoutInSeconds,
                                        geofenceEnabled: geofenceEnabled,
                                        askLocationPermmissionAtStart: askLocationPermmissionAtStart,
                                        maxGeofenceCount: maxGeofenceCount,
                                        isIDFAEnabled: isIDFAEnabled,
                                        loggingEnabled: loggingEnabled)
        self.instance = instance
        return instance
    }
    
    func setTest(test:Bool) {
        if test {
            urlConstant.shared.setTest()
        }
    }
    
    func initialize() {
        VisilabsManager.initializeCalled = true
        if let instance = VisilabsInstance() {
            self.instance = instance
        }
    }
    
    func getInstance() -> VisilabsInstance? {
        return instance
    }
}
