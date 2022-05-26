//
//  AntModel.swift
//  AntSDK
//
//  Created by 猜猜我是谁 on 2022/5/7.
//

import Foundation
import CoreBluetooth
import UIKit

//public struct AntScanModel {
//    public var name:String?
//    public var rssi:Int?
//    public var peripheral:CBPeripheral?
//    fileprivate init() {
//
//    }
//}

@objc public class AntScanModel: NSObject {
    @objc public var name:String?
    @objc public var rssi:Int = 0
    @objc public var peripheral:CBPeripheral?
    @objc public var uuidString:String?
}

@objc public enum AntFunctionListType:Int {
    case exercise           = 0             //锻炼功能
    case step               = 1             //计步功能
    case sleep              = 2             //睡眠
    case heartrate          = 3             //心率检测
    case bloodPressure      = 4             //血压检测
    case bloodOxygen        = 5             //血氧检测
    case notification       = 6             //消息推送
    case metricSystem       = 7             //公英制
    case alarm              = 8             //闹钟提醒
    case sedentary          = 9             //久坐提醒
    case goal               = 10            //目标提醒
    case vibration          = 11            //振动提醒
    case noDisturb          = 12            //勿扰模式
    case lost               = 13            //防丢
    case weather            = 14            //天气
    case language           = 15            //多国语言
    case screenConreol      = 16            //背光控制
    case addressBook        = 17            //通讯录
    case onlineDial         = 18            //在线表盘
    case customDial         = 19            //自定义表盘
    case localDial          = 20            //本地表盘
    case hrWarning          = 21            //心率预警
    case menstrualCycle     = 22            //生理周期
    case drinkWater         = 23            //喝水提醒
    case lightScreen        = 24            //抬腕亮屏
    case hrMonitor          = 25            //全天心率监测
    case camera             = 26            //拍照
    case musicControl       = 27            //音乐控制
    case findDevice         = 28            //查找手环
    case powerOff           = 29            //关机
    case restart            = 30            //重启
    case restoreFactory     = 31            //恢复出厂
    case ringOff            = 32            //挂断电话
    case answerCalls        = 33            //接听电话
    case timeFormat         = 34            //时间制
}

@objc public class AntFunctionListModel:NSObject {
    @objc public private(set) var functionList_exercise = false
    @objc public private(set) var functionList_step = false
    @objc public private(set) var functionList_sleep = false
    @objc public private(set) var functionList_heartrate = false
    @objc public private(set) var functionList_bloodPressure = false
    @objc public private(set) var functionList_bloodOxygen = false
    @objc public private(set) var functionList_notification = false
    @objc public private(set) var functionList_metricSystem = false
    @objc public private(set) var functionList_alarm = false
    @objc public private(set) var functionList_sedentary = false
    @objc public private(set) var functionList_goal = false
    @objc public private(set) var functionList_vibration = false
    @objc public private(set) var functionList_noDisturb = false
    @objc public private(set) var functionList_lost = false
    @objc public private(set) var functionList_weather = false
    @objc public private(set) var functionList_language = false
    @objc public private(set) var functionList_screenConreol = false
    @objc public private(set) var functionList_addressBook = false
    @objc public private(set) var functionList_onlineDial = false
    @objc public private(set) var functionList_customDial = false
    @objc public private(set) var functionList_localDial = false
    @objc public private(set) var functionList_hrWarning = false
    @objc public private(set) var functionList_menstrualCycle = false
    @objc public private(set) var functionList_drinkWater = false
    @objc public private(set) var functionList_lightScreen = false
    @objc public private(set) var functionList_hrMonitor = false
    @objc public private(set) var functionList_camera = false
    @objc public private(set) var functionList_musicControl = false
    @objc public private(set) var functionList_findDevice = false
    @objc public private(set) var functionList_powerOff = false
    @objc public private(set) var functionList_restart = false
    @objc public private(set) var functionList_restoreFactory = false
    @objc public private(set) var functionList_ringOff = false
    @objc public private(set) var functionList_answerCalls = false
    @objc public private(set) var functionList_timeFormat = false
    
    @objc public private(set) var functionDetail_notification:AntFunctionModel_notification?
    @objc public private(set) var functionDetail_language:AntFunctionModel_language?
    @objc public private(set) var functionDetail_alarm:AntFunctionModel_alarm?
    @objc public private(set) var functionDetail_screenControl:AntFunctionModel_screenControl?
    @objc public private(set) var functionDetail_localDial:AntFunctionModel_localDial?
    @objc public private(set) var functionDetail_hrMonitor:AntFunctionModel_hrMonitor?
    @objc public private(set) var functionDetail_goal:AntFunctionModel_goal?
    
    init(val:[UInt8]) {
        
        super.init()
        var currentIndex = 0
        
        let mainLength = val[0]
        var funcList_1 = 0
        let mainVal = Array.init(val[1...Int(mainLength)])
        
        for i in 0...Int(mainLength)/8 {
            var listValue = 0
            for j in 0..<8 {
                //在数组范围内
                if i*8+j < mainVal.count {
                    listValue |= (Int(mainVal[i*8+j]) << (j*8))
                }
            }
            if i == 0 {
                funcList_1 = listValue
            }
        }
        self.dealMainFunction(result: funcList_1)
        
        currentIndex = Int(1+mainLength)
        self.dealDetailFunction(index: currentIndex, val: val)

    }
    
    func dealDetailFunction(index:Int,val:[UInt8]) {
        printLog("dealDetailFunction index =\(index)")
        if index >= val.count {
            printLog("dealDetailFunction 已全部处理完毕")
            AntSDKLog.writeStringToSDKLog(string: self.showAllSupportFunctionLog())
        }else{
            //一个子功能块至少有3个byte，少于就会异常，直接报错
            if index+3 > val.count  {
                printLog("数据错误，检查设备数据")
                return
            }
            let functionId = val[index]
            let functionLength = val[index+1]
            let functionVal = Array.init(val[(index+2)..<(index+2+Int(functionLength))])
            
            printLog("functionId =\(functionId),functionLength =\(functionLength),functionVal =\(functionVal)")
            
            var functionCount = 0
            for i in 0...Int(functionLength)/8 {
                var listValue = 0
                for j in 0..<8 {
                    //在数组范围内
                    if i*8+j < functionVal.count {
                        listValue |= (Int(functionVal[i*8+j]) << (j*8))
                    }
                }
                if i == 0 {
                    functionCount = listValue
                }
            }
            
            switch functionId {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            case 3:
                break
            case 4:
                break
            case 5:
                break
            case 6:
                self.functionDetail_notification = AntFunctionModel_notification.init(result: functionCount)
                break
            case 7:
                break
            case 8:
                self.functionDetail_alarm = AntFunctionModel_alarm.init(result: functionCount)
                break
            case 9:
                break
            case 10:
                self.functionDetail_goal = AntFunctionModel_goal.init(result: functionCount)
                break
            case 11:
                break
            case 12:
                break
            case 13:
                break
            case 14:
                break
            case 15:
                self.functionDetail_language = AntFunctionModel_language.init(result: functionCount)
                break
            case 16:
                self.functionDetail_screenControl = AntFunctionModel_screenControl.init(val: functionVal)
                break
            case 17:
                break
            case 18:
                break
            case 19:
                break
            case 20:
                self.functionDetail_localDial = AntFunctionModel_localDial.init(result: functionCount)
                break
            case 21:
                self.functionDetail_hrMonitor = AntFunctionModel_hrMonitor.init(val: functionVal)
                break
            case 22:
                break
            case 23:
                break
            case 24:
                break
            case 25:
                break
            case 26:
                break
            case 27:
                break
            case 28:
                break
            case 29:
                break
            case 30:
                break
            case 31:
                break
            case 32:
                break
            case 33:
                break
            case 34:
                break
            case 35:
                break
            default:
                break
            }
            self.dealDetailFunction(index: index+2+Int(functionLength), val: val)
        }
    }
    
    func dealMainFunction(result:Int) {
        
        let count:Int = result
        
        for i in 0..<64 {
            let state = (count >> i) & 0x01

            switch i {
            case 0:self.functionList_exercise = state == 0 ? false:true
                break
            case 1:self.functionList_step = state == 0 ? false:true
                break
            case 2:self.functionList_sleep = state == 0 ? false:true
                break
            case 3:self.functionList_heartrate = state == 0 ? false:true
                break
            case 4:self.functionList_bloodPressure = state == 0 ? false:true
                break
            case 5:self.functionList_bloodOxygen = state == 0 ? false:true
                break
            case 6:self.functionList_notification = state == 0 ? false:true
                break
            case 7:self.functionList_metricSystem = state == 0 ? false:true
                break
            case 8:self.functionList_alarm = state == 0 ? false:true
                break
            case 9:self.functionList_sedentary = state == 0 ? false:true
                break
            case 10:self.functionList_goal = state == 0 ? false:true
                break
            case 11:self.functionList_vibration = state == 0 ? false:true
                break
            case 12:self.functionList_noDisturb = state == 0 ? false:true
                break
            case 13:self.functionList_lost = state == 0 ? false:true
                break
            case 14:self.functionList_weather = state == 0 ? false:true
                break
            case 15:self.functionList_language = state == 0 ? false:true
                break
            case 16:self.functionList_screenConreol = state == 0 ? false:true
                break
            case 17:self.functionList_addressBook = state == 0 ? false:true
                break
            case 18:self.functionList_onlineDial = state == 0 ? false:true
                break
            case 19:self.functionList_customDial = state == 0 ? false:true
                break
            case 20:self.functionList_localDial = state == 0 ? false:true
                break
            case 21:self.functionList_hrWarning = state == 0 ? false:true
                break
            case 22:self.functionList_menstrualCycle = state == 0 ? false:true
                break
            case 23:self.functionList_drinkWater = state == 0 ? false:true
                break
            case 24:self.functionList_lightScreen = state == 0 ? false:true
                break
            case 25:self.functionList_hrMonitor = state == 0 ? false:true
                break
            case 26:self.functionList_camera = state == 0 ? false:true
                break
            case 27:self.functionList_musicControl = state == 0 ? false:true
                break
            case 28:self.functionList_findDevice = state == 0 ? false:true
                break
            case 29:self.functionList_powerOff = state == 0 ? false:true
                break
            case 30:self.functionList_restart = state == 0 ? false:true
                break
            case 31:self.functionList_restoreFactory = state == 0 ? false:true
                break
            case 32:self.functionList_ringOff = state == 0 ? false:true
                break
            case 33:self.functionList_answerCalls = state == 0 ? false:true
                break
            case 34:self.functionList_timeFormat = state == 0 ? false:true
                break
            case 35:
                break
            case 36:
                break
            case 37:
                break
            case 38:
                break
            default:
                break
            }
        }
    }

    @objc public func showAllSupportFunctionLog() -> String{
        var log = ""
        
        if self.functionList_exercise {
            log += "\n锻炼"
        }
        if self.functionList_step {
            log += "\n计步"
        }
        if self.functionList_sleep {
            log += "\n睡眠"
        }
        if self.functionList_heartrate {
            log += "\n心率"
        }
        if self.functionList_bloodPressure {
            log += "\n血压"
        }
        if self.functionList_bloodOxygen {
            log += "\n血氧"
        }
        if self.functionList_notification {
            log += "\n消息推送"
            if let model = self.functionDetail_notification {
                if model.isSupportCall {
                    log += "\n      来电 / isSupportCall"
                }
                if model.isSupportSMS {
                    log += "\n      短信 / isSupportSMS"
                }
                if model.isSupportInstagram {
                    log += "\n      Instagram / isSupportInstagram"
                }
                if model.isSupportWechat {
                    log += "\n      Wechat / isSupportWechat"
                }
                if model.isSupportQQ {
                    log += "\n      QQ / isSupportQQ"
                }
                if model.isSupportLine {
                    log += "\n      Line / isSupportLine"
                }
                if model.isSupportLinkedIn {
                    log += "\n      LinkedIn / isSupportLinkedIn"
                }
                if model.isSupportWhatsApp {
                    log += "\n      WhatsApp / isSupportWhatsApp"
                }
                if model.isSupportTwitter {
                    log += "\n      Twitter / isSupportTwitter"
                }
                if model.isSupportFacebook {
                    log += "\n      Facebook / isSupportFacebook"
                }
                if model.isSupportMessenger {
                    log += "\n      Messenger / isSupportMessenger"
                }
                if model.isSupportSkype {
                    log += "\n      Skype / isSupportSkype"
                }
                if model.isSupportSnapchat {
                    log += "\n      Snapchat / isSupportSnapchat"
                }
            }
        }
        if self.functionList_metricSystem {
            log += "\n公英制"
        }
        if self.functionList_alarm {
            log += "\n闹钟"
            if let model = self.functionDetail_alarm {
                log += "\n      最多支持 \(model.maxAlarmCount) 组"
            }
        }
        if self.functionList_sedentary {
            log += "\n久坐"
        }
        if self.functionList_goal {
            log += "\n目标"
            if let model = self.functionDetail_goal {
                if model.isSupportStep {
                    log += "\n      步数目标 / isSupportStep"
                }
                if model.isSupportSleep {
                    log += "\n      睡眠目标 / isSupportSleep"
                }
                if model.isSupportCalorie {
                    log += "\n      卡路里 / isSupportCalorie"
                }
                if model.isSupportTimeLong {
                    log += "\n      时长 / isSupportTimeLong"
                }
                if model.isSupportDistance {
                    log += "\n      距离 / isSupportDistance"
                }
            }
        }
        if self.functionList_vibration {
            log += "\n振动"
        }
        if self.functionList_noDisturb {
            log += "\n勿扰"
        }
        if self.functionList_lost {
            log += "\n防丢"
        }
        if self.functionList_weather {
            log += "\n天气"
        }
        if self.functionList_language {
            log += "\n语言"
            if let model = self.functionDetail_language {
                if model.isSupportEnglish {
                    log += "\n      英文 / isSupportEnglish"
                }
                if model.isSupportSimplifiedChinese {
                    log += "\n      简体中文 / isSupportSimplifiedChinese"
                }
                if model.isSupportJapan {
                    log += "\n      日语 / isSupportJapan"
                }
                if model.isSupportKorean {
                    log += "\n      韩语 / isSupportKorean"
                }
                if model.isSupportGerman {
                    log += "\n      德语 / isSupportGerman"
                }
                if model.isSupportFrench {
                    log += "\n      法语 / isSupportFrench"
                }
                if model.isSupportSpanish {
                    log += "\n      西班牙语 / isSupportSpanish"
                }
                if model.isSupportArabic {
                    log += "\n      阿拉伯语 / isSupportArabic"
                }
                if model.isSupportRussian {
                    log += "\n      俄语 / isSupportRussian"
                }
                if model.isSupportTraditionalChinese {
                    log += "\n      繁体中文 / isSupportTraditionalChinese"
                }
                if model.isSupportItalian {
                    log += "\n      意大利语 / isSupportItalian"
                }
                if model.isSupportPortuguese {
                    log += "\n      葡萄牙语 / isSupportPortuguese"
                }
                if model.isSupportUkrainian {
                    log += "\n      乌克兰语 / isSupportUkrainian"
                }
                if model.isSupportHindi {
                    log += "\n      印度语 / isSupportHindi"
                }
                if model.isSupportPolish {
                    log += "\n      波兰语 / isSupportPolish"
                }
                if model.isSupportGreek {
                    log += "\n      希腊语 / isSupportGreek"
                }
                if model.isSupportVietnamese {
                    log += "\n      越南语 / isSupportVietnamese"
                }
                if model.isSupportIndonesian {
                    log += "\n      印尼语 / isSupportIndonesian"
                }
                if model.isSupportThai {
                    log += "\n      泰语 / isSupportThai"
                }
            }
        }
        if self.functionList_screenConreol {
            log += "\n背光控制"
            if let model = self.functionDetail_screenControl {
                log += "\n      屏幕亮度最大等级 \(model.screenLevelCount)"
                log += "\n      亮屏时长最大值 \(model.screenTimeLong_max)"
                log += "\n      亮屏时长最小值 \(model.screenTimeLong_min)"
            }
        }
        if self.functionList_addressBook {
            log += "\n通讯录"
        }
        if self.functionList_onlineDial {
            log += "\n在线表盘"
        }
        if self.functionList_customDial {
            log += "\n自定义表盘"
        }
        if self.functionList_localDial {
            log += "\n本地表盘"
            if let model = self.functionDetail_localDial {
                log += "\n      内置 \(model.maxDialCount) 个本地表盘"
            }
        }
        if self.functionList_hrWarning {
            log += "\n心率预警"
            if let model = self.functionDetail_hrMonitor {
                log += "\n      心率预警最大值 \(model.maxValue)"
                log += "\n      心率预警最小值 \(model.minValue)"
            }
        }
        if self.functionList_menstrualCycle {
            log += "\n生理周期"
        }
        if self.functionList_drinkWater {
            log += "\n喝水"
        }
        if self.functionList_lightScreen {
            log += "\n抬腕亮屏"
        }
        if self.functionList_hrMonitor {
            log += "\n24小时心率监测"
        }
        if self.functionList_camera {
            log += "\n拍照"
        }
        if self.functionList_musicControl {
            log += "\n音乐控制"
        }
        if self.functionList_findDevice {
            log += "\n寻找设备"
        }
        if self.functionList_powerOff {
            log += "\n关机"
        }
        if self.functionList_restart {
            log += "\n重启"
        }
        if self.functionList_restoreFactory {
            log += "\n恢复出厂"
        }
        if self.functionList_ringOff {
            log += "\n挂断电话"
        }
        if self.functionList_answerCalls {
            log += "\n接听电话"
        }
        if self.functionList_timeFormat {
            log += "\n时间格式"
        }
        return log
    }
}

@objc public class AntFunctionModel_notification:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportCall = false
    @objc public private(set) var isSupportSMS = false
    @objc public private(set) var isSupportInstagram = false
    @objc public private(set) var isSupportWechat = false
    @objc public private(set) var isSupportQQ = false
    @objc public private(set) var isSupportLine = false
    @objc public private(set) var isSupportLinkedIn = false
    @objc public private(set) var isSupportWhatsApp = false
    @objc public private(set) var isSupportTwitter = false
    @objc public private(set) var isSupportFacebook = false
    @objc public private(set) var isSupportMessenger = false
    @objc public private(set) var isSupportSkype = false
    @objc public private(set) var isSupportSnapchat = false

    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<64 {
            let state = (result >> i) & 0x01

            switch i {
            case 0:self.isSupportCall = state == 0 ? false:true
                break
            case 1:self.isSupportSMS = state == 0 ? false:true
                break
            case 2:self.isSupportInstagram = state == 0 ? false:true
                break
            case 3:self.isSupportWechat = state == 0 ? false:true
                break
            case 4:self.isSupportQQ = state == 0 ? false:true
                break
            case 5:self.isSupportLine = state == 0 ? false:true
                break
            case 6:self.isSupportLinkedIn = state == 0 ? false:true
                break
            case 7:self.isSupportWhatsApp = state == 0 ? false:true
                break
            case 8:self.isSupportTwitter = state == 0 ? false:true
                break
            case 9:self.isSupportFacebook = state == 0 ? false:true
                break
            case 10:self.isSupportMessenger = state == 0 ? false:true
                break
            case 11:self.isSupportSkype = state == 0 ? false:true
                break
            case 12:self.isSupportSnapchat = state == 0 ? false:true
                break
            case 13:
                break
            default:
                break
            }
        }
    }
}

@objc public class AntFunctionModel_language:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportEnglish = false                      //英文
    @objc public private(set) var isSupportSimplifiedChinese = false            //简体中文
    @objc public private(set) var isSupportJapan = false                        //日语
    @objc public private(set) var isSupportKorean = false                       //韩语
    @objc public private(set) var isSupportGerman = false                       //德语
    @objc public private(set) var isSupportFrench = false                       //法语
    @objc public private(set) var isSupportSpanish = false                      //西班牙语
    @objc public private(set) var isSupportArabic = false                       //阿拉伯语
    @objc public private(set) var isSupportRussian = false                      //俄语
    @objc public private(set) var isSupportTraditionalChinese = false           //繁体中文
    @objc public private(set) var isSupportItalian = false                      //意大利语
    @objc public private(set) var isSupportPortuguese = false                   //葡萄牙语
    @objc public private(set) var isSupportUkrainian = false                    //乌克兰语
    @objc public private(set) var isSupportHindi = false                        //印度语
    @objc public private(set) var isSupportPolish = false                       //波兰语
    @objc public private(set) var isSupportGreek = false                        //希腊语
    @objc public private(set) var isSupportVietnamese = false                   //越南语
    @objc public private(set) var isSupportIndonesian = false                   //印尼语
    @objc public private(set) var isSupportThai = false                         //泰语

    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<64 {
            let state = (result >> i) & 0x01

            switch i {
            case 0:self.isSupportEnglish = state == 0 ? false:true
                break
            case 1:self.isSupportSimplifiedChinese = state == 0 ? false:true
                break
            case 2:self.isSupportJapan = state == 0 ? false:true
                break
            case 3:self.isSupportKorean = state == 0 ? false:true
                break
            case 4:self.isSupportGerman = state == 0 ? false:true
                break
            case 5:self.isSupportFrench = state == 0 ? false:true
                break
            case 6:self.isSupportSpanish = state == 0 ? false:true
                break
            case 7:self.isSupportArabic = state == 0 ? false:true
                break
            case 8:self.isSupportRussian = state == 0 ? false:true
                break
            case 9:self.isSupportTraditionalChinese = state == 0 ? false:true
                break
            case 10:self.isSupportItalian = state == 0 ? false:true
                break
            case 11:self.isSupportPortuguese = state == 0 ? false:true
                break
            case 12:self.isSupportUkrainian = state == 0 ? false:true
                break
            case 13:self.isSupportHindi = state == 0 ? false:true
                break
            case 14:self.isSupportPolish = state == 0 ? false:true
                break
            case 15:self.isSupportGreek = state == 0 ? false:true
                break
            case 16:self.isSupportVietnamese = state == 0 ? false:true
                break
            case 17:self.isSupportIndonesian = state == 0 ? false:true
                break
            case 18:self.isSupportThai = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}

@objc public class AntFunctionModel_alarm:NSObject {
    @objc public private(set) var maxAlarmCount = 0         //最多支持多少个闹钟
    
    init(result:Int) {
        self.maxAlarmCount = result
        super.init()
    }
}

@objc public class AntFunctionModel_screenControl:NSObject {
    @objc public private(set) var screenLevelCount = 0           //支持的亮度等级
    @objc public private(set) var screenTimeLong_max = 0    //亮屏时长最大值
    @objc public private(set) var screenTimeLong_min = 0    //亮屏时长最小值
    
    init(val:[UInt8]) {
        self.screenLevelCount = Int(val[0])
        self.screenTimeLong_max = Int(val[1])
        self.screenTimeLong_min = Int(val[2])
        super.init()
    }
}

@objc public class AntFunctionModel_localDial:NSObject {
    @objc public private(set) var maxDialCount = 0         //内置表盘个数
    
    init(result:Int) {
        self.maxDialCount = result
        super.init()
    }
}

@objc public class AntFunctionModel_hrMonitor:NSObject {
    @objc public private(set) var maxValue = 0         //最大值
    @objc public private(set) var minValue = 0         //最小值
    
    init(val:[UInt8]) {
        self.maxValue = Int(val[0])
        self.minValue = Int(val[1])
        super.init()
    }
}

@objc public class AntFunctionModel_goal:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportStep = false             //步数目标
    @objc public private(set) var isSupportSleep = false            //睡眠目标
    @objc public private(set) var isSupportCalorie = false          //卡路里目标
    @objc public private(set) var isSupportTimeLong = false         //时长目标
    @objc public private(set) var isSupportDistance = false         //距离目标
    
    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<64 {
            let state = (result >> i) & 0x01

            switch i {
            case 0:self.isSupportStep = state == 0 ? false:true
                break
            case 1:self.isSupportSleep = state == 0 ? false:true
                break
            case 2:self.isSupportCalorie = state == 0 ? false:true
                break
            case 3:self.isSupportTimeLong = state == 0 ? false:true
                break
            case 4:self.isSupportDistance = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}

@objc public class AntPersonalModel:NSObject {
    @objc public var age:Int = 0
    @objc public var gender:Bool = false
    @objc public var height:Float = 0
    @objc public var weight:Float = 0
    
    public override init() {
        super.init()
    }
}
@objc public enum AntWeatherType : Int {
    case overcast               //阴
    case fog                    //雾
    case sunny                  //晴
    case cloudy                 //多云
    case snow                   //雪
    case rain                   //雨
}

@objc public class AntWeatherModel:NSObject {
    @objc public var dayCount:Int = 0
    @objc public var type:AntWeatherType = AntWeatherType.sunny
    @objc public var temp:Int = 0
    @objc public var airQuality:Int = 0
    @objc public var minTemp:Int = 0
    @objc public var maxTemp:Int = 0
    @objc public var tomorrowMinTemp:Int = 0
    @objc public var tomorrowMaxTemp:Int = 0
    
    public override init() {
        super.init()
    }
}

@objc public enum AntAlarmType : Int {
    case single
    case cycle
}
@objc public class AntAlarmModel:NSObject {
    @objc public var alarmIndex:Int = -1
    @objc public var alarmOpen:Bool = false
    @objc public var alarmHour:Int = -1
    @objc public var alarmMinute = -1
    @objc public var alarmType:AntAlarmType = .single
    @objc public var alarmRepeatArray:Array<Int>?
    @objc public private(set) var alarmRepeatCount:Int = 0
    
    public override init() {
        super.init()
    }
    
    @objc public init(dic:[String:Any]) {
        super.init()
        
        if dic.keys.contains("index") && dic.keys.contains("repeatCount") && dic.keys.contains("hour") && dic.keys.contains("minute") {
            if let index = dic["index"] as? String {
                self.alarmIndex = Int(index) ?? 0
            }

            self.alarmHour = Int(dic["hour"] as! String) ?? 0
            self.alarmMinute = Int(dic["minute"] as! String) ?? 0
            let repeatCount = Int(dic["repeatCount"] as! String) ?? 0
            
            if let repeatString = dic["repeatCount"] as? String {
                self.alarmRepeatCount = Int(repeatString) ?? 0
            }
            
            if repeatCount < 128 {
                self.alarmOpen = false
            }else{
                self.alarmOpen = true
                
                if repeatCount == 128 {
                    self.alarmType = .single
                }else{
                    self.alarmType = .cycle
                }
            }
            
            self.alarmRepeatArray = []
            for i in stride(from: 0, to: 7, by: 1) {
                if (((repeatCount >> i) & 0x01) != 0) {
                    self.alarmRepeatArray?.append(1)
                }else{
                    self.alarmRepeatArray?.append(0)
                }
            }
        }else{
            printLog("闹钟dic初始化异常")
        }
        
    }
}

@objc public enum AntLanguageType : Int {
    case English = 0
    case SimplifiedChinese
    case Japanese
    case Korean
    case German
    case French
    case Spanish
    case Arabic
    case Russian
    case TraditionalChinese
    case Italian
    case Portuguese
    case Ukrainian
    case Hindi
}

@objc public enum AntNotificationType : Int {
    case Call = 1
    case SMS
    case Instagram
    case Wechat
    case QQ
    case Line
    case LinkedIn
    case WhatsApp
    case Twitter
    case Facebook
    case Messenger
    case Skype
    case Snapchat
    case Other = 15
}

@objc public enum AntPositionType : Int {
    case leftUp
    case leftMiddle
    case letfDown
    case rightUp
    case rightMiddle
    case rightDown
}
@objc public enum AntPositionShowType : Int {
    case close
    case date
    case sleep
    case heartrate
    case step
}
@objc public class AntCustomDialModel:NSObject {
    @objc public private(set) var colorHex:String = "0xFFFFFF"
    @objc public var color:UIColor = .white
    @objc public var positionType:AntPositionType = .leftUp
    @objc public var timeUpType:AntPositionShowType = .close
    @objc public var timeDownType:AntPositionShowType = .close
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        self.colorHex = dic["colorHex"] as! String
        self.color = dic["color"] as! UIColor
        let positionType = dic["positionType"] as! String
        let timeUpType = dic["timeUpType"] as! String
        let timeDownType = dic["timeDownType"] as! String
        self.positionType = AntPositionType.init(rawValue: Int(positionType) ?? 0) ?? .leftUp
        self.timeUpType = AntPositionShowType.init(rawValue: Int(timeUpType) ?? 0) ?? .close
        self.timeDownType = AntPositionShowType.init(rawValue: Int(timeDownType) ?? 0) ?? .close
    }
}

@objc public class AntDialFrameSizeModel:NSObject {
    @objc public private(set) var bigWidth:Int = 0
    @objc public private(set) var bigHeight:Int = 0
    @objc public private(set) var smallWidth:Int = 0
    @objc public private(set) var smallHeight:Int = 0
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        self.bigWidth = Int(dic["bigWidth"] as! String) ?? 0
        self.bigHeight = Int(dic["bigHeight"] as! String) ?? 0
        self.smallWidth = Int(dic["smallWidth"] as! String) ?? 0
        self.smallHeight = Int(dic["smallHeight"] as! String) ?? 0
    }
}


@objc public class AntOnlineDialModel:NSObject {
    @objc public var dialId:Int = -1
    @objc public var dialImageUrl:String?
    @objc public var dialFileUrl:String?
    @objc public var dialName:String?
    
    public override init() {
        super.init()
    }
}

@objc public class AntSedentaryModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var timeLong:Int = 0
    @objc public var timeArray:[AntStartEndTimeModel] = []
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        let result = Int(dic["isOpen"] as! String) ?? 0
        
        self.isOpen = result == 0 ? false:true
        self.timeLong = Int(dic["timeLong"] as! String) ?? 0
        self.timeArray = dic["timeArray"] as? [AntStartEndTimeModel] ?? []
    }
}

@objc public class AntDoNotDisturbModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var timeModel:AntStartEndTimeModel = AntStartEndTimeModel.init()
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        let result = Int(dic["isOpen"] as! String) ?? 0
        self.isOpen = result == 0 ? false:true
        self.timeModel.startHour = Int(dic["startHour"] as! String) ?? 0
        self.timeModel.startMinute = Int(dic["startMinute"] as! String) ?? 0
        self.timeModel.endHour = Int(dic["endHour"] as! String) ?? 0
        self.timeModel.endMinute = Int(dic["endMinute"] as! String) ?? 0
    }
}

@objc public class AntHrWaringModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var maxValue:Int = 0
    @objc public var minValue:Int = 0
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        let result = Int(dic["isOpen"] as! String) ?? 0
        self.isOpen = result == 0 ? false:true
        self.maxValue = Int(dic["maxHr"] as! String) ?? 0
        self.minValue = Int(dic["minHr"] as! String) ?? 0
    }
}

@objc public class AntStepModel:NSObject {
    @objc public var step = 0
    @objc public var calorie = 0
    @objc public var distance = 0
    @objc public var detailArray:[Int] = []
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        self.step = Int(dic["step"] as! String) ?? 0
        self.calorie = Int(dic["calorie"] as! String) ?? 0
        self.distance = Int(dic["distance"] as! String) ?? 0
        
        if dic.keys.contains("detailArray") {
            self.detailArray = dic["detailArray"] as? [Int] ?? []
        }
    }
}

@objc public class AntHrModel:NSObject {

    @objc public var detailArray:[Int] = []
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        if dic.keys.contains("detailArray") {
            self.detailArray = dic["detailArray"] as? [Int] ?? []
        }
    }
}

@objc public class AntSleepModel:NSObject {
    @objc public var deep = 0
    @objc public var light = 0
    @objc public var awake = 0
    @objc public var detailArray:[[String:String]] = []             //详情数据，无效状态转换成清醒状态
    @objc public var detailArray_filter:[[String:String]] = []      //过滤了无效数据的详情数据
    
    public override init() {
        super.init()
    }

    init(dic:[String:Any]) {
        super.init()
        
        self.deep = Int(dic["deep"] as! String) ?? 0
        self.light = Int(dic["light"] as! String) ?? 0
        self.awake = Int(dic["awake"] as! String) ?? 0
        
        if dic.keys.contains("detailArray") {
            self.detailArray = dic["detailArray"] as? [[String:String]] ?? []
        }
        
        if dic.keys.contains("detailArray_filter") {
            self.detailArray_filter = dic["detailArray_filter"] as? [[String:String]] ?? []
        }
    }
}

@objc public class AntExerciseModel:NSObject {
    @objc public var type:Int = 0
    @objc public var startTime:String = ""
    @objc public var endTime:String = ""
    @objc public var validTimeLength:Int = 0
    @objc public var heartrate:Int = 0
    @objc public var step:Int = 0
    @objc public var calorie:Int = 0
    @objc public var distance:Int = 0
    
    public override init() {
        super.init()
    }
    init(dic:[String:Any]) {
        super.init()
        
        self.type = Int(dic["type"] as! String) ?? 0
        self.startTime = dic["startTime"] as! String
        self.endTime = dic["endTime"] as! String
        self.validTimeLength = Int(dic["validTimeLength"] as! String) ?? 0
        self.heartrate = Int(dic["hr"] as! String) ?? 0
        self.step = Int(dic["step"] as! String) ?? 0
        self.calorie = Int(dic["calorie"] as! String) ?? 0
        self.distance = Int(dic["distance"] as! String) ?? 0

    }
}


@objc public class AntStartEndTimeModel:NSObject {
    @objc public var startHour:Int = -1
    @objc public var startMinute:Int = -1
    @objc public var endHour:Int = -1
    @objc public var endMinute:Int = -1
    
    public override init() {
        super.init()
    }
}
