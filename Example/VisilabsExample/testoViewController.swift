//
//  testoViewController.swift
//  VisilabsExample
//
//  Created by Umut Can Alparslan on 22.04.2022.
//

import UIKit
import VisilabsIOS

class testoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        Visilabs.createAPI(organizationId: visilabsProfile.organizationId, profileId: visilabsProfile.profileId,
                           dataSource: visilabsProfile.dataSource,
                           inAppNotificationsEnabled: visilabsProfile.inAppNotificationsEnabled,
                           channel: visilabsProfile.channel,
                           requestTimeoutInSeconds: visilabsProfile.requestTimeoutInSeconds,
                           geofenceEnabled: visilabsProfile.geofenceEnabled,
                           askLocationPermmissionAtStart: visilabsProfile.askLocationPermmissionAtStart,
                           maxGeofenceCount: visilabsProfile.maxGeofenceCount,
                           isIDFAEnabled: visilabsProfile.isIDFAEnabled,
                           loggingEnabled: true,isTest: visilabsProfile.IsTest)
        Visilabs.callAPI().useInsecureProtocol = false
        Visilabs.callAPI().loggingEnabled = true
    }
    

    @IBAction func but(_ sender: Any) {
        
        var properties = [String: String]()
        properties["OM.sys.TokenID"] = visilabsProfile.appToken //"Token ID to use for push messages"
        properties["OM.sys.AppID"] = visilabsProfile.appAlias
        Visilabs.callAPI().login(exVisitorId: "umut@visilabs.com", properties: properties)
        
        var props = [String: String]()
        props["OM.sys.TokenID"] = visilabsProfile.appToken
        props["OM.sys.AppID"] = visilabsProfile.appAlias
        Visilabs.callAPI().customEvent("homepage", properties: props)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
