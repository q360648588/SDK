//
//  ChargingBoxCommandVC.swift
//  ZyTools
//
//  Created by 猜猜我是谁 on 2024/4/26.
//

import UIKit
import Photos

class ChargingBoxCommandVC: UIViewController {
    //存放照片资源的标志符
    var localId:String!
    var customBgImage:UIImage?
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

        self.currentBleState = ZywlCommandModule.shareInstance.chargingBoxPeripheral?.state ?? .disconnected
        
        ZywlCommandModule.shareInstance.peripheralStateChange { [weak self] isHeadphone, state in
            self?.currentBleState = state
        }
        
        if #available(iOS 13.0, *) {
            if let state = ZywlCommandModule.shareInstance.chargingBoxPeripheral?.ancsAuthorized {
                self.ancsState = state
            }
        }
        ZywlCommandModule.shareInstance.bluetoothAncsStateChange { [weak self] state in
            self?.ancsState = state
        }
        
        ZywlCommandModule.shareInstance.checkUpgradeState { success, error in
            print("继续升级")

            if error == .none {
                print("success.keys.count =",success.keys.count)
                if success.keys.count > 0 {
                    self.presentSystemAlertVC(title: NSLocalizedString("Warning", comment: "警告"), message: NSLocalizedString("The current device is being upgraded. Do you want to continue upgrading? (Timeout option will exit upgrade)", comment: "检测到当前设备正在升级，是否继续升级？(超时选择将退出升级)")) {
                        ZywlCommandModule.shareInstance.setStopUpgrade { error in
                            print("退出升级")
                        }
                    } okAction: {

                        let type = success["type"] as! String
                        let fileString = self.getFilePathWithType(type: type)

                        var showProgress = 0
                        ZywlCommandModule.shareInstance.setStartUpgrade(type: Int(type) ?? 0, localFile: fileString, maxCount: 20, isContinue: true) { progress in

                            print("progress =",progress)
                            if showProgress == Int(progress) {
                                showProgress += 1
                                self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                            }

                        } success: { error in

                            self.logView.writeString(string: self.getErrorCodeString(error: error))
                            print("setStartUpgrade -> error =",error.rawValue)
                        }
                    }
                }
            }
        }
        
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
            "连接仓的设备上报",
            "升级",
            "耳机转发 功能列表",
            "耳机转发 设备信息",
            "耳机转发 参数获取",
            "耳机转发 参数设置",
            "耳机转发 设备控制",
            "耳机转发 状态查询",
            "耳机转发 主动上报",
        ]
        self.dataSourceArray = [
            [
                "获取本机支持的最大MTU长度",
                "同步设备支持的最大MTU长度",
            ],
            [
                "查询设备功能列表",
            ],
            [
                "获取设备信息",
            ],
            [
                "参数获取(全部)",
                "参数获取(自选)",
                "获取时区",
                "获取时间",
                "获取时间制式",
                "获取天气单位",
                "获取屏幕亮度",
                "获取亮屏时间",
                "获取本地表盘序号",
                "获取语言",
                "获取消息提醒开关",
                "获取自定义表盘",
                "获取天气信息",
                "获取SOS紧急报警联系人",
                "获取UUID",
                "获取震动",
                "获取久坐",
                "获取喝水",
                "获取勿扰",
                "获取防丢",
                "获取生理周期",
                "获取蓝牙名",
            ],
            [
//                "参数设置(全部)",
//                "参数设置(自选)",
                "设置时区",
                "设置时间",
                "设置时间制式",
                "设置天气单位",
                "设置屏幕亮度",
                "设置亮屏时间",
                "设置本地表盘序号",
                "设置语言",
                "设置消息提醒开关",
                NSLocalizedString("Set up a custom watch face", comment: "设置自定义表盘"),
                NSLocalizedString("Set the weather", comment: "设置天气"),
                NSLocalizedString("Set up SOS contacts", comment: "设置SOS联系人"),
                "设置常用联系人",
                "设置UUID",
                "设置震动",
                "设置久坐",
                "设置喝水",
                "设置勿扰",
                "设置防丢",
                "设置生理周期",
                "设置蓝牙名",
            ],
            [
                "关机",
                "重启",
                "恢复出厂设置",
                "恢复出厂设置后关机",
                "船运模式",
                "马达震动",
                "查找仓",
            ],
            [
                "获取电量",
                "耳机连接状态",
                "仓盖状态"
            ],
            [
                "设备主动上报",
            ],
            [
                "设置音乐状态",
                "设置通话状态",
            ],
            [
                "设置应用文件路径",
                "\(NSLocalizedString("Application upgrade", comment: "应用升级"))",
                "设置图库文件路径",
                "\(NSLocalizedString("Gallery upgrade", comment: "图库升级"))",
                "设置字库文件路径",
                "\(NSLocalizedString("Font library upgrade", comment: "字库升级"))",
                "设置表盘文件路径",
                "\(NSLocalizedString("Watch face upgrade", comment: "表盘升级"))",
                NSLocalizedString("(Select directly without editing) Customize the background selection", comment: "(直接选取无编辑)自定义背景选择"),
                NSLocalizedString("Set Custom Background", comment: "设置自定义背景"),
                "设置自定义表盘文件路径",
                "\(NSLocalizedString("Custom watch face upgrade", comment: "自定义表盘升级"))",
                "设置本地音乐文件路径",
                "\(NSLocalizedString("Local music data", comment: "本地音乐数据"))",
            ],
            [
                "耳机转发 功能列表",
            ],
            [
                "耳机转发 设备信息",
            ],
            [
                "耳机转发 参数获取(全部)",
                "耳机转发 参数获取(自选)",
                "耳机转发 获取自定义按键",
                "耳机转发 获取EQ模式",
                "耳机转发 获取自定义EQ音效",
                "耳机转发 获取环境音效",
                "耳机转发 获取空间音效",
                "耳机转发 获取入耳感知",
                "耳机转发 获取极速模式",
                "耳机转发 获取抗风噪模式",
                "耳机转发 获取低音增强模式",
                "耳机转发 获取低频增强模式",
                "耳机转发 获取对联模式",
                "耳机转发 获取桌面模式",
                "耳机转发 获取摇一摇切歌模式",
                "耳机转发 获取耳机音量",
                "耳机转发 获取耳机电量",
            ],
            [
                "耳机转发 设置自定义按键",
                "耳机转发 设置EQ模式",
                "耳机转发 设置自定义EQ音效",
                "耳机转发 设置环境音效",
                "耳机转发 设置空间音效",
                "耳机转发 设置入耳感知",
                "耳机转发 设置极速模式",
                "耳机转发 设置抗风噪模式",
                "耳机转发 设置低音增强模式",
                "耳机转发 设置低频增强模式",
                "耳机转发 设置对联模式",
                "耳机转发 设置摇一摇切歌模式",
                "耳机转发 设置耳机音量",
                "耳机转发 设置耳机电量",
            ],
            [
                "耳机转发 关机",
                "耳机转发 重启",
                "耳机转发 恢复出厂设置",
                "耳机转发 恢复出厂设置后关机",
                "耳机转发 抖音控制",
                "耳机转发 音乐控制",
                "耳机转发 来电控制(挂断接听)",
                "耳机转发 来电控制(DTMF/拨号)",
                "耳机转发 来电控制(音量调节)",
                "耳机转发 寻找耳机",
                "耳机转发 拍照",
                "耳机转发 双耳自定义按键恢复默认",
            ],
            [
                "耳机转发 耳机电量",
                "耳机转发 音乐状态",
                "耳机转发 当前时间"
            ],
            [
                "耳机转发 主动上报"
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
extension ChargingBoxCommandVC:UITableViewDataSource,UITableViewDelegate {
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
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "chargingBoxCommandCell") ?? UITableViewCell.init(style: .default, reuseIdentifier: "chargingBoxCommandCell")
        
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
        case "获取本机支持的最大MTU长度":
            let maxMtu = ZywlCommandModule.shareInstance.getPhoneMaxMtu()
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
                ZywlCommandModule.shareInstance.getZycxSubcontractingInfomation(maxValue: maxMtu) { count, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "getZycxSubcontractingInfomation -> \(count)"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
            
        case "查询设备功能列表":
            
            ZywlCommandModule.shareInstance.getZycxFunctionList { functionModel, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let functionModel = functionModel {
                        self.logView.writeString(string: functionModel.showAllSupportFunctionLog())
                    }
                }
            }
            
            break
            
        case "获取设备信息":
            
            ZywlCommandModule.shareInstance.getZycxDeviceInfomation { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        
                        let name = model.name
                        let firmwareVersion = model.firmwareVersion
                        let imageVersion = model.imageVersion
                        let fontVersion = model.fontVersion
                        let productId = model.productId
                        let projectId = model.projectId
                        let mac = model.mac
                        let serialNumber = model.serialNumber
                        let hardwareVersion = model.hardwareVersion
                        let bigWidth = model.dialSize.bigWidth
                        let bigHeight = model.dialSize.bigHeight
                        let smallWidth = model.dialSize.smallWidth
                        let smallHeight = model.dialSize.smallHeight

                        let logString =
                                        """
                                        
                                        name = \(name)
                                        firmwareVersion = \(firmwareVersion)
                                        imageVersion = \(imageVersion)
                                        fontVersion = \(fontVersion)
                                        productId = \(productId)
                                        projectId = \(projectId)
                                        mac = \(mac)
                                        serialNumber = \(serialNumber)
                                        hardwareVersion = \(hardwareVersion)
                                        bigWidth = \(bigWidth)
                                        bigHeight = \(bigHeight)
                                        smallWidth = \(smallWidth)
                                        smallHeight = \(smallHeight)
                                        """
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
            
        case "参数获取(全部)":
            ZywlCommandModule.shareInstance.getZycxDeviceParameters { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        
                        let timezone = model.timezone
                        let timeString = model.timeString
                        let screenLightLevel = model.screenLightLevel
                        let screenLightTimeLong = model.screenLightTimeLong
                        let languageIndex = model.languageIndex
                        let is24 = !model.timeFormat_is12
                        let isC = !model.weatherUnit_isH
                        let messagePushCount = model.messagePushModel?.openCount
                        var messagePushString = ""
                        if model.messagePushModel?.isOpenCall == true {
                            messagePushString += "\n isOpenCall"
                        }
                        if model.messagePushModel?.isOpenSMS == true {
                            messagePushString += "\n isOpenSMS"
                        }
                        if model.messagePushModel?.isOpenWechat == true {
                            messagePushString += "\n isOpenWechat"
                        }
                        if model.messagePushModel?.isOpenQQ == true {
                            messagePushString += "\n isOpenQQ"
                        }
                        if model.messagePushModel?.isOpenFacebook == true {
                            messagePushString += "\n isOpenFacebook"
                        }
                        if model.messagePushModel?.isOpenTwitter == true {
                            messagePushString += "\n isOpenTwitter"
                        }
                        if model.messagePushModel?.isOpenWhatsApp == true {
                            messagePushString += "\n isOpenWhatsApp"
                        }
                        if model.messagePushModel?.isOpenInstagram == true {
                            messagePushString += "\n isOpenInstagram"
                        }
                        if model.messagePushModel?.isOpenSkype == true {
                            messagePushString += "\n isOpenSkype"
                        }
                        if model.messagePushModel?.isOpenKakaoTalk == true {
                            messagePushString += "\n isOpenKakaoTalk"
                        }
                        if model.messagePushModel?.isOpenLine == true {
                            messagePushString += "\n isOpenLine"
                        }
                        if model.messagePushModel?.isOpenLinkedIn == true {
                            messagePushString += "\n isOpenLinkedIn"
                        }
                        if model.messagePushModel?.isOpenMessenger == true {
                            messagePushString += "\n isOpenMessenger"
                        }
                        if model.messagePushModel?.isOpenSnapchat == true {
                            messagePushString += "\n isOpenSnapchat"
                        }
                        if model.messagePushModel?.isOpenAlipay == true {
                            messagePushString += "\n isOpenAlipay"
                        }
                        if model.messagePushModel?.isOpenTaoBao == true {
                            messagePushString += "\n isOpenTaoBao"
                        }
                        if model.messagePushModel?.isOpenDouYin == true {
                            messagePushString += "\n isOpenDouYin"
                        }
                        if model.messagePushModel?.isOpenDingDing == true {
                            messagePushString += "\n isOpenDingDing"
                        }
                        if model.messagePushModel?.isOpenJingDong == true {
                            messagePushString += "\n isOpenJingDong"
                        }
                        if model.messagePushModel?.isOpenGmail == true {
                            messagePushString += "\n isOpenGmail"
                        }
                        if model.messagePushModel?.isOpenViber == true {
                            messagePushString += "\n isOpenViber"
                        }
                        if model.messagePushModel?.isOpenYouTube == true {
                            messagePushString += "\n isOpenYouTube"
                        }
                        if model.messagePushModel?.isOpenTelegram == true {
                            messagePushString += "\n isOpenTelegram"
                        }
                        if model.messagePushModel?.isOpenHangouts == true {
                            messagePushString += "\n isOpenHangouts"
                        }
                        if model.messagePushModel?.isOpenVkontakte == true {
                            messagePushString += "\n isOpenVkontakte"
                        }
                        if model.messagePushModel?.isOpenFlickr == true {
                            messagePushString += "\n isOpenFlickr"
                        }
                        if model.messagePushModel?.isOpenTumblr == true {
                            messagePushString += "\n isOpenTumblr"
                        }
                        if model.messagePushModel?.isOpenPinterest == true {
                            messagePushString += "\n isOpenPinterest"
                        }
                        if model.messagePushModel?.isOpenTruecaller == true {
                            messagePushString += "\n isOpenTruecaller"
                        }
                        if model.messagePushModel?.isOpenPaytm == true {
                            messagePushString += "\n isOpenPaytm"
                        }
                        if model.messagePushModel?.isOpenZalo == true {
                            messagePushString += "\n isOpenZalo"
                        }
                        if model.messagePushModel?.isOpenMicrosoftTeams == true {
                            messagePushString += "\n isOpenMicrosoftTeams"
                        }

                        var alarmCount = 0
                        var alarmString = ""
                        for item in model.alarmListModel {
                            
                            if item.isValid {
                                alarmCount += 1
                                alarmString += "\n \(String.init(format: "index:%d,%02d:%02d,%@,%@", item.alarmIndex,item.alarmHour,item.alarmMinute,item.alarmRepeatArray ?? [],item.alarmOpen ? "open":"close"))"
                            }
                        }

                        let localDialIndex = model.localDialIndex
                        let customDial_colorHex = model.customDialModel?.colorHex
                        let customDial_positionType = model.customDialModel?.positionType.rawValue
                        let customDial_timeUpType = model.customDialModel?.timeUpType.rawValue
                        let customDial_timeDownType = model.customDialModel?.timeDownType.rawValue
                        let weatherTimeString = model.weatherModel?.timeString
                        var weatherListString = ""
                        for item in model.weatherModel?.weatherArray ?? [] {
                            weatherListString += "\n \(String.init(format: "dayCount:%d,type:%d,temp:%d,airQuality:%d,maxTemp:%d,minTemp:%d",item.dayCount,item.type.rawValue,item.temp,item.airQuality,item.maxTemp,item.minTemp))"
                        }
                        let sosName = model.sosContactModel?.name
                        let sosPhoneNumber = model.sosContactModel?.phoneNumber
                        let uuidString = model.uuidString
                        let vibration = model.vibration
                        var sedentaryString = ""
                        if let sedentary = model.sedentaryModel {
                            sedentaryString += "\n isOpen:\(sedentary.isOpen),timeLong:\(sedentary.timeLong)"
                            for item in sedentary.timeArray {
                                sedentaryString += "\n startHour:\(item.startHour),startMinute:\(item.startMinute),endHour:\(item.endHour),endMinute:\(item.endMinute),"
                            }
                        }
                        var drinkWaterString = ""
                        if let drinkWater = model.drinkWaterModel {
                            drinkWaterString += "\n isOpen:\(drinkWater.isOpen),remindInterval:\(drinkWater.remindInterval),startHour:\(drinkWater.timeModel.startHour),startMinute:\(drinkWater.timeModel.startMinute),endHour:\(drinkWater.timeModel.endHour),endMinute:\(drinkWater.timeModel.endMinute)"
                        }
                        var disturbString = ""
                        if let disturb = model.disturbModel {
                            disturbString += "\n isOpen:\(disturb.isOpen),startHour:\(disturb.timeModel.startHour),startMinute:\(disturb.timeModel.startMinute),endHour:\(disturb.timeModel.endHour),endMinute:\(disturb.timeModel.endMinute)"
                        }
                        let lostRemind = model.lostRemind
                        var physiologicalString = ""
                        if let physiological = model.physiologicalModel {
                            physiologicalString += "\n isOpen:\(physiological.isOpen),cycleCount:\(physiological.cycleCount),menstrualCount:\(physiological.menstrualCount),timeString:\(physiological.year):\(physiological.month):\(physiological.day),advanceDay:\(physiological.advanceDay),remindHour:\(physiological.remindHour),remindMinute:\(physiological.remindMinute)"
                        }
                        let bleName = model.bleName
                        let logString = """
                                        
                                        timezone = \(timezone)
                                        timeString = \(timeString)
                                        screenLightLevel = \(screenLightLevel)
                                        screenLightTimeLong = \(screenLightTimeLong)
                                        languageIndex = \(languageIndex)
                                        is24 = \(is24)
                                        isC = \(isC)
                                        messagePushCount = \(messagePushCount)
                                        \(messagePushString)
                                        alarmCount = \(alarmCount)
                                        \(alarmString)
                                        localDialIndex = \(localDialIndex)
                                        customDial_colorHex = \(customDial_colorHex)
                                        customDial_positionType = \(customDial_positionType)
                                        customDial_timeUpType = \(customDial_timeUpType)
                                        customDial_timeDownType = \(customDial_timeDownType)
                                        weatherTimeString = \(weatherTimeString)
                                        \(weatherListString)
                                        sosName = \(sosName)
                                        sosPhoneNumber = \(sosPhoneNumber)
                                        uuidString = \(uuidString)
                                        vibration = \(vibration)
                                        sedentaryString = \(sedentaryString)
                                        drinkWaterString = \(drinkWaterString)
                                        disturbString = \(disturbString)
                                        lostRemind = \(lostRemind)
                                        physiologicalString = \(physiologicalString)
                                        bleName = \(bleName)
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
                ZywlCommandModule.shareInstance.getZycxDeviceParameters(listArray: parameterArray) { model, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        if let model = model {
                            
                            let timezone = model.timezone
                            let timeString = model.timeString
                            let screenLightLevel = model.screenLightLevel
                            let screenLightTimeLong = model.screenLightTimeLong
                            let languageIndex = model.languageIndex
                            let is24 = !model.timeFormat_is12
                            let isC = !model.weatherUnit_isH
                            let messagePushCount = model.messagePushModel?.openCount
                            var messagePushString = ""
                            if model.messagePushModel?.isOpenCall == true {
                                messagePushString += "\n isOpenCall"
                            }
                            if model.messagePushModel?.isOpenSMS == true {
                                messagePushString += "\n isOpenSMS"
                            }
                            if model.messagePushModel?.isOpenWechat == true {
                                messagePushString += "\n isOpenWechat"
                            }
                            if model.messagePushModel?.isOpenQQ == true {
                                messagePushString += "\n isOpenQQ"
                            }
                            if model.messagePushModel?.isOpenFacebook == true {
                                messagePushString += "\n isOpenFacebook"
                            }
                            if model.messagePushModel?.isOpenTwitter == true {
                                messagePushString += "\n isOpenTwitter"
                            }
                            if model.messagePushModel?.isOpenWhatsApp == true {
                                messagePushString += "\n isOpenWhatsApp"
                            }
                            if model.messagePushModel?.isOpenInstagram == true {
                                messagePushString += "\n isOpenInstagram"
                            }
                            if model.messagePushModel?.isOpenSkype == true {
                                messagePushString += "\n isOpenSkype"
                            }
                            if model.messagePushModel?.isOpenKakaoTalk == true {
                                messagePushString += "\n isOpenKakaoTalk"
                            }
                            if model.messagePushModel?.isOpenLine == true {
                                messagePushString += "\n isOpenLine"
                            }
                            if model.messagePushModel?.isOpenLinkedIn == true {
                                messagePushString += "\n isOpenLinkedIn"
                            }
                            if model.messagePushModel?.isOpenMessenger == true {
                                messagePushString += "\n isOpenMessenger"
                            }
                            if model.messagePushModel?.isOpenSnapchat == true {
                                messagePushString += "\n isOpenSnapchat"
                            }
                            if model.messagePushModel?.isOpenAlipay == true {
                                messagePushString += "\n isOpenAlipay"
                            }
                            if model.messagePushModel?.isOpenTaoBao == true {
                                messagePushString += "\n isOpenTaoBao"
                            }
                            if model.messagePushModel?.isOpenDouYin == true {
                                messagePushString += "\n isOpenDouYin"
                            }
                            if model.messagePushModel?.isOpenDingDing == true {
                                messagePushString += "\n isOpenDingDing"
                            }
                            if model.messagePushModel?.isOpenJingDong == true {
                                messagePushString += "\n isOpenJingDong"
                            }
                            if model.messagePushModel?.isOpenGmail == true {
                                messagePushString += "\n isOpenGmail"
                            }
                            if model.messagePushModel?.isOpenViber == true {
                                messagePushString += "\n isOpenViber"
                            }
                            if model.messagePushModel?.isOpenYouTube == true {
                                messagePushString += "\n isOpenYouTube"
                            }
                            if model.messagePushModel?.isOpenTelegram == true {
                                messagePushString += "\n isOpenTelegram"
                            }
                            if model.messagePushModel?.isOpenHangouts == true {
                                messagePushString += "\n isOpenHangouts"
                            }
                            if model.messagePushModel?.isOpenVkontakte == true {
                                messagePushString += "\n isOpenVkontakte"
                            }
                            if model.messagePushModel?.isOpenFlickr == true {
                                messagePushString += "\n isOpenFlickr"
                            }
                            if model.messagePushModel?.isOpenTumblr == true {
                                messagePushString += "\n isOpenTumblr"
                            }
                            if model.messagePushModel?.isOpenPinterest == true {
                                messagePushString += "\n isOpenPinterest"
                            }
                            if model.messagePushModel?.isOpenTruecaller == true {
                                messagePushString += "\n isOpenTruecaller"
                            }
                            if model.messagePushModel?.isOpenPaytm == true {
                                messagePushString += "\n isOpenPaytm"
                            }
                            if model.messagePushModel?.isOpenZalo == true {
                                messagePushString += "\n isOpenZalo"
                            }
                            if model.messagePushModel?.isOpenMicrosoftTeams == true {
                                messagePushString += "\n isOpenMicrosoftTeams"
                            }

                            var alarmCount = 0
                            var alarmString = ""
                            for item in model.alarmListModel {
                                
                                if item.isValid {
                                    alarmCount += 1
                                    alarmString += "\n \(String.init(format: "index:%d,%02d:%02d,%@,%@", item.alarmIndex,item.alarmHour,item.alarmMinute,item.alarmRepeatArray ?? [],item.alarmOpen ? "open":"close"))"
                                }
                            }

                            let localDialIndex = model.localDialIndex
                            let customDial_colorHex = model.customDialModel?.colorHex
                            let customDial_positionType = model.customDialModel?.positionType.rawValue
                            let customDial_timeUpType = model.customDialModel?.timeUpType.rawValue
                            let customDial_timeDownType = model.customDialModel?.timeDownType.rawValue
                            let weatherTimeString = model.weatherModel?.timeString
                            var weatherListString = ""
                            for item in model.weatherModel?.weatherArray ?? [] {
                                weatherListString += "\n \(String.init(format: "dayCount:%d,type:%d,temp:%d,airQuality:%d,maxTemp:%d,minTemp:%d",item.dayCount,item.type.rawValue,item.temp,item.airQuality,item.maxTemp,item.minTemp))"
                            }
                            let sosName = model.sosContactModel?.name
                            let sosPhoneNumber = model.sosContactModel?.phoneNumber
                            let uuidString = model.uuidString
                            
                            let vibration = model.vibration
                            var sedentaryString = ""
                            if let sedentary = model.sedentaryModel {
                                sedentaryString += "\n isOpen:\(sedentary.isOpen),timeLong:\(sedentary.timeLong)"
                                for item in sedentary.timeArray {
                                    sedentaryString += "\n startHour:\(item.startHour),startMinute:\(item.startMinute),endHour:\(item.endHour),endMinute:\(item.endMinute),"
                                }
                            }
                            var drinkWaterString = ""
                            if let drinkWater = model.drinkWaterModel {
                                drinkWaterString += "\n isOpen:\(drinkWater.isOpen),remindInterval:\(drinkWater.remindInterval),startHour:\(drinkWater.timeModel.startHour),startMinute:\(drinkWater.timeModel.startMinute),endHour:\(drinkWater.timeModel.endHour),endMinute:\(drinkWater.timeModel.endMinute)"
                            }
                            var disturbString = ""
                            if let disturb = model.disturbModel {
                                disturbString += "\n isOpen:\(disturb.isOpen),startHour:\(disturb.timeModel.startHour),startMinute:\(disturb.timeModel.startMinute),endHour:\(disturb.timeModel.endHour),endMinute:\(disturb.timeModel.endMinute)"
                            }
                            let lostRemind = model.lostRemind
                            var physiologicalString = ""
                            if let physiological = model.physiologicalModel {
                                physiologicalString += "\n isOpen:\(physiological.isOpen),cycleCount:\(physiological.cycleCount),menstrualCount:\(physiological.menstrualCount),timeString:\(physiological.year):\(physiological.month):\(physiological.day),advanceDay:\(physiological.advanceDay),remindHour:\(physiological.remindHour),remindMinute:\(physiological.remindMinute)"
                            }
                            let bleName = model.bleName
                            var logString = ""
                            if parameterArray.contains(0) {
                                logString += "\ntimezone = \(timezone)"
                            }
                            if parameterArray.contains(1) {
                                logString += "\ntimeString = \(timeString)"
                            }
                            if parameterArray.contains(2) {
                                logString += "\nis24 = \(is24)"
                            }
                            if parameterArray.contains(3) {
                                logString += "\nisC = \(isC)"
                            }
                            if parameterArray.contains(4) {
                                logString += "\nscreenLightLevel = \(screenLightLevel)"
                            }
                            if parameterArray.contains(5) {
                                logString += "\nscreenLightTimeLong = \(screenLightTimeLong)"
                            }
                            if parameterArray.contains(6) {
                                logString += "\nlocalDialIndex = \(localDialIndex)"
                            }
                            if parameterArray.contains(7) {
                                logString += "\nlanguageIndex = \(languageIndex)"
                            }
                            if parameterArray.contains(8) {
                                logString += "\nmessagePushCount = \(messagePushCount) \n \(messagePushString)"
                            }
                            if parameterArray.contains(9) {
                                logString += "\nalarmCount = \(alarmCount) \n \(alarmString)"
                            }
                            if parameterArray.contains(10) {
                                logString += "\ncustomDial_colorHex = \(customDial_colorHex) \ncustomDial_positionType = \(customDial_positionType) \ncustomDial_timeUpType = \(customDial_timeUpType) \ncustomDial_timeDownType = \(customDial_timeDownType)"
                            }
                            if parameterArray.contains(11) {
                                logString += "\nweatherTimeString = \(weatherTimeString) \n \(weatherListString)"
                            }
                            if parameterArray.contains(12) {
                                logString += "\nsosName = \(sosName) \nsosPhoneNumber = \(sosPhoneNumber)"
                            }
                            if parameterArray.contains(14) {
                                logString += "\nuuidString = \(uuidString)"
                            }
                            if parameterArray.contains(15) {
                                logString += "\nvibration = \(vibration)"
                            }
                            if parameterArray.contains(16) {
                                logString += "\nsedentaryString = \(sedentaryString)"
                            }
                            if parameterArray.contains(17) {
                                logString += "\ndrinkWaterString = \(drinkWaterString)"
                            }
                            if parameterArray.contains(18) {
                                logString += "\ndisturbString = \(disturbString)"
                            }
                            if parameterArray.contains(19) {
                                logString += "\nlostRemind = \(lostRemind)"
                            }
                            if parameterArray.contains(20) {
                                logString += "\nphysiologicalString = \(physiologicalString)"
                            }
                            if parameterArray.contains(21) {
                                logString += "\nbleName = \(bleName)"
                            }
                            print(logString)
                            self.logView.writeString(string: logString)
                        }
                    }
                }
            }
            
            break
        case "获取时区":
            ZywlCommandModule.shareInstance.getZycxTimezone { timezone, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "timezone = \(timezone)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取时间":
            ZywlCommandModule.shareInstance.getZycxTime { timeString, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    
                    let logString = "timeString = \(timeString)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取时间制式":
            ZywlCommandModule.shareInstance.getZycxTimeformat { timeformat, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "timeformat = \(timeformat ? 12:24)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取天气单位":
            ZywlCommandModule.shareInstance.getZycxWeatherUnit { weatherUnit, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "weatherUnit = \(weatherUnit ? "H":"C")"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取屏幕亮度":
            ZywlCommandModule.shareInstance.getZycxScreenLightLevel { level, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "level = \(level)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取亮屏时间":
            ZywlCommandModule.shareInstance.getZycxScreenLightTimeLong { timelong, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "timelong = \(timelong)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取本地表盘序号":
            ZywlCommandModule.shareInstance.getZycxDialIndex { index, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "index = \(index)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取语言":
            ZywlCommandModule.shareInstance.getZycxLanguageIndex { index, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "index = \(index)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "获取消息提醒开关":
            ZywlCommandModule.shareInstance.getZycxMessagePush { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        let messagePushCount = model.openCount
                        var messagePushString = ""
                        if model.isOpenCall == true {
                            messagePushString += "\n isOpenCall"
                        }
                        if model.isOpenSMS == true {
                            messagePushString += "\n isOpenSMS"
                        }
                        if model.isOpenWechat == true {
                            messagePushString += "\n isOpenWechat"
                        }
                        if model.isOpenQQ == true {
                            messagePushString += "\n isOpenQQ"
                        }
                        if model.isOpenFacebook == true {
                            messagePushString += "\n isOpenFacebook"
                        }
                        if model.isOpenTwitter == true {
                            messagePushString += "\n isOpenTwitter"
                        }
                        if model.isOpenWhatsApp == true {
                            messagePushString += "\n isOpenWhatsApp"
                        }
                        if model.isOpenInstagram == true {
                            messagePushString += "\n isOpenInstagram"
                        }
                        if model.isOpenSkype == true {
                            messagePushString += "\n isOpenSkype"
                        }
                        if model.isOpenKakaoTalk == true {
                            messagePushString += "\n isOpenKakaoTalk"
                        }
                        if model.isOpenLine == true {
                            messagePushString += "\n isOpenLine"
                        }
                        if model.isOpenLinkedIn == true {
                            messagePushString += "\n isOpenLinkedIn"
                        }
                        if model.isOpenMessenger == true {
                            messagePushString += "\n isOpenMessenger"
                        }
                        if model.isOpenSnapchat == true {
                            messagePushString += "\n isOpenSnapchat"
                        }
                        if model.isOpenAlipay == true {
                            messagePushString += "\n isOpenAlipay"
                        }
                        if model.isOpenTaoBao == true {
                            messagePushString += "\n isOpenTaoBao"
                        }
                        if model.isOpenDouYin == true {
                            messagePushString += "\n isOpenDouYin"
                        }
                        if model.isOpenDingDing == true {
                            messagePushString += "\n isOpenDingDing"
                        }
                        if model.isOpenJingDong == true {
                            messagePushString += "\n isOpenJingDong"
                        }
                        if model.isOpenGmail == true {
                            messagePushString += "\n isOpenGmail"
                        }
                        if model.isOpenViber == true {
                            messagePushString += "\n isOpenViber"
                        }
                        if model.isOpenYouTube == true {
                            messagePushString += "\n isOpenYouTube"
                        }
                        if model.isOpenTelegram == true {
                            messagePushString += "\n isOpenTelegram"
                        }
                        if model.isOpenHangouts == true {
                            messagePushString += "\n isOpenHangouts"
                        }
                        if model.isOpenVkontakte == true {
                            messagePushString += "\n isOpenVkontakte"
                        }
                        if model.isOpenFlickr == true {
                            messagePushString += "\n isOpenFlickr"
                        }
                        if model.isOpenTumblr == true {
                            messagePushString += "\n isOpenTumblr"
                        }
                        if model.isOpenPinterest == true {
                            messagePushString += "\n isOpenPinterest"
                        }
                        if model.isOpenTruecaller == true {
                            messagePushString += "\n isOpenTruecaller"
                        }
                        if model.isOpenPaytm == true {
                            messagePushString += "\n isOpenPaytm"
                        }
                        if model.isOpenZalo == true {
                            messagePushString += "\n isOpenZalo"
                        }
                        if model.isOpenMicrosoftTeams == true {
                            messagePushString += "\n isOpenMicrosoftTeams"
                        }
                        let logString = "messagePushCount = \(messagePushCount) \n \(messagePushString)"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "获取自定义表盘":
            
            ZywlCommandModule.shareInstance.getZycxCustomDialInfomation { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        let logString = "customDial_colorHex = \(model.colorHex) \ncustomDial_positionType = \(model.positionType.rawValue) \ncustomDial_timeUpType = \(model.timeUpType.rawValue) \ncustomDial_timeDownType = \(model.timeDownType.rawValue)"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "获取天气信息":

            ZywlCommandModule.shareInstance.getZycxWeather { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        let weatherTimeString = model.timeString
                        var weatherListString = ""
                        for item in model.weatherArray {
                            weatherListString += "\n \(String.init(format: "dayCount:%d,type:%d,temp:%d,airQuality:%d,maxTemp:%d,minTemp:%d",item.dayCount,item.type.rawValue,item.temp,item.airQuality,item.maxTemp,item.minTemp))"
                        }
                        let logString = "weatherTimeString = \(weatherTimeString) \n \(weatherListString)"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "获取SOS紧急报警联系人":
            
            ZywlCommandModule.shareInstance.getZycxSosContact { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        let sosName = model.name
                        let sosPhoneNumber = model.phoneNumber
                        let logString = "sosName = \(sosName) \nsosPhoneNumber = \(sosPhoneNumber)"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "获取常用联系人":
            
            break
        case "获取UUID":
            
            ZywlCommandModule.shareInstance.getZycxDeviceUuidString { uuidString, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "uuidString = \(uuidString)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
            
        case "获取震动":
            ZywlCommandModule.shareInstance.getZycxDeviceVibration { isOpen, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "isOpen = \(isOpen)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "获取久坐":
            
            ZywlCommandModule.shareInstance.getZycxSedentary { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let sedentary = model {
                        var logString = "\n isOpen:\(sedentary.isOpen),timeLong:\(sedentary.timeLong)"
                        for item in sedentary.timeArray {
                            logString += "\n startHour:\(item.startHour),startMinute:\(item.startMinute),endHour:\(item.endHour),endMinute:\(item.endMinute),"
                        }
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
                
            }
            
            break
        case "获取喝水":
            
            ZywlCommandModule.shareInstance.getZycxDrinkWater { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let drinkWater = model {
                        var logString = "\n isOpen:\(drinkWater.isOpen),remindInterval:\(drinkWater.remindInterval),startHour:\(drinkWater.timeModel.startHour),startMinute:\(drinkWater.timeModel.startMinute),endHour:\(drinkWater.timeModel.endHour),endMinute:\(drinkWater.timeModel.endMinute)"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
                
            }
            
            break
        case "获取勿扰":
            
            ZywlCommandModule.shareInstance.getZycxDisturb { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let disturb = model {
                        var logString = "\n isOpen:\(disturb.isOpen),startHour:\(disturb.timeModel.startHour),startMinute:\(disturb.timeModel.startMinute),endHour:\(disturb.timeModel.endHour),endMinute:\(disturb.timeModel.endMinute)"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "获取防丢":
            
            ZywlCommandModule.shareInstance.getZycxLostRemind { isOpen, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "isOpen = \(isOpen)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "获取生理周期":
            
            ZywlCommandModule.shareInstance.getZycxPhysiologicalCycle { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let physiological = model {
                        var logString = "\n isOpen:\(physiological.isOpen),cycleCount:\(physiological.cycleCount),menstrualCount:\(physiological.menstrualCount),timeString:\(physiological.year):\(physiological.month):\(physiological.day),advanceDay:\(physiological.advanceDay),remindHour:\(physiological.remindHour),remindMinute:\(physiological.remindMinute)"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "获取蓝牙名":
            
            ZywlCommandModule.shareInstance.getZycxBleName { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    var logString = "\n bleName:\(model)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
            
        case "参数设置(全部)":
            
            break
        case "参数设置(自选)":
            
            break
        case "设置时区":
            
            let array = [
                "默认0,范围[0,24]"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let timeZone = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "timeZone:\(timeZone)")
                ZywlCommandModule.shareInstance.setZycxTimezone(timezone: timeZone) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxTimezone -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置时间":
            
            ZywlCommandModule.shareInstance.setZycxTime(timeString: nil) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxTime -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "设置时间制式":
            
            let array = [
                "默认0,24小时制"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let is24 = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "\(is24 == 0 ? "24":"12")")
                ZywlCommandModule.shareInstance.setZycxTimeFormat(is12: is24 > 0 ? true : false) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxTimeFormat -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置天气单位":
            
            let array = [
                "默认0,摄氏度"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let isC = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "\(isC == 0 ? "C":"H")")
                ZywlCommandModule.shareInstance.setZycxWeatherUnit(isH: isC > 0 ? true : false) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxWeatherUnit -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置屏幕亮度":
            
            let array = [
                "默认0,范围[0,100]"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let level = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "level:\(level)")
                ZywlCommandModule.shareInstance.setZycxScreenLightLevel(level: level) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxScreenLightLevel -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置亮屏时间":
            
            let array = [
                "默认1,范围[1,60]"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let timeLong = textArray[0].count > 0 ? (Int(textArray[0]) ?? 1) : 1
                self.logView.writeString(string: "timeLong:\(timeLong)")
                ZywlCommandModule.shareInstance.setZycxScreenLightTimeLong(timeLong: timeLong) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxScreenLightLevel -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置本地表盘序号":
            
            let array = [
                "默认0"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let index = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "index:\(index)")
                ZywlCommandModule.shareInstance.setZycxDialIndex(index: index) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxScreenLightLevel -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置语言":
            let array = [
                "默认0"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: "\(NSLocalizedString("Set the device language", comment: "设置设备语言"))\n\(NSLocalizedString("0 English 1 Simplified Chinese 2 Japanese 3 Korean 4 German 5 French 6 Spanish 7 Arabic 8 Russian 9 Traditional Chinese 10 Italian 11 Portuguese 12 Ukrainian 13 Hindi 14 Polish 15 Greek 16 Vietnamese 17 Indonesian 18 Thai 19 Dutch 20 Turkish 21 Romanian 22 Danish 23 Swedish 24 Bangladeshi Latin 25 Czech 26 Persian 27 Hebrew 28 Malay 29 Slovak 30 Xhosa 31 Slovenian 32 Hungarian 33 Lithuanian 34 Urdu 35 Bulgarian 36 Croatian 37 Latvian 38 Estonian 39 Khmer", comment: "0英文1简体中文2日语3韩语4德语5法语6西班牙语7阿拉伯语8俄语9繁体中文10意大利语11葡萄牙语12乌克兰语13印地语14波兰语15希腊语16越南语17印度尼西亚语18泰语19荷兰语20土耳其语21罗马尼亚语22丹麦语23瑞典语24孟加拉语25捷克语26波斯语27希伯来语28马来语29斯洛伐克语30南非科萨语31斯洛文尼亚语32匈牙利语33立陶宛语34乌尔都语35保加利亚语36克罗地亚语37拉脱维亚语38爱沙尼亚语39高棉语"))", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let index = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "index:\(index)")
                ZywlCommandModule.shareInstance.setZycxLanguageIndex(index: index) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxScreenLightLevel -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "设置消息提醒开关":
            let array = [
                "默认全开"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let openCount:Double = textArray[0].count > 0 ? (Double(textArray[0]) ?? -1) : 0
                self.logView.writeString(string: "openCount:\(openCount)")
                let pushModel = ZycxDeviceParametersModel_messagePush()
                if openCount < 0 {
                    pushModel.setAllOpen()
                }else{
                    pushModel.setOpenState(result: openCount)
                }
                ZywlCommandModule.shareInstance.setZycxMessagePush(model: pushModel) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let model = pushModel
                        let messagePushCount = model.openCount
                        var messagePushString = ""
                        if model.isOpenCall == true {
                            messagePushString += "\n isOpenCall"
                        }
                        if model.isOpenSMS == true {
                            messagePushString += "\n isOpenSMS"
                        }
                        if model.isOpenWechat == true {
                            messagePushString += "\n isOpenWechat"
                        }
                        if model.isOpenQQ == true {
                            messagePushString += "\n isOpenQQ"
                        }
                        if model.isOpenFacebook == true {
                            messagePushString += "\n isOpenFacebook"
                        }
                        if model.isOpenTwitter == true {
                            messagePushString += "\n isOpenTwitter"
                        }
                        if model.isOpenWhatsApp == true {
                            messagePushString += "\n isOpenWhatsApp"
                        }
                        if model.isOpenInstagram == true {
                            messagePushString += "\n isOpenInstagram"
                        }
                        if model.isOpenSkype == true {
                            messagePushString += "\n isOpenSkype"
                        }
                        if model.isOpenKakaoTalk == true {
                            messagePushString += "\n isOpenKakaoTalk"
                        }
                        if model.isOpenLine == true {
                            messagePushString += "\n isOpenLine"
                        }
                        if model.isOpenLinkedIn == true {
                            messagePushString += "\n isOpenLinkedIn"
                        }
                        if model.isOpenMessenger == true {
                            messagePushString += "\n isOpenMessenger"
                        }
                        if model.isOpenSnapchat == true {
                            messagePushString += "\n isOpenSnapchat"
                        }
                        if model.isOpenAlipay == true {
                            messagePushString += "\n isOpenAlipay"
                        }
                        if model.isOpenTaoBao == true {
                            messagePushString += "\n isOpenTaoBao"
                        }
                        if model.isOpenDouYin == true {
                            messagePushString += "\n isOpenDouYin"
                        }
                        if model.isOpenDingDing == true {
                            messagePushString += "\n isOpenDingDing"
                        }
                        if model.isOpenJingDong == true {
                            messagePushString += "\n isOpenJingDong"
                        }
                        if model.isOpenGmail == true {
                            messagePushString += "\n isOpenGmail"
                        }
                        if model.isOpenViber == true {
                            messagePushString += "\n isOpenViber"
                        }
                        if model.isOpenYouTube == true {
                            messagePushString += "\n isOpenYouTube"
                        }
                        if model.isOpenTelegram == true {
                            messagePushString += "\n isOpenTelegram"
                        }
                        if model.isOpenHangouts == true {
                            messagePushString += "\n isOpenHangouts"
                        }
                        if model.isOpenVkontakte == true {
                            messagePushString += "\n isOpenVkontakte"
                        }
                        if model.isOpenFlickr == true {
                            messagePushString += "\n isOpenFlickr"
                        }
                        if model.isOpenTumblr == true {
                            messagePushString += "\n isOpenTumblr"
                        }
                        if model.isOpenPinterest == true {
                            messagePushString += "\n isOpenPinterest"
                        }
                        if model.isOpenTruecaller == true {
                            messagePushString += "\n isOpenTruecaller"
                        }
                        if model.isOpenPaytm == true {
                            messagePushString += "\n isOpenPaytm"
                        }
                        if model.isOpenZalo == true {
                            messagePushString += "\n isOpenZalo"
                        }
                        if model.isOpenMicrosoftTeams == true {
                            messagePushString += "\n isOpenMicrosoftTeams"
                        }
                        let logString = "messagePushCount = \(messagePushCount) \n \(messagePushString)"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case NSLocalizedString("Set up a custom watch face", comment: "设置自定义表盘"):
            
            let array = [
                NSLocalizedString("Enter the hexadecimal color value", comment: "输入十六进制颜色值"),
                NSLocalizedString("Display position,0 top left 1 Middle left 2 Bottom left 3 Top right 4 Middle right 5 bottom right", comment: "显示位置,0左上1左中2左下3右上4右中5右下"),
                "\(NSLocalizedString("Above the time", comment: "时间上方")),0\(NSLocalizedString("Shut down", comment: "关闭"))1\(NSLocalizedString("Date", comment: "日期"))2\(NSLocalizedString("Sleep", comment: "睡眠"))3\(NSLocalizedString("Heart rate", comment: "心率"))4\(NSLocalizedString("Step counting", comment: "计步"))5\(NSLocalizedString("Week of the week", comment: "星期"))",
                "\(NSLocalizedString("Below the time", comment: "时间下方")),0\(NSLocalizedString("Shut down", comment: "关闭"))1\(NSLocalizedString("Date", comment: "日期"))2\(NSLocalizedString("Sleep", comment: "睡眠"))3\(NSLocalizedString("Heart rate", comment: "心率"))4\(NSLocalizedString("Step counting", comment: "计步"))5\(NSLocalizedString("Week of the week", comment: "星期"))"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let color = textArray[0]
                let positionType = textArray[1]
                let timeUpType = textArray[2]
                let timeDownType = textArray[3]
                
                self.logView.writeString(string: "\(NSLocalizedString("Value of color", comment: "颜色值")):\(color)")
                self.logView.writeString(string: "\(NSLocalizedString("Type of location", comment: "位置类型")):\(positionType)")
                self.logView.writeString(string: "\(NSLocalizedString("Above the time", comment: "时间上方")):\(timeUpType)")
                self.logView.writeString(string: "\(NSLocalizedString("Below the time", comment: "时间下方")):\(timeDownType)")
                
                let model = ZycxDeviceParametersModel_customDial.init()
                model.color = UIColor.init(hexString: color)
                model.positionType = ZycxPositionType.init(rawValue: Int(positionType) ?? 0) ?? .leftTop
                model.timeUpType = ZycxPositionShowType.init(rawValue: Int(timeUpType) ?? 0) ?? .close
                model.timeDownType = ZycxPositionShowType.init(rawValue: Int(timeDownType) ?? 0) ?? .close
                
                ZywlCommandModule.shareInstance.setZycxCustomDialInfomation(model: model) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxCustomDialInfomation -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case NSLocalizedString("Set the weather", comment: "设置天气"):
            
            let array = [
                NSLocalizedString("Year", comment: "年"),
                NSLocalizedString("Month", comment: "月"),
                NSLocalizedString("Day", comment: "日"),
                NSLocalizedString("Hour", comment: "时"),
                NSLocalizedString("Minute", comment: "分"),
                NSLocalizedString("Second", comment: "秒"),
                NSLocalizedString("The total number of bars, all subsequent temperatures increase by +1", comment: "总条数，后续的所有温度递增+1"),
                NSLocalizedString("Type of weather", comment: "天气类型"),
                NSLocalizedString("temperature", comment: "温度"),
                NSLocalizedString("Air quality", comment: "空气质量"),
                NSLocalizedString("Minimum temperature", comment: "最低温度"),
                NSLocalizedString("Maximum temperature", comment: "最高温度"),
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let year = textArray[0]
                let month = textArray[1]
                let day = textArray[2]
                let hour = textArray[3]
                let minute = textArray[4]
                let second = textArray[5]
                let dayCount = textArray[6]
                let type = textArray[7]
                let temp = textArray[8]
                let airQuality = textArray[9]
                let minTemp = textArray[10]
                let maxTemp = textArray[11]
                
                let date = Date()
                let calendar = NSCalendar.current
                let yearDate = calendar.component(.year, from: date)
                let monthDate = calendar.component(.month, from: date)
                let dayDate = calendar.component(.day, from: date)
                let hourDate = calendar.component(.hour, from: date)
                let minuteDate = calendar.component(.minute, from: date)
                let secondDate = calendar.component(.second, from: date)
                
                let time = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", Int(year) ?? yearDate , Int(month) ?? monthDate , Int(day) ?? dayDate , Int(hour) ?? hourDate , Int(minute) ?? minuteDate , Int(second) ?? secondDate)
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let timeDate = format.date(from: time)
                let timestamp:Int = Int(timeDate?.timeIntervalSince1970 ?? 0)
                
                self.logView.writeString(string: "\(NSLocalizedString("Time of display", comment: "显示时间")):\(time),时间戳:\(timestamp)")
                
                var modelArray = [ZycxDeviceParametersModel_weather]()
                
                for i in stride(from: 0, to: Int(dayCount) ?? 0, by: 1) {
                    self.logView.writeString(string: "第\(i)天")
                    self.logView.writeString(string: "\(NSLocalizedString("Type of weather", comment: "天气类型")):\(type)")
                    self.logView.writeString(string: "\(NSLocalizedString("temperature", comment: "温度")):\((Int(temp) ?? 0) + i)")
                    self.logView.writeString(string: "\(NSLocalizedString("Air quality", comment: "空气质量")):\(airQuality)")
                    self.logView.writeString(string: "\(NSLocalizedString("Minimum temperature", comment: "最低温度")):\((Int(minTemp) ?? 0) + i)")
                    self.logView.writeString(string: "\(NSLocalizedString("Maximum temperature", comment: "最高温度")):\((Int(maxTemp) ?? 0) + i)")
                    self.logView.writeString(string: "\n")
                    
                    let model = ZycxDeviceParametersModel_weather.init()
                    model.dayCount = i
                    model.type = ZycxWeatherType(rawValue:Int(type) ?? 0) ?? .sunny
                    model.temp = (Int(temp) ?? 0) + i
                    model.airQuality = Int(airQuality) ?? 0
                    model.minTemp = (Int(minTemp) ?? 0) + i
                    model.maxTemp = (Int(maxTemp) ?? 0) + i
                    modelArray.append(model)
                }
                
                let weatherModel = ZycxDeviceParametersModel_weatherListModel()
                weatherModel.timeString = time
                weatherModel.weatherArray = modelArray
                
                ZywlCommandModule.shareInstance.setZycxWeather(model: weatherModel) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxWeather -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case NSLocalizedString("Set up SOS contacts", comment: "设置SOS联系人"):
            
            let array = [
                NSLocalizedString("Name", comment: "姓名"),
                NSLocalizedString("Number", comment: "号码"),
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Hint (Invalid data is null by default)", comment: "提示(无效数据默认为空)"), message: rowString, holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let model = ZycxDeviceParametersModel_contactPerson.init()
                model.name = textArray[0]
                model.phoneNumber = textArray[1]
                
                self.logView.writeString(string: "\(NSLocalizedString("Contact Person", comment: "联系人")) \(NSLocalizedString("Name", comment: "姓名")):\(model.name),\(NSLocalizedString("Number", comment: "号码")):\(model.phoneNumber)")
                
                ZywlCommandModule.shareInstance.setZycxSosContact(model: model) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxSosContact -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置常用联系人":
            
            let array = [
                "0\(NSLocalizedString("Name", comment: "姓名"))(默认张三)",
                "0\(NSLocalizedString("Number", comment: "号码"))(默认13755660033)",
                "1\(NSLocalizedString("Name", comment: "姓名"))(默认李四)",
                "1\(NSLocalizedString("Number", comment: "号码"))(默认0755-6128998)",
                "2\(NSLocalizedString("Name", comment: "姓名"))",
                "2\(NSLocalizedString("Number", comment: "号码"))",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Synchronizing contacts", comment: "同步联系人"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Hint (Invalid data is null by default)", comment: "提示(无效数据默认为空)"), message: NSLocalizedString("Set up contacts", comment: "设置联系人"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let model_0 = ZycxDeviceParametersModel_contactPerson.init()
                model_0.name = textArray[0].count == 0 ? "张三" : textArray[0]
                model_0.phoneNumber = textArray[1].count == 0 ? "13755660033" : textArray[1]

                let model_1 = ZycxDeviceParametersModel_contactPerson.init()
                model_1.name = textArray[2].count == 0 ? "李四" : textArray[2]
                model_1.phoneNumber = textArray[3].count == 0 ? "0755-6128998" : textArray[3]
                
                let model_2 = ZycxDeviceParametersModel_contactPerson.init()
                model_2.name = textArray[4]
                model_2.phoneNumber = textArray[5]
                
                self.logView.writeString(string: "\(NSLocalizedString("Contact Person", comment: "联系人"))0 \(NSLocalizedString("Name", comment: "姓名")):\(model_0.name),\(NSLocalizedString("Number", comment: "号码")):\(model_0.phoneNumber)")
                self.logView.writeString(string: "\(NSLocalizedString("Contact Person", comment: "联系人"))1 \(NSLocalizedString("Name", comment: "姓名")):\(model_1.name),\(NSLocalizedString("Number", comment: "号码")):\(model_1.phoneNumber)")
                self.logView.writeString(string: "\(NSLocalizedString("Contact Person", comment: "联系人"))2 \(NSLocalizedString("Name", comment: "姓名")):\(model_2.name),\(NSLocalizedString("Number", comment: "号码")):\(model_2.phoneNumber)")
                
                ZywlCommandModule.shareInstance.setZycxAddressContact(listModel: [model_0,model_1,model_2]) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxAddressContact -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置UUID":
            
            let array = [
                "默认\(ZywlCommandModule.shareInstance.chargingBoxPeripheral?.identifier.uuidString ?? "")"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let uuid = textArray[0].count > 0 ? textArray[0] : ZywlCommandModule.shareInstance.chargingBoxPeripheral?.identifier.uuidString
                self.logView.writeString(string: "uuid:\(uuid ?? "")")
                
                ZywlCommandModule.shareInstance.setZycxDeviceUuidString(uuid: uuid) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxDeviceUuidString -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break

        case "设置震动":
            
            let array = [
                "默认0"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let isOpen = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0 > 0 ? true : false) : false
                self.logView.writeString(string: "isOpen:\(isOpen)")
                
                ZywlCommandModule.shareInstance.setZycxDeviceVibration(isOpen: isOpen) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxDeviceVibration -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置久坐":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))",
                NSLocalizedString("Length of interval", comment: "间隔时长"),
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟"),
                NSLocalizedString("Closing hours", comment: "结束小时"),
                NSLocalizedString("End of the minute", comment: "结束分钟"),
                
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0,格式错误可能闪退)", message: rowString, holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0 > 0 ? true : false) : false
                let timeLong = textArray[1]
                let startHour = textArray[2]
                let startMinute = textArray[3]
                let endHour = textArray[4]
                let endMinute = textArray[5]
                
                self.logView.writeString(string: (isOpen ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭")))
                self.logView.writeString(string: "\(NSLocalizedString("Time to start", comment: "开始时间")):\(startHour.count>0 ? startHour:"0").\(startMinute.count>0 ? startMinute:"0")")
                self.logView.writeString(string: "\(NSLocalizedString("End of period", comment: "结束时间")):\(endHour.count>0 ? endHour:"0").\(endMinute.count>0 ? endMinute:"0")")
                self.logView.writeString(string: "\(NSLocalizedString("Length of interval", comment: "间隔时长")):\(timeLong.count>0 ? timeLong:"0")")
                
                let model = ZycxDeviceParametersModel_sedentaryModel()
                model.isOpen = isOpen
                model.timeLong = Int(timeLong) ?? 0
                let timeModel = ZycxDeviceParametersModel_timeModel()
                timeModel.startHour = Int(startHour) ?? 0
                timeModel.startMinute = Int(startMinute) ?? 0
                timeModel.endHour = Int(endHour) ?? 0
                timeModel.endMinute = Int(endMinute) ?? 0
                model.timeArray = [timeModel]
                
                ZywlCommandModule.shareInstance.setZycxSedentary(model: model) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxSedentary -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置喝水":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))",
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟"),
                NSLocalizedString("Closing hours", comment: "结束小时"),
                NSLocalizedString("End of the minute", comment: "结束分钟"),
                NSLocalizedString("Length of interval", comment: "间隔时长")
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0 > 0 ? true : false) : false
                let startHour = textArray[1]
                let startMinute = textArray[2]
                let endHour = textArray[3]
                let endMinute = textArray[4]
                let remindInterval = textArray[5]
                self.logView.writeString(string: (isOpen ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭")))
                self.logView.writeString(string: "\(NSLocalizedString("Time to start", comment: "开始时间")):\(startHour.count>0 ? startHour:"0").\(startMinute.count>0 ? startMinute:"0")")
                self.logView.writeString(string: "\(NSLocalizedString("End of period", comment: "结束时间")):\(endHour.count>0 ? endHour:"0").\(endMinute.count>0 ? endMinute:"0")")
                self.logView.writeString(string: "\(NSLocalizedString("Length of interval", comment: "间隔时长")):\(remindInterval.count>0 ? remindInterval:"0")")
                
                let model = ZycxDeviceParametersModel_drinkWaterModel.init()
                model.isOpen = isOpen
                model.remindInterval = Int(remindInterval) ?? 0
                model.timeModel.startHour = Int(startHour) ?? 0
                model.timeModel.startMinute = Int(startMinute) ?? 0
                model.timeModel.endHour = Int(endHour) ?? 0
                model.timeModel.endMinute = Int(endMinute) ?? 0

                ZywlCommandModule.shareInstance.setZycxDrinkWater(model: model) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxDrinkWater -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置勿扰":
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))",
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟"),
                NSLocalizedString("Closing hours", comment: "结束小时"),
                NSLocalizedString("End of the minute", comment: "结束分钟")
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0 > 0 ? true : false) : false
                let startHour = textArray[1]
                let startMinute = textArray[2]
                let endHour = textArray[3]
                let endMinute = textArray[4]
                
                self.logView.writeString(string: isOpen ? NSLocalizedString("Shut down", comment: "关闭"):NSLocalizedString("Turn on", comment: "开启"))
                self.logView.writeString(string: String.init(format: "\(NSLocalizedString("Time to start", comment: "开始时间")) %02d:%02d", Int(startHour) ?? 0,Int(startMinute) ?? 0))
                self.logView.writeString(string: String.init(format: "\(NSLocalizedString("End of period", comment: "结束时间")) %02d:%02d", Int(endHour) ?? 0,Int(endMinute) ?? 0))
                
                let model = ZycxDeviceParametersModel_disturbModel()
                model.isOpen = isOpen
                model.timeModel.startHour = Int(startHour) ?? 0
                model.timeModel.startMinute = Int(startMinute) ?? 0
                model.timeModel.endHour = Int(endHour) ?? 0
                model.timeModel.endMinute = Int(endMinute) ?? 0
                
                ZywlCommandModule.shareInstance.setZycxDisturb(model: model) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxDisturb -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
                
            }
            
            break
        case "设置防丢":
            
            let array = [
                "默认0"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let isOpen = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0 > 0 ? true : false) : false
                self.logView.writeString(string: "isOpen:\(isOpen)")
                ZywlCommandModule.shareInstance.setZycxLostRemind(isOpen: isOpen) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxLostRemind -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置生理周期":
            
            let array = [
                NSLocalizedString("On/off switch", comment: "开关"),
                NSLocalizedString("Number of cycle days", comment: "周期天数"),
                NSLocalizedString("Number of menstrual days", comment: "经期天数"),
                NSLocalizedString("The year of your last period", comment: "上次经期的年"),
                NSLocalizedString("The month of your last period", comment: "上次经期的月"),
                NSLocalizedString("The date of your last period", comment: "上次经期的日"),
                NSLocalizedString("The number of days of advance reminder", comment: "提前提醒的天数"),
                NSLocalizedString("Hours of reminder", comment: "提醒小时"),
                NSLocalizedString("A reminder minute", comment: "提醒分钟")
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let isOpen:Bool = (Int(textArray[0]) ?? 0) == 0 ? false : true
                let cycleCount:Int = Int(textArray[1]) ?? 0
                let menstrualCount:Int = Int(textArray[2]) ?? 0
                let year:Int = Int(textArray[3]) ?? 0
                let month:Int = Int(textArray[4]) ?? 0
                let day:Int = Int(textArray[5]) ?? 0
                let advanceDay:Int = Int(textArray[6]) ?? 0
                let remindHour:Int = Int(textArray[7]) ?? 0
                let remindMinute:Int = Int(textArray[8]) ?? 0
                
                let model = ZycxDeviceParametersModel_physiologicalModel.init()
                model.isOpen = isOpen
                model.cycleCount = cycleCount
                model.menstrualCount = menstrualCount
                model.year = year
                model.month = month
                model.day = day
                model.advanceDay = advanceDay
                model.remindHour = remindHour
                model.remindMinute = remindMinute
                
                self.logView.writeString(string: isOpen ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                self.logView.writeString(string: "\(NSLocalizedString("Number of cycle days", comment: "周期天数")): \(cycleCount)")
                self.logView.writeString(string: "\(NSLocalizedString("Number of menstrual days", comment: "经期天数")): \(menstrualCount)")
                self.logView.writeString(string: String.init(format: "\(NSLocalizedString("Date of commencement of last menstrual period", comment: "上一次月经开始日期")): %04d-%02d-%02d", year,month,day))
                self.logView.writeString(string: "\(NSLocalizedString("Remind days in advance", comment: "提前提醒天数")): \(advanceDay)")
                self.logView.writeString(string: String.init(format: "\(NSLocalizedString("Time to remind", comment: "提醒时间")): %02d:%02d", remindHour,remindMinute))
                
                ZywlCommandModule.shareInstance.setZycxPhysiologicalCycle(model: model) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxPhysiologicalCycle -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "设置蓝牙名":
            
            let array = [
                "默认 zycx"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let name = textArray[0] ?? "zycx"
                self.logView.writeString(string: "name:\(name)")
                ZywlCommandModule.shareInstance.setZycxBleName(bleName: name) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxLostRemind -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "关机":
            
            ZywlCommandModule.shareInstance.setZycxPowerOff { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxPowerOff -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "重启":
            
            ZywlCommandModule.shareInstance.setZycxRestart { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxRestart -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }

            break
        case "恢复出厂设置":
            
            ZywlCommandModule.shareInstance.setZycxResetFactory { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxResetFactory -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "恢复出厂设置后关机":
            
            ZywlCommandModule.shareInstance.setZycxResetFactoryAndPowerOff { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxResetFactoryAndPowerOff -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "船运模式":
            
            ZywlCommandModule.shareInstance.setZycxShipMode { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxShipMode -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "马达震动":
            
            let array = [
                "默认0,close"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let isOpen = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "\(isOpen == 0 ? "close":"Open")")
                ZywlCommandModule.shareInstance.setZycxVibrationMotor(isOpen: isOpen == 0 ? false : true) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxVibrationMotor -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "查找仓":
            let array = [
                "默认0,close"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let isOpen = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "\(isOpen == 0 ? "close":"Open")")
                ZywlCommandModule.shareInstance.setZycxFindChargingBox(isOpen: isOpen == 0 ? false : true) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxFindChargingBox -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "获取电量":
            
            ZywlCommandModule.shareInstance.getZycxBattery { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "getZycxBattery -> \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "耳机连接状态":
            ZywlCommandModule.shareInstance.getZycxHeadphoneConnectState { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "getZycxBattery -> \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
            
        case "仓盖状态":
            
            ZywlCommandModule.shareInstance.getZycxBoxCoverState { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "getZycxBattery -> \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break

        case "设备主动上报":
            
            ZywlCommandModule.shareInstance.reportZycxBattery { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxBattery -> \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            ZywlCommandModule.shareInstance.reportZycxWeatherUnit { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxWeatherUnit -> \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            ZywlCommandModule.shareInstance.reportZycxScreenLightLevel { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxScreenLightLevel -> \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            ZywlCommandModule.shareInstance.reportZycxScreenLightTimeLong { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxScreenLightTimeLong -> \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            ZywlCommandModule.shareInstance.reportZycxLocalDialIndex { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxLocalDialIndex -> \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            ZywlCommandModule.shareInstance.reportZycxLanguageIndex { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxLocalDialIndex -> \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            ZywlCommandModule.shareInstance.reportZycxShakeSong { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxShakeSong -> \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            ZywlCommandModule.shareInstance.reportZycxMusicControl { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxMusicControl -> \(value)"
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
                }
            }
            ZywlCommandModule.shareInstance.reportZycxBoxCoverState { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxBoxCoverState value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            ZywlCommandModule.shareInstance.reportZycxTakePhoto { value, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "reportZycxTakePhoto value = \(value)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "设置音乐状态":
            let array = [
                "默认0,0开始1暂停",
                "默认0,范围[0,100]"
            ]

            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let state = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                let vioceVoolume = textArray[1].count > 0 ? (Int(textArray[1]) ?? 0) : 0
                self.logView.writeString(string: "\(state == 0 ? "start":"puase")")
                self.logView.writeString(string: "vioceVoolume:\(vioceVoolume)")
                ZywlCommandModule.shareInstance.setZycxMusicState(state, vioceVoolume: vioceVoolume)
            }
            break
        case "设置通话状态":
            let array = [
                "默认0",
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: "0无通话1来电2通话中", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let state = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "state:\(state)")
                ZywlCommandModule.shareInstance.setZycxCallState(state)
            }
            break
        case "设置应用文件路径":
            let fileString = UserDefaults.standard.string(forKey: "1_ApplicationFiles")
            
            var message = NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径")
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: NSLocalizedString("Application file path", comment: "应用文件路径"), message: message, cancel: NSLocalizedString("Modify the path", comment: "修改路径"), cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: NSLocalizedString("Application file path", comment: "应用文件路径"))
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "1_ApplicationFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "1_ApplicationFiles")
                        self.logView.writeString(string: NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径"))
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) {
                                
            }
            break
        case "\(NSLocalizedString("Application upgrade", comment: "应用升级"))":
            let fileString = self.getFilePathWithType(type: "1")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):1\(NSLocalizedString("Application upgrade", comment: "应用升级"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            ZywlCommandModule.shareInstance.setOtaStartUpgrade(type: 1, localFile: fileString, isContinue: false) { progress in
                
                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                }
                
                print("progress ->",progress)

            } success: { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }

            break
        case "设置图库文件路径":
            let fileString = UserDefaults.standard.string(forKey: "2_LibraryFiles")
            
            var message = NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径")
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: NSLocalizedString("Gallery file path", comment: "图库文件路径"), message: message, cancel: NSLocalizedString("Modify the path", comment: "修改路径"), cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: NSLocalizedString("Gallery file path", comment: "图库文件路径"))
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "2_LibraryFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "2_LibraryFiles")
                        self.logView.writeString(string: NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径"))
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) {
                                
            }
            break
        case "\(NSLocalizedString("Gallery upgrade", comment: "图库升级"))":
            let fileString = self.getFilePathWithType(type: "2")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):2\(NSLocalizedString("Gallery upgrade", comment: "图库升级"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            ZywlCommandModule.shareInstance.setOtaStartUpgrade(type: 2, localFile: fileString, isContinue: false) { progress in
                
                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                }
                
                print("progress ->",progress)

            } success: { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }
            break
        case "设置字库文件路径":
            
            let fileString = UserDefaults.standard.string(forKey: "3_FontFiles")
            
            var message = NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径")
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: NSLocalizedString("Font file path", comment: "字库文件路径"), message: message, cancel: NSLocalizedString("Modify the path", comment: "修改路径"), cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: NSLocalizedString("Font file path", comment: "字库文件路径"))
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "3_FontFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "3_FontFiles")
                        self.logView.writeString(string: NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径"))
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) {
                                
            }
            
            break
        case "\(NSLocalizedString("Font library upgrade", comment: "字库升级"))":
            let fileString = self.getFilePathWithType(type: "3")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):3\(NSLocalizedString("Font library upgrade", comment: "字库升级"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            ZywlCommandModule.shareInstance.setOtaStartUpgrade(type: 3, localFile: fileString, isContinue: false) { progress in
                
                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                }
                
                print("progress ->",progress)

            } success: { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }
            break
            
        case "设置表盘文件路径":
            let fileString = UserDefaults.standard.string(forKey: "4_DialFiles")
            
            var message = NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径")
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: NSLocalizedString("Watch face file path", comment: "表盘文件路径"), message: message, cancel: NSLocalizedString("Modify the path", comment: "修改路径"), cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: NSLocalizedString("Watch face file path", comment: "表盘文件路径"))
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "4_DialFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "4_DialFiles")
                        self.logView.writeString(string: NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径"))
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) {
                                
            }
            break
        case "\(NSLocalizedString("Watch face upgrade", comment: "表盘升级"))":
            let fileString = self.getFilePathWithType(type: "4")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):4\(NSLocalizedString("Watch face upgrade", comment: "表盘升级"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            ZywlCommandModule.shareInstance.setOtaStartUpgrade(type: 4, localFile: fileString, isContinue: false) { progress in
                
                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                }
                
                print("progress ->",progress)

            } success: { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }
            break
        case NSLocalizedString("(Select directly without editing) Customize the background selection", comment: "(直接选取无编辑)自定义背景选择"):
            
            self.presentSystemAlertVC(title: NSLocalizedString("(Select directly without editing) Customize the background selection", comment: "(直接选取无编辑)自定义背景选择"), message: "", cancel: NSLocalizedString("Photo album", comment: "相册"), cancelAction: {
                self.initPhotoPicker(allowsEditing: false)
            }, ok: NSLocalizedString("Take a photo", comment: "拍照")) {
                self.initCameraPicker()
            }
            
            break
            
        case NSLocalizedString("Set Custom Background", comment: "设置自定义背景"):
            
            if var image = self.customBgImage {
                print("image = \(image)")
                
                if let infoModel = ZywlCommandModule.shareInstance.zycxDeviceInfoModel {
                    image = image.img_changeSize(size: .init(width: infoModel.dialSize.bigWidth, height: infoModel.dialSize.bigHeight))
                    print("image.img_changeSize = \(image)")
                    var showProgress = 0
                    ZywlCommandModule.shareInstance.setZycxCustomDial(image: image) { progress in
                        if showProgress == Int(progress) {
                            showProgress += 1
                            self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                        }else{
                            showProgress = Int(progress)
                            self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                        }
                        print("progress ->",progress)
                    } success: { error in
                        self.logView.writeString(string: self.getErrorCodeString(error: error))
                        print("SetCustomDialEdit -> error =",error.rawValue)
                    }

                }else{
                    self.logView.writeString(string: "需要先获取设备信息命令")
                }
            }else{
                self.presentSystemAlertVC(title: "警告:当前没有选择背景", message: "请选择自定义背景", cancel: nil, cancelAction: {

                }, ok: nil) {

                }
            }
            
            break
        case "设置自定义表盘文件路径":
            let fileString = UserDefaults.standard.string(forKey: "5_CustonDialFiles")
            
            var message = NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径")
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: NSLocalizedString("Customize the watch face file path", comment: "自定义表盘文件路径"), message: message, cancel: NSLocalizedString("Modify the path", comment: "修改路径"), cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: NSLocalizedString("Customize the watch face file path", comment: "自定义表盘文件路径"))
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "5_CustonDialFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "5_CustonDialFiles")
                        self.logView.writeString(string: NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径"))
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) {
                                
            }
            break
        case "\(NSLocalizedString("Custom watch face upgrade", comment: "自定义表盘升级"))":
            let fileString = self.getFilePathWithType(type: "5")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):5\(NSLocalizedString("Custom watch face upgrade", comment: "自定义表盘升级"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            ZywlCommandModule.shareInstance.setOtaStartUpgrade(type: 5, localFile: fileString, isContinue: false) { progress in
                
                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                }
                
                print("progress ->",progress)

            } success: { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }
            break
        case "设置本地音乐文件路径":
            
            let fileString = UserDefaults.standard.string(forKey: "7_MusicFiles")
            
            var message = NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径")
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: NSLocalizedString("Music file path", comment: "音乐文件路径"), message: message, cancel: NSLocalizedString("Modify the path", comment: "修改路径"), cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    
                    if let fileName = URL.init(string: pathString)?.lastPathComponent {
                        print("fileName = \(fileName)")
                        var isSupport = false
                        var supportString = "功能列表获取支持的音乐文件类型"
                        if let musicTypeModel = ZywlCommandModule.shareInstance.chargingBoxFunctionListModel?.functionDetail_localPlay {
                            supportString = ""
                            if musicTypeModel.isSupportMp3 {
                                supportString += ".mp3 "
                                if fileName.lowercased().hasSuffix(".mp3") {
                                    isSupport = true
                                }
                            }
                            if musicTypeModel.isSupportWav {
                                supportString += ".wav "
                                if fileName.lowercased().hasSuffix(".wav") {
                                    isSupport = true
                                }
                            }
                        }else{
                            isSupport = true
                        }
                        
                        if isSupport {
                            let homePath = NSHomeDirectory()
                            let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                            print("选中的文件连接 pathString =",pathString)
                            self.logView.writeString(string: NSLocalizedString("Music file path", comment: "音乐文件路径"))
                            if pathString.count > 0 {
                                UserDefaults.standard.setValue(pathString, forKey: "7_MusicFiles")
                                self.logView.writeString(string: pathString)
                            }else{
                                UserDefaults.standard.removeObject(forKey: "7_MusicFiles")
                                self.logView.writeString(string: NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径"))
                            }
                            UserDefaults.standard.synchronize()
                        }else{
                            self.presentSystemAlertVC(title: "文件类型错误", message: "请选择设备支持的音乐文件\(supportString)") {
                                
                            } okAction: {
                                
                            }
                        }

                    }else{
                        let homePath = NSHomeDirectory()
                        let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                        print("选中的文件连接 pathString =",pathString)
                        self.logView.writeString(string: NSLocalizedString("Music file path", comment: "音乐文件路径"))
                        if pathString.count > 0 {
                            UserDefaults.standard.setValue(pathString, forKey: "7_MusicFiles")
                            self.logView.writeString(string: pathString)
                        }else{
                            UserDefaults.standard.removeObject(forKey: "7_MusicFiles")
                            self.logView.writeString(string: NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径"))
                        }
                        UserDefaults.standard.synchronize()
                    }
                }
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) {
                                
            }
            
            break
        case "\(NSLocalizedString("Local music data", comment: "本地音乐数据"))":
            let fileString = self.getFilePathWithType(type: "7")
            print("fileString =",fileString)
            
            var fileName = ""
            
            let url = URL(string: fileString) ?? URL.init(fileURLWithPath: fileString)
            fileName = url.lastPathComponent
            
            let array = [
                "文件名:\(fileName)",
            ]
            var showProgress = 0
            self.presentTextFieldAlertVC(title: "提示(默认文件名:\(fileName))", message: NSLocalizedString("Local music data", comment: "本地音乐数据"), holderStringArray: array) {
                
            } okAction: { (textArray) in
                let name = textArray[0].count == 0 ? fileName : textArray[0]
                ZywlCommandModule.shareInstance.setZycxLocalMusicFile(name, localFile: fileString) { progress in
                    
                    if showProgress == Int(progress) {
                        showProgress += 1
                        self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                    }
                    print("progress ->",progress)

                } success: { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    print("setStartUpgrade -> error =",error.rawValue)
                }
            }
            break
            
        case "耳机转发 功能列表":
            
            ZywlCommandModule.shareInstance.getZycxHeadphoneFunctionList(isForwardingData: true) { functionModel, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let functionModel = functionModel {
                        self.logView.writeString(string: functionModel.showAllSupportFunctionLog())
                    }
                }
            }
            
            break
        case "耳机转发 设备信息":
            
            ZywlCommandModule.shareInstance.getZycxHeadphoneDeviceInfomation(isForwardingData: true) { model, error in
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
        case "耳机转发 参数获取(全部)":
            
            ZywlCommandModule.shareInstance.getZycxHeadphoneDeviceParameters(isForwardingData: true) { model, error in
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
            
            break
        case "耳机转发 参数获取(自选)":
            
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
                ZywlCommandModule.shareInstance.getZycxHeadphoneDeviceParameters(isForwardingData: true, listArray: parameterArray) { model, error in
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
        case "耳机转发 获取自定义按键":
            ZywlCommandModule.shareInstance.getZycxHeadphoneCustomButtonList(isForwardingData: true) { listArray, error in
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
        case "耳机转发 获取EQ模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneEqMode(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取自定义EQ音效":
            ZywlCommandModule.shareInstance.getZycxHeadphoneCustomEq(isForwardingData: true) { listArray, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
            }
            break
        case "耳机转发 获取环境音效":
            ZywlCommandModule.shareInstance.getZycxHeadphoneAmbientSoundEffect(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取空间音效":
            ZywlCommandModule.shareInstance.getZycxHeadphoneSpaceSoundEffect(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取入耳感知":
            ZywlCommandModule.shareInstance.getZycxHeadphoneInEarPerception(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取极速模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneExtremeSpeedMode(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取抗风噪模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneWindNoiseResistantMode(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取低音增强模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneBassToneEnhancement(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取低频增强模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneLowFrequencyEnhancement(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取对联模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneCoupletPattern(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取桌面模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneDesktopMode(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "耳机转发 获取摇一摇切歌模式":
            ZywlCommandModule.shareInstance.getZycxHeadphoneShakeSong(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取耳机音量":
            ZywlCommandModule.shareInstance.getZycxHeadphoneVoiceVolume(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 获取耳机电量":
            ZywlCommandModule.shareInstance.getZycxHeadphoneBattery(isForwardingData: true) { leftBattery, rightBattery, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "leftBattery = \(leftBattery),rightBattery = \(rightBattery)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 设置自定义按键":
            let array = [
                "默认0,左耳0右耳1",
                "默认0,单击0双击1三击2长按3",
                "默认0,左耳0右耳1",
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n功能ID:0无功能1播放暂停2上一曲3下一曲4音量+5音量-6来电接听7来电拒绝8挂断电话9环境音切换10唤醒语音助手11回拨电话", holderStringArray: array) {
                
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
                ZywlCommandModule.shareInstance.setZycxHeadphoneCustomButtonList(isForwardingData: true, listArray: [model]) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCustomButtonList -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 设置EQ模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\neq模式:0：默认、1：重低音、2：影院音效、3：DJ、4：流行、5：爵士、6：古典、7：摇滚、8：原声、9：怀旧、10：律动、11：舞曲、12：电子、13：丽音、14：纯净人声、15：自定义", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneEqMode(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneEqMode -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "耳机转发 设置自定义EQ音效":
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
                ZywlCommandModule.shareInstance.setZycxHeadphoneCustomEq(isForwardingData: true, customModel: customModel) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCustomEq -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
                
            }
            
            break
        case "耳机转发 设置环境音效":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认、1：通透、2：降噪", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneAmbientSoundEffect(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneAmbientSoundEffect -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 设置空间音效":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认、1：音乐、2：影院、3：游戏", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneSpaceSoundEffect(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneSpaceSoundEffect -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 设置入耳感知":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneInEarPerception(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneInEarPerception -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 设置极速模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneExtremeSpeedMode(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneExtremeSpeedMode -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 设置抗风噪模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneWindNoiseResistantMode(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneWindNoiseResistantMode -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 设置低音增强模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneBassToneEnhancement(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneBassToneEnhancement -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 设置低频增强模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneLowFrequencyEnhancement(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneLowFrequencyEnhancement -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 设置对联模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneCoupletPattern(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCoupletPattern -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 设置摇一摇切歌模式":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0：关闭/默认 1：开", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneShakeSong(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneShakeSong -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 设置耳机音量":
            let array = [
                "默认0,[0,22]",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString, holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneVoiceVolume(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneAmbientSoundEffect -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            
            break
        case "耳机转发 设置耳机电量":
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
                ZywlCommandModule.shareInstance.setZycxHeadphoneBattery(isForwardingData: true, leftBattery: leftBattery, rightBattery: rightBattery, success: { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneBattery -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                })
            }
            break
        case "耳机转发 关机":
            ZywlCommandModule.shareInstance.setZycxHeadphonePowerOff(isForwardingData: true) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphonePowerOff -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 重启":
            ZywlCommandModule.shareInstance.setZycxHeadphoneRestart(isForwardingData: true) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphoneRestart -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 恢复出厂设置":
            ZywlCommandModule.shareInstance.setZycxHeadphoneResetFactory(isForwardingData: true) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphoneResetFactory -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 恢复出厂设置后关机":
            ZywlCommandModule.shareInstance.setZycxHeadphoneResetFactoryAndPowerOff(isForwardingData: true) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphoneResetFactoryAndPowerOff -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 抖音控制":
            let array = [
                "默认0",
                "预留默认0"
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0开始1暂停2下一首3上一首4点赞5音量", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                let value = textArray[1].count > 0 ? (Int(textArray[1]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneTiktokControl(isForwardingData: true, type: type,value:value) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneTiktokControl -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 音乐控制":
            let array = [
                "默认0",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0开始1暂停2下一首3上一首4音量", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneMusicControl(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneMusicControl -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 来电控制(挂断接听)":
            let array = [
                "默认0,0接听1挂断",
                
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n0挂断1接听", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneCallControl_AndswerHandUp(isForwardingData: true, type: type) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCallControl_AndswerHandUp -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 来电控制(DTMF/拨号)":
            let array = [
                "默认2,2DTMF3拨号",
                "DTMF/拨号数据中的每个字符必须是0~9,A~Z,+,*,# 字符中的一个",
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n2DTMF3拨号\n每个字符必须是0~9,A~Z,+,*,# 字符中的一个", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let type = textArray[0].count > 0 ? (Int(textArray[0]) ?? 2) : 2
                let string = textArray[1]
                self.logView.writeString(string: "type:\(type)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneCallControl_DtmfDialing(isForwardingData: true,type: type, number: string) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCallControl_DtmfDialing -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 来电控制(音量调节)":
            let array = [
                "默认0,[0,16]",
            ]
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: rowString+"\n2DTMF3拨号\n每个字符必须是0~9,A~Z,+,*,# 字符中的一个", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let value = textArray[0].count > 0 ? (Int(textArray[0]) ?? 0) : 0
                self.logView.writeString(string: "value:\(value)")
                ZywlCommandModule.shareInstance.setZycxHeadphoneCallControl_VolumeVoice(isForwardingData: true,value: value, success: { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneCallControl_VolumeVoice -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                })
            }
            break
        case "耳机转发 寻找耳机":
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
                ZywlCommandModule.shareInstance.setZycxHeadphoneFind(isForwardingData: true, headphoneType: headphoneType, isStart: isStart) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        let logString = "setZycxHeadphoneFind -> success"
                        print(logString)
                        self.logView.writeString(string: logString)
                    }
                }
            }
            break
        case "耳机转发 拍照":
            
            ZywlCommandModule.shareInstance.setZycxHeadphoneTakePhoto(isForwardingData: true) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphoneTakePhoto -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 双耳自定义按键恢复默认":
            ZywlCommandModule.shareInstance.setZycxHeadphoneCustomButtonResetDefault(isForwardingData: true) { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "setZycxHeadphoneCustomButtonResetDefault -> success"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
            
        case "耳机转发 耳机电量":
            ZywlCommandModule.shareInstance.getZycxHeadphoneStateBattery(isForwardingData: true) { leftBattery, rightBattery, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "leftBattery = \(leftBattery),rightBattery = \(rightBattery)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 音乐状态":
            ZywlCommandModule.shareInstance.getZycxHeadphoneMusicState(isForwardingData: true) { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "type = \(type)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            break
        case "耳机转发 当前时间":
            
            ZywlCommandModule.shareInstance.getZycxHeadphoneCurrentTime(isForwardingData: true) { timeString, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    let logString = "timeString = \(timeString)"
                    print(logString)
                    self.logView.writeString(string: logString)
                }
            }
            
            break
        case "耳机转发 主动上报":
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
                    ZywlCommandModule.shareInstance.getZycxHeadphoneDeviceInfomation(isForwardingData: true) { model, error in
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
                    ZywlCommandModule.shareInstance.getZycxHeadphoneFunctionList(isForwardingData: true) { functionModel, error in
                        self.logView.writeString(string: self.getErrorCodeString(error: error))
                        if error == .none {
                            if let functionModel = functionModel {
                                self.logView.writeString(string: functionModel.showAllSupportFunctionLog())
                            }
                        }
                    }
                    ZywlCommandModule.shareInstance.getZycxHeadphoneDeviceParameters(isForwardingData: true) { model, error in
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

extension ChargingBoxCommandVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK: - 相机
    
    //从相册中选择
    func initPhotoPicker(allowsEditing:Bool = true){
        DispatchQueue.main.async {
            let photoPicker =  UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.allowsEditing = allowsEditing
            photoPicker.sourceType = .photoLibrary
            //在需要的地方present出来
            photoPicker.modalPresentationStyle = .fullScreen
            self.present(photoPicker, animated: true, completion: nil)
        }
        
    }
    
    
    //拍照
    func initCameraPicker(){
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let  cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
                cameraPicker.allowsEditing = true
                cameraPicker.sourceType = .camera
                //在需要的地方present出来
                self.present(cameraPicker, animated: true, completion: nil)
            } else {
                
                print("不支持拍照")
                
            }
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //获得照片
        let image:UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage ?? (info[UIImagePickerController.InfoKey.originalImage] ?? UIImage.init()) as! UIImage
        
        let imageUrl:URL?
        if #available(iOS 11.0, *) {
            imageUrl = info[.imageURL] as? URL
        } else {
            imageUrl = info[.referenceURL] as? URL
            // Fallback on earlier versions
        }
        //UIImagePickerControllerReferenceURL UIImagePickerControllerImageURL
        // 拍照
        if picker.sourceType == .camera {
            //保存相册
            //UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
            
            PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
                DispatchQueue.main.async {
                    if status == .authorized {
                        
                        PHPhotoLibrary.shared().performChanges({
                            let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
                            let assetPlaceholder = result.placeholderForCreatedAsset
                            //保存标志符
                            self.localId = assetPlaceholder?.localIdentifier
                        }) { (isSuccess, error) in
                            if isSuccess {
                                print("保存成功!")
                                //通过标志符获取对应的资源
                                let assetResult = PHAsset.fetchAssets(
                                    withLocalIdentifiers: [self.localId], options: nil)
                                let asset = assetResult[0]
                                let options = PHContentEditingInputRequestOptions()
                                options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData)
                                    -> Bool in
                                    return true
                                }
                                
                                //获取保存的图片路径
                                asset.requestContentEditingInput(with: options, completionHandler: {
                                    (contentEditingInput:PHContentEditingInput?, info: [AnyHashable : Any]) in
                                    
                                    let headerStr = contentEditingInput!.fullSizeImageURL!.absoluteString
                                    
                                    print("地址：",headerStr)

                                })
                                
                            } else{
                                print("保存失败：", error!.localizedDescription)
                            }
                        }
                        
                    }else {
                       
                        self.presentSystemAlertVC(title: NSLocalizedString("public_tip_title_photoAuthorization", comment: ""), message: "\(NSLocalizedString("public_settings", comment: ""))->\(NSLocalizedString("public_settings", comment: "public_privacy"))->\(NSLocalizedString("public_photo", comment: ""))", cancel: NSLocalizedString("public_tip_cancel", comment: ""), cancelAction: {
                            
                        }, ok: NSLocalizedString("public_tip_ok", comment: "")) {
                            let url = URL(string: UIApplication.openSettingsURLString)
                            if (UIApplication.shared.canOpenURL(url!)){
                                UIApplication.shared.openURL(url!)
                            }
                        }
                    }
                }
            }
        }
        print("customBgImage = \(image)")
        self.customBgImage = image

        self.dismiss(animated: true, completion: nil)
        
    }
        
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        
        if error != nil {
            
            print("保存失败")
            
            
        } else {
            
            print("保存成功")
            
        }
    }
    
}
