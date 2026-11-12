//
//  SceneDelegate.swift
//  VisilabsIOS_Example
//
//  Created by Egemen on 17.08.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import Euromsg

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Window başlatma ve ilk ekranı set etme
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = UIColor.white
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = storyboard.instantiateInitialViewController() ?? HomeViewController()
        window.rootViewController = initialVC
        window.makeKeyAndVisible()
        self.window = window

        // iOS 13+ açılış bildirimi yönetimi
        if let userInfo = connectionOptions.notificationResponse?.notification.request.content.userInfo {
            Euromsg.handlePush(pushDictionary: userInfo)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

