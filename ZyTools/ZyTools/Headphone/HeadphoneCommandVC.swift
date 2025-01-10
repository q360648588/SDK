//
//  HeadphoneCommandVC.swift
//  ZyTools
//
//  Created by 猜猜我是谁 on 2024/4/25.
//

import UIKit

class HeadphoneCommandVC: UIViewController {

    var currentBleState:CBPeripheralState! {
        didSet {
            if self.currentBleState == .disconnected {
                self.title = "disconnected"
            }else if self.currentBleState == .connecting {
                self.title = "connecting"
            }else if self.currentBleState == .connected {
                self.title = "connected"
            }else if self.currentBleState == .disconnecting {
                self.title = "disconnecting"
            }
        }
    }
    var ancsState:Bool = false
    var tableView:UITableView!
    var dataSourceArray = [[String]].init()
    var titleArray = [String].init()
    var logView:ShowLogView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentBleState = ZywlCommandModule.shareInstance.headphonePeripheral?.state ?? .disconnected
        
        ZywlCommandModule.shareInstance.peripheralStateChange { [weak self] isHeadphone, state in
            self?.currentBleState = state
        }
        
        if #available(iOS 13.0, *) {
            if let state = ZywlCommandModule.shareInstance.headphonePeripheral?.ancsAuthorized {
                self.ancsState = state
            }
        }
        ZywlCommandModule.shareInstance.bluetoothAncsStateChange { [weak self] state in
            self?.ancsState = state
        }
        
            //        ZywlCommandModule.shareInstance.checkUpgradeState { success, error in
            //            print("继续升级")
            //
            //            if error == .none {
            //                print("success.keys.count =",success.keys.count)
            //                if success.keys.count > 0 {
            //                    self.presentSystemAlertVC(title: NSLocalizedString("Warning", comment: "警告"), message: NSLocalizedString("The current device is being upgraded. Do you want to continue upgrading? (Timeout option will exit upgrade)", comment: "检测到当前设备正在升级，是否继续升级？(超时选择将退出升级)")) {
            //                        ZywlCommandModule.shareInstance.setStopUpgrade { error in
            //                            print("退出升级")
            //                        }
            //                    } okAction: {
            //
            //                        let type = success["type"] as! String
            //                        let fileString = self.getFilePathWithType(type: type)
            //
            //                        var showProgress = 0
            //                        ZywlCommandModule.shareInstance.setStartUpgrade(type: Int(type) ?? 0, localFile: fileString, maxCount: 20, isContinue: true) { progress in
            //
            //                            print("progress =",progress)
            //                            if showProgress == Int(progress) {
            //                                showProgress += 1
            //                                self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
            //                            }
            //
            //                        } success: { error in
            //
            //                            self.logView.writeString(string: self.getErrorCodeString(error: error))
            //                            print("setStartUpgrade -> error =",error.rawValue)
            //                        }
            //                    }
            //                }
            //            }
            //        }
        
        let rightItem = UIBarButtonItem.init(title: "→", style: .done, target: self, action: #selector(pushNextVC))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.tableView = UITableView.init(frame: .init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.logView = ShowLogView.init(frame: .init(x: 0, y: 44 + StatusBarHeight, width: screenWidth, height: screenHeight - (44 + StatusBarHeight)))
        self.logView.isHidden = true
        self.view.addSubview(self.logView)
        
        self.loadData()
        
    }
    
    func loadData() {
        self.titleArray.removeAll()
        self.dataSourceArray.removeAll()
        
        self.titleArray = [
            "分包信息",
            "功能列表",
            "设备信息",
            "参数获取",
            "参数设置",
            "设备控制",
            "状态查询",
            "主动上报",
        ]
        self.dataSourceArray = [
            [
                "获取本机支持的最大MTU长度",
                "同步设备支持的最大MTU长度",
            ],
            [
                "功能列表",
            ],
            [
                "设备信息",
            ],
            [
                "参数获取(全部)",
                "参数获取(自选)",
                "获取自定义按键",
                "获取EQ模式",
                "获取自定义EQ音效",
                "获取环境音效",
                "获取空间音效",
                "获取入耳感知",
                "获取极速模式",
                "获取抗风噪模式",
                "获取低音增强模式",
                "获取低频增强模式",
                "获取对联模式",
                "获取桌面模式",
                "获取摇一摇切歌模式",
                "获取耳机音量",
                "获取耳机电量",
                "获取音效模式",
                "获取信号模式",
            ],
            [
                "设置自定义按键",
                "设置EQ模式",
                "设置自定义EQ音效",
                "设置环境音效",
                "设置空间音效",
                "设置入耳感知",
                "设置极速模式",
                "设置抗风噪模式",
                "设置低音增强模式",
                "设置低频增强模式",
                "设置对联模式",
                "设置摇一摇切歌模式",
                "设置耳机音量",
                "设置耳机电量",
                "设置音效模式",
                "设置信号模式",
            ],
            [
                "关机",
                "重启",
                "恢复出厂设置",
                "恢复出厂设置后关机",
                "抖音控制",
                "音乐控制",
                "来电控制(挂断接听)",
                "来电控制(DTMF/拨号)",
                "来电控制(音量调节)",
                "寻找耳机",
                "拍照",
                "双耳自定义按键恢复默认",
            ],
            [
                "耳机电量",
                "音乐状态",
                "当前时间",
                "经典蓝牙连接状态",
                "TWS是否配对"
            ],
            [
                "主动上报"
            ],
        ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func pushNextVC() {
        let vc = LogViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func getErrorCodeString(error:ZywlError) -> String {
        if error == .none {
            return "成功 none"
        }else if error == .disconnected {
            return "设备未连接 disconnected"
        }else if error == .invalidCharacteristic {
            return "无效特征值 invalidCharacteristic"
        }else if error == .invalidLength {
            return "无效数据长度 invalidLength"
        }else if error == .invalidState {
            return "无效状态 invalidState"
        }else if error == .notSupport {
            return "不支持此功能"
        }
        return "未知error"
    }

}

extension HeadphoneCommandVC:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.titleArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionArray = self.dataSourceArray[section]
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UILabel.init(frame: .init(x: 0, y: 0, width: screenWidth, height: 50))
        view.backgroundColor = .gray//ViewBgColor
        view.isUserInteractionEnabled = true
        
        let label = UILabel.init(frame: .init(x: 20, y: 0, width: screenWidth-40, height: 50))
        label.text = self.titleArray[section]
        view.addSubview(label)

        return view
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "headphoneCommandCell") ?? UITableViewCell.init(style: .default, reuseIdentifier: "headphoneCommandCell")
        
        let sectionArray = self.dataSourceArray[indexPath.section]
        cell.textLabel?.text = sectionArray[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionArray = self.dataSourceArray[indexPath.section]
        let rowString = sectionArray[indexPath.row]
        let vc = LogViewController.init()
        
        print("didSelectRowAt -> date =",Date.init())
        
        self.logView.clearString()
        self.logView.writeString(string: rowString)
        
        switch rowString {
        case "获取手机支持的最大MTU长度":
            let maxMtu = ZywlCommandModule.shareInstance.getHeadphonePhoneMaxMtu()
            let logString = "获取本机支持的最大MTU长度:\(maxMtu)"
            self.logView.writeString(string: logString)
            print(logString)
            break
            
        case "同步设备支持的最大MTU长度":
            
            let array = [
                "mtu长度,默认本机最大长度"
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let maxMtu = textArray[0].count > 0 ? (Int(textArray[0]) ?? 20) : ZywlCommandModule.shareInstance.getPhoneMaxMtu()
                self.logView.writeString(string: "设置的mtu长度:\(maxMtu)")
                ZywlCommandModule.shareInstance.getZycxHeadphoneSubcontractingInfomation(maxValue: maxMtu) { count, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "getZycxHeadphoneSubcontractingInfomation -> \(count)"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
            
        case "功能列表":
            
            ZywlCommandModule.shareInstance.getZycxHeadphoneFunctionList(isForwardingData: false) { functionModel, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let functionModel = functionModel {
                        self.logView.writeString(string: functionModel.showAllSupportFunctionLog())
                    }
                }
            }
            
            break
        case "设备信息":
            
            ZywlCommandModule.shareInstance.getZycxHeadphoneDeviceInfomation(isForwardingData: false) { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        
                        let deviceName = model.deviceName
                        let mac_ble = model.mac_ble
                        let serialNumber = model.serialNumber
                        let hardwareVersion = model.hardwareVersion
                        let softwareVersion = model.softwareVersion
                        let bleName = model.bleName
                        let mac_br = model.mac_br
                        let bleName_br = model.bleName_br

                        let logString =
                                        """
                                        
                                        deviceName = \(deviceName)
                                        mac_ble = \(mac_ble)
                                        serialNumber = \(serialNumber)
                                        hardwareVersion = \(hardwareVersion)
                                        softwareVersion = \(softwareVersion)
                                        bleName = \(bleName)
                                        mac_br = \(mac_br)
                                        bleName_br = \(bleName_br)
                                        """
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "参数获取(全部)":
            
            ZywlCommandModule.shareInstance.getZycxHeadphoneDeviceParameters(isForwardingData: false) { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        
                        let customButtonList = model.customButtonList
                        var buttonString = ""
                        for item in customButtonList {
                            buttonString += "\nheadphoneType:\(item.headphoneType),touchType:\(item.touchType),commandType:\(item.commandType)"
                        }
                        let eqMode = model.eqMode
                        var customEqString = ""
                        if let customModel = model.customEqModel {
                            customEqString += "\ntotalBuff:\(customModel.totalBuff),count:\(customModel.eqListArray.count)"
                            for item in customModel.eqListArray {
                                customEqString += "\nfrequency:\(item.frequency),buff:\(item.buff),Qvalue:\(item.Qvalue),type:\(item.type)"
                            }
                        }
                        
                        let ambientSoundEffect = model.ambientSoundEffect
                        let spaceSoundEffect = model.spaceSoundEffect
                        let inEarPerception = model.inEarPerception
                        let extremeSpeedMode = model.extremeSpeedMode
                        var windNoiseResistantMode = model.windNoiseResistantMode
                    
                        let bassToneEnhancement = model.bassToneEnhancement
                        let lowFrequencyEnhancement = model.lowFrequencyEnhancement
                        let coupletPattern = model.coupletPattern
                        let desktopMode = model.desktopMode
                        let shakeSong = model.shakeSong
                        let voiceVolume = model.voiceVolume
                        let leftBattery = model.leftBattery
                        let rightBattery = model.rightBattery
                        let soundEffectMode = model.soundEffectMode
                        let patternMode = model.patternMode
                        
                        let logString = """
                                        buttonList = \(buttonString)
                                        eqeqMode = \(eqMode)
                                        customEqString = \(customEqString)
                                        ambientSoundEffect = \(ambientSoundEffect)
                                        spaceSoundEffect = \(spaceSoundEffect)
                                        inEarPerception = \(inEarPerception)
                                        extremeSpeedMode = \(extremeSpeedMode)
                                        windNoiseResistantMode = \(windNoiseResistantMode)
                                        bassToneEnhancement = \(bassToneEnhancement)
                                        lowFrequencyEnhancement = \(lowFrequencyEnhancement)
                                        coupletPattern = \(coupletPattern)
                                        desktopMode = \(desktopMode)
                                        shakeSong = \(shakeSong)
                                        voiceVolume = \(voiceVolume)
                                        leftBattery = \(leftBattery)
                                        rightBattery = \(rightBattery)
                                        soundEffectMode = \(soundEffectMode)
                                        patternMode = \(patternMode)
                                        """
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "参数获取(自选)":
            
            let array = [
                "参数id,多个参数以英文逗号','隔开"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                var parameterArray = [Int]()
                let parameterString:String = textArray[0]
                let componentArray = parameterString.components(separatedBy: ",")
                for i in 0..<componentArray.count {
                    if let value = Int(componentArray[i]) {
                        parameterArray.append(value)
                    }
                }
                
                if parameterArray.count <= 0 {
                    parameterArray = [0]
                }
                self.logView.writeString(string: "获取参数数组:\(parameterArray)")
                ZywlCommandModule.shareInstance.getZycxHeadphoneDeviceParameters(isForwardingData: false, listArray: parameterArray) { model, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        if let model = model {
                            
                            let customButtonList = model.customButtonList
                            var buttonString = ""
                            for item in customButtonList {
                                buttonString += "\nheadphoneType:\(item.headphoneType),touchType:\(item.touchType),commandType:\(item.commandType)"
                            }
                            let eqMode = model.eqMode
                            var customEqString = ""
                            if let customModel = model.customEqModel {
                                customEqString += "\ntotalBuff:\(customModel.totalBuff),count:\(customModel.eqListArray.count)"
                                for item in customModel.eqListArray {
                                    customEqString += "\nfrequency:\(item.frequency),buff:\(item.buff),Qvalue:\(item.Qvalue),type:\(item.type)"
                                }
                            }
                            let ambientSoundEffect = model.ambientSoundEffect
                            let spaceSoundEffect = model.spaceSoundEffect
                            let inEarPerception = model.inEarPerception
                            let extremeSpeedMode = model.extremeSpeedMode
                            var windNoiseResistantMode = model.windNoiseResistantMode
                        
                            let bassToneEnhancement = model.bassToneEnhancement
                            let lowFrequencyEnhancement = model.lowFrequencyEnhancement
                            let coupletPattern = model.coupletPattern
                            let desktopMode = model.desktopMode
                            let shakeSong = model.shakeSong
                            let voiceVolume = model.voiceVolume
                            let leftBattery = model.leftBattery
                            let rightBattery = model.rightBattery
                            
                            var logString = ""
                            if parameterArray.contains(0) {
                                logString += "\nbuttonString = \(buttonString)"
                            }
                            if parameterArray.contains(1) {
                                logString += "\neqMode = \(eqMode)"
                            }
                            if parameterArray.contains(2) {
                                logString += "\ncustomEqString = \(customEqString)"
                            }
                            if parameterArray.contains(3) {
                                logString += "\nambientSoundEffect = \(ambientSoundEffect)"
                            }
                            if parameterArray.contains(4) {
                                logString += "\nspaceSoundEffect = \(spaceSoundEffect)"
                            }
                            if parameterArray.contains(5) {
                                logString += "\ninEarPerception = \(inEarPerception)"
                            }
                            if parameterArray.contains(6) {
                                logString += "\nextremeSpeedMode = \(extremeSpeedMode)"
                            }
                            if parameterArray.contains(7) {
                                logString += "\nwindNoiseResistantMode = \(windNoiseResistantMode)"
                            }
                            if parameterArray.contains(8) {
                                logString += "\nbassToneEnhancement = \(bassToneEnhancement)"
                            }
                            if parameterArray.contains(9) {
                                logString += "\nlowFrequencyEnhancement = \(lowFrequencyEnhancement)"
                            }
                            if parameterArray.contains(10) {
                                logString += "\ncoupletPattern = \(coupletPattern)"
                            }
                            if parameterArray.contains(11) {
                                logString += "\ndesktopMode = \(desktopMode)"
                            }
                            if parameterArray.contains(12) {
                                logString += "\nshakeSong = \(shakeSong)"
                            }
                            if parameterArray.contains(13) {
                                logString += "\nvoiceVolume = \(voiceVolume)"
                            }
                            if parameterArray.contains(14) {
                                logString += "\nleftBattery = \(leftBattery),rightBattery = \(rightBattery)"
                            }
                            print(logString)
                            self.logView.writeString(string: logString)
                        }
                    }
                }
            }
            
            break
        case "获取自定义按键":
            ZywlCommandModule.shareInstance.getZycxHeadphoneCustomButtonList(isForwardingData: false) { listArray, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    var buttonString = ""
                    for item in listArray {
                        buttonString += "\nheadphoneType:\(item.headphoneType),touchType:\(item.touchType),commandType:\(item.commandType)"
                    }
                    let logString = "listArray = \(buttonString)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取EQ模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneEqMode(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取自定义EQ音效":
            ZywlCommandModule.shareInstance.getZycxHeadphoneCustomEq(isForwardingData: false) { listArray, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
            }
            break
        case "获取环境音效":
            ZywlCommandModule.shareInstance.getZycxHeadphoneAmbientSoundEffect(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取空间音效":
            ZywlCommandModule.shareInstance.getZycxHeadphoneSpaceSoundEffect(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取入耳感知":
            ZywlCommandModule.shareInstance.getZycxHeadphoneInEarPerception(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取极速模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneExtremeSpeedMode(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取抗风噪模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneWindNoiseResistantMode(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取低音增强模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneBassToneEnhancement(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取低频增强模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneLowFrequencyEnhancement(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取对联模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneCoupletPattern(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取桌面模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneDesktopMode(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "获取摇一摇切歌模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneShakeSong(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取耳机音量":
            ZywlCommandModule.shareInstance.getZycxHeadphoneVoiceVolume(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取耳机电量":
            ZywlCommandModule.shareInstance.getZycxHeadphoneBattery(isForwardingData: false) { leftBattery, rightBattery, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "leftBattery = \(leftBattery),rightBattery = \(rightBattery)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取音效模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneSoundEffectMode { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取信号模式":
            ZywlCommandModule.shareInstance.getZycxHeadphonePatternMode { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
            
        case "设置自定义按键":
            let array = [
                "默认0,左耳0右耳1",
                "默认0,单击0双击1三击2长按3",
                "默认0,功能ID",
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n功能ID:0无功能1播放暂停2上一曲3下一曲4音量+5音量-6来电接听7来电拒绝8挂断电话9环境音切换10唤醒语音助手11回拨电话12eq切换13游戏模式切换", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let headphoneType = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                let touchType = textArray[1].count > 0 ? (Int(textArray[1]) ?? 0) : 0
                let commandType = textArray[2].count > 0 ? (Int(textArray[2]) ?? 0) : 0
                self.logView.writeString(string: "headphoneType:\(headphoneType)")
                self.logView.writeString(string: "touchType:\(touchType)")
                self.logView.writeString(string: "commandType:\(commandType)")
                let model = ZycxHeadphoneDeviceParametersModel_customButton()
                model.headphoneType = headphoneType
                model.touchType = touchType
                model.commandType = commandType
                ZywlCommandModule.shareInstance.setZycxHeadphoneCustomButtonList(isForwardingData: false, listArray: [model]) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCustomButtonList -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置EQ模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\neq模式:0：默认、1：重低音、2：影院音效、3：DJ、4：流行、5：爵士、6：古典、7：摇滚、8：原声、9：怀旧、10：律动、11：舞曲、12：电子、13：丽音、14：纯净人声、15：自定义", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneEqMode(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneEqMode -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置自定义EQ音效":
            self.logView.writeString(string: "暂无设置")
            
            let array = [
                "总增益 默认0",
                "音效项总个数 默认1",
                "频率 默认0 多个递增1",
                "增益 默认0 [0-120] 多个递增1",
                "q值 默认0 [0-100] 多个递增1",
                "类型 默认0",
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n 总个数大于，频率增益q值后续递增1", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let totalBuff = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "totalBuff:\(totalBuff)")
                let count = textArray[1].count > 0 ? (Int(textArray[1]) ?? 1) : 1
                var listArray = [ZycxHeadphoneDeviceParametersModel_customEqItem]()
                let frequency = textArray[2].count > 0 ? (Int(textArray[2]) ?? 0) : 0
                let buff = textArray[3].count > 0 ? (Int(textArray[3]) ?? 0) : 0
                let Qvalue = textArray[4].count > 0 ? (Int(textArray[4]) ?? 0) : 0
                let type = textArray[5].count > 0 ? (Int(textArray[5]) ?? 0) : 0
                
                for i in 0..<count {
                    let eqItem = ZycxHeadphoneDeviceParametersModel_customEqItem()
                    eqItem.frequency = frequency + i
                    eqItem.buff = buff + i
                    eqItem.Qvalue = Qvalue + i
                    eqItem.type = type
                    listArray.append(eqItem)
                }
                
                let customModel = ZycxHeadphoneDeviceParametersModel_customEqModel()
                customModel.totalBuff = totalBuff
                //customModel.
                ZywlCommandModule.shareInstance.setZycxHeadphoneCustomEq(isForwardingData: false, customModel: customModel) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCustomEq -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
                
            }
            
            break
        case "设置环境音效":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认、1：通透、2：降噪", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneAmbientSoundEffect(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneAmbientSoundEffect -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置空间音效":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认、1：音乐、2：影院、3：游戏", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneSpaceSoundEffect(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneSpaceSoundEffect -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置入耳感知":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneInEarPerception(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneInEarPerception -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置极速模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneExtremeSpeedMode(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneExtremeSpeedMode -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置抗风噪模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneWindNoiseResistantMode(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneWindNoiseResistantMode -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置低音增强模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneBassToneEnhancement(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneBassToneEnhancement -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置低频增强模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneLowFrequencyEnhancement(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneLowFrequencyEnhancement -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置对联模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneCoupletPattern(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCoupletPattern -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置摇一摇切歌模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneShakeSong(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneShakeSong -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置耳机音量":
            let array = [
                "默认0,[0,22]",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneVoiceVolume(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneAmbientSoundEffect -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置耳机电量":
            let array = [
                "默认0",
                "默认0",
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let leftBattery = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                let rightBattery = textArray[1].count > 0 ? (Int(textArray[1]) ?? 0) : 0
                self.logView.writeString(string: "leftBattery:\(leftBattery)")
                self.logView.writeString(string: "rightBattery:\(rightBattery)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneBattery(isForwardingData: false, leftBattery: leftBattery, rightBattery: rightBattery, success: { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneBattery -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                })
            }
            break
        case "设置音效模式":
            let array = [
                "默认0,0音效1私密2空间低音",
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：音响模式 1：私密模式 2：空间低音", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneSoundEffectMode(type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneSoundEffectMode -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置信号模式":
            let array = [
                "默认0,0兼容1穿墙2超速",
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：兼容模式 1：穿墙模式 2：超速模式", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphonePatternMode(type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphonePatternMode -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "关机":
            ZywlCommandModule.shareInstance.setZycxHeadphonePowerOff(isForwardingData: false) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphonePowerOff -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "重启":
            ZywlCommandModule.shareInstance.setZycxHeadphoneRestart(isForwardingData: false) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphoneRestart -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "恢复出厂设置":
            ZywlCommandModule.shareInstance.setZycxHeadphoneResetFactory(isForwardingData: false) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphoneResetFactory -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "恢复出厂设置后关机":
            ZywlCommandModule.shareInstance.setZycxHeadphoneResetFactoryAndPowerOff(isForwardingData: false) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphoneResetFactoryAndPowerOff -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "抖音控制":
            let array = [
                "默认0",
                "预留默认0"
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0开始1暂停2下一首3上一首4点赞5音量", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                let value = textArray[1].count > 0 ? (Int(textArray[1]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneTiktokControl(isForwardingData: false, type: type,value:value) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneTiktokControl -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "音乐控制":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0开始1暂停2下一首3上一首4音量", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneMusicControl(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneMusicControl -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "来电控制(挂断接听)":
            let array = [
                "默认0,0接听1挂断",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0挂断1接听", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneCallControl_AndswerHandUp(isForwardingData: false, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCallControl_AndswerHandUp -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "来电控制(DTMF/拨号)":
            let array = [
                "默认2,2DTMF3拨号",
                "DTMF/拨号数据中的每个字符必须是0~9,A~Z,+,*,# 字符中的一个",
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n2DTMF3拨号\n每个字符必须是0~9,A~Z,+,*,# 字符中的一个", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 2) : 2
                let string = textArray[1]
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneCallControl_DtmfDialing(isForwardingData: false,type: type, number: string) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCallControl_DtmfDialing -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "来电控制(音量调节)":
            let array = [
                "默认0,[0,16]",
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n2DTMF3拨号\n每个字符必须是0~9,A~Z,+,*,# 字符中的一个", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let value = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "value:\(value)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneCallControl_VolumeVoice(isForwardingData: false,value: value, success: { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCallControl_VolumeVoice -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                })
            }
            break
        case "寻找耳机":
            let array = [
                "默认0,左耳0右耳1",
                "默认0,开始0结束1",
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0挂断1接听", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let headphoneType = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                let isStart = textArray[1].count > 0 ? (Int(textArray[1]) ?? 0) : 0
                self.logView.writeString(string: "headphoneType:\(headphoneType)")
                self.logView.writeString(string: "isStart:\(isStart)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneFind(isForwardingData: false, headphoneType: headphoneType, isStart: isStart) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneFind -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
            
        case "拍照":
            
            ZywlCommandModule.shareInstance.setZycxHeadphoneTakePhoto(isForwardingData: false) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphoneTakePhoto -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "双耳自定义按键恢复默认":
            ZywlCommandModule.shareInstance.setZycxHeadphoneCustomButtonResetDefault(isForwardingData: false) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphoneCustomButtonResetDefault -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
            
        case "耳机电量":
            ZywlCommandModule.shareInstance.getZycxHeadphoneStateBattery(isForwardingData: false) { leftBattery, rightBattery, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "leftBattery = \(leftBattery),rightBattery = \(rightBattery)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "音乐状态":
            ZywlCommandModule.shareInstance.getZycxHeadphoneMusicState(isForwardingData: false) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "当前时间":
            
            ZywlCommandModule.shareInstance.getZycxHeadphoneCurrentTime(isForwardingData: false) { timeString, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "timeString = \(timeString)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "经典蓝牙连接状态":
            ZywlCommandModule.shareInstance.getZycxHeadphoneBtConncetState { state, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "state = \(state)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break

        case "TWS是否配对":
            ZywlCommandModule.shareInstance.getZycxHeadphoneTwsIsPair { state, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "state = \(state)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
            
        case "主动上报":
            ZywlCommandModule.shareInstance.reportZycxHeadphoneBattery { leftBattery, rightBattery, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneBattery leftBattery = \(leftBattery),rightBattery = \(rightBattery)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneFind { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneFind value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            ZywlCommandModule.shareInstance.reportZycxHeadphoneCallControl { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneCallControl value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneMusicState { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneMusicState value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneAmbientSoundEffect { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneAmbientSoundEffect value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneSpaceSoundEffect { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneSpaceSoundEffect value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneInEarPerception { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneInEarPerception value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneExtremeSpeedMode { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneExtremeSpeedMode value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneWindNoiseResistantMode { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneWindNoiseResistantMode value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneBassToneEnhancement { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneBassToneEnhancement value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneLowFrequencyEnhancement { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneLowFrequencyEnhancement value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneCoupletPattern { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneCoupletPattern value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneDesktopMode { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneDesktopMode value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneShakeSong { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneShakeSong value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneEqMode { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneEqMode value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneVoiceVolume { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneVoiceVolume value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneCustomButton { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    var valueString = ""
                    for item in value {
                        valueString += "\n 耳机类型:\(item.headphoneType) 按键类型:\(item.touchType) 功能类型:\(item.commandType)"
                    }
                    let logString = "reportZycxHeadphoneCustomButton value = \(valueString)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneClassicBluetoothConnect { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneClassicBluetoothConnect value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneConnectState { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneConnectState value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                    ZywlCommandModule.shareInstance.getZycxHeadphoneDeviceInfomation(isForwardingData: false) { model, error in
                        self.logView.writeString(string: self.getErrorCodeString(error: error))
                        if error == .none {
                            if let model = model {
                                
                                let deviceName = model.deviceName
                                let mac_ble = model.mac_ble
                                let serialNumber = model.serialNumber
                                let hardwareVersion = model.hardwareVersion
                                let softwareVersion = model.softwareVersion
                                let bleName = model.bleName
                                let mac_br = model.mac_br
                                let bleName_br = model.bleName_br

                                let logString =
                                                """
                                                
                                                deviceName = \(deviceName)
                                                mac_ble = \(mac_ble)
                                                serialNumber = \(serialNumber)
                                                hardwareVersion = \(hardwareVersion)
                                                softwareVersion = \(softwareVersion)
                                                bleName = \(bleName)
                                                mac_br = \(mac_br)
                                                bleName_br = \(bleName_br)
                                                """
                                print(logString)
                                self.logView.writeString(string: logString)
                            }
                        }
                    }
                    ZywlCommandModule.shareInstance.getZycxHeadphoneFunctionList(isForwardingData: false) { functionModel, error in
                        self.logView.writeString(string: self.getErrorCodeString(error: error))
                        if error == .none {
                            if let functionModel = functionModel {
                                self.logView.writeString(string: functionModel.showAllSupportFunctionLog())
                            }
                        }
                    }
                    ZywlCommandModule.shareInstance.getZycxHeadphoneDeviceParameters(isForwardingData: false) { model, error in
                        self.logView.writeString(string: self.getErrorCodeString(error: error))
                        if error == .none {
                            if let model = model {
                                
                                let customButtonList = model.customButtonList
                                var buttonString = ""
                                for item in customButtonList {
                                    buttonString += "\nheadphoneType:\(item.headphoneType),touchType:\(item.touchType),commandType:\(item.commandType)"
                                }
                                let eqMode = model.eqMode
                                var customEqString = ""
                                if let customModel = model.customEqModel {
                                    customEqString += "\ntotalBuff:\(customModel.totalBuff),count:\(customModel.eqListArray.count)"
                                    for item in customModel.eqListArray {
                                        customEqString += "\nfrequency:\(item.frequency),buff:\(item.buff),Qvalue:\(item.Qvalue),type:\(item.type)"
                                    }
                                }
                                
                                let ambientSoundEffect = model.ambientSoundEffect
                                let spaceSoundEffect = model.spaceSoundEffect
                                let inEarPerception = model.inEarPerception
                                let extremeSpeedMode = model.extremeSpeedMode
                                var windNoiseResistantMode = model.windNoiseResistantMode
                            
                                let bassToneEnhancement = model.bassToneEnhancement
                                let lowFrequencyEnhancement = model.lowFrequencyEnhancement
                                let coupletPattern = model.coupletPattern
                                let desktopMode = model.desktopMode
                                let shakeSong = model.shakeSong
                                let voiceVolume = model.voiceVolume
                                let leftBattery = model.leftBattery
                                let rightBattery = model.rightBattery
                                
                                let logString = """
                                                buttonList = \(buttonString)
                                                eqeqMode = \(eqMode)
                                                customEqString = \(customEqString)
                                                ambientSoundEffect = \(ambientSoundEffect)
                                                spaceSoundEffect = \(spaceSoundEffect)
                                                inEarPerception = \(inEarPerception)
                                                extremeSpeedMode = \(extremeSpeedMode)
                                                windNoiseResistantMode = \(windNoiseResistantMode)
                                                bassToneEnhancement = \(bassToneEnhancement)
                                                lowFrequencyEnhancement = \(lowFrequencyEnhancement)
                                                coupletPattern = \(coupletPattern)
                                                desktopMode = \(desktopMode)
                                                shakeSong = \(shakeSong)
                                                voiceVolume = \(voiceVolume)
                                                leftBattery = \(leftBattery)
                                                rightBattery = \(rightBattery)
                                                """
                                print(logString)
                            }
                        }
                    }
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphoneSoundEffectMode { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneSoundEffectMode value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxHeadphonePatternMode { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxHeadphoneShakeSong value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
        case "1":
            
            break
            
        default:
            break
        }
    }
        
    func getFilePathWithType(type:String) ->String {
        var fileString = ""
        if type == "0" {
            
            if UserDefaults.standard.string(forKey: "0_BootFiles") != nil {
                
                fileString = UserDefaults.standard.string(forKey: "0_BootFiles")!
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString
                
            }else{
                
                fileString = Bundle.main.path(forResource: "bootLoader", ofType: "bin") ?? ""
                
            }

        }else if type == "1" {
            
            if UserDefaults.standard.string(forKey: "1_ApplicationFiles") != nil {
                
                fileString = UserDefaults.standard.string(forKey: "1_ApplicationFiles")!
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString
                
            }else{
                
                fileString = Bundle.main.path(forResource: "最新应用程序", ofType: "bin") ?? ""
                
            }
            
        }else if type == "2" {
            
            if UserDefaults.standard.string(forKey: "2_LibraryFiles") != nil {
                
                fileString = UserDefaults.standard.string(forKey: "2_LibraryFiles")!
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString
                
            }else{
                
                fileString = Bundle.main.path(forResource: "图库", ofType: "bin") ?? ""
                
            }
            
        }else if type == "3" {
            
            if UserDefaults.standard.string(forKey: "3_FontFiles") != nil {
                
                fileString = UserDefaults.standard.string(forKey: "3_FontFiles")!
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString
                
            }else{
                
                fileString = Bundle.main.path(forResource: "字库", ofType: "bin") ?? ""
                
            }
            
        }else if type == "4" {
            
            if UserDefaults.standard.string(forKey: "4_DialFiles") != nil {
                
                fileString = UserDefaults.standard.string(forKey: "4_DialFiles")!
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString
                
            }else{
                
                fileString = Bundle.main.path(forResource: "数字表盘", ofType: "bin") ?? ""
                
            }
            
        }else if type == "5" {
            
            if UserDefaults.standard.string(forKey: "5_CustonDialFiles") != nil {
                
                fileString = UserDefaults.standard.string(forKey: "5_CustonDialFiles")!
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString
                
            }else{
                
                fileString = Bundle.main.path(forResource: "数字表盘", ofType: "bin") ?? ""
                
            }
            
        }else if type == "7" {
            
            if UserDefaults.standard.string(forKey: "7_MusicFiles") != nil {
                
                fileString = UserDefaults.standard.string(forKey: "7_MusicFiles")!
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString
                
            }else{
                
                fileString = Bundle.main.path(forResource: "消愁", ofType: "mp3") ?? ""
                
            }
            
        }else if type == "8" {
            
            if UserDefaults.standard.string(forKey: "8_locationFile") != nil {
                
                fileString = UserDefaults.standard.string(forKey: "8_locationFile")!
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString
                
            }else{
                
                fileString = ""
                
            }
            
        }else if type == "9" {
            
            if UserDefaults.standard.string(forKey: "9_sportsType") != nil {
                
                fileString = UserDefaults.standard.string(forKey: "9_sportsType")!
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString
                
            }else{
                
                fileString = ""
                
            }
            
        }else {
            
            if UserDefaults.standard.string(forKey: "0_BootFiles") != nil {
                
                fileString = UserDefaults.standard.string(forKey: "0_BootFiles")!
                let homePath = NSHomeDirectory()
                fileString = homePath + fileString
                
            }else{
                
                fileString = Bundle.main.path(forResource: "bootLoader", ofType: "bin") ?? ""
                
            }
        }
        return fileString
    }

}
