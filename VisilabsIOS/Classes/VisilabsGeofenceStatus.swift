//
//  VisilabsGeofenceStatus.swift
//  VisilabsIOS
//
//  Created by Egemen on 15.04.2020.
//

import Foundation
import CoreLocation

/// The object to handle geofence status inside SHAppStatus.
class VisilabsGeofenceStatus: NSObject {
    

    /// Match to `app_status` dictionary's `geofences`. It's a time stamp of server provided geofence list. If the time stamp is newer than client fetch time, client should fetch geofence list again and monitor new list; if the time stamp is NULL or empty, client should clear cached geofence and stop monitor.
    private var _geofenceTimestamp: String?
    var geofenceTimestamp: String? {
        get {
            assert(false, "Should not call geofenceTimestamp.")
            return nil
        }
        set {
            let locationServiceEnabledForApp = VisilabsGeofenceLocationManager.locationServiceEnabled(forApp: false)
            let isMonitoringAvailableForClass = CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
            if !locationServiceEnabledForApp || !isMonitoringAvailableForClass {
                return
            }
            if newValue != nil {
                let serverTime = visilabsParseDate(geofenceTimestamp, 0)
                if serverTime != nil {
                }
                
            }
        }
    }
    
    //TODO: DispatchSemaphore u kontrol et
    private let visilabsParseDateFormatter_semaphore = { () -> DispatchSemaphore in
        var formatter_semaphore = DispatchSemaphore(value: 1)
        return formatter_semaphore
    }()

    private func visilabsParseDate(_ input: String?, _ offsetSeconds: Int) -> Date? {
        // `dispatch_once()` call was converted to a static variable initializer
        var out: Date? = nil
        if !visilabsStrIsEmpty(input) {
            (visilabsParseDateFormatter_semaphore.wait(timeout: DispatchTime.distantFuture) == .success ? 0 : -1)
            let dateFormatter = visilabsGetDateFormatter()
            out = dateFormatter.date(from: input ?? "")
            if out == nil {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                out = dateFormatter.date(from: input ?? "")
            }
        }
        return out
    }
    
    private func visilabsStrIsEmpty(_ str: String?) -> Bool {
        return str == nil || (str?.count ?? 0) == 0
    }
    
    private func visilabsGetDateFormatter(dateFormat: String = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone? = TimeZone(identifier: "UTC"), locale: Locale = Locale(identifier: "en_US")) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = locale
        return dateFormatter
    }
    
    
    
    var arrayGeofenceFetchList: [AnyHashable]?
    
    
    // MARK: - life cycle
    
    //TODO: sharedInstance ı klasik hale getir
    private static var instance: VisilabsGeofenceStatus? = {
        var instance = VisilabsGeofenceStatus()
        return instance
    }()

    /// Singleton for get app status instance.
    class func sharedInstance() -> VisilabsGeofenceStatus? {
        // `dispatch_once()` call was converted to a static variable initializer
        return instance!
    }
}
