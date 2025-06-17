//
//  RecordBoxConfigurationVC.swift
//  ZyTools
//
//  Created by c h on 2025/3/12.
//

import UIKit

class RecordBoxConfigurationVC: UIViewController {
    
    var currentPeripheralState:CBPeripheralState! {
        didSet {
            if self.currentPeripheralState == .disconnected {
                let newString = "\(NSLocalizedString("Current connection status", comment: "当前连接状态")):disconnected"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Current connection status", comment: "当前连接状态"), newString: newString)
            }else if self.currentPeripheralState == .connecting {
                let newString = "\(NSLocalizedString("Current connection status", comment: "当前连接状态")):connecting"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Current connection status", comment: "当前连接状态"), newString: newString)
            }else if self.currentPeripheralState == .connected {
                let newString = "\(NSLocalizedString("Current connection status", comment: "当前连接状态")):connected"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Current connection status", comment: "当前连接状态"), newString: newString)
            }else if self.currentPeripheralState == .disconnecting {
                let newString = "\(NSLocalizedString("Current connection status", comment: "当前连接状态")):disconnecting"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Current connection status", comment: "当前连接状态"), newString: newString)
            }
        }
    }
    var currentBlePowerState:CBCentralManagerState! {
        didSet {
            if self.currentBlePowerState == .unknown {
                let newString = "\(NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态")):unknown"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态"), newString: newString)
            }else if self.currentBlePowerState == .resetting {
                let newString = "\(NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态")):resetting"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态"), newString: newString)
            }else if self.currentBlePowerState == .unsupported {
                let newString = "\(NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态")):unsupported"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态"), newString: newString)
            }else if self.currentBlePowerState == .unauthorized {
                let newString = "\(NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态")):unauthorized"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态"), newString: newString)
            }else if self.currentBlePowerState == .poweredOff {
                let newString = "\(NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态")):poweredOff"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态"), newString: newString)
            }else if self.currentBlePowerState == .poweredOn {
                let newString = "\(NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态")):poweredOn"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态"), newString: newString)
            }
        }
    }
    var filterString = ""
    var tableView:UITableView!
    var dataSourceArray = [String].init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Connection Settings", comment: "连接设置")

        let rightItem = UIBarButtonItem.init(title: "→", style: .done, target: self, action: #selector(pushNextVC))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.tableView = UITableView.init(frame: .init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.dataSourceArray = [
            "\(NSLocalizedString("Current Bluetooth status", comment: "当前蓝牙状态")):--",
            "\(NSLocalizedString("Current connection status", comment: "当前连接状态")):--",
            NSLocalizedString("Disconnect and unbind", comment: "断开连接,解绑"),
            NSLocalizedString("Filter device name", comment: "过滤设备名"),
            NSLocalizedString("View Local file", comment: "查看本地文件"),
            "\(NSLocalizedString("Date of update", comment: "更新日期")):2025-2-13",
        ]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        ZyCommandModule.shareInstance.reconnectDevice { [weak self] in
            print("重连成功")

            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self?.pushNextVC()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.currentBlePowerState = ZyCommandModule.shareInstance.blePowerState
        ZyCommandModule.shareInstance.bluetoothPowerStateChange { [weak self] state in
            self?.currentBlePowerState = state
        }
        
        self.currentPeripheralState = ZyCommandModule.shareInstance.peripheral?.state
        ZyCommandModule.shareInstance.peripheralStateChange { [weak self] state in
            self?.currentPeripheralState = state
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - 跳转界面
    @objc func pushNextVC() {
        print("self.navigationController?.viewControllers = \(self.navigationController?.viewControllers)")
        let isHaveReconnect = ZyCommandModule.shareInstance.getReconnectIdentifier()
        
        if isHaveReconnect.count > 0 {
            if self.navigationController?.viewControllers.count ?? 0 <= 2 {
                let vc = RecordBoxCommandVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let vc = RecordScanVC()
            vc.filterString = self.filterString
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //断开连接
    @objc func disConnectButtonClick() {
        print("断开连接")
        ZyCommandModule.shareInstance.disconnect()
    }

    // MARK: - 过滤设备
    @objc func filterButtonClick() {
        let array = [
            NSLocalizedString("Not case sensitive", comment: "不用区分大小写")
        ]
        self.presentTextFieldAlertVC(title: NSLocalizedString("Filter device name", comment: "过滤设备名"), message: nil, holderStringArray: array, cancel: nil, cancelAction: {
            
        }, ok: nil) { textArray in
            let filterString = textArray[0]
            self.filterString = filterString
            if filterString.count > 0 {
                let newString = "\(NSLocalizedString("Filter device name", comment: "过滤设备名")):\(filterString)"
                self.reloadTableViewDataSource(originalString: NSLocalizedString("Filter device name", comment: "过滤设备名"), newString: newString)
            }
        }
    }
    
    // MARK: - 查看本地文件
    func checkLocalFile() {
        let path = NSHomeDirectory() + "/Documents"
        //let exist = FileManager.default.fileExists(atPath: path)
        let vc = FileVC.init(filePath: path)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 刷新tableview数据显示
    func reloadTableViewDataSource(originalString:String,newString:String) {
        if let index = self.dataSourceArray.firstIndex(where: { title in
            return title.contains(originalString)
        }) {
            self.dataSourceArray[index] = newString
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension RecordBoxConfigurationVC:UITableViewDataSource,UITableViewDelegate {
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
        cell.selectionStyle = .none
        cell.textLabel?.text = self.dataSourceArray[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let titleString = self.dataSourceArray[indexPath.row]
        print("titleString = \(titleString)")
        
        if titleString == NSLocalizedString("Disconnect and unbind", comment: "断开连接,解绑") {
            self.disConnectButtonClick()
        }
        if titleString == "查看本地文件" {
            self.checkLocalFile()
        }
        if titleString.contains(NSLocalizedString("Filter device name", comment: "过滤设备名")) {
            self.filterButtonClick()
        }
    }
}
