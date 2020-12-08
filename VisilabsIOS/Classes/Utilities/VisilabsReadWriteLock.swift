//
//  VisilabsReadWriteLock.swift
//  VisilabsIOS
//
//  Created by Egemen on 3.05.2020.
//

import Foundation

class VisilabsReadWriteLock {
    let concurentQueue: DispatchQueue

    init(label: String) {
        self.concurentQueue = DispatchQueue(label: label, attributes: .concurrent)
    }

    func read(closure: () -> Void) {
        self.concurentQueue.sync {
            closure()
        }
    }
    func write(closure: () -> Void) {
        self.concurentQueue.sync(flags: .barrier, execute: {
            closure()
        })
    }
}
