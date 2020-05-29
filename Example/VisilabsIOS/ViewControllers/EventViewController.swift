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
        Visilabs2.callAPI().customEvent("Test", properties: properties)
        print(properties)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func geri(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "homeview") {
           self.view.window?.rootViewController = vc
        }
    }
    
}
