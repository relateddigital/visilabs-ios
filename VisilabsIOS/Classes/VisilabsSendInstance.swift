//
//  VisilabsSendInstance.swift
//  VisilabsIOS
//
//  Created by Egemen on 11.05.2020.
//

import Foundation

protocol VisilabsSendDelegate {
    func send(completion: (() -> Void)?)
    func updateNetworkActivityIndicator(_ on: Bool)
}


//TODO: lock kullanılımıyor sanki, kaldırılabilir
class VisilabsSendInstance: AppLifecycle {
    let lock: VisilabsReadWriteLock
    var delegate: VisilabsSendDelegate?
    
    
    required init(lock: VisilabsReadWriteLock) {
        self.lock = lock
    }
    
    //TODO: burada internet bağlantısı kontrolü yapmaya gerek var mı?
    func sendEventsQueue(_ eventsQueue: Queue, visilabsCookie: VisilabsCookie) -> Queue? {
        var mutableQueue = eventsQueue
        
        let range = 0..<mutableQueue.count
        
        for i in range {
            var event = mutableQueue[0]
            VisilabsLogger.debug(message: "Sending event")
            VisilabsLogger.debug(message: event)
            let headers = prepareHeaders()
            
            let semaphore = DispatchSemaphore(value: 0)
            delegate?.updateNetworkActivityIndicator(true)
            VisilabsEventRequest.sendRequest(properties: event, headers: headers, completion: <#T##(Bool) -> Void#>)
    
            
        }
        
        
        while !mutableQueue.isEmpty {
            VisilabsLogger.debug(message: "Sending batch of data")
            VisilabsLogger.debug(message: batch as Any)
        }
        
        
        
        
        let (automaticEventsQueue, eventsQueue) = orderAutomaticEvents(queue: eventsQueue,
                                                        automaticEventsEnabled: automaticEventsEnabled)
        var mutableEventsQueue = flushQueue(type: .events, queue: eventsQueue)
        if let automaticEventsQueue = automaticEventsQueue {
            mutableEventsQueue?.append(contentsOf: automaticEventsQueue)
        }
        return mutableEventsQueue
    }
    
    private func prepareHeaders() -> [String:String] {
        return [String:String]()
    }
    
    
    func flushQueueInBatches(_ queue: Queue) -> Queue {
        var mutableQueue = queue
        while !mutableQueue.isEmpty {
            var shouldContinue = false
            let batchSize = min(mutableQueue.count, APIConstants.batchSize)
            let range = 0..<batchSize
            let batch = Array(mutableQueue[range])
            // Log data payload sent
            VisilabsLogger.debug(message: "Sending batch of data")
            VisilabsLogger.debug(message: batch as Any)
            let requestData = JSONHandler.encodeAPIData(batch)
            if let requestData = requestData {
                let semaphore = DispatchSemaphore(value: 0)
                delegate?.updateNetworkActivityIndicator(true)
                var shadowQueue = mutableQueue
                loggerRequest.sendRequest(requestData,
                                         type: type,
                                         useIP: useIPAddressForGeoLocation,
                                         completion: { [weak self, semaphore, range] success in
                                            guard let self = self else { return }
                                            self.delegate?.updateNetworkActivityIndicator(false)
                                            if success {
                                                if let lastIndex = range.last, shadowQueue.count - 1 > lastIndex {
                                                    shadowQueue.removeSubrange(range)
                                                } else {
                                                    shadowQueue.removeAll()
                                                }
                                            }
                                            shouldContinue = success
                                            semaphore.signal()
                })
                _ = semaphore.wait(timeout: DispatchTime.distantFuture)
                mutableQueue = shadowQueue
            }

            if !shouldContinue {
                break
            }
        }
        return mutableQueue
    }

    
    
    // MARK: - Lifecycle
    func applicationDidBecomeActive() {
        //startFlushTimer()
    }

    func applicationWillResignActive() {
        //stopFlushTimer()
    }
}
