//
//  EventViewController.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 22.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation


import UIKit
import VisilabsIOS

class EventViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var properties = [String:String]()
        properties["OM.clist"] = "123"
        properties["OM.exVisitorID"] = "umut@visilabs.com"
        properties["OM.sys.AppID"] = "EuromsgTest"
        Visilabs.callAPI()?.customEvent("Event", properties: properties)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
