//
//  VisilabsServerGeofence.swift
//  VisilabsIOS
//
//  Created by Egemen on 22.04.2020.
//

import Foundation
import CoreLocation

class VisilabsServerGeofence: NSObject {
    /// Id from server for this fence. It will be used as `identifier` in `CLCircularRegion` so it must be not duplicated.
    var serverId: String?
    /// Latitude of this fence.
    var latitude = 0.0
    /// Longitude of this fence.
    var longitude = 0.0
    /// Radius of this fence. It will be adjust to not exceed `maximumRegionMonitoringDistance`.
    var radius = 0.0
    
    var distanceFromCurrentLastKnownLocation = 0.0
    /// Internal unique id for object. Optional for leaf geofence, none for inner node.
    var suid: String?
    /// Web console input the title name for this latitude/longitude. Optional for leaf geofence, none for inner node.
    var title: String?
    /// Whether device is inside this geofence.
    var isInside = false
    /// A weak reference to its parent fence.
    weak var parentFence: VisilabsServerGeofence?
    /// Child nodes for parent fence. For child fence it's definity nil; for parent fence it would be nil.
    var arrayNodes: [VisilabsServerGeofence]?
    /// Whether this is actual geofence. Only actual geofence should send logline to server. Inner nodes's `id` starts with "_", actual geofence's `id` is "<id>-<distance>".
    private(set) var isLeaves = false
    
    var type: String?
    var durationInSeconds = 0
    
    /// Use this geofence data to create monitoring region.

    func getGeoRegion() -> CLCircularRegion? {
        return CLCircularRegion(center: CLLocationCoordinate2DMake(latitude, longitude), radius: radius, identifier: serverId!)
    }
    
    /// Compare function.
    func isEqual(toCircleRegion geoRegion: CLCircularRegion?) -> Bool {
        //TODO:print'leri düzelt
        print("geoRegion.identifier: \(geoRegion?.identifier ?? "nil"), self.serverId: \(serverId ?? "nil")" )
        if let sid = serverId, let gid = geoRegion?.identifier  {
            //region only compares by `identifier`.
            return sid.compare(gid) == .orderedSame
        }else{
            return false
        }
        
    }

    //TODO: isLeaves ve arrayNodes kullanılıyor mu kontrol et
    /// Serialize self into a dictionary. Vice verse against `+ (VisilabsServerGeofence *)parseGeofenceFromDict:(NSDictionary *)dict;`.
    func serializeGeofenceToDict() -> [String : Any] {
        var dict: [String : Any] = [:]
        dict["id"] = serverId
        dict["latitude"] = latitude
        dict["longitude"] = longitude
        dict["radius"] = radius
        dict["suid"] = suid ?? ""
        dict["title"] = title ?? ""
        dict["inside"] = isInside
        dict["type"] = type ?? ""
        dict["durationInSeconds"] = durationInSeconds
        
        return dict

        /*
        if isLeaves {
            assert(arrayNodes.count == 0, "Leave node should not have child.")
            return dict
        } else {
            assert(arrayNodes.count > 0, "Inner node should have child.")
            var arrayChild: [AnyHashable] = []
            for childFence in arrayNodes {
                if let serialize = childFence.serializeGeofeneToDict() {
                    arrayChild.append(serialize)
                }
            }
            dict["geofences"] = arrayChild
            return dict
        }
         */
    }

    

    /// Parse an object from dictionary. If parse fail return nil.
    /// - Parameter dict: The dictionary information.
    /// - Returns: If successfully parse return the object; otherwise return nil.
    class func parseGeofence(fromDict dict: [String : Any]) -> VisilabsServerGeofence? {
        let isValidKey = dict.keys.count >= 4 && dict.keys.contains("id") && dict.keys.contains("latitude") && dict.keys.contains("longitude") && dict.keys.contains("radius")
        assert(isValidKey, "Geofence key format invalid: \(dict).")
        if isValidKey{
            let isValidValue = dict["id"] is String && dict["latitude"] is Double && dict["longitude"] is Double && dict["radius"] is Double
            assert(isValidValue, "Geofence value format invalid: \(dict).")
            if isValidValue{
                let geofence = VisilabsServerGeofence()
                geofence.serverId = (dict["id"] as! String)
                geofence.latitude = dict["latitude"] as! Double
                geofence.longitude = dict["longitude"] as! Double
                geofence.radius = dict["radius"] as! Double
                if dict.keys.contains("suid") {
                    geofence.suid = dict["suid"] as? String
                }
                if dict.keys.contains("title") {
                    geofence.title = dict["title"] as? String
                }
                if dict.keys.contains("inside") {
                    geofence.isInside = dict["inside"] as? Bool ?? false
                }
                if dict.keys.contains("type") {
                    geofence.type = dict["type"] as? String
                }
                if dict.keys.contains("durationInSeconds") {
                    geofence.durationInSeconds = dict["durationInSeconds"] as? Int ?? 0 //TODO: default value 0 olması sorun mu
                }
                
                /*TODO: bu kısım gereksizse kaldır.
                let hasGeofence = dict.keys.contains("geofences") && (dict["geofences"] is [AnyHashable]) && (((dict["geofences"] as? [AnyHashable])?.count ?? 0) > 0)
                if geofence.isLeaves {
                    assert(!hasGeofence, "Leave dict should not have child.")
                    return geofence
                } else {
                    assert(hasGeofence, "Inner dict should have child.")
                    if hasGeofence {
                        for dictChild in dict["geofences"] {
                            let childFence = VisilabsServerGeofence.parseGeofence(fromDict: dictChild)
                            if childFence != nil {
                                childFence?.parentFence = geofence
                                if let childFence = childFence {
                                    geofence.arrayNodes.append(childFence)
                                }
                            }
                        }
                    }
                    assert(geofence.arrayNodes.count > 0, "Inner node have none child.")
                    return geofence
                }
                */
                
                return geofence
                
            }
        }
        return nil
    }

    /// Make this object array to string array for store to NSUserDefaults.
    class func serialize(toArrayDict parentFences: [VisilabsServerGeofence]) -> [[String : Any]] {
        var array: [[String : Any]] = []
        for parentFence in parentFences{
            array.append(parentFence.serializeGeofenceToDict())
        }
        return array
    }

    //TODO: bu kullanılmıyor sanırım. gereksizse kaldır.
    /// When read from NSUserDefaults, parse back to object array.
    class func deserialize(toArrayObj arrayDict: [AnyHashable]?) -> [AnyHashable]? {
        return nil
    }


}
