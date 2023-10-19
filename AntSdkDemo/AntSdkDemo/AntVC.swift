//
//  AntXuVC.swift
//  AntSdkDemo
//
//  Created by 猜猜我是谁 on 2021/7/3.
//

import UIKit
import AntSDK
import CoreBluetooth
//import Alamofire
import Photos

class AntVC: UIViewController {
    //存放照片资源的标志符
    var localId:String!
    var customBgImage:UIImage?
    var currentBleState:CBPeripheralState! {
        didSet {
            if self.currentBleState == .disconnected {
                self.title = "已断开"
            }else if self.currentBleState == .connecting {
                self.title = "正在连接"
            }else if self.currentBleState == .connected {
                self.title = "已连接"
            }else if self.currentBleState == .disconnecting {
                self.title = "正在断开"
            }
        }
    }
    var ancsState:Bool = false
    var testCount = 0
    var tableView:UITableView!
    var dataSourceArray = [[String]].init()
    var titleArray = [String].init()
    var logView:ShowLogView!
    var dialArray = [AntOnlineDialModel].init()
    var autoTimer:Timer?
    var timestamp:Int?

    func test() {
        return
        AntCommandModule.shareInstance.getDeviceSupportList { _, _ in
            
        }
        
        AntCommandModule.shareInstance.setReportRealtimeData(isOpen: 1) { _ in
            
        }
        
        AntCommandModule.shareInstance.setNotificationRemind(isOpen: "65535", extensionOpen: "0") { _ in
            
        }
        
        AntCommandModule.shareInstance.setLightScreen(isOpen: 1) { _ in
            
        }
        
        AntCommandModule.shareInstance.set24HrMonitor(isOpen: 1) { _ in
            
        }
        
        AntCommandModule.shareInstance.setTime { _ in
            
        }
        
        AntCommandModule.shareInstance.getCustonDialFrameSize { _, _ in
            
        }
        
        AntCommandModule.shareInstance.setMetricSystem(metric: 0) { error in
            
        }
        
        for i in stride(from: 0, to: 3, by: 1) {

            AntCommandModule.shareInstance.getAlarm(index: i) { _, _ in
                                    
            }
        }
        
        return
        AntCommandModule.shareInstance.checkUpgradeState { _, _ in
            
        }
        
        AntCommandModule.shareInstance.setReportRealtimeData(isOpen: 1) { _ in
            
        }
        
        AntCommandModule.shareInstance.setTime { _ in
            
        }
        
        AntCommandModule.shareInstance.getCustonDialFrameSize { _, _ in
            
        }
        
        AntCommandModule.shareInstance.setDeviceLanguage(index: 0) { _ in
            
        }
        
        AntCommandModule.shareInstance.setWeatherUnit(type: 0) { _ in
            
        }
        
        AntCommandModule.shareInstance.getMetricSystem { _, _ in
            
        }
        
        AntCommandModule.shareInstance.getMac { _, _ in
            
        }
        
        AntCommandModule.shareInstance.getNotificationRemind { _,_, _ in
            
        }
        
        for i in stride(from: 0, to: 3, by: 1) {

            AntCommandModule.shareInstance.getAlarm(index: i) { _, _ in
                                    
            }
        }
        
        AntCommandModule.shareInstance.getSedentary { _, _ in
            
        }
        
        AntCommandModule.shareInstance.getDoNotDisturb { _, _ in
            
        }
        
        AntCommandModule.shareInstance.getLightScreen { _, _ in
            
        }
        
        AntCommandModule.shareInstance.get24HrMonitor { _, _ in
            
        }
        
        AntCommandModule.shareInstance.getScreenTimeLong { _, _ in
            
        }
        
        AntCommandModule.shareInstance.getTimeFormat { _, _ in
            
        }
        
        AntCommandModule.shareInstance.getMetricSystem { _, _ in
            
        }
        
        AntCommandModule.shareInstance.getDeviceLanguage { _, _ in
            
        }
        
        AntCommandModule.shareInstance.setWeatherUnit(type: 0) { _ in
            
        }
        
        AntCommandModule.shareInstance.getCustonDialFrameSize { _, _ in
            
        }
        
        AntCommandModule.shareInstance.setMetricSystem(metric: 0) { error in
            
        }
    }
    func decimalToBcd(value:Int) -> Int {
        return ((((value) / 10) << 4) + ((value) % 10))
    }
    
    // MARK: - BCD码转十进制
    func bcdToDecimal(value:Int) -> Int {
        return ((((value) & 0xf0) >> 4) * 10 + ((value) & 0x0f))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //e4 bd a0 e5 a5 bd e6 98 8e e5 a4 a9
        let valArray:[UInt8] = [170, 5, 129, 129, 2, 0, 1, 0, 4, 1, 0, 255, 121, 1, 0, 0, 231, 7, 8, 18, 0, 10, 37, 22, 0, 0, 23, 3, 150, 0, 0, 0, 208, 7, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 105, 0, 0, 0, 87, 1, 10, 1, 0, 0, 0, 233, 161, 89, 1, 247, 183, 203, 6, 82, 0, 0, 0, 0, 0, 199, 1, 139, 4, 159, 6, 126, 9, 9, 12, 96, 13, 139, 13, 75, 15, 202, 16, 134, 17, 249, 16, 137, 16, 240, 15, 201, 14, 104, 13, 210, 11, 160, 10, 242, 8, 189, 6, 0, 0, 0, 0, 0, 0, 199, 1, 139, 4, 159, 6, 126, 9, 9, 12, 96, 13, 139, 13, 75, 15, 202, 16, 134, 17, 249, 16, 137, 16, 240, 15, 201, 14, 104, 13, 210, 11, 160, 10, 242, 8, 189, 6, 0, 0, 0, 0, 0, 0, 199, 1, 139, 4, 159, 6, 126, 9, 9, 12, 96, 13, 139, 13, 75, 15, 202, 16, 134, 17, 249, 16, 137]// [0x05,0xff,0xf7,0x3f,0xff,0xbf,0x00,0x04,0xff,0xfb,0xff,0x01,0x06,0x02,0xff,0x1f,0x08,0x02,0x0a,0x01,0x0a,0x01,0x31,0x0f,0x03,0xff,0x1f,0x00,0x10,0x03,0x05,0x08,0x03,0x14,0x01,0x03,0x15,0x02,0x96,0x32,0x11,0x02,0x1e,0x00,0x25,0x01,0x03]//[0x05,0xff,0xf7,0x3f,0xfb,0xf0,0x00,0x04,0xff,0xfb,0xff,0x01,0x06,0x02,0xff,0x1f,0x08,0x02,0x0a,0x01,0x0a,0x01,0x31,0x0f,0x03,0xff,0x1f,0x00,0x10,0x03,0x05,0x08,0x03,0x14,0x01,0x03,0x15,0x02,0x96,0x32,0x11,0x02,0x1e,0x00,0x25,0x01,0x03]//[5, 255, 247, 63, 251, 240, 0, 4, 255, 251, 255, 1, 6, 2, 255, 31, 8, 2, 10, 1, 10, 1, 49, 15, 3, 255, 31, 0, 16, 3, 5, 8, 3, 20, 1, 3, 21, 2, 150, 50, 17, 2, 30, 0, 37, 1, 3]//[0x2F, 0x00, 0x02, 0x00,0x00, 0x00, 0x06, 0x0B, 0xE5, 0xBC, 0xA0, 0xE4, 0xB8, 0x89, 0x31, 0x33, 0x37, 0x35, 0x35, 0x36, 0x36, 0x30, 0x30, 0x33, 0x33,0x01, 0x00, 0x06, 0x0C, 0xE6, 0x9D, 0x8E, 0xE5, 0x9B, 0x9B, 0x30, 0x37, 0x35, 0x35, 0x2D, 0x36,0x31, 0x32, 0x38, 0x39, 0x39, 0x38]
                
        var str = ""
        for item in valArray {
            str += String.init(format: "0x%02x,", item)
        }
        print(str,"\(valArray.count)")
        
//        let fileData = try! Data.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "test_small.bin", ofType: "")!))
//        print("\(self.convertDataToHexStr(data: fileData))")
//        
        let result = AntCommandModule.shareInstance.CRC16(val:valArray)
        print("result =\(result),\(String.init(format: "0x%04x", result))")

//        let val = data.withUnsafeBytes { (byte) -> [UInt8] in
//            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
//            return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
//        }
//        let test:[UInt8] = Array.init(val[val.startIndex...20])
//        print("test =",type(of: test),test)
        
        self.currentBleState = AntCommandModule.shareInstance.peripheral?.state ?? .disconnected
        
        AntCommandModule.shareInstance.peripheralStateChange { [weak self] state in
            self?.currentBleState = state
        }
        
        if #available(iOS 13.0, *) {
            if let state = AntCommandModule.shareInstance.peripheral?.ancsAuthorized {
                self.ancsState = state
            }
        } else {
            
        }
        
        AntCommandModule.shareInstance.bluetoothAncsStateChange { [weak self] state in
            self?.ancsState = state
        }
        
        AntCommandModule.shareInstance.checkUpgradeState { success, error in
            print("继续升级")

            if error == .none {
                print("success.keys.count =",success.keys.count)
                if success.keys.count > 0 {
                    self.presentSystemAlertVC(title: "警告", message: "检测到当前设备正在升级，是否继续升级？(超时选择将退出升级)") {
                        AntCommandModule.shareInstance.setStopUpgrade { error in
                            print("退出升级")
                        }
                    } okAction: {

                        let type = success["type"] as! String
                        let fileString = self.getFilePathWithType(type: type)

                        var showProgress = 0
                        AntCommandModule.shareInstance.setStartUpgrade(type: Int(type) ?? 0, localFile: fileString, maxCount: 20, isContinue: true) { progress in

                            print("progress =",progress)
                            if showProgress == Int(progress) {
                                showProgress += 1
                                self.logView.writeString(string: "进度:\(progress)")
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
        
        self.logView = ShowLogView.init(frame: .init(x: 0, y: 84, width: screenWidth, height: screenHeight-84))
        //self.logView.center = self.view.center
        self.logView.isHidden = true
        self.view.addSubview(self.logView)
        
        self.titleArray = ["0x00 设备信息","0x01 设备设置","0x02 设备提醒","0x03 设备同步","0xaa 新协议命令","0x04 测试命令","0x80 设备主动上报","测试多包","路径设置","测试升级","服务器相关命令,使用前确定网络正常","个性化定制"]
        self.dataSourceArray = [
            [
                "0引导升级",
                "1应用升级",
                "2图库升级",
                "3字库升级",
                "4表盘升级",
                "5自定义表盘升级",
                "6朝拜闹钟数据",
                "7本地音乐数据",
                "0x00 获取设备名称",
                "0x02 获取固件版本",
                "0x04 获取序列号",
                //"0x05 设置序列号",
                "0x06 获取mac地址",
                "0x08 获取电量",
                "0x09 设置时间",
                "0x0a 获取设备支持的功能列表",
                "10 获取产品、固件、资源等版本信息",
            ],
            [
                "0x00 获取个人信息",
                "0x01 设置个人信息",
                "0x02 获取时间制式",
                "0x03 设置时间制式",
                "0x04 获取公英制",
                "0x05 设置公英制",
                "0x07 设置天气",
                "设置天气(拓展参数)",
                "0x09 设备进入拍照模式",
                "0x0b 寻找手环",
                "0x0c 获取抬腕亮屏",
                "0x0d 设置抬腕亮屏",
                "0x0e 获取屏幕亮度",
                "0x0f 设置屏幕亮度",
                "0x32 获取亮屏时长",
                "0x33 设置亮屏时长",
                "0x10 获取本地表盘",
                "0x11 设置本地表盘",
                "0x12 获取闹钟",
                "0x13 设置闹钟",
                "0x14 获取设备语言",
                "0x15 设置设备语言",
                "0x16 获取目标步数",
                "0x17 设置目标步数",
                //"0x18 获取显示方式",
                //"0x19 设置显示方式",
                //"0x1a 获取佩戴方式",
                //"0x1b 设置佩戴方式",
                //"0x1c",
                "0x1d 设置单次测量",
                "0x1e 获取锻炼模式",
                "0x1f 设置锻炼模式",
                //"0x21 设置设备模式",
                "0x25 设置手机类型",
                "0x28 获取天气单位",
                "0x29 设置天气单位",
                "0x2b 设置实时数据上报开关",
                "0x2c 获取自定义表盘",
                "0x2d 设置自定义表盘",
                "自定义背景选择",
                "(直接选取无编辑)自定义背景选择",
                "设置自定义背景",
                "设置自定义背景(JL)",
                "0x2e 设置电话状态",
                "0x30 获取自定义表盘尺寸",
                "0x34 获取24小时心率监测",
                "0x35 设置24小时心率监测",
                "0x37 设置设备进入或退出拍照模式",
                "0x3b app同步运动数据至设备(手动自定义)",
                "0x3b app同步运动数据至设备(自动1s递增)",
                "0x3d 设置清除所有数据",
                "0x3f 绑定",
                "0x41 解绑",
            ],
            [
                "0x00 获取消息提醒",
                "0x01 设置消息提醒",
                "0x02 获取久坐提醒",
                "0x03 设置久坐提醒(一组)",
                "0x03 设置久坐提醒(多组)",
                //"0x04 获取防丢提醒",
                //"0x05 设置防丢提醒",
                "0x06 获取勿扰提醒",
                "0x07 设置勿扰提醒",
                "0x08 获取心率预警",
                "0x09 设置心率预警",
                "0x0a 获取生理周期",
                "0x0b 设置生理周期",
                //"0x0c 获取洗手提醒",
                //"0x0d 设置洗手提醒",
                "0x0e 获取喝水提醒",
                "0x0f 设置喝水提醒",
                "同步联系人",
                "同步N个联系人",
                "0x14 获取低电提醒",
                "0x15 设置低电提醒",
                "0x16 获取单个LED灯功能",
                "0x17 设置单个LED灯功能",
                "0x19 设置单个LED灯电量显示",
                "0x1A 获取马达震动功能",
                "0x1B 设置马达震动功能",
            ],
            [
                "0x00 同步计步数据",
                "0x01",
                "0x02 同步锻炼数据",
                "同步测量数据",
            ],
            [
                "0x85 同步数据",
                "0x83(4) 设置天气",
                "0x83(5) 设置闹钟",
                "0x83(0x19) 设置睡眠目标",
                "0x84(5) 获取闹钟",
                "0x84(0x19) 获取睡眠目标",
                "0x83(0x1a) 设置SOS联系人",
                "0x84(0x1a) 获取SOS联系人",
                "0x83(0x1b) 周期测量参数设置",
                "0x84(0x1d) 获取朝拜闹钟天数及开始时间",
                "0x83(0x0f) 设置时区",
                "无响应 回应定位信息",
                "0x83(0x1e) 设置LED灯功能",
                "0x83(0x1f) 设置马达震动功能",
                "0x84(0x1e) 获取LED灯功能",
                "0x84(0x1f) 获取马达震动功能",
            ],
            [
                "0x00 ",
                "0x01 关机",
                "0x02 ",
                "0x03 恢复出厂设置",
                "0x04",
                "0x05 马达震动",
                "0x07 重新启动",
                "恢复出厂并关机"
            ],
            [
                "0x80 实时步数",
                "0x82 实时心率",
                "0x84 单次测量结果",
                "0x86 锻炼状态",
                "0x88 找手机",
                "0x89 结束找手机",
                "0x8a 拍照",
                "0x8c 音乐控制",
                "0x8e 来电控制",
                "上报屏幕亮度",
                "上报亮屏时长",
                "上报抬腕亮屏",
                "上报设备振动",
                "上报实时数据",
                "上报运动交互数据",
                "上报进入或退出拍照模式",
                "上报勿扰设置",
                "上报朝拜闹钟天数及开始时间",
                "上报请求定位信息",
                "上报闹钟",
            ],
            [
                "多包测试命令",
                "多包UTF8字符串测试命令",
                "多包Unicode字符串测命令"
            ],
            [
                "0引导文件",
                "1应用文件",
                "2图库文件",
                "3字库文件",
                "4表盘文件",
                "5自定义表盘文件",
                "7音乐文件",
            ],
            [
                "OTA升级",
                "0x00 分包信息交互(APP)",
                "0x02 启动升级",
                "0x03 停止升级",
            ],
            [
                "获取服务器OTA信息",
                "自动OTA升级服务器最新设备相关版本",
                "获取在线表盘(旧接口，获取全部)",
                "获取在线表盘(新接口，获取分页)",
                "发送在线表盘",
                "获取本地表盘图片",
                "获取自定义表盘图片",
            ],
            [
                "保存现有命令log",
                "删除所有文件夹",
            ]
        ]

        
    }
    
    func colorRgb565(color:UIColor) {
        
        let uint8Max = CGFloat(UInt8.max)
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var alpha:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        print("color.ciColor.red =",r,"g =",g,"b =",b)
        
        let intR = Int(r * uint8Max)
        let intG = Int(g * uint8Max)
        let intB = Int(b * uint8Max)
        
        let a = ((intB >> 3) & 0x1f)
        let newColor = UInt16((intR & 0xf8) << 8 | (intG & 0xfc) << 3 | a)
        
        print("newColor =",newColor)
    }
    
    func colorRgb565(red:Int,green:Int,blue:Int) -> [UInt8] {
        
//        var color_value = ((red & 0xf8 | (green>>5)) << 8)
//        color_value += ((green << 3 & 0xe0 | blue>>3) & 0xff)
//
//        return [UInt8((color_value >> 8) & 0xff),UInt8(color_value & 0xff)]
        
        
        let a = ((blue >> 3) & 0x1f)
        let newColor = UInt16((red & 0xf8) << 8 | (green & 0xfc) << 3 | a)

        return [UInt8((newColor >> 8) & 0xff),UInt8(newColor & 0xff)]
        //return [UInt8(newColor & 0xff),UInt8((newColor >> 8) & 0xff)]
    }
    
    func colorRgb888(hex:UInt16) {
        let a = ((hex & 0x001f) << 3)
        let abc:Int = Int((hex & 0xf800) << 8 | (hex & 0x07e0) << 5 | a)
        
        print("abc =",abc)
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
    
    @objc func pushNextVC() {
        let vc = LogViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func logButtonClick(sender:UIButton) {
        let vc = LogViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    deinit {
        print("deinit AntVC")
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

extension AntVC:UITableViewDataSource,UITableViewDelegate {
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
        let vc = LogViewController.init()
        
        print("didSelectRowAt -> date =",Date.init())
        
        switch rowString {
        case "0x00 获取设备名称":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取设备名称")
            AntCommandModule.shareInstance.getDeviceName { success, error in

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
        case "0x02 获取固件版本":

            self.logView.clearString()
            self.logView.writeString(string: "获取固件版本")
            AntCommandModule.shareInstance.getFirmwareVersion{ success, error in
                
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
            
        case "0x04 获取序列号":

            self.logView.clearString()
            self.logView.writeString(string: "获取序列号")
            AntCommandModule.shareInstance.getSerialNumber {success, error in

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
            
        case "0x05 设置序列号":

            
            
            break
        
        case "0x06 获取mac地址":

            self.logView.clearString()
            self.logView.writeString(string: "获取mac地址")
            AntCommandModule.shareInstance.getMac { success, error in
                
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
            
        case "0x08 获取电量":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取电量")
            AntCommandModule.shareInstance.getBattery { success, error in
                
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
            
        case "0x09 设置时间":
            
            self.logView.clearString()
            self.logView.writeString(string: "设置时间")
            let format = DateFormatter.init()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.logView.writeString(string: String.init(format: "%@", format.string(from: Date.init())))
            AntCommandModule.shareInstance.setTime(time: "") { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetTime ->","设置成功")
                    
                }
                
            }

            break
            
        case "0x0a 获取设备支持的功能列表":
            
            AntCommandModule.shareInstance.getDeviceSupportList { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    
                    if let model = success {
                        print("GetDeviceSupportList ->",model.showAllSupportFunctionLog())
                                            
                        self.logView.writeString(string: "\(model.showAllSupportFunctionLog())")
                    }
                }
            }

            break
            
        case "10 获取产品、固件、资源等版本信息":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取产品、固件、资源等版本信息")
            
            AntCommandModule.shareInstance.getDeviceOtaVersionInfo { success, error in
                
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
                    
                    self.logView.writeString(string: "产品id:\(product)")
                    self.logView.writeString(string: "项目id:\(project)")
                    self.logView.writeString(string: "固件:\(firmware)")
                    self.logView.writeString(string: "图库:\(library)")
                    self.logView.writeString(string: "字库:\(font)")
                }
            }
            
            break
        case "0x00 获取个人信息":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取个人信息")
            
            AntCommandModule.shareInstance.getPersonalInformation { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetPersonalInformation ->",success)
                    
                    if let model = success {
                        let height = model.height
                        let age = model.age
                        let weight = model.weight
                        let gender = model.gender
                        print("height ->",height,"age ->",age,"weight ->",weight,"gender ->",gender ? "女":"男")
                        
                        self.logView.writeString(string: "age:\(age)")
                        self.logView.writeString(string: "height:\(height)")
                        self.logView.writeString(string: "weight:\(weight)")
                        self.logView.writeString(string: "gender:\(gender ? "女":"男")")
                    }
                    
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }

            break
            
        case "0x01 设置个人信息":
            
            let array = [
                "age:[0,255]",
                "height:[0,255]",
                "weight:[0,255]",
                "gender:[0,1] 0男1女"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置个人信息")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "请输入用户资料设置", holderStringArray: array, cancel: "取消", cancelAction: {
                
            }, ok: "确定") { (textArray) in
                let age = textArray[0]
                let height = textArray[1]
                let weight = textArray[2]
                let gender = textArray[3]
                
                self.logView.writeString(string: "age:\(age.count > 0 ? age:"0")")
                self.logView.writeString(string: "height:\(height.count > 0 ? height:"0")")
                self.logView.writeString(string: "weight:\(weight.count > 0 ? weight:"0")")
                self.logView.writeString(string: "gender:\(gender == "1" ? "女":"男")")
                
                
                let model = AntPersonalModel.init()
                model.age = Int(age) ?? 0
                model.height = Float(height) ?? 0
                model.weight = Float(weight) ?? 0
                model.gender = (Int(gender) ?? 0) == 0 ? false:true
                
                AntCommandModule.shareInstance.setPersonalInformation(model: model) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetPersonalInformation ->","设置成功")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "0x02 获取时间制式":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取时间制式")
            
            AntCommandModule.shareInstance.getTimeFormat { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetTimeFormat ->",success)
                    
                    let timeFormat = success
                    print("timeFormat ->",timeFormat == 0 ? "24小时制":"12小时制")
                    
                    self.logView.writeString(string: timeFormat == 0 ? "24小时制":"12小时制")
                }
                
                //self.navigationController?.pushViewController(vc, animated: true)
            }

            break
            
        case "0x03 设置时间制式":
            
            let array = [
                "format:0-24小时制,1-12小时制"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置时间制式")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "请输入时间制", holderStringArray: array, cancel: "取消", cancelAction: {
                
            }, ok: "确定") { (textArray) in
                let format = textArray[0]
                
                self.logView.writeString(string: "\(format == "1" ? "12小时制":"24小时制")")
                AntCommandModule.shareInstance.setTimeFormat(format: Int(format) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetTimeFormat ->","设置成功")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            
            
            break
            
        case "0x04 获取公英制":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取公英制")
            AntCommandModule.shareInstance.getMetricSystem { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetMetricSystem ->",success)
                    
                    let metricSystem = success
                    print("metricSystem ->",metricSystem == 0 ? "公制":"英制")
                    
                    self.logView.writeString(string: metricSystem == 0 ? "公制":"英制")
                }
            }
            
            break
            
        case "0x05 设置公英制":
            
            let array = [
                "0:公制，1:英制"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置公英制")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "请输入公英制", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let format = textArray[0]
                
                self.logView.writeString(string: format == "1" ? "英制":"公制")
                
                AntCommandModule.shareInstance.setMetricSystem(metric: Int(format) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetMetricSystem ->","设置成功")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "0x07 设置天气":
            
            let array = [
                "未来天数",
                "天气类型",
                "温度",
                "空气质量",
                "最低温度",
                "最高温度",
                "明日最低温度",
                "明日最高温度",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置天气")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置天气", holderStringArray: array, cancel: nil, cancelAction: {
                
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
                self.logView.writeString(string: "天气类型:\(type)")
                self.logView.writeString(string: "温度:\(temp)")
                self.logView.writeString(string: "空气质量:\(airQuality)")
                self.logView.writeString(string: "最低温度:\(minTemp)")
                self.logView.writeString(string: "最高温度:\(maxTemp)")
                self.logView.writeString(string: "明日最低温度:\(tomorrowMinTemp)")
                self.logView.writeString(string: "明日最大温度:\(tomorrowMaxTemp)")
                
                let model = AntWeatherModel.init()
                model.dayCount = Int(dayCount) ?? 0
                model.type = AntWeatherType(rawValue:Int(type) ?? 0) ?? .sunny
                model.temp = Int(temp) ?? 0
                model.airQuality = Int(airQuality) ?? 0
                model.minTemp = Int(minTemp) ?? 0
                model.maxTemp = Int(maxTemp) ?? 0
                model.tomorrowMinTemp = Int(tomorrowMinTemp) ?? 0
                model.tomorrowMaxTemp = Int(tomorrowMaxTemp) ?? 0
                
                AntCommandModule.shareInstance.setWeather(model: model) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetWeather ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "设置天气(拓展参数)":
        
            let array = [
                "年",
                "月",
                "日",
                "时",
                "分",
                "秒",
                "未来天数",
                "天气类型",
                "温度",
                "空气质量",
                "最低温度",
                "最高温度",
                "明日最低温度",
                "明日最高温度",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置天气")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置天气", holderStringArray: array, cancel: nil, cancelAction: {
                
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
                
                self.logView.writeString(string: "显示时间:\(time)")
                self.logView.writeString(string: "第\(dayCount.count>0 ? dayCount : "0")天")
                self.logView.writeString(string: "天气类型:\(type)")
                self.logView.writeString(string: "温度:\(temp)")
                self.logView.writeString(string: "空气质量:\(airQuality)")
                self.logView.writeString(string: "最低温度:\(minTemp)")
                self.logView.writeString(string: "最高温度:\(maxTemp)")
                self.logView.writeString(string: "明日最低温度:\(tomorrowMinTemp)")
                self.logView.writeString(string: "明日最大温度:\(tomorrowMaxTemp)")
                
                let model = AntWeatherModel.init()
                model.dayCount = Int(dayCount) ?? 0
                model.type = AntWeatherType(rawValue:Int(type) ?? 0) ?? .sunny
                model.temp = Int(temp) ?? 0
                model.airQuality = Int(airQuality) ?? 0
                model.minTemp = Int(minTemp) ?? 0
                model.maxTemp = Int(maxTemp) ?? 0
                model.tomorrowMinTemp = Int(tomorrowMinTemp) ?? 0
                model.tomorrowMaxTemp = Int(tomorrowMaxTemp) ?? 0
                
                AntCommandModule.shareInstance.setWeather(model: model,updateTime: time) { error in

                    self.logView.writeString(string: self.getErrorCodeString(error: error))

                    if error == .none {
                        print("SetWeather ->","success")
                    }
                }
            }
            
            
            break
            
        case "0x09 设备进入拍照模式":
            
            self.logView.clearString()
            self.logView.writeString(string: "设备进入拍照模式")
            AntCommandModule.shareInstance.setEnterCamera { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetEnterCamera ->","success")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "0x0b 寻找手环":
            
            self.logView.clearString()
            self.logView.writeString(string: "寻找手环")
            AntCommandModule.shareInstance.setFindDevice { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetFindDevice ->","success")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }

            break
            
        case "0x0c 获取抬腕亮屏":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取抬腕亮屏")
            AntCommandModule.shareInstance.getLightScreen { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("success ->",success)
                    
                    let isOpen = success
                    print("isOpen ->",isOpen == 0 ? "关闭":"开启")
                    
                    self.logView.writeString(string: isOpen == 0 ? "关闭":"开启")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "0x0d 设置抬腕亮屏":
            
            let array = [
                "0:关，1:开"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置抬腕亮屏")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置抬腕亮屏", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                
                self.logView.writeString(string: (Int(isOpen) ?? 0) > 0 ? "开启":"关闭")
                AntCommandModule.shareInstance.setLightScreen(isOpen: Int(isOpen) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetLightScreen ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }

            break
            
        case "0x0e 获取屏幕亮度":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取屏幕亮度")
            
            AntCommandModule.shareInstance.getScreenLevel { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetScreenLevel ->",success)
                    
                    let level = success
                    print("level ->",level)
                    
                    self.logView.writeString(string: "亮度等级:\(level)")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }

            break
            
        case "0x0f 设置屏幕亮度":
            let array = [
                "亮度等级",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置屏幕亮度")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置屏幕亮度", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let level = textArray[0]
                
                self.logView.writeString(string: "亮度等级:\(level.count>0 ? level:"0")")
                
                AntCommandModule.shareInstance.setScreenLevel(value: Int(level) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetScreenLevelAndTime ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "0x32 获取亮屏时长":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取亮屏时长")
            
            AntCommandModule.shareInstance.getScreenTimeLong { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetScreenTimeLong ->",success)
                    
                    let timeLong = success
                    print("timeLong ->",timeLong)
                    
                    self.logView.writeString(string: "亮屏时长:\(timeLong)")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "0x33 设置亮屏时长":
            let array = [
                "时长",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置亮屏时长")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置亮屏时长", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let timeLong = textArray[0]
                
                self.logView.writeString(string: "亮屏时长:\(timeLong.count>0 ? timeLong:"0")")
                
                AntCommandModule.shareInstance.setScreenTimeLong(value: Int(timeLong) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetScreenTimeLong ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            break
            
        case "0x10 获取本地表盘":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取本地表盘")
            AntCommandModule.shareInstance.getLocalDial { success, error in
                
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
            
        case "0x11 设置本地表盘":
            let array = [
                "表盘序号"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置本地表盘")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置本地表盘", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let index = textArray[0]
                
                self.logView.writeString(string: "\(index.count>0 ? index:"0")")
                AntCommandModule.shareInstance.setLocalDial(index: Int(index) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetLocalDial ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "0x12 获取闹钟":
            let array = [
                "闹钟序号"
            ]

            self.logView.clearString()
            self.logView.writeString(string: "获取闹钟")
//            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "获取闹钟", holderStringArray: array, cancel: nil, cancelAction: {
//
//            }, ok: nil) { (textArray) in
//                let index = textArray[0]
//
//                AntCommandModule.shareInstance.getAlarm(index: index) { success, error in
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
//                        let alarmModel = AntAlarmModel.init(dic: success)
//                        print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",alarmModel.alarmTime,"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)
//
//                        self.logView.writeString(string: "闹钟序号:\(index.count>0 ? index:"0")")
//                        self.logView.writeString(string: "闹钟时间:\(alarmModel.alarmTime ?? "00:00")")
//                        self.logView.writeString(string: "repeatCount:\(repeatCount)")
//                        self.logView.writeString(string: "闹钟开关:\(alarmModel.alarmOpen)")
//                        if alarmModel.alarmOpen {
//                            self.logView.writeString(string: "闹钟重复类型:\(alarmModel.alarmType == .single ? "单次闹钟":"重复闹钟")")
//                            if alarmModel.alarmType == .cycle {
//                                if alarmModel.alarmRepeatArray != nil {
//                                    let str = ((alarmModel.alarmRepeatArray![0] != 0 ? "星期天":"")+(alarmModel.alarmRepeatArray![1] != 0 ? "星期一":"")+(alarmModel.alarmRepeatArray![2] != 0 ? "星期二":"")+(alarmModel.alarmRepeatArray![3] != 0 ? "星期三":"")+(alarmModel.alarmRepeatArray![4] != 0 ? "星期四":"")+(alarmModel.alarmRepeatArray![5] != 0 ? "星期五":"")+(alarmModel.alarmRepeatArray![6] != 0 ? "星期六":""))
//                                    self.logView.writeString(string: "闹钟重复星期:\(str)")
//                                }else{
//                                    self.logView.writeString(string: "闹钟重复星期:重复星期未开启,默认单次闹钟")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
            
            self.presentTextFieldAlertVC(title: "获取闹钟", message: "", holderStringArray: nil, cancel: "有效闹钟", cancelAction: {
                for i in stride(from: 0, to: 10, by: 1) {
                    AntCommandModule.shareInstance.getAlarm(index: i) { success, error in

                        if error == .none {
                            print("GetAlarm ->",success)

                            if let alarmModel = success {
                                print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute),"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)
                                if alarmModel.isValid {
                                    self.logView.writeString(string: "闹钟序号:\(alarmModel.alarmIndex)")
                                    self.logView.writeString(string: "闹钟时间:\(String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute))")
                                    self.logView.writeString(string: "repeatCount:\(alarmModel.alarmRepeatCount)")
                                    let str = alarmModel.alarmOpen ? "":"\n"
                                    self.logView.writeString(string: "闹钟开关:\(alarmModel.alarmOpen)\(str)")
                                    if alarmModel.alarmOpen {
                                        self.logView.writeString(string: "闹钟重复类型:\(alarmModel.alarmType == .single ? "单次闹钟":"重复闹钟")")
                                        if alarmModel.alarmType == .cycle {
                                            if alarmModel.alarmRepeatArray != nil {
                                                let str = ((alarmModel.alarmRepeatArray![0] != 0 ? "星期天":"")+(alarmModel.alarmRepeatArray![1] != 0 ? "星期一":"")+(alarmModel.alarmRepeatArray![2] != 0 ? "星期二":"")+(alarmModel.alarmRepeatArray![3] != 0 ? "星期三":"")+(alarmModel.alarmRepeatArray![4] != 0 ? "星期四":"")+(alarmModel.alarmRepeatArray![5] != 0 ? "星期五":"")+(alarmModel.alarmRepeatArray![6] != 0 ? "星期六":""))
                                                print("闹钟重复星期:\(str)")
                                                self.logView.writeString(string: "闹钟重复星期:\(str)\n")
                                            }else{
                                                self.logView.writeString(string: "闹钟重复星期:重复星期未开启,默认单次闹钟\n")
                                                print("闹钟重复星期:重复星期未开启,默认单次闹钟")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }, ok: "全部闹钟") { _ in
                for i in stride(from: 0, to: 10, by: 1) {
                    AntCommandModule.shareInstance.getAlarm(index: i) { success, error in

                        if error == .none {
                            print("GetAlarm ->",success)

                            if let alarmModel = success {
                                print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute),"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)

                                self.logView.writeString(string: "闹钟序号:\(alarmModel.alarmIndex)")
                                self.logView.writeString(string: "闹钟时间:\(String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute))")
                                self.logView.writeString(string: "repeatCount:\(alarmModel.alarmRepeatCount)")
                                let str = alarmModel.alarmOpen ? "":"\n"
                                self.logView.writeString(string: "闹钟开关:\(alarmModel.alarmOpen)\(str)")
                                if alarmModel.alarmOpen {
                                    self.logView.writeString(string: "闹钟重复类型:\(alarmModel.alarmType == .single ? "单次闹钟":"重复闹钟")")
                                    if alarmModel.alarmType == .cycle {
                                        if alarmModel.alarmRepeatArray != nil {
                                            let str = ((alarmModel.alarmRepeatArray![0] != 0 ? "星期天":"")+(alarmModel.alarmRepeatArray![1] != 0 ? "星期一":"")+(alarmModel.alarmRepeatArray![2] != 0 ? "星期二":"")+(alarmModel.alarmRepeatArray![3] != 0 ? "星期三":"")+(alarmModel.alarmRepeatArray![4] != 0 ? "星期四":"")+(alarmModel.alarmRepeatArray![5] != 0 ? "星期五":"")+(alarmModel.alarmRepeatArray![6] != 0 ? "星期六":""))
                                            print("闹钟重复星期:\(str)")
                                            self.logView.writeString(string: "闹钟重复星期:\(str)\n")
                                        }else{
                                            self.logView.writeString(string: "闹钟重复星期:重复星期未开启,默认单次闹钟\n")
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
            
        case "0x13 设置闹钟":
            
            let array = [
                "闹钟序号",
                "重复",
                "开始小时",
                "开始分钟"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置闹钟")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置闹钟", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let index = textArray[0]
                let repeatCount = textArray[1]
                let hour = textArray[2]
                let minute = textArray[3]
                                
//                AntCommandModule.shareInstance.setAlarm(index: index, repeatCount: repeatCount, hour: hour, minute: minute) { error in
//                    if error == .none {
//                        print("SetAlarm ->","success")
//                    }
//                }
                
                let dic = ["repeatCount": repeatCount, "hour": hour, "index": index, "minute": minute]
                let alarmModel = AntAlarmModel.init(dic: dic)
                
                self.logView.writeString(string: "闹钟序号:\(index.count>0 ? index:"0")")
                self.logView.writeString(string: "闹钟时间:\(String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute))")
                self.logView.writeString(string: "repeatCount:\(repeatCount)")
                self.logView.writeString(string: "闹钟开关:\(alarmModel.alarmOpen)")
                if alarmModel.alarmOpen {
                    self.logView.writeString(string: "闹钟重复类型:\(alarmModel.alarmType == .single ? "单次闹钟":"重复闹钟")")
                    if alarmModel.alarmType == .cycle {
                        if alarmModel.alarmRepeatArray != nil {
                            let str = ((alarmModel.alarmRepeatArray![0] != 0 ? "星期天":"")+(alarmModel.alarmRepeatArray![1] != 0 ? "星期一":"")+(alarmModel.alarmRepeatArray![2] != 0 ? "星期二":"")+(alarmModel.alarmRepeatArray![3] != 0 ? "星期三":"")+(alarmModel.alarmRepeatArray![4] != 0 ? "星期四":"")+(alarmModel.alarmRepeatArray![5] != 0 ? "星期五":"")+(alarmModel.alarmRepeatArray![6] != 0 ? "星期六":""))
                            self.logView.writeString(string: "闹钟重复星期:\(str)")
                        }else{
                            self.logView.writeString(string: "闹钟重复星期:重复星期未开启,默认单次闹钟")
                        }
                    }
                }
                
                print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute),"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)
                
                AntCommandModule.shareInstance.setAlarmModel(model: alarmModel) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetAlarm ->","success")
                    }
                }
                //self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            break
            
        case "0x14 获取设备语言":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取设备语言")
            AntCommandModule.shareInstance.getDeviceLanguage { success, error in
                
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
            
        case "0x15 设置设备语言":
            
            let array = [
                "语言序号"
            ]
            self.logView.clearString()
            self.logView.writeString(string: "设置设备语言")
            
            //0英语1中文简体2日语3韩语4德语5法语6西班牙语7阿拉伯语8俄语9中文繁体10意大利11葡萄牙12乌克兰语13印地语
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置设备语言\n0英文1简体中文2日语3韩语4德语5法语6西班牙语7阿拉伯语8俄语9繁体中文10意大利语11葡萄牙语12乌克兰语13印地语14波兰语15希腊语16越南语17印度尼西亚语18泰语19荷兰语20土耳其语21罗马尼亚语22丹麦语23瑞典语24孟加拉语25捷克语26波斯语27希伯来语28马来语29斯洛伐克语30南非科萨语31斯洛文尼亚语32匈牙利语33立陶宛语34乌尔都语35保加利亚语36克罗地亚语37拉脱维亚语38爱沙尼亚语39高棉语", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let index = textArray[0]
                
                self.logView.writeString(string: index.count > 0 ? index:"0")
                AntCommandModule.shareInstance.setDeviceLanguage(index: Int(index) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetDeviceLanguage ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "0x16 获取目标步数":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取目标步数")
            AntCommandModule.shareInstance.getStepGoal { success, error in
                
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
            
        case "0x17 设置目标步数":
            
            let array = [
                "目标步数"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置目标步数")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置目标步数", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let target = textArray[0]
                
                self.logView.writeString(string: target.count>0 ? target:"0")
                AntCommandModule.shareInstance.setStepGoal(target: Int(target) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetStepGoal ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "0x18 获取显示方式":
            
            AntCommandModule.shareInstance.getDispalyMode { success, error in
                print("GetDispalyMode ->",success)
            }

            break
            
        case "0x19 设置显示方式":
            
            let array = [
                "0:横屏，1:竖屏"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置显示方式", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isLandscape = textArray[0]
                
                AntCommandModule.shareInstance.setDispalyMode(isVertical: Int(isLandscape) ?? 0) { success in
                    print("SetDispalyMode ->",success)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            
            break
            
        case "0x1a 获取佩戴方式":
            
            AntCommandModule.shareInstance.getWearingWay { success, error in
                print("GetWearingWay ->",success)
            }
                        
            break
            
        case "0x1b 设置佩戴方式":
            
            let array = [
                "0:左手,1:右手"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置佩戴方式", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isLeftHand = textArray[0]
                
                AntCommandModule.shareInstance.setWearingWay(isLeftHand: Int(isLeftHand) ?? 0) { success in
                    print("SetWearingWay ->",success)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

            break
            
        case "0x1c":
            
            
            
            break
            
        case "0x1d 设置单次测量":
                        
            let array = [
                "类型：0-心率，1-血压，2-血氧",
                "0:关，1:开"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置单次测量")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置单次测量", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let isOpen = textArray[1]
                if type.count > 0 {
                    var str = ""
                    if type == "0" {
                        str = "心率"
                    }else if type == "1" {
                        str = "血压"
                    }else if type == "2" {
                        str = "血氧"
                    }else{
                        str = type
                    }
                    self.logView.writeString(string: "测量类型:\(str)")
                }else{
                    self.logView.writeString(string: "测量类型:心率")
                }

                self.logView.writeString(string: (Int(isOpen) ?? 0) > 0 ? "开启":"关闭")
                
                AntCommandModule.shareInstance.setSingleMeasurement(type: Int(type) ?? 0, isOpen: Int(isOpen) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetSingleMeasurement ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "0x1e 获取锻炼模式":

            self.logView.clearString()
            self.logView.writeString(string: "获取锻炼模式")
            AntCommandModule.shareInstance.getExerciseMode { success, state, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    print("GetExerciseMode ->",success)
                    
                    let type = success
                    print("type ->",type)
                    var stateString = ""
                    if state == .unknow {
                        stateString = "不支持的状态"
                        print(stateString)
                    }else if state == .end {
                        stateString = "结束"
                        print(stateString)
                    }else if state == .start {
                        stateString = "开始"
                        print(stateString)
                    }else if state == .continue {
                        stateString = "继续"
                        print(stateString)
                    }else if state == .pause {
                        stateString = "暂停"
                        print(stateString)
                    }
                    self.logView.writeString(string: "\(type.rawValue),\(stateString)")
                }
            }
            
            break
            
        case "0x1f 设置锻炼模式":
            
            let array = [
                "锻炼类型",
                "0:退出,1:进入,2:继续,3:暂停",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置锻炼模式")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置锻炼模式", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let isOpen = textArray[1]
                
                self.logView.writeString(string: "锻炼类型:\(type.count>0 ? type:"0")")
                var stateString = "退出"
                if Int(isOpen) == 0 {
                    stateString = "退出"
                    self.timestamp = nil
                }else if Int(isOpen) == 1 {
                    stateString = "进入"
                    let timestamp = Int(Date().timeIntervalSince1970)
                    self.timestamp = timestamp
                }else if Int(isOpen) == 2 {
                    stateString = "继续"
                }else if Int(isOpen) == 3 {
                    stateString = "暂停"
                }
                self.logView.writeString(string: stateString)
                let state = AntExerciseState.init(rawValue: Int(isOpen) ?? 0) ?? .end
                
                self.logView.writeString(string: "\(self.timestamp)")
                print("timestamp = \(self.timestamp)")
                AntCommandModule.shareInstance.setExerciseMode(type: AntExerciseType.init(rawValue: Int(type) ?? 0) ?? .runOutside, isOpen: state, timestamp: self.timestamp ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetExerciseMode ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "0x21 设置设备模式":
            
            let array = [
                "设备类型",
                "0:退出,1:进入",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置设备模式")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置设备模式", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let isOpen = textArray[1]
                
                self.logView.writeString(string: "设备类型:\(type.count>0 ? type:"0")")
                self.logView.writeString(string: (Int(isOpen) ?? 0) > 0 ? "进入":"退出")
                AntCommandModule.shareInstance.setDeviceMode(type: Int(type) ?? 0, isOpen: Int(isOpen) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetDeviceMode ->","success")
                    }
                }
            }

            break
            
        case "0x25 设置手机类型":
            let array = [
                "0:iOS,1:Android",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置手机类型")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置手机类型", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                AntCommandModule.shareInstance.setPhoneMode(type: Int(type) ?? 0) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetPhoneMode ->","success")
                    }
                }
            }
            break
            
        case "0x28 获取天气单位":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取天气单位")
            
            AntCommandModule.shareInstance.getWeatherUnit { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetWeatherUnit ->",success)
                    
                    let weatherUnit = success
                    print("weatherUnit ->",weatherUnit)
                    
                    self.logView.writeString(string: weatherUnit == 0 ? "摄氏度":"华氏度")
                }
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "0x29 设置天气单位":
            let array = [
                "0:摄氏度,1:华氏度",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置天气单位")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置天气单位", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                AntCommandModule.shareInstance.setWeatherUnit(type: Int(type) ?? 0) { error in
                    
                    self.logView.writeString(string: (type as NSString).intValue > 0 ? "华氏度":"摄氏度")
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetWeatherUnit ->","success")
                    }
                }
            }
            break
            
        case "0x2b 设置实时数据上报开关":
            let array = [
                "0:关闭,1:开启",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "实时数据上报开关")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置实时数据上报开关", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                
                AntCommandModule.shareInstance.setReportRealtimeData(isOpen: Int(isOpen) ?? 0, success: { error in
                    
                    self.logView.writeString(string: (Int(isOpen) ?? 0) == 0 ? "关闭":"开启")
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetReportRealtimeData ->","success")
                    }
                })
            }
            break
            
        case "0x2c 获取自定义表盘":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取自定义表盘")
            
            AntCommandModule.shareInstance.getCustomDialEdit { success, error in
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
                        
                        self.logView.writeString(string: "颜色值:\(colorHex)")
                        self.logView.writeString(string: "位置类型:\(positionType.rawValue)")
                        self.logView.writeString(string: "时间上方:\(timeUpType.rawValue)")
                        self.logView.writeString(string: "时间下方:\(timeDownType.rawValue)")
                    }
                }
            }
            
            break
            
        case "0x2d 设置自定义表盘":
            let array = [
                "输入十六进制颜色值",
                "显示位置,0左上1左中2左下3右上4右中5右下",
                "时间上方类型,0关闭1日期2睡眠3心率4计步5星期",
                "时间下方类型,0关闭1日期2睡眠3心率4计步5星期"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置自定义表盘")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置自定义表盘", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let color = textArray[0]
                let positionType = textArray[1]
                let timeUpType = textArray[2]
                let timeDownType = textArray[3]
                
                self.logView.writeString(string: "颜色值:\(color)")
                self.logView.writeString(string: "位置类型:\(positionType)")
                self.logView.writeString(string: "时间上方:\(timeUpType)")
                self.logView.writeString(string: "时间下方:\(timeDownType)")
                
                let model = AntCustomDialModel.init()
                model.color = UIColor.init(hexString: color)
                model.positionType = AntPositionType.init(rawValue: Int(positionType) ?? 0) ?? .leftTop
                model.timeUpType = AntPositionShowType.init(rawValue: Int(timeUpType) ?? 0) ?? .close
                model.timeDownType = AntPositionShowType.init(rawValue: Int(timeDownType) ?? 0) ?? .close
                
                AntCommandModule.shareInstance.setCustomDialEdit(model: model) { error in
                    
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))

                    if error == .none {
                        print("setCustomDialEdit ->","success")
                    }
                }
                
            }
            break
            
        case "0x2e 设置电话状态":
            
            let array = [
                "0:已挂断,1:已接听",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置电话状态")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置电话状态", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let state = textArray[0]
                
                AntCommandModule.shareInstance.setPhoneState(state: state) { error in
                    
                    self.logView.writeString(string: state == "1" ? "接听":"挂断")
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetPhoneState ->","success")
                    }
                }

            }
            
            break
            
        case "0x30 获取自定义表盘尺寸":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取自定义表盘尺寸")
            
            AntCommandModule.shareInstance.getCustonDialFrameSize { success, error in
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
            
        case "0x34 获取24小时心率监测":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取24小时心率监测")
            
            AntCommandModule.shareInstance.get24HrMonitor { success, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("Get24HrMonitor ->",success)
                    
                    let isOpen = success
                    self.logView.writeString(string: isOpen == 0 ? "关闭":"开启")
                }
            }
            
            break
            
        case "0x35 设置24小时心率监测":
            
            let array = [
                "0:关闭,1:开启",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置24小时心率监测")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置24小时心率监测", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                
                AntCommandModule.shareInstance.set24HrMonitor(isOpen: Int(isOpen) ?? 0) { error in
                    
                    self.logView.writeString(string: (Int(isOpen) ?? 0) == 0 ? "关闭":"启动")
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("Set24HrMonitor ->","success")
                    }
                }
            }
            
            break
            
        case "0x37 设置设备进入或退出拍照模式":
            
            let array = [
                "0:进入,1:退出",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置设备进入或退出拍照模式")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置设备进入或退出拍照模式", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                
                AntCommandModule.shareInstance.setEnterOrExitCamera(isOpen: Int(isOpen) ?? 0) { error in
                    self.logView.writeString(string: (Int(isOpen) ?? 0) == 0 ? "进入":"退出")
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("Set24HrMonitor ->","success")
                    }
                }
            }
            
            break
            
        case "0x3b app同步运动数据至设备(手动自定义)":
            
            let array = [
                "锻炼类型",
                "运动时长",
                "卡路里",
                "距离",
            ]

            self.logView.clearString()
            self.logView.writeString(string: "app同步运动数据至设备")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "app同步运动数据至设备", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let timeLong = textArray[1]
                let calories = textArray[2]
                let distance = textArray[3]
                
                AntCommandModule.shareInstance.setExerciseDataToDevice(type: AntExerciseType.init(rawValue: Int(type) ?? 0) ?? .runOutside, timeLong: Int(timeLong) ?? 0, calories: Int(calories) ?? 0, distance: Int(distance) ?? 0) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setExerciseDataToDevice ->","success")
                    }
                }
            }
            
            break
            
        case "0x3b app同步运动数据至设备(自动1s递增)":
            
            let array = [
                "锻炼类型",
                "运动时长递增数(默认1)",
                "卡路里递增数(默认1)",
                "距离递递增数(默认1)",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "app同步运动数据至设备")
            
            var timer:Timer?
                
            if #available(iOS 10.0, *) {
                
                self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "app同步运动数据至设备", holderStringArray: array, cancel: "取消", cancelAction: {
                    
                }, ok: "开始") { (textArray) in

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
                        self.logView.writeString(string: "运动类型:\(Int(type) ?? 0)")
                        self.logView.writeString(string: "运动时长:\(timeLong)")
                        self.logView.writeString(string: "卡路里:\(calories)")
                        self.logView.writeString(string: "距离:\(distance)\n")
                        AntCommandModule.shareInstance.setExerciseDataToDevice(type: AntExerciseType.init(rawValue: Int(type) ?? 0) ?? .runOutside, timeLong: timeLong, calories: calories, distance: distance) { error in

                            if error == .none {
                                print("setExerciseDataToDevice ->","success")
                            }
                        }
                    }
                    
                    self.presentSystemAlertVC(title: "提示", message: "点击确定结束此次自动发送", cancelAction: nil) {
                        timer?.invalidate()
                        timer = nil
                    }
                }

            } else {

            }
            
            break
            
        case "0x3d 设置清除所有数据":
            self.logView.clearString()
            self.logView.writeString(string: "设置清除所有数据")
            
            AntCommandModule.shareInstance.setClearAllData { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("setClearAllData ->","success")
                }
            }
            
            break
            
        case "0x3f 绑定":
            self.logView.clearString()
            self.logView.writeString(string: "绑定")
            
            AntCommandModule.shareInstance.setBind { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("setBind ->","success")
                }
            }
            
            break
            
        case "0x41 解绑":
            
            self.logView.clearString()
            self.logView.writeString(string: "解绑")
            
            AntCommandModule.shareInstance.setUnbind { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("setUnbind ->","success")
                }
            }
            break

        case "0x00 获取消息提醒":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取消息提醒")
            AntCommandModule.shareInstance.getNotificationRemind { success,success1, error  in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetMessageRemind ->",success)
                    
                    let array = success
                    print("GetMessageRemind ->",array)
                    
                    let array1 = success1
                    print("GetMessageRemind ->",array1)
                    self.logView.writeString(string: "\(array)")
                    self.logView.writeString(string: "拓展推送:\(array1)")
                }
                
                //self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "0x01 设置消息提醒":
            
            let array = [
                "消息类型开关",
                "拓展消息开关",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置消息提醒")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置消息提醒", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let extensionOpen = textArray[1]
                
//                AntCommandModule.shareInstance.setNotificationRemind(isOpen: isOpen) { error in
//
//                    self.logView.writeString(string: self.getErrorCodeString(error: error))
//
//                    if error == .none {
//                        print("SetMessageRemind ->","success")
//                    }
//                    //self.navigationController?.pushViewController(vc, animated: true)
//                }
                if #available(iOS 13.0, *) {
                    if let state = AntCommandModule.shareInstance.peripheral?.ancsAuthorized {
                        self.logView.writeString(string: "蓝牙共享系统通知:\(state ? "开":"关")")
                    }
                }
                let array = AntCommandModule.shareInstance.getNotificationTypeArrayWithIntString(countString: isOpen)
                print("array ->",array)
                let extensionArray = AntCommandModule.shareInstance.getNotificationExtensionTypeArrayWithIntString(countString: extensionOpen)
                print("extensionArray ->",extensionArray)
                
                self.logView.writeString(string: "\(array)")
                self.logView.writeString(string: "拓展消息:\(extensionArray)")
                AntCommandModule.shareInstance.setNotificationRemindArray(array: array, extensionArray: extensionArray) { error in

                    self.logView.writeString(string: self.getErrorCodeString(error: error))

                    if error == .none {
                        print("SetMessageRemind ->","success")
                    }
                }
                
            }

            break
            
        case "0x02 获取久坐提醒":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取久坐提醒")
            AntCommandModule.shareInstance.getSedentary { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetSedentary ->",success)
                    
                    if let model = success {
                        let isOpen = model.isOpen
                        let timeLong = model.timeLong
                        let modelArray = model.timeArray
                        self.logView.writeString(string: isOpen ? "开启":"关闭")
                        self.logView.writeString(string: "提醒时长:\(timeLong)")
                        for item in modelArray {
                            self.logView.writeString(string: "开始时间:\(item.startHour).\(item.startMinute)")
                            self.logView.writeString(string: "结束时间:\(item.endHour).\(item.endMinute)")
                        }
                    }
                }
            }
            
            break
            
        case "0x03 设置久坐提醒(一组)":
            
            let array = [
                "0:关，1:开",
                "间隔时长",
                "开始小时",
                "开始分钟",
                "结束小时",
                "结束分钟",
                
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置久坐提醒")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0,格式错误可能闪退)", message: "设置久坐提醒", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let timeLong = textArray[1]
                let startHour = textArray[2]
                let startMinute = textArray[3]
                let endHour = textArray[4]
                let endMinute = textArray[5]
                
                self.logView.writeString(string: (Int(isOpen) ?? 0) > 0 ? "开启":"关闭")
                self.logView.writeString(string: "开始时间:\(startHour.count>0 ? startHour:"0").\(startMinute.count>0 ? startMinute:"0")")
                self.logView.writeString(string: "结束时间:\(endHour.count>0 ? endHour:"0").\(endMinute.count>0 ? endMinute:"0")")
                self.logView.writeString(string: "提醒时长:\(timeLong.count>0 ? timeLong:"0")")
                
                AntCommandModule.shareInstance.setSedentary(isOpen: isOpen, timeLong: timeLong, startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetSedentary ->","success")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
            }

            break
            
        case "0x03 设置久坐提醒(多组)":
            
            let array = [
                "0:关，1:开",
                "间隔时长",
                "开始小时",
                "开始分钟",
                "结束小时",
                "结束分钟",
                "开始小时",
                "开始分钟",
                "结束小时",
                "结束分钟",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置久坐提醒")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0,格式错误可能闪退)", message: "设置久坐提醒", holderStringArray: array, cancel: nil, cancelAction: {
                
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
                
                self.logView.writeString(string: (Int(isOpen) ?? 0) > 0 ? "开启":"关闭")
                self.logView.writeString(string: "提醒时长:\(timeLong.count>0 ? timeLong:"0")")
                self.logView.writeString(string: "第一组开始时间:\(startHour.count>0 ? startHour:"0").\(startMinute.count>0 ? startMinute:"0")")
                self.logView.writeString(string: "第一组结束时间:\(endHour.count>0 ? endHour:"0").\(endMinute.count>0 ? endMinute:"0")")
                self.logView.writeString(string: "第二组开始时间:\(startHour_2.count>0 ? startHour_2:"0").\(startMinute_2.count>0 ? startMinute_2:"0")")
                self.logView.writeString(string: "第二组结束时间:\(endHour_2.count>0 ? endHour_2:"0").\(endMinute_2.count>0 ? endMinute_2:"0")")
                
                let model = AntStartEndTimeModel.init()
                model.startHour = Int(startHour) ?? 0
                model.startMinute = Int(startMinute) ?? 0
                model.endHour = Int(endHour) ?? 0
                model.endMinute = Int(endMinute) ?? 0
                
                let model_2 = AntStartEndTimeModel.init()
                model_2.startHour = Int(startHour_2) ?? 0
                model_2.startMinute = Int(startMinute_2) ?? 0
                model_2.endHour = Int(endHour_2) ?? 0
                model_2.endMinute = Int(endMinute_2) ?? 0
                
                let sedentaryModel = AntSedentaryModel.init()
                sedentaryModel.isOpen = (Int(isOpen) ?? 0) == 0 ? false:true
                sedentaryModel.timeLong = Int(timeLong) ?? 0
                sedentaryModel.timeArray = [model,model_2]
                
                AntCommandModule.shareInstance.setSedentary(model: sedentaryModel) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))

                    if error == .none {
                        print("SetSedentary ->","success")
                    }

                }
                
//                AntCommandModule.shareInstance.setSedentary(isOpen: isOpen, timeLong: timeLong, timeArray: [model,model_2]) { error in
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
            
        case "0x04 获取防丢提醒":
            
            AntCommandModule.shareInstance.getLost { success, error in
                print("GetLost ->",success)
                self.navigationController?.pushViewController(vc, animated: true)
            }

            break
            
        case "0x05 设置防丢提醒":
            
            let array = [
                "0:关闭，1:开启"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置防丢提醒", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                
                AntCommandModule.shareInstance.setLost(isOpen: isOpen) { success in
                    print("SetLost ->",success)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

            
            
            break
            
        case "0x06 获取勿扰提醒":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取勿扰提醒")
            
            AntCommandModule.shareInstance.getDoNotDisturb { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    
                    print("GetDoNotDisturb ->",success)
                    
                    if let model = success {
                        let isOpen = model.isOpen
                        let startHour = model.timeModel.startHour
                        let startMinute = model.timeModel.startMinute
                        let endHour = model.timeModel.endHour
                        let endMinute = model.timeModel.endMinute
                        
                        self.logView.writeString(string: isOpen ? "开启":"关闭")
                        self.logView.writeString(string: "开始时间:\(startHour):\(startMinute)")
                        self.logView.writeString(string: "结束时间:\(endHour):\(endMinute)")
                    }
                }
            }
            
            break
            
        case "0x07 设置勿扰提醒":
            
            let array = [
                "0:关闭，1:开启",
                "开始小时",
                "开始分钟",
                "结束小时",
                "结束分钟"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置勿扰提醒")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置勿扰提醒", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let startHour = textArray[1]
                let startMinute = textArray[2]
                let endHour = textArray[3]
                let endMinute = textArray[4]
                
                self.logView.writeString(string: (Int(isOpen) ?? 0) == 0 ? "关闭":"开启")
                self.logView.writeString(string: String.init(format: "开始时间 %02d:%02d", Int(startHour) ?? 0,Int(startMinute) ?? 0))
                self.logView.writeString(string: String.init(format: "结束时间 %02d:%02d", Int(endHour) ?? 0,Int(endMinute) ?? 0))
                
                AntCommandModule.shareInstance.setDoNotDisturb(isOpen: isOpen, startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetDoNotDisturb -> success")
                    }
                }
            }
            
            break
            
        case "0x08 获取心率预警":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取心率预警")
            
            AntCommandModule.shareInstance.getHrWaring { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetHrWaring ->",success)
                    
                    if let model = success {
                        let isOpen = model.isOpen
                        let maxHr = model.maxValue
                        let minHr = model.minValue
                        
                        self.logView.writeString(string: isOpen ? "开启":"关闭")
                        self.logView.writeString(string: "最大值:\(maxHr)")
                        self.logView.writeString(string: "最小值:\(minHr)")
                    }
                    
                    
                }
            }
            
            break
            
        case "0x09 设置心率预警":
            
            let array = [
                "0:关闭，1:开启",
                "最大值",
                "最小值",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置心率预警")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置心率预警", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let maxHr = textArray[1]
                let minHr = textArray[2]
                
                self.logView.writeString(string: (Int(isOpen) ?? 0) == 0 ? "关闭":"开启")
                self.logView.writeString(string: "最大值:\(maxHr)")
                self.logView.writeString(string: "最小值:\(minHr)")
                
                AntCommandModule.shareInstance.setHrWaring(isOpen: isOpen, maxHr: maxHr, minHr: minHr) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetHrWaring -> success")
                    }
                }
            }
            
            break
            
        case "同步联系人":
            
            let array = [
                "0姓名(默认张三)",
                "0号码(默认13755660033)",
                "1姓名(默认李四)",
                "1号码(默认0755-6128998)",
                "2姓名",
                "2号码",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "同步联系人")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认为空)", message: "设置联系人", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let model_0 = AntAddressBookModel.init()
                model_0.name = textArray[0].count == 0 ? "张三" : textArray[0]
                model_0.phoneNumber = textArray[1].count == 0 ? "13755660033" : textArray[1]

                let model_1 = AntAddressBookModel.init()
                model_1.name = textArray[2].count == 0 ? "李四" : textArray[2]
                model_1.phoneNumber = textArray[3].count == 0 ? "0755-6128998" : textArray[3]
                
                let model_2 = AntAddressBookModel.init()
                model_2.name = textArray[4]
                model_2.phoneNumber = textArray[5]
                
                self.logView.writeString(string: "联系人0 姓名:\(model_0.name),号码:\(model_0.phoneNumber)")
                self.logView.writeString(string: "联系人1 姓名:\(model_1.name),号码:\(model_1.phoneNumber)")
                self.logView.writeString(string: "联系人2 姓名:\(model_2.name),号码:\(model_2.phoneNumber)")
                
                AntCommandModule.shareInstance.setAddressBook(modelArray: [model_0,model_1,model_2]) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        print("SetAddressBook -> success")
                    }
                }
                
            }
            
            break
            
        case "同步N个联系人":
            
            let array = [
                "同步个数(默认10个)",
                "姓名(默认张三,+\"-序号\")",
                "号码(默认13755660000,+序号)",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "同步N个联系人")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认为空)", message: "设置联系人", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                var peopleCount = 10
                if let string = textArray[0] as? String{
                    peopleCount = Int(string) ?? 10
                }
                var modelArray = Array<AntAddressBookModel>.init()
                for i in 0..<peopleCount {
                    let model = AntAddressBookModel.init()
                    model.name = (textArray[1].count == 0 ? "张三" : textArray[1])+"-\(i)"
                    model.phoneNumber = String.init(format: "%ld", (Int64(textArray[2].count == 0 ? "13755660000" : textArray[2]) ?? 13755660000)+Int64(i))
                    modelArray.append(model)
                    self.logView.writeString(string: "联系人\(i) 姓名:\(model.name),号码:\(model.phoneNumber)")
                }
                
                AntCommandModule.shareInstance.setAddressBook(modelArray: modelArray) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        print("SetAddressBook -> success")
                    }
                }
                
            }
            
            break
            
        case "0x0a 获取生理周期":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取生理周期")
            
            AntCommandModule.shareInstance.getMenstrualCycle { success, error in
                
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
                        
                        self.logView.writeString(string: isOpen ? "开启":"关闭")
                        self.logView.writeString(string: "周期天数: \(cycleCount)")
                        self.logView.writeString(string: "经期天数: \(menstrualCount)")
                        self.logView.writeString(string: String.init(format: "上一次月经开始日期: %04d-%02d-%02d", year,month,day))
                        self.logView.writeString(string: "提前提醒天数: \(advanceDay)")
                        self.logView.writeString(string: String.init(format: "提醒时间: %02d:%02d", remindHour,remindMinute))
                    }
                }
            }
            
            break
            
        case "0x0b 设置生理周期":
            
            let array = [
                "开关",
                "周期天数",
                "月经天数",
                "上次经期的年",
                "上次经期的月",
                "上次经期的日",
                "提前提醒的天数",
                "提醒小时",
                "提醒分钟"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置生理周期", holderStringArray: array, cancel: nil, cancelAction: {
                
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
                
                let model = AntMenstrualModel.init()
                model.isOpen = isOpen
                model.cycleCount = cycleCount
                model.menstrualCount = menstrualCount
                model.year = year
                model.month = month
                model.day = day
                model.advanceDay = advanceDay
                model.remindHour = remindHour
                model.remindMinute = remindMinute
                
                self.logView.writeString(string: isOpen ? "开启":"关闭")
                self.logView.writeString(string: "周期天数: \(cycleCount)")
                self.logView.writeString(string: "经期天数: \(menstrualCount)")
                self.logView.writeString(string: String.init(format: "上一次月经开始日期: %04d-%02d-%02d", year,month,day))
                self.logView.writeString(string: "提前提醒天数: \(advanceDay)")
                self.logView.writeString(string: String.init(format: "提醒时间: %02d:%02d", remindHour,remindMinute))
                
                AntCommandModule.shareInstance.setMenstrualCycle(model: model) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        
                    }
                }
            }
            
            
            break
            
        case "0x0c 获取洗手提醒":
            
            AntCommandModule.shareInstance.getWashHand { success, error in
                print("GetWashHand ->",success)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case "0x0d 设置洗手提醒":
            
            let array = [
                "0:关，1:开",
                "开始小时",
                "开始分钟",
                "目标次数",
                "提醒间隔"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置洗手提醒", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let startHour = textArray[1]
                let startMinute = textArray[2]
                let targetCount = textArray[3]
                let remindInterval = textArray[4]
                
                AntCommandModule.shareInstance.setWashHand(isOpen: isOpen, startHour: startHour, startMinute: startMinute, targetCount: targetCount, remindInterval: remindInterval) { success in
                    print("SetWashHand ->",success)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            break
            
        case "0x0e 获取喝水提醒":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取喝水提醒")

            AntCommandModule.shareInstance.getDrinkWater { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if let model = success {
                        let isOpen = model.isOpen
                        let startHour = model.timeModel.startHour
                        let startMinute = model.timeModel.startMinute
                        let endHour = model.timeModel.endHour
                        let endMinute = model.timeModel.endMinute
                        let remindInterval = model.remindInterval
                        
                        self.logView.writeString(string: isOpen ? "开启":"关闭")
                        self.logView.writeString(string: "开始时间: \(startHour):\(startMinute)")
                        self.logView.writeString(string: "结束时间: \(endHour):\(endMinute)")
                        self.logView.writeString(string: "提醒间隔: \(remindInterval)")
                    }
                }
            }
            
            break
            
        case "0x0f 设置喝水提醒":
            
            let array = [
                "0:关，1:开",
                "开始小时",
                "开始分钟",
                "结束小时",
                "结束分钟",
                "提醒间隔"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置喝水提醒", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let startHour = textArray[1]
                let startMinute = textArray[2]
                let endHour = textArray[3]
                let endMinute = textArray[4]
                let remindInterval = textArray[5]
                
//                let model = AntDrinkWaterModel.init()
//                model.isOpen = isOpen
//                model.remindInterval = remindInterval
//                model.timeModel.startHour = startHour
//                model.timeModel.startMinute = startMinute
//                model.timeModel.endHour = endHour
//                model.timeModel.endMinute = endMinute
//
//                AntCommandModule.shareInstance.setDrinkWater(model: model) { error in
                AntCommandModule.shareInstance.setDrinkWater(isOpen: isOpen, startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute, remindInterval: remindInterval) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetDrinkWater -> success")
                    }
                }
                
            }
            
            break
            
        case "0x14 获取低电提醒":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取低电提醒")
            
            AntCommandModule.shareInstance.getLowBatteryRemind { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if let model = success {
                        let isOpen = model.isOpen
                        let remindBattery = model.remindBattery
                        let remindCount = model.remindCount
                        let remindInterval = model.remindInterval
                        
                        self.logView.writeString(string: isOpen ? "开启":"关闭")
                        self.logView.writeString(string: "提醒电量:\(remindBattery)")
                        self.logView.writeString(string: "提醒次数:\(remindCount)")
                        self.logView.writeString(string: "提醒间隔:\(remindInterval)")
                    }
                }
                
            }
            
            break
            
        case "0x15 设置低电提醒":
            
            let array = [
                "0:关，1:开",
                "提醒电量",
                "提醒次数",
                "提醒间隔",
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置洗手提醒", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let isOpen = textArray[0]
                let remindBattery = textArray[1]
                let remindCount = textArray[2]
                let remindInterval = textArray[3]
                
//                let model = AntLowBatteryModel.init()
//                model.isOpen = isOpen
//                model.remindBattery = remindBattery
//                model.remindCount = remindCount
//                model.remindInterval = remindInterval
//
//                AntCommandModule.shareInstance.setLowBatteryRemind(model: model) { error in
                AntCommandModule.shareInstance.setLowBatteryRemind(isOpen: isOpen, remindBattery: remindBattery, remindCount: remindCount, remindInterval: remindInterval) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setLowBatteryRemind -> success")
                    }
                }
            }
            
            break
            
        case "0x16 获取单个LED灯功能":
            
            let array = [
                "0:电量 1:信息 2:bt连接 3:计步达标 4:低电",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "获取单个LED灯功能")
            
            self.presentTextFieldAlertVC(title: "提示(默认0)", message: "获取单个LED灯功能", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = Int(textArray[0]) ?? 0
                                
                AntCommandModule.shareInstance.getLedSetup(type: AntLedFunctionType.init(rawValue: type) ?? .powerIndicator) { model, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        
                        if let model = model {
                            self.logView.writeString(string: "功能类型: \(model.ledType.rawValue)")
                            self.logView.writeString(string: "颜色: \(model.ledColor)")
                            self.logView.writeString(string: "97-100颜色: \(model.firstColor)")
                            self.logView.writeString(string: "21-74颜色: \(model.secondColor)")
                            self.logView.writeString(string: "0-20颜色: \(model.thirdColor)")
                            self.logView.writeString(string: "持续时长: \(model.timeLength)")
                            self.logView.writeString(string: "闪烁频次: \(model.frequency)\n\n")
                        }
                    }
                }
            }

            break
        case "0x17 设置单个LED灯功能":
            
            let array = [
                "参数类型 1:信息 2:bt连接 3:计步达标 4:低电",
                "颜色(0-15,bit0:红 bit1:绿 bit2:蓝 bit3:白)",
                "持续时间 0-50",
                "闪烁频次 0-5，0常亮",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "LED灯功能设置")
            self.presentTextFieldAlertVC(title: "提示(默认类型1其他0)", message: "LED灯功能设置(后续参数递增)", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let modelCount = Int(textArray[1]) ?? 1
                let colorType = Int(textArray[1]) ?? 0
                let timeLength = Int(textArray[2]) ?? 0
                let frequency = Int(textArray[3]) ?? 0
                
                let model = AntLedFunctionModel()
                model.ledType = AntLedFunctionType.init(rawValue: modelCount) ?? .informationReminder
                model.timeLength = timeLength
                model.frequency = frequency
                model.ledColor = colorType
                self.logView.writeString(string: "功能类型: \(model.ledType.rawValue)")
                self.logView.writeString(string: "颜色: \(model.ledColor)")
                self.logView.writeString(string: "持续时长: \(model.timeLength)")
                self.logView.writeString(string: "闪烁频次: \(model.frequency)\n\n")
                
                AntCommandModule.shareInstance.setLedSetup(model: model, success: { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setLedSetup ->","success")
                    }
                })
            }
            
            break

        case "0x19 设置单个LED灯电量显示":
            
            let array = [
                "75-100颜色(0-15,bit0:红 bit1:绿 bit2:蓝 bit3:白)",
                "21-74颜色(0-15,bit0:红 bit1:绿 bit2:蓝 bit3:白)",
                "0-20颜色(0-15,bit0:红 bit1:绿 bit2:蓝 bit3:白)",
                "持续时间 0-50",
                "闪烁频次 0-5，0常亮",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "LED灯功能设置")
            self.presentTextFieldAlertVC(title: "提示(默认类型1其他0)", message: "LED灯功能设置(后续参数递增)", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let firstColor = Int(textArray[0]) ?? 1
                let secondColor = Int(textArray[1]) ?? 0
                let thirdColor = Int(textArray[2]) ?? 0
                let timeLength = Int(textArray[3]) ?? 0
                let frequency = Int(textArray[4]) ?? 0
                
                let model = AntLedFunctionModel()
                model.ledType = .powerIndicator
                model.timeLength = timeLength
                model.frequency = frequency
                model.firstColor = firstColor
                model.secondColor = secondColor
                model.thirdColor = thirdColor

                self.logView.writeString(string: "功能类型: \(model.ledType.rawValue)")
                self.logView.writeString(string: "75-100颜色: \(model.firstColor)")
                self.logView.writeString(string: "21-74颜色: \(model.secondColor)")
                self.logView.writeString(string: "0-20颜色: \(model.thirdColor)")
                self.logView.writeString(string: "持续时长: \(model.timeLength)")
                self.logView.writeString(string: "闪烁频次: \(model.frequency)\n\n")
                
                AntCommandModule.shareInstance.setLedSetup(model: model, success: { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setLedSetup ->","success")
                    }
                })
            }
            
            break
        case "0x1A 获取马达震动功能":
            
            let array = [
                "0:电量 1:信息 2:bt连接 3:计步达标 4:低电",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "获取马达震动功能")
            
            self.presentTextFieldAlertVC(title: "提示(默认0)", message: "获取马达震动功能", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = Int(textArray[0]) ?? 0
                                
                AntCommandModule.shareInstance.getMotorShakeFunction(type: AntLedFunctionType.init(rawValue: type) ?? .powerIndicator) { model, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        if let model = model {
                            self.logView.writeString(string: "功能类型: \(model.ledType.rawValue)")
                            self.logView.writeString(string: "震动时长: \(model.timeLength)")
                            self.logView.writeString(string: "震动频次: \(model.frequency)")
                            self.logView.writeString(string: "震动强度: \(model.level)\n\n")
                        }
                    }
                }
            }
            
            break
        case "0x1B 设置马达震动功能":
            
            let array = [
                "参数类型 1:信息 2:bt连接 3:计步达标 4:低电",
                "震动时长 0-20",
                "震动频次 0-5 ,0长震",
                "震动强度 0-10",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "马达震动功能设置")
            self.presentTextFieldAlertVC(title: "提示(默认0)", message: "马达震动功能设置", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in

                let ledType = Int(textArray[1]) ?? 0
                let timeLength = Int(textArray[1]) ?? 0
                let frequency = Int(textArray[2]) ?? 0
                let level = Int(textArray[3]) ?? 0
                
                let model = AntMotorFunctionModel()
                model.ledType = AntLedFunctionType.init(rawValue: ledType) ?? .powerIndicator
                model.timeLength = timeLength
                model.frequency = frequency
                model.level = level
                self.logView.writeString(string: "功能类型: \(model.ledType.rawValue)")
                self.logView.writeString(string: "震动时长: \(model.timeLength)")
                self.logView.writeString(string: "震动频次: \(model.frequency)")
                self.logView.writeString(string: "震动强度: \(model.level)\n\n")
                
                AntCommandModule.shareInstance.setMotorShakeFunction(model: model) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setMotorShakeFunction ->","success")
                    }
                }
            }
            
            break
        case "0x00 同步计步数据":
            
            let array = [
                "同步类型",
                "同步天数",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "同步健康数据")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "同步计步数据", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let dayCount = textArray[1]
                
                AntCommandModule.shareInstance.setSyncHealthData(type: type, dayCount: dayCount) { success,error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        //print("SetSyncHealthData ->",success)
                        
                        if success is AntStepModel {
                            if let model:AntStepModel = success as? AntStepModel {
                                let detailArray = model.detailArray
                                let step = model.step
                                let calorie = model.calorie
                                let distance = model.distance
                                
                                print("detailArray ->",detailArray)
                                
                                self.logView.writeString(string: "详情步数:\(detailArray)")
                                self.logView.writeString(string: "总步数:\(step)")
                                self.logView.writeString(string: "总卡路里:\(calorie)")
                                self.logView.writeString(string: "总距离:\(distance)")
                            }
                        }
                        
                        if success is AntSleepModel {
                            if let model:AntSleepModel = success as? AntSleepModel {
                                let deep = model.deep
                                let awake = model.awake
                                let light = model.light
                                let detailArray = model.detailArray
                                print("deep ->",deep,"awake ->",awake,"light ->",light,"detailArray ->",detailArray)
                                
                                self.logView.writeString(string: "深睡时长:\(deep)")
                                self.logView.writeString(string: "浅睡时长:\(light)")
                                self.logView.writeString(string: "清醒时长:\(awake)")
                                self.logView.writeString(string: "详情睡眠:\(detailArray)")
                            }
                        }
                        
                        if success is AntHrModel {
                            if let model:AntHrModel = success as? AntHrModel {
                                let detailArray = model.detailArray
                                print("detailArray ->",detailArray)
                                
                                self.logView.writeString(string: "详情心率:\(detailArray)")
                            }
                        }
                        
                    }else{

                        var typeString = ""
                        if type == "1" {
                            typeString = "步数"
                        }else if type == "2" {
                            typeString = "心率"
                        }else if type == "3" {
                            typeString = "睡眠"
                        }
                        self.logView.writeString(string: "类型:\(typeString)")
                        self.logView.writeString(string: "第\(dayCount)天数据")
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            
            break
            
        case "0x01":
            
            break
            
        case "0x02 同步锻炼数据":
            
            let array = [
                //"同步类型",
                "同步序号",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "同步锻炼数据")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "同步锻炼数据", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                //let type = textArray[0]
                let indexCount = textArray[0]
                                
                AntCommandModule.shareInstance.setSyncExerciseData(indexCount: Int(indexCount) ?? 0) { success, error in
                    
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
                        
                        self.logView.writeString(string: "开始时间:\(startTime)")
                        self.logView.writeString(string: "类型:\(type.rawValue)")
                        self.logView.writeString(string: "心率:\(hr)")
                        self.logView.writeString(string: "运动时长:\(validTimeLength)")
                        self.logView.writeString(string: "步数:\(step)")
                        self.logView.writeString(string: "结束时间:\(endTime)")
                        self.logView.writeString(string: "卡路里:\(calorie)")
                        self.logView.writeString(string: "距离:\(distance)")
                    }

                }
                
            }
            
            break
            
        case "同步测量数据":
            let array = [
                "1：心率，2：血氧，3：血压，4：血糖，5：压力，6.体温，7：心电",
                "1：全天测量 ，2：点击测量",
                "第x天(条) 10以内输入不间隔",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "同步数据")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "同步计步数据", holderStringArray: array) {
                
            } okAction: { textArray in
                let dataType = textArray[0]
                let measureType = textArray[1]
                let dayCount = textArray[2]
                
                let dayNumber:String = dayCount.components(separatedBy: .decimalDigits.inverted).joined()
                var dayArray = [Int]()
                for i in dayNumber {
                    dayArray.append(Int(String(i)) ?? 0)
                }
                
                AntCommandModule.shareInstance.setSyncMeasurementData(dataType: Int(dataType) ?? 1, measureType: Int(measureType) ?? 1, indexArray: dayArray) { success,error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        
                        if let model:AntMeasurementModel = success as? AntMeasurementModel {
                            let type = model.type
                            let timeInterval = model.timeInterval
                            let listModelArray = model.listArray
                            
                            print("listModelArray ->",listModelArray)
                            self.logView.writeString(string: "类型:\(type.rawValue)")
                            self.logView.writeString(string: "间隔时长:\(timeInterval)")
                            for item in listModelArray {
                                let item:AntMeasurementValueModel = item
                                self.logView.writeString(string: "历史数据 时间:\(item.time) value1:\(item.value_1),value2:\(item.value_2)\n")
                            }
                        }
                        
                    }
                }
            }
            break
            
        case "0x85 同步数据":
            
            let array = [
                "1:步数 2:心率 3:睡眠 4:锻炼",
                "第x天(条) 10以内输入不间隔",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "同步数据")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "同步计步数据", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                let dayCount = textArray[1]
                
                let dayNumber:String = dayCount.components(separatedBy: .decimalDigits.inverted).joined()
                var dayArray = [Int]()
                for i in dayNumber {
                    dayArray.append(Int(String(i)) ?? 0)
                }
                print("dayArray = \(dayArray)")
                
                AntCommandModule.shareInstance.setNewSyncHealthData(type: Int(type) ?? 1, indexArray: dayArray) { success,error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        //print("SetSyncHealthData ->",success)
                        
                        if let successDic:[String:Any?] = success as? [String : Any?] {
                            
                            for key in successDic.keys {
                                
                                if let value = successDic[key] {
                                    
                                    if value is AntStepModel {
                                        if let model:AntStepModel = value as? AntStepModel {
                                            let detailArray = model.detailArray
                                            let step = model.step
                                            let calorie = model.calorie
                                            let distance = model.distance
                                            
                                            print("detailArray ->",detailArray)
                                            self.logView.writeString(string: "第\(key)天")
                                            self.logView.writeString(string: "详情步数:\(detailArray)")
                                            self.logView.writeString(string: "总步数:\(step)")
                                            self.logView.writeString(string: "总卡路里:\(calorie)")
                                            self.logView.writeString(string: "总距离:\(distance)\n")
                                        }
                                    }
                                    
                                    if value is AntSleepModel {
                                        if let model:AntSleepModel = value as? AntSleepModel {
                                            let deep = model.deep
                                            let awake = model.awake
                                            let light = model.light
                                            let detailArray = model.detailArray
                                            print("deep ->",deep,"awake ->",awake,"light ->",light,"detailArray ->",detailArray)
                                            self.logView.writeString(string: "第\(key)天")
                                            self.logView.writeString(string: "深睡时长:\(deep)")
                                            self.logView.writeString(string: "浅睡时长:\(light)")
                                            self.logView.writeString(string: "清醒时长:\(awake)")
                                            self.logView.writeString(string: "详情睡眠:\(detailArray)\n")
                                        }
                                    }
                                    
                                    if value is AntHrModel {
                                        if let model:AntHrModel = value as? AntHrModel {
                                            let detailArray = model.detailArray
                                            print("detailArray ->",detailArray)
                                            self.logView.writeString(string: "第\(key)天")
                                            self.logView.writeString(string: "详情心率:\(detailArray)\n")
                                        }
                                    }
                                    
                                    if value is AntExerciseModel {
                                        if let model:AntExerciseModel = value as? AntExerciseModel {
                                            let startTime = model.startTime
                                            let type = model.type
                                            let hr = model.heartrate
                                            let validTimeLength = model.validTimeLength
                                            let step = model.step
                                            let endTime = model.endTime
                                            let calorie = model.calorie
                                            let distance = model.distance
                                            self.logView.writeString(string: "第\(key)条")
                                            self.logView.writeString(string: "开始时间:\(startTime)")
                                            self.logView.writeString(string: "类型:\(type.rawValue)")
                                            self.logView.writeString(string: "心率:\(hr)")
                                            self.logView.writeString(string: "运动时长:\(validTimeLength)")
                                            self.logView.writeString(string: "步数:\(step)")
                                            self.logView.writeString(string: "结束时间:\(endTime)")
                                            self.logView.writeString(string: "卡路里:\(calorie)")
                                            self.logView.writeString(string: "距离:\(distance)\n")
                                            let gpsArray = model.gpsArray
                                            if gpsArray.count > 0 {
                                                var logArray = [String]()
                                                for locationArray in gpsArray {
                                                    for item in locationArray {
                                                        logArray.append("时间:\(item.timestamp.conversionDateToString(DateFormat: "yyyy-MM-dd HH:mm:ss")),latitude:\(item.coordinate.latitude),longitude:\(item.coordinate.longitude)")
                                                    }
                                                }
                                                self.logView.writeString(string: "距离:\(logArray)\n")
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
            
        case "0x83(4) 设置天气":
            
            let array = [
                "年",
                "月",
                "日",
                "时",
                "分",
                "秒",
                "总条数，后续的所有温度递增+1",
                "天气类型",
                "温度",
                "空气质量",
                "最低温度",
                "最高温度",
                "明日最低温度",
                "明日最高温度",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置天气")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置天气", holderStringArray: array, cancel: nil, cancelAction: {
                
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
                
                self.logView.writeString(string: "显示时间:\(time),时间戳:\(timestamp)")
                
                var modelArray = [AntWeatherModel]()
                
                for i in stride(from: 0, to: Int(dayCount) ?? 0, by: 1) {
                    self.logView.writeString(string: "第\(i)天")
                    self.logView.writeString(string: "天气类型:\(type)")
                    self.logView.writeString(string: "温度:\((Int(temp) ?? 0) + i)")
                    self.logView.writeString(string: "空气质量:\(airQuality)")
                    self.logView.writeString(string: "最低温度:\((Int(minTemp) ?? 0) + i)")
                    self.logView.writeString(string: "最高温度:\((Int(maxTemp) ?? 0) + i)")
                    self.logView.writeString(string: "明日最低温度:\((Int(tomorrowMinTemp) ?? 0) + i)")
                    self.logView.writeString(string: "明日最大温度:\((Int(tomorrowMaxTemp) ?? 0) + i)")
                    self.logView.writeString(string: "\n")
                    
                    let model = AntWeatherModel.init()
                    model.dayCount = i
                    model.type = AntWeatherType(rawValue:Int(type) ?? 0) ?? .sunny
                    model.temp = (Int(temp) ?? 0) + i
                    model.airQuality = Int(airQuality) ?? 0
                    model.minTemp = (Int(minTemp) ?? 0) + i
                    model.maxTemp = (Int(maxTemp) ?? 0) + i
                    model.tomorrowMinTemp = (Int(tomorrowMinTemp) ?? 0) + i
                    model.tomorrowMaxTemp = (Int(tomorrowMaxTemp) ?? 0) + i
                    
                    modelArray.append(model)
                }
                
                AntCommandModule.shareInstance.setNewWeather(modelArray: modelArray, updateTime: time) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))

                    if error == .none {
                        print("SetWeather ->","success")
                    }
                }
            }
            
            
            break
            
        case "0x83(5) 设置闹钟":
            
            let array = [
                "闹钟个数",
                "重复",
                "开始小时",
                "开始分钟"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置闹钟")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置闹钟", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let totalCount = textArray[0]
                let repeatCount = textArray[1]
                let hour = textArray[2]
                let minute = textArray[3]
                
                var alarmArray = [AntAlarmModel]()
                
                for i in stride(from: 0, to: Int(totalCount) ?? 0, by: 1) {
                    let dic = ["repeatCount": "\(repeatCount)", "hour": "\(hour)", "index": "\(i)", "minute": "\(minute)"]
                    let alarmModel = AntAlarmModel.init(dic: dic)
                    
                    self.logView.writeString(string: "闹钟序号:\(i)")
                    self.logView.writeString(string: "闹钟时间:\(String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute))")
                    self.logView.writeString(string: "repeatCount:\(repeatCount)")
                    self.logView.writeString(string: "闹钟开关:\(alarmModel.alarmOpen)")
                    if alarmModel.alarmOpen {
                        self.logView.writeString(string: "闹钟重复类型:\(alarmModel.alarmType == .single ? "单次闹钟":"重复闹钟")")
                        if alarmModel.alarmType == .cycle {
                            if alarmModel.alarmRepeatArray != nil {
                                let str = ((alarmModel.alarmRepeatArray![0] != 0 ? "星期天":"")+(alarmModel.alarmRepeatArray![1] != 0 ? "星期一":"")+(alarmModel.alarmRepeatArray![2] != 0 ? "星期二":"")+(alarmModel.alarmRepeatArray![3] != 0 ? "星期三":"")+(alarmModel.alarmRepeatArray![4] != 0 ? "星期四":"")+(alarmModel.alarmRepeatArray![5] != 0 ? "星期五":"")+(alarmModel.alarmRepeatArray![6] != 0 ? "星期六":""))
                                self.logView.writeString(string: "闹钟重复星期:\(str)")
                            }else{
                                self.logView.writeString(string: "闹钟重复星期:重复星期未开启,默认单次闹钟")
                            }
                        }
                    }
                    self.logView.writeString(string: "\n")
                    alarmArray.append(alarmModel)
                    print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",String.init(format: "%02d:%02d", alarmModel.alarmHour,alarmModel.alarmMinute),"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)
                }
                
                AntCommandModule.shareInstance.setNewAlarmArray(modelArray: alarmArray) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetAlarm ->","success")
                    }
                }
                
            }
            
            break
            
        case "0x84(5) 获取闹钟":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取闹钟")
            
            AntCommandModule.shareInstance.getNewAlarmArray { alarmArray, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetAlarm ->",alarmArray)

                    for alarm in alarmArray {
                        let alarmModel = alarm
                        //print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",alarmModel.alarmTime,"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)

                        self.logView.writeString(string: "闹钟序号:\(alarmModel.alarmIndex)")
                        self.logView.writeString(string: "闹钟时间:\(alarmModel.alarmHour):\(alarmModel.alarmMinute)")
                        self.logView.writeString(string: "repeatCount:\(alarmModel.alarmRepeatCount)")
                        self.logView.writeString(string: "闹钟开关:\(alarmModel.alarmOpen)")
                        if alarmModel.alarmOpen {
                            self.logView.writeString(string: "闹钟重复类型:\(alarmModel.alarmType == .single ? "单次闹钟":"重复闹钟")")
                            if alarmModel.alarmType == .cycle {
                                if alarmModel.alarmRepeatArray != nil {
                                    let str = ((alarmModel.alarmRepeatArray![0] != 0 ? "星期天":"")+(alarmModel.alarmRepeatArray![1] != 0 ? "星期一":"")+(alarmModel.alarmRepeatArray![2] != 0 ? "星期二":"")+(alarmModel.alarmRepeatArray![3] != 0 ? "星期三":"")+(alarmModel.alarmRepeatArray![4] != 0 ? "星期四":"")+(alarmModel.alarmRepeatArray![5] != 0 ? "星期五":"")+(alarmModel.alarmRepeatArray![6] != 0 ? "星期六":""))
                                    self.logView.writeString(string: "闹钟重复星期:\(str)")
                                }else{
                                    self.logView.writeString(string: "闹钟重复星期:重复星期未开启,默认单次闹钟")
                                }
                            }
                        }
                        self.logView.writeString(string: "\n")
                    }
                }
            }
            
            break
            
        case "0x83(0x19) 设置睡眠目标":
            
            let array = [
                "睡眠目标(分钟)",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "设置睡眠目标")
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置睡眠目标", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let targetCount = Int(textArray[0]) ?? 0
                
                AntCommandModule.shareInstance.setSleepGoal(target: targetCount) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setSleepGoal ->","success")
                    }
                }                
            }
            
            break
            
        case "0x84(0x19) 获取睡眠目标":
            self.logView.clearString()
            self.logView.writeString(string: "获取睡眠目标")
            
            AntCommandModule.shareInstance.getSleepGoal { targetCount, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    
                    self.logView.writeString(string: "睡眠目标(分钟):\(targetCount)   \(targetCount/60):\(targetCount%60)")
                    
                }
            }
            
            break
            
        case "0x83(0x1a) 设置SOS联系人":

            let array = [
                "姓名",
                "号码",
            ]

            self.logView.clearString()
            self.logView.writeString(string: "设置SOS联系人")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认为空)", message: "设置联系人", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let model = AntAddressBookModel.init()
                model.name = textArray[0]
                model.phoneNumber = textArray[1]
                
                self.logView.writeString(string: "联系人 姓名:\(model.name),号码:\(model.phoneNumber)")
                
                AntCommandModule.shareInstance.setSosContactPerson(model: model) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        print("setSosContactPerson -> success")
                    }
                }
            }
            break
            
        case "0x84(0x1a) 获取SOS联系人":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取SOS联系人")
            
            AntCommandModule.shareInstance.getSosContactPerson { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if let model = model {
                    self.logView.writeString(string: "联系人 姓名:\(model.name),号码:\(model.phoneNumber)")
                    print("getSosContactPerson -> success")
                }
            }
            
            break
            
        case "0x83(0x1b) 周期测量参数设置":
            
            let array = [
                "类型：1：心率，2：血氧，3：血压，4：血糖，5：压力，6.体温，7：心电，",
                "开关：0：关 1：开",
                "时长：>0"
            ]

            self.logView.clearString()
            self.logView.writeString(string: "设置周期测量参数")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认为空)", message: "设置周期测量参数", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let type = textArray[0]
                let isOpen = textArray[1]
                let timeInterval = textArray[2]
                
                self.logView.writeString(string: "类型:\(type),开关:\(isOpen),时长:\(timeInterval)")
                
                AntCommandModule.shareInstance.setCycleMeasurementParameters(type: Int(type) ?? 0, isOpen: Int(isOpen) ?? 0, timeInterval: Int(timeInterval) ?? 0) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        print("setCycleMeasurementParameters -> success")
                    }
                }
            }
            
            break
        case "0x84(0x1d) 获取朝拜闹钟天数及开始时间":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取朝拜闹钟天数及开始时间")
            
            AntCommandModule.shareInstance.getWorshipStartTime { timeString, dayCount, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                self.logView.writeString(string: "朝拜闹钟 天数:\(dayCount),开始日期:\(timeString)")
                print("getWorshipStartTime -> timeString = \(timeString),dayCount = \(dayCount)")
            }
            
            break
            
        case "0x83(0x0f) 设置时区":
            
            let array = [
                "0:零时区 1-12:东区 13-24:西区",
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认为手机系统时区)", message: "设置时区", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let timeZone = textArray[0]
                self.logView.writeString(string: "设置时区: \(timeZone)")
                            
                AntCommandModule.shareInstance.setTimeZone(timeZone:  Int(timeZone) ?? 0) { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        print("setTimeZone -> success")
                    }
                }
            }
            
            break
            
        case "无响应 回应定位信息":
            
            let array = [
                "纬度:xxx.xxxxxx",
                "经度:xxx.xxxxxx",
                "方向:xxx",
                "速度:xx.xx"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认为0)", message: "设置定位信息", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                
                let latitude = Double(textArray[0]) ?? 0.0
                let longitude = Double(textArray[1]) ?? 0.0
                let course = Double(textArray[2]) ?? 0.0
                let speed = Double(textArray[3]) ?? 0.0
                
                self.logView.writeString(string: "纬度: \(latitude)")
                self.logView.writeString(string: "经度: \(longitude)")
                self.logView.writeString(string: "方向: \(course)")
                self.logView.writeString(string: "速度: \(speed)")
                
                let location = CLLocation.init(coordinate: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude), altitude: 0, horizontalAccuracy: CLLocationAccuracy(), verticalAccuracy: CLLocationAccuracy(), course: course, speed: speed, timestamp: Date())

                AntCommandModule.shareInstance.setLocationInfo(localtion: location)
                
            }
            
            break
            
        case "0x83(0x1e) 设置LED灯功能":
            
            let array = [
                "参数数组(设置类型输入不间隔) 0:电量 1:信息 2:bt连接 3:计步达标 4:低电",
                "颜色(0-15,bit0:红 bit1:绿 bit2:蓝 bit3:白)",
                "持续时间 0-50",
                "闪烁频次 0-5，0常亮",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "LED灯功能设置")
            self.presentTextFieldAlertVC(title: "提示(参数个数默认1其他默认0)", message: "LED灯功能设置(后续参数递增)", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let modelCount = textArray[0]
                let colorType = Int(textArray[1]) ?? 0
                let timeLength = Int(textArray[2]) ?? 0
                let frequency = Int(textArray[3]) ?? 0
                                
                let dayNumber:String = modelCount.components(separatedBy: .decimalDigits.inverted).joined()
                var dayArray = [Int]()
                for i in dayNumber {
                    dayArray.append(Int(String(i)) ?? 0)
                }
                print("dayArray = \(dayArray)")
                
                var modelArray = [AntLedFunctionModel]()
                for i in dayArray {
                    let model = AntLedFunctionModel()
                    model.ledType = AntLedFunctionType.init(rawValue: i) ?? .powerIndicator
                    model.timeLength = timeLength
                    model.frequency = frequency
                    model.ledColor = colorType
                    modelArray.append(model)
                    self.logView.writeString(string: "功能类型: \(model.ledType.rawValue)")
                    self.logView.writeString(string: "颜色: \(model.ledColor)")
                    self.logView.writeString(string: "持续时长: \(model.timeLength)")
                    self.logView.writeString(string: "闪烁频次: \(model.frequency)\n\n")
                }
                
                AntCommandModule.shareInstance.setLedSetup(modelArray: modelArray) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setLedSetup ->","success")
                    }
                }
            }
            
            break
        case "0x83(0x1f) 设置马达震动功能":
            
            let array = [
                "参数数组(设置类型输入不间隔) 0:电量 1:信息 2:bt连接 3:计步达标 4:低电",
                "震动时长 0-20",
                "震动频次 0-5 ,0长震",
                "震动强度 0-10",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "马达震动功能设置")
            self.presentTextFieldAlertVC(title: "提示(参数个数默认1其他默认0)", message: "马达震动功能设置(后续参数递增)", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in

                let modelCount = textArray[0]
                let timeLength = Int(textArray[1]) ?? 0
                let frequency = Int(textArray[2]) ?? 0
                let level = Int(textArray[3]) ?? 0
                
                let dayNumber:String = modelCount.components(separatedBy: .decimalDigits.inverted).joined()
                var dayArray = [Int]()
                for i in dayNumber {
                    dayArray.append(Int(String(i)) ?? 0)
                }
                print("dayArray = \(dayArray)")
                
                var modelArray = [AntMotorFunctionModel]()
                for i in dayArray {
                    let model = AntMotorFunctionModel()
                    model.ledType = AntLedFunctionType.init(rawValue: i) ?? .powerIndicator
                    model.timeLength = timeLength
                    model.frequency = frequency
                    model.level = level
                    modelArray.append(model)
                    self.logView.writeString(string: "功能类型: \(model.ledType.rawValue)")
                    self.logView.writeString(string: "震动时长: \(model.timeLength)")
                    self.logView.writeString(string: "震动频次: \(model.frequency)")
                    self.logView.writeString(string: "震动强度: \(model.level)\n\n")
                }
                
                AntCommandModule.shareInstance.setMotorShakeFunction(modelArray: modelArray, success: { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("setMotorShakeFunction ->","success")
                    }
                })
            }
            
            break
            
        case "0x84(0x1e) 获取LED灯功能":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取LED灯功能")
            AntCommandModule.shareInstance.getLedSetup { modelArray, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    for model in modelArray {
                        
                        self.logView.writeString(string: "功能类型: \(model.ledType.rawValue)")
                        self.logView.writeString(string: "颜色: \(model.ledColor)")
                        self.logView.writeString(string: "持续时长: \(model.timeLength)")
                        self.logView.writeString(string: "闪烁频次: \(model.frequency)\n\n")
                        
                    }
                }
            }
            
            break
        case "0x84(0x1f) 获取马达震动功能":
            self.logView.clearString()
            self.logView.writeString(string: "获取马达震动功能")
            AntCommandModule.shareInstance.getMotorShakeFunction { modelArray, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    for model in modelArray {
                        
                        self.logView.writeString(string: "功能类型: \(model.ledType.rawValue)")
                        self.logView.writeString(string: "震动时长: \(model.timeLength)")
                        self.logView.writeString(string: "震动频次: \(model.frequency)")
                        self.logView.writeString(string: "震动强度: \(model.level)\n\n")
                        
                    }
                }
            }
            
            break
        case "0x00 ":
            
            
            break
            
        case "0x01 关机":
            
            self.logView.clearString()
            self.logView.writeString(string: "关机")
            
            AntCommandModule.shareInstance.setPowerTurnOff { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetPowerTurnOff ->","success")
                }
                
            }
            
            break
            
        case "0x02 ":
            
            break
            
        case "0x03 恢复出厂设置":
            
            self.logView.clearString()
            self.logView.writeString(string: "恢复出厂设置")
            
            AntCommandModule.shareInstance.setFactoryDataReset { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetFactoryDataReset ->","success")
                }
            }
            
            break
            
        case "0x04":
            
            break
            
        case "0x05 马达震动":
            
            let array = [
                "0:停止，1:单次震动，2:间歇震动三次，3:连续震动"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: "马达震动")
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "马达震动", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let type = textArray[0]
                var str = "未知状态"
                if type == "0" || type.count <= 0 {
                    str = "停止"
                } else if type == "1" {
                    str = "单次震动"
                }else if type == "2" {
                    str = "间歇震动三次"
                }else if type == "3" {
                    str = "连续震动"
                }
                self.logView.writeString(string: "类型:\(str)")
                
                AntCommandModule.shareInstance.setMotorVibration(type: type) { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("SetMotorVibration ->","success")
                    }
                }
            }
            
            break
        case "0x07 重新启动":
            self.logView.clearString()
            self.logView.writeString(string: "重新启动")
            
            AntCommandModule.shareInstance.setRestart { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetFactoryDataReset ->","success")
                }
            }
            break
        case "恢复出厂并关机":
            self.logView.clearString()
            self.logView.writeString(string: "重新启动")
            
            AntCommandModule.shareInstance.setFactoryAndPowerOff { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("SetFactoryDataReset ->","success")
                }
            }
            break
        case "0x80 实时步数":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportRealTimeStep { success, error in
                //self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if self.logView.isHidden {
                        return
                    }
                    
                    if let model = success {
                        let step = model.step
                        let distance = model.distance
                        let calorie = model.calorie
                        self.logView.writeString(string: "步数:\(step)")
                        self.logView.writeString(string: "距离:\(distance)")
                        self.logView.writeString(string: "卡路里:\(calorie)")
                    }
                    
                }
            }
            break
            
        case "0x82 实时心率":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
                        
            AntCommandModule.shareInstance.reportRealTimeHr { success, error in
                //self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    let hr = success["hr"] as! String
                    self.logView.writeString(string: "心率:\(hr)")
                }
            }
            break
        case "0x84 单次测量结果":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
                        
            AntCommandModule.shareInstance.reportSingleMeasurementResult { success, error in
                //self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    let type = success["type"] as! String
                    var str = "未知类型"
                    if type == "0" {
                        str = "心率"
                    }else if type == "1" {
                        str = "血压"
                    }else if type == "2" {
                        str = "血氧"
                    }
                    let value1 = success["value1"] as! String
                    let value2 = success["value2"] as! String
                    self.logView.writeString(string: "类型:\(str)")
                    self.logView.writeString(string: "测量值1:\(value1)")
                    self.logView.writeString(string: "测量值2:\(value2)")
                }
            }
            break
        case "0x86 锻炼状态":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportExerciseState { state ,error in

                if error == .none {
                    var stateString = ""
                    if state == .unknow {
                        stateString = "不支持状态"
                    }else if state == .end {
                        stateString = "结束"
                    }else if state == .start {
                        stateString = "开始"
                    }else if state == .pause {
                        stateString = "暂停"
                    }else if state == .continue {
                        stateString = "继续"
                    }
                    self.logView.writeString(string: "上报锻炼状态:\(stateString)")
                }
            }
            break
        case "0x88 找手机":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportFindPhone { error in
                if error == .none {
                    self.logView.writeString(string: "找手机")
                }
            }
            break
        case "0x89 结束找手机":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportEndFindPhone { error in
                if error == .none {
                    self.logView.writeString(string: "结束找手机")
                }
            }
            break
        case "0x8a 拍照":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportTakePictures { error in
                if error == .none {
                    self.logView.writeString(string: "拍照")
                }
            }
            break
        case "0x8c 音乐控制":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportMusicControl { success, error in
                
                if error == .none {
                    let type = success
                    var str = "未知类型"
                    if type == 0 {
                        str = "暂停"
                    }else if type == 1 {
                        str = "播放"
                    }else if type == 2 {
                        str = "上一曲"
                    }else if type == 3 {
                        str = "下一曲"
                    }
                    self.logView.writeString(string: "类型:\(str)")
                }
            }
            break
            
        case "0x8e 来电控制":
            
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportCallControl { success, error in
                if error == .none {
                    let type = success
                    var str = "未知类型"
                    if type == 0 {
                        str = "挂断"
                    }else if type == 1 {
                        str = "接听"
                    }
                    self.logView.writeString(string: "类型:\(str)")
                }
            }
            
            break
            
        case "上报屏幕亮度":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportScreenLevel { success, error in
                if error == .none {
                    let level = success
                    self.logView.writeString(string: "屏幕亮度:\(level)")
                }
            }
            
            break
            
        case "上报亮屏时长":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportScreenTimeLong { success, error in
                if error == .none {
                    let timeLong = success
                    self.logView.writeString(string: "屏幕时长:\(timeLong)")
                }
            }
            
            break
            
        case "上报抬腕亮屏":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportLightScreen { success, error in
                if error == .none {
                    let isOpen = success
                    self.logView.writeString(string: "抬腕亮屏 开关:\(isOpen == 0 ? "关":"开")")
                }
            }
            
            break
            
        case "上报设备振动":
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportDeviceVibration { success, error in
                if error == .none {
                    let isOpen = success
                    self.logView.writeString(string: "设备振动 开关:\(isOpen == 0 ? "关":"开")")
                }
            }
            break
            
        case "上报实时数据":
            
            self.logView.clearString()
            self.logView.writeString(string: "设备端点击显示")
            
            AntCommandModule.shareInstance.reportNewRealtimeData { stepModel, hr, bo, sbp, dbp, error in
                if error == .none {
                    if let model:AntStepModel = stepModel as? AntStepModel {
                        let step = model.step
                        let calorie = model.calorie
                        let distance = model.distance
                        
                        self.logView.writeString(string: "总步数:\(step)")
                        self.logView.writeString(string: "总卡路里:\(calorie)")
                        self.logView.writeString(string: "总距离:\(distance)")
                    }
                    self.logView.writeString(string: "心率:\(hr)")
                    self.logView.writeString(string: "血氧:\(bo)")
                    self.logView.writeString(string: "血压:\(sbp)/\(dbp)")
                }
            }
            
            break
            
        case "上报运动交互数据":
            
            self.logView.clearString()
            self.logView.writeString(string: "上报运动交互数据")
            
            AntCommandModule.shareInstance.reportExerciseInteractionData { timestamp, step, hr, error in
                if error == .none {
                    self.logView.writeString(string: "时间戳:\(timestamp)")
                    self.logView.writeString(string: "总步数:\(step)")
                    self.logView.writeString(string: "心率:\(hr)\n")
                }
            }
            
            break
            
        case "上报进入或退出拍照模式":
            
            self.logView.clearString()
            self.logView.writeString(string: "上报进入或退出拍照模式")
            
            AntCommandModule.shareInstance.reportEnterOrExitCamera { result, error in
                if error == .none {
                    self.logView.writeString(string: "\(result == 0 ? "进入":"退出")拍照模式")
                }
            }
            
            break
            
        case "上报勿扰设置":
            
            self.logView.clearString()
            self.logView.writeString(string: "上报勿扰设置")
            
            AntCommandModule.shareInstance.reportDoNotDisturb { model, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                if error == .none {
                    if let model = model {
                        let isOpen = model.isOpen
                        let startHour = model.timeModel.startHour
                        let startMinute = model.timeModel.startMinute
                        let endHour = model.timeModel.endHour
                        let endMinute = model.timeModel.endMinute
                        
                        self.logView.writeString(string: isOpen ? "开启":"关闭")
                        self.logView.writeString(string: "开始时间:\(startHour):\(startMinute)")
                        self.logView.writeString(string: "结束时间:\(endHour):\(endMinute)")
                    }
                }
            }
            
            break
        case "上报朝拜闹钟天数及开始时间":
            
            self.logView.clearString()
            self.logView.writeString(string: "上报勿扰设置")
            
            AntCommandModule.shareInstance.reportWorshipStartTime { timeString, dayCount, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                self.logView.writeString(string: "朝拜闹钟 天数:\(dayCount),开始日期:\(timeString)")
                print("reportWorshipStartTime -> timeString = \(timeString),dayCount = \(dayCount)")
            }
            
            break
        case "上报请求定位信息":
            
            self.logView.clearString()
            self.logView.writeString(string: "设备端触发显示")
            
            AntCommandModule.shareInstance.reportLocationInfo { error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                self.logView.writeString(string: "上报请求定位信息")
                print("reportLocationInfo")
            }
            
            break
        case "上报闹钟":
            
            self.logView.clearString()
            self.logView.writeString(string: "设备端触发显示")
            
            AntCommandModule.shareInstance.reportAlarmArray { alarmArray, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    print("GetAlarm ->",alarmArray)

                    for alarm in alarmArray {
                        let alarmModel = alarm
                        //print("alarmModel",alarmModel.alarmIndex,"alarmOpen ->",alarmModel.alarmOpen,"alarmTime ->",alarmModel.alarmTime,"alarmType ->",alarmModel.alarmType.rawValue,"alarmRepeat ->",alarmModel.alarmRepeatArray)

                        self.logView.writeString(string: "闹钟序号:\(alarmModel.alarmIndex)")
                        self.logView.writeString(string: "闹钟时间:\(alarmModel.alarmHour):\(alarmModel.alarmMinute)")
                        self.logView.writeString(string: "repeatCount:\(alarmModel.alarmRepeatCount)")
                        self.logView.writeString(string: "闹钟开关:\(alarmModel.alarmOpen)")
                        if alarmModel.alarmOpen {
                            self.logView.writeString(string: "闹钟重复类型:\(alarmModel.alarmType == .single ? "单次闹钟":"重复闹钟")")
                            if alarmModel.alarmType == .cycle {
                                if alarmModel.alarmRepeatArray != nil {
                                    let str = ((alarmModel.alarmRepeatArray![0] != 0 ? "星期天":"")+(alarmModel.alarmRepeatArray![1] != 0 ? "星期一":"")+(alarmModel.alarmRepeatArray![2] != 0 ? "星期二":"")+(alarmModel.alarmRepeatArray![3] != 0 ? "星期三":"")+(alarmModel.alarmRepeatArray![4] != 0 ? "星期四":"")+(alarmModel.alarmRepeatArray![5] != 0 ? "星期五":"")+(alarmModel.alarmRepeatArray![6] != 0 ? "星期六":""))
                                    self.logView.writeString(string: "闹钟重复星期:\(str)")
                                }else{
                                    self.logView.writeString(string: "闹钟重复星期:重复星期未开启,默认单次闹钟")
                                }
                            }
                        }
                        self.logView.writeString(string: "\n")
                    }
                }
            }
            
            break
        case "多包测试命令":
            
            let array = [
                "数据总长度 默认1000",
                "分包发送长度 默认20",
                "CMD_CLASS 默认0x80",
                "CMD_ID 默认0"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "多包测试命令", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let totalLength = textArray[0]
                let subpackageLength = textArray[1]
                let cmdClass = textArray[2]
                let cmdId = textArray[3]
                
                AntCommandModule.shareInstance.testMultiplePackages(cmdClass: Int(cmdClass) ?? 0x80, cmdId: Int(cmdId) ?? 0, totalLength: Int(totalLength) ?? 1000, subpackageLength:  Int(subpackageLength) ?? 20)
                
            }
            
            
            break
            
        case "多包UTF8字符串测试命令":
            
            let array = [
                "输入字符串,默认'你好'",
                "CMD_CLASS 默认0x02",
                "CMD_ID 默认0x11",
                "type 默认1"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "多包UTF8字符串测试命令", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let sendString = textArray[0]
                let cmdClass = textArray[1]
                let cmdId = textArray[2]
                let type = textArray[3]
                
                AntCommandModule.shareInstance.testUtf8StringData(cmdClass: Int(cmdClass) ?? 0x02, cmdId: Int(cmdId) ?? 0x11,type: type, sendString: sendString.count <= 0 ? "你好":sendString)
                
            }
            
            break
            
        case "多包Unicode字符串测命令":
            let array = [
                "输入字符串,默认'你好'",
                "CMD_CLASS 默认0x02",
                "CMD_ID 默认0x11",
                "type 默认1"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "多包Unicode字符串测命令", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let sendString = textArray[0]
                let cmdClass = textArray[1]
                let cmdId = textArray[2]
                let type = textArray[3]
                
                AntCommandModule.shareInstance.testUnicodeStringData(cmdClass: Int(cmdClass) ?? 0x02, cmdId: Int(cmdId) ?? 0x11,type: type, sendString: sendString.count <= 0 ? "你好":sendString)
                
            }
            break
            
        case "0引导文件":
            
            let fileString = UserDefaults.standard.string(forKey: "0_BootFiles")
            
            var message = "未选择，默认项目内置工程文件路径"
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: "当前引导文件路径", message: message, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: "引导文件路径")
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "0_BootFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "0_BootFiles")
                        self.logView.writeString(string: "未选择，默认项目内置工程文件路径")
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: "确定") {
                                
            }
            
            break
        
        case "1应用文件":
            
            let fileString = UserDefaults.standard.string(forKey: "1_ApplicationFiles")
            
            var message = "未选择，默认项目内置工程文件路径"
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: "当前应用文件路径", message: message, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: "应用文件路径")
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "1_ApplicationFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "1_ApplicationFiles")
                        self.logView.writeString(string: "未选择，默认项目内置工程文件路径")
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: "确定") {
                                
            }
            
            break
            
        case "2图库文件":
            
            let fileString = UserDefaults.standard.string(forKey: "2_LibraryFiles")
            
            var message = "未选择，默认项目内置工程文件路径"
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: "当前图库文件路径", message: message, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: "图库文件路径")
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "2_LibraryFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "2_LibraryFiles")
                        self.logView.writeString(string: "未选择，默认项目内置工程文件路径")
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: "确定") {
                                
            }
            
            break
            
        case "3字库文件":
            
            let fileString = UserDefaults.standard.string(forKey: "3_FontFiles")
            
            var message = "未选择，默认项目内置工程文件路径"
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: "当前字库文件路径", message: message, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: "字库文件路径")
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "3_FontFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "3_FontFiles")
                        self.logView.writeString(string: "未选择，默认项目内置工程文件路径")
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: "确定") {
                                
            }
            
            break
        
        case "4表盘文件":
            
            let fileString = UserDefaults.standard.string(forKey: "4_DialFiles")
            
            var message = "未选择，默认项目内置工程文件路径"
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: "当前表盘文件路径", message: message, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: "表盘文件路径")
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "4_DialFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "4_DialFiles")
                        self.logView.writeString(string: "未选择，默认项目内置工程文件路径")
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: "确定") {
                                
            }
            
            break
            
        case "5自定义表盘文件":
            
            let fileString = UserDefaults.standard.string(forKey: "5_CustonDialFiles")
            
            var message = "未选择，默认项目内置工程文件路径"
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: "当前自定义表盘文件路径", message: message, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    self.logView.writeString(string: "自定义表盘文件路径")
                    if pathString.count > 0 {
                        UserDefaults.standard.setValue(pathString, forKey: "5_CustonDialFiles")
                        self.logView.writeString(string: pathString)
                    }else{
                        UserDefaults.standard.removeObject(forKey: "5_CustonDialFiles")
                        self.logView.writeString(string: "未选择，默认项目内置工程文件路径")
                    }
                    UserDefaults.standard.synchronize()
                }
                
            }, ok: "确定") {
                                
            }
            
            break
            
        case "7音乐文件":
            
            let fileString = UserDefaults.standard.string(forKey: "7_MusicFiles")
            
            var message = "未选择，默认项目内置工程文件路径"
            if fileString?.count ?? 0 > 0 {
                message = fileString!
            }
            
            self.logView.clearString()
            
            self.presentSystemAlertVC(title: "当前音乐文件路径", message: message, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"
                //let exist = FileManager.default.fileExists(atPath: path)
                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    
                    if let fileName = URL.init(string: pathString)?.lastPathComponent {
                        print("fileName = \(fileName)")
                        var isSupport = false
                        var supportString = "功能列表获取支持的音乐文件类型"
                        if let musicTypeModel = AntCommandModule.shareInstance.functionListModel?.functionDetail_localPlay {
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
                            self.logView.writeString(string: "音乐文件路径")
                            if pathString.count > 0 {
                                UserDefaults.standard.setValue(pathString, forKey: "7_MusicFiles")
                                self.logView.writeString(string: pathString)
                            }else{
                                UserDefaults.standard.removeObject(forKey: "7_MusicFiles")
                                self.logView.writeString(string: "未选择，默认项目内置工程文件路径")
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
                        self.logView.writeString(string: "音乐文件路径")
                        if pathString.count > 0 {
                            UserDefaults.standard.setValue(pathString, forKey: "7_MusicFiles")
                            self.logView.writeString(string: pathString)
                        }else{
                            UserDefaults.standard.removeObject(forKey: "7_MusicFiles")
                            self.logView.writeString(string: "未选择，默认项目内置工程文件路径")
                        }
                        UserDefaults.standard.synchronize()
                    }
                }
                
            }, ok: "确定") {
                                
            }
            
            break
        case "OTA升级":
            
            let array = [
                "文件类型：默认0-引导文件",
            ]
            
            self.logView.clearString()
            self.presentTextFieldAlertVC(title: "OTA升级(无效类型默认0)", message: "请确定文件路径选择正确，错误或无效数据可能导致闪退", holderStringArray: array, cancel: "取消", cancelAction: {
                
            }, ok: "确定") { textArray in
                
                let type = textArray[0]
                
                let fileString = self.getFilePathWithType(type: type)
                
                self.logView.writeString(string: "当前选择类型:\(type)")
                self.logView.writeString(string: "文件路径:\(fileString as! String)")
                
                print("fileString =",fileString)
                var showProgress = 0
                AntCommandModule.shareInstance.setOtaStartUpgrade(type: Int(type) ?? 0, localFile: fileString, isContinue: false) { progress in

                    if showProgress == Int(progress) {
                        showProgress += 1
                        self.logView.writeString(string: "进度:\(progress)")
                    }
                    print("progress ->",progress)

                } success: { error in

                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    print("setStartUpgrade -> error =",error.rawValue)

                }
                
            }
            
            break
            
        case "0x00 分包信息交互(APP)":
            
            let array = [
                "最大发送长度:默认1024",
                "最大接收长度:默认1024"
            ]
            
            self.logView.clearString()
            
            self.presentTextFieldAlertVC(title: "提示(不输入或无效数据为默认1024)", message: "分包信息交互", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { textArray in
                
                let maxSend = textArray[0]
                let maxReceive = textArray[1]
                
                self.logView.writeString(string: "APP -> maxSend:\(maxSend)")
                self.logView.writeString(string: "APP -> maxReceive:\(maxReceive)")
                
                AntCommandModule.shareInstance.setSubpackageInformationInteraction(maxSend: Int(maxSend) ?? 1024, maxReceive: Int(maxReceive) ?? 1024) { success,error in
                    print("SetSubpackageInformationInteraction -> error =",error)
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        
                        let maxSend = success["maxSend"] as! String
                        let maxReceive = success["maxReceive"] as! String
                        
                        self.logView.writeString(string: "设备 -> maxSend:\(maxSend)")
                        self.logView.writeString(string: "设备 -> maxReceive:\(maxReceive)")
                        
                        print("maxSend =",maxSend)
                        print("maxReceive =",maxReceive)
                        
                    }
                    
                }
                                
            }
            

            
            break
            
        case "0x02 启动升级":
            
            let array = [
                "文件类型:默认0-引导文件",
                "单包最大字节:默认20"
            ]
            
            self.logView.clearString()
            self.presentTextFieldAlertVC(title: "启动升级", message: "请确定文件路径选择正确，错误或无效数据可能导致闪退", holderStringArray: array, cancel: "取消", cancelAction: {
                
            }, ok: "确定") { textArray in
                
                let type = textArray[0]
                let maxCount = textArray[1]
                
                let fileString = self.getFilePathWithType(type: type)
                                
                self.logView.writeString(string: "当前选择类型:\(type)")
                self.logView.writeString(string: "文件路径:\(fileString)")
                self.logView.writeString(string: "单包最大字节数:\(maxCount)")
                var showProgress = 0
                AntCommandModule.shareInstance.setStartUpgrade(type: Int(type) ?? 0, localFile: fileString, maxCount: Int(maxCount) ?? 20, isContinue: false) { progress in
                    
                    print("progress =",progress)
                    if showProgress == Int(progress) {
                        showProgress += 1
                        self.logView.writeString(string: "进度:\(progress)")
                    }
                    
                } success: { error in
                    
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    print("setStartUpgrade -> error =",error.rawValue)
                    
                }
                
                //Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.test123(timer:)), userInfo: nil, repeats: true)
                
                
            }
            
            break
            
        case "0x03 停止升级":
            
            AntCommandModule.shareInstance.setStopUpgrade { error in
                print("setStopUpgrade -> error =",error)
            }
            
            break

        case "0引导升级":
            
            let fileString = self.getFilePathWithType(type: "0")
            
            self.logView.writeString(string: "当前选择类型:0引导升级")
            self.logView.writeString(string: "文件路径:\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            AntCommandModule.shareInstance.setOtaStartUpgrade(type: 0, localFile: fileString, isContinue: false) { progress in

                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "进度:\(progress)")
                }
                print("progress ->",progress)

            } success: { error in

                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }
            
            break
            
        case "1应用升级":
            let fileString = self.getFilePathWithType(type: "1")
            
            self.logView.writeString(string: "当前选择类型:1应用升级")
            self.logView.writeString(string: "文件路径:\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            AntCommandModule.shareInstance.setOtaStartUpgrade(type: 1, localFile: fileString, isContinue: false) { progress in

                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "进度:\(progress)")
                }
                
                print("progress ->",progress)

            } success: { error in

                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }
            break
            
        case "2图库升级":
            let fileString = self.getFilePathWithType(type: "2")
            
            self.logView.writeString(string: "当前选择类型:2图库升级")
            self.logView.writeString(string: "文件路径:\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            AntCommandModule.shareInstance.setOtaStartUpgrade(type: 2, localFile: fileString, isContinue: false) { progress in

                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "进度:\(progress)")
                }
                print("progress ->",progress)

            } success: { error in

                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }
            break
            
        case "3字库升级":
            let fileString = self.getFilePathWithType(type: "3")
            
            self.logView.writeString(string: "当前选择类型:3字库升级")
            self.logView.writeString(string: "文件路径:\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            AntCommandModule.shareInstance.setOtaStartUpgrade(type: 3, localFile: fileString, isContinue: false) { progress in

                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "进度:\(progress)")
                }
                print("progress ->",progress)

            } success: { error in

                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }
            break
            
        case "4表盘升级":
            let fileString = self.getFilePathWithType(type: "4")
            
            self.logView.writeString(string: "当前选择类型:4表盘升级")
            self.logView.writeString(string: "文件路径:\(fileString as! String)")
            
            print("fileString =",fileString)
            var showProgress = 0
            AntCommandModule.shareInstance.setOtaStartUpgrade(type: 4, localFile: fileString, isContinue: false) { progress in

                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "进度:\(progress)")
                }
                print("progress ->",progress)

            } success: { error in

                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }
            break
            
        case "5自定义表盘升级":
            
            let fileString = self.getFilePathWithType(type: "5")
            
            self.logView.writeString(string: "当前选择类型:5自定义表盘升级")
            self.logView.writeString(string: "文件路径:\(fileString as! String)")
                 
            print("fileString =",fileString)
            var showProgress = 0
            AntCommandModule.shareInstance.setOtaStartUpgrade(type: 5, localFile: fileString, isContinue: false) { progress in

                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "进度:\(progress)")
                }
                print("progress ->",progress)

            } success: { error in

                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setStartUpgrade -> error =",error.rawValue)

            }
            
            break
            
        case "6朝拜闹钟数据":
            self.logView.clearString()
            let array = [
                "起始日期:yyyy-MM-dd(默认当天)",
                "发送条数(时间按序号开始且递增+1,默认1条)",
            ]

            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "设置朝拜闹钟至设备", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                let timeString = textArray[0]
                let arrayCount = textArray[1]

                let startDate = formatter.date(from: timeString) ?? Date()
                var modelArray = [AntWorshipTimeModel]()
                
                for i in 0..<(Int(arrayCount) ?? 1) {
                    let model = AntWorshipTimeModel()
                    model.timeString = startDate.afterDay(dayCount: i).conversionDateToString(DateFormat: "yyyy-MM-dd")
                    model.fajr = (0 + i) >= 1440 ? (0 + i - 1440) : (0 + i)
                    model.dhuhr = (60 + i) >= 1440 ? (60 + i - 1440) : (60 + i)
                    model.asr = (120 + i) >= 1440 ? (120 + i - 1440) : (120 + i)
                    model.maghrib = (180 + i) >= 1440 ? (180 + i - 1440) : (180 + i)
                    model.isha = (240 + i) >= 1440 ? (240 + i - 1440) : (240 + i)
                    modelArray.append(model)
                }
                
                var showProgress = 0
                AntCommandModule.shareInstance.setWorshipTime(modelArray) { progress in
                    
                    if showProgress == Int(progress) {
                        showProgress += 1
                        self.logView.writeString(string: "进度:\(progress)")
                    }
                    print("progress ->",progress)

                } success: { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    print("setStartUpgrade -> error =",error.rawValue)
                }
            }
            break
        case "7本地音乐数据":
            
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
            self.presentTextFieldAlertVC(title: "提示(默认文件名:\(fileName))", message: "发送音乐文件至设备", holderStringArray: array) {
                
            } okAction: { (textArray) in
                let name = textArray[0].count == 0 ? fileName : textArray[0]
                AntCommandModule.shareInstance.setLocalMusicFile(name, localFile: fileString) { progress in
                    
                    if showProgress == Int(progress) {
                        showProgress += 1
                        self.logView.writeString(string: "进度:\(progress)")
                    }
                    print("progress ->",progress)

                } success: { error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    print("setStartUpgrade -> error =",error.rawValue)
                }

            }
            break
        case "自定义背景选择":
            
            self.presentSystemAlertVC(title: "自定义背景选择", message: "", cancel: "相册", cancelAction: {
                self.initPhotoPicker()
            }, ok: "拍照") {
                self.initCameraPicker()
            }
            
            break
        case "(直接选取无编辑)自定义背景选择":
            
            self.presentSystemAlertVC(title: "(直接选取无编辑)自定义背景选择", message: "", cancel: "相册", cancelAction: {
                self.initPhotoPicker(allowsEditing: false)
            }, ok: "拍照") {
                self.initCameraPicker()
            }
            
            break
            
        case "设置自定义背景":
            
//            if let image = self.customBgImage {
//
//                let dialFile = self.otaFile()
//
//                AntCommandModule.shareInstance.setOtaStartUpgrade(type: 5, localFile: dialFile, isContinue: false) { progress in
//
//                    self.logView.writeString(string: "进度:\(progress)")
//                    print("progress ->",progress)
//
//                } success: { error in
//
//                    self.logView.writeString(string: self.getErrorCodeString(error: error))
//                    print("setStartUpgrade -> error =",error.rawValue)
//
//                }
//
//            }

            if var image = self.customBgImage {
                print("image = \(image)")
                AntCommandModule.shareInstance.getCustonDialFrameSize { success, error in

                    if error == .none {

                        if let model = success {
                            let bigWidth = model.bigWidth
                            let bigheight = model.bigHeight

                            if bigWidth > 0 && bigheight > 0 {
                                image = image.img_changeSize(size: .init(width: bigWidth, height: bigheight))
                                print("image.img_changeSize = \(image)")
                                var showProgress = 0
                                AntCommandModule.shareInstance.setCustomDialEdit(image: image) { progress in
                                    if showProgress == Int(progress) {
                                        showProgress += 1
                                        self.logView.writeString(string: "进度:\(progress)")
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
            
        case "设置自定义背景(JL)":
            
            if var image = self.customBgImage {
                
                AntCommandModule.shareInstance.getCustonDialFrameSize { success, error in

                    if error == .none {

                        if let model = success {
                            let bigWidth = model.bigWidth
                            let bigheight = model.bigHeight

                            if bigWidth > 0 && bigheight > 0 {
                                image = image.img_changeSize(size: .init(width: bigWidth, height: bigheight))
                                var showProgress = 0
                                AntCommandModule.shareInstance.setCustomDialEdit(image: image, progress: { progress in
                                    if showProgress == Int(progress) {
                                        showProgress += 1
                                        self.logView.writeString(string: "进度:\(progress)")
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
            
        case "获取服务器OTA信息":
            
            AntCommandModule.shareInstance.getServerOtaDeviceInfo { success, error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    self.logView.writeString(string: "message:\(success["message"]!)")
                    self.logView.writeString(string: "code:\(success["code"]!)")
                }
                
                print("getServerOtaDeviceInfo ->",success)

            }
            
            break
            
        case "自动OTA升级服务器最新设备相关版本":
            var showProgress = 0
            AntCommandModule.shareInstance.setAutoServerOtaDeviceInfo { progress in

                if showProgress == Int(progress) {
                    showProgress += 1
                    self.logView.writeString(string: "进度:\(progress)")
                }
                print("progress ->",progress)

            } success: { error in
                
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                print("setAutoServerOtaDeviceInfo ->",error)
            }
            
            break
        case "获取在线表盘(旧接口，获取全部)":

            self.logView.clearString()
            self.logView.writeString(string: "获取在线表盘信息")
            
            AntCommandModule.shareInstance.getOnlineDialList { dialArray, error in
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
        case "获取在线表盘(新接口，获取分页)":

            self.logView.clearString()
            self.logView.writeString(string: "获取在线表盘信息")
            
            
            let array = [
                "获取的页数",
                "单页的个数"
            ]
            
            self.presentTextFieldAlertVC(title: "提示(无效数据默认0)", message: "获取在线表盘信息", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let pageIndex = textArray[0]
                let pageSize = textArray[1]
                
                AntCommandModule.shareInstance.getOnlineDialList(pageIndex: Int(pageIndex) ?? 0, pageSize: Int(pageSize) ?? 0) { dialArray, error in
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
                
//                AntCommandModule.shareInstance.GetDeviceOtaVersionInfo
                
            }
            
            break
            
        case "发送在线表盘":
            
            self.logView.clearString()
            self.logView.writeString(string: "发送在线表盘")
            
            let array = ["输入获取到的表盘ID"]
            
            self.presentTextFieldAlertVC(title: "发送在线表盘", message: "输入获取的表盘ID,输入错误不操作", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { textArray in
                
                let id = textArray[0]
                
                if let index = self.dialArray.firstIndex(where: { model in
                    return model.dialId == Int(id)
                }) {
                    self.logView.writeString(string: "ID:\(id)")
                    var showProgress = 0
                    AntCommandModule.shareInstance.setOnlienDialFile(model: self.dialArray[index]) { progress in
                        if showProgress == Int(progress) {
                            showProgress += 1
                            self.logView.writeString(string: "进度:\(progress)")
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
            
        case "获取本地表盘图片":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取本地表盘图片")
            
            AntCommandModule.shareInstance.getLocalDialImageServerInfo { dic, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if let dic = dic {
                        print("获取本地表盘图片 \ndic =\(dic)")
                        self.logView.writeString(string: "本地表盘图片信息:\(dic)")
                    }
                }
                
            }
            
            break
            
        case "获取自定义表盘图片":
            
            self.logView.clearString()
            self.logView.writeString(string: "获取自定义表盘图片")
            
            AntCommandModule.shareInstance.getCustomDialImageServerInfo { dic, error in
                self.logView.writeString(string: self.getErrorCodeString(error: error))
                
                if error == .none {
                    if let dic = dic {
                        print("获取自定义表盘图片 \ndic =\(dic)")
                        self.logView.writeString(string: "获取自定义表盘图片:\(dic)")
                    }
                }
                
            }
            
            break
            
        case "保存现有命令log":
                        
            let date:Date = Date()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "YYYY/MM/dd hh:mm:ss SS"
            let strNowTime = timeFormatter.string(from: date)
            let onceUrl:String = String.init(format: "\n保存时间:%@\n\n\n\n\n%@",strNowTime,AntSDKLog.showLog())
            let allUrl:String = String.init(format: "\n保存时间:%@\n\n\n\n\n%@",strNowTime,AntSDKLog.showAllLog())
            
            let savePath = NSHomeDirectory() + "/Documents/saveLog"
            let fileManager = FileManager.default
            let exit:Bool = fileManager.fileExists(atPath: savePath)
            if exit == false {
                do{
                    //                创建指定位置上的文件夹
                    try fileManager.createDirectory(atPath: savePath, withIntermediateDirectories: true, attributes: nil)
                    print("Succes to create folder")
                }
                catch{
                    print("Error to create folder")
                }
            }
            
            do{
                try onceUrl.write(toFile: String.init(format: "%@/%@_onceLog.txt",savePath,Date.init().conversionDateToString(DateFormat: "yyyy-MM-dd HH:mm:ss")), atomically: true, encoding: .utf8)
                try allUrl.write(toFile: String.init(format: "%@/%@_allLog.txt",savePath,Date.init().conversionDateToString(DateFormat: "yyyy-MM-dd HH:mm:ss")), atomically: true, encoding: .utf8)
            }catch {
                print("信息保存失败")
            }
            
            if self.autoTimer == nil {
                self.autoTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.autoSaveLog), userInfo: nil, repeats: true)
            }
            
            
            break

        case "删除所有文件夹":
            let savePath = NSHomeDirectory() + "/Documents/saveLog"

            self.presentSystemAlertVC(title: "警告", message: "删除所有已保存的log文件") {

            } okAction: {
                print("删除所有文件夹")
                FileManager.removefile(filePath: savePath)
            }

            break
            
        default:
            break
        }
    }
    
    @objc func autoSaveLog() {
        let date:Date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "YYYY/MM/dd hh:mm:ss SS"
        let strNowTime = timeFormatter.string(from: date)
        let autoUrl:String = String.init(format: "\n保存时间:%@\n\n\n\n\n%@",strNowTime,AntSDKLog.showAllLog())
        
        let savePath = NSHomeDirectory() + "/Documents/saveLog"
        let fileManager = FileManager.default
        let exit:Bool = fileManager.fileExists(atPath: savePath)
        if exit == false {
            do{
                //                创建指定位置上的文件夹
                try fileManager.createDirectory(atPath: savePath, withIntermediateDirectories: true, attributes: nil)
                print("Succes to create folder")
            }
            catch{
                print("Error to create folder")
            }
        }
        
        do{
            try autoUrl.write(toFile: String.init(format: "%@/automaticSaveLog.txt",savePath), atomically: true, encoding: .utf8)
        }catch {
            print("信息保存失败")
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
    
    @objc func test123(timer:Timer) {
        
        if self.testCount >= (861949/7250)+1 {
            print("取消定时器")
            timer.invalidate()
        }else{
            AntCommandModule.shareInstance.setOtaStartUpgrade(type: 0, localFile: "", isContinue: false) { progress in
                
            } success: { error in
                
            }
        }
        self.testCount += 1
        
    }
    
    func getErrorCodeString(error:AntError) -> String {
        if error == .none {
            return "成功"
        }else if error == .disconnected {
            return "设备未连接"
        }else if error == .invalidCharacteristic {
            return "无效特征值"
        }else if error == .invalidLength {
            return "无效数据长度"
        }else if error == .invalidState {
            return "无效状态"
        }else if error == .notSupport {
            return "不支持此功能"
        }
        return "未知error"
    }

    static var antStepIndex = 0
    // MARK: - 同步ANT步数
    private func antSyncHistoryStepModel(complete:(()->())?) {
        
        print("ANT同步历史步数")
        
        if AntVC.antStepIndex < 7 {
            
            self.antSyncStepDetailModel(dayCount: AntVC.antStepIndex) {
                AntVC.antStepIndex += 1
                
                DispatchQueue.main.async {
                    
                    self.antSyncHistoryStepModel(complete: complete)
                }
                
            }
            
        }else{
            AntVC.antStepIndex = 0
            
            DispatchQueue.main.async {
                
                if let complete = complete {
                    complete()
                }
            }
            
        }
    }
    
    private func antSyncStepDetailModel(dayCount:Int,success:(()->())?) {
        
        print("step dayCount ->",dayCount)
        
        AntCommandModule.shareInstance.setSyncHealthData(type: "1", dayCount: "\(dayCount)") { stepSuccess, error in
            
            if error == .none {
                if stepSuccess is AntStepModel {
                    if let model:AntStepModel = stepSuccess as? AntStepModel {
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
        
        if AntVC.antSleepIndex < 7 {
            
            self.antSyncSleepDetailModel(dayCount: AntVC.antSleepIndex) {
                AntVC.antSleepIndex += 1
                
                self.antSyncHistorySleepModel(complete: complete)
            }
            
        }else{
            AntVC.antSleepIndex = 0
            
            if let complete = complete {
                complete()
            }
        }

    }
    
    private func antSyncSleepDetailModel(dayCount:Int,success:(()->())?) {
        
        AntCommandModule.shareInstance.setSyncHealthData(type: "3", dayCount: "\(dayCount)") { sleepSuccess, error in
            
            if error == .none {
                
                if sleepSuccess is AntSleepModel {
                    if let model:AntSleepModel = sleepSuccess as? AntSleepModel {
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
        
        if AntVC.antHeartrateIndex < 7 {
            
            self.antSyncHeartrateDetailModel(dayCount: AntVC.antHeartrateIndex) {
                AntVC.antHeartrateIndex += 1
                
                
                self.antSyncHistoryHeartrateModel(complete: complete)
                
            }
            
        }else{
            AntVC.antHeartrateIndex = 0
            
            if let complete = complete {
                complete()
            }
        }
        
    }
    
    func antSyncHeartrateDetailModel(dayCount:Int,success:(()->())?) {
            
        AntCommandModule.shareInstance.setSyncHealthData(type: "2", dayCount: "\(dayCount)") { hrSuccess, error in
            
            print("error =",error.rawValue)
            
            if error == .none {
                
                if hrSuccess is AntHrModel {
                    if let model:AntHrModel = hrSuccess as? AntHrModel {
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

extension AntVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
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
    
    /**
    获取图片中的像素颜色值
    
    - parameter pos: 图片中的位置
    
    - returns: 颜色值
    */
    func getPixelColor(pos:CGPoint)->(alpha: UInt8, red: UInt8, green: UInt8,blue:UInt8){
//        pixelsWide
        if let cgImage = self.cgImage {
            let pixelData=cgImage.dataProvider?.data//CGImageGetDataProvider(cgImage).data
            
            let data:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            let pixelInfo: Int = ((Int(cgImage.width) * Int(pos.x)) + Int(pos.y)) * 4
            
            //("pixelData =",CFDataGetLength(pixelData))
            //print("cgImage.bytesPerRow =",cgImage.bytesPerRow)
            //print("cgImage.width =",cgImage.width)
            //print("cgImage.height =",cgImage.height)
            
            var a:UInt8 = 0
            var r:UInt8 = 0
            var g:UInt8 = 0
            var b:UInt8 = 0
            
            if cgImage.alphaInfo == .premultipliedFirst || cgImage.alphaInfo == .noneSkipFirst || cgImage.alphaInfo == .first {
                //ARGB
                a = UInt8(data[pixelInfo])
                r = UInt8(data[pixelInfo+1])
                g = UInt8(data[pixelInfo+2])
                b = UInt8(data[pixelInfo+3])
                
            }else if cgImage.alphaInfo == .premultipliedLast || cgImage.alphaInfo == .noneSkipLast || cgImage.alphaInfo == .last {
                //RGBA
                r = UInt8(data[pixelInfo])
                g = UInt8(data[pixelInfo+1])
                b = UInt8(data[pixelInfo+2])
                a = UInt8(data[pixelInfo+3])
                
            }
            
            return (a,r,g,b)
        }
        
        return (0,0,0,0)
    }
    
    public func pickColor(at position: CGPoint) -> (alpha: UInt8, red: UInt8, green: UInt8,blue:UInt8) {
        
        // 用来存放目标像素值
//        var pixel = [UInt8](repeatElement(0, count: 4))
//        // 颜色空间为 RGB，这决定了输出颜色的编码是 RGB 还是其他（比如 YUV）
//        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!//CGColorSpaceCreateDeviceRGB()
//        // 设置位图颜色分布为 RGBA
//        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
//        guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
//            return (0,0,0,0)
//        }
//        // 设置 context 原点偏移为目标位置所有坐标
//        context.translateBy(x: -position.x, y: -position.y)
//        // 将图像渲染到 context 中
//        if let cgImage = self.cgImage {
//            context.draw(cgImage, in: .init(origin: .init(x: 0, y: 0), size: self.size))
//        }
//        let r:UInt8 = UInt8(pixel[0])
//        let g:UInt8 = UInt8(pixel[1])
//        let b:UInt8 = UInt8(pixel[2])
//        let a:UInt8 = UInt8(pixel[3])
//
//        return (a,r,g,b)
//
        

            let pointX = trunc(position.x);
            let pointY = trunc(position.y);

            let width = self.size.width;
            let height = self.size.height;
            let colorSpace = CGColorSpaceCreateDeviceRGB();
            var pixelData: [UInt8] = [0, 0, 0, 0]

            pixelData.withUnsafeMutableBytes { pointer in
                if let context = CGContext(data: pointer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let cgImage = self.cgImage {
                    context.setBlendMode(.copy)
                    context.translateBy(x: -pointX, y: pointY - height)
                    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
                }
            }
        
        let r:UInt8 = UInt8(pixelData[0])
        let g:UInt8 = UInt8(pixelData[1])
        let b:UInt8 = UInt8(pixelData[2])
        let a:UInt8 = UInt8(pixelData[3])

        return (a,r,g,b)

            

    }
    
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
    
    func img_changeCircle(fillColor:UIColor) -> UIImage{

        if let cgImage = self.cgImage {
            let rect = CGRect.init(origin: .zero, size: CGSize.init(width: cgImage.width, height: cgImage.height))
            
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 1.0)
            fillColor.setFill()
            UIRectFill(rect)
            
            let path = UIBezierPath.init(ovalIn: rect)
            path.addClip()
            
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? UIImage.init()
        }
        return UIImage.init()
    }
    
    /**
     Converts the image into an array of RGBA bytes.
     */
    @nonobjc public func toByteArray() -> [UInt8] {
        let width = Int(size.width)
        let height = Int(size.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        
        bytes.withUnsafeMutableBytes { ptr in
            if let context = CGContext(
                data: ptr.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) {
                
                if let image = self.cgImage {
                    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    context.draw(image, in: rect)
                }
            }
        }
        return bytes
    }
    
    /**
     Creates a new UIImage from an array of RGBA bytes.
     */
    @nonobjc public class func fromByteArray(_ bytes: UnsafeMutableRawPointer,
                                             width: Int,
                                             height: Int) -> UIImage {
        
        if let context = CGContext(data: bytes, width: width, height: height,
                                   bitsPerComponent: 8, bytesPerRow: width * 4,
                                   space: CGColorSpaceCreateDeviceRGB(),
                                   bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue),
           let cgImage = context.makeImage() {
            return UIImage(cgImage: cgImage, scale: 0, orientation: .up)
        } else {
            return UIImage()
        }
    }
    
}

extension Date {
    // MARK: - 返回dayCount天日期，+为之后，-为之前
    func afterDay(dayCount:Int) -> Date {
        return self.addingTimeInterval(TimeInterval(dayCount * 86400))
    }
    
    func conversionDateToString(DateFormat dateFormatter:String) -> String {
        let formatter = DateFormatter.init()
        //formatter.dateStyle = .medium
        formatter.dateFormat = dateFormatter
        return formatter.string(from:self)
    }
}

extension FileManager {
    
    // 文件管理器
    static var fileManager: FileManager {
        return FileManager.default
    }
    
    // MARK: 2.1、创建文件夹(蓝色的，文件夹和文件是不一样的)
    /// 创建文件夹(蓝色的，文件夹和文件是不一样的)
    /// - Parameter folderName: 文件夹的名字
    /// - Returns: 返回创建的 创建文件夹路径
    @discardableResult
    static func createFolder(folderPath: String) -> (isSuccess: Bool, error: String) {
        if !judgeFileOrFolderExists(filePath: folderPath) {
            // 不存在的路径才会创建
            do {
                // withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
                try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                print("创建文件夹成功")
                return (true, "")
            } catch _ {
                return (false, "创建失败")
            }
        }
        return (true, "")
    }
    
    // MARK: 2.2、删除文件夹
    /// 删除文件夹
    /// - Parameter folderPath: 文件的路径
    @discardableResult
    static func removefolder(folderPath: String) -> (isSuccess: Bool, error: String) {
        let filePath = "\(folderPath)"
        guard judgeFileOrFolderExists(filePath: filePath) else {
            // 不存在就不做什么操作了
            print("removefolder 文件路径为空")
            return (true, "")
        }
        // 文件存在进行删除
        do {
            try fileManager.removeItem(atPath: filePath)
            print("删除文件夹成功")
            return (true, "")
            
        } catch _ {
            return (false, "删除失败")
        }
    }
    
    // MARK: 2.3、创建文件
    /// 创建文件
    /// - Parameter filePath: 文件路径
    /// - Returns: 返回创建的结果 和 路径
    @discardableResult
    static func createFile(filePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: filePath) else {
            // 不存在的文件路径才会创建
            // withIntermediateDirectories 为 ture 表示路径中间如果有不存在的文件夹都会创建
            let createSuccess = fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
            
            return (createSuccess, "")
        }
        return (true, "")
    }
    
    // MARK: 2.4、删除文件
    /// 删除文件
    /// - Parameter filePath: 文件路径
    @discardableResult
    static func removefile(filePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: filePath) else {
            // 不存在的文件路径就不需要要移除
            return (true, "")
        }
        // 移除文件
        do {
            try fileManager.removeItem(atPath: filePath)
            print("删除文件成功")
            return (true, "")
        } catch _ {
            return (false, "移除文件失败")
        }
    }
    
    // MARK: 文件写入
    @discardableResult
    static func writeDicToFile(content: [String:Any], writePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: writePath) else {
            // 不存在的文件路径
            print("writeDicToFile 文件路径为空")
            return (false, "不存在的文件路径")
        }
        
        let result = (content as NSDictionary).write(toFile: writePath, atomically: true)
        if result {
            print("文件写入成功")
            return (true, "")
        } else {
            return (false, "写入失败")
        }
    }
    
    //文件读取
    @discardableResult
    static func readDicFromFile(readPath: String) -> (isSuccess: Bool, content: Any?, error: String) {
        guard judgeFileOrFolderExists(filePath: readPath),  let readHandler =  FileHandle(forReadingAtPath: readPath) else {
            // 不存在的文件路径
            print("readDicFromFile 文件路径为空")
            return (false, nil, "不存在的文件路径")
        }

        let dic = NSDictionary.init(contentsOfFile: readPath)
        
        return (true, dic, "")
    }
    
    // MARK: 图片写入
    @discardableResult
    static func writeImageToFile(content: UIImage, writePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: writePath) else {
            // 不存在的文件路径
            print("writeImageToFile 文件路径为空")
            return (false, "不存在的文件路径")
        }

        let imageData:Data = content.pngData() ?? Data.init()
        let result: ()? = try? imageData.write(to: URL.init(fileURLWithPath: writePath))
        
        if (result != nil) {
            print("文件写入成功")
            return (true, "")
        }else{
            return (false, "写入失败")
        }
        
    }
    
    //图片读取
    @discardableResult
    static func readImageFromFile(readPath: String) -> (isSuccess: Bool, content: Any?, error: String) {
        guard judgeFileOrFolderExists(filePath: readPath) else {
            // 不存在的文件路径
            print("readImageFromFile 文件路径为空")
            return (false, nil, "不存在的文件路径")
        }

        let image = UIImage.init(contentsOfFile: readPath)
        return (true, image, "")

    }
    
    //获取文件夹下文件列表
    @discardableResult
    static func getFileListInFolderWithPath(path:String) -> (isSuccess: Bool, content: [Any]?, error: String) {
        guard judgeFileOrFolderExists(filePath: path) else {
            // 不存在的文件路径
            print("getFileListInFolderWithPath 文件路径为空")
            return (false , nil , "不存在的文件路径")
        }
        
        do {
            // withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
            let fileList = try self.fileManager.contentsOfDirectory(atPath: path)
//            print("获取文件夹下文件列表成功")
            return (true , fileList , "获取成功")
        } catch _ {
            return (false , nil , "获取失败")
        }

        
    }

    
    // MARK: 2.10、判断 (文件夹/文件) 是否存在
     /** 判断文件或文件夹是否存在*/
     static func judgeFileOrFolderExists(filePath: String) -> Bool {
         let exist = fileManager.fileExists(atPath: filePath)
         // 查看文件夹是否存在，如果存在就直接读取，不存在就直接反空
         guard exist else {
             return false
         }
         return true
     }
}
