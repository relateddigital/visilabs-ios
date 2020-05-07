//
//  VisilabsGeofenceInterceptor.swift
//  VisilabsIOS
//
//  Created by Egemen on 21.04.2020.
//

import Foundation


//TODO:responder tipleri any mi olmalı?

class VisilabsGeofenceInterceptor : NSObject {
    
    /**
    Setup the first choice Responder.
    */
    var firstResponder: VisilabsGeofenceInterceptor?

    /**
    Setup the second choice Responder.
    */
    var secondResponder: VisilabsGeofenceInterceptor?
    
    
    //TODO: init'e gerek var mı?
    // MARK: - life cycle
    override init() {
        firstResponder = nil
        secondResponder = nil
    }
    
    // MARK: - pass handling
    
    func setFirstResponder(_ firstResponder_: VisilabsGeofenceInterceptor?) {
        //Fix a dead loop, if firstResponder_ is self, the following forwardingTargetForSelector and respondsToSelector dead loop.
        if firstResponder_ != self {
            firstResponder = firstResponder_
        }
    }
    
    func setSecondResponder(_ secondResponder_: VisilabsGeofenceInterceptor?) {
        //Fix a dead loop, if secondResponder_ is self, the following forwardingTargetForSelector and respondsToSelector dead loop.
        //Also need to check not first Responder, because some first Responder also call backup Responder for supplement functions, if they are same cause dead loop.
        if secondResponder_ != self && secondResponder != self.firstResponder {
            secondResponder = secondResponder_
        }
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if self.firstResponder!.responds(to: aSelector) {
            return true
        } else if self.secondResponder!.responds(to: aSelector) {
            return true
        } else {
            return super.responds(to: aSelector)
        }
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if self.firstResponder!.responds(to: aSelector) {
            return self.firstResponder
        } else if self.secondResponder!.responds(to: aSelector) {
            return self.secondResponder
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }
    
}
