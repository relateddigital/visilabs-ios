//
//  VisilabsManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 14.07.2020.
//

class RelatedDigitalManager {
    static let sharedInstance = RelatedDigitalManager()
    private var instance: RelatedDigitalInstance?
    
    init() {
        RelatedDigitalLogger.addLogging(VisilabsPrintLogging())
    }
    // swiftlint:disable function_parameter_count
    func initialize(organizationId: String,
                    profileId: String,
                    dataSource: String,
                    inAppNotificationsEnabled: Bool,
                    channel: String,
                    requestTimeoutInSeconds: Int,
                    geofenceEnabled: Bool,
                    maxGeofenceCount: Int,
                    isIDFAEnabled: Bool,
                    loggingEnabled: Bool,
                    isTest: Bool) -> RelatedDigitalInstance {
        setTest(test: isTest)
        let instance = RelatedDigitalInstance(organizationId: organizationId,
                                        profileId: profileId,
                                        dataSource: dataSource,
                                        inAppNotificationsEnabled: inAppNotificationsEnabled,
                                        channel: channel,
                                        requestTimeoutInSeconds: requestTimeoutInSeconds,
                                        geofenceEnabled: geofenceEnabled,
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
        if let instance = RelatedDigitalInstance() {
            self.instance = instance
        }
    }
    
    func getInstance() -> RelatedDigitalInstance? {
        return instance
    }
}
