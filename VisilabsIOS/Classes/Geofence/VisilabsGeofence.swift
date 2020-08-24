//
//  VisilabsGeofence.swift
//  VisilabsIOS
//
//  Created by Egemen on 10.06.2020.
//

import Foundation
import CoreLocation



public extension TimeInterval {
    static var oneMinute: TimeInterval { return 60 }
    static var oneHour: TimeInterval { return oneMinute * 60 }
    static var oneDay: TimeInterval { return oneHour * 24 }
    static var oneWeek: TimeInterval { return oneDay * 7 }
    static var oneMonth: TimeInterval { return oneDay * 30 }
    static var oneYear: TimeInterval { return oneDay * 365 }
}

class VisilabsGeofenceEntity: Codable {
    internal init(actId: Int, geofenceId: Int, latitude: Double, longitude: Double, radius: Double, durationInSeconds: Int, targetEvent: String, distanceFromCurrentLastKnownLocation: Double?) {
        self.actId = actId
        self.geofenceId = geofenceId
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.durationInSeconds = durationInSeconds
        self.targetEvent = targetEvent
        self.distanceFromCurrentLastKnownLocation = distanceFromCurrentLastKnownLocation
    }
    var actId: Int
    var geofenceId: Int
    var latitude: Double
    var longitude: Double
    var radius: Double
    var durationInSeconds: Int
    var targetEvent: String
    var distanceFromCurrentLastKnownLocation: Double?
}

class VisilabsGeofenceHistory: Codable {
    internal init(lastKnownLatitude: Double? = nil, lastKnownLongitude: Double? = nil, lastFetchTime: Date? = nil, fetchHistory: [Date : [VisilabsGeofenceEntity]]? = nil, errorHistory:[Date: VisilabsReason]? = nil) {
        self.lastKnownLatitude = lastKnownLatitude
        self.lastKnownLongitude = lastKnownLongitude
        self.lastFetchTime = lastFetchTime
        self.fetchHistory = fetchHistory ?? [Date: [VisilabsGeofenceEntity]]()
        self.errorHistory = errorHistory ??  [Date: VisilabsReason]()
    }
    
    internal init(){
        self.fetchHistory = [Date: [VisilabsGeofenceEntity]]()
        self.errorHistory = [Date: VisilabsReason]()
    }
    var lastKnownLatitude : Double?
    var lastKnownLongitude : Double?
    var lastFetchTime : Date?
    var fetchHistory: [Date: [VisilabsGeofenceEntity]]
    var errorHistory: [Date: VisilabsReason]
}

class VisilabsGeofence {
    
    public static let sharedManager = VisilabsGeofence()
    
    var activeGeofenceList: [VisilabsGeofenceEntity]
    let profile: VisilabsProfile
    var geofenceHistory: VisilabsGeofenceHistory
    
    init?() {
        if let profile = VisilabsDataManager.readVisilabsProfile() {
            self.profile = profile
            self.activeGeofenceList = [VisilabsGeofenceEntity]()
            self.geofenceHistory = VisilabsDataManager.readVisilabsGeofenceHistory()
        }else {
            return nil
        }
    }
    
    func startGeofencing() {
        VisilabsLocationManager.sharedManager.createLocationManager()
    }
    
    func startMonitorGeofences(geofences: [VisilabsGeofenceEntity]) {
        self.activeGeofenceList = Array(sortVisilabsGeofenceEntities(geofences).prefix(self.profile.maxGeofenceCount))
        
        for geofence in self.activeGeofenceList {
            
            var geoRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(geofence.latitude, geofence.longitude), radius: geofence.radius, identifier: "")
        }
    }
    
    private func sortVisilabsGeofenceEntities(_ geofences: [VisilabsGeofenceEntity]) -> [VisilabsGeofenceEntity]{
        return geofences.sorted { (first, second) -> Bool in
            let firstDistance = first.distanceFromCurrentLastKnownLocation ?? Double.greatestFiniteMagnitude
            let secondDistance = second.distanceFromCurrentLastKnownLocation ?? Double.greatestFiniteMagnitude
            return firstDistance < secondDistance
        }
    }
    
    func getGeofenceList(lastKnownLatitude: Double?, lastKnownLongitude: Double?) {
        if profile.geofenceEnabled {
            let user = VisilabsDataManager.readVisilabsUser()
            let geofenceHistory = VisilabsDataManager.readVisilabsGeofenceHistory()
            var props = [String: String]()
            props[VisilabsConstants.ORGANIZATIONID_KEY] = profile.organizationId
            props[VisilabsConstants.PROFILEID_KEY] = profile.profileId
            props[VisilabsConstants.COOKIEID_KEY] = user?.cookieId ?? nil
            props[VisilabsConstants.EXVISITORID_KEY] = user?.exVisitorId ?? nil
            props[VisilabsConstants.ACT_KEY] = VisilabsConstants.GET_LIST
            props[VisilabsConstants.TOKENID_KEY] = user?.tokenId ?? nil
            props[VisilabsConstants.APPID_KEY] = user?.appId ?? nil
            if let lat = lastKnownLatitude, let lon = lastKnownLongitude {
                props[VisilabsConstants.LATITUDE_KEY] = String(format: "%.013f", lat)
                props[VisilabsConstants.LONGITUDE_KEY] = String(format: "%.013f", lon)
            } else if let lat = geofenceHistory.lastKnownLatitude, let lon = geofenceHistory.lastKnownLongitude {
                props[VisilabsConstants.LATITUDE_KEY] = String(format: "%.013f", lat)
                props[VisilabsConstants.LONGITUDE_KEY] = String(format: "%.013f", lon)
            }
            
            for (key, value) in VisilabsPersistence.getParameters() {
               if !key.isEmptyOrWhitespace && !value.isNilOrWhiteSpace && props[key] == nil {
                   props[key] = value
               }
            }
            
            VisilabsRequest.sendGeofenceRequest(properties: props, headers: [String: String](), timeoutInterval: TimeInterval(profile.requestTimeoutInSeconds)) { [lastKnownLatitude, lastKnownLongitude, geofenceHistory] (result, reason) in
                
                if reason != nil {
                    geofenceHistory.lastFetchTime = Date()
                    geofenceHistory.lastKnownLatitude = lastKnownLatitude ?? geofenceHistory.lastKnownLatitude
                    geofenceHistory.lastKnownLongitude = lastKnownLongitude ?? geofenceHistory.lastKnownLongitude
                    if geofenceHistory.errorHistory.count > VisilabsConstants.GEOFENCE_HISTORY_ERROR_MAX_COUNT {
                        let ascendingKeys = Array(geofenceHistory.errorHistory.keys).sorted(by: { $0 < $1 })
                        let keysToBeDeleted = ascendingKeys[0..<(ascendingKeys.count - VisilabsConstants.GEOFENCE_HISTORY_ERROR_MAX_COUNT)]
                        for key in keysToBeDeleted {
                            geofenceHistory.errorHistory[key] = nil
                        }
                    }
                    VisilabsDataManager.saveVisilabsGeofenceHistory(geofenceHistory)
                    return
                }
                
                var fetchedGeofences = [VisilabsGeofenceEntity]()
                if let res = result {
                    for targetingAction in res {
                        if let actionId = targetingAction["actid"] as? Int, let targetEvent = targetingAction["trgevt"] as? String, let durationInSeconds = targetingAction["dis"] as? Int , let geofences = targetingAction["geo"] as? [[String: Any]] {
                            for geofence in geofences {
                                if let geofenceId = geofence["id"] as? Int, let latitude = geofence["lat"] as? Double, let longitude = geofence["long"] as? Double, let radius = geofence["rds"] as? Double {
                                    var distanceFromCurrentLastKnownLocation: Double? = nil
                                    if let lastLat = lastKnownLatitude, let lastLong = lastKnownLongitude {
                                        distanceFromCurrentLastKnownLocation = VisilabsHelper.distanceSquared(lat1: lastLat, lng1: lastLong, lat2: latitude, lng2: longitude)
                                    }
                                    fetchedGeofences.append(VisilabsGeofenceEntity(actId: actionId, geofenceId: geofenceId, latitude: latitude, longitude: longitude, radius: radius, durationInSeconds: durationInSeconds, targetEvent: targetEvent, distanceFromCurrentLastKnownLocation: distanceFromCurrentLastKnownLocation))
                                }
                            }
                        }
                    }
                }
                geofenceHistory.lastFetchTime = Date()
                geofenceHistory.lastKnownLatitude = lastKnownLatitude
                geofenceHistory.lastKnownLongitude = lastKnownLongitude
                geofenceHistory.fetchHistory[Date()] = fetchedGeofences
                
                if geofenceHistory.fetchHistory.count > VisilabsConstants.GEOFENCE_HISTORY_MAX_COUNT {
                    let ascendingKeys = Array(geofenceHistory.fetchHistory.keys).sorted(by: { $0 < $1 })
                    let keysToBeDeleted = ascendingKeys[0..<(ascendingKeys.count - VisilabsConstants.GEOFENCE_HISTORY_MAX_COUNT)]
                    for key in keysToBeDeleted {
                        geofenceHistory.fetchHistory[key] = nil
                    }
                }
                self.geofenceHistory = geofenceHistory
                VisilabsDataManager.saveVisilabsGeofenceHistory(geofenceHistory)
                self.startMonitorGeofences(geofences: fetchedGeofences)
            }
        }
    }
    
    func sendPushNotification(actionId: String, geofenceId: String, isDwell: Bool, isEnter: Bool) {
        let user = VisilabsPersistence.unarchiveUser()
        var props = [String: String]()
        props[VisilabsConstants.ORGANIZATIONID_KEY] = profile.organizationId
        props[VisilabsConstants.PROFILEID_KEY] = profile.profileId
        props[VisilabsConstants.COOKIEID_KEY] = user.cookieId
        props[VisilabsConstants.EXVISITORID_KEY] = user.exVisitorId
        props[VisilabsConstants.ACT_KEY] = VisilabsConstants.PROCESSV2
        props[VisilabsConstants.ACT_ID_KEY] = actionId
        props[VisilabsConstants.TOKENID_KEY] = user.tokenId
        props[VisilabsConstants.APPID_KEY] = user.appId
        props[VisilabsConstants.GEO_ID_KEY] = geofenceId
        
        if isDwell{
            if isEnter {
                props[VisilabsConstants.TRIGGER_EVENT_KEY] = VisilabsConstants.ON_ENTER
            } else {
                props[VisilabsConstants.TRIGGER_EVENT_KEY] = VisilabsConstants.ON_EXIT
            }
        }
        
        for (key, value) in VisilabsPersistence.getParameters() {
           if !key.isEmptyOrWhitespace && !value.isNilOrWhiteSpace && props[key] == nil {
               props[key] = value
           }
        }
        
        VisilabsRequest.sendGeofenceRequest(properties: props, headers: [String: String](), timeoutInterval: TimeInterval(profile.requestTimeoutInSeconds)) { (result, reason) in
            
        }
    }
    
}


class VisilabsGeofence2 : NSObject, CLLocationManagerDelegate {
    
    
    
    
    
    internal var lastLocationManagerCreated: Date?
    internal var maximumDesiredLocationAccuracy: CLLocationAccuracy = 30 // TODO: burada 30 yerine başka değer vermek doğru mu? önceden kCLLocationAccuracyHundredMeters kullanıyorduk.
    let organizationId: String
    let siteId: String
    
    lazy var locationManager: CLLocationManager = {
        lastLocationManagerCreated = Date()

        let manager = CLLocationManager()
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = self.maximumDesiredLocationAccuracy
        manager.pausesLocationUpdatesAutomatically = false
        
        manager.delegate = self

        return manager
    }()
    
    init(organizationId: String, siteId: String) {
        self.organizationId = organizationId
        self.siteId = siteId
    }
    
    
    // MARK: - iOS bug workaround

    // to work around an iOS 13.3 bug that results in the location manager "dying", no longer receiving location updates
    public func recreateTheLocationManager() {

        // don't recreate location managers too often
        //if let last = lastLocationManagerCreated, last.age! < .oneMinute { return }

        if let llmc = lastLocationManagerCreated, llmc > Date().addingTimeInterval(-TimeInterval.oneMinute) {
            return
        }
        
        lastLocationManagerCreated = Date()

        let freshManager = CLLocationManager()
        freshManager.distanceFilter = locationManager.distanceFilter
        freshManager.desiredAccuracy = locationManager.desiredAccuracy
        freshManager.pausesLocationUpdatesAutomatically = false
        freshManager.allowsBackgroundLocationUpdates = true
        freshManager.delegate = self

        // hand over to new manager
        freshManager.startUpdatingLocation()
        locationManager.stopUpdatingLocation()
        locationManager = freshManager

        VisilabsLogger.warn("Recreated the LocationManager")
    }
    
}
