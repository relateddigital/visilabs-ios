//
//  VisilabsLocationManager.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.08.2020.
//

import Foundation
import UIKit
import CoreLocation

let kIdentifierPrefix = "visilabs_"
let kBubbleGeofenceIdentifierPrefix = "visilabs_bubble_"
let kSyncGeofenceIdentifierPrefix = "visilabs_geofence_"

class VisilabsLocationManager: NSObject {
    
    typealias VLogger = VisilabsLogger
    
    let options = VisilabsGeofenceOptions()
    var locMan: CLLocationManager
    var lpLocMan: CLLocationManager
    var lastKnownCLAuthorizationStatus : CLAuthorizationStatus?
    
    var visilabsProfile: VisilabsProfile?
    var geofenceEnabled = false
    var askLocationPermmissionAtStart = false
    
    private var started = false
    private var startedInterval = 0
    private var sending = false
    private var fetching = false
    private var timer: Timer?
    
    var activeGeofenceList = [VisilabsGeofenceEntity]()
    var lastGeofenceFetchTime = Date(timeIntervalSince1970: 0)
    var lastSuccessfulGeofenceFetchTime = Date(timeIntervalSince1970: 0)
    var geofenceHistory: VisilabsGeofenceHistory
    
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locMan.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
    
    override init() {
        locMan = CLLocationManager()
        lpLocMan = CLLocationManager()
        geofenceHistory = VisilabsPersistence.readVisilabsGeofenceHistory()
        super.init()
        locMan.desiredAccuracy = options.desiredCLLocationAccuracy
        locMan.distanceFilter = kCLDistanceFilterNone
        locMan.allowsBackgroundLocationUpdates = options.locationBackgroundMode && getAuthorizationStatus() == .authorizedAlways
        lpLocMan.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        lpLocMan.distanceFilter = 3000
        lpLocMan.allowsBackgroundLocationUpdates = options.locationBackgroundMode
        locMan.delegate = self
        lpLocMan.delegate = self
        VisilabsGeofenceState.setStopped(false)
        updateTracking(location: nil, fromInit: true)
        if let profile = VisilabsPersistence.readVisilabsProfile() {
            self.visilabsProfile = profile
            if !Visilabs.initializeCalled() {
                Visilabs.createAPI()
            }
            VisilabsHelper.setEndpoints(dataSource: profile.dataSource)
            geofenceEnabled = profile.geofenceEnabled
            askLocationPermmissionAtStart = profile.askLocationPermmissionAtStart
            if geofenceEnabled {
                startGeofencing(fromInit: true)
            }
            
        }
    }
    
    deinit {
        locMan.delegate = nil
        lpLocMan.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func startGeofencing(fromInit: Bool) {
        if askLocationPermmissionAtStart {
            requestLocationPermissions()
        }
        
        let authorizationStatus = VisilabsGeofenceState.locationAuthorizationStatus
        if !(authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
            return
        }
        VisilabsGeofenceState.setGeofenceEnabled(true)
        updateTracking(location: nil, fromInit: fromInit)
        if let geoEntities = geofenceHistory.fetchHistory.sorted(by: { $0.key > $1.key }).first?.value {
            replaceSyncedGeofences(geoEntities)
        }
        fetchGeofences()
    }
    
    func stopGeofence() {
        VisilabsGeofenceState.setGeofenceEnabled(false)
        updateTracking(location: nil, fromInit: false)
    }
    
    func startUpdates(_ interval: Int) {
        if !started || interval != startedInterval {
            VLogger.info("Starting geofence timer | interval = \(interval)")
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(shutDown), object: nil)
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { [self] _ in
                VLogger.info("Geofence timer fired")
                self.requestLocation()
            }
            lpLocMan.startUpdatingLocation()
            started = true
            startedInterval = interval
        } else {
            //VLogger.info("Already started geofence timer")
        }
    }
    
    private func stopUpdates() {
        guard let timer = timer else {
            return
        }
        VLogger.info("Stopping geofence timer")
        timer.invalidate()
        started = false
        startedInterval = 0
        if !sending {
            let delay: TimeInterval = VisilabsGeofenceState.getGeofenceEnabled() ? 10 : 0
            VLogger.info("Scheduling geofence shutdown")
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.shutDown()
            }
        }
    }
    
    @objc func shutDown() {
        VLogger.info("Shutting geofence down")
        lpLocMan.stopUpdatingLocation()
    }
    
    func requestLocation() {
        VLogger.info("Requesting location")
        locMan.requestLocation()
    }
    
    func updateTracking(location: CLLocation?, fromInit: Bool) {
        DispatchQueue.main.async {
            //VLogger.info("Updating geofence tracking | options = \(self.options); location = \(String(describing: location))")
            
            if VisilabsGeofenceState.getGeofenceEnabled() {
                self.locMan.allowsBackgroundLocationUpdates = self.options.locationBackgroundMode && self.getAuthorizationStatus() == .authorizedAlways
                self.locMan.pausesLocationUpdatesAutomatically = false
                
                self.lpLocMan.allowsBackgroundLocationUpdates = self.options.locationBackgroundMode
                self.lpLocMan.pausesLocationUpdatesAutomatically = false
                
                self.locMan.desiredAccuracy = self.options.desiredCLLocationAccuracy
                
                if #available(iOS 11, *) {
                    self.lpLocMan.showsBackgroundLocationIndicator = self.options.showBlueBar
                }
                
                let startUpdates = self.options.showBlueBar || self.getAuthorizationStatus() == .authorizedAlways
                let stopped = VisilabsGeofenceState.getStopped()
                if stopped {
                    
                    if self.options.desiredStoppedUpdateInterval == 0 {
                        self.stopUpdates()
                    } else if startUpdates {
                        self.startUpdates(self.options.desiredStoppedUpdateInterval)
                    }
                    
                    if self.options.useStoppedGeofence, let location = location {
                        self.replaceBubbleGeofence(location, radius: self.options.stoppedGeofenceRadius)
                    } else {
                        self.removeBubbleGeofence()
                    }
                    
                } else {
                    
                    if self.options.desiredMovingUpdateInterval == 0 {
                        self.stopUpdates()
                    } else if startUpdates {
                        self.startUpdates(self.options.desiredMovingUpdateInterval)
                    }
                    if self.options.useMovingGeofence, let location = location {
                        self.replaceBubbleGeofence(location, radius: self.options.movingGeofenceRadius)
                    } else {
                        self.removeBubbleGeofence()
                    }
                }
                
                if !self.options.syncGeofences {
                    self.removeSyncedGeofences()
                }
                if self.options.useSignificantLocationChanges {
                    self.locMan.startMonitoringSignificantLocationChanges()
                }
                
            } else {
                self.stopUpdates()
                self.removeAllRegions()
                if !fromInit {
                    self.locMan.stopMonitoringSignificantLocationChanges()
                }
            }
            
        }
    }
    
    func replaceBubbleGeofence(_ location: CLLocation, radius: Int) {
        removeBubbleGeofence()
        if !VisilabsGeofenceState.getGeofenceEnabled() {
            return
        }
        locMan.startMonitoring(for: CLCircularRegion(center: location.coordinate,
                                                     radius: CLLocationDistance(radius),
                                                     identifier: "\(kBubbleGeofenceIdentifierPrefix)\(UUID().uuidString)"))
    }
    
    func removeBubbleGeofence() {
        for region in locMan.monitoredRegions {
            if region.identifier.hasPrefix(kBubbleGeofenceIdentifierPrefix) {
                locMan.stopMonitoring(for: region)
            }
        }
    }
    
    func replaceSyncedGeofences(_ geoEntities: [VisilabsGeofenceEntity]) {
        
        
        removeSyncedGeofences()
        if !VisilabsGeofenceState.getGeofenceEnabled() || !options.syncGeofences {
            return
        }
        
        let newGeoEntities = sortAndTakeVisilabsGeofenceEntitiesToMonitor(geoEntities)
        
        for geoEnt in newGeoEntities {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: geoEnt.latitude,
                                                                         longitude: geoEnt.longitude),
                                          radius: CLLocationDistance(geoEnt.radius),
                                          identifier: geoEnt.identifier)
            locMan.startMonitoring(for: region)
            VLogger.info("Synced geofence | lat = \(geoEnt.latitude); lon = \(geoEnt.longitude); rad = \(geoEnt.radius); id \(geoEnt.identifier)")
        }
    }
    
    func removeSyncedGeofences() {
        for region in locMan.monitoredRegions {
            if region.identifier.hasPrefix(kSyncGeofenceIdentifierPrefix) {
                locMan.stopMonitoring(for: region)
            }
        }
    }
    
    func removeAllRegions() {
        for region in locMan.monitoredRegions {
            if region.identifier.hasPrefix(kIdentifierPrefix) {
                locMan.stopMonitoring(for: region)
            }
        }
    }

}

extension VisilabsLocationManager {
    
    func handleLocation(_ location: CLLocation, source: LocationSource, region: CLRegion? = nil) {
        //VLogger.info("Handling location | source = \(source); location = \(String(describing: location))")
        
        if !VisilabsGeofenceState.validLocation(location) {
            VLogger.info("Invalid location | source = \(source); location = \(String(describing: location))")
            return
        }
        
        let options = self.options
        let wasStopped = VisilabsGeofenceState.getStopped()
        var stopped = false
        
        let force = source == .foregroundLocation || source == .manualLocation
        
        if wasStopped && !force && location.horizontalAccuracy >= 1000 && options.desiredAccuracy != .low {
            VLogger.info("Skipping location: inaccurate | accuracy = \(location.horizontalAccuracy)")
            updateTracking(location: location, fromInit: false)
            return
        }
        
        if !force && !VisilabsGeofenceState.getGeofenceEnabled() {
            VLogger.info("Skipping location: not tracking")
            return
        }
        
        var distance = CLLocationDistanceMax
        var duration: TimeInterval = 0
        if options.stopDistance > 0, options.stopDuration > 0 {
            
            var lastMovedLocation: CLLocation?
            var lastMovedAt: Date?
            
            if VisilabsGeofenceState.getLastMovedLocation() == nil {
                lastMovedLocation = location
                VisilabsGeofenceState.setLastMovedLocation(location)
            }
            
            if VisilabsGeofenceState.getLastMovedAt() == nil {
                lastMovedAt = location.timestamp
                VisilabsGeofenceState.setLastMovedAt(location.timestamp)
            }
            
            if !force, let lastMovedAt = lastMovedAt, lastMovedAt.timeIntervalSince(location.timestamp) > 0 {
                VLogger.info("Skipping location: old | lastMovedAt = \(lastMovedAt); location.timestamp = \(location.timestamp)")
                return
            }
            
            if let lastMovedLocation = lastMovedLocation, let lastMovedAt = lastMovedAt {
                distance = location.distance(from: lastMovedLocation)
                duration = location.timestamp.timeIntervalSince(lastMovedAt)
                if duration == 0 {
                    duration = -location.timestamp.timeIntervalSinceNow
                }
                stopped = Int(distance) <= options.stopDistance && Int(duration) >= options.stopDuration
                VLogger.info("Calculating stopped | stopped = \(stopped); distance = \(distance); duration = \(duration); location.timestamp = \(location.timestamp); lastMovedAt = \(lastMovedAt)")
                
                if Int(distance) > options.stopDistance {
                    VisilabsGeofenceState.setLastMovedLocation(location)
                    if !stopped {
                        VisilabsGeofenceState.setLastMovedAt(location.timestamp)
                    }
                }
            }
        } else {
            stopped = force
        }
        
        let justStopped = stopped && !wasStopped
        VisilabsGeofenceState.setStopped(stopped)
        VisilabsGeofenceState.setLastLocation(location)
        
        if source != .manualLocation {
            updateTracking(location: location, fromInit: false)
        }
        
        var sendLocation = location
        
        let lastFailedStoppedLocation = VisilabsGeofenceState.getLastFailedStoppedLocation()
        var replayed = false
        if options.replay == .stops,
           let lastFailedStoppedLocation = lastFailedStoppedLocation,
           !justStopped {
            sendLocation = lastFailedStoppedLocation
            stopped = true
            replayed = true
            VisilabsGeofenceState.setLastFailedStoppedLocation(nil)
            VLogger.info("Replaying location | location = \(sendLocation); stopped = \(stopped)")
        }
        let lastSentAt = VisilabsGeofenceState.getLastSentAt()
        let ignoreSync = lastSentAt == nil || justStopped || replayed
        let now = Date()
        var lastSyncInterval: TimeInterval?
        
        if let lastSentAt = lastSentAt {
            lastSyncInterval = now.timeIntervalSince(lastSentAt)
        }
        
        if !ignoreSync {
            if !force && stopped && wasStopped && Int(distance) <= options.stopDistance && (options.desiredStoppedUpdateInterval == 0 || options.syncLocations != .syncAll) {
                //VLogger.info("Skipping sync: already stopped | stopped = \(stopped); wasStopped = \(wasStopped)")
                return
            }
            if Int(lastSyncInterval ?? 0) < options.desiredSyncInterval {
                //VLogger.info("Skipping sync: desired sync interval | desiredSyncInterval = \(options.desiredSyncInterval); lastSyncInterval = \(lastSyncInterval ?? 0)")
            }
            if !force && !justStopped && Int(lastSyncInterval ?? 0) < 1 {
                //VLogger.info("Skipping sync: rate limit | justStopped = \(justStopped); lastSyncInterval = \(String(describing: lastSyncInterval))")
                return
            }
            if options.syncLocations == .syncNone {
                //VLogger.info("Skipping sync: sync mode | sync = \(options.syncLocations)")
                return
            }
        }
        
        VisilabsGeofenceState.setLastSentAt()
        
        if source == .foregroundLocation {
            return
        }
        self.sendLocation(sendLocation, stopped: stopped, source: source, replayed: replayed, region: region)
    }
    
    func sendLocation(_ location: CLLocation, stopped: Bool, source: LocationSource, replayed: Bool, region: CLRegion? = nil) {
        //VLogger.info("Sending location | source = \(source); location = \(location); stopped = \(stopped); replayed = \(replayed)")
        sending = true
        
        if [LocationSource.geofenceEnter, LocationSource.geofenceExit].contains(source) {
            guard let region = region, region.identifier.hasPrefix(kIdentifierPrefix) else {
                sending = false
                return
            }
            
            let identifier = region.identifier
            
            let idArr = identifier.components(separatedBy: "_")
            guard idArr.count >= 4, let actId = Int(idArr[2]), let geoId = Int(idArr[3]) else {
                sending = false
                return
            }
            let targetEvent = idArr[4]
            
            guard (source == .geofenceEnter && targetEvent == VisilabsConstants.onExit)
            || (source == .geofenceExit && targetEvent == VisilabsConstants.onEnter) else {
                sending = false
                return
            }
            
            var isDwell = false
            var isEnter = false
            
            if source == .geofenceEnter, targetEvent == VisilabsConstants.onEnter {
                isDwell = false
                isEnter = true
            } else if source == .geofenceEnter, targetEvent == VisilabsConstants.dwell {
                isDwell = true
                isEnter = true
            } else if source == .geofenceExit, targetEvent == VisilabsConstants.onExit {
                isDwell = false
                isEnter = false
            } else if source == .geofenceExit, targetEvent == VisilabsConstants.dwell {
                isDwell = true
                isEnter = false
            }
            
            sendPushNotification(actId: actId,
                                 geoId: geoId,
                                 isDwell: isDwell,
                                 isEnter: isEnter) { [weak self] response in
                self?.sending = false
                self?.updateTracking(location: location, fromInit: false)
            }
            
        } else {
            sending = false
            fetchGeofences()
        }
    }
    
    func fetchGeofences() {
        if fetching {
            return
        }
        fetching = true
        let lat = locMan.location?.coordinate.latitude
        let lon = locMan.location?.coordinate.longitude
        getGeofenceList(lastKnownLatitude: lat,
                        lastKnownLongitude: lon) { [weak self] (response, fetchedGeofences) in
            if response {
                self?.replaceSyncedGeofences(fetchedGeofences)
            }
            self?.fetching = false
            self?.updateTracking(location: self?.locMan.location, fromInit: false)
        }
    }
    
    func requestLocationPermissions() {
        var status: CLAuthorizationStatus = .notDetermined
        if #available(iOS 14.0, *) {
            status = locMan.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        if #available(iOS 13.4, *) {
            if status == .notDetermined {
                locMan.requestWhenInUseAuthorization()
            } else if status == .authorizedWhenInUse {
                locMan.requestAlwaysAuthorization()
            }
        } else {
            locMan.requestAlwaysAuthorization()
        }
    }
}

// MARK: - Permissions
extension VisilabsLocationManager {
    
    func sendLocationPermission(status: CLAuthorizationStatus? = nil, geofenceEnabled: Bool = true) {
        let authorizationStatus = status ?? VisilabsGeofenceState.locationServiceStateStatus
        if authorizationStatus != lastKnownCLAuthorizationStatus {
            var properties = [String: String]()
            properties[VisilabsConstants.locationPermissionReqKey] = authorizationStatus.queryStringValue
            Visilabs.callAPI().customEvent(VisilabsConstants.omEvtGif, properties: properties)
            lastKnownCLAuthorizationStatus = authorizationStatus
        }
        if !geofenceEnabled {
            self.geofenceEnabled = false
            stopUpdates()
        }
    }
}

// MARK: - Request
extension VisilabsLocationManager {
    
    func sendPushNotification(actId: Int,
                              geoId: Int,
                              isDwell: Bool,
                              isEnter: Bool,
                              completion: @escaping ((_ response: Bool) -> Void)) {
        
        guard let profile = self.visilabsProfile else {
            return
        }
        
        let user = VisilabsPersistence.unarchiveUser()
        var props = [String: String]()
        props[VisilabsConstants.organizationIdKey] = profile.organizationId
        props[VisilabsConstants.profileIdKey] = profile.profileId
        props[VisilabsConstants.cookieIdKey] = user.cookieId
        props[VisilabsConstants.exvisitorIdKey] = user.exVisitorId
        props[VisilabsConstants.actKey] = VisilabsConstants.processV2
        props[VisilabsConstants.actidKey] = "\(actId)"
        props[VisilabsConstants.tokenIdKey] = user.tokenId
        props[VisilabsConstants.appidKey] = user.appId
        props[VisilabsConstants.geoIdKey] = "\(geoId)"
        
        props[VisilabsConstants.nrvKey] = String(user.nrv)
        props[VisilabsConstants.pvivKey] = String(user.pviv)
        props[VisilabsConstants.tvcKey] = String(user.tvc)
        props[VisilabsConstants.lvtKey] = user.lvt

        if isDwell {
            props[VisilabsConstants.triggerEventKey] = isEnter ? VisilabsConstants.onEnter : VisilabsConstants.onExit
        }

        for (key, value) in VisilabsPersistence.readTargetParameters() {
           if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
               props[key] = value
           }
        }
        VLogger.info("Geofence Triggerred: actionId: \(actId) geofenceid: \(geoId)")
        VisilabsRequest.sendGeofenceRequest(properties: props,
                                            headers: [String: String](),
                                            timeoutInterval: profile.requestTimeoutInterval) { (_, error) in
            if let error = error {
                VLogger.error("Geofence Push Send Error: \(error)")
            }
            completion(true)
        }
    }
    
    func getGeofenceList(lastKnownLatitude: Double?,
                         lastKnownLongitude: Double?,
                         completion: @escaping ((_ response: Bool, _ fetchedGeofences: [VisilabsGeofenceEntity]) -> Void)) {
        
        guard let profile = visilabsProfile else {
            completion(false, [VisilabsGeofenceEntity]())
            return
        }
        
        if profile.geofenceEnabled, VisilabsGeofenceState.locationServicesEnabledForDevice, VisilabsGeofenceState.locationServiceEnabledForApplication {
            let now = Date()
            let timeInterval = now.timeIntervalSince1970 - self.lastGeofenceFetchTime.timeIntervalSince1970
            if timeInterval < VisilabsConstants.geofenceFetchTimeInterval {
                completion(false, [VisilabsGeofenceEntity]())
                return
            }

            self.lastGeofenceFetchTime = now
            let user = VisilabsPersistence.unarchiveUser()
            let geofenceHistory = VisilabsPersistence.readVisilabsGeofenceHistory()
            var props = [String: String]()
            props[VisilabsConstants.organizationIdKey] = profile.organizationId
            props[VisilabsConstants.profileIdKey] = profile.profileId
            props[VisilabsConstants.cookieIdKey] = user.cookieId
            props[VisilabsConstants.exvisitorIdKey] = user.exVisitorId
            props[VisilabsConstants.actKey] = VisilabsConstants.getList
            props[VisilabsConstants.tokenIdKey] = user.tokenId
            props[VisilabsConstants.appidKey] = user.appId
            props[VisilabsConstants.channelKey] = profile.channel
            if let lat = lastKnownLatitude, let lon = lastKnownLongitude {
                props[VisilabsConstants.latitudeKey] = String(format: "%.013f", lat)
                props[VisilabsConstants.longitudeKey] = String(format: "%.013f", lon)
            } else if let lat = geofenceHistory.lastKnownLatitude, let lon = geofenceHistory.lastKnownLongitude {
                props[VisilabsConstants.latitudeKey] = String(format: "%.013f", lat)
                props[VisilabsConstants.longitudeKey] = String(format: "%.013f", lon)
            }
            
            props[VisilabsConstants.nrvKey] = String(user.nrv)
            props[VisilabsConstants.pvivKey] = String(user.pviv)
            props[VisilabsConstants.tvcKey] = String(user.tvc)
            props[VisilabsConstants.lvtKey] = user.lvt

            for (key, value) in VisilabsPersistence.readTargetParameters() {
               if !key.isEmptyOrWhitespace && !value.isEmptyOrWhitespace && props[key] == nil {
                   props[key] = value
               }
            }

            VisilabsRequest.sendGeofenceRequest(properties: props,
                                                headers: [String: String](),
                                            timeoutInterval: profile.requestTimeoutInterval) {
                [lastKnownLatitude, lastKnownLongitude, geofenceHistory, now] (result, error) in

                if error != nil {
                    self.geofenceHistory.lastKnownLatitude = lastKnownLatitude ?? geofenceHistory.lastKnownLatitude
                    self.geofenceHistory.lastKnownLongitude = lastKnownLongitude ?? geofenceHistory.lastKnownLongitude
                    if self.geofenceHistory.errorHistory.count > VisilabsConstants.geofenceHistoryErrorMaxCount {
                        let ascendingKeys = Array(self.geofenceHistory.errorHistory.keys).sorted(by: { $0 < $1 })
                        let keysToBeDeleted = ascendingKeys[0..<(ascendingKeys.count
                                            - VisilabsConstants.geofenceHistoryErrorMaxCount)]
                        for key in keysToBeDeleted {
                            self.geofenceHistory.errorHistory[key] = nil
                        }
                    }
                    VisilabsPersistence.saveVisilabsGeofenceHistory(self.geofenceHistory)
                    completion(false, [VisilabsGeofenceEntity]())
                    return
                }
                (self.lastSuccessfulGeofenceFetchTime, self.geofenceHistory.lastFetchTime) = (now, now)
                var fetchedGeofences = [VisilabsGeofenceEntity]()
                if let res = result {
                    for targetingAction in res {
                        if let actionId = targetingAction["actid"] as? Int,
                           let targetEvent = targetingAction["trgevt"] as? String,
                           let durationInSeconds = targetingAction["dis"] as? Int,
                           let geofences = targetingAction["geo"] as? [[String: Any]] {

                            for geofence in geofences {
                                if let geofenceId = geofence["id"] as? Int,
                                   let latitude = geofence["lat"] as? Double,
                                   let longitude = geofence["long"] as? Double,
                                   let radius = geofence["rds"] as? Double {
                                    var distanceFromCurrentLastKnownLocation: Double?
                                    if let lastLat = lastKnownLatitude, let lastLong = lastKnownLongitude {
                            distanceFromCurrentLastKnownLocation = VisilabsHelper.distanceSquared(lat1: lastLat,
                                                                            lng1: lastLong,
                                                                            lat2: latitude,
                                                                            lng2: longitude)
                                    }
                                    fetchedGeofences.append(VisilabsGeofenceEntity(actId: actionId,
                                                                                   geofenceId: geofenceId,
                                                                                   latitude: latitude,
                                                                                   longitude: longitude,
                                                                                   radius: radius,
                                                                                   durationInSeconds: durationInSeconds,
                                                                                   targetEvent: targetEvent,
                                        distanceFromCurrentLastKnownLocation: distanceFromCurrentLastKnownLocation))
                                }
                            }
                        }
                    }
                }
                self.geofenceHistory.lastFetchTime = now
                self.geofenceHistory.lastKnownLatitude = lastKnownLatitude
                self.geofenceHistory.lastKnownLongitude = lastKnownLongitude
                self.geofenceHistory.fetchHistory[now] = fetchedGeofences
                if self.geofenceHistory.fetchHistory.count > VisilabsConstants.geofenceHistoryMaxCount {
                    let ascendingKeys = Array(self.geofenceHistory.fetchHistory.keys).sorted(by: { $0 < $1 })
                    let keysToBeDeleted = ascendingKeys[0..<(ascendingKeys.count
                                                            - VisilabsConstants.geofenceHistoryMaxCount)]
                    for key in keysToBeDeleted {
                        self.geofenceHistory.fetchHistory[key] = nil
                    }
                }
                VisilabsPersistence.saveVisilabsGeofenceHistory(self.geofenceHistory)
                completion(true, fetchedGeofences)
            }
        }
    }
    
    private func sortAndTakeVisilabsGeofenceEntitiesToMonitor(_ geofences: [VisilabsGeofenceEntity])
                                                                    -> [VisilabsGeofenceEntity] {
        let geofencesSortedAscending = geofences.sorted { (first, second) -> Bool in
            let firstDistance = first.distanceFromCurrentLastKnownLocation ?? Double.greatestFiniteMagnitude
            let secondDistance = second.distanceFromCurrentLastKnownLocation ?? Double.greatestFiniteMagnitude
            return firstDistance < secondDistance
        }
        var geofencesToMonitor = [VisilabsGeofenceEntity]()
        for geofence in geofencesSortedAscending {
            if geofencesToMonitor.count == visilabsProfile?.maxGeofenceCount {
                break
            }
            geofencesToMonitor.append(geofence)
        }
        return [VisilabsGeofenceEntity](geofencesToMonitor)
    }
}



// MARK: - CLLocationManagerDelegate
extension VisilabsLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            handleLocation(location, source: .backgroundLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let location = manager.location, region.identifier.hasPrefix(kIdentifierPrefix) else {
            return
        }
        handleLocation(location, source: .geofenceEnter, region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let location = manager.location, region.identifier.hasPrefix(kIdentifierPrefix) else {
            return
        }
        handleLocation(location, source: .geofenceExit, region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        VLogger.info("CLLocationManager didChangeAuthorization: status: \(status.string)")
        sendLocationPermission(status: status)
        startGeofencing(fromInit: true)
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        VLogger.info("CLLocationManager didChangeAuthorization: status: \(manager.authorizationStatus.string)")
        sendLocationPermission(status: manager.authorizationStatus)
        startGeofencing(fromInit: true)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        VLogger.error("CLLocationManager didFailWithError : \(error.localizedDescription)")
    }
    
    
}
