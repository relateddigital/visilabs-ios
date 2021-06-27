//
//  VisilabsCLAuthorizationStatus.swift
//  VisilabsIOS
//
//  Created by Egemen on 2.09.2020.
//

import Foundation

public enum VisilabsCLAuthorizationStatus: Int32 {
   case notDetermined = 0
   case restricted = 1
   case denied = 2
   case authorizedAlways = 3
   case authorizedWhenInUse = 4
   case none = 5
}
