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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("url = \(url),options = \(options)")
                
        let fileName = url.lastPathComponent
        print("fileName = \(fileName)")
        
        var fileTypeString = ""
        if fileName.lowercased().contains("font") || fileName.lowercased().contains("src") || fileName.lowercased().contains("app"){
            if fileName.lowercased().contains("font") {
                fileTypeString = "字库"
            }else if fileName.lowercased().contains("src") {
                fileTypeString = "图库"
            }else if fileName.lowercased().contains("app") {
                fileTypeString = "应用"
            }
            
            self.window?.rootViewController?.presentSystemAlertVC(title: "检测到当前为\(fileTypeString)文件", message: "是否设置为需要升级的文件路径?", cancel: "否", cancelAction: {

            }, ok: "是") {
                let homePath = NSHomeDirectory()
                let urlString = String.init(format: "%@", url as CVarArg)
                let separatedArray = urlString.components(separatedBy: "/Documents")
                let pathString = urlString.replacingOccurrences(of: separatedArray[0], with: "")
                print("选中的文件连接 pathString =",pathString)
                
                let userDefault = UserDefaults.standard
                if fileTypeString == "字库" {
                    userDefault.set(pathString, forKey: FontKey)
                }else if fileTypeString == "图库" {
                    userDefault.set(pathString, forKey: LibraryKey)
                }else if fileTypeString == "应用" {
                    userDefault.set(pathString, forKey: ApplicationKey)
                }
                userDefault.synchronize()
            }
            
        }
        
        return true
    }
}

