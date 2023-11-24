//
//  ZyXuVC.swift
//  ZySdkDemo
//
//  Created by 猜猜我是谁 on 2021/7/3.
//

import UIKit
import ZySDK
import CoreBluetooth
//import Alamofire
import Photos

class ZyVC: UIViewController {
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
    var testCount = 0
    var tableView:UITableView!
    var dataSourceArray = [[String]].init()
    var titleArray = [String].init()
    var logView:ShowLogView!
    var dialArray = [ZyOnlineDialModel].init()
    var autoTimer:Timer?
    var timestamp:Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentBleState = ZyCommandModule.shareInstance.peripheral?.state ?? .disconnected
        
        ZyCommandModule.shareInstance.peripheralStateChange { [weak self] state in
            self?.currentBleState = state
        }
        
        if #available(iOS 13.0, *) {
            if let state = ZyCommandModule.shareInstance.peripheral?.ancsAuthorized {
                self.ancsState = state
            }
        } else {
            
        }
        
        ZyCommandModule.shareInstance.bluetoothAncsStateChange { [weak self] state in
            self?.ancsState = state
        }
        
        ZyCommandModule.shareInstance.checkUpgradeState { success, error in
            print("继续升级")

            if error == .none {
                print("success.keys.count =",success.keys.count)
                if success.keys.count > 0 {
                    self.presentSystemAlertVC(title: NSLocalizedString("Warning", comment: "警告"), message: NSLocalizedString("The current device is being upgraded. Do you want to continue upgrading? (Timeout option will exit upgrade)", comment: "检测到当前设备正在升级，是否继续升级？(超时选择将退出升级)")) {
                        ZyCommandModule.shareInstance.setStopUpgrade { error in
                            print("退出升级")
                        }
                    } okAction: {

                        let type = success["type"] as! String
                        let fileString = self.getFilePathWithType(type: type)

                        var showProgress = 0
                        ZyCommandModule.shareInstance.setStartUpgrade(type: Int(type) ?? 0, localFile: fileString, maxCount: 20, isContinue: true) { progress in

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
        
        self.tableView = UITableView.init(frame: .init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.logView = ShowLogView.init(frame: .init(x: 0, y: 84, width: screenWidth, height: screenHeight-84))
        //self.logView.center = self.view.center
        self.logView.isHidden = true
        self.view.addSubview(self.logView)
        
        self.titleArray = ["\(NSLocalizedString("Device Information", comment: "设备信息"))",
                           "\(NSLocalizedString("Device Settings", comment: "设备设置"))",
                           "\(NSLocalizedString("Device Reminder", comment: "设备提醒"))",
                           "\(NSLocalizedString("Device Sync", comment: "设备同步"))",
                           "\(NSLocalizedString("New Protocol command", comment: "新协议命令"))",
                           "\(NSLocalizedString("test command", comment: "测试命令"))",
                           "\(NSLocalizedString("Device actively reports", comment: "设备主动上报"))",
                           NSLocalizedString("Path Settings", comment: "路径设置"),
                           NSLocalizedString("Test upgrade", comment: "测试升级"),
                           NSLocalizedString("Server related commands, make sure the network is normal before using", comment: "服务器相关命令,使用前确定网络正常"),
                           ]
        self.dataSourceArray = [
            [
                //"0\(NSLocalizedString("Boot upgrade", comment: "引导升级"))",
                //"1\(NSLocalizedString("Application upgrade", comment: "应用升级"))",
                //"2\(NSLocalizedString("Gallery upgrade", comment: "图库升级"))",
                //"3\(NSLocalizedString("Font library upgrade", comment: "字库升级"))",
                //"4\(NSLocalizedString("Watch face upgrade", comment: "表盘升级"))",
                //"5\(NSLocalizedString("Custom watch face upgrade", comment: "自定义表盘升级"))",
                //"6\(NSLocalizedString("Worship alarm clock data", comment: "朝拜闹钟数据"))",
                //"7\(NSLocalizedString("Local music data", comment: "本地音乐数据"))",
                //"8\(NSLocalizedString("Auxiliary positioning data", comment: "辅助定位数据"))",
                //"9\(NSLocalizedString("Customize the exercise type", comment: "自定义运动类型"))",
                "\(NSLocalizedString("Get the device name", comment: "获取设备名称"))",
                "\(NSLocalizedString("Get the firmware version", comment: "获取固件版本"))",
                "\(NSLocalizedString("Gets the serial number", comment: "获取序列号"))",
                "\(NSLocalizedString("Get mac address", comment: "获取mac地址"))",
                "\(NSLocalizedString("Get the power", comment: "获取电量"))",
                "\(NSLocalizedString("Set up time", comment: "设置时间"))",
                "\(NSLocalizedString("Get a list of features supported by your device", comment: "获取设备支持的功能列表"))",
                "\(NSLocalizedString("Obtain version information for products, firmware, and resources", comment: "获取产品、固件、资源等版本信息"))",
            ],
            [
                "\(NSLocalizedString("Access to Personal Information", comment: "获取个人信息"))",
                "\(NSLocalizedString("Set up personal information", comment: "设置个人信息"))",
                "\(NSLocalizedString("Get the time standard", comment: "获取时间制式"))",
                "\(NSLocalizedString("Set the time standard", comment: "设置时间制式"))",
                "\(NSLocalizedString("Get the metric system", comment: "获取公英制"))",
                "\(NSLocalizedString("Set the metric system", comment: "设置公英制"))",
                "\(NSLocalizedString("Set the weather", comment: "设置天气"))",
                "\(NSLocalizedString("Set weather (expand parameters)", comment: "设置天气(拓展参数)"))",
                "\(NSLocalizedString("The device enters camera mode", comment: "设备进入拍照模式"))",
                "\(NSLocalizedString("Find a bracelet", comment: "寻找手环"))",
                "\(NSLocalizedString("Get a bright screen for wrist lifting", comment: "获取抬腕亮屏"))",
                "\(NSLocalizedString("Set up wrist lift bright screen", comment: "设置抬腕亮屏"))",
                "\(NSLocalizedString("Get screen brightness", comment: "获取屏幕亮度"))",
                "\(NSLocalizedString("Set screen brightness", comment: "设置屏幕亮度"))",
                "\(NSLocalizedString("Gets the screen duration", comment: "获取亮屏时长"))",
                "\(NSLocalizedString("Set the screen duration", comment: "设置亮屏时长"))",
                "\(NSLocalizedString("Gets the local watch face", comment: "获取本地表盘"))",
                "\(NSLocalizedString("Set the local watch face", comment: "设置本地表盘"))",
                "\(NSLocalizedString("Get the alarm clock", comment: "获取闹钟"))",
                "\(NSLocalizedString("Set an alarm", comment: "设置闹钟"))",
                "\(NSLocalizedString("Get the device language", comment: "获取设备语言"))",
                "\(NSLocalizedString("Set the device language", comment: "设置设备语言"))",
                "\(NSLocalizedString("Gets the target number of steps", comment: "获取目标步数"))",
                "\(NSLocalizedString("Set the target number of steps", comment: "设置目标步数"))",
                "\(NSLocalizedString("Set up a single measurement", comment: "设置单次测量"))",
                "\(NSLocalizedString("Get Exercise patterns", comment: "获取锻炼模式"))",
                "\(NSLocalizedString("Set exercise mode", comment: "设置锻炼模式"))",
                "\(NSLocalizedString("Get weather units", comment: "获取天气单位"))",
                "\(NSLocalizedString("Set weather units", comment: "设置天气单位"))",
                "\(NSLocalizedString("Set the real-time data reporting switch", comment: "设置实时数据上报开关"))",
                "\(NSLocalizedString("Gets a custom watch face", comment: "获取自定义表盘"))",
                "\(NSLocalizedString("Set up a custom watch face", comment: "设置自定义表盘"))",
                "\(NSLocalizedString("Customize the background selection", comment: "自定义背景选择"))",
                "\(NSLocalizedString("(Select directly without editing) Customize the background selection", comment: "(直接选取无编辑)自定义背景选择"))",
                "\(NSLocalizedString("Set Custom Background", comment: "设置自定义背景"))",
                "\(NSLocalizedString("Set Custom Background (JL)", comment: "设置自定义背景(JL)"))",
                "\(NSLocalizedString("Set phone status", comment: "设置电话状态"))",
                "\(NSLocalizedString("Gets the custom dial dimensions", comment: "获取自定义表盘尺寸"))",
                "\(NSLocalizedString("Get a 24-hour heart rate monitor", comment: "获取24小时心率监测"))",
                "\(NSLocalizedString("Set up a 24-hour heart rate monitor", comment: "设置24小时心率监测"))",
                "\(NSLocalizedString("Set the device to enter or exit photo mode", comment: "设置设备进入或退出拍照模式"))",
                "\(NSLocalizedString("app synchronizes motion data to the device (manually customized)", comment: "app同步运动数据至设备(手动自定义)"))",
                "\(NSLocalizedString("app synchronizes motion data to the device (automatic 1s increment)", comment: "app同步运动数据至设备(自动1s递增)"))",
                "\(NSLocalizedString("Set to clear all data", comment: "设置清除所有数据"))",
                "\(NSLocalizedString("Binding up", comment: "绑定"))",
                "\(NSLocalizedString("unbind", comment: "解绑"))",
            ],
            [
                "\(NSLocalizedString("Get message alerts", comment: "获取消息提醒"))",
                "\(NSLocalizedString("Set message reminders", comment: "设置消息提醒"))",
                "\(NSLocalizedString("Get sedentary reminders", comment: "获取久坐提醒"))",
                "\(NSLocalizedString("Set a sedentary reminder (one set)", comment: "设置久坐提醒(一组)"))",
                "\(NSLocalizedString("Set a sedentary reminder (multiple groups)", comment: "设置久坐提醒(多组)"))",
                "\(NSLocalizedString("Get Do not disturb reminders", comment: "获取勿扰提醒"))",
                "\(NSLocalizedString("Set Do not disturb reminder", comment: "设置勿扰提醒"))",
                "\(NSLocalizedString("Get heart rate alerts", comment: "获取心率预警"))",
                "\(NSLocalizedString("Set heart rate alert", comment: "设置心率预警"))",
                "\(NSLocalizedString("Get the cycle", comment: "获取生理周期"))",
                "\(NSLocalizedString("Set your cycle", comment: "设置生理周期"))",
                "\(NSLocalizedString("Get water reminders", comment: "获取喝水提醒"))",
                "\(NSLocalizedString("Set a water reminder", comment: "设置喝水提醒"))",
                "\(NSLocalizedString("Synchronizing contacts", comment: "同步联系人"))",
                "\(NSLocalizedString("Synchronize N contacts", comment: "同步N个联系人"))",
                "\(NSLocalizedString("Get low power alerts", comment: "获取低电提醒"))",
                "\(NSLocalizedString("Set a low power reminder", comment: "设置低电提醒"))",
                "\(NSLocalizedString("Get a single LED lamp function", comment: "获取单个LED灯功能"))",
                "\(NSLocalizedString("Set up a single LED light function", comment: "设置单个LED灯功能"))",
                "\(NSLocalizedString("Set individual LED light power display", comment: "设置单个LED灯电量显示"))",
                "\(NSLocalizedString("Get motor vibration function", comment: "获取马达震动功能"))",
                "\(NSLocalizedString("Set motor vibration function", comment: "设置马达震动功能"))",
                "\(NSLocalizedString("Get a custom LED", comment: "获取自定义LED"))",
                "\(NSLocalizedString("Set up a custom LED", comment: "设置自定义LED"))",
                "\(NSLocalizedString("Get custom vibrations", comment: "获取自定义震动"))",
                "\(NSLocalizedString("Set up custom vibration", comment: "设置自定义震动"))",
            ],
            [
                "\(NSLocalizedString("Synchronize step data", comment: "同步计步数据"))",
                "\(NSLocalizedString("Synchronizing exercise data", comment: "同步锻炼数据"))",
                "\(NSLocalizedString("Synchronized measurement data", comment: "同步测量数据"))",
            ],
            [
                "New \(NSLocalizedString("Synchronizing data", comment: "同步数据"))",
                "New \(NSLocalizedString("Set the weather", comment: "设置天气"))",
                "New \(NSLocalizedString("Set an alarm", comment: "设置闹钟"))",
                "New \(NSLocalizedString("Set a sleep goal", comment: "设置睡眠目标"))",
                "New \(NSLocalizedString("Get the alarm clock", comment: "获取闹钟"))",
                "New \(NSLocalizedString("Get a sleep Goal", comment: "获取睡眠目标"))",
                "New \(NSLocalizedString("Set up SOS contacts", comment: "设置SOS联系人"))",
                "New \(NSLocalizedString("Get SOS contacts", comment: "获取SOS联系人"))",
                "New \(NSLocalizedString("Cycle measurement parameter setting", comment: "周期测量参数设置"))",
                "New \(NSLocalizedString("Get the number of days and start time of the pilgrimage alarm clock", comment: "获取朝拜闹钟天数及开始时间"))",
                "New \(NSLocalizedString("Set the time zone", comment: "设置时区"))",
                "New \(NSLocalizedString("No response response location information", comment: "无响应 回应定位信息"))",
                "New \(NSLocalizedString("Gets a custom movement type", comment: "获取自定义运动类型"))",
            ],
            [
                "\(NSLocalizedString("Power off", comment: "关机"))",
                "\(NSLocalizedString("factory data reset", comment: "恢复出厂设置"))",
                "\(NSLocalizedString("Vibration of motor", comment: "马达震动"))",
                "\(NSLocalizedString("Start up again", comment: "重新启动"))",
                "\(NSLocalizedString("Restore the factory and power down", comment: "恢复出厂并关机"))",
            ],
            [
                "\(NSLocalizedString("Real time step count", comment: "实时步数"))",
                "\(NSLocalizedString("Real time heart rate", comment: "实时心率"))",
                "\(NSLocalizedString("Results of a single measurement", comment: "单次测量结果"))",
                "\(NSLocalizedString("Status of exercise", comment: "锻炼状态"))",
                "\(NSLocalizedString("Find your phone", comment: "找手机"))",
                "\(NSLocalizedString("End the phone search", comment: "结束找手机"))",
                "\(NSLocalizedString("Take a photo", comment: "拍照"))",
                "\(NSLocalizedString("Control of music", comment: "音乐控制"))",
                "\(NSLocalizedString("Incoming call control", comment: "来电控制"))",
                "\(NSLocalizedString("Report screen brightness", comment: "上报屏幕亮度"))",
                "\(NSLocalizedString("Report the screen duration", comment: "上报亮屏时长"))",
                "\(NSLocalizedString("Report wrist bright screen", comment: "上报抬腕亮屏"))",
                "\(NSLocalizedString("Report equipment vibration", comment: "上报设备振动"))",
                "\(NSLocalizedString("Report real-time data", comment: "上报实时数据"))",
                "\(NSLocalizedString("Report movement interaction data", comment: "上报运动交互数据"))",
                "\(NSLocalizedString("Report to enter or exit photo mode", comment: "上报进入或退出拍照模式"))",
                "\(NSLocalizedString("Do not disturb Settings for reporting", comment: "上报勿扰设置"))",
                "\(NSLocalizedString("Report the number of days and start time of the pilgrimage alarm clock", comment: "上报朝拜闹钟天数及开始时间"))",
                "\(NSLocalizedString("Report request location information", comment: "上报请求定位信息"))",
                "\(NSLocalizedString("Report the alarm clock", comment: "上报闹钟"))",
                "\(NSLocalizedString("Language of reporting", comment: "上报语言"))",
            ],
            [
                "0\(NSLocalizedString("The boot file", comment: "引导文件"))",
                "1\(NSLocalizedString("File of application", comment: "应用文件"))",
                "2\(NSLocalizedString("Photo gallery file", comment: "图库文件"))",
                "3\(NSLocalizedString("Character library file", comment: "字库文件"))",
                "4\(NSLocalizedString("Watch face file", comment: "表盘文件"))",
                "5\(NSLocalizedString("Customize the watch face file", comment: "自定义表盘文件"))",
                "7\(NSLocalizedString("Music file", comment: "音乐文件"))",
                "8\(NSLocalizedString("Auxiliary location file", comment: "辅助定位文件"))",
                "9\(NSLocalizedString("Customize the motion file", comment: "自定义运动文件"))",
            ],
            [
                "\(NSLocalizedString("OTA upgrade", comment: "OTA升级"))",
                "\(NSLocalizedString("Stop upgrading", comment: "停止升级"))",
            ],
            [
                "\(NSLocalizedString("Get the server OTA information", comment: "获取服务器OTA信息"))",
                "\(NSLocalizedString("Automatic OTA upgrade server for the latest device version", comment: "自动OTA升级服务器最新设备相关版本"))",
                "\(NSLocalizedString("Get online watch face (old interface, get all)", comment: "获取在线表盘(旧接口，获取全部)"))",
                "\(NSLocalizedString("Get online watch face (new interface, get paging)", comment: "获取在线表盘(新接口，获取分页)"))",
                "\(NSLocalizedString("Send online watch face", comment: "发送在线表盘"))",
                "\(NSLocalizedString("Gets the local watch face picture", comment: "获取本地表盘图片"))",
                "\(NSLocalizedString("Get a custom watch face picture", comment: "获取自定义表盘图片"))",
            ],
        ]
    }
    
    

    deinit {
        print("deinit ZyVC")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("didReceiveMemoryWarning")
        
        print("didReceiveMemoryWarning -> date =",Date.init())
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ZyVC:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSourceArray.count
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
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "commandCell") ?? UITableViewCell.init(style: .default, reuseIdentifier: "commandCell")
        
        let sectionArray = self.dataSourceArray[indexPath.section]
        cell.textLabel?.text = sectionArray[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionArray = self.dataSourceArray[indexPath.section]
        let rowString = sectionArray[indexPath.row]
        
        print("didSelectRowAt -> date =",Date.init())
        
        switch rowString {
        case "\(NSLocalizedString("Get the device name", comment: "获取设备名称"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get the device name", comment: "获取设备名称"))
            ZyCommandModule.shareInstance.getDeviceName { success, error in

                self.logView.writeString(string: self.getErrorCodeString(error: error))

                if error == .none {
                    print("GetDeviceName success ->",success)

                    if let deviceName = success {
                        print("deviceName ->",deviceName)

                        self.logView.writeString(string: deviceName)
                    }
                    
                }
            }
            
            break
        case "\(NSLocalizedString("Get the firmware version", comment: "获取固件版本"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get the firmware version", comment: "获取固件版本"))
            ZyCommandModule.shareInstance.getFirmwareVersion{ success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetFirmwareVersion ->",success)
                    
                    if let firmwareVersion = success {
                        print("firmwareVersion ->",firmwareVersion)
                        
                        self.logView.writeString(string: firmwareVersion)
                    }
                    
                }
            }

            break
            
        case "\(NSLocalizedString("Gets the serial number", comment: "获取序列号"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Gets the serial number", comment: "获取序列号"))
            ZyCommandModule.shareInstance.getSerialNumber {success, error in

                self.logView.writeString(string: self.getErrorCodeString(error: error))

                if error == .none {
                    print("GetSerialNumber ->",success)

                    if let serialNumber = success {
                        print("serialNumber ->",serialNumber)

                        self.logView.writeString(string: serialNumber)
                    }
                    
                }

            }
            
            break
        
        case "\(NSLocalizedString("Get mac address", comment: "获取mac地址"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get mac address", comment: "获取mac地址"))
            ZyCommandModule.shareInstance.getMac { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetMac ->",success)
                    
                    if let mac = success {
                        print("mac ->",mac)
                        
                        self.logView.writeString(string: mac)
                    }
                    
                }

            }
            
            break
            
        case "\(NSLocalizedString("Get the power", comment: "获取电量"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get the power", comment: "获取电量"))
            ZyCommandModule.shareInstance.getBattery { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetBattery ->",success)
                    
                    if let battery = success {
                        print("battery ->",battery)
                        
                        self.logView.writeString(string: battery)
                    }
                    
                }

            }

            break
            
        case "\(NSLocalizedString("Set up time", comment: "设置时间"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set up time", comment: "设置时间"))
            let format = DateFormatter.init()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.logView.writeString(string: String.init(format: "%@", format.string(from: Date.init())))
            ZyCommandModule.shareInstance.setTime(time: "") { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetTime ->","设置成功")
                    
                }
                
            }

            break
            
        case "\(NSLocalizedString("Get a list of features supported by your device", comment: "获取设备支持的功能列表"))":
            
            ZyCommandModule.shareInstance.getDeviceSupportList { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    
                    if let model = success {
                        print("GetDeviceSupportList ->",model.showAllSupportFunctionLog())
                                            
                        self.logView.writeString(string: "\(model.showAllSupportFunctionLog())")
                    }
                }
            }

            break
            
        case "\(NSLocalizedString("Obtain version information for products, firmware, and resources", comment: "获取产品、固件、资源等版本信息"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Obtain version information for products, firmware, and resources", comment: "获取产品、固件、资源等版本信息"))
            
            ZyCommandModule.shareInstance.getDeviceOtaVersionInfo { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetDeviceOtaVersionInfo ->",success)
                    
                    let product = success["product"] as! String
                    let project = success["project"] as! String
                    let boot = success["boot"] as! String
                    let firmware = success["firmware"] as! String
                    let library = success["library"] as! String
                    let font = success["font"] as! String
                    
                    print("product ->",product)
                    print("project ->",project)
                    print("boot ->",boot)
                    print("firmware ->",firmware)
                    print("library ->",library)
                    print("font ->",font)
                    
                    self.logView.writeString(string: "product id:\(product)")
                    self.logView.writeString(string: "project id:\(project)")
                    self.logView.writeString(string: "firmware:\(firmware)")
                    self.logView.writeString(string: "library:\(library)")
                    self.logView.writeString(string: "font:\(font)")
                }
            }
            
            break

        case "\(NSLocalizedString("Access to Personal Information", comment: "获取个人信息"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Access to Personal Information", comment: "获取个人信息"))
            
            ZyCommandModule.shareInstance.getPersonalInformation { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetPersonalInformation ->",success)
                    
                    if let model = success {
                        let height = model.height
                        let age = model.age
                        let weight = model.weight
                        let gender = model.gender
                        print("height ->",height,"age ->",age,"weight ->",weight,"gender ->",gender ? NSLocalizedString("female", comment: "女"):NSLocalizedString("male", comment: "男"))
                        
                        self.logView.writeString(string: "age:\(age)")
                        self.logView.writeString(string: "height:\(height)")
                        self.logView.writeString(string: "weight:\(weight)")
                        self.logView.writeString(string: "gender:\(gender ? NSLocalizedString("female", comment: "女"):NSLocalizedString("male", comment: "男"))")
                    }
                    
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }

            break
            
        case "\(NSLocalizedString("Set up personal information", comment: "设置个人信息"))":
            
            let array = [
                "age:[0,255]",
                "height:[0,255]",
                "weight:[0,255]",
                "gender:[0,1] 0\(NSLocalizedString("male", comment: "男"))1\(NSLocalizedString("female", comment: "女"))"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set up personal information", comment: "设置个人信息"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set up personal information", comment: "设置个人信息"), holderStringArray: array, cancel: NSLocalizedString("Cancel", comment: "取消"), cancelAction: {
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) { (textArray) in
                let age = textArray[0]
                let height = textArray[1]
                let weight = textArray[2]
                let gender = textArray[3]
                
                self.logView.writeString(string: "age:\(age.count > 0 ? age:"0")")
                self.logView.writeString(string: "height:\(height.count > 0 ? height:"0")")
                self.logView.writeString(string: "weight:\(weight.count > 0 ? weight:"0")")
                self.logView.writeString(string: "gender:\(gender == "1" ? NSLocalizedString("female", comment: "女"):NSLocalizedString("male", comment: "男"))")
                
                
                let model = ZyPersonalModel.init()
                model.age = Int(age) ?? 0
                model.height = Float(height) ?? 0
                model.weight = Float(weight) ?? 0
                model.gender = (Int(gender) ?? 0) == 0 ? false:true
                
                ZyCommandModule.shareInstance.setPersonalInformation(model: model) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetPersonalInformation ->","设置成功")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "\(NSLocalizedString("Get the time standard", comment: "获取时间制式"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get the time standard", comment: "获取时间制式"))
            
            ZyCommandModule.shareInstance.getTimeFormat { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetTimeFormat ->",success)
                    
                    let timeFormat = success
                    print("timeFormat ->",timeFormat == 0 ? NSLocalizedString("24 hour system", comment: "24小时制"):NSLocalizedString("12 hour system", comment: "12小时制"))
                    
                    self.logView.writeString(string: timeFormat == 0 ? NSLocalizedString("24 hour system", comment: "24小时制"):NSLocalizedString("12 hour system", comment: "12小时制"))
                }
                
                //self.navigationController?.pushViewController(vc, animated: true)
            }

            break
            
        case "\(NSLocalizedString("Set the time standard", comment: "设置时间制式"))":
            
            let array = [
                "format:0-\(NSLocalizedString("24 hour system", comment: "24小时制")),1-\(NSLocalizedString("12 hour system", comment: "12小时制"))"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the time standard", comment: "设置时间制式"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set the time standard", comment: "设置时间制式"), holderStringArray: array, cancel: NSLocalizedString("Cancel", comment: "取消"), cancelAction: {
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) { (textArray) in
                let format = textArray[0]
                
                self.logView.writeString(string: "\(format == "1" ? NSLocalizedString("12 hour system", comment: "12小时制"):NSLocalizedString("24 hour system", comment: "24小时制"))")
                ZyCommandModule.shareInstance.setTimeFormat(format: Int(format) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetTimeFormat ->","设置成功")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            
            
            break
            
        case "\(NSLocalizedString("Get the metric system", comment: "获取公英制"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get the metric system", comment: "获取公英制"))
            ZyCommandModule.shareInstance.getMetricSystem { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetMetricSystem ->",success)
                    
                    let metricSystem = success
                    print("metricSystem ->",metricSystem == 0 ? NSLocalizedString("Metric system", comment: "公制"):NSLocalizedString("British system", comment: "英制"))
                    
                    self.logView.writeString(string: metricSystem == 0 ? NSLocalizedString("Metric system", comment: "公制"):NSLocalizedString("British system", comment: "英制"))
                }
            }
            
            break
            
        case "\(NSLocalizedString("Set the metric system", comment: "设置公英制"))":
            
            let array = [
                "0:\(NSLocalizedString("Metric system", comment: "公制"))，1:\(NSLocalizedString("British system", comment: "英制"))"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the metric system", comment: "设置公英制"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set the metric system", comment: "设置公英制"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let format = textArray[0]
                
                self.logView.writeString(string: format == "1" ? NSLocalizedString("British system", comment: "英制"):NSLocalizedString("Metric system", comment: "公制"))
                
                ZyCommandModule.shareInstance.setMetricSystem(metric: Int(format) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetMetricSystem ->","设置成功")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "\(NSLocalizedString("Set the weather", comment: "设置天气"))":
            
            let array = [
                NSLocalizedString("Days to come", comment: "未来天数"),
                NSLocalizedString("Type of weather", comment: "天气类型"),
                NSLocalizedString("temperature", comment: "温度"),
                NSLocalizedString("Air quality", comment: "空气质量"),
                NSLocalizedString("Minimum temperature", comment: "最低温度"),
                NSLocalizedString("Maximum temperature", comment: "最高温度"),
                NSLocalizedString("Minimum temperature tomorrow", comment: "明日最低温度"),
                NSLocalizedString("Maximum temperature tomorrow", comment: "明日最高温度"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the weather", comment: "设置天气"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set the weather", comment: "设置天气"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let dayCount = textArray[0]
                let type = textArray[1]
                let temp = textArray[2]
                let airQuality = textArray[3]
                let minTemp = textArray[4]
                let maxTemp = textArray[5]
                let tomorrowMinTemp = textArray[6]
                let tomorrowMaxTemp = textArray[7]
                
                self.logView.writeString(string: "第\(dayCount.count>0 ? dayCount : "0")天")
                self.logView.writeString(string: "\(NSLocalizedString("Type of weather", comment: "天气类型")):\(type)")
                self.logView.writeString(string: "\(NSLocalizedString("temperature", comment: "温度")):\(temp)")
                self.logView.writeString(string: "\(NSLocalizedString("Air quality", comment: "空气质量")):\(airQuality)")
                self.logView.writeString(string: "\(NSLocalizedString("Minimum temperature", comment: "最低温度")):\(minTemp)")
                self.logView.writeString(string: "\(NSLocalizedString("Maximum temperature", comment: "最高温度")):\(maxTemp)")
                self.logView.writeString(string: "\(NSLocalizedString("Minimum temperature tomorrow", comment: "明日最低温度")):\(tomorrowMinTemp)")
                self.logView.writeString(string: "\(NSLocalizedString("Maximum temperature tomorrow", comment: "明日最高温度")):\(tomorrowMaxTemp)")
                
                let model = ZyWeatherModel.init()
                model.dayCount = Int(dayCount) ?? 0
                model.type = ZyWeatherType(rawValue:Int(type) ?? 0) ?? .sunny
                model.temp = Int(temp) ?? 0
                model.airQuality = Int(airQuality) ?? 0
                model.minTemp = Int(minTemp) ?? 0
                model.maxTemp = Int(maxTemp) ?? 0
                model.tomorrowMinTemp = Int(tomorrowMinTemp) ?? 0
                model.tomorrowMaxTemp = Int(tomorrowMaxTemp) ?? 0
                
                ZyCommandModule.shareInstance.setWeather(model: model) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetWeather ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case NSLocalizedString("Set weather (expand parameters)", comment: "设置天气(拓展参数)"):
        
            let array = [
                NSLocalizedString("Year", comment: "年"),
                NSLocalizedString("Month", comment: "月"),
                NSLocalizedString("Day", comment: "日"),
                NSLocalizedString("Hour", comment: "时"),
                NSLocalizedString("Minute", comment: "分"),
                NSLocalizedString("Second", comment: "秒"),
                NSLocalizedString("Days to come", comment: "未来天数"),
                NSLocalizedString("Type of weather", comment: "天气类型"),
                NSLocalizedString("temperature", comment: "温度"),
                NSLocalizedString("Air quality", comment: "空气质量"),
                NSLocalizedString("Minimum temperature", comment: "最低温度"),
                NSLocalizedString("Maximum temperature", comment: "最高温度"),
                NSLocalizedString("Minimum temperature tomorrow", comment: "明日最低温度"),
                NSLocalizedString("Maximum temperature tomorrow", comment: "明日最高温度"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the weather", comment: "设置天气"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set the weather", comment: "设置天气"), holderStringArray: array, cancel: nil, cancelAction: {
                
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
                let tomorrowMinTemp = textArray[12]
                let tomorrowMaxTemp = textArray[13]
                
                let date = Date()
                let calendar = NSCalendar.current
                let yearDate = calendar.component(.year, from: date)
                let monthDate = calendar.component(.month, from: date)
                let dayDate = calendar.component(.day, from: date)
                let hourDate = calendar.component(.hour, from: date)
                let minuteDate = calendar.component(.minute, from: date)
                let secondDate = calendar.component(.second, from: date)
                
                let time = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", Int(year) ?? yearDate , Int(month) ?? monthDate , Int(day) ?? dayDate , Int(hour) ?? hourDate , Int(minute) ?? minuteDate , Int(second) ?? secondDate)
                
                self.logView.writeString(string: "\(NSLocalizedString("Time of display", comment: "显示时间")):\(time)")
                self.logView.writeString(string: "第\(dayCount.count>0 ? dayCount : "0")天")
                self.logView.writeString(string: "\(NSLocalizedString("Type of weather", comment: "天气类型")):\(type)")
                self.logView.writeString(string: "\(NSLocalizedString("temperature", comment: "温度")):\(temp)")
                self.logView.writeString(string: "\(NSLocalizedString("Air quality", comment: "空气质量")):\(airQuality)")
                self.logView.writeString(string: "\(NSLocalizedString("Minimum temperature", comment: "最低温度")):\(minTemp)")
                self.logView.writeString(string: "\(NSLocalizedString("Maximum temperature", comment: "最高温度")):\(maxTemp)")
                self.logView.writeString(string: "\(NSLocalizedString("Minimum temperature tomorrow", comment: "明日最低温度")):\(tomorrowMinTemp)")
                self.logView.writeString(string: "\(NSLocalizedString("Maximum temperature tomorrow", comment: "明日最高温度")):\(tomorrowMaxTemp)")
                
                let model = ZyWeatherModel.init()
                model.dayCount = Int(dayCount) ?? 0
                model.type = ZyWeatherType(rawValue:Int(type) ?? 0) ?? .sunny
                model.temp = Int(temp) ?? 0
                model.airQuality = Int(airQuality) ?? 0
                model.minTemp = Int(minTemp) ?? 0
                model.maxTemp = Int(maxTemp) ?? 0
                model.tomorrowMinTemp = Int(tomorrowMinTemp) ?? 0
                model.tomorrowMaxTemp = Int(tomorrowMaxTemp) ?? 0
                
                ZyCommandModule.shareInstance.setWeather(model: model,updateTime: time) { error in

                    self.logView.writeString(string: self.getErrorCodeString(error: error))

                    if error == .none {
                        print("SetWeather ->","success")
                    }
                }
            }
            
            
            break
            
        case "\(NSLocalizedString("The device enters camera mode", comment: "设备进入拍照模式"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("The device enters camera mode", comment: "设备进入拍照模式"))
            ZyCommandModule.shareInstance.setEnterCamera { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetEnterCamera ->","success")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "\(NSLocalizedString("Find a bracelet", comment: "寻找手环"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Find a bracelet", comment: "寻找手环"))
            ZyCommandModule.shareInstance.setFindDevice { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetFindDevice ->","success")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }

            break
            
        case "\(NSLocalizedString("Get a bright screen for wrist lifting", comment: "获取抬腕亮屏"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get a bright screen for wrist lifting", comment: "获取抬腕亮屏"))
            ZyCommandModule.shareInstance.getLightScreen { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("success ->",success)
                    
                    let isOpen = success
                    print("isOpen ->",isOpen == 0 ? NSLocalizedString("Shut down", comment: "关闭"):NSLocalizedString("Turn on", comment: "开启"))
                    
                    self.logView.writeString(string: isOpen == 0 ? NSLocalizedString("Shut down", comment: "关闭"):NSLocalizedString("Turn on", comment: "开启"))
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "\(NSLocalizedString("Set up wrist lift bright screen", comment: "设置抬腕亮屏"))":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set up wrist lift bright screen", comment: "设置抬腕亮屏"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set up wrist lift bright screen", comment: "设置抬腕亮屏"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                
                self.logView.writeString(string: (Int(isOpen) ?? 0) > 0 ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                ZyCommandModule.shareInstance.setLightScreen(isOpen: Int(isOpen) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetLightScreen ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }

            break
            
        case "\(NSLocalizedString("Get screen brightness", comment: "获取屏幕亮度"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get screen brightness", comment: "获取屏幕亮度"))
            
            ZyCommandModule.shareInstance.getScreenLevel { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetScreenLevel ->",success)
                    
                    let level = success
                    print("level ->",level)
                    
                    self.logView.writeString(string: "\(NSLocalizedString("Level of brightness", comment: "亮度等级")):\(level)")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }

            break
            
        case "\(NSLocalizedString("Set screen brightness", comment: "设置屏幕亮度"))":
            let array = [
                NSLocalizedString("Level of brightness", comment: "亮度等级"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set screen brightness", comment: "设置屏幕亮度"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set screen brightness", comment: "设置屏幕亮度"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let level = textArray[0]
                
                self.logView.writeString(string: "\(NSLocalizedString("Level of brightness", comment: "亮度等级")):\(level.count>0 ? level:"0")")
                
                ZyCommandModule.shareInstance.setScreenLevel(value: Int(level) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetScreenLevelAndTime ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "\(NSLocalizedString("Gets the screen duration", comment: "获取亮屏时长"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Gets the screen duration", comment: "获取亮屏时长"))
            
            ZyCommandModule.shareInstance.getScreenTimeLong { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetScreenTimeLong ->",success)
                    
                    let timeLong = success
                    print("timeLong ->",timeLong)
                    
                    self.logView.writeString(string: "\(NSLocalizedString("Screen duration", comment: "亮屏时长")):\(timeLong)")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "\(NSLocalizedString("Set the screen duration", comment: "设置亮屏时长"))":
            let array = [
                NSLocalizedString("Screen duration", comment: "亮屏时长"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the screen duration", comment: "设置亮屏时长"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set the screen duration", comment: "设置亮屏时长"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let timeLong = textArray[0]
                
                self.logView.writeString(string: "\(NSLocalizedString("Screen duration", comment: "亮屏时长")):\(timeLong.count>0 ? timeLong:"0")")
                
                ZyCommandModule.shareInstance.setScreenTimeLong(value: Int(timeLong) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetScreenTimeLong ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            break
            
        case "\(NSLocalizedString("Gets the local watch face", comment: "获取本地表盘"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Gets the local watch face", comment: "获取本地表盘"))
            ZyCommandModule.shareInstance.getLocalDial { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetLocalDial ->",success)
                    
                    let index = success
                    print("index ->",index)
                    
                    self.logView.writeString(string: "\(index)")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "\(NSLocalizedString("Set the local watch face", comment: "设置本地表盘"))":
            let array = [
                "表盘序号"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the local watch face", comment: "设置本地表盘"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set the local watch face", comment: "设置本地表盘"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let index = textArray[0]
                
                self.logView.writeString(string: "\(index.count>0 ? index:"0")")
                ZyCommandModule.shareInstance.setLocalDial(index: Int(index) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetLocalDial ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "\(NSLocalizedString("Get the alarm clock", comment: "获取闹钟"))":

            let array = [
                NSLocalizedString("Alarm clock serial number", comment: "闹钟序号")
            ]

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get the alarm clock", comment: "获取闹钟"))
//            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Get the alarm clock", comment: "获取闹钟"), holderStringArray: array, cancel: nil, cancelAction: {
//
//            }, ok: nil) { (textArray) in
//                let index = textArray[0]
//
//                ZyCommandModule.shareInstance.getAlarm(index: index) { success, error in
//
//                    self.logView.writeString(string: self.getErrorCodeString(error: error))
//
//                    if error == .none {
//                        print("GetAlarm ->",success)
//
//                        let index = success["index"] as! String
//                        let repeatCount = success["repeatCount"] as! String
//                        let hour = success["hour"] as! String
//                        let minute = success["minute"] as! String
//                        print("index ->",index,"repeatCount ->",repeatCount,"hour ->",hour,"minute ->",minute)
//
//                        let alarmModel = ZyAlarmModel.init(dic: success)
//                        print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",alarmModel.alarmTime,"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)
//
//                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock serial number", comment: "闹钟序号")):\(index.count>0 ? index:"0")")
//                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock time", comment: "闹钟时间")):\(alarmModel.alarmTime ?? "00:00")")
//                        self.logView.writeString(string: "repeatCount:\(repeatCount)")
//                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock switch", comment: "闹钟开关")):\(alarmModel.alarmOpen)")
//                        if alarmModel.alarmOpen {
//                            self.logView.writeString(string: "\(NSLocalizedString("Alarm clock repetition type", comment: "闹钟重复类型")):\(alarmModel.alarmType == .single ? NSLocalizedString("Single time alarm clock", comment: "单次闹钟"):NSLocalizedString("Repeat the alarm clock", comment: "重复闹钟"))")
//                            if alarmModel.alarmType == .cycle {
//                                if alarmModel.alarmRepeatArray != nil {
//                                    let str = ((alarmModel.alarmRepeatArray![0] != 0 ? NSLocalizedString("Sunday", comment: "星期天"):"")+(alarmModel.alarmRepeatArray![1] != 0 ? NSLocalizedString("Monday", comment: "星期一"):"")+(alarmModel.alarmRepeatArray![2] != 0 ? NSLocalizedString("Tuesday", comment: "星期二"):"")+(alarmModel.alarmRepeatArray![3] != 0 ? NSLocalizedString("Wednesday", comment: "星期三"):"")+(alarmModel.alarmRepeatArray![4] != 0 ? NSLocalizedString("Thursday", comment: "星期四"):"")+(alarmModel.alarmRepeatArray![5] != 0 ? NSLocalizedString("Friday", comment: "星期五"):"")+(alarmModel.alarmRepeatArray![6] != 0 ? NSLocalizedString("Saturday", comment: "星期六"):""))
//                                    self.logView.writeString(string: "\(NSLocalizedString("The alarm clock repeats the week", comment: "闹钟重复星期")):\(str)")
//                                }else{
//                                    self.logView.writeString(string: NSLocalizedString("Alarm repeat week: Repeat week is not turned on, default single alarm", comment: "闹钟重复星期:重复星期未开启,默认单次闹钟"))
//                                }
//                            }
//                        }
//                    }
//                }
//            }
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Get the alarm clock", comment: "获取闹钟"), message: "", holderStringArray: nil, cancel: "有效闹钟", cancelAction: {
                for i in stride(from: 0, to: 10, by: 1) {
                    ZyCommandModule.shareInstance.getAlarm(index: i) { success, error in

                        if error == .none {
                            print("GetAlarm ->",success)

                            if let alarmModel = success {
                                print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute),"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)
                                if alarmModel.isValid {
                                    self.logView.writeString(string: "\(NSLocalizedString("Alarm clock serial number", comment: "闹钟序号")):\(alarmModel.alarmIndex)")
                                    self.logView.writeString(string: "\(NSLocalizedString("Alarm clock time", comment: "闹钟时间")):\(String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute))")
                                    self.logView.writeString(string: "repeatCount:\(alarmModel.alarmRepeatCount)")
                                    let str = alarmModel.alarmOpen ? "":"\n"
                                    self.logView.writeString(string: "\(NSLocalizedString("Alarm clock switch", comment: "闹钟开关")):\(alarmModel.alarmOpen)\(str)")
                                    if alarmModel.alarmOpen {
                                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock repetition type", comment: "闹钟重复类型")):\(alarmModel.alarmType == .single ? NSLocalizedString("Single time alarm clock", comment: "单次闹钟"):NSLocalizedString("Repeat the alarm clock", comment: "重复闹钟"))")
                                        if alarmModel.alarmType == .cycle {
                                            if alarmModel.alarmRepeatArray != nil {
                                                let str = ((alarmModel.alarmRepeatArray![0] != 0 ? NSLocalizedString("Sunday", comment: "星期天"):"")+(alarmModel.alarmRepeatArray![1] != 0 ? NSLocalizedString("Monday", comment: "星期一"):"")+(alarmModel.alarmRepeatArray![2] != 0 ? NSLocalizedString("Tuesday", comment: "星期二"):"")+(alarmModel.alarmRepeatArray![3] != 0 ? NSLocalizedString("Wednesday", comment: "星期三"):"")+(alarmModel.alarmRepeatArray![4] != 0 ? NSLocalizedString("Thursday", comment: "星期四"):"")+(alarmModel.alarmRepeatArray![5] != 0 ? NSLocalizedString("Friday", comment: "星期五"):"")+(alarmModel.alarmRepeatArray![6] != 0 ? NSLocalizedString("Saturday", comment: "星期六"):""))
                                                print("闹钟重复星期:\(str)")
                                                self.logView.writeString(string: "\(NSLocalizedString("The alarm clock repeats the week", comment: "闹钟重复星期")):\(str)\n")
                                            }else{
                                                self.logView.writeString(string: "\(NSLocalizedString("Alarm repeat week: Repeat week is not turned on, default single alarm", comment: "闹钟重复星期:重复星期未开启,默认单次闹钟"))\n")
                                                print("闹钟重复星期:重复星期未开启,默认单次闹钟")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }, ok: NSLocalizedString("All the alarm clocks", comment: "全部闹钟")) { _ in
                for i in stride(from: 0, to: 10, by: 1) {
                    ZyCommandModule.shareInstance.getAlarm(index: i) { success, error in

                        if error == .none {
                            print("GetAlarm ->",success)

                            if let alarmModel = success {
                                print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute),"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)

                                self.logView.writeString(string: "\(NSLocalizedString("Alarm clock serial number", comment: "闹钟序号")):\(alarmModel.alarmIndex)")
                                self.logView.writeString(string: "\(NSLocalizedString("Alarm clock time", comment: "闹钟时间")):\(String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute))")
                                self.logView.writeString(string: "repeatCount:\(alarmModel.alarmRepeatCount)")
                                let str = alarmModel.alarmOpen ? "":"\n"
                                self.logView.writeString(string: "\(NSLocalizedString("Alarm clock switch", comment: "闹钟开关")):\(alarmModel.alarmOpen)\(str)")
                                if alarmModel.alarmOpen {
                                    self.logView.writeString(string: "\(NSLocalizedString("Alarm clock repetition type", comment: "闹钟重复类型")):\(alarmModel.alarmType == .single ? NSLocalizedString("Single time alarm clock", comment: "单次闹钟"):NSLocalizedString("Repeat the alarm clock", comment: "重复闹钟"))")
                                    if alarmModel.alarmType == .cycle {
                                        if alarmModel.alarmRepeatArray != nil {
                                            let str = ((alarmModel.alarmRepeatArray![0] != 0 ? NSLocalizedString("Sunday", comment: "星期天"):"")+(alarmModel.alarmRepeatArray![1] != 0 ? NSLocalizedString("Monday", comment: "星期一"):"")+(alarmModel.alarmRepeatArray![2] != 0 ? NSLocalizedString("Tuesday", comment: "星期二"):"")+(alarmModel.alarmRepeatArray![3] != 0 ? NSLocalizedString("Wednesday", comment: "星期三"):"")+(alarmModel.alarmRepeatArray![4] != 0 ? NSLocalizedString("Thursday", comment: "星期四"):"")+(alarmModel.alarmRepeatArray![5] != 0 ? NSLocalizedString("Friday", comment: "星期五"):"")+(alarmModel.alarmRepeatArray![6] != 0 ? NSLocalizedString("Saturday", comment: "星期六"):""))
                                            print("闹钟重复星期:\(str)")
                                            self.logView.writeString(string: "\(NSLocalizedString("The alarm clock repeats the week", comment: "闹钟重复星期")):\(str)\n")
                                        }else{
                                            self.logView.writeString(string: "\(NSLocalizedString("Alarm repeat week: Repeat week is not turned on, default single alarm", comment: "闹钟重复星期:重复星期未开启,默认单次闹钟"))\n")
                                            print("闹钟重复星期:重复星期未开启,默认单次闹钟")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Set an alarm", comment: "设置闹钟"))":
            
            let array = [
                NSLocalizedString("Alarm clock serial number", comment: "闹钟序号"),
                NSLocalizedString("Repeat the alarm clock", comment: "重复闹钟"),
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟")
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set an alarm", comment: "设置闹钟"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set an alarm", comment: "设置闹钟"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let index = textArray[0]
                let repeatCount = textArray[1]
                let hour = textArray[2]
                let minute = textArray[3]
                                
//                ZyCommandModule.shareInstance.setAlarm(index: index, repeatCount: repeatCount, hour: hour, minute: minute) { error in
//                    if error == .none {
//                        print("SetAlarm ->","success")
//                    }
//                }
                
                let dic = ["repeatCount": repeatCount, "hour": hour, "index": index, "minute": minute]
                let alarmModel = ZyAlarmModel.init(dic: dic)
                
                self.logView.writeString(string: "\(NSLocalizedString("Alarm clock serial number", comment: "闹钟序号")):\(index.count>0 ? index:"0")")
                self.logView.writeString(string: "\(NSLocalizedString("Alarm clock time", comment: "闹钟时间")):\(String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute))")
                self.logView.writeString(string: "repeatCount:\(repeatCount)")
                self.logView.writeString(string: "\(NSLocalizedString("Alarm clock switch", comment: "闹钟开关")):\(alarmModel.alarmOpen)")
                if alarmModel.alarmOpen {
                    self.logView.writeString(string: "\(NSLocalizedString("Alarm clock repetition type", comment: "闹钟重复类型")):\(alarmModel.alarmType == .single ? NSLocalizedString("Single time alarm clock", comment: "单次闹钟"):NSLocalizedString("Repeat the alarm clock", comment: "重复闹钟"))")
                    if alarmModel.alarmType == .cycle {
                        if alarmModel.alarmRepeatArray != nil {
                            let str = ((alarmModel.alarmRepeatArray![0] != 0 ? NSLocalizedString("Sunday", comment: "星期天"):"")+(alarmModel.alarmRepeatArray![1] != 0 ? NSLocalizedString("Monday", comment: "星期一"):"")+(alarmModel.alarmRepeatArray![2] != 0 ? NSLocalizedString("Tuesday", comment: "星期二"):"")+(alarmModel.alarmRepeatArray![3] != 0 ? NSLocalizedString("Wednesday", comment: "星期三"):"")+(alarmModel.alarmRepeatArray![4] != 0 ? NSLocalizedString("Thursday", comment: "星期四"):"")+(alarmModel.alarmRepeatArray![5] != 0 ? NSLocalizedString("Friday", comment: "星期五"):"")+(alarmModel.alarmRepeatArray![6] != 0 ? NSLocalizedString("Saturday", comment: "星期六"):""))
                            self.logView.writeString(string: "\(NSLocalizedString("The alarm clock repeats the week", comment: "闹钟重复星期")):\(str)")
                        }else{
                            self.logView.writeString(string: NSLocalizedString("Alarm repeat week: Repeat week is not turned on, default single alarm", comment: "闹钟重复星期:重复星期未开启,默认单次闹钟"))
                        }
                    }
                }
                
                print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute),"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)
                
                ZyCommandModule.shareInstance.setAlarmModel(model: alarmModel) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetAlarm ->","success")
                    }
                }
                //self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            break
            
        case "\(NSLocalizedString("Get the device language", comment: "获取设备语言"))":

            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get the device language", comment: "获取设备语言"))
            ZyCommandModule.shareInstance.getDeviceLanguage { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetDeviceLanguage ->",success)
                    
                    let index = success
                    print("index ->",index)
                    self.logView.writeString(string: "\(index)")
                }
                
            }
            //self.navigationController?.pushViewController(vc, animated: true)
            break
            
        case "\(NSLocalizedString("Set the device language", comment: "设置设备语言"))":

            
            let array = [
                NSLocalizedString("Language serial number", comment: "语言序号")
            ]
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the device language", comment: "设置设备语言"))
            
            //0英语1中文简体2日语3韩语4德语5法语6西班牙语7阿拉伯语8俄语9中文繁体10意大利11葡萄牙12乌克兰语13印地语
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: "\(NSLocalizedString("Set the device language", comment: "设置设备语言"))\n\(NSLocalizedString("0 English 1 Simplified Chinese 2 Japanese 3 Korean 4 German 5 French 6 Spanish 7 Arabic 8 Russian 9 Traditional Chinese 10 Italian 11 Portuguese 12 Ukrainian 13 Hindi 14 Polish 15 Greek 16 Vietnamese 17 Indonesian 18 Thai 19 Dutch 20 Turkish 21 Romanian 22 Danish 23 Swedish 24 Bangladeshi Latin 25 Czech 26 Persian 27 Hebrew 28 Malay 29 Slovak 30 Xhosa 31 Slovenian 32 Hungarian 33 Lithuanian 34 Urdu 35 Bulgarian 36 Croatian 37 Latvian 38 Estonian 39 Khmer", comment: "0英文1简体中文2日语3韩语4德语5法语6西班牙语7阿拉伯语8俄语9繁体中文10意大利语11葡萄牙语12乌克兰语13印地语14波兰语15希腊语16越南语17印度尼西亚语18泰语19荷兰语20土耳其语21罗马尼亚语22丹麦语23瑞典语24孟加拉语25捷克语26波斯语27希伯来语28马来语29斯洛伐克语30南非科萨语31斯洛文尼亚语32匈牙利语33立陶宛语34乌尔都语35保加利亚语36克罗地亚语37拉脱维亚语38爱沙尼亚语39高棉语"))", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let index = textArray[0]
                
                self.logView.writeString(string: index.count > 0 ? index:"0")
                ZyCommandModule.shareInstance.setDeviceLanguage(index: Int(index) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetDeviceLanguage ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "\(NSLocalizedString("Gets the target number of steps", comment: "获取目标步数"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Gets the target number of steps", comment: "获取目标步数"))
            ZyCommandModule.shareInstance.getStepGoal { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetStepGoal ->",success)
                    
                    let stepGoal = success
                    print("stepGoal ->",stepGoal)
                    
                    self.logView.writeString(string: "\(stepGoal)")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }
                        
            break
            
        case "\(NSLocalizedString("Set the target number of steps", comment: "设置目标步数"))":
            
            let array = [
                NSLocalizedString("Target number of steps", comment: "目标步数")
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the target number of steps", comment: "设置目标步数"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set the target number of steps", comment: "设置目标步数"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let target = textArray[0]
                
                self.logView.writeString(string: target.count>0 ? target:"0")
                ZyCommandModule.shareInstance.setStepGoal(target: Int(target) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetStepGoal ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "\(NSLocalizedString("Set up a single measurement", comment: "设置单次测量"))":
                        
            let array = [
                "\(NSLocalizedString("Type", comment: "类型"))：0-\(NSLocalizedString("Heart rate", comment: "心率"))，1-\(NSLocalizedString("Blood pressure", comment: "血压"))，2-\(NSLocalizedString("Blood oxygen", comment: "血氧"))",
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set up a single measurement", comment: "设置单次测量"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set up a single measurement", comment: "设置单次测量"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let isOpen = textArray[1]
                if type.count > 0 {
                    var str = ""
                    if type == "0" {
                        str = NSLocalizedString("Heart rate", comment: "心率")
                    }else if type == "1" {
                        str = NSLocalizedString("Blood pressure", comment: "血压")
                    }else if type == "2" {
                        str = NSLocalizedString("Blood oxygen", comment: "血氧")
                    }else{
                        str = type
                    }
                    self.logView.writeString(string: "\(NSLocalizedString("Type of measurement", comment: "测量类型")):\(str)")
                }else{
                    self.logView.writeString(string: "\(NSLocalizedString("Type of measurement", comment: "测量类型")):\(NSLocalizedString("Heart rate", comment: "心率"))")
                }

                self.logView.writeString(string: (Int(isOpen) ?? 0) > 0 ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                
                ZyCommandModule.shareInstance.setSingleMeasurement(type: Int(type) ?? 0, isOpen: Int(isOpen) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetSingleMeasurement ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "\(NSLocalizedString("Get Exercise patterns", comment: "获取锻炼模式"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get Exercise patterns", comment: "获取锻炼模式"))
            ZyCommandModule.shareInstance.getExerciseMode { success, state, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    print("GetExerciseMode ->",success)
                    
                    let type = success
                    print("type ->",type)
                    var stateString = ""
                    if state == .unknow {
                        stateString = NSLocalizedString("The state is not supported", comment: "不支持的状态")
                        print(stateString)
                    }else if state == .end {
                        stateString = NSLocalizedString("End of", comment: "结束")
                        print(stateString)
                    }else if state == .start {
                        stateString = NSLocalizedString("Start", comment: "开始")
                        print(stateString)
                    }else if state == .continue {
                        stateString = NSLocalizedString("Go on", comment: "继续")
                        print(stateString)
                    }else if state == .pause {
                        stateString = NSLocalizedString("Pause", comment: "暂停")
                        print(stateString)
                    }
                    self.logView.writeString(string: "\(type.rawValue),\(stateString)")
                }
            }
            
            break
            
        case "\(NSLocalizedString("Set exercise mode", comment: "设置锻炼模式"))":
            
            let array = [
                NSLocalizedString("Type of exercise", comment: "锻炼类型"),
                "0:\(NSLocalizedString("Drop out", comment: "退出")),1:\(NSLocalizedString("Enter into", comment: "进入")),2:\(NSLocalizedString("Go on", comment: "继续")),3:\(NSLocalizedString("Pause", comment: "暂停"))",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set exercise mode", comment: "设置锻炼模式"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set exercise mode", comment: "设置锻炼模式"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let isOpen = textArray[1]
                
                self.logView.writeString(string: "\(NSLocalizedString("Type of exercise", comment: "锻炼类型")):\(type.count>0 ? type:"0")")
                var stateString = NSLocalizedString("Drop out", comment: "退出")
                if Int(isOpen) == 0 {
                    stateString = NSLocalizedString("Drop out", comment: "退出")
                    self.timestamp = nil
                }else if Int(isOpen) == 1 {
                    stateString = NSLocalizedString("Enter into", comment: "进入")
                    let timestamp = Int(Date().timeIntervalSince1970)
                    self.timestamp = timestamp
                }else if Int(isOpen) == 2 {
                    stateString = NSLocalizedString("Go on", comment: "继续")
                }else if Int(isOpen) == 3 {
                    stateString = NSLocalizedString("Pause", comment: "暂停")
                }
                self.logView.writeString(string: stateString)
                let state = ZyExerciseState.init(rawValue: Int(isOpen) ?? 0) ?? .end
                
                self.logView.writeString(string: "\(self.timestamp)")
                print("timestamp = \(self.timestamp)")
                ZyCommandModule.shareInstance.setExerciseMode(type: ZyExerciseType.init(rawValue: Int(type) ?? 0) ?? .runOutside, isOpen: state, timestamp: self.timestamp ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetExerciseMode ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "\(NSLocalizedString("Get weather units", comment: "获取天气单位"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get weather units", comment: "获取天气单位"))
            
            ZyCommandModule.shareInstance.getWeatherUnit { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetWeatherUnit ->",success)
                    
                    let weatherUnit = success
                    print("weatherUnit ->",weatherUnit)
                    
                    self.logView.writeString(string: weatherUnit == 0 ? NSLocalizedString("Degrees Celsius", comment: "摄氏度"):NSLocalizedString("Degrees Fahrenheit", comment: "华氏度"))
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "\(NSLocalizedString("Set weather units", comment: "设置天气单位"))":
            let array = [
                "0:\(NSLocalizedString("Degrees Celsius", comment: "摄氏度")),1:\(NSLocalizedString("Degrees Fahrenheit", comment: "华氏度"))",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set weather units", comment: "设置天气单位"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set weather units", comment: "设置天气单位"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                ZyCommandModule.shareInstance.setWeatherUnit(type: Int(type) ?? 0) { error in
                    
                    self.logView.writeString(string: (type as NSString).intValue > 0 ? NSLocalizedString("Degrees Fahrenheit", comment: "华氏度"):NSLocalizedString("Degrees Celsius", comment: "摄氏度"))
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetWeatherUnit ->","success")
                    }
                }
            }
            break
            
        case "\(NSLocalizedString("Set the real-time data reporting switch", comment: "设置实时数据上报开关"))":

            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭")),1:\(NSLocalizedString("Turn on", comment: "开启"))",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the real-time data reporting switch", comment: "设置实时数据上报开关"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set the real-time data reporting switch", comment: "设置实时数据上报开关"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                
                ZyCommandModule.shareInstance.setReportRealtimeData(isOpen: Int(isOpen) ?? 0, success: { error in
                    
                    self.logView.writeString(string: (Int(isOpen) ?? 0) == 0 ? NSLocalizedString("Shut down", comment: "关闭"):NSLocalizedString("Turn on", comment: "开启"))
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetReportRealtimeData ->","success")
                    }
                })
            }
            break
            
        case "\(NSLocalizedString("Gets a custom watch face", comment: "获取自定义表盘"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Gets a custom watch face", comment: "获取自定义表盘"))
            
            ZyCommandModule.shareInstance.getCustomDialEdit { success, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetCustomDialEdit ->",success)
                    
                    if let model = success {
                        let colorHex = model.colorHex
                        let positionType = model.positionType
                        let timeUpType = model.timeUpType
                        let timeDownType = model.timeDownType
                        let color = model.color
                        print("color ->",color)
                        
                        self.logView.writeString(string: "\(NSLocalizedString("Value of color", comment: "颜色值")):\(colorHex)")
                        self.logView.writeString(string: "\(NSLocalizedString("Type of location", comment: "位置类型")):\(positionType.rawValue)")
                        self.logView.writeString(string: "\(NSLocalizedString("Above the time", comment: "时间上方")):\(timeUpType.rawValue)")
                        self.logView.writeString(string: "\(NSLocalizedString("Below the time", comment: "时间下方")):\(timeDownType.rawValue)")
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Set up a custom watch face", comment: "设置自定义表盘"))":
            let array = [
                NSLocalizedString("Enter the hexadecimal color value", comment: "输入十六进制颜色值"),
                NSLocalizedString("Display position,0 top left 1 Middle left 2 Bottom left 3 Top right 4 Middle right 5 bottom right", comment: "显示位置,0左上1左中2左下3右上4右中5右下"),
                "\(NSLocalizedString("Above the time", comment: "时间上方")),0\(NSLocalizedString("Shut down", comment: "关闭"))1\(NSLocalizedString("Date", comment: "日期"))2\(NSLocalizedString("Sleep", comment: "睡眠"))3\(NSLocalizedString("Heart rate", comment: "心率"))4\(NSLocalizedString("Step counting", comment: "计步"))5\(NSLocalizedString("Week of the week", comment: "星期"))",
                "\(NSLocalizedString("Below the time", comment: "时间下方")),0\(NSLocalizedString("Shut down", comment: "关闭"))1\(NSLocalizedString("Date", comment: "日期"))2\(NSLocalizedString("Sleep", comment: "睡眠"))3\(NSLocalizedString("Heart rate", comment: "心率"))4\(NSLocalizedString("Step counting", comment: "计步"))5\(NSLocalizedString("Week of the week", comment: "星期"))"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set up a custom watch face", comment: "设置自定义表盘"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set up a custom watch face", comment: "设置自定义表盘"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let color = textArray[0]
                let positionType = textArray[1]
                let timeUpType = textArray[2]
                let timeDownType = textArray[3]
                
                self.logView.writeString(string: "\(NSLocalizedString("Value of color", comment: "颜色值")):\(color)")
                self.logView.writeString(string: "\(NSLocalizedString("Type of location", comment: "位置类型")):\(positionType)")
                self.logView.writeString(string: "\(NSLocalizedString("Above the time", comment: "时间上方")):\(timeUpType)")
                self.logView.writeString(string: "\(NSLocalizedString("Below the time", comment: "时间下方")):\(timeDownType)")
                
                let model = ZyCustomDialModel.init()
                model.color = UIColor.init(hexString: color)
                model.positionType = ZyPositionType.init(rawValue: Int(positionType) ?? 0) ?? .leftTop
                model.timeUpType = ZyPositionShowType.init(rawValue: Int(timeUpType) ?? 0) ?? .close
                model.timeDownType = ZyPositionShowType.init(rawValue: Int(timeDownType) ?? 0) ?? .close
                
                ZyCommandModule.shareInstance.setCustomDialEdit(model: model) { error in
                    
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))

                    if error == .none {
                        print("setCustomDialEdit ->","success")
                    }
                }
                
            }
            break
            
        case "\(NSLocalizedString("Set phone status", comment: "设置电话状态"))":
            
            let array = [
                "0:\(NSLocalizedString("Hang up", comment: "挂断")),1:\(NSLocalizedString("Answer the phone", comment: "接听"))",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set phone status", comment: "设置电话状态"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set phone status", comment: "设置电话状态"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let state = textArray[0]
                
                ZyCommandModule.shareInstance.setPhoneState(state: state) { error in
                    
                    self.logView.writeString(string: state == "1" ? NSLocalizedString("Answer the phone", comment: "接听"):NSLocalizedString("Hang up", comment: "挂断"))
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetPhoneState ->","success")
                    }
                }

            }
            
            break
            
        case "\(NSLocalizedString("Gets the custom dial dimensions", comment: "获取自定义表盘尺寸"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Gets the custom dial dimensions", comment: "获取自定义表盘尺寸"))
            
            ZyCommandModule.shareInstance.getCustonDialFrameSize { success, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))

                if error == .none {
                    print("GetCustonDialFrameSize ->",success)

                    if let model = success {
                        let bigWidth = model.bigWidth
                        let bigheight = model.bigHeight
                        let smallWidth = model.smallWidth
                        let smallHeight = model.smallHeight
                        
                        self.logView.writeString(string: String.init(format: "%dx%d,%dx%d", bigWidth,bigheight,smallWidth,smallHeight))
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Get a 24-hour heart rate monitor", comment: "获取24小时心率监测"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get a 24-hour heart rate monitor", comment: "获取24小时心率监测"))
            
            ZyCommandModule.shareInstance.get24HrMonitor { success, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("Get24HrMonitor ->",success)
                    
                    let isOpen = success
                    self.logView.writeString(string: isOpen == 0 ? NSLocalizedString("Shut down", comment: "关闭"):NSLocalizedString("Turn on", comment: "开启"))
                }
            }
            
            break

        case "\(NSLocalizedString("Set up a 24-hour heart rate monitor", comment: "设置24小时心率监测"))":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭")),1:\(NSLocalizedString("Turn on", comment: "开启"))",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set up a 24-hour heart rate monitor", comment: "设置24小时心率监测"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set up a 24-hour heart rate monitor", comment: "设置24小时心率监测"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                
                ZyCommandModule.shareInstance.set24HrMonitor(isOpen: Int(isOpen) ?? 0) { error in
                    
                    self.logView.writeString(string: (Int(isOpen) ?? 0) == 0 ? NSLocalizedString("Shut down", comment: "关闭"):NSLocalizedString("Turn on", comment: "开启"))
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("Set24HrMonitor ->","success")
                    }
                }
            }
            
            break

        case "\(NSLocalizedString("Set the device to enter or exit photo mode", comment: "设置设备进入或退出拍照模式"))":
            
            let array = [
                "0:\(NSLocalizedString("Enter into", comment: "进入")),1:\(NSLocalizedString("Drop out", comment: "退出"))",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the device to enter or exit photo mode", comment: "设置设备进入或退出拍照模式"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set the device to enter or exit photo mode", comment: "设置设备进入或退出拍照模式"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                
                ZyCommandModule.shareInstance.setEnterOrExitCamera(isOpen: Int(isOpen) ?? 0) { error in
                    self.logView.writeString(string: (Int(isOpen) ?? 0) == 0 ? NSLocalizedString("Enter into", comment: "进入"):NSLocalizedString("Drop out", comment: "退出"))
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("Set24HrMonitor ->","success")
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("app synchronizes motion data to the device (manually customized)", comment: "app同步运动数据至设备(手动自定义)"))":
            
            let array = [
                NSLocalizedString("Type of exercise", comment: "锻炼类型"),
                NSLocalizedString("Duration of exercise", comment: "运动时长"),
                NSLocalizedString("Calories", comment: "卡路里"),
                NSLocalizedString("Distance", comment: "距离"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("app synchronizes motion data to the device", comment: "app同步运动数据至设备"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("app synchronizes motion data to the device", comment: "app同步运动数据至设备"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let timeLong = textArray[1]
                let calories = textArray[2]
                let distance = textArray[3]
                
                ZyCommandModule.shareInstance.setExerciseDataToDevice(type: ZyExerciseType.init(rawValue: Int(type) ?? 0) ?? .runOutside, timeLong: Int(timeLong) ?? 0, calories: Int(calories) ?? 0, distance: Int(distance) ?? 0) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setExerciseDataToDevice ->","success")
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("app synchronizes motion data to the device (automatic 1s increment)", comment: "app同步运动数据至设备(自动1s递增)"))":
            
            let array = [
                NSLocalizedString("Type of exercise", comment: "锻炼类型"),
                NSLocalizedString("Increasing number of exercise duration (default 1)", comment: "运动时长递增数(默认1)"),
                NSLocalizedString("Calorie increment (default 1)", comment: "卡路里递增数(默认1)"),
                NSLocalizedString("Distance increment number (default 1)", comment: "距离递递增数(默认1)"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("app synchronizes motion data to the device", comment: "app同步运动数据至设备"))
            
            var timer:Timer?
            
            if #available(iOS 10.0, *) {
                
                self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("app synchronizes motion data to the device", comment: "app同步运动数据至设备"), holderStringArray: array, cancel: NSLocalizedString("Cancel", comment: "取消"), cancelAction: {
                    
                }, ok: NSLocalizedString("Start", comment: "开始")) { (textArray) in
                    var timeLong = 0
                    var calories = 0
                    var distance = 0
                    
                    let type = textArray[0]
                    let timeLongAddCount = textArray[1]
                    let caloriesAddCount = textArray[2]
                    let distanceAddCount = textArray[3]
                    
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { time in
                        timeLong += (Int(timeLongAddCount) ?? 1)
                        calories += (Int(caloriesAddCount) ?? 1)
                        distance += (Int(distanceAddCount) ?? 1)
                        print("timeLong = \(timeLong), calories = \(calories), distance = \(distance)")
                        self.logView.writeString(string: "\(NSLocalizedString("Type of exercise", comment: "锻炼类型")):\(Int(type) ?? 0)")
                        self.logView.writeString(string: "\(NSLocalizedString("Duration of exercise", comment: "运动时长")):\(timeLong)")
                        self.logView.writeString(string: "\(NSLocalizedString("Calories", comment: "卡路里")):\(calories)")
                        self.logView.writeString(string: "\(NSLocalizedString("Distance", comment: "距离")):\(distance)\n")
                        ZyCommandModule.shareInstance.setExerciseDataToDevice(type: ZyExerciseType.init(rawValue: Int(type) ?? 0) ?? .runOutside, timeLong: timeLong, calories: calories, distance: distance) { error in

                            if error == .none {
                                print("setExerciseDataToDevice ->","success")
                            }
                        }
                    }
                    
                    self.presentSystemAlertVC(title: NSLocalizedString("Tips", comment: "提示"), message: NSLocalizedString("Click OK to end this automatic send", comment: "点击确定结束此次自动发送"), cancelAction: nil) {
                        timer?.invalidate()
                        timer = nil
                    }
                }
                
            } else {
                
            }
            
            break
            
        case "\(NSLocalizedString("Set to clear all data", comment: "设置清除所有数据"))":
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set to clear all data", comment: "设置清除所有数据"))
            
            ZyCommandModule.shareInstance.setClearAllData { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("setClearAllData ->","success")
                }
            }
            
            break
            
        case "\(NSLocalizedString("Binding up", comment: "绑定"))":
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Binding up", comment: "绑定"))
            
            ZyCommandModule.shareInstance.setBind { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("setBind ->","success")
                }
            }
            
            break
            
        case "\(NSLocalizedString("unbind", comment: "解绑"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("unbind", comment: "解绑"))
            
            ZyCommandModule.shareInstance.setUnbind { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("setUnbind ->","success")
                }
            }
            break

        case "\(NSLocalizedString("Get message alerts", comment: "获取消息提醒"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get message alerts", comment: "获取消息提醒"))
            ZyCommandModule.shareInstance.getNotificationRemind { success,success1, error  in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetMessageRemind ->",success)
                    
                    let array = success
                    print("GetMessageRemind ->",array)
                    
                    let array1 = success1
                    print("GetMessageRemind ->",array1)
                    self.logView.writeString(string: "\(NSLocalizedString("Message type switch", comment: "消息类型开关")):\(array)")
                    self.logView.writeString(string: "\(NSLocalizedString("Extended message switch", comment: "拓展消息开关")):\(array1)")
                }
                
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "\(NSLocalizedString("Set message reminders", comment: "设置消息提醒"))":
            
            let array = [
                NSLocalizedString("Message type switch", comment: "消息类型开关"),
                NSLocalizedString("Extended message switch", comment: "拓展消息开关"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set message reminders", comment: "设置消息提醒"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set message reminders", comment: "设置消息提醒"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let extensionOpen = textArray[1]
                
//                ZyCommandModule.shareInstance.setNotificationRemind(isOpen: isOpen) { error in
//                    self.logView.writeString(string: self.getErrorCodeString(error: error))
//
//                    if error == .none {
//                        print("SetMessageRemind ->","success")
//                    }
//                    //self.navigationController?.pushViewController(vc, animated: true)
//                }
                if #available(iOS 13.0, *) {
                    if let state = ZyCommandModule.shareInstance.peripheral?.ancsAuthorized {
                        self.logView.writeString(string: "蓝牙共享系统通知:\(state ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))")
                    }
                }
                let array = ZyCommandModule.shareInstance.getNotificationTypeArrayWithIntString(countString: isOpen)
                print("array ->",array)
                let extensionArray = ZyCommandModule.shareInstance.getNotificationExtensionTypeArrayWithIntString(countString: extensionOpen)
                print("extensionArray ->",extensionArray)
                
                self.logView.writeString(string: "\(NSLocalizedString("Message type switch", comment: "消息类型开关")):\(array)")
                self.logView.writeString(string: "\(NSLocalizedString("Extended message switch", comment: "拓展消息开关")):\(extensionArray)")
                ZyCommandModule.shareInstance.setNotificationRemindArray(array: array, extensionArray: extensionArray) { error in

                    self.logView.writeString(string: self.getErrorCodeString(error: error))

                    if error == .none {
                        print("SetMessageRemind ->","success")
                    }
                }
                
            }

            break
            
        case "\(NSLocalizedString("Get sedentary reminders", comment: "获取久坐提醒"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get sedentary reminders", comment: "获取久坐提醒"))
            ZyCommandModule.shareInstance.getSedentary { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetSedentary ->",success)
                    
                    if let model = success {
                        let isOpen = model.isOpen
                        let timeLong = model.timeLong
                        let modelArray = model.timeArray
                        self.logView.writeString(string: isOpen ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                        self.logView.writeString(string: "\(NSLocalizedString("Length of interval", comment: "间隔时长")):\(timeLong)")
                        for item in modelArray {
                            self.logView.writeString(string: "\(NSLocalizedString("Time to start", comment: "开始时间")):\(item.startHour).\(item.startMinute)")
                            self.logView.writeString(string: "\(NSLocalizedString("End of period", comment: "结束时间")):\(item.endHour).\(item.endMinute)")
                        }
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Set a sedentary reminder (one set)", comment: "设置久坐提醒(一组)"))":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))",
                NSLocalizedString("Length of interval", comment: "间隔时长"),
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟"),
                NSLocalizedString("Closing hours", comment: "结束小时"),
                NSLocalizedString("End of the minute", comment: "结束分钟"),
                
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set reminders for sitting", comment: "设置久坐提醒"))
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0,格式错误可能闪退)", message: NSLocalizedString("Set reminders for sitting", comment: "设置久坐提醒"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let timeLong = textArray[1]
                let startHour = textArray[2]
                let startMinute = textArray[3]
                let endHour = textArray[4]
                let endMinute = textArray[5]
                
                self.logView.writeString(string: (Int(isOpen) ?? 0) > 0 ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                self.logView.writeString(string: "\(NSLocalizedString("Time to start", comment: "开始时间")):\(startHour.count>0 ? startHour:"0").\(startMinute.count>0 ? startMinute:"0")")
                self.logView.writeString(string: "\(NSLocalizedString("End of period", comment: "结束时间")):\(endHour.count>0 ? endHour:"0").\(endMinute.count>0 ? endMinute:"0")")
                self.logView.writeString(string: "\(NSLocalizedString("Length of interval", comment: "间隔时长")):\(timeLong.count>0 ? timeLong:"0")")
                
                ZyCommandModule.shareInstance.setSedentary(isOpen: isOpen, timeLong: timeLong, startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetSedentary ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }

            break
            
        case "\(NSLocalizedString("Set a sedentary reminder (multiple groups)", comment: "设置久坐提醒(多组)"))":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))",
                NSLocalizedString("Length of interval", comment: "间隔时长"),
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟"),
                NSLocalizedString("Closing hours", comment: "结束小时"),
                NSLocalizedString("End of the minute", comment: "结束分钟"),
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟"),
                NSLocalizedString("Closing hours", comment: "结束小时"),
                NSLocalizedString("End of the minute", comment: "结束分钟"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set reminders for sitting", comment: "设置久坐提醒"))
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0,格式错误可能闪退)", message: NSLocalizedString("Set reminders for sitting", comment: "设置久坐提醒"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let timeLong = textArray[1]
                let startHour = textArray[2]
                let startMinute = textArray[3]
                let endHour = textArray[4]
                let endMinute = textArray[5]
                let startHour_2 = textArray[6]
                let startMinute_2 = textArray[7]
                let endHour_2 = textArray[8]
                let endMinute_2 = textArray[9]
                
                self.logView.writeString(string: (Int(isOpen) ?? 0) > 0 ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                self.logView.writeString(string: "\(NSLocalizedString("Length of interval", comment: "间隔时长")):\(timeLong.count>0 ? timeLong:"0")")
                self.logView.writeString(string: "1\(NSLocalizedString("Time to start", comment: "开始时间")):\(startHour.count>0 ? startHour:"0").\(startMinute.count>0 ? startMinute:"0")")
                self.logView.writeString(string: "1\(NSLocalizedString("End of period", comment: "结束时间")):\(endHour.count>0 ? endHour:"0").\(endMinute.count>0 ? endMinute:"0")")
                self.logView.writeString(string: "2\(NSLocalizedString("Time to start", comment: "开始时间")):\(startHour_2.count>0 ? startHour_2:"0").\(startMinute_2.count>0 ? startMinute_2:"0")")
                self.logView.writeString(string: "2\(NSLocalizedString("End of period", comment: "结束时间")):\(endHour_2.count>0 ? endHour_2:"0").\(endMinute_2.count>0 ? endMinute_2:"0")")
                
                let model = ZyStartEndTimeModel.init()
                model.startHour = Int(startHour) ?? 0
                model.startMinute = Int(startMinute) ?? 0
                model.endHour = Int(endHour) ?? 0
                model.endMinute = Int(endMinute) ?? 0
                
                let model_2 = ZyStartEndTimeModel.init()
                model_2.startHour = Int(startHour_2) ?? 0
                model_2.startMinute = Int(startMinute_2) ?? 0
                model_2.endHour = Int(endHour_2) ?? 0
                model_2.endMinute = Int(endMinute_2) ?? 0
                
                let sedentaryModel = ZySedentaryModel.init()
                sedentaryModel.isOpen = (Int(isOpen) ?? 0) == 0 ? false:true
                sedentaryModel.timeLong = Int(timeLong) ?? 0
                sedentaryModel.timeArray = [model,model_2]
                
                ZyCommandModule.shareInstance.setSedentary(model: sedentaryModel) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))

                    if error == .none {
                        print("SetSedentary ->","success")
                    }

                }
                
//                ZyCommandModule.shareInstance.setSedentary(isOpen: isOpen, timeLong: timeLong, timeArray: [model,model_2]) { error in
//
//                    self.logView.writeString(string: self.getErrorCodeString(error: error))
//
//                    if error == .none {
//                        print("SetSedentary ->","success")
//                    }
//
//                }
                
            }
            break

        case "\(NSLocalizedString("Get Do not disturb reminders", comment: "获取勿扰提醒"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get Do not disturb reminders", comment: "获取勿扰提醒"))
            
            ZyCommandModule.shareInstance.getDoNotDisturb { success, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    
                    print("GetDoNotDisturb ->",success)
                    
                    if let model = success {
                        let isOpen = model.isOpen
                        let startHour = model.timeModel.startHour
                        let startMinute = model.timeModel.startMinute
                        let endHour = model.timeModel.endHour
                        let endMinute = model.timeModel.endMinute
                        
                        self.logView.writeString(string: isOpen ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                        self.logView.writeString(string: "\(NSLocalizedString("Time to start", comment: "开始时间")):\(startHour):\(startMinute)")
                        self.logView.writeString(string: "\(NSLocalizedString("End of period", comment: "结束时间")):\(endHour):\(endMinute)")
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Set Do not disturb reminder", comment: "设置勿扰提醒"))":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))",
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟"),
                NSLocalizedString("Closing hours", comment: "结束小时"),
                NSLocalizedString("End of the minute", comment: "结束分钟")
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set Do not disturb reminder", comment: "设置勿扰提醒"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set Do not disturb reminder", comment: "设置勿扰提醒"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let startHour = textArray[1]
                let startMinute = textArray[2]
                let endHour = textArray[3]
                let endMinute = textArray[4]
                
                self.logView.writeString(string: (Int(isOpen) ?? 0) == 0 ? NSLocalizedString("Shut down", comment: "关闭"):NSLocalizedString("Turn on", comment: "开启"))
                self.logView.writeString(string: String.init(format: "\(NSLocalizedString("Time to start", comment: "开始时间")) %02d:%02d", Int(startHour) ?? 0,Int(startMinute) ?? 0))
                self.logView.writeString(string: String.init(format: "\(NSLocalizedString("End of period", comment: "结束时间")) %02d:%02d", Int(endHour) ?? 0,Int(endMinute) ?? 0))
                
                ZyCommandModule.shareInstance.setDoNotDisturb(isOpen: isOpen, startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetDoNotDisturb -> success")
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Get heart rate alerts", comment: "获取心率预警"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get heart rate alerts", comment: "获取心率预警"))
            
            ZyCommandModule.shareInstance.getHrWaring { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetHrWaring ->",success)
                    
                    if let model = success {
                        let isOpen = model.isOpen
                        let maxHr = model.maxValue
                        let minHr = model.minValue
                        
                        self.logView.writeString(string: isOpen ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                        self.logView.writeString(string: "\(NSLocalizedString("Maximum value", comment: "最大值")):\(maxHr)")
                        self.logView.writeString(string: "\(NSLocalizedString("Minimum value", comment: "最小值")):\(minHr)")
                    }
                    
                    
                }
            }
            
            break

        case "\(NSLocalizedString("Set heart rate alert", comment: "设置心率预警"))":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))",
                NSLocalizedString("Maximum value", comment: "最大值"),
                NSLocalizedString("Minimum value", comment: "最小值"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set heart rate alert", comment: "设置心率预警"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set heart rate alert", comment: "设置心率预警"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let maxHr = textArray[1]
                let minHr = textArray[2]
                
                self.logView.writeString(string: (Int(isOpen) ?? 0) == 0 ? NSLocalizedString("Shut down", comment: "关闭"):NSLocalizedString("Turn on", comment: "开启"))
                self.logView.writeString(string: "\(NSLocalizedString("Maximum value", comment: "最大值")):\(maxHr)")
                self.logView.writeString(string: "\(NSLocalizedString("Minimum value", comment: "最小值")):\(minHr)")
                
                ZyCommandModule.shareInstance.setHrWaring(isOpen: isOpen, maxHr: maxHr, minHr: minHr) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetHrWaring -> success")
                    }
                }
            }
            
            break
            
        case NSLocalizedString("Synchronizing contacts", comment: "同步联系人"):
            
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
                let model_0 = ZyAddressBookModel.init()
                model_0.name = textArray[0].count == 0 ? "张三" : textArray[0]
                model_0.phoneNumber = textArray[1].count == 0 ? "13755660033" : textArray[1]

                let model_1 = ZyAddressBookModel.init()
                model_1.name = textArray[2].count == 0 ? "李四" : textArray[2]
                model_1.phoneNumber = textArray[3].count == 0 ? "0755-6128998" : textArray[3]
                
                let model_2 = ZyAddressBookModel.init()
                model_2.name = textArray[4]
                model_2.phoneNumber = textArray[5]
                
                self.logView.writeString(string: "\(NSLocalizedString("Contact Person", comment: "联系人"))0 \(NSLocalizedString("Name", comment: "姓名")):\(model_0.name),\(NSLocalizedString("Number", comment: "号码")):\(model_0.phoneNumber)")
                self.logView.writeString(string: "\(NSLocalizedString("Contact Person", comment: "联系人"))1 \(NSLocalizedString("Name", comment: "姓名")):\(model_1.name),\(NSLocalizedString("Number", comment: "号码")):\(model_1.phoneNumber)")
                self.logView.writeString(string: "\(NSLocalizedString("Contact Person", comment: "联系人"))2 \(NSLocalizedString("Name", comment: "姓名")):\(model_2.name),\(NSLocalizedString("Number", comment: "号码")):\(model_2.phoneNumber)")
                
                ZyCommandModule.shareInstance.setAddressBook(modelArray: [model_0,model_1,model_2]) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        print("SetAddressBook -> success")
                    }
                }
                
            }
            
            break
            
        case NSLocalizedString("Synchronize N contacts", comment: "同步N个联系人"):
            
            let array = [
                NSLocalizedString("Number of synchronizations (default 10)", comment: "同步个数(默认10个)"),
                "\(NSLocalizedString("Name", comment: "姓名"))(默认张三,+\"-序号\")",
                "\(NSLocalizedString("Number", comment: "号码"))(默认13755660000,+序号)",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Synchronize N contacts", comment: "同步N个联系人"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Hint (Invalid data is null by default)", comment: "提示(无效数据默认为空)"), message: NSLocalizedString("Set up contacts", comment: "设置联系人"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                var peopleCount = 10
                if let string = textArray[0] as? String{
                    peopleCount = Int(string) ?? 10
                }
                var modelArray = Array<ZyAddressBookModel>.init()
                for i in 0..<peopleCount {
                    let model = ZyAddressBookModel.init()
                    model.name = (textArray[1].count == 0 ? "张三" : textArray[1])+"-\(i)"
                    model.phoneNumber = String.init(format: "%ld", (Int64(textArray[2].count == 0 ? "13755660000" : textArray[2]) ?? 13755660000)+Int64(i))
                    modelArray.append(model)
                    self.logView.writeString(string: "\(NSLocalizedString("Contact Person", comment: "联系人"))\(i) \(NSLocalizedString("Name", comment: "姓名")):\(model.name),\(NSLocalizedString("Number", comment: "号码")):\(model.phoneNumber)")
                }
                
                ZyCommandModule.shareInstance.setAddressBook(modelArray: modelArray) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        print("SetAddressBook -> success")
                    }
                }
                
            }
            
            break
            
        case "\(NSLocalizedString("Get the cycle", comment: "获取生理周期"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get the cycle", comment: "获取生理周期"))
            
            ZyCommandModule.shareInstance.getMenstrualCycle { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if let model = success {
                        
                        let isOpen = model.isOpen
                        let cycleCount = model.cycleCount
                        let menstrualCount = model.menstrualCount
                        let year = model.year
                        let month = model.month
                        let day = model.day
                        let advanceDay = model.advanceDay
                        let remindHour = model.remindHour
                        let remindMinute = model.remindMinute
                        
                        self.logView.writeString(string: isOpen ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                        self.logView.writeString(string: "\(NSLocalizedString("Number of cycle days", comment: "周期天数")): \(cycleCount)")
                        self.logView.writeString(string: "\(NSLocalizedString("Number of menstrual days", comment: "经期天数")): \(menstrualCount)")
                        self.logView.writeString(string: String.init(format: "\(NSLocalizedString("Date of commencement of last menstrual period", comment: "上一次月经开始日期")): %04d-%02d-%02d", year,month,day))
                        self.logView.writeString(string: "\(NSLocalizedString("Remind days in advance", comment: "提前提醒天数")): \(advanceDay)")
                        self.logView.writeString(string: String.init(format: "\(NSLocalizedString("Time to remind", comment: "提醒时间")): %02d:%02d", remindHour,remindMinute))
                    }
                }
            }
            
            break

        case "\(NSLocalizedString("Set your cycle", comment: "设置生理周期"))":
            
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
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set your cycle", comment: "设置生理周期"), holderStringArray: array, cancel: nil, cancelAction: {
                
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
                
                let model = ZyMenstrualModel.init()
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
                
                ZyCommandModule.shareInstance.setMenstrualCycle(model: model) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        
                    }
                }
            }
            
            
            break
            
        case "\(NSLocalizedString("Get Hand-washing reminders", comment: "获取洗手提醒"))":
            
            ZyCommandModule.shareInstance.getWashHand { success, error in
                print("GetWashHand ->",success)
            }
            
            break
            
        case "\(NSLocalizedString("Set reminders for hand washing", comment: "设置洗手提醒"))":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))",
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟"),
                NSLocalizedString("Number of targets", comment: "目标次数"),
                NSLocalizedString("Length of interval", comment: "间隔时长")
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set reminders for hand washing", comment: "设置洗手提醒"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let startHour = textArray[1]
                let startMinute = textArray[2]
                let targetCount = textArray[3]
                let remindInterval = textArray[4]
                
                ZyCommandModule.shareInstance.setWashHand(isOpen: isOpen, startHour: startHour, startMinute: startMinute, targetCount: targetCount, remindInterval: remindInterval) { success in
                    print("SetWashHand ->",success)
                }
            }
            
            break
            
        case "\(NSLocalizedString("Get water reminders", comment: "获取喝水提醒"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get water reminders", comment: "获取喝水提醒"))

            ZyCommandModule.shareInstance.getDrinkWater { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if let model = success {
                        let isOpen = model.isOpen
                        let startHour = model.timeModel.startHour
                        let startMinute = model.timeModel.startMinute
                        let endHour = model.timeModel.endHour
                        let endMinute = model.timeModel.endMinute
                        let remindInterval = model.remindInterval
                        
                        self.logView.writeString(string: isOpen ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                        self.logView.writeString(string: "\(NSLocalizedString("Time to start", comment: "开始时间")): \(startHour):\(startMinute)")
                        self.logView.writeString(string: "\(NSLocalizedString("End of period", comment: "结束时间")): \(endHour):\(endMinute)")
                        self.logView.writeString(string: "\(NSLocalizedString("Length of interval", comment: "间隔时长")): \(remindInterval)")
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Set a water reminder", comment: "设置喝水提醒"))":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))",
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟"),
                NSLocalizedString("Closing hours", comment: "结束小时"),
                NSLocalizedString("End of the minute", comment: "结束分钟"),
                NSLocalizedString("Length of interval", comment: "间隔时长")
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set a water reminder", comment: "设置喝水提醒"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let startHour = textArray[1]
                let startMinute = textArray[2]
                let endHour = textArray[3]
                let endMinute = textArray[4]
                let remindInterval = textArray[5]
                
//                let model = ZyDrinkWaterModel.init()
//                model.isOpen = isOpen
//                model.remindInterval = remindInterval
//                model.timeModel.startHour = startHour
//                model.timeModel.startMinute = startMinute
//                model.timeModel.endHour = endHour
//                model.timeModel.endMinute = endMinute
//
//                ZyCommandModule.shareInstance.setDrinkWater(model: model) { error in
                ZyCommandModule.shareInstance.setDrinkWater(isOpen: isOpen, startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute, remindInterval: remindInterval) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetDrinkWater -> success")
                    }
                }
                
            }
            
            break
            
        case "\(NSLocalizedString("Get low power alerts", comment: "获取低电提醒"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get low power alerts", comment: "获取低电提醒"))
            
            ZyCommandModule.shareInstance.getLowBatteryRemind { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if let model = success {
                        let isOpen = model.isOpen
                        let remindBattery = model.remindBattery
                        let remindCount = model.remindCount
                        let remindInterval = model.remindInterval
                        
                        self.logView.writeString(string: isOpen ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                        self.logView.writeString(string: "\(NSLocalizedString("Reminder of power", comment: "提醒电量")):\(remindBattery)")
                        self.logView.writeString(string: "\(NSLocalizedString("Number of reminders", comment: "提醒次数")):\(remindCount)")
                        self.logView.writeString(string: "\(NSLocalizedString("Length of interval", comment: "间隔时长")):\(remindInterval)")
                    }
                }
                
            }
            
            break

        case "\(NSLocalizedString("Set a low power reminder", comment: "设置低电提醒"))":
            
            let array = [
                "0:\(NSLocalizedString("Shut down", comment: "关闭"))，1:\(NSLocalizedString("Turn on", comment: "开启"))",
                NSLocalizedString("Reminder of power", comment: "提醒电量"),
                NSLocalizedString("Number of reminders", comment: "提醒次数"),
                NSLocalizedString("Length of interval", comment: "间隔时长"),
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set reminders for hand washing", comment: "设置洗手提醒"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let remindBattery = textArray[1]
                let remindCount = textArray[2]
                let remindInterval = textArray[3]
                
//                let model = ZyLowBatteryModel.init()
//                model.isOpen = isOpen
//                model.remindBattery = remindBattery
//                model.remindCount = remindCount
//                model.remindInterval = remindInterval
//
//                ZyCommandModule.shareInstance.setLowBatteryRemind(model: model) { error in
                ZyCommandModule.shareInstance.setLowBatteryRemind(isOpen: isOpen, remindBattery: remindBattery, remindCount: remindCount, remindInterval: remindInterval) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setLowBatteryRemind -> success")
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Get a single LED lamp function", comment: "获取单个LED灯功能"))":
            
            let array = [
                "0:\(NSLocalizedString("Amount of electricity", comment: "电量")) 1:\(NSLocalizedString("Information", comment: "信息")) 2:\(NSLocalizedString("bt connection", comment: "bt连接")) 3:\(NSLocalizedString("Count steps to reach the standard", comment: "计步达标"))",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get a single LED lamp function", comment: "获取单个LED灯功能"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Get a single LED lamp function", comment: "获取单个LED灯功能"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = Int(textArray[0]) ?? 0
                                
                ZyCommandModule.shareInstance.getLedSetup(type: ZyLedFunctionType.init(rawValue: type) ?? .powerIndicator) { model, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        
                        if let model = model {
                            self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")): \(model.ledType.rawValue)")
                            self.logView.writeString(string: "\(NSLocalizedString("Color", comment: "颜色")): \(model.ledColor)")
                            self.logView.writeString(string: "97-100\(NSLocalizedString("Color", comment: "颜色")): \(model.firstColor)")
                            self.logView.writeString(string: "21-74\(NSLocalizedString("Color", comment: "颜色")): \(model.secondColor)")
                            self.logView.writeString(string: "0-20\(NSLocalizedString("Color", comment: "颜色")): \(model.thirdColor)")
                            self.logView.writeString(string: "\(NSLocalizedString("Duration of duration", comment: "持续时长")): \(model.timeLength)")
                            self.logView.writeString(string: "\(NSLocalizedString("Frequency of flicker", comment: "闪烁频次")): \(model.frequency)\n\n")
                        }
                    }
                }
            }

            break
        case "\(NSLocalizedString("Set up a single LED light function", comment: "设置单个LED灯功能"))":
            
            let array = [
                "\(NSLocalizedString("Type", comment: "类型")) 1:\(NSLocalizedString("Information", comment: "信息")) 2:\(NSLocalizedString("bt connection", comment: "bt连接")) 3:\(NSLocalizedString("Count steps to reach the standard", comment: "计步达标")) 4:低电",
                "\(NSLocalizedString("Color", comment: "颜色"))(0-15,bit0:\(NSLocalizedString("red", comment: "红")) bit1:\(NSLocalizedString("green", comment: "绿")) bit2:\(NSLocalizedString("blue", comment: "蓝")) bit3:\(NSLocalizedString("white", comment: "白")))",
                "\(NSLocalizedString("Duration of duration", comment: "持续时长")) 1-20",
                "\(NSLocalizedString("Frequency of flicker", comment: "闪烁频次")) 0-5，0常亮",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("LED lamp function setting", comment: "LED灯功能设置"))
            self.presentTextFieldAlertVC(title: "提示(默认类型1其他0)", message: NSLocalizedString("LED lamp function setting", comment: "LED灯功能设置"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let modelCount = Int(textArray[0]) ?? 1
                let colorType = Int(textArray[1]) ?? 0
                let timeLength = Int(textArray[2]) ?? 0
                let frequency = Int(textArray[3]) ?? 0
                
                let model = ZyLedFunctionModel()
                model.ledType = ZyLedFunctionType.init(rawValue: modelCount) ?? .informationReminder
                model.timeLength = timeLength
                model.frequency = frequency
                model.ledColor = colorType
                self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")): \(model.ledType.rawValue)")
                self.logView.writeString(string: "\(NSLocalizedString("Color", comment: "颜色")): \(model.ledColor)")
                self.logView.writeString(string: "\(NSLocalizedString("Duration of duration", comment: "持续时长")): \(model.timeLength)")
                self.logView.writeString(string: "\(NSLocalizedString("Frequency of flicker", comment: "闪烁频次")): \(model.frequency)\n\n")
                
                ZyCommandModule.shareInstance.setLedSetup(model: model, success: { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setLedSetup ->","success")
                    }
                })
            }
            
            break

        case "\(NSLocalizedString("Set individual LED light power display", comment: "设置单个LED灯电量显示"))":
            
            let array = [
                "75-100\(NSLocalizedString("Color", comment: "颜色"))(0-15,bit0:\(NSLocalizedString("red", comment: "红")) bit1:\(NSLocalizedString("green", comment: "绿")) bit2:\(NSLocalizedString("blue", comment: "蓝")) bit3:\(NSLocalizedString("white", comment: "白"))",
                "21-74\(NSLocalizedString("Color", comment: "颜色"))(0-15,bit0:\(NSLocalizedString("red", comment: "红")) bit1:\(NSLocalizedString("green", comment: "绿")) bit2:\(NSLocalizedString("blue", comment: "蓝")) bit3:\(NSLocalizedString("white", comment: "白"))",
                "0-20\(NSLocalizedString("Color", comment: "颜色"))(0-15,bit0:\(NSLocalizedString("red", comment: "红")) bit1:\(NSLocalizedString("green", comment: "绿")) bit2:\(NSLocalizedString("blue", comment: "蓝")) bit3:\(NSLocalizedString("white", comment: "白"))",
                "\(NSLocalizedString("Duration of duration", comment: "持续时长")) 1-20",
                "\(NSLocalizedString("Frequency of flicker", comment: "闪烁频次")) 0-5，0常亮",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("LED lamp function setting", comment: "LED灯功能设置"))
            self.presentTextFieldAlertVC(title: "提示(默认类型1其他0)", message: NSLocalizedString("LED lamp function setting", comment: "LED灯功能设置"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let firstColor = Int(textArray[0]) ?? 1
                let secondColor = Int(textArray[1]) ?? 0
                let thirdColor = Int(textArray[2]) ?? 0
                let timeLength = Int(textArray[3]) ?? 0
                let frequency = Int(textArray[4]) ?? 0
                
                let model = ZyLedFunctionModel()
                model.ledType = .powerIndicator
                model.timeLength = timeLength
                model.frequency = frequency
                model.firstColor = firstColor
                model.secondColor = secondColor
                model.thirdColor = thirdColor

                self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")): \(model.ledType.rawValue)")
                self.logView.writeString(string: "75-100\(NSLocalizedString("Color", comment: "颜色")): \(model.firstColor)")
                self.logView.writeString(string: "21-74\(NSLocalizedString("Color", comment: "颜色")): \(model.secondColor)")
                self.logView.writeString(string: "0-20\(NSLocalizedString("Color", comment: "颜色")): \(model.thirdColor)")
                self.logView.writeString(string: "\(NSLocalizedString("Duration of duration", comment: "持续时长")): \(model.timeLength)")
                self.logView.writeString(string: "\(NSLocalizedString("Frequency of flicker", comment: "闪烁频次")): \(model.frequency)\n\n")
                
                ZyCommandModule.shareInstance.setLedSetup(model: model, success: { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setLedSetup ->","success")
                    }
                })
            }
            
            break

        case "\(NSLocalizedString("Get motor vibration function", comment: "获取马达震动功能"))":
            
            let array = [
                "0:\(NSLocalizedString("Amount of electricity", comment: "电量")) 1:\(NSLocalizedString("Information", comment: "信息")) 2:\(NSLocalizedString("bt connection", comment: "bt连接")) 3:\(NSLocalizedString("Count steps to reach the standard", comment: "计步达标"))",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get motor vibration function", comment: "获取马达震动功能"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Get motor vibration function", comment: "获取马达震动功能"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = Int(textArray[0]) ?? 0
                                
                ZyCommandModule.shareInstance.getMotorShakeFunction(type: ZyLedFunctionType.init(rawValue: type) ?? .powerIndicator) { model, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        if let model = model {
                            self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")): \(model.ledType.rawValue)")
                            self.logView.writeString(string: "\(NSLocalizedString("Duration of vibration", comment: "震动时长")): \(model.timeLength)")
                            self.logView.writeString(string: "\(NSLocalizedString("Frequency of vibration", comment: "震动频次")): \(model.frequency)")
                            self.logView.writeString(string: "\(NSLocalizedString("Intensity of vibration", comment: "震动强度")): \(model.level)\n\n")
                        }
                    }
                }
            }
            
            break

        case "\(NSLocalizedString("Set motor vibration function", comment: "设置马达震动功能"))":
            
            let array = [
                "\(NSLocalizedString("Type", comment: "类型")) 1:\(NSLocalizedString("Information", comment: "信息")) 2:\(NSLocalizedString("bt connection", comment: "bt连接")) 3:\(NSLocalizedString("Count steps to reach the standard", comment: "计步达标"))",
                "\(NSLocalizedString("Duration of vibration", comment: "震动时长")) 10-50",
                "\(NSLocalizedString("Frequency of vibration", comment: "震动频次")) 0-5 ,0长震",
                "\(NSLocalizedString("Intensity of vibration", comment: "震动强度")) 1-10",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set motor vibration function", comment: "设置马达震动功能"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set motor vibration function", comment: "设置马达震动功能"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in

                let ledType = Int(textArray[0]) ?? 0
                let timeLength = Int(textArray[1]) ?? 0
                let frequency = Int(textArray[2]) ?? 0
                let level = Int(textArray[3]) ?? 0
                
                let model = ZyMotorFunctionModel()
                model.ledType = ZyLedFunctionType.init(rawValue: ledType) ?? .powerIndicator
                model.timeLength = timeLength
                model.frequency = frequency
                model.level = level
                self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")): \(model.ledType.rawValue)")
                self.logView.writeString(string: "\(NSLocalizedString("Duration of vibration", comment: "震动时长")): \(model.timeLength)")
                self.logView.writeString(string: "\(NSLocalizedString("Frequency of vibration", comment: "震动频次")): \(model.frequency)")
                self.logView.writeString(string: "\(NSLocalizedString("Intensity of vibration", comment: "震动强度")): \(model.level)\n\n")
                
                ZyCommandModule.shareInstance.setMotorShakeFunction(model: model) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setMotorShakeFunction ->","success")
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Get a custom LED", comment: "获取自定义LED"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get a custom LED", comment: "获取自定义LED"))
            
            ZyCommandModule.shareInstance.getLedCustomSetup { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        self.logView.writeString(string: "\(NSLocalizedString("Color", comment: "颜色")): \(model.ledColor)")
                        self.logView.writeString(string: "\(NSLocalizedString("Duration of duration", comment: "持续时长")): \(model.timeLength)")
                        self.logView.writeString(string: "\(NSLocalizedString("Frequency of flicker", comment: "闪烁频次")): \(model.frequency)")
                        self.logView.writeString(string: "model.ledOpenCount: \(model.ledOpenCount)\n\n")
                    }
                }
            }
            
            break
        case "\(NSLocalizedString("Set up a custom LED", comment: "设置自定义LED"))":
            
            let array = [
                "\(NSLocalizedString("Color", comment: "颜色"))(0-15,bit0:\(NSLocalizedString("red", comment: "红")) bit1:\(NSLocalizedString("green", comment: "绿")) bit2:\(NSLocalizedString("blue", comment: "蓝")) bit3:\(NSLocalizedString("white", comment: "白")))",
                "\(NSLocalizedString("Duration of duration", comment: "持续时长")) 1-20",
                "\(NSLocalizedString("Frequency of flicker", comment: "闪烁频次")) 0-5，0常亮",
                "ledOpenCount"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set up a custom LED", comment: "设置自定义LED"))
            self.presentTextFieldAlertVC(title: "提示(默认类型1其他0)", message: NSLocalizedString("Set up a custom LED", comment: "设置自定义LED"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let colorType = Int(textArray[0]) ?? 0
                let timeLength = Int(textArray[1]) ?? 0
                let frequency = Int(textArray[2]) ?? 0
                let ledOpenCount = Int(textArray[3]) ?? 0
                
                let model = ZyLedFunctionModel()
                model.ledType = .customSetup
                model.timeLength = timeLength
                model.frequency = frequency
                model.ledColor = colorType
                model.ledOpenCount = ledOpenCount
                self.logView.writeString(string: "\(NSLocalizedString("Color", comment: "颜色")): \(model.ledColor)")
                self.logView.writeString(string: "\(NSLocalizedString("Duration of duration", comment: "持续时长")): \(model.timeLength)")
                self.logView.writeString(string: "\(NSLocalizedString("Frequency of flicker", comment: "闪烁频次")): \(model.frequency)")
                self.logView.writeString(string: "model.ledOpenCount: \(model.ledOpenCount)\n\n")
                ZyCommandModule.shareInstance.setLedCustomSetup(model: model) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setLedSetup ->","success")
                    }
                }
            }
            
            break
        case "\(NSLocalizedString("Get custom vibrations", comment: "获取自定义震动"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get custom vibrations", comment: "获取自定义震动"))
            
            ZyCommandModule.shareInstance.getMotorShakeCustom { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        self.logView.writeString(string: "\(NSLocalizedString("Duration of vibration", comment: "震动时长")): \(model.timeLength)")
                        self.logView.writeString(string: "\(NSLocalizedString("Frequency of vibration", comment: "震动频次")): \(model.frequency)")
                        self.logView.writeString(string: "\(NSLocalizedString("Intensity of vibration", comment: "震动强度")): \(model.level)\n\n")
                    }
                }
            }
            
            break
        case "\(NSLocalizedString("Set up custom vibration", comment: "设置自定义震动"))":
            
            let array = [
                "\(NSLocalizedString("Duration of vibration", comment: "震动时长")) 10-50",
                "\(NSLocalizedString("Frequency of vibration", comment: "震动频次")) 0-5 ,0长震",
                "\(NSLocalizedString("Intensity of vibration", comment: "震动强度")) 1-10",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set up custom vibration", comment: "设置自定义震动"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set up custom vibration", comment: "设置自定义震动"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in

                let timeLength = Int(textArray[0]) ?? 0
                let frequency = Int(textArray[1]) ?? 0
                let level = Int(textArray[2]) ?? 0
                
                let model = ZyMotorFunctionModel()
                model.ledType = .customSetup
                model.timeLength = timeLength
                model.frequency = frequency
                model.level = level
                self.logView.writeString(string: "\(NSLocalizedString("Duration of vibration", comment: "震动时长")): \(model.timeLength)")
                self.logView.writeString(string: "\(NSLocalizedString("Frequency of vibration", comment: "震动频次")): \(model.frequency)")
                self.logView.writeString(string: "\(NSLocalizedString("Intensity of vibration", comment: "震动强度")): \(model.level)\n\n")
                
                ZyCommandModule.shareInstance.setMotorShakeCustom(model: model) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setMotorShakeFunction ->","success")
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Synchronize step data", comment: "同步计步数据"))":
            let array = [
                NSLocalizedString("Type of synchronization", comment: "同步类型"),
                NSLocalizedString("Number of synchronized days", comment: "同步天数"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Synchronize step data", comment: "同步计步数据"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Synchronize step data", comment: "同步计步数据"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let dayCount = textArray[1]
                
                ZyCommandModule.shareInstance.setSyncHealthData(type: type, dayCount: dayCount) { success,error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        //print("SetSyncHealthData ->",success)
                        
                        if success is ZyStepModel {
                            if let model:ZyStepModel = success as? ZyStepModel {
                                let detailArray = model.detailArray
                                let step = model.step
                                let calorie = model.calorie
                                let distance = model.distance
                                
                                print("detailArray ->",detailArray)
                                
                                self.logView.writeString(string: "\(NSLocalizedString("Detailed steps", comment: "详情步数")):\(detailArray)")
                                self.logView.writeString(string: "\(NSLocalizedString("Total number of steps", comment: "总步数")):\(step)")
                                self.logView.writeString(string: "\(NSLocalizedString("Total calories", comment: "总卡路里")):\(calorie)")
                                self.logView.writeString(string: "\(NSLocalizedString("Total distance", comment: "总距离")):\(distance)")
                            }
                        }
                        
                        if success is ZySleepModel {
                            if let model:ZySleepModel = success as? ZySleepModel {
                                let deep = model.deep
                                let awake = model.awake
                                let light = model.light
                                let detailArray = model.detailArray
                                print("deep ->",deep,"awake ->",awake,"light ->",light,"detailArray ->",detailArray)
                                
                                self.logView.writeString(string: "\(NSLocalizedString("Deep sleep duration", comment: "深睡时长")):\(deep)")
                                self.logView.writeString(string: "\(NSLocalizedString("Light sleep duration", comment: "浅睡时长")):\(light)")
                                self.logView.writeString(string: "\(NSLocalizedString("Duration of wakefulness", comment: "清醒时长")):\(awake)")
                                self.logView.writeString(string: "\(NSLocalizedString("Details Sleep", comment: "详情睡眠")):\(detailArray)")
                            }
                        }
                        
                        if success is ZyHrModel {
                            if let model:ZyHrModel = success as? ZyHrModel {
                                let detailArray = model.detailArray
                                print("detailArray ->",detailArray)
                                
                                self.logView.writeString(string: "\(NSLocalizedString("Details Heart rate", comment: "详情心率")):\(detailArray)")
                            }
                        }
                        
                    }else{

                        var typeString = ""
                        if type == "1" {
                            typeString = NSLocalizedString("Number of steps", comment: "步数")
                        }else if type == "2" {
                            typeString = NSLocalizedString("Heart rate", comment: "心率")
                        }else if type == "3" {
                            typeString = NSLocalizedString("Sleep", comment: "睡眠")
                        }
                        self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")):\(typeString)")
                        self.logView.writeString(string: "第\(dayCount)天数据")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            
            break
            
        case "\(NSLocalizedString("Synchronizing exercise data", comment: "同步锻炼数据"))":
            
            let array = [
                //NSLocalizedString("Type of synchronization", comment: "同步类型"),
                NSLocalizedString("Synchronization serial number", comment: "同步序号"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Synchronizing exercise data", comment: "同步锻炼数据"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Synchronizing exercise data", comment: "同步锻炼数据"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                //let type = textArray[0]
                let indexCount = textArray[0]
                                
                ZyCommandModule.shareInstance.setSyncExerciseData(indexCount: Int(indexCount) ?? 0) { success, error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    print("SetSyncExerciseData ->",success)
                    
                    if let model = success {
                        let startTime = model.startTime
                        let type = model.type
                        let hr = model.heartrate
                        let validTimeLength = model.validTimeLength
                        let step = model.step
                        let endTime = model.endTime
                        let calorie = model.calorie
                        let distance = model.distance
                        
                        self.logView.writeString(string: "\(NSLocalizedString("Time to start", comment: "开始时间")):\(startTime)")
                        self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")):\(type.rawValue)")
                        self.logView.writeString(string: "\(NSLocalizedString("Heart rate", comment: "心率")):\(hr)")
                        self.logView.writeString(string: "\(NSLocalizedString("Duration of exercise", comment: "运动时长")):\(validTimeLength)")
                        self.logView.writeString(string: "\(NSLocalizedString("Number of steps", comment: "步数")):\(step)")
                        self.logView.writeString(string: "\(NSLocalizedString("End of period", comment: "结束时间")):\(endTime)")
                        self.logView.writeString(string: "\(NSLocalizedString("Calories", comment: "卡路里")):\(calorie)")
                        self.logView.writeString(string: "\(NSLocalizedString("Distance", comment: "距离")):\(distance)")
                    }

                }
                
            }
            
            break
            
        case NSLocalizedString("Synchronized measurement data", comment: "同步测量数据"):
            
            let array = [
                "1：\(NSLocalizedString("Heart rate", comment: "心率"))，2：\(NSLocalizedString("Blood oxygen", comment: "血氧"))，3：\(NSLocalizedString("Blood pressure", comment: "血压"))，4：\(NSLocalizedString("Blood sugar", comment: "血糖"))，5：\(NSLocalizedString("Pressure", comment: "压力"))，6.\(NSLocalizedString("Body temperature", comment: "体温"))，7：\(NSLocalizedString("electrocardiogram", comment: "心电"))",
                "1：\(NSLocalizedString("Full day measurement", comment: "全天测量")) ，2：\(NSLocalizedString("Click and measure", comment: "点击测量"))",
                NSLocalizedString("The input is not spaced within 10 days of x day (article)", comment: "第x天(条) 10以内输入不间隔"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Synchronizing data", comment: "同步数据"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Synchronizing data", comment: "同步数据"), holderStringArray: array) {
                
            } okAction: { textArray in
                let dataType = textArray[0]
                let measureType = textArray[1]
                let dayCount = textArray[2]
                
                let dayNumber:String = dayCount.components(separatedBy: .decimalDigits.inverted).joined()
                var dayArray = [Int]()
                for i in dayNumber {
                    dayArray.append(Int(String(i)) ?? 0)
                }
                
                ZyCommandModule.shareInstance.setSyncMeasurementData(dataType: Int(dataType) ?? 1, measureType: Int(measureType) ?? 1, indexArray: dayArray) { success,error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        
                        if let model:ZyMeasurementModel = success as? ZyMeasurementModel {
                            let type = model.type
                            let timeInterval = model.timeInterval
                            let listModelArray = model.listArray
                            
                            print("listModelArray ->",listModelArray)
                            self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")):\(type.rawValue)")
                            self.logView.writeString(string: "\(NSLocalizedString("Length of interval", comment: "间隔时长")):\(timeInterval)")
                            for item in listModelArray {
                                let item:ZyMeasurementValueModel = item
                                self.logView.writeString(string: "time:\(item.time) value1:\(item.value_1),value2:\(item.value_2)\n")
                            }
                        }
                        
                    }
                }
            }
            break
            
        case "New \(NSLocalizedString("Synchronizing data", comment: "同步数据"))":
            
            let array = [
                "1:\(NSLocalizedString("Number of steps", comment: "步数")) 2:\(NSLocalizedString("Heart rate", comment: "心率")) 3:\(NSLocalizedString("Sleep", comment: "睡眠")) 4:\(NSLocalizedString("Exercise", comment: "锻炼"))",
                NSLocalizedString("The input is not spaced within 10 days of x day (article)", comment: "第x天(条) 10以内输入不间隔"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Synchronizing data", comment: "同步数据"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Synchronizing data", comment: "同步数据"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let dayCount = textArray[1]
                
                let dayNumber:String = dayCount.components(separatedBy: .decimalDigits.inverted).joined()
                var dayArray = [Int]()
                for i in dayNumber {
                    dayArray.append(Int(String(i)) ?? 0)
                }
                print("dayArray = \(dayArray)")
                
                ZyCommandModule.shareInstance.setNewSyncHealthData(type: Int(type) ?? 1, indexArray: dayArray) { success,error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        //print("SetSyncHealthData ->",success)
                        
                        if let successDic:[String:Any?] = success as? [String : Any?] {
                            
                            for key in successDic.keys {
                                
                                if let value = successDic[key] {
                                    
                                    if value is ZyStepModel {
                                        if let model:ZyStepModel = value as? ZyStepModel {
                                            let detailArray = model.detailArray
                                            let step = model.step
                                            let calorie = model.calorie
                                            let distance = model.distance
                                            
                                            print("detailArray ->",detailArray)
                                            self.logView.writeString(string: "第\(key)天")
                                            self.logView.writeString(string: "\(NSLocalizedString("Detailed steps", comment: "详情步数")):\(detailArray)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Total number of steps", comment: "总步数")):\(step)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Total calories", comment: "总卡路里")):\(calorie)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Total distance", comment: "总距离")):\(distance)\n")
                                        }
                                    }
                                    
                                    if value is ZySleepModel {
                                        if let model:ZySleepModel = value as? ZySleepModel {
                                            let deep = model.deep
                                            let awake = model.awake
                                            let light = model.light
                                            let detailArray = model.detailArray
                                            print("deep ->",deep,"awake ->",awake,"light ->",light,"detailArray ->",detailArray)
                                            self.logView.writeString(string: "第\(key)天")
                                            self.logView.writeString(string: "\(NSLocalizedString("Deep sleep duration", comment: "深睡时长")):\(deep)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Light sleep duration", comment: "浅睡时长")):\(light)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Duration of wakefulness", comment: "清醒时长")):\(awake)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Details Sleep", comment: "详情睡眠")):\(detailArray)\n")
                                        }
                                    }
                                    
                                    if value is ZyHrModel {
                                        if let model:ZyHrModel = value as? ZyHrModel {
                                            let detailArray = model.detailArray
                                            print("detailArray ->",detailArray)
                                            self.logView.writeString(string: "第\(key)天")
                                            self.logView.writeString(string: "\(NSLocalizedString("Details Heart rate", comment: "详情心率")):\(detailArray)\n")
                                        }
                                    }
                                    
                                    if value is ZyExerciseModel {
                                        if let model:ZyExerciseModel = value as? ZyExerciseModel {
                                            let startTime = model.startTime
                                            let type = model.type
                                            let hr = model.heartrate
                                            let validTimeLength = model.validTimeLength
                                            let step = model.step
                                            let endTime = model.endTime
                                            let calorie = model.calorie
                                            let distance = model.distance
                                            self.logView.writeString(string: "第\(key)条")
                                            self.logView.writeString(string: "\(NSLocalizedString("Time to start", comment: "开始时间")):\(startTime)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")):\(type.rawValue)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Heart rate", comment: "心率")):\(hr)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Duration of exercise", comment: "运动时长")):\(validTimeLength)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Number of steps", comment: "步数")):\(step)")
                                            self.logView.writeString(string: "\(NSLocalizedString("End of period", comment: "结束时间")):\(endTime)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Calories", comment: "卡路里")):\(calorie)")
                                            self.logView.writeString(string: "\(NSLocalizedString("Distance", comment: "距离")):\(distance)\n")
                                            let gpsArray = model.gpsArray
                                            if gpsArray.count > 0 {
                                                var logArray = [String]()
                                                for locationArray in gpsArray {
                                                    for item in locationArray {
                                                        let formatter = DateFormatter.init()
                                                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                        logArray.append("时间:\(formatter.string(from:item.timestamp)),latitude:\(item.coordinate.latitude),longitude:\(item.coordinate.longitude)")
                                                    }
                                                }
                                                self.logView.writeString(string: "\(NSLocalizedString("Distance", comment: "距离")):\(logArray)\n")
                                            }
                                        }
                                    }
                                    if value is NSNull {
                                        self.logView.writeString(string: "第\(key)天(条)数据为空")
                                    }
                                }else{
                                    self.logView.writeString(string: "第\(key)天(条)数据为空")
                                }
                            }
                        }
                    }
                }
            }
            
            break
            
        case "New \(NSLocalizedString("Set the weather", comment: "设置天气"))":
            
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
                NSLocalizedString("Minimum temperature tomorrow", comment: "明日最低温度"),
                NSLocalizedString("Maximum temperature tomorrow", comment: "明日最高温度"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set the weather", comment: "设置天气"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set the weather", comment: "设置天气"), holderStringArray: array, cancel: nil, cancelAction: {
                
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
                let tomorrowMinTemp = textArray[12]
                let tomorrowMaxTemp = textArray[13]
                
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
                
                var modelArray = [ZyWeatherModel]()
                
                for i in stride(from: 0, to: Int(dayCount) ?? 0, by: 1) {
                    self.logView.writeString(string: "第\(i)天")
                    self.logView.writeString(string: "\(NSLocalizedString("Type of weather", comment: "天气类型")):\(type)")
                    self.logView.writeString(string: "\(NSLocalizedString("temperature", comment: "温度")):\((Int(temp) ?? 0) + i)")
                    self.logView.writeString(string: "\(NSLocalizedString("Air quality", comment: "空气质量")):\(airQuality)")
                    self.logView.writeString(string: "\(NSLocalizedString("Minimum temperature", comment: "最低温度")):\((Int(minTemp) ?? 0) + i)")
                    self.logView.writeString(string: "\(NSLocalizedString("Maximum temperature", comment: "最高温度")):\((Int(maxTemp) ?? 0) + i)")
                    self.logView.writeString(string: "\(NSLocalizedString("Minimum temperature tomorrow", comment: "明日最低温度")):\((Int(tomorrowMinTemp) ?? 0) + i)")
                    self.logView.writeString(string: "\(NSLocalizedString("Maximum temperature tomorrow", comment: "明日最高温度")):\((Int(tomorrowMaxTemp) ?? 0) + i)")
                    self.logView.writeString(string: "\n")
                    
                    let model = ZyWeatherModel.init()
                    model.dayCount = i
                    model.type = ZyWeatherType(rawValue:Int(type) ?? 0) ?? .sunny
                    model.temp = (Int(temp) ?? 0) + i
                    model.airQuality = Int(airQuality) ?? 0
                    model.minTemp = (Int(minTemp) ?? 0) + i
                    model.maxTemp = (Int(maxTemp) ?? 0) + i
                    model.tomorrowMinTemp = (Int(tomorrowMinTemp) ?? 0) + i
                    model.tomorrowMaxTemp = (Int(tomorrowMaxTemp) ?? 0) + i
                    
                    modelArray.append(model)
                }
                
                ZyCommandModule.shareInstance.setNewWeather(modelArray: modelArray, updateTime: time) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetWeather ->","success")
                    }
                }
            }
            
            
            break
            
        case "New \(NSLocalizedString("Set an alarm", comment: "设置闹钟"))":
            
            let array = [
                NSLocalizedString("Number of alarm clocks", comment: "闹钟个数"),
                NSLocalizedString("Repeat the alarm clock", comment: "重复闹钟"),
                NSLocalizedString("Hour of commencement", comment: "开始小时"),
                NSLocalizedString("Start minutes", comment: "开始分钟")
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set an alarm", comment: "设置闹钟"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set an alarm", comment: "设置闹钟"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let totalCount = textArray[0]
                let repeatCount = textArray[1]
                let hour = textArray[2]
                let minute = textArray[3]
                
                var alarmArray = [ZyAlarmModel]()
                
                for i in stride(from: 0, to: Int(totalCount) ?? 0, by: 1) {
                    let dic = ["repeatCount": "\(repeatCount)", "hour": "\(hour)", "index": "\(i)", "minute": "\(minute)"]
                    let alarmModel = ZyAlarmModel.init(dic: dic)
                    
                    self.logView.writeString(string: "\(NSLocalizedString("Alarm clock serial number", comment: "闹钟序号")):\(i)")
                    self.logView.writeString(string: "\(NSLocalizedString("Alarm clock time", comment: "闹钟时间")):\(String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute))")
                    self.logView.writeString(string: "repeatCount:\(repeatCount)")
                    self.logView.writeString(string: "\(NSLocalizedString("Alarm clock switch", comment: "闹钟开关")):\(alarmModel.alarmOpen)")
                    if alarmModel.alarmOpen {
                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock repetition type", comment: "闹钟重复类型")):\(alarmModel.alarmType == .single ? NSLocalizedString("Single time alarm clock", comment: "单次闹钟"):NSLocalizedString("Repeat the alarm clock", comment: "重复闹钟"))")
                        if alarmModel.alarmType == .cycle {
                            if alarmModel.alarmRepeatArray != nil {
                                let str = ((alarmModel.alarmRepeatArray![0] != 0 ? NSLocalizedString("Sunday", comment: "星期天"):"")+(alarmModel.alarmRepeatArray![1] != 0 ? NSLocalizedString("Monday", comment: "星期一"):"")+(alarmModel.alarmRepeatArray![2] != 0 ? NSLocalizedString("Tuesday", comment: "星期二"):"")+(alarmModel.alarmRepeatArray![3] != 0 ? NSLocalizedString("Wednesday", comment: "星期三"):"")+(alarmModel.alarmRepeatArray![4] != 0 ? NSLocalizedString("Thursday", comment: "星期四"):"")+(alarmModel.alarmRepeatArray![5] != 0 ? NSLocalizedString("Friday", comment: "星期五"):"")+(alarmModel.alarmRepeatArray![6] != 0 ? NSLocalizedString("Saturday", comment: "星期六"):""))
                                self.logView.writeString(string: "\(NSLocalizedString("The alarm clock repeats the week", comment: "闹钟重复星期")):\(str)")
                            }else{
                                self.logView.writeString(string: NSLocalizedString("Alarm repeat week: Repeat week is not turned on, default single alarm", comment: "闹钟重复星期:重复星期未开启,默认单次闹钟"))
                            }
                        }
                    }
                    self.logView.writeString(string: "\n")
                    alarmArray.append(alarmModel)
                    print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute),"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)
                }
                
                ZyCommandModule.shareInstance.setNewAlarmArray(modelArray: alarmArray) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetAlarm ->","success")
                    }
                }
                
            }
            
            break
            
        case "New \(NSLocalizedString("Get the alarm clock", comment: "获取闹钟"))":

            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get the alarm clock", comment: "获取闹钟"))
            
            ZyCommandModule.shareInstance.getNewAlarmArray { alarmArray, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetAlarm ->",alarmArray)
                    
                    for alarm in alarmArray {
                        let alarmModel = alarm
                        //print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",alarmModel.alarmTime,"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)

                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock serial number", comment: "闹钟序号")):\(alarmModel.alarmIndex)")
                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock time", comment: "闹钟时间")):\(alarmModel.alarmHour):\(alarmModel.alarmMinute)")
                        self.logView.writeString(string: "repeatCount:\(alarmModel.alarmRepeatCount)")
                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock switch", comment: "闹钟开关")):\(alarmModel.alarmOpen)")
                        if alarmModel.alarmOpen {
                            self.logView.writeString(string: "\(NSLocalizedString("Alarm clock repetition type", comment: "闹钟重复类型")):\(alarmModel.alarmType == .single ? NSLocalizedString("Single time alarm clock", comment: "单次闹钟"):NSLocalizedString("Repeat the alarm clock", comment: "重复闹钟"))")
                            if alarmModel.alarmType == .cycle {
                                if alarmModel.alarmRepeatArray != nil {
                                    let str = ((alarmModel.alarmRepeatArray![0] != 0 ? NSLocalizedString("Sunday", comment: "星期天"):"")+(alarmModel.alarmRepeatArray![1] != 0 ? NSLocalizedString("Monday", comment: "星期一"):"")+(alarmModel.alarmRepeatArray![2] != 0 ? NSLocalizedString("Tuesday", comment: "星期二"):"")+(alarmModel.alarmRepeatArray![3] != 0 ? NSLocalizedString("Wednesday", comment: "星期三"):"")+(alarmModel.alarmRepeatArray![4] != 0 ? NSLocalizedString("Thursday", comment: "星期四"):"")+(alarmModel.alarmRepeatArray![5] != 0 ? NSLocalizedString("Friday", comment: "星期五"):"")+(alarmModel.alarmRepeatArray![6] != 0 ? NSLocalizedString("Saturday", comment: "星期六"):""))
                                    self.logView.writeString(string: "\(NSLocalizedString("The alarm clock repeats the week", comment: "闹钟重复星期")):\(str)")
                                }else{
                                    self.logView.writeString(string: NSLocalizedString("Alarm repeat week: Repeat week is not turned on, default single alarm", comment: "闹钟重复星期:重复星期未开启,默认单次闹钟"))
                                }
                            }
                        }
                        self.logView.writeString(string: "\n")
                    }
                }
            }
            
            break
            
        case "New \(NSLocalizedString("Set a sleep goal", comment: "设置睡眠目标"))":
            
            let array = [
                NSLocalizedString("Sleep Goals (minutes)", comment: "睡眠目标(分钟)"),
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set a sleep goal", comment: "设置睡眠目标"))
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Set a sleep goal", comment: "设置睡眠目标"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let targetCount = Int(textArray[0]) ?? 0
                
                ZyCommandModule.shareInstance.setSleepGoal(target: targetCount) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setSleepGoal ->","success")
                    }
                }
            }
            
            break
            
        case "New \(NSLocalizedString("Get a sleep Goal", comment: "获取睡眠目标"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get a sleep Goal", comment: "获取睡眠目标"))
            
            ZyCommandModule.shareInstance.getSleepGoal { targetCount, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    
                    self.logView.writeString(string: "\(NSLocalizedString("Sleep Goals (minutes)", comment: "睡眠目标(分钟)")):\(targetCount)   \(targetCount/60):\(targetCount%60)")
                    
                }
            }
            
            break
            
        case "New \(NSLocalizedString("Set up SOS contacts", comment: "设置SOS联系人"))":

            let array = [
                NSLocalizedString("Name", comment: "姓名"),
                NSLocalizedString("Number", comment: "号码"),
            ]

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Set up SOS contacts", comment: "设置SOS联系人"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Hint (Invalid data is null by default)", comment: "提示(无效数据默认为空)"), message: NSLocalizedString("Set up contacts", comment: "设置联系人"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let model = ZyAddressBookModel.init()
                model.name = textArray[0]
                model.phoneNumber = textArray[1]
                
                self.logView.writeString(string: "\(NSLocalizedString("Contact Person", comment: "联系人")) \(NSLocalizedString("Name", comment: "姓名")):\(model.name),\(NSLocalizedString("Number", comment: "号码")):\(model.phoneNumber)")
                
                ZyCommandModule.shareInstance.setSosContactPerson(model: model) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        print("setSosContactPerson -> success")
                    }
                }
            }
            break
            
        case "New \(NSLocalizedString("Get SOS contacts", comment: "获取SOS联系人"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get SOS contacts", comment: "获取SOS联系人"))
            
            ZyCommandModule.shareInstance.getSosContactPerson { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if let model = model {
                    self.logView.writeString(string: "\(NSLocalizedString("Contact Person", comment: "联系人")) \(NSLocalizedString("Name", comment: "姓名")):\(model.name),\(NSLocalizedString("Number", comment: "号码")):\(model.phoneNumber)")
                    print("getSosContactPerson -> success")
                }
            }
            
            break
            
        case "New \(NSLocalizedString("Cycle measurement parameter setting", comment: "周期测量参数设置"))":
            
            let array = [
                "\(NSLocalizedString("Type", comment: "类型"))：1：\(NSLocalizedString("Heart rate", comment: "心率"))，2：\(NSLocalizedString("Blood oxygen", comment: "血氧"))，3：\(NSLocalizedString("Blood pressure", comment: "血压"))，4：\(NSLocalizedString("Blood sugar", comment: "血糖"))，5：\(NSLocalizedString("Pressure", comment: "压力"))，6.\(NSLocalizedString("Body temperature", comment: "体温"))，7：\(NSLocalizedString("electrocardiogram", comment: "心电"))，",
                "\(NSLocalizedString("On/off switch", comment: "开关"))：0：\(NSLocalizedString("Shut down", comment: "关闭")) 1：\(NSLocalizedString("Turn on", comment: "开启"))",
                "\(NSLocalizedString("Length of time", comment: "时长"))时长：>0"
            ]

            self.logView.clearString()
            self.logView.writeString(string: "设置周期测量参数")
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Hint (Invalid data is null by default)", comment: "提示(无效数据默认为空)"), message: "设置周期测量参数", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let type = textArray[0]
                let isOpen = textArray[1]
                let timeInterval = textArray[2]
                
                self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")):\(type),\(NSLocalizedString("On/off switch", comment: "开关")):\(isOpen),时长:\(timeInterval)")
                
                ZyCommandModule.shareInstance.setCycleMeasurementParameters(type: Int(type) ?? 0, isOpen: Int(isOpen) ?? 0, timeInterval: Int(timeInterval) ?? 0) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        print("setCycleMeasurementParameters -> success")
                    }
                }
            }
            
            break

        case "New \(NSLocalizedString("Get the number of days and start time of the pilgrimage alarm clock", comment: "获取朝拜闹钟天数及开始时间"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get the number of days and start time of the pilgrimage alarm clock", comment: "获取朝拜闹钟天数及开始时间"))
            
            ZyCommandModule.shareInstance.getWorshipStartTime { timeString, dayCount, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                self.logView.writeString(string: "\(NSLocalizedString("Pilgrimage alarm clock", comment: "朝拜闹钟")) dayCount:\(dayCount),date:\(timeString)")
                print("getWorshipStartTime -> timeString = \(timeString),dayCount = \(dayCount)")
            }
            
            break
            
        case "New \(NSLocalizedString("Set the time zone", comment: "设置时区"))":
            
            let array = [
                "0:\(NSLocalizedString("Zero time zone", comment: "零时区")) 1-12:\(NSLocalizedString("east area", comment: "东区")) 13-24:\(NSLocalizedString("west area", comment: "西区"))",
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认为手机系统时区)", message: NSLocalizedString("Set the time zone", comment: "设置时区"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let timeZone = textArray[0]
                self.logView.writeString(string: "\(NSLocalizedString("Set the time zone", comment: "设置时区")): \(timeZone)")
                            
                ZyCommandModule.shareInstance.setTimeZone(timeZone:  Int(timeZone) ?? 0) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        print("setTimeZone -> success")
                    }
                }
            }
            
            break
            
        case NSLocalizedString("No response response location information", comment: "无响应 回应定位信息"):
            
            let array = [
                "\(NSLocalizedString("Latitude of latitude", comment: "纬度")):xxx.xxxxxx",
                "\(NSLocalizedString("Degree of longitude", comment: "经度")):xxx.xxxxxx",
                "\(NSLocalizedString("Direction of travel", comment: "方向")):xxx",
                "\(NSLocalizedString("Speed of movement", comment: "速度")):xx.xx"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认为0)", message: "设置定位信息", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let latitude = Double(textArray[0]) ?? 0.0
                let longitude = Double(textArray[1]) ?? 0.0
                let course = Double(textArray[2]) ?? 0.0
                let speed = Double(textArray[3]) ?? 0.0
                
                self.logView.writeString(string: "\(NSLocalizedString("Latitude of latitude", comment: "纬度")): \(latitude)")
                self.logView.writeString(string: "\(NSLocalizedString("Degree of longitude", comment: "经度")): \(longitude)")
                self.logView.writeString(string: "\(NSLocalizedString("Direction of travel", comment: "方向")): \(course)")
                self.logView.writeString(string: "\(NSLocalizedString("Speed of movement", comment: "速度")): \(speed)")
                
                let location = CLLocation.init(coordinate: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude), altitude: 0, horizontalAccuracy: CLLocationAccuracy(), verticalAccuracy: CLLocationAccuracy(), course: course, speed: speed, timestamp: Date())

                ZyCommandModule.shareInstance.setLocationInfo(localtion: location)
                
            }
            
            break

        case "New \(NSLocalizedString("Gets a custom movement type", comment: "获取自定义运动类型"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Gets a custom movement type", comment: "获取自定义运动类型"))
            ZyCommandModule.shareInstance.getCustomSportsMode { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    self.logView.writeString(string: "\(NSLocalizedString("Customize the exercise type", comment: "自定义运动类型")):\(type)")
                }
            }
            
            break
            
        case "\(NSLocalizedString("Power off", comment: "关机"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Power off", comment: "关机"))
            
            ZyCommandModule.shareInstance.setPowerTurnOff { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetPowerTurnOff ->","success")
                }
                
            }
            
            break
            
        case "\(NSLocalizedString("factory data reset", comment: "恢复出厂设置"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("factory data reset", comment: "恢复出厂设置"))
            
            ZyCommandModule.shareInstance.setFactoryDataReset { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetFactoryDataReset ->","success")
                }
            }
            
            break
            
        case "马达震动":
            
            let array = [
                "0:\(NSLocalizedString("stop", comment: "停止"))，1:\(NSLocalizedString("A single vibration", comment: "单次震动"))，2:\(NSLocalizedString("Intermittent vibration three times", comment: "间歇震动三次"))，3:\(NSLocalizedString("Continuous vibration", comment: "连续震动"))"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Vibration of motor", comment: "马达震动"))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Vibration of motor", comment: "马达震动"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                var str = "未知状态"
                if type == "0" || type.count <= 0 {
                    str = NSLocalizedString("stop", comment: "停止")
                } else if type == "1" {
                    str = NSLocalizedString("A single vibration", comment: "单次震动")
                }else if type == "2" {
                    str = NSLocalizedString("Intermittent vibration three times", comment: "间歇震动三次")
                }else if type == "3" {
                    str = NSLocalizedString("Continuous vibration", comment: "连续震动")
                }
                self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")):\(str)")
                
                ZyCommandModule.shareInstance.setMotorVibration(type: type) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetMotorVibration ->","success")
                    }
                }
            }
            
            break
            
        case "\(NSLocalizedString("Start up again", comment: "重新启动"))":
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Start up again", comment: "重新启动"))
            
            ZyCommandModule.shareInstance.setRestart { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetFactoryDataReset ->","success")
                }
            }
            break
        case NSLocalizedString("Restore the factory and power down", comment: "恢复出厂并关机"):
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Restore the factory and power down", comment: "恢复出厂并关机"))
            
            ZyCommandModule.shareInstance.setFactoryAndPowerOff { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetFactoryDataReset ->","success")
                }
            }
            break


        case "\(NSLocalizedString("Real time step count", comment: "实时步数"))":
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportRealTimeStep { success, error in
                //self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if self.logView.isHidden {
                        return
                    }
                    
                    if let model = success {
                        let step = model.step
                        let distance = model.distance
                        let calorie = model.calorie
                        self.logView.writeString(string: "\(NSLocalizedString("Number of steps", comment: "步数")):\(step)")
                        self.logView.writeString(string: "\(NSLocalizedString("Distance", comment: "距离")):\(distance)")
                        self.logView.writeString(string: "\(NSLocalizedString("Calories", comment: "卡路里")):\(calorie)")
                    }
                    
                }
            }
            break
            
        case "\(NSLocalizedString("Real time heart rate", comment: "实时心率"))":
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
                        
            ZyCommandModule.shareInstance.reportRealTimeHr { success, error in
                //self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    let hr = success["hr"] as! String
                    self.logView.writeString(string: "\(NSLocalizedString("Heart rate", comment: "心率")):\(hr)")
                }
            }
            break

        case "\(NSLocalizedString("Results of a single measurement", comment: "单次测量结果"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
                        
            ZyCommandModule.shareInstance.reportSingleMeasurementResult { success, error in
                //self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    let type = success["type"] as! String
                    var str = NSLocalizedString("Type unknown", comment: "未知类型")
                    if type == "0" {
                        str = NSLocalizedString("Heart rate", comment: "心率")
                    }else if type == "1" {
                        str = NSLocalizedString("Blood pressure", comment: "血压")
                    }else if type == "2" {
                        str = NSLocalizedString("Blood oxygen", comment: "血氧")
                    }
                    let value1 = success["value1"] as! String
                    let value2 = success["value2"] as! String
                    self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")):\(str)")
                    self.logView.writeString(string: "value1:\(value1)")
                    self.logView.writeString(string: "value2:\(value2)")
                }
            }
            break

        case "\(NSLocalizedString("Status of exercise", comment: "锻炼状态"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportExerciseState { state ,error in

                if error == .none {
                    var stateString = ""
                    if state == .unknow {
                        stateString = "unknow"
                    }else if state == .end {
                        stateString = NSLocalizedString("End of", comment: "结束")
                    }else if state == .start {
                        stateString = NSLocalizedString("Start", comment: "开始")
                    }else if state == .pause {
                        stateString = NSLocalizedString("Pause", comment: "暂停")
                    }else if state == .continue {
                        stateString = NSLocalizedString("Go on", comment: "继续")
                    }
                    self.logView.writeString(string: "上报锻炼状态:\(stateString)")
                }
            }
            break

        case "\(NSLocalizedString("Find your phone", comment: "找手机"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportFindPhone { error in
                if error == .none {
                    self.logView.writeString(string: NSLocalizedString("Find your phone", comment: "找手机"))
                }
            }
            break

        case "\(NSLocalizedString("End the phone search", comment: "结束找手机"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportEndFindPhone { error in
                if error == .none {
                    self.logView.writeString(string: NSLocalizedString("End the phone search", comment: "结束找手机"))
                }
            }
            break

        case "\(NSLocalizedString("Take a photo", comment: "拍照"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportTakePictures { error in
                if error == .none {
                    self.logView.writeString(string: NSLocalizedString("Take a photo", comment: "拍照"))
                }
            }
            break

        case "\(NSLocalizedString("Control of music", comment: "音乐控制"))":

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportMusicControl { success, error in
                
                if error == .none {
                    let type = success
                    var str = NSLocalizedString("Type unknown", comment: "未知类型")
                    if type == 0 {
                        str = NSLocalizedString("Pause", comment: "暂停")
                    }else if type == 1 {
                        str = NSLocalizedString("Play on", comment: "播放")
                    }else if type == 2 {
                        str = NSLocalizedString("The last song", comment: "上一曲")
                    }else if type == 3 {
                        str = NSLocalizedString("The next song", comment: "下一曲")
                    }
                    self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")):\(str)")
                }
            }
            break
            
        case "\(NSLocalizedString("Incoming call control", comment: "来电控制"))":
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportCallControl { success, error in
                if error == .none {
                    let type = success
                    var str = NSLocalizedString("Type unknown", comment: "未知类型")
                    if type == 0 {
                        str = NSLocalizedString("Hang up", comment: "挂断")
                    }else if type == 1 {
                        str = NSLocalizedString("Answer the phone", comment: "接听")
                    }
                    self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")):\(str)")
                }
            }
            
            break
            
        case NSLocalizedString("Report screen brightness", comment: "上报屏幕亮度"):
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportScreenLevel { success, error in
                if error == .none {
                    let level = success
                    self.logView.writeString(string: "\(NSLocalizedString("Brightness of screen", comment: "屏幕亮度")):\(level)")
                }
            }
            
            break
            
        case NSLocalizedString("Report the screen duration", comment: "上报亮屏时长"):
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportScreenTimeLong { success, error in
                if error == .none {
                    let timeLong = success
                    self.logView.writeString(string: "\(NSLocalizedString("Screen duration", comment: "亮屏时长")):\(timeLong)")
                }
            }
            
            break
            
        case NSLocalizedString("Report wrist bright screen", comment: "上报抬腕亮屏"):
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportLightScreen { success, error in
                if error == .none {
                    let isOpen = success
                    self.logView.writeString(string: "\(NSLocalizedString("Lift wrist bright screen", comment: "抬腕亮屏")) \(NSLocalizedString("On/off switch", comment: "开关")):\(isOpen == 0 ? NSLocalizedString("Shut down", comment: "关闭"):NSLocalizedString("Turn on", comment: "开启"))")
                }
            }
            
            break
            
        case NSLocalizedString("Report equipment vibration", comment: "上报设备振动"):
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportDeviceVibration { success, error in
                if error == .none {
                    let isOpen = success
                    self.logView.writeString(string: "\(NSLocalizedString("Vibration of equipment", comment: "设备振动")) \(NSLocalizedString("On/off switch", comment: "开关")):\(isOpen == 0 ? NSLocalizedString("Shut down", comment: "关闭"):NSLocalizedString("Turn on", comment: "开启"))")
                }
            }
            break
            
        case NSLocalizedString("Report real-time data", comment: "上报实时数据"):
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Click display on the device side", comment: "设备端点击显示"))
            
            ZyCommandModule.shareInstance.reportNewRealtimeData { stepModel, hr, bo, sbp, dbp, error in
                if error == .none {
                    if let model:ZyStepModel = stepModel as? ZyStepModel {
                        let step = model.step
                        let calorie = model.calorie
                        let distance = model.distance
                        
                        self.logView.writeString(string: "\(NSLocalizedString("Total number of steps", comment: "总步数")):\(step)")
                        self.logView.writeString(string: "\(NSLocalizedString("Total calories", comment: "总卡路里")):\(calorie)")
                        self.logView.writeString(string: "\(NSLocalizedString("Total distance", comment: "总距离")):\(distance)")
                    }
                    self.logView.writeString(string: "\(NSLocalizedString("Heart rate", comment: "心率")):\(hr)")
                    self.logView.writeString(string: "\(NSLocalizedString("Blood oxygen", comment: "血氧")):\(bo)")
                    self.logView.writeString(string: "\(NSLocalizedString("Blood pressure", comment: "血压")):\(sbp)/\(dbp)")
                }
            }
            
            break
            
        case NSLocalizedString("Report movement interaction data", comment: "上报运动交互数据"):
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Report movement interaction data", comment: "上报运动交互数据"))
            
            ZyCommandModule.shareInstance.reportExerciseInteractionData { timestamp, step, hr, error in
                if error == .none {
                    self.logView.writeString(string: "时间戳:\(timestamp)")
                    self.logView.writeString(string: "\(NSLocalizedString("Total number of steps", comment: "总步数")):\(step)")
                    self.logView.writeString(string: "\(NSLocalizedString("Heart rate", comment: "心率")):\(hr)\n")
                }
            }
            
            break
            
        case NSLocalizedString("Report to enter or exit photo mode", comment: "上报进入或退出拍照模式"):
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Report to enter or exit photo mode", comment: "上报进入或退出拍照模式"))
            
            ZyCommandModule.shareInstance.reportEnterOrExitCamera { result, error in
                if error == .none {
                    self.logView.writeString(string: "\(result == 0 ? NSLocalizedString("Enter photo mode", comment: "进入拍照模式"):NSLocalizedString("Exit photo mode", comment: "退出拍照模式"))")
                }
            }
            
            break
            
        case NSLocalizedString("Do not disturb Settings for reporting", comment: "上报勿扰设置"):
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Do not disturb Settings for reporting", comment: "上报勿扰设置"))
            
            ZyCommandModule.shareInstance.reportDoNotDisturb { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        let isOpen = model.isOpen
                        let startHour = model.timeModel.startHour
                        let startMinute = model.timeModel.startMinute
                        let endHour = model.timeModel.endHour
                        let endMinute = model.timeModel.endMinute
                        
                        self.logView.writeString(string: isOpen ? NSLocalizedString("Turn on", comment: "开启"):NSLocalizedString("Shut down", comment: "关闭"))
                        self.logView.writeString(string: "\(NSLocalizedString("Time to start", comment: "开始时间")):\(startHour):\(startMinute)")
                        self.logView.writeString(string: "\(NSLocalizedString("End of period", comment: "结束时间")):\(endHour):\(endMinute)")
                    }
                }
            }
            
            break
        case NSLocalizedString("Report the number of days and start time of the pilgrimage alarm clock", comment: "上报朝拜闹钟天数及开始时间"):
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Report the number of days and start time of the pilgrimage alarm clock", comment: "上报朝拜闹钟天数及开始时间"))
            
            ZyCommandModule.shareInstance.reportWorshipStartTime { timeString, dayCount, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                self.logView.writeString(string: "\(NSLocalizedString("Pilgrimage alarm clock", comment: "朝拜闹钟")) dayCount:\(dayCount),date:\(timeString)")
                print("reportWorshipStartTime -> timeString = \(timeString),dayCount = \(dayCount)")
            }
            
            break
        case NSLocalizedString("Report request location information", comment: "上报请求定位信息"):
            
            self.logView.clearString()
            self.logView.writeString(string: "设备端触发显示")
            
            ZyCommandModule.shareInstance.reportLocationInfo { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                self.logView.writeString(string: NSLocalizedString("Report request location information", comment: "上报请求定位信息"))
                print("reportLocationInfo")
            }
            
            break

        case NSLocalizedString("Report the alarm clock", comment: "上报闹钟"):
            
            self.logView.clearString()
            self.logView.writeString(string: "设备端触发显示")
            
            ZyCommandModule.shareInstance.reportAlarmArray { alarmArray, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetAlarm ->",alarmArray)

                    for alarm in alarmArray {
                        let alarmModel = alarm
                        //print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",alarmModel.alarmTime,"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)

                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock serial number", comment: "闹钟序号")):\(alarmModel.alarmIndex)")
                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock time", comment: "闹钟时间")):\(alarmModel.alarmHour):\(alarmModel.alarmMinute)")
                        self.logView.writeString(string: "repeatCount:\(alarmModel.alarmRepeatCount)")
                        self.logView.writeString(string: "\(NSLocalizedString("Alarm clock switch", comment: "闹钟开关")):\(alarmModel.alarmOpen)")
                        if alarmModel.alarmOpen {
                            self.logView.writeString(string: "\(NSLocalizedString("Alarm clock repetition type", comment: "闹钟重复类型")):\(alarmModel.alarmType == .single ? NSLocalizedString("Single time alarm clock", comment: "单次闹钟"):NSLocalizedString("Repeat the alarm clock", comment: "重复闹钟"))")
                            if alarmModel.alarmType == .cycle {
                                if alarmModel.alarmRepeatArray != nil {
                                    let str = ((alarmModel.alarmRepeatArray![0] != 0 ? NSLocalizedString("Sunday", comment: "星期天"):"")+(alarmModel.alarmRepeatArray![1] != 0 ? NSLocalizedString("Monday", comment: "星期一"):"")+(alarmModel.alarmRepeatArray![2] != 0 ? NSLocalizedString("Tuesday", comment: "星期二"):"")+(alarmModel.alarmRepeatArray![3] != 0 ? NSLocalizedString("Wednesday", comment: "星期三"):"")+(alarmModel.alarmRepeatArray![4] != 0 ? NSLocalizedString("Thursday", comment: "星期四"):"")+(alarmModel.alarmRepeatArray![5] != 0 ? NSLocalizedString("Friday", comment: "星期五"):"")+(alarmModel.alarmRepeatArray![6] != 0 ? NSLocalizedString("Saturday", comment: "星期六"):""))
                                    self.logView.writeString(string: "\(NSLocalizedString("The alarm clock repeats the week", comment: "闹钟重复星期")):\(str)")
                                }else{
                                    self.logView.writeString(string: NSLocalizedString("Alarm repeat week: Repeat week is not turned on, default single alarm", comment: "闹钟重复星期:重复星期未开启,默认单次闹钟"))
                                }
                            }
                        }
                        self.logView.writeString(string: "\n")
                    }
                }
            }
            
            break
        case NSLocalizedString("Language of reporting", comment: "上报语言"):
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Language of reporting", comment: "上报语言"))
            
            ZyCommandModule.shareInstance.reportLanguageType { type, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                self.logView.writeString(string: "\(NSLocalizedString("Type", comment: "类型")):\(type)")
                print("reportLanguageType -> type = \(type)")
            }
            
            break
            
        case "0\(NSLocalizedString("The boot file", comment: "引导文件"))":
            
            let fileString = UserDefaults.standard.string(forKey: "0_BootFiles")
            
            var message = NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径")
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: NSLocalizedString("Boot file path", comment: "引导文件路径"), message: message, cancel: NSLocalizedString("Modify the path", comment: "修改路径"), cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: NSLocalizedString("Boot file path", comment: "引导文件路径"))
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "0_BootFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "0_BootFiles")
                        self.logView.writeString(string: NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径"))
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) {
                                
            }
            
            break
        
        case "1\(NSLocalizedString("File of application", comment: "应用文件"))":
            
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
            
        case "2\(NSLocalizedString("Photo gallery file", comment: "图库文件"))":
            
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
            
        case "3\(NSLocalizedString("Character library file", comment: "字库文件"))":
            
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
        
        case "4\(NSLocalizedString("Watch face file", comment: "表盘文件"))":
            
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
            
        case "5\(NSLocalizedString("Customize the watch face file", comment: "自定义表盘文件"))":
            
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
            
        case "7\(NSLocalizedString("Music file", comment: "音乐文件"))":
            
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
                        if let musicTypeModel = ZyCommandModule.shareInstance.functionListModel?.functionDetail_localPlay {
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
                            self.presentSystemAlertVC(title: "文件类型错误", message: "请选择设备支持的音乐文件(\(supportString)") {
                                
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
        case "8\(NSLocalizedString("Auxiliary location file", comment: "辅助定位文件"))":
            
            let fileString = UserDefaults.standard.string(forKey: "8_locationFile")
            
            var message = NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径")
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: NSLocalizedString("Auxiliary location path", comment: "辅助定位路径"), message: message, cancel: NSLocalizedString("Modify the path", comment: "修改路径"), cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: NSLocalizedString("Auxiliary location path", comment: "辅助定位路径"))
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "8_locationFile")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "8_locationFile")
                        self.logView.writeString(string: NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径"))
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) {
                                
            }
            
            break
        case "9\(NSLocalizedString("Customize the motion file", comment: "自定义运动文件"))":
            
            let fileString = UserDefaults.standard.string(forKey: "9_sportsType")
            
            var message = NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径")
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: NSLocalizedString("Customize the motion file path", comment: "自定义运动文件路径"), message: message, cancel: NSLocalizedString("Modify the path", comment: "修改路径"), cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: NSLocalizedString("Customize the motion file path", comment: "自定义运动文件路径"))
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "9_sportsType")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "9_sportsType")
                        self.logView.writeString(string: NSLocalizedString("Not selected, default project built-in project file path", comment: "未选择，默认项目内置工程文件路径"))
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) {
                                
            }
            
            break

        case NSLocalizedString("OTA upgrade", comment: "OTA升级"):
            
            let array = [
                "文件类型：默认0-\(NSLocalizedString("The boot file", comment: "引导文件"))",
            ]
            
            self.logView.clearString()
            self.presentTextFieldAlertVC(title: NSLocalizedString("OTA upgrade (default 0 for invalid types)", comment: "OTA升级(无效类型默认0)"), message: NSLocalizedString("Make sure the file path is correctly selected. Errors or invalid data may cause a flashback", comment: "请确定文件路径选择正确，错误或无效数据可能导致闪退"), holderStringArray: array, cancel: NSLocalizedString("Cancel", comment: "取消"), cancelAction: {
                
            }, ok: NSLocalizedString("Sure", comment: "确定")) { textArray in
                
                let type = textArray[0]
                
                let fileString = self.getFilePathWithType(type: type)
                
                self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):\(type)")
                self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
                
                print("fileString =",fileString)
                var showProgress = 0
                ZyCommandModule.shareInstance.setOtaStartUpgrade(type: Int(type) ?? 0, localFile: fileString, isContinue: false) { progress in

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

        case "\(NSLocalizedString("Stop upgrading", comment: "停止升级"))":
            
            ZyCommandModule.shareInstance.setStopUpgrade { error in
                print("setStopUpgrade -> error =",error)
            }
            
            break

        case "0\(NSLocalizedString("Boot upgrade", comment: "引导升级"))":
            
            let fileString = self.getFilePathWithType(type: "0")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):0\(NSLocalizedString("Boot upgrade", comment: "引导升级"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            ZyCommandModule.shareInstance.setOtaStartUpgrade(type: 0, localFile: fileString, isContinue: false) { progress in

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
            
        case "1\(NSLocalizedString("Application upgrade", comment: "应用升级"))":
            let fileString = self.getFilePathWithType(type: "1")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):1\(NSLocalizedString("Application upgrade", comment: "应用升级"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            ZyCommandModule.shareInstance.setOtaStartUpgrade(type: 1, localFile: fileString, isContinue: false) { progress in

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
            
        case "2\(NSLocalizedString("Gallery upgrade", comment: "图库升级"))":
            let fileString = self.getFilePathWithType(type: "2")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):2\(NSLocalizedString("Gallery upgrade", comment: "图库升级"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            ZyCommandModule.shareInstance.setOtaStartUpgrade(type: 2, localFile: fileString, isContinue: false) { progress in

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
            
        case "3\(NSLocalizedString("Font library upgrade", comment: "字库升级")))":
            let fileString = self.getFilePathWithType(type: "3")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):3\(NSLocalizedString("Font library upgrade", comment: "字库升级")))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            ZyCommandModule.shareInstance.setOtaStartUpgrade(type: 3, localFile: fileString, isContinue: false) { progress in

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
            
        case "4\(NSLocalizedString("Watch face upgrade", comment: "表盘升级"))":
            let fileString = self.getFilePathWithType(type: "4")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):4\(NSLocalizedString("Watch face upgrade", comment: "表盘升级"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            ZyCommandModule.shareInstance.setOtaStartUpgrade(type: 4, localFile: fileString, isContinue: false) { progress in

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
            
        case "5\(NSLocalizedString("Custom watch face upgrade", comment: "自定义表盘升级"))":
            
            let fileString = self.getFilePathWithType(type: "5")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):5\(NSLocalizedString("Custom watch face upgrade", comment: "自定义表盘升级"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
                 
            print("fileString =",fileString)
            var showProgress = 0
            ZyCommandModule.shareInstance.setOtaStartUpgrade(type: 5, localFile: fileString, isContinue: false) { progress in

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
            
        case "6\(NSLocalizedString("Worship alarm clock data", comment: "朝拜闹钟数据"))":
            self.logView.clearString()
            let array = [
                "起始日期:yyyy-MM-dd(默认当天)",
                "发送条数(时间按序号开始且递增+1,默认1条)",
            ]

            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Worship alarm clock data", comment: "朝拜闹钟数据"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                let timeString = textArray[0]
                let arrayCount = textArray[1]

                let startDate = formatter.date(from: timeString) ?? Date()
                var modelArray = [ZyWorshipTimeModel]()
                
                for i in 0..<(Int(arrayCount) ?? 1) {

                    let model = ZyWorshipTimeModel()
                    model.timeString = "2023-10-11"
                    model.fajr = (0 + i) >= 1440 ? (0 + i - 1440) : (0 + i)
                    model.dhuhr = (60 + i) >= 1440 ? (60 + i - 1440) : (60 + i)
                    model.asr = (120 + i) >= 1440 ? (120 + i - 1440) : (120 + i)
                    model.maghrib = (180 + i) >= 1440 ? (180 + i - 1440) : (180 + i)
                    model.isha = (240 + i) >= 1440 ? (240 + i - 1440) : (240 + i)
                    modelArray.append(model)
                }
                
                var showProgress = 0
                ZyCommandModule.shareInstance.setWorshipTime(modelArray) { progress in
                    
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
        case "7\(NSLocalizedString("Local music data", comment: "本地音乐数据"))":
            
            let fileString = self.getFilePathWithType(type: "7")
            print("fileString =",fileString)
            self.logView.clearString()
            
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
                ZyCommandModule.shareInstance.setLocalMusicFile(name, localFile: fileString) { progress in
                    
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
            
        case "8\(NSLocalizedString("Auxiliary positioning data", comment: "辅助定位数据"))":
            
            let fileString = self.getFilePathWithType(type: "8")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):8\(NSLocalizedString("Auxiliary positioning data", comment: "辅助定位数据"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
                 
            print("fileString =",fileString)
            var showProgress = 0
            ZyCommandModule.shareInstance.setAssistedPositioning(fileString) { progress in
                
                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                }
                print("progress ->",progress)

            } success: { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setAssistedPositioning -> error =",error.rawValue)

            }
            
            break
            
        case "9\(NSLocalizedString("Customize the exercise type", comment: "自定义运动类型"))":
            
            let fileString = self.getFilePathWithType(type: "9")
            
            self.logView.writeString(string: "\(NSLocalizedString("Current selection type", comment: "当前选择类型")):9\(NSLocalizedString("Customize the exercise type", comment: "自定义运动类型"))")
            self.logView.writeString(string: "\(NSLocalizedString("Path to file", comment: "文件路径")):\(fileString as! String)")
            print("fileString =",fileString)
            
            let array = [
                NSLocalizedString("Customize the exercise type", comment: "自定义运动类型"),
            ]
            var showProgress = 0
            self.presentTextFieldAlertVC(title: "提示(默认自定义运动类型26)", message: NSLocalizedString("Customize the exercise type", comment: "自定义运动类型"),holderStringArray: array) {
                
            } okAction: { textArray in
                let sportsType = Int(textArray[0]) ?? 26
                ZyCommandModule.shareInstance.setCustomSportsMode(sportsType, localFile: fileString) { progress in
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
        case NSLocalizedString("Customize the background selection", comment: "自定义背景选择"):
            
            self.presentSystemAlertVC(title: NSLocalizedString("Customize the background selection", comment: "自定义背景选择"), message: "", cancel: NSLocalizedString("Photo album", comment: "相册"), cancelAction: {
                self.initPhotoPicker()
            }, ok: NSLocalizedString("Take a photo", comment: "拍照")) {
                self.initCameraPicker()
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
                ZyCommandModule.shareInstance.getCustonDialFrameSize { success, error in

                    if error == .none {

                        if let model = success {
                            let bigWidth = model.bigWidth
                            let bigheight = model.bigHeight

                            if bigWidth > 0 && bigheight > 0 {
                                image = image.img_changeSize(size: .init(width: bigWidth, height: bigheight))
                                print("image.img_changeSize = \(image)")
                                var showProgress = 0
                                ZyCommandModule.shareInstance.setCustomDialEdit(image: image) { progress in
                                    if showProgress == Int(progress) {
                                        showProgress += 1
                                        self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                                    }
                                    print("progress ->",progress)
                                } success: { error in
                                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                                    print("SetCustomDialEdit -> error =",error.rawValue)
                                }
                                
                            }else{
                                print("GetCustonDialFrameSize 尺寸错误")
                            }
                        }
                        
                    }else{
                        print("GetCustonDialFrameSize error")
                    }
                }
      
            }else{
                self.presentSystemAlertVC(title: "警告:当前没有选择背景", message: "请选择自定义背景", cancel: nil, cancelAction: {

                }, ok: nil) {

                }
            }
                        
            break
            
        case NSLocalizedString("Set Custom Background (JL)", comment: "设置自定义背景(JL)"):
            
            if var image = self.customBgImage {
                
                ZyCommandModule.shareInstance.getCustonDialFrameSize { success, error in

                    if error == .none {

                        if let model = success {
                            let bigWidth = model.bigWidth
                            let bigheight = model.bigHeight

                            if bigWidth > 0 && bigheight > 0 {
                                image = image.img_changeSize(size: .init(width: bigWidth, height: bigheight))
                                var showProgress = 0
                                ZyCommandModule.shareInstance.setCustomDialEdit(image: image, progress: { progress in
                                    if showProgress == Int(progress) {
                                        showProgress += 1
                                        self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                                    }
                                    print("progress ->",progress)
                                }, isJL_Device: true) { error in
                                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                                    print("SetCustomDialEdit -> error =",error.rawValue)
                                }
                                
                            }else{
                                print("GetCustonDialFrameSize 尺寸错误")
                            }
                        }
                        
                    }else{
                        print("GetCustonDialFrameSize error")
                    }
                }
      
            }else{
                self.presentSystemAlertVC(title: "警告:当前没有选择背景", message: "请选择自定义背景", cancel: nil, cancelAction: {

                }, ok: nil) {

                }
            }
            
            break
            
        case NSLocalizedString("Get the server OTA information", comment: "获取服务器OTA信息"):
            
            ZyCommandModule.shareInstance.getServerOtaDeviceInfo { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    self.logView.writeString(string: "message:\(success["message"]!)")
                    self.logView.writeString(string: "code:\(success["code"]!)")
                }
                
                print("getServerOtaDeviceInfo ->",success)

            }
            
            break
            
        case NSLocalizedString("Automatic OTA upgrade server for the latest device version", comment: "自动OTA升级服务器最新设备相关版本"):
            var showProgress = 0
            ZyCommandModule.shareInstance.setAutoServerOtaDeviceInfo { progress in

                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                }
                print("progress ->",progress)

            } success: { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setAutoServerOtaDeviceInfo ->",error)
            }
            break
        case NSLocalizedString("Get online watch face (old interface, get all)", comment: "获取在线表盘(旧接口，获取全部)"):

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get online watch face", comment: "获取在线表盘"))
            
            ZyCommandModule.shareInstance.getOnlineDialList { dialArray, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("getOnlineDialList ->",dialArray.count)
                
                for item in dialArray {
                    print("item.dialId =",item.dialId,"item.dialImageUrl =",item.dialImageUrl,"item.dialFileUrl =",item.dialFileUrl,"item.dialName =",item.dialName)
                    self.logView.writeString(string: "id:\(item.dialId)")
                    self.logView.writeString(string: "imageUrl:\(item.dialImageUrl!)")
                    self.logView.writeString(string: "fileUrl:\(item.dialFileUrl!)")
                    self.logView.writeString(string: "name:\(item.dialName!)\n\n")
                }
                
                self.dialArray.removeAll()
                self.dialArray = dialArray

            }
            
            break
        case NSLocalizedString("Get online watch face (new interface, get paging)", comment: "获取在线表盘(新接口，获取分页)"):

            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get online watch face", comment: "获取在线表盘"))
            
            
            let array = [
                "获取的页数",
                "单页的个数"
            ]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("Get online watch face", comment: "获取在线表盘"), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let pageIndex = textArray[0]
                let pageSize = textArray[1]
                
                ZyCommandModule.shareInstance.getOnlineDialList(pageIndex: Int(pageIndex) ?? 0, pageSize: Int(pageSize) ?? 0) { dialArray, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    print("getOnlineDialList ->",dialArray.count)
                    
                    for item in dialArray {
                        print("item.dialId =",item.dialId,"item.dialImageUrl =",item.dialImageUrl,"item.dialFileUrl =",item.dialFileUrl,"item.dialName =",item.dialName)
                        self.logView.writeString(string: "id:\(item.dialId)")
                        self.logView.writeString(string: "imageUrl:\(item.dialImageUrl!)")
                        self.logView.writeString(string: "fileUrl:\(item.dialFileUrl!)")
                        self.logView.writeString(string: "name:\(item.dialName!)\n\n")
                    }
                    
                    self.dialArray.removeAll()
                    self.dialArray = dialArray

                }
                
//                ZyCommandModule.shareInstance.GetDeviceOtaVersionInfo
                
            }
            
            break
            
        case NSLocalizedString("Send online watch face", comment: "发送在线表盘"):
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Send online watch face", comment: "发送在线表盘"))
            
            let array = ["输入获取到的表盘ID"]
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Send online watch face", comment: "发送在线表盘"), message: "输入获取的表盘ID,输入错误不操作", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { textArray in
                
                let id = textArray[0]
                
                if let index = self.dialArray.firstIndex(where: { model in
                    return model.dialId == Int(id)
                }) {
                    self.logView.writeString(string: "ID:\(id)")
                    var showProgress = 0
                    ZyCommandModule.shareInstance.setOnlienDialFile(model: self.dialArray[index]) { progress in
                        if showProgress == Int(progress) {
                            showProgress += 1
                            self.logView.writeString(string: "\(NSLocalizedString("progress", comment: "进度")):\(progress)")
                        }
                        print("progress ->",progress)
                    } success: { error in
                        self.logView.writeString(string: self.getErrorCodeString(error: error))
                        print("setOnlienDialFile ->",error)
                    }
                }else{
                    self.logView.writeString(string: "没有此ID的表盘")
                }
            }
            
            break
            
        case NSLocalizedString("Gets the local watch face picture", comment: "获取本地表盘图片"):
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Gets the local watch face picture", comment: "获取本地表盘图片"))
            
            ZyCommandModule.shareInstance.getLocalDialImageServerInfo { dic, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if let dic = dic {
                        print("获取本地表盘图片 \ndic =\(dic)")
                        self.logView.writeString(string: "\(NSLocalizedString("Gets the local watch face picture", comment: "获取本地表盘图片")):\(dic)")
                    }
                }
                
            }
            
            break
            
        case NSLocalizedString("Get a custom watch face picture", comment: "获取自定义表盘图片"):
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("Get a custom watch face picture", comment: "获取自定义表盘图片"))
            
            ZyCommandModule.shareInstance.getCustomDialImageServerInfo { dic, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if let dic = dic {
                        print("获取自定义表盘图片 \ndic =\(dic)")
                        self.logView.writeString(string: "\(NSLocalizedString("Get a custom watch face picture", comment: "获取自定义表盘图片")):\(dic)")
                    }
                }
                
            }
            
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

    func getErrorCodeString(error:ZyError) -> String {
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
        }else if error == .noResponse {
            return "设备无响应"
        }else if error == .noMoreData {
            return "没有更多数据"
        }
        return "未知error"
    }

    static var antStepIndex = 0
    // MARK: - 同步ANT步数
    private func antSyncHistoryStepModel(complete:(()->())?) {
        
        print("ANT同步历史步数")
        
        if ZyVC.antStepIndex < 7 {
            
            self.antSyncStepDetailModel(dayCount: ZyVC.antStepIndex) {
                ZyVC.antStepIndex += 1
                
                DispatchQueue.main.async {
                    
                    self.antSyncHistoryStepModel(complete: complete)
                }
                
            }
            
        }else{
            ZyVC.antStepIndex = 0
            
            DispatchQueue.main.async {
                
                if let complete = complete {
                    complete()
                }
            }
            
        }
    }
    
    private func antSyncStepDetailModel(dayCount:Int,success:(()->())?) {
        
        print("step dayCount ->",dayCount)
        
        ZyCommandModule.shareInstance.setSyncHealthData(type: "1", dayCount: "\(dayCount)") { stepSuccess, error in
            
            if error == .none {
                if stepSuccess is ZyStepModel {
                    if let model:ZyStepModel = stepSuccess as? ZyStepModel {
                        let detailArray = model.detailArray
                        
                        print("detailArray -> 1",detailArray,detailArray.count)
                        
                        var stepArray = Array<Int>.init()
                        //SDK返回的是半个小时一个数据   整合到本地数据库每个小时一个数据
                        for i in stride(from: 0, to: detailArray.count/2, by: 1) {
                            let result = detailArray[i*2] + detailArray[i*2+1]
                            stepArray.append(result)
                        }
                    }
                }
            }
            
            if let success = success {
                print("ant同步第\(dayCount)天的步数数据完成")
                success()
            }
        }
    }
    
    static var antSleepIndex = 0
    // MARK: - 同步ANT睡眠
    private func antSyncHistorySleepModel(complete:(()->())?){
        
        if ZyVC.antSleepIndex < 7 {
            
            self.antSyncSleepDetailModel(dayCount: ZyVC.antSleepIndex) {
                ZyVC.antSleepIndex += 1
                
                self.antSyncHistorySleepModel(complete: complete)
            }
            
        }else{
            ZyVC.antSleepIndex = 0
            
            if let complete = complete {
                complete()
            }
        }

    }
    
    private func antSyncSleepDetailModel(dayCount:Int,success:(()->())?) {
        
        ZyCommandModule.shareInstance.setSyncHealthData(type: "3", dayCount: "\(dayCount)") { sleepSuccess, error in
            
            if error == .none {
                
                if sleepSuccess is ZySleepModel {
                    if let model:ZySleepModel = sleepSuccess as? ZySleepModel {
                        let deep = model.deep
                        let awake = model.awake
                        let light = model.light
                        let detailArray = model.detailArray
                        print("deep ->",deep,"awake ->",awake,"light ->",light,"detailArray ->",detailArray)
                    }
                }
            }
            if let success = success {
                print("ant同步第\(dayCount)天的睡眠数据完成")
                success()
            }
        }
    }
    
    static var antHeartrateIndex = 0
    // MARK: - 同步ANT心率历史
    func antSyncHistoryHeartrateModel(complete:(()->())?){
        
        if ZyVC.antHeartrateIndex < 7 {
            
            self.antSyncHeartrateDetailModel(dayCount: ZyVC.antHeartrateIndex) {
                ZyVC.antHeartrateIndex += 1
                
                
                self.antSyncHistoryHeartrateModel(complete: complete)
                
            }
            
        }else{
            ZyVC.antHeartrateIndex = 0
            
            if let complete = complete {
                complete()
            }
        }
    }

    func antSyncHeartrateDetailModel(dayCount:Int,success:(()->())?) {
            
        ZyCommandModule.shareInstance.setSyncHealthData(type: "2", dayCount: "\(dayCount)") { hrSuccess, error in
            
            print("error =",error.rawValue)
            
            if error == .none {
                
                if hrSuccess is ZyHrModel {
                    if let model:ZyHrModel = hrSuccess as? ZyHrModel {
                        let detailArray = model.detailArray
                        print("detailArray -> 2",detailArray)
                    }
                }

            }
            if let success = success {
                print("ant同步第\(dayCount)天的心率数据完成")
                success()
            }
        }
    }
}

extension ZyVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
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
                       
                        self.presentSystemAlertVC(title: "没有权限", message: "", cancel: "取消", cancelAction: {
                            
                        }, ok: "确定") {
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

extension UIColor {
     
    // Hex String -> UIColor
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
         
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
         
        var color: UInt32 = 0xFFFFFF
        scanner.scanHexInt32(&color)
         
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
         
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
         
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
     
    // UIColor -> Hex String
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(UInt8.max)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
         
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
}

extension UIImage{
    
    func img_changeSize(size:CGSize) -> UIImage {


        if let cgImage = self.cgImage {

            UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
            self.draw(in: .init(x: 0, y: 0, width: size.width, height: size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage ?? UIImage.init()

        }
        return UIImage.init()

    }
    
}
