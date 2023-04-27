//
//  ViewController.swift
//  AntSdkDemo
//
//  Created by 猜猜我是谁 on 2021/4/16.
//

import UIKit
import AntSDK
import CoreBluetooth

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let StatusBarHeight = UIApplication.shared.statusBarFrame.height

class ViewController: UIViewController {
    
    var currentPeripheralState:CBPeripheralState! {
        didSet {
            if self.currentPeripheralState == .disconnected {
                self.currenStateLabel.text = "当前连接状态:已断开"
            }else if self.currentPeripheralState == .connecting {
                self.currenStateLabel.text = "当前连接状态:正在连接"
            }else if self.currentPeripheralState == .connected {
                self.currenStateLabel.text = "当前连接状态:已连接"
            }else if self.currentPeripheralState == .disconnecting {
                self.currenStateLabel.text = "当前连接状态:正在断开"
            }
        }
    }
    var currentBlePowerState:CBCentralManagerState! {
        didSet {
            if self.currentBlePowerState == .unknown {
                self.blePowerLabel.text = "当前蓝牙状态:unknown"
            }else if self.currentBlePowerState == .resetting {
                self.blePowerLabel.text = "当前蓝牙状态:resetting"
            }else if self.currentBlePowerState == .unsupported {
                self.blePowerLabel.text = "当前蓝牙状态:unsupported"
            }else if self.currentBlePowerState == .unauthorized {
                self.blePowerLabel.text = "当前蓝牙状态:unauthorized"
            }else if self.currentBlePowerState == .poweredOff {
                self.blePowerLabel.text = "当前蓝牙状态:poweredOff"
            }else if self.currentBlePowerState == .poweredOn {
                self.blePowerLabel.text = "当前蓝牙状态:poweredOn"
            }
        }
    }
    var currenStateLabel:UILabel!
    var blePowerLabel:UILabel!
    var filterString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.title = "AntSDK连接设置"
        
        self.createConfigurationView()
        
        let rightItem = UIBarButtonItem.init(title: "→", style: .done, target: self, action: #selector(pushNextVC))
        self.navigationItem.rightBarButtonItem = rightItem
        
        AntCommandModule.shareInstance.reconnectDevice {
            print("重连成功")

            if self.navigationController?.viewControllers.count == 1 {
                let vc = AntVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            let vc = UIViewController.getAnyVC(vc: AntVC())
            //vc?.test()
            //vc?.test()
        }
        
        //self.semaphore_demo()
        
    }
    
    func convertDataToHexStr(data:Data) ->String {
        
        if data.count <= 0 {
            return ""
        }
        
        var dataString = ""
        let str = data.withUnsafeBytes { (bytes) -> String in
            for i in stride(from: 0, to: bytes.count, by: 1) {
                let count = UInt8(bytes[i])
                
                if dataString.count > 0 {
                    
                    dataString = dataString + " "

                }
                dataString = dataString + String.init(format: "%02x", count)
            }
            return String.init(format: "{length = %d , bytes = 0x%@}", data.count,dataString)
        }
        return str
    }
    
    func semaphore_demo() {
        let queue = DispatchQueue.global()
        //创建信号量  值为1  意思是最大并发数为1，任务只能一个接一个执行
        var count = 1
        let semaphore = DispatchSemaphore.init(value: count)
        
        //此时信号量为1，无需等待，向下执行 信号量 1->0
        semaphore.wait()
        queue.asyncAfter(deadline: .now() + 5) {
            print("1111")
            //延迟4秒后输出1111，释放信号量，信号量 从0->1
            count = semaphore.signal()
            print("count1111 =",count)
        }
        print("1111count =",count)
        
        //延迟4秒输出1111后，此时信号量为1，继续向下执行  同上操作。。。
        semaphore.wait()
        queue.asyncAfter(deadline: .now() + 4) {
            print("2222")
            count = semaphore.signal()
            print("count2222 =",count)
        }
        print("2222 count =",count)
        
        semaphore.wait()
        queue.asyncAfter(deadline: .now() + 3) {
            print("3333")
            count = semaphore.signal()
            print("count3333 =",count)
        }
        print("3333count =",count)
        
        semaphore.wait()
        queue.asyncAfter(deadline: .now() + 2) {
            print("4444")
            count = semaphore.signal()
            print("count4444 =",count)
        }
        print("4444count =",count)
        
        semaphore.wait()
        queue.asyncAfter(deadline: .now() + 1) {
            print("5555")
            semaphore.signal()
        }
        print("55555 count =",count)
        semaphore.wait()
        print("任务全部完成")
        count = semaphore.signal()
        print("count5555 =",count)
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AntCommandModule.shareInstance.bluetoothPowerStateChange { state in
            self.currentBlePowerState = state
        }
        
        AntCommandModule.shareInstance.peripheralStateChange { state in
            self.currentPeripheralState = state
        }
    }

    func createConfigurationView() {
        let tipLabel = UILabel.init(frame: .init(x: 0, y: 40+StatusBarHeight+10, width: screenWidth, height: 44))
        tipLabel.backgroundColor = .green
        tipLabel.text = "重连设置需要下次启动生效"
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        self.view.addSubview(tipLabel)
        
        let currenStateLabel = UILabel.init(frame: .init(x: 0, y: 40+StatusBarHeight+60, width: screenWidth, height: 44))
        currenStateLabel.backgroundColor = .green
        currenStateLabel.text = "当前连接状态:--"
        currenStateLabel.textColor = .red
        currenStateLabel.numberOfLines = 0
        currenStateLabel.textAlignment = .center
        self.view.addSubview(currenStateLabel)
        self.currenStateLabel = currenStateLabel
        self.currentPeripheralState = AntCommandModule.shareInstance.peripheral?.state
        
        let reconnectButton = UIButton.init(frame: .init(x: 0, y: 200, width: screenWidth, height: 44))
        reconnectButton.backgroundColor = .green
        reconnectButton.setTitle("打开重连", for: .normal)
        reconnectButton.addTarget(self, action: #selector(reconnectButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(reconnectButton)
        
        let closeButton = UIButton.init(frame: .init(x: 0, y: 250, width: screenWidth, height: 44))
        closeButton.backgroundColor = .green
        closeButton.setTitle("关闭重连(已连接不会断开连接)", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(closeButton)
        
        let scanTimeButton = UIButton.init(frame: .init(x: 0, y: 300, width: screenWidth, height: 44))
        scanTimeButton.backgroundColor = .green
        scanTimeButton.setTitle("扫描时间(默认30s)", for: .normal)
        scanTimeButton.addTarget(self, action: #selector(scanTimeButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(scanTimeButton)
        
        let disConnectButton = UIButton.init(frame: .init(x: 0, y: 350, width: screenWidth, height: 44))
        disConnectButton.backgroundColor = .green
        disConnectButton.setTitle("断开连接,解绑", for: .normal)
        disConnectButton.addTarget(self, action: #selector(disConnectButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(disConnectButton)
        
        let directConnectionButton = UIButton.init(frame: .init(x: 0, y: 400, width: screenWidth, height: 44))
        directConnectionButton.backgroundColor = .green
        directConnectionButton.setTitle("直连设备", for: .normal)
        directConnectionButton.addTarget(self, action: #selector(directConnectionButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(directConnectionButton)
                
        let blePowerLabel = UILabel.init(frame: .init(x: 0, y: 450, width: screenWidth, height: 44))
        blePowerLabel.backgroundColor = .green
        blePowerLabel.text = "当前蓝牙状态:--"
        blePowerLabel.textColor = .red
        blePowerLabel.numberOfLines = 0
        blePowerLabel.textAlignment = .center
        self.view.addSubview(blePowerLabel)
        self.blePowerLabel = blePowerLabel
        self.currentBlePowerState = AntCommandModule.shareInstance.blePowerState
        
        let crashButton = UIButton.init(frame: .init(x: 0, y: 500, width: screenWidth, height: 44))
        crashButton.backgroundColor = .green
        crashButton.setTitle("闪退日志", for: .normal)
        crashButton.addTarget(self, action: #selector(crashButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(crashButton)
        
        let filterButton = UIButton.init(frame: .init(x: 0, y: 550, width: screenWidth, height: 44))
        filterButton.backgroundColor = .green
        filterButton.setTitle("过滤设备名", for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(filterButton)
        
        let dateLabel = UILabel.init(frame: .init(x: 0, y: 600, width: screenWidth, height: 44))
        dateLabel.backgroundColor = .green
        dateLabel.text = "更新日期:2023-4-20"
        dateLabel.textColor = .red
        dateLabel.numberOfLines = 0
        dateLabel.textAlignment = .center
        self.view.addSubview(dateLabel)
        
    }
    
    @objc func pushNextVC() {
        
        let isHaveReconnect = AntCommandModule.shareInstance.getReconnectIdentifier()
        
        if isHaveReconnect.count > 0 {
            let vc = AntVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = ScanVC()
            vc.filterString = self.filterString
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @objc func reconnectButtonClick(sender:UIButton) {
        print("打开重连")
        AntCommandModule.shareInstance.setIsNeedReconnect(state: true)

    }
    
    @objc func closeButtonClick(sender:UIButton) {
        print("关闭重连")
        AntCommandModule.shareInstance.setIsNeedReconnect(state: false)

    }
    
    @objc func disConnectButtonClick(sender:UIButton) {
        print("断开连接")
        AntCommandModule.shareInstance.disconnect()
    }
    
    @objc func directConnectionButtonClick(sender:UIButton) {
        print("设备直连")
        //可以重连的设备唯一标识
        let uuidString = AntCommandModule.shareInstance.getReconnectIdentifier()//"44EBA7A3-C161-DFB3-A08A-59C8B5F7F3EC"//
        print("uuidString =",uuidString)
                
        AntCommandModule.shareInstance.connectDevice(peripheral: uuidString) { state in
            if state {
                print("连接成功")
                
            }else{
                print("连接失败")
            }
        }

    }
    
    @objc func scanTimeButtonClick(sender:UIButton) {
        let array = [
            "扫描时间"
        ]
        self.presentTextFieldAlertVC(title: "设置扫描时间", message: nil, holderStringArray: array, cancel: nil, cancelAction: {
            
        }, ok: nil) { textArray in
            let timeLength = textArray[0]
            AntCommandModule.shareInstance.scanInterval = Int(timeLength) ?? 30
        }
    }
    
    @objc func crashButtonClick(sender:UIButton) {
        let path = NSHomeDirectory() + "/Documents"
        //let exist = FileManager.default.fileExists(atPath: path)
        let vc = FileVC.init(filePath: path)
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        vc.saveClickBlock = { (pathString) in
            print("选中的文件连接 pathString =",pathString)
            var string = ""
            do{
                //                创建指定位置上的文件夹
                string = try String.init(contentsOfFile: pathString, encoding: .utf8)
                print("string =",string)
            }
            catch{
                print("Error to create folder")
            }
                        
            let logVc = UIViewController.init()
            let logView = ShowLogView.init(frame: .init(x: 0, y: 0, width: screenWidth, height: screenHeight))
            logView.writeString(string: string)
            logVc.view.addSubview(logView)
            self.navigationController?.pushViewController(logVc, animated: true)
            
        }
    }
    
    @objc func filterButtonClick(sender:UIButton) {
        let array = [
            "不用区分大小写"
        ]
        self.presentTextFieldAlertVC(title: "设置过滤设备的名称", message: nil, holderStringArray: array, cancel: nil, cancelAction: {
            
        }, ok: nil) { textArray in
            let filterString = textArray[0]
            self.filterString = filterString
            if filterString.count > 0 {
                sender.setTitle("过滤设备名:\(filterString)", for: .normal)
            }else{
                sender.setTitle("过滤设备名", for: .normal)
            }
        }
    }
}



extension UIViewController {
    func presentTextFieldAlertVC(title:String?,message:String?,holderStringArray:[String]? = [],cancel:String? = "取消" ,cancelAction:(()->())?,ok:String? = "确定" ,okAction:(([String])->())?){

        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)

        var cancel = cancel
        if cancel == nil {
            cancel = "取消"
        }
        
        var ok = ok
        if ok == nil {
            ok = "确定"
        }
        
        for item in holderStringArray ?? [] {
            alertVC.addTextField { (textField) in
                textField.keyboardType = .numbersAndPunctuation
                textField.placeholder = item
            }
        }
        
        let cancelAC = UIAlertAction.init(title: cancel, style: .default) { (action) in
            if let cancelAction = cancelAction{
                cancelAction()
            }
        }

        let okAC = UIAlertAction.init(title: ok, style: .default) { (action) in
            var array = [String].init()
            for i in stride(from: 0, to: holderStringArray?.count ?? 0, by: 1) {
                let textField = alertVC.textFields?[i]
                array.append(textField?.text ?? "")
            }
            
            if let okAction = okAction{
                okAction(array)
            }
        }

        alertVC.addAction(cancelAC)
        alertVC.addAction(okAC)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            alertVC.popoverPresentationController?.sourceView = self.view //要展示在哪里
            
            alertVC.popoverPresentationController?.sourceRect = self.view.frame //箭头指向哪里
            
        }
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func presentSystemAlertVC(title:String?,message:String?,cancel:String? = "取消",cancelAction:(()->())?,ok:String?  = "确定",okAction:(()->())?) {
        
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)

        var cancel = cancel
        if cancel == nil {
            cancel = NSLocalizedString("取消", comment: "")
        }
        
        var ok = ok
        if ok == nil {
            ok = NSLocalizedString("确定", comment: "")
        }
        
        if let cancelAction = cancelAction{
            let cancelAC = UIAlertAction.init(title: cancel, style: .default) { (action) in
                cancelAction()
            }
            alertVC.addAction(cancelAC)
        }
        
        //cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        if let okAction = okAction{
            let okAC = UIAlertAction.init(title: ok, style: .default) { (action) in
                okAction()
            }
            alertVC.addAction(okAC)
        }

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            alertVC.popoverPresentationController?.sourceView = self.view //要展示在哪里
            
            alertVC.popoverPresentationController?.sourceRect = self.view.frame //箭头指向哪里
            
        }
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension UIViewController {
    class func getAnyVC<T>(vc:T) -> T? {
        
        var anyVC:T? = nil
        let HcWindow = UIApplication.shared.delegate as! AppDelegate
        let nc = HcWindow.window?.rootViewController
        //print("nc = \(nc)")
        if nc is UITabBarController {
            let nc:UITabBarController = nc as! UITabBarController
            for vc in nc.viewControllers! {
                if vc is UINavigationController {
                    let vc:UINavigationController = vc as! UINavigationController
                    for item in vc.viewControllers {
                        if item is T {
                            anyVC = item as? T
                        }
                        //print("item = \(item)")
                    }
                }
            }
        }else if nc is UINavigationController {
            let nc:UINavigationController = nc as! UINavigationController
            for vc in nc.viewControllers {
                if vc is UINavigationController {
                    let vc:UINavigationController = vc as! UINavigationController
                    for item in vc.viewControllers {
                        if item is T {
                            anyVC = item as? T
                        }
                        //print("item = \(item)")
                    }
                }
                if vc is UIViewController {
                    if vc is T {
                        anyVC = vc as? T
                    }
                }
            }
        }
        return anyVC
    }
}
