//
//  ViewController.swift
//  ZyTools
//
//  Created by 猜猜我是谁 on 2024/4/23.
//

import UIKit
@_exported import ZywlSDK
@_exported import CoreBluetooth
@_exported import ZySDK

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let StatusBarHeight = UIApplication.shared.statusBarFrame.height


class ViewController: UIViewController {

    var tableView:UITableView!
    var dataSourceArray = [String].init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "选择类型"
        
        let rightItem = UIBarButtonItem.init(title: "→", style: .done, target: self, action: #selector(pushNextVC))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.tableView = UITableView.init(frame: .init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.dataSourceArray = ["手环命令测试","手环工厂模式","充电仓命令测试","充电仓工厂模式","耳机命令测试","版本更新"]
        
        self.pushNextVC()
    }

    @objc func pushNextVC() {
        if let localType = UserDefaults.standard.string(forKey: "HC_LocalSelectType") {
            if localType == "103" {
                let vc = ChargingBoxConfigurationVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if localType == "102" {
                let vc = HeadphoneConfigurationVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if localType == "101" {
                let vc = WatchConfigurationVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if localType == "201" {
                ZywlCommandModule.shareInstance.setIsNeedReconnect(state: false)
                ZyCommandModule.shareInstance.setIsNeedReconnect(state: false)
                
                let vc = WatchFactoryCommandVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if localType == "202" {
                ZywlCommandModule.shareInstance.setIsNeedReconnect(state: false)
                ZyCommandModule.shareInstance.setIsNeedReconnect(state: false)
                
                let vc = BoxFactoryCommandVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func saveLocalSelectType(titleString:String) {
        /*
         命令测试id:100+
         工厂模式id:200+
         手环 1
         耳机 2
         充电仓 3
         */
        let userDefault = UserDefaults.standard
        if titleString == "手环命令测试" {
            userDefault.setValue("101", forKey: "HC_LocalSelectType")
        }else if titleString == "耳机命令测试" {
            userDefault.setValue("102", forKey: "HC_LocalSelectType")
        }else if titleString == "充电仓命令测试" {
            userDefault.setValue("103", forKey: "HC_LocalSelectType")
        }else if titleString == "手环工厂模式" {
            userDefault.setValue("201", forKey: "HC_LocalSelectType")
        }else if titleString == "充电仓工厂模式" {
            userDefault.setValue("202", forKey: "HC_LocalSelectType")
        }
    }
}

extension ViewController:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "commandCell") ?? UITableViewCell.init(style: .default, reuseIdentifier: "commandCell")
        
        cell.textLabel?.text = self.dataSourceArray[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let titleString = self.dataSourceArray[indexPath.row]
        print("titleString = \(titleString)")
        self.saveLocalSelectType(titleString: titleString)
        
        if titleString == "手环命令测试" {
            _ = ZyCommandModule.shareInstance
            ZyCommandModule.shareInstance.setIsNeedReconnect(state: true)

            let vc = WatchConfigurationVC()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if titleString == "充电仓命令测试" {
            _ = ZywlCommandModule.shareInstance
            ZywlCommandModule.shareInstance.setIsNeedReconnect(state: true)
            
            let vc = ChargingBoxConfigurationVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if titleString == "耳机命令测试" {
            _ = ZywlCommandModule.shareInstance
            ZywlCommandModule.shareInstance.setIsNeedReconnect(state: true)
            
            let vc = HeadphoneConfigurationVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if titleString == "手环工厂模式" {
            _ = ZyCommandModule.shareInstance
            ZyCommandModule.shareInstance.setIsNeedReconnect(state: false)
            ZywlCommandModule.shareInstance.setIsNeedReconnect(state: false)
            
            let vc = WatchFactoryCommandVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if titleString == "充电仓工厂模式" {
            _ = ZywlCommandModule.shareInstance
            ZywlCommandModule.shareInstance.setIsNeedReconnect(state: false)
            ZyCommandModule.shareInstance.setIsNeedReconnect(state: false)
            
            let vc = BoxFactoryCommandVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if titleString == "版本更新" {
            
            let url = URL(string: "https://apps.apple.com/cn/app/zytools/id6498898870")
               // 注意: 跳转之前, 可以使用 canOpenURL: 判断是否可以跳转
               if !UIApplication.shared.canOpenURL(url!) {
                   // 不能跳转就不要往下执行了
                   return
               }

               if #available(iOS 10.0, *) {
                   UIApplication.shared.open(url!, options: [:]) { (success) in
                       if (success) {
                           print("10以后可以跳转url")
                       }else{
                           print("10以后不能完成跳转")
                       }
                   }
                } else {
                   // Fallback on earlier versions
                   let success = UIApplication.shared.openURL(url!)
                   if (success) {
                       print("10以下可以跳转")
                   }else{
                       print("10以下不能完成跳转")
                   }
                }
        }
    }
}
