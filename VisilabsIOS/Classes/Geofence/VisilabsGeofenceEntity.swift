//
//  VisilabsGeofenceEntity.swift
//  VisilabsIOS
//
//  Created by Egemen on 1.09.2020.
//

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
        self.identifier = "visilabs_\(self.actId)_\(self.geofenceId)_\(self.targetEvent)"
    }
    var actId: Int
    var geofenceId: Int
    var latitude: Double
    var longitude: Double
    var radius: Double
    var durationInSeconds: Int
    var targetEvent: String
    var distanceFromCurrentLastKnownLocation: Double?
    let identifier: String
}
