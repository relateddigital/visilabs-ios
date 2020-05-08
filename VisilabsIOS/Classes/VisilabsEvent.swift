//
//  VisilabsEvent.swift
//  VisilabsIOS
//
//  Created by Egemen on 7.05.2020.
//

import Foundation

func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

class VisilabsEvent {
    let organizationId: String
    let siteId: String
    let dataSource: String
    let visilabsUser: VisilabsUser
    
    let lock: VisilabsReadWriteLock

    init(organizationId: String, siteId: String, dataSource: String, visilabsUser: VisilabsUser, lock: VisilabsReadWriteLock) {
        self.organizationId = organizationId
        self.siteId = siteId
        self.dataSource = dataSource
        self.visilabsUser = visilabsUser
        self.lock = lock
    }
    
    func track(event: String, properties: Properties, eventsQueue: Queue,
               superProperties: InternalProperties,
               distinctId: String,
               anonymousId: String?,
               userId: String?,
               hadPersistedDistinctId: Bool?,
               epochInterval: Double) -> (eventsQueque: Queue, timedEvents: InternalProperties, properties: InternalProperties) {
        var ev = event
        let epochSeconds = Int(round(epochInterval))
        var p = InternalProperties()

        p["token"] = apiToken

        p["distinct_id"] = distinctId
        if anonymousId != nil {
            p["$device_id"] = anonymousId
        }
        if userId != nil {
            p["$user_id"] = userId
        }

        
        p += superProperties
        p += properties

        var trackEvent: InternalProperties = ["event": ev, "properties": p]
        var shadowEventsQueue = eventsQueue
        
        shadowEventsQueue.append(trackEvent)
        if shadowEventsQueue.count > QueueConstants.queueSize {
            shadowEventsQueue.remove(at: 0)
        }
        
        return (shadowEventsQueue, shadowTimedEvents, p)
    }

    func registerSuperProperties(_ properties: Properties,
                                 superProperties: InternalProperties) -> InternalProperties {
        var updatedSuperProperties = superProperties
        updatedSuperProperties += properties
        return updatedSuperProperties
    }

    func registerSuperPropertiesOnce(_ properties: Properties, superProperties: InternalProperties, defaultValue: MixpanelType?) -> InternalProperties {

        var updatedSuperProperties = superProperties
        _ = properties.map() {
            let val = updatedSuperProperties[$0.key]
            if val == nil ||
                (defaultValue != nil && (val as? NSObject == defaultValue as? NSObject)) {
                updatedSuperProperties[$0.key] = $0.value
            }
        }
        
        return updatedSuperProperties
    }

    func unregisterSuperProperty(_ propertyName: String,
                                 superProperties: InternalProperties) -> InternalProperties {
        
        var updatedSuperProperties = superProperties
        updatedSuperProperties.removeValue(forKey: propertyName)
        return updatedSuperProperties
    }

    func clearSuperProperties(_ superProperties: InternalProperties) -> InternalProperties {
        var updatedSuperProperties = superProperties
        updatedSuperProperties.removeAll()
        return updatedSuperProperties
    }
    
    func updateSuperProperty(_ update: (_ superProperties: inout InternalProperties) -> Void, superProperties: inout InternalProperties) {
        update(&superProperties)
    }

    func time(event: String, timedEvents: InternalProperties, startTime: Double) -> InternalProperties {

        var updatedTimedEvents = timedEvents

        //updatedTimedEvents[event] = startTime
        return updatedTimedEvents
    }

    func clearTimedEvents(_ timedEvents: InternalProperties) -> InternalProperties {
        var updatedTimedEvents = timedEvents
        updatedTimedEvents.removeAll()
        return updatedTimedEvents
    }
}
