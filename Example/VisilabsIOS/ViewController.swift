//
//  ViewController.swift
//  VisilabsIOS
//
//  Created by egemen@visilabs.com on 03/30/2020.
//  Copyright (c) 2020 egemen@visilabs.com. All rights reserved.
//

import UIKit
import VisilabsIOS

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let props = [String : String]()
        
        Visilabs.callAPI()!.customEvent("test", properties: props)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

