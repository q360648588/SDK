//
//  AppDelegate.swift
//  FactoryDemo
//
//  Created by 猜猜我是谁 on 2022/1/8.
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
        AntCommandModule.shareInstance.scanInterval = 24*60*60
        AntCommandModule.shareInstance.setIsNeedReconnect(state: false)
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        AntCommandModule.shareInstance.setIsNeedReconnect(state: false)
        print("app退出前的操作")
        
    }
}

