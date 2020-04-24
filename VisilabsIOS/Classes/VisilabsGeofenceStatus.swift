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
            if let gts = newValue {
                let serverTime = visilabsParseDate(gts, 0)
                if let serverTime = serverTime {
                    //update local cache time before send request, because this request has same format as others {app_status:..., code:0, value:...}, it will trigger `setGeofenceTimestamp` again.
                    //If fail to get request, clear local cache time in callback handler, make next fetch happen.
                    UserDefaults.standard.set(NSNumber(value: serverTime.timeIntervalSinceReferenceDate), forKey: "APPSTATUS_GEOFENCE_FETCH_TIME")
                    UserDefaults.standard.synchronize()
                    
                    let lastKnownLocation = VisilabsGeofenceLocationManager.sharedInstance().currentGeoLocationValue
                    let lastKnownLocationLatitude = lastKnownLocation!.latitude
                    let lastKnownLocationLongitude = lastKnownLocation!.longitude
                    
                    let request = Visilabs.callAPI()!.buildGeofenceRequest(action: "getlist", latitude: lastKnownLocationLatitude, longitude: lastKnownLocationLongitude, isDwell: false, isEnter: false)
                    
                    let successBlock: ((VisilabsResponse?) -> Void) = { response in
                        var returnedRegions: [VisilabsServerGeofence] = []
                        print("Response: \(response?.rawResponseAsString ?? "nil")")
                        if let parsedArray = response?.responseArray {
                            var i = 0
                            
                            //TODO: burada try catch gerekli mi?
                            
                            for object in parsedArray {
                                if let action = object as? [String : Any?] {
                                    let durationInSeconds = action["dis"] as? Int ?? 0
                                    if let actid = action["actid"] as? Int, let targetEvent = action["trgevt"] as? String, let geoFencesArray = action["geo"] as? [Any?] {
                                        for geo in geoFencesArray {
                                            if let geofence = geo as? [String : Any?] {
                                                let latitude = geofence["lat"] as? Double ?? 0.0 //TODO: default value set etmeli miyim?, yoksa atlamalı mıyım?
                                                let longitude = geofence["long"] as? Double ?? 0.0
                                                let radius = geofence["rds"] as? Double ?? 0.0
                                                let geoID = geofence["id"] as? String ?? "" //TODO: default value set etmeli miyim?, yoksa atlamalı mıyım?
                                                
                                                let visilabsServerGeofence = VisilabsServerGeofence()
                                                visilabsServerGeofence.latitude = latitude
                                                visilabsServerGeofence.longitude = longitude
                                                visilabsServerGeofence.radius = radius
                                                visilabsServerGeofence.isInside = false
                                                visilabsServerGeofence.type = targetEvent;
                                                visilabsServerGeofence.durationInSeconds = durationInSeconds
                                                visilabsServerGeofence.distanceFromCurrentLastKnownLocation = .greatestFiniteMagnitude
                                                
                                                let currentLocation = VisilabsGeofenceLocationManager.sharedInstance().currentGeoLocationValue
                                                let currentLatitude = currentLocation?.latitude ?? 0.0
                                                let currentLongitude = currentLocation?.longitude ?? 0.0

                                                visilabsServerGeofence.distanceFromCurrentLastKnownLocation = self.distanceSquared(forLat1: visilabsServerGeofence.latitude, lng1: visilabsServerGeofence.longitude, lat2: currentLatitude, lng2: currentLongitude)
                                                
                                                //TODO:burada ikinci targetEvent'e gerek var mı? kullanıldığı yeri bul gereksizse kaldır.
                                                visilabsServerGeofence.serverId = "visilabs_\(actid)_\(i)_\(targetEvent)_\(targetEvent)_\(geoID)"
                                                visilabsServerGeofence.suid = "visilabs_\(actid)_\(i)_\(targetEvent)_\(targetEvent)_\(geoID)"
                                                visilabsServerGeofence.title = "visilabs_\(actid)_\(i)_\(targetEvent)_\(targetEvent)_\(geoID)"
                                                returnedRegions.append(visilabsServerGeofence)

                                                if i == 0 {
                                                    print("Current latitude: \(currentLatitude) longitude: \(currentLongitude)")
                                                }

                                                i = i + 1
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            }
                            
                            //Geofence would monitor parent or child, and it's possible `id` not change but latitude/longitude/radius change. When timestamp change, stop monitor existing geofences and start to monitor from new list totally.
                            self.stopMonitorPreviousGeofencesOnly() //server's geofence change, stop monitor all.
                            //Update local cache and memory, start monitor parent.
                            
                            var maxGeofenceCount = Visilabs.callAPI()!.maxGeofenceCount
                            if maxGeofenceCount > 20 || maxGeofenceCount < 0 {
                                maxGeofenceCount = 20
                            }

                            if returnedRegions.count > maxGeofenceCount {
                                let sortDescriptor = NSSortDescriptor(key: "distanceFromCurrentLastKnownLocation", ascending: true)
                                let sortDescriptors = [sortDescriptor]
                                var sortedReturnedRegions = returnedRegions.sorted(by: { (g1, g2) -> Bool in
                                    //TODO:bunu ayarla, test et
                                    //return g1.distanceFromCurrentLastKnownLocation < g2.distanceFromCurrentLastKnownLocation
                                    return false
                                })
                                
                                //TODO: burada kaldık
                                //returnedRegions = (sortedReturnedRegions as NSArray).subarray(with: NSRange(location: 0, length: maxGeofenceCount))
                            }

                            
                        }
                    }
                    
                    let failBlock: ((VisilabsResponse?) -> Void) = { response in }

                    request?.execAsync(withSuccess: successBlock, andFailure: failBlock)
                }
            }
        }
    }
    
    // MARK: - private functions
    
    //TODO: buradaki değerleri VisilabsConfig e aktar, metersPerNauticalMile niye var?
    private func distanceSquared(forLat1 lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let radius = 0.0174532925199433 // 3.14159265358979323846 / 180.0
        let nauticalMilesPerLatitude = 60.00721
        let nauticalMilesPerLongitude = 60.10793
        let metersPerNauticalMile = 1852.00
        let nauticalMilesPerLongitudeDividedByTwo = 30.053965
        // simple pythagorean formula - for efficiency
        //let yDistance = Float((lat2 - lat1) * nauticalMilesPerLatitude)
        //let xDistance = Float((cos(lat1 * radius) + cos(lat2 * radius)) * (lng2 - lng1) * nauticalMilesPerLongitudeDividedByTwo)
        //let res = ((yDistance * yDistance) + (xDistance * xDistance)) * (metersPerNauticalMile * metersPerNauticalMile)
        return Double(0.0)
    }
    
    //DONE
    private func stopMonitorPreviousGeofencesOnly() {
        if let v = VisilabsGeofenceApp.sharedInstance(), let lm = v.locationManager, let mrs = lm.monitoredRegions {
            for mr in mrs {
                //only stop if this region is previous geofence
                if let mri = mr as? CLRegion, mri.identifier.contains("visilabs") {
                    lm.stopMonitorRegion(mri)
                    print("\(mri.identifier) stopped.")
                }
            }
        }
    }
    
    
    //TODO: DispatchSemaphore u kontrol et
    private static let visilabsParseDateFormatter_semaphore = { () -> DispatchSemaphore in
        var formatter_semaphore = DispatchSemaphore(value: 1)
        return formatter_semaphore
    }()

    private func visilabsParseDate(_ input: String, _ offsetSeconds: Int) -> Date? {
        // `dispatch_once()` call was converted to a static variable initializer
        var out: Date? = nil
        if input.count > 0 {
            let a = VisilabsGeofenceStatus.visilabsParseDateFormatter_semaphore.wait(timeout: DispatchTime.distantFuture)
            //TODO: kaldır sonra
            print("VisilabsGeofenceStatus.visilabsParseDateFormatter_semaphore.wait DispatchTimeoutResult : \(a)")
            
            let dateFormatter = visilabsGetDateFormatter()
            out = dateFormatter.date(from: input)
            if out == nil {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                out = dateFormatter.date(from: input)
            }
            if out == nil {
                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                out = dateFormatter.date(from: input)
            }
            if out == nil {
                dateFormatter.dateFormat = "dd/MM/yyyy"
                out = dateFormatter.date(from: input)
            }
            if out == nil {
                dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
                out = dateFormatter.date(from: input)
            }
            if out == nil {
                dateFormatter.dateFormat = "MM/dd/yyyy"
                out = dateFormatter.date(from: input)
            }
            VisilabsGeofenceStatus.visilabsParseDateFormatter_semaphore.signal()
            if offsetSeconds != 0 {
                out = Date(timeInterval: TimeInterval(offsetSeconds), since: out!)
            }
        }
        return out
    }
    
    private func visilabsGetDateFormatter(dateFormat: String = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone? = TimeZone(identifier: "UTC"), locale: Locale = Locale(identifier: "en_US")) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = locale
        return dateFormatter
    }
    
    //TODO: kullanılmıyor.
    //stopMonitorSelfAndChildGeofence
    
    
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


