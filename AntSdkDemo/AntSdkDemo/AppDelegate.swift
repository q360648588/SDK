//
//  AppDelegate.swift
//  AntSdkDemo
//
//  Created by 猜猜我是谁 on 2021/4/16.
//

import UIKit
@_exported import AntSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()

        let nav = UINavigationController.init(rootViewController: ViewController.init())
        self.window?.rootViewController = nav

        _ = AntCommandModule.shareInstance
        AntCommandModule.shareInstance.setIsNeedReconnect(state: true)
        
        return true
    }


}

