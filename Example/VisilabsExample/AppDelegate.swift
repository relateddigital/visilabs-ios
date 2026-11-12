//
//  AppDelegate.swift
//  VisilabsIOS
//
//  Created by egemen@visilabs.com on 03/30/2020.
//  Copyright (c) 2020 egemen@visilabs.com. All rights reserved.
//

import UIKit
import VisilabsIOS
import Euromsg
import UserNotifications

var visilabsProfile = VisilabsProfile()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Euromsg.configure(appAlias: visilabsProfile.appAlias, enableLog: false)
        InAppHelper.downloadMiniIconImagesAndSave()
        
        if let vlp = DataManager.readVisilabsProfile() {
            visilabsProfile = vlp
        }

        
        // iOS 13 öncesi için geriye dönük uyumluluk (iOS 13 ve üzerinde bu işi SceneDelegate yapar)
        if #available(iOS 13, *) {
            // SceneDelegate handles window & push
        } else {
            if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
                Euromsg.handlePush(pushDictionary: userInfo)
            }
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = UIColor.white
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialVC = storyboard.instantiateInitialViewController() ?? HomeViewController()
            window.rootViewController = initialVC
            window.makeKeyAndVisible()
            self.window = window
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        visilabsProfile.appToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        DataManager.saveVisilabsProfile(visilabsProfile)
        Euromsg.registerToken(tokenData: deviceToken)
    }

    // MARK: - UISceneSession Lifecycle

    /*
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
 */

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Euromsg.handlePush(pushDictionary: userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Euromsg.handlePush(pushDictionary: userInfo)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                    @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        Euromsg.handlePush(pushDictionary: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let sendingAppID = options[.sourceApplication]
        print("source application = \(sendingAppID ?? "Unknown")")
        print("url.absoluteString = \(url.absoluteString)")
        
        let storyVC = StoryViewController()
        window?.rootViewController = storyVC
        
        return true
    }
    
    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
