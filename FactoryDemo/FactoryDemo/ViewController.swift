//
//  ViewController.swift
//  FactoryDemo
//
//  Created by 猜猜我是谁 on 2022/1/8.
//

import UIKit
import AntSDK

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let StatusBarHeight = UIApplication.shared.statusBarFrame.height

let ScanNameKey = "hc_scanNameKey"
let BootKey = "0_BootFiles"
let ApplicationKey = "1_ApplicationFiles"
let LibraryKey = "2_LibraryFiles"
let FontKey = "3_FontFiles"
let DialKey = "4_DialFiles"
let OtaSortKey = "hc_otaSortKey"

class ViewController: UIViewController {

    var isStart = false
    var failNameArray:[String] = Array.init()
    let logView = ShowLogView.init(frame: .init(x: 0, y: StatusBarHeight+44, width: screenWidth, height: screenHeight-StatusBarHeight-44))
    var recordIndex:Int? = nil
    var isNeedCheckOtaMethod = false   //升级过程中异常断开需要在重连之后检测升级状态，  升级结束之后设备自动断开的那种重连不需要检测
    var scanNameLabel:UILabel!
    
    var connectCountLabel:UILabel!
    var failConnectCount = 0 {
        didSet {
            self.connectCountLabel.text = "3次连接失败次数:\(self.failConnectCount)"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "自动扫描发送"
        
        let rightItem = UIBarButtonItem.init(title: "配置", style: .done, target: self, action: #selector(pushNextVC))
        self.navigationItem.rightBarButtonItem = rightItem
                
        self.createView()
        
        self.logView.isHidden = true
        self.view.addSubview(self.logView)
        
        AntCommandModule.shareInstance.reconnectDevice {
            let model = AntScanModel.init()
            model.name = AntCommandModule.shareInstance.peripheral?.name
            model.peripheral = AntCommandModule.shareInstance.peripheral
            //升级过程中异常断开需要在重连之后检测升级状态，  升级结束之后设备自动断开的那种重连不需要检测
            if self.isNeedCheckOtaMethod {
                print("重连完成监测升级")
                self.checkOtaMethod(model: model)
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        let userDefault = UserDefaults.standard
        
        let scanArray = userDefault.array(forKey: ScanNameKey)
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
        self.scanNameLabel.text = "自动连接的设备名:\(scanNameString)"
        
        self.stateString = "未开启"
        
        var processString = ""
        
        let sortArray = userDefault.array(forKey: OtaSortKey)
        if let sortArray:[Int] = sortArray as? [Int] {
            for item in sortArray {
                if item == 0 {
                    let bootPath = userDefault.string(forKey: BootKey)
                    if let path = bootPath {
                        processString = processString+"->0引导文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
                    }
                }
                if item == 1 {
                    let applicationPath = userDefault.string(forKey: ApplicationKey)
                    if let path = applicationPath {
                        processString = processString+"->1应用文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
                    }
                }
                if item == 2 {
                    let libraryPath = userDefault.string(forKey: LibraryKey)
                    if let path = libraryPath {
                        processString = processString+"->2图库文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
                    }
                }
                if item == 3 {
                    let fontPath = userDefault.string(forKey: FontKey)
                    if let path = fontPath {
                        processString = processString+"->3字库文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
                    }
                }
                if item == 4 {
                    let dialPath = userDefault.string(forKey: DialKey)
                    if let path = dialPath {
                        processString = processString+"->4表盘文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
                    }
                    processString = processString+"->关机"
                }
            }
        }

        self.configurationLabel.text = "配置选项流程:"+processString
    }
    
    func createView() {
        
        let scanNameLabel = UILabel.init(frame: .init(x: 0, y: 40+StatusBarHeight+10, width: screenWidth, height: 44))
        scanNameLabel.backgroundColor = .clear
        scanNameLabel.textColor = .black
        scanNameLabel.text = "自动连接的设备名"
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
        
        let successCountLabel = UILabel.init(frame: .init(x: 0, y: currentStateLabel.frame.maxY+10, width: screenWidth, height: 44))
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
        connectCountLabel.text = "3次连接失败次数:0"
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
        
        let startButton = UIButton.init(frame: .init(x: 0, y: 450, width: screenWidth/2.0, height: 44))
        startButton.setTitleColor(.black, for: .normal)
        startButton.backgroundColor = .clear
        startButton.setTitle("开始", for: .normal)
        startButton.addTarget(self, action: #selector(startButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(startButton)

        let stopButton = UIButton.init(frame: .init(x: screenWidth/2.0, y: 450, width: screenWidth/2.0, height: 44))
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
                self.isStart = false
                self.pushNextVC()
            }
            
            return
        }
        
        let vc = ConfigurationVC()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func failProcessButtonClick(sender:UIButton) {
        self.logView.clearString()
        self.logView.writeString(string: self.failProcessString)
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
        AntCommandModule.shareInstance.setIsNeedReconnect(state: true)
        
        self.successCount = 0
        self.failConnectCount = 0
        self.failProcessCount = 0
        
        print("开始扫描")
        
        
        let userDefault = UserDefaults.standard
        let scanArray = userDefault.array(forKey: ScanNameKey)
        
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
        AntCommandModule.shareInstance.setIsNeedReconnect(state: false)
        self.singleProcessEndMethod()
        self.stateString = "未开启"
    }
    
    func scanDevice() {
        
        self.stateString = "开始扫描"
        let userDefault = UserDefaults.standard
        let scanArray = userDefault.array(forKey: ScanNameKey)
        
        AntCommandModule.shareInstance.scanDevice { (model) in
            //单个扫描到的model
            
            if self.failNameArray.contains(where: { failString in
                return failString.lowercased() == (model.name ?? "").lowercased()
            }) {
                return
            }
            
            if let filterArray = scanArray {
                if filterArray.contains(where: { filterString in
                    let filterString = filterString as! String
                    return (model.name ?? "").lowercased().contains(filterString.lowercased())
                }) {
                    self.connectDevice(model: model)
                }
            }
            
        } modelArray: { (modelArray) in

        }
    }
    
    @objc func connectTimeout(model:AntScanModel) {

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
    func connectDevice(model:AntScanModel) {

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(connectTimeout(model:)), object: nil)
        self.perform(#selector(connectTimeout(model:)), with: nil, afterDelay: 60)
        
        self.stateString = "正在连接\(model.name ?? "nil")"
        AntCommandModule.shareInstance.connectDevice(peripheral: model) { result in
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.connectTimeout(model:)), object: nil)
            
            if result {
                self.stateString = "连接成功\(model.name ?? "nil")"
                print("连接成功恢复出厂设置")
                
                AntCommandModule.shareInstance.SetFactoryDataReset { error in
                    if error == .none {
                        self.stateString = "恢复出厂设置成功"
                        print("恢复出厂设置成功")
                        self.isNeedCheckOtaMethod = true
                    }else{
                        self.stateString = "恢复出厂设置失败"
                        print("恢复出厂设置失败")
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
    
    // MARK: - 检查升级
    func checkOtaMethod(model:AntScanModel) {
        let userDefault = UserDefaults.standard
        let sortArray = userDefault.array(forKey: OtaSortKey)
        
        AntCommandModule.shareInstance.checkUpgradeState { success, error in
            print("继续升级")

            if error == .none {
                print("success.keys.count =",success.keys.count)
                if success.keys.count > 0 {
                    
                    let type = success["type"] as! String
                    var fileString:String?
                    if type == "0" {
                        fileString = userDefault.string(forKey: BootKey)
                    }else if type == "1" {
                        fileString = userDefault.string(forKey: ApplicationKey)
                    }else if type == "2" {
                        fileString = userDefault.string(forKey: LibraryKey)
                    }else if type == "3" {
                        fileString = userDefault.string(forKey: FontKey)
                    }else if type == "4" {
                        fileString = userDefault.string(forKey: DialKey)
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
                        self.stateString = "检测到升级未完成,继续升级"
                        let homePath = NSHomeDirectory()
                        fileString = homePath + fileString!
                        AntCommandModule.shareInstance.setStartUpgrade(type: Int(type) ?? 0, localFile: fileString!, maxCount: 20, isContinue: true) { progress in

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
            }
        }
    }
    
    // MARK: - 升级部分
    func setOtaMethod(type:Int? = nil,model:AntScanModel) {
        let userDefault = UserDefaults.standard
        let sortArray = userDefault.array(forKey: OtaSortKey)
        print("sortArray =",sortArray)
        
        var fileString:String?
        
        var currentIndex = 0
        
        if let sortArray:[Int] = sortArray as? [Int] {
            if let type = type {
                currentIndex = sortArray.firstIndex(of: type) ?? -1
            }
        }
        self.recordIndex = currentIndex
        
        print("type =",type)
        print("currentIndex =",currentIndex)
        
        if let type = type {
            
            if type == 0 {
                fileString = userDefault.string(forKey: BootKey)
            }else if type == 1 {
                fileString = userDefault.string(forKey: ApplicationKey)
            }else if type == 2 {
                fileString = userDefault.string(forKey: LibraryKey)
            }else if type == 3 {
                fileString = userDefault.string(forKey: FontKey)
            }else if type == 4 {
                fileString = userDefault.string(forKey: DialKey)
            }

            if fileString != nil {
                
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString!
                self.isNeedCheckOtaMethod = true
                
                AntCommandModule.shareInstance.setOtaStartUpgrade(type: type , localFile: fileString as Any, isContinue: false) { progress in

                    print("progress ->",progress)
                    self.stateString = "\(self.getOtaTypeString(type: type))\(progress)"
                    
                } success: { error in

                    print("setOtaStartUpgrade -> error =",error.rawValue)
                    if error == .none {
                        self.isNeedCheckOtaMethod = false
                        self.stateString = "\(self.getOtaTypeString(type: Int(type) ?? 0))完成"
                        
                        if let sortArray:[Int] = sortArray as? [Int] {
                            
                            if currentIndex < sortArray.count - 1 {
                                //此处升级完成之后有些是设备会类似重启再次断开，重连过快发下一个类型的时候设备自动断开了。延时等设备重连成功之后再发下一个类型
                                DispatchQueue.main.asyncAfter(deadline: .now()+10) {
                                    self.setOtaMethod(type: sortArray[currentIndex+1],model: model)
                                }
                            }else{
                                self.powerOffMethod()
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
                        self.powerOffMethod()
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
        AntCommandModule.shareInstance.SetPowerTurnOff { error in
            print("关机")
            
            self.stateString = "关机成功"
            self.successCount += 1
            self.singleProcessEndMethod()
        }
    }
    
    func singleProcessEndMethod() {
        self.stateString = "单次操作结束,开始下一轮"
        self.recordIndex = nil
        AntCommandModule.shareInstance.disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            if self.isStart {
                self.scanDevice()
            }
        }
    }
    
    func getOtaTypeString(type:Int) -> String {
        var otaString = ""
        
        if type == 0 {
            otaString = "引导升级"
        }else if type == 1 {
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
        
        let cancelAC = UIAlertAction.init(title: cancel, style: .default) { (action) in
            if let cancelAction = cancelAction{
                cancelAction()
            }
        }
        //cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        let okAC = UIAlertAction.init(title: ok, style: .default) { (action) in
            if let okAction = okAction{
                okAction()
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
}
