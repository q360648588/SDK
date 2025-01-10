//
//  BoxFactoryCommandVC.swift
//  ZyTools
//
//  Created by 猜猜我是谁 on 2024/5/20.
//

import UIKit

class BoxFactoryCommandVC: UIViewController {
    
    var isStart = false
    var failNameArray:[String] = Array.init()
    let logView = ShowLogView.init(frame: .init(x: 0, y: StatusBarHeight+44, width: screenWidth, height: screenHeight-StatusBarHeight-44))
    var connectModel:ZywlScanModel?
    var recordIndex:Int? = nil
    var isNeedCheckOtaMethod = false   //升级过程中异常断开需要在重连之后检测升级状态，  升级结束之后设备自动断开的那种重连不需要检测
    var scanNameLabel:UILabel!
    var currentConnetName:UILabel!
    var currentDeviceString = "" {
        didSet {
            self.currentConnetName.text = "当前设备名及状态:\(self.currentDeviceString)"
        }
    }
    
    var connectCountLabel:UILabel!
    var failConnectCount = 0 {
        didSet {
            self.connectCountLabel.text = "连接失败次数:\(self.failConnectCount)"
        }
    }
    var failConnectString = ""
    
    var failCountLabel:UILabel!
    var failProcessCount = 0 {
        didSet{
            self.failCountLabel.text = "流程失败次数:\(self.failProcessCount)"
        }
    }
    var failProcessString = ""
    
    var successCountLabel:UILabel!
    var successCount = 0 {
        didSet {
            self.successCountLabel.text = "流程完成次数:\(self.successCount)"
        }
    }
    
    var configurationLabel:UILabel!
    var currentStateLabel:UILabel!
    var stateString = "" {
        didSet {
            self.currentStateLabel.text = "当前操作状态:\(self.stateString)"
        }
    }
    var filterUuidStringArray = [String]()
    
    var totalCountLabel:UILabel!
    var totalCount = 0 {
        didSet {
            self.totalCountLabel.text = "总次数:\(self.totalCount)"
        }
    }
    
    var reconnectTimer:Timer?
    var reconnectTimerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "自动扫描发送"
        
        let rightItem = UIBarButtonItem.init(title: "配置", style: .done, target: self, action: #selector(pushNextVC))
        self.navigationItem.rightBarButtonItem = rightItem
                
        self.createView()
        
        self.logView.isHidden = true
        self.view.addSubview(self.logView)
        
        ZywlCommandModule.shareInstance.reconnectDevice { [weak self] isHeadphone in
            if let self = self {
                if isHeadphone == false {
                    let model = ZywlScanModel.init()
                    model.name = ZywlCommandModule.shareInstance.chargingBoxPeripheral?.name
                    model.peripheral = ZywlCommandModule.shareInstance.chargingBoxPeripheral
                    //升级过程中异常断开sdk内部会在连接之后监测升级，有升级data则自动接上一次升级进度。  升级完成之后自动断开的则需要在此检测下一个升级文件
                    if self.isNeedCheckOtaMethod == true {
                        print("重连完成监测升级")
                        self.checkOtaMethod(model: model)
                    }
                }
            }
            
        }
        
        ZywlCommandModule.shareInstance.bluetoothPowerStateChange { [weak self] state in
            if let self = self {
                if state == .poweredOn {
                    self.stateString = "蓝牙开关开启"
                }
                if state == .poweredOff {
                    self.stateString = "蓝牙开关关闭"
                }
            }
        }
        
        ZywlCommandModule.shareInstance.peripheralStateChange { [weak self] isHeadphone, state in
            if let self = self {
                if state == .disconnected {
                    self.currentDeviceString = "\(ZywlCommandModule.shareInstance.chargingBoxPeripheral?.name ?? "") 已断开"
                    
                    if ZywlCommandModule.shareInstance.getChargingBoxReconnectIdentifier().count > 0 {
                        if self.reconnectTimer == nil {
                            self.reconnectTimer = Timer.scheduledTimer(timeInterval: 50, target: self, selector: #selector(self.reconnectFailTimerMethod), userInfo: nil, repeats: true)
                        }
                    }
                    
                }else if state == .connecting {
                    self.currentDeviceString = "\(ZywlCommandModule.shareInstance.chargingBoxPeripheral?.name ?? "") 正在连接"
                }else if state == .connected {
                    self.currentDeviceString = "\(ZywlCommandModule.shareInstance.chargingBoxPeripheral?.name ?? "") 已连接"
                    let model = ZywlScanModel.init()
                    model.peripheral = ZywlCommandModule.shareInstance.chargingBoxPeripheral
                    model.name = ZywlCommandModule.shareInstance.chargingBoxPeripheral?.name
                    self.connectModel = model
                    self.reconnectFailTimerInvalidate()
                }else if state == .disconnecting {
                    self.currentDeviceString = "\(ZywlCommandModule.shareInstance.chargingBoxPeripheral?.name ?? "") 正在断开"
                }
            }
        }
    }

    @objc func reconnectFailTimerMethod() {
        
        if self.singleConnectCount < 3 {
            self.singleConnectCount += 1
            self.stateString = "第\(self.singleConnectCount)次回连失败\(self.connectModel?.name ?? "nil")"
            
        }else{
            
            if let name = self.connectModel?.name {
                self.failNameArray.append(name)
            }
            
            self.failConnectCount += 1
            self.failConnectString = self.failConnectString + "\n\(self.connectModel?.name ?? "")\n\(self.connectModel?.peripheral?.identifier.uuidString ?? "")\n"
            print("self.failConnectString =",self.failConnectString)
            self.singleConnectCount = 0
            self.singleProcessEndMethod()
            self.reconnectFailTimerInvalidate()
        }
    }
    
    func reconnectFailTimerInvalidate() {
        if self.reconnectTimer != nil {
            self.reconnectTimer?.invalidate()
            self.reconnectTimer = nil
        }
        self.singleConnectCount = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        let userDefault = UserDefaults.standard
        
        let scanArray = userDefault.array(forKey: zycxScanNameKey)
        var scanNameString = ""
        if let arr = scanArray {
            for i in 0..<arr.count {
                let item = arr[i] as! String
                scanNameString = scanNameString + item
                if i < arr.count - 1 {
                    scanNameString = scanNameString + ","
                }
            }
        }
        self.scanNameLabel.text = "自动扫描的设备名:\(scanNameString)"
        
        self.stateString = "未开启"
        
        var processString = ""
        
        let sortArray = userDefault.array(forKey: zycxOtaSortKey)
        if let sortArray:[Int] = sortArray as? [Int] {
            for item in sortArray {
                if item == 1 {
                    let applicationPath = userDefault.string(forKey: zycxApplicationKey)
                    if let path = applicationPath {
                        processString = processString+"->1应用文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
                    }
                }
                if item == 2 {
                    let libraryPath = userDefault.string(forKey: zycxLibraryKey)
                    if let path = libraryPath {
                        processString = processString+"->2图库文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
                    }
                }
                if item == 3 {
                    let fontPath = userDefault.string(forKey: zycxFontKey)
                    if let path = fontPath {
                        processString = processString+"->3字库文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
                    }
                }
                if item == 4 {
                    let dialPath = userDefault.string(forKey: zycxDialKey)
                    if let path = dialPath {
                        processString = processString+"->4表盘文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
                    }
                    if userDefault.bool(forKey: zycxPowerOffKey) == true {
                        processString = processString+"->关机"
                    }
                }
            }
        }

        self.configurationLabel.text = "配置选项流程:"+processString
    }
    
    func createView() {
        
        let scanNameLabel = UILabel.init(frame: .init(x: 0, y: 40+StatusBarHeight+10, width: screenWidth, height: 44))
        scanNameLabel.backgroundColor = .clear
        scanNameLabel.textColor = .black
        scanNameLabel.text = "自动扫描的设备名"
        scanNameLabel.numberOfLines = 0
        scanNameLabel.textAlignment = .left
        self.view.addSubview(scanNameLabel)
        self.scanNameLabel = scanNameLabel
        
        let configurationLabel = UILabel.init(frame: .init(x: 0, y: scanNameLabel.frame.maxY+10, width: screenWidth, height: 80))
        configurationLabel.backgroundColor = .clear
        configurationLabel.textColor = .black
        configurationLabel.numberOfLines = 0
        configurationLabel.textAlignment = .left
        self.view.addSubview(configurationLabel)
        self.configurationLabel = configurationLabel
        
        let currentStateLabel = UILabel.init(frame: .init(x: 0, y: configurationLabel.frame.maxY+10, width: screenWidth, height: 44))
        currentStateLabel.backgroundColor = .clear
        currentStateLabel.textColor = .black
        currentStateLabel.text = "当前操作状态"
        currentStateLabel.numberOfLines = 0
        currentStateLabel.textAlignment = .left
        self.view.addSubview(currentStateLabel)
        self.currentStateLabel = currentStateLabel
        
        let currentConnetName = UILabel.init(frame: .init(x: 0, y: currentStateLabel.frame.maxY+10, width: screenWidth, height: 44))
        currentConnetName.backgroundColor = .clear
        currentConnetName.textColor = .black
        currentConnetName.text = "当前设备名及状态:"
        currentConnetName.numberOfLines = 0
        currentConnetName.textAlignment = .left
        self.view.addSubview(currentConnetName)
        self.currentConnetName = currentConnetName
        
        let successCountLabel = UILabel.init(frame: .init(x: 0, y: currentConnetName.frame.maxY+10, width: screenWidth, height: 44))
        successCountLabel.backgroundColor = .clear
        successCountLabel.textColor = .black
        successCountLabel.text = "流程完成次数:0"
        successCountLabel.numberOfLines = 0
        successCountLabel.textAlignment = .left
        self.view.addSubview(successCountLabel)
        self.successCountLabel = successCountLabel
        
        let failCountLabel = UILabel.init(frame: .init(x: 0, y: successCountLabel.frame.maxY+10, width: screenWidth, height: 44))
        failCountLabel.backgroundColor = .clear
        failCountLabel.textColor = .black
        failCountLabel.text = "流程失败次数:0"
        failCountLabel.numberOfLines = 0
        failCountLabel.textAlignment = .left
        self.view.addSubview(failCountLabel)
        self.failCountLabel = failCountLabel
        
        let failProcessButton = UIButton.init(frame: .init(x: screenWidth/2.0, y: failCountLabel.frame.minY, width: screenWidth/2.0, height: 44))
        failProcessButton.setTitleColor(.black, for: .normal)
        failProcessButton.backgroundColor = .clear
        failProcessButton.setTitle("查看失败流程", for: .normal)
        failProcessButton.addTarget(self, action: #selector(failProcessButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(failProcessButton)
        
        let connectCountLabel = UILabel.init(frame: .init(x: 0, y: failCountLabel.frame.maxY+10, width: screenWidth/2.0, height: 44))
        connectCountLabel.backgroundColor = .clear
        connectCountLabel.textColor = .black
        connectCountLabel.text = "连接失败次数:0"
        connectCountLabel.numberOfLines = 0
        connectCountLabel.textAlignment = .left
        self.view.addSubview(connectCountLabel)
        self.connectCountLabel = connectCountLabel
        
        let failConnectButton = UIButton.init(frame: .init(x: screenWidth/2.0, y: connectCountLabel.frame.minY, width: screenWidth/2.0, height: 44))
        failConnectButton.setTitleColor(.black, for: .normal)
        failConnectButton.backgroundColor = .clear
        failConnectButton.setTitle("查看连接失败设备", for: .normal)
        failConnectButton.addTarget(self, action: #selector(failConnectButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(failConnectButton)
        
        let totalCountLabel = UILabel.init(frame: .init(x: 0, y: connectCountLabel.frame.maxY+10, width: screenWidth/2.0, height: 44))
        totalCountLabel.backgroundColor = .clear
        totalCountLabel.textColor = .black
        totalCountLabel.text = "总次数:0"
        totalCountLabel.numberOfLines = 0
        totalCountLabel.textAlignment = .left
        self.view.addSubview(totalCountLabel)
        self.totalCountLabel = totalCountLabel
        
        let clearCountButton = UIButton.init(frame: .init(x: screenWidth/2.0, y: totalCountLabel.frame.minY, width: screenWidth/2.0, height: 44))
        clearCountButton.setTitleColor(.black, for: .normal)
        clearCountButton.backgroundColor = .clear
        clearCountButton.setTitle("总次数清零", for: .normal)
        clearCountButton.addTarget(self, action: #selector(clearCountButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(clearCountButton)
        
        let startButton = UIButton.init(frame: .init(x: 0, y: 600, width: screenWidth/2.0, height: 44))
        startButton.setTitleColor(.black, for: .normal)
        startButton.backgroundColor = .clear
        startButton.setTitle("开始", for: .normal)
        startButton.addTarget(self, action: #selector(startButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(startButton)

        let stopButton = UIButton.init(frame: .init(x: screenWidth/2.0, y: 600, width: screenWidth/2.0, height: 44))
        stopButton.setTitleColor(.black, for: .normal)
        stopButton.backgroundColor = .clear
        stopButton.setTitle("结束", for: .normal)
        stopButton.addTarget(self, action: #selector(stopButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(stopButton)
        
    }
    
    @objc func pushNextVC() {
        
        if self.isStart {
            
            self.presentSystemAlertVC(title: "警告", message: "修改配置会结束当前自动操作,是否确认结束并进入配置界面") {
                
            } okAction: {
                ZywlCommandModule.shareInstance.disconnectChargingBox()
                ZywlCommandModule.shareInstance.setIsNeedReconnect(state: false)
                self.isStart = false
                self.pushNextVC()
            }
            
            return
        }
        
        let vc = BoxFactoryConfigurationVC()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func failProcessButtonClick(sender:UIButton) {
        self.logView.clearString()
        self.logView.writeString(string: self.failProcessString)
    }
    
    @objc func clearCountButtonClick(sender:UIButton) {
        self.totalCount = 0
    }
    
    @objc func failConnectButtonClick(sender:UIButton) {
        self.logView.clearString()
        self.logView.writeString(string: self.failConnectString)
    }
    
    // MARK: - 启动
    @objc func startButtonClick(sender:UIButton) {
        
        if self.isStart {
            return
        }
        
        self.isStart = true
        ZywlCommandModule.shareInstance.setIsNeedReconnect(state: true)
        
        self.successCount = 0
        self.failConnectCount = 0
        self.failProcessCount = 0
        
        print("开始扫描")
        
        
        let userDefault = UserDefaults.standard
        let scanArray = userDefault.array(forKey: zycxScanNameKey)
        
        if scanArray == nil {
            self.isStart = false
            self.presentSystemAlertVC(title: "警告", message: "未设置需要扫描的设备名无法开始") {
                
            } okAction: {
                
                self.pushNextVC()
            }
        }else{
            self.scanDevice()
        }
    }
    
    // MARK: - 结束
    @objc func stopButtonClick(sender:UIButton) {
        self.isStart = false
        ZywlCommandModule.shareInstance.setIsNeedReconnect(state: false)
        self.singleProcessEndMethod()
        self.stateString = "未开启"
    }
    
    func scanDevice() {
        
        self.stateString = "开始扫描"
        let userDefault = UserDefaults.standard
        let scanArray = userDefault.array(forKey: zycxScanNameKey)
        
        ZywlCommandModule.shareInstance.scanDevice { (model) in
            //单个扫描到的model
            
            if self.failNameArray.contains(where: { failString in
                return failString.lowercased() == (model.name ?? "").lowercased()
            }) {
                return
            }
            
            if let filterArray = scanArray {
                if filterArray.contains(where: { filterString in
                    print("---------------->>>> model.name.lowercased() =",(model.name ?? "").lowercased(),"filterString =",filterString)
                    let filterString = filterString as! String
                    return (model.name ?? "").lowercased().contains(filterString.lowercased())
                }) {
                    if let uuidString = model.uuidString {
                        if self.filterUuidStringArray.contains(uuidString) {
                            
                        }else{
                            self.connectDevice(model: model)
                        }
                    }
                }
            }
            
        } modelArray: { (modelArray) in

        }
    }
    
    @objc func connectTimeout(model:ZywlScanModel) {

        self.singleProcessEndMethod()
        
        if let name = model.name {
            self.failNameArray.append(name)
        }
        self.failConnectCount += 1
        self.failConnectString = self.failConnectString + "\n\(model.name ?? "nil")\n\(model.peripheral?.identifier.uuidString)\n"
        print("self.failConnectString =",self.failConnectString)
        self.singleConnectCount = 0
    }
    
    var singleConnectCount = 0
    func connectDevice(model:ZywlScanModel) {

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(connectTimeout(model:)), object: model)
        self.perform(#selector(connectTimeout(model:)), with: model, afterDelay: 20)
        
        self.stateString = "正在连接\(model.name ?? "nil")"
        var callBackResult = false
        ZywlCommandModule.shareInstance.connectChargingBoxDevice(peripheral: model) { [weak self] result in
            
            if let self = self {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.connectTimeout(model:)), object: model)
                
                if result {
                    self.stateString = "连接成功\(model.name ?? "nil")"
                    print("连接成功恢复出厂设置")
                    
                    let userDefault = UserDefaults.standard
                    let appVersion = userDefault.string(forKey: zycxAppVersionKey)
                    let imageVersion = userDefault.string(forKey: zycxImageVersionKey)
                    let fontVersion = userDefault.string(forKey: zycxFontVersionKey)
                    let projectId = userDefault.string(forKey: zycxProjectIdKey)
                    let productId = userDefault.string(forKey: zycxProductIdKey)
                    
                    
                    if let newNameString = userDefault.string(forKey: zycxNewBleNameKey) {
                        if newNameString.count > 0 {
                            ZywlCommandModule.shareInstance.setZycxBleName(bleName: newNameString) { [weak self] error in
                                print("setZycxBleName error = \(error.rawValue)")
                                if let self = self {
                                    if error == .none {
                                        print("setBleName \(newNameString) success")
                                    }
                                }
                            }
                        }
                    }
                    
                    ZywlCommandModule.shareInstance.getZycxDeviceInfomation { model, error in
                        if callBackResult {
                            return
                        }
                        
                        if error == .none {
                            callBackResult = true
                            print("getZycxDeviceInfomation -> success")
                            
                            if let model = model {
                                let product = model.productId
                                let project = model.projectId
                                let firmware = model.firmwareVersion
                                let library = model.imageVersion
                                let font = model.fontVersion
                                
                                print("product ->",product)
                                print("project ->",project)
                                print("firmware ->",firmware)
                                print("library ->",library)
                                print("font ->",font)
                                
                                if productId != nil {
                                    if product != productId {
                                        if let uuidString = ZywlCommandModule.shareInstance.chargingBoxPeripheral?.identifier.uuidString {
                                            self.filterUuidStringArray.append(uuidString)
                                        }
                                        self.singleProcessEndMethod()
                                    }
                                }
                                
                                if projectId != nil {
                                    if project != projectId {
                                        if let uuidString = ZywlCommandModule.shareInstance.chargingBoxPeripheral?.identifier.uuidString {
                                            self.filterUuidStringArray.append(uuidString)
                                        }
                                        self.singleProcessEndMethod()
                                    }
                                }
                                
                                if appVersion != nil || imageVersion != nil || fontVersion != nil {
                                    if (appVersion == firmware && appVersion != nil) || (imageVersion == library && imageVersion != nil) || (fontVersion == font && fontVersion != nil) {
                                        if let uuidString = ZywlCommandModule.shareInstance.chargingBoxPeripheral?.identifier.uuidString {
                                            self.filterUuidStringArray.append(uuidString)
                                        }
                                        self.powerOffMethod()
                                    }else{
                                        self.sendNextOtaType()
                                    }
                                }else{
                                    self.sendNextOtaType()
                                }
                            }
                        }
                    }
                
                }else{
                    
                    if self.singleConnectCount < 3 {
                        self.singleConnectCount += 1
                        self.stateString = "第\(self.singleConnectCount)次连接失败\(model.name ?? "nil")"
                        self.connectDevice(model: model)
                        
                    }else{
                        
                        if let name = model.name {
                            self.failNameArray.append(name)
                        }
                        
                        self.failConnectCount += 1
                        self.failConnectString = self.failConnectString + "\n\(model.name ?? "nil")\n\(model.peripheral?.identifier.uuidString)\n"
                        print("self.failConnectString =",self.failConnectString)
                        self.singleConnectCount = 0
                        
                    }
                }
            }
            
        }
    }
    
    // MARK: - 发送下一个升级类型
    func sendNextOtaType() {
        print("下一个升级类型")
        
        let userDefault = UserDefaults.standard
        let sortArray = userDefault.array(forKey: zycxOtaSortKey)
        let model = ZywlScanModel.init()
        model.name = ZywlCommandModule.shareInstance.chargingBoxPeripheral?.name
        model.peripheral = ZywlCommandModule.shareInstance.chargingBoxPeripheral
        
        if let recordIndex = self.recordIndex {
            
            if let sortArray:[Int] = sortArray as? [Int] {
                
                if recordIndex < sortArray.count - 1 {
                    self.setOtaMethod(type: sortArray[recordIndex+1],model: model)
                }else{
                    self.powerOffMethod()
                }
            }
            
        }else{
            self.setOtaMethod(type: nil,model: model)
        }
        
    }
    
    // MARK: - 检查升级
    func checkOtaMethod(model:ZywlScanModel) {
        let userDefault = UserDefaults.standard
        let sortArray = userDefault.array(forKey: zycxOtaSortKey)
        
        ZywlCommandModule.shareInstance.checkUpgradeState { [weak self] success, error in
            print("继续升级")

            if let self = self {
                if error == .none {
                    print("success.keys.count =",success.keys.count)
                    //检测到正在升级且没有继续升级的data
                    if success.keys.count > 0 {
                        
                        let type = success["type"] as! String
                        var fileString:String?
                        if type == "1" {
                            fileString = userDefault.string(forKey: zycxApplicationKey)
                        }else if type == "2" {
                            fileString = userDefault.string(forKey: zycxLibraryKey)
                        }else if type == "3" {
                            fileString = userDefault.string(forKey: zycxFontKey)
                        }else if type == "4" {
                            fileString = userDefault.string(forKey: zycxDialKey)
                        }
                        
                        var currentIndex = 0
                        if let sortArray:[Int] = sortArray as? [Int] {
                            currentIndex = sortArray.firstIndex(of: (Int(type) ?? 0)) ?? -1
                        }
                        
                        if fileString == nil {
                            
                            if let recordIndex = self.recordIndex {
                                
                                if let sortArray:[Int] = sortArray as? [Int] {
                                    
                                    if recordIndex < sortArray.count - 1 {
                                        self.setOtaMethod(type: sortArray[recordIndex+1],model: model)
                                    }else{
                                        self.powerOffMethod()
                                    }
                                }
                                
                            }else{
                                self.setOtaMethod(type: nil,model: model)
                            }

                        }else{
                            print("检测到升级未完成,继续升级  此方法大概率是不会调用的")
                            self.stateString = "检测到升级未完成,继续升级"
                            let homePath = NSHomeDirectory()
                            fileString = homePath + fileString!
                            ZywlCommandModule.shareInstance.setOtaStartUpgrade(type: Int(type) ?? 0, localFile: fileString!, isContinue: true) { progress in
                                
                                print("progress =",progress)
                                self.stateString = "\(self.getOtaTypeString(type: Int(type) ?? 0))\(progress)"

                            } success: { error in
                                
                                if error == .none {
                                    
                                    self.stateString = "\(self.getOtaTypeString(type: Int(type) ?? 0))完成"
                                    self.recordIndex = currentIndex
                                    
                                    if let sortArray:[Int] = sortArray as? [Int] {
                                        
                                        if currentIndex < sortArray.count - 1 {
                                            self.setOtaMethod(type: sortArray[currentIndex+1],model: model)
                                        }else{
                                            self.powerOffMethod()
                                        }
                                    }
                                    
                                } else {
                                    self.stateString = "\(self.getOtaTypeString(type: Int(type) ?? 0))失败"
                                    self.failProcessCount += 1
                                    self.failProcessString = self.failProcessString+"\n\(model.name ?? "nil")\n\(model.peripheral?.identifier.uuidString)\nerror.rawValue:\(error.rawValue)\ntype:\(type)\n"
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                                        self.singleProcessEndMethod()
                                    }
                                    
                                }
                            }
                        }
                    }else{
                        if let recordIndex = self.recordIndex{
                            
                            if let sortArray:[Int] = sortArray as? [Int] {
                                
                                if recordIndex < sortArray.count {
                                    self.setOtaMethod(type: sortArray[recordIndex],model: model)
                                }else{
                                    self.powerOffMethod()
                                }
                            }
                            
                        }else{
                            self.setOtaMethod(type: nil,model: model)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 升级部分
    func setOtaMethod(type:Int? = nil,model:ZywlScanModel) {
        let userDefault = UserDefaults.standard
        let sortArray = userDefault.array(forKey: zycxOtaSortKey)
        print("sortArray =",sortArray)
        
        var fileString:String?
        
        var currentIndex = 0
        
        if let sortArray:[Int] = sortArray as? [Int] {
            if let type = type {
                currentIndex = sortArray.firstIndex(of: type) ?? -1
            }
        }
        
        print("type =",type)
        print("currentIndex =",currentIndex)
        
        if let type = type {
            
            if type == 1 {
                fileString = userDefault.string(forKey: zycxApplicationKey)
            }else if type == 2 {
                fileString = userDefault.string(forKey: zycxLibraryKey)
            }else if type == 3 {
                fileString = userDefault.string(forKey: zycxFontKey)
            }else if type == 4 {
                fileString = userDefault.string(forKey: zycxDialKey)
            }

            if fileString != nil {
                
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString!
                
                print("开始升级 type = \(type) , localFile = \(fileString)")
                //self.isNeedCheckOtaMethod = false
                ZywlCommandModule.shareInstance.setOtaStartUpgrade(type: type , localFile: fileString as Any, isContinue: false) { progress in

                    print("progress ->",progress)
                    self.stateString = "\(self.getOtaTypeString(type: type))\(progress)"
                    
                } success: { error in

                    print("setOtaStartUpgrade -> error =",error.rawValue)
                    if error == .none {
                        
                        self.stateString = "\(self.getOtaTypeString(type: Int(type) ?? 0))完成"
                        
                        if let sortArray:[Int] = sortArray as? [Int] {
                            if currentIndex < sortArray.count - 1 {
                                self.recordIndex = currentIndex+1
                                self.setOtaMethod(type: sortArray[currentIndex+1],model: model)
                                //self.isNeedCheckOtaMethod = true
                            }else{
                                DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                                    if ZywlCommandModule.shareInstance.chargingBoxPeripheral?.state == .connected {
                                        self.powerOffMethod()
                                    }else{
                                        self.isNeedCheckOtaMethod = true
                                    }
                                }
                            }
                        }
                        
                    }else {
                        self.stateString = "\(self.getOtaTypeString(type: type))失败"
                        self.failProcessCount += 1
                        self.failProcessString = self.failProcessString+"\n\(model.name ?? "nil")\n\(model.peripheral?.identifier.uuidString)\nerror.rawValue:\(error.rawValue)\ntype:\(type)\n"
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                            self.singleProcessEndMethod()
                        }
                        
                    }
                    
                    
                }
                
            }else{
                
                if let sortArray:[Int] = sortArray as? [Int] {
                    self.recordIndex = currentIndex + 1
                    if currentIndex < sortArray.count - 1 {
                        self.setOtaMethod(type: sortArray[currentIndex+1],model: model)
                    }else{
                        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                            if ZywlCommandModule.shareInstance.chargingBoxPeripheral?.state == .connected {
                                self.powerOffMethod()
                            }else{
                                self.isNeedCheckOtaMethod = true
                            }
                        }
                    }
                }
            }
        }else{
            if let sortArray:[Int] = sortArray as? [Int] {
                self.setOtaMethod(type: sortArray[0],model: model)
            }
            
        }

    }
    
    // MARK: - 关机
    func powerOffMethod() {
        let userDefault = UserDefaults.standard
        let result = userDefault.bool(forKey: zycxPowerOffKey)
        
        if result {
            ZywlCommandModule.shareInstance.setZycxResetFactoryAndPowerOff { [weak self] error in
                print("关机 setZycxResetFactoryAndPowerOff error = \(error.rawValue)")
                if let self = self {
                    if error == .none {
                        self.stateString = "恢复出厂并关机成功"
                        self.successCount += 1
                        self.totalCount += 1
                        self.singleProcessEndMethod()
                    }else{
                        ZywlCommandModule.shareInstance.setZycxPowerOff { error in
                            print("关机")
                            
                            self.stateString = "关机成功"
                            self.successCount += 1
                            self.totalCount += 1
                            self.singleProcessEndMethod()
                        }
                    }
                }
            }
        }else{
            if let uuidString = ZywlCommandModule.shareInstance.chargingBoxPeripheral?.identifier.uuidString {
                self.filterUuidStringArray.append(uuidString)
            }
            ZywlCommandModule.shareInstance.disconnectChargingBox()
            self.successCount += 1
            self.totalCount += 1
            self.singleProcessEndMethod()
        }
    }
    
    func singleProcessEndMethod() {
        self.stateString = "单次操作结束,开始下一轮"
        self.recordIndex = nil
        ZywlCommandModule.shareInstance.disconnectChargingBox()
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            if self.isStart {
                self.scanDevice()
            }
        }
    }
    
    func getOtaTypeString(type:Int) -> String {
        var otaString = ""
        
        if type == 1 {
            otaString = "应用升级"
        }else if type == 2 {
            otaString = "图库升级"
        }else if type == 3 {
            otaString = "字库升级"
        }else if type == 4 {
            otaString = "表盘升级"
        }
        
        return otaString
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
    
}
