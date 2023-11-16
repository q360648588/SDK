//
//  ZyModel.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2022/5/7.
//

import Foundation
import CoreBluetooth
import UIKit
import CoreLocation

//public struct ZyScanModel {
//    public var name:String?
//    public var rssi:Int?
//    public var peripheral:CBPeripheral?
//    fileprivate init() {
//
//    }
//}

@objc public class ZyScanModel: NSObject {
    @objc public var name:String?
    @objc public var rssi:Int = 0
    @objc public var peripheral:CBPeripheral?
    @objc public var uuidString:String?
}

@objc public enum ZyFunctionListType:Int {
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
    case screenType         = 35            //手表款式
    case sportCountdown     = 37            //运动倒计时
    case lowBattery         = 38            //低电提醒
    case exerciseInteraction   = 39            //app发起运动交互
}

@objc public class ZyFunctionListModel:NSObject {
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
    @objc public private(set) var functionList_screenType = false
    @objc public private(set) var functionList_sportCountdown = false
    @objc public private(set) var functionList_lowBattery = false
    @objc public private(set) var functionList_exerciseInteraction = false
    @objc public private(set) var functionList_clearData = false
    @objc public private(set) var functionList_bind = false
    @objc public private(set) var functionList_weatherExtend = false
    @objc public private(set) var functionList_newPortocol = false
    @objc public private(set) var functionList_platformType = false
    @objc public private(set) var functionList_bloodSugar = false
    @objc public private(set) var functionList_pressure = false
    @objc public private(set) var functionList_electrocardiogram = false
    @objc public private(set) var functionList_bodyTemperature = false
    @objc public private(set) var functionList_sosContactPerson = false
    @objc public private(set) var functionList_worshipAlarm = false
    @objc public private(set) var functionList_localPlay = false
    @objc public private(set) var functionList_locationGps = false
    @objc public private(set) var functionList_customSports = false
    
    @objc public private(set) var functionDetail_exercise:ZyFunctionModel_exercise?
    @objc public private(set) var functionDetail_notification:ZyFunctionModel_notification?
    @objc public private(set) var functionDetail_language:ZyFunctionModel_language?
    @objc public private(set) var functionDetail_alarm:ZyFunctionModel_alarm?
    @objc public private(set) var functionDetail_screenControl:ZyFunctionModel_screenControl?
    @objc public private(set) var functionDetail_addressBook:ZyFunctionModel_addressBook?
    @objc public private(set) var functionDetail_localDial:ZyFunctionModel_localDial?
    @objc public private(set) var functionDetail_hrWarning:ZyFunctionModel_hrWarning?
    @objc public private(set) var functionDetail_goal:ZyFunctionModel_goal?
    @objc public private(set) var functionDetail_screenType:ZyFunctionModel_scrrenType?
    @objc public private(set) var functionDetail_sportCountdown:ZyFunctionModel_sportCountdown?
    var functionDetail_newPortocol:ZyFunctionModel_newPortocol?
    @objc public private(set) var functionDetail_platformType:ZyFunctionModel_platformType?
    @objc public private(set) var functionDetail_customDial:ZyFunctionModel_customDial?
    @objc public private(set) var functionDetail_heartrate:ZyFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_bloodPressure:ZyFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_bloodOxygen:ZyFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_bloodSugar:ZyFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_pressure:ZyFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_electrocardiogram:ZyFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_bodyTemperature:ZyFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_localPlay:ZyFunctionModel_supportMusicFileTypeModel?
    @objc public private(set) var functionDetail_locationGps:ZyFunctionModel_locationGps?
    @objc public private(set) var functionDetail_customSports:ZyFunctionModel_customSports?
    
    init(val:[UInt8]) {
        
        super.init()
//        let val:[UInt8] = [0x07,0xff,0xd7,0xdf,0xff,0xbf,0x1f,0xff,0x00,0x04,0xff,0xfb,0x7e,0x00,0x06,0x06,0xff,0x3f,0xff,0xff,0x07,0x00,0x08,0x02,0x0a,0x01,0x0a,0x01,0x1f,0x0f,0x05,0x7f,0x1f,0x00,0x00,0x00,0x10,0x04,0x64,0x1e,0x05,0x05,0x13,0x01,0x00,0x14,0x01,0x05,0x11,0x02,0x64,0x00,0x23,0x01,0x02,0x25,0x01,0x03,0x2b,0x02,0xb6,0x00,0x2c,0x01,0x01,0x36,0x0d,0xf0,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf7,0xf8,0xf9,0xfa,0xfb,0xfc]
        
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
            printLog("\(self.showAllSupportFunctionLog())")
            ZySDKLog.writeStringToSDKLog(string: self.showAllSupportFunctionLog())
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
                self.functionDetail_exercise = ZyFunctionModel_exercise.init(result: functionCount)
                break
            case 1:
                break
            case 2:
                break
            case 3:
                self.functionDetail_heartrate = ZyFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 4:
                self.functionDetail_bloodPressure = ZyFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 5:
                self.functionDetail_bloodOxygen = ZyFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 6:
                self.functionDetail_notification = ZyFunctionModel_notification.init(result: functionCount)
                break
            case 7:
                break
            case 8:
                self.functionDetail_alarm = ZyFunctionModel_alarm.init(val: functionVal)
                break
            case 9:
                break
            case 10:
                self.functionDetail_goal = ZyFunctionModel_goal.init(result: functionCount)
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
                self.functionDetail_language = ZyFunctionModel_language.init(result: functionCount)
                break
            case 16:
                self.functionDetail_screenControl = ZyFunctionModel_screenControl.init(val: functionVal)
                break
            case 17:
                self.functionDetail_addressBook = ZyFunctionModel_addressBook.init(val: functionVal)
                break
            case 18:
                break
            case 19:
                self.functionDetail_customDial = ZyFunctionModel_customDial.init(result: functionCount)
                break
            case 20:
                self.functionDetail_localDial = ZyFunctionModel_localDial.init(result: functionCount)
                break
            case 21:
                self.functionDetail_hrWarning = ZyFunctionModel_hrWarning.init(val: functionVal)
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
                self.functionDetail_screenType = ZyFunctionModel_scrrenType.init(result: functionCount)
                break
            case 36:
                break
            case 37:
                self.functionDetail_sportCountdown = ZyFunctionModel_sportCountdown.init(result: functionCount)
                break
            case 38:
                break
            case 39:
                break
            case 40:
                break
            case 41:
                break
            case 42:
                break
            case 43:
                self.functionDetail_newPortocol = ZyFunctionModel_newPortocol.init(result: functionCount)
                break
            case 44:
                self.functionDetail_platformType = ZyFunctionModel_platformType.init(result: functionCount)
                break
            case 45:
                break
            case 46:
                self.functionDetail_bloodSugar = ZyFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 47:
                self.functionDetail_pressure = ZyFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 48:
                self.functionDetail_electrocardiogram = ZyFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 49:
                self.functionDetail_bodyTemperature = ZyFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 52:
                self.functionDetail_localPlay = ZyFunctionModel_supportMusicFileTypeModel(val: functionVal)
                break
            case 53:
                self.functionDetail_locationGps = ZyFunctionModel_locationGps(val: functionVal)
                break
            case 54:
                self.functionDetail_customSports = ZyFunctionModel_customSports(val: functionVal)
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
            case 35:self.functionList_screenType = state == 0 ? false:true
                break
            case 36:
                break
            case 37:self.functionList_sportCountdown = state == 0 ? false:true
                break
            case 38:self.functionList_lowBattery = state == 0 ? false:true
                break
            case 39:self.functionList_exerciseInteraction = state == 0 ? false:true
                break
            case 40:self.functionList_clearData = state == 0 ? false:true
                break
            case 41:self.functionList_bind = state == 0 ? false:true
                break
            case 42:self.functionList_weatherExtend = state == 0 ? false:true
                break
            case 43:self.functionList_newPortocol = state == 0 ? false:true
                break
            case 44:self.functionList_platformType = state == 0 ? false:true
                break
            case 45:
                break
            case 46:self.functionList_bloodSugar = state == 0 ? false:true
                break
            case 47:self.functionList_pressure = state == 0 ? false:true
                break
            case 48:self.functionList_electrocardiogram = state == 0 ? false:true
                break
            case 49:self.functionList_bodyTemperature = state == 0 ? false:true
                break
            case 50:self.functionList_sosContactPerson = state == 0 ? false:true
                break
            case 51:self.functionList_worshipAlarm = state == 0 ? false:true
                break
            case 52:self.functionList_localPlay = state == 0 ? false:true
                break
            case 53:self.functionList_locationGps = state == 0 ? false:true
                break
            case 54:self.functionList_customSports = state == 0 ? false:true
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
            if let model = self.functionDetail_exercise {
                if model.isSupportRunOutside {
                    log += "\n      户外跑 / isSupportRunOutside"
                }
                if model.isSupportWalk {
                    log += "\n      走路 / isSupportWalk"
                }
                if model.isSupportCycling {
                    log += "\n      骑行 / isSupportCycling"
                }
                if model.isSupportBasketball {
                    log += "\n      篮球 / isSupportBasketball"
                }
                if model.isSupportFootball {
                    log += "\n      足球 / isSupportFootball"
                }
                if model.isSupportBadminton {
                    log += "\n      羽毛球 / isSupportBadminton"
                }
                if model.isSupportJumpRope {
                    log += "\n      跳绳 / isSupportJumpRope"
                }
                if model.isSupportSwimming {
                    log += "\n      游泳 / isSupportSwimming"
                }
                if model.isSupportRunIndoor {
                    log += "\n      室内跑 / isSupportRunIndoor"
                }
                if model.isSupportVolleyball {
                    log += "\n      排球 / isSupportVolleyball"
                }
                if model.isSupportWalkFast {
                    log += "\n      健走 / isSupportWalkFast"
                }
                if model.isSupportSpinning {
                    log += "\n      动感单车 / isSupportSpinning"
                }
                if model.isSupportSitUps {
                    log += "\n      仰卧起坐 / isSupportSitUps"
                }
                if model.isSupportMountainClimbing {
                    log += "\n      登山 / isSupportMountainClimbing"
                }
                if model.isSupportYoga {
                    log += "\n      瑜伽 / isSupportYoga"
                }
                if model.isSupportDance {
                    log += "\n      舞蹈 / isSupportDance"
                }
                if model.isSupportJumpingJacks {
                    log += "\n      开合跳 / isSupportJumpingJacks"
                }
                if model.isSupportGymnastics {
                    log += "\n      体操 / isSupportGymnastics"
                }
                if model.isSupportRowing {
                    log += "\n      划船 / isSupportRowing"
                }
                if model.isSupportTennis {
                    log += "\n      网球 / isSupportTennis"
                }
                if model.isSupportHockey {
                    log += "\n      曲棍球 / isSupportHockey"
                }
                if model.isSupportBaseball {
                    log += "\n      棒球 / isSupportBaseball"
                }
                if model.isSupportTableTennis {
                    log += "\n      乒乓球 / isSupportTableTennis"
                }
                if model.isSupportCricket {
                    log += "\n      板球 / isSupportCricket"
                }
                if model.isSupportRugby {
                    log += "\n      橄榄球 / isSupportRugby"
                }
            }
        }
        if self.functionList_step {
            log += "\n计步"
        }
        if self.functionList_sleep {
            log += "\n睡眠"
        }
        if self.functionList_heartrate {
            log += "\n心率"
            if let model = self.functionDetail_heartrate {
                log += "\n      \(model.isSupportSingleClickData ? "":"不")支持点击测量数据存储"
                log += "\n      \(model.isSupportAllDayData ? "":"不")支持全天测量数据存储"
                log += "\n      一天点击测量存储总条数:\(model.singleClickDataCount)"
                log += "\n      全天测量时间间隔:\(model.allDayDataTimeInterval)分钟"
            }
        }
        if self.functionList_bloodPressure {
            log += "\n血压"
            if let model = self.functionDetail_bloodPressure {
                log += "\n      \(model.isSupportSingleClickData ? "":"不")支持点击测量数据存储"
                log += "\n      \(model.isSupportAllDayData ? "":"不")支持全天测量数据存储"
                log += "\n      一天点击测量存储总条数:\(model.singleClickDataCount)"
                log += "\n      全天测量时间间隔:\(model.allDayDataTimeInterval)分钟"
            }
        }
        if self.functionList_bloodOxygen {
            log += "\n血氧"
            if let model = self.functionDetail_bloodOxygen {
                log += "\n      \(model.isSupportSingleClickData ? "":"不")支持点击测量数据存储"
                log += "\n      \(model.isSupportAllDayData ? "":"不")支持全天测量数据存储"
                log += "\n      一天点击测量存储总条数:\(model.singleClickDataCount)"
                log += "\n      全天测量时间间隔:\(model.allDayDataTimeInterval)分钟"
            }
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
                if model.isSupportExtensionNotification {
                    log += "\n      拓展推送 / isSupportExtensionNotification"
                }
                if model.isSupportAlipay {
                    log += "\n      支付宝 / isSupportAlipay"
                }
                if model.isSupportTaoBao {
                    log += "\n      淘宝 / isSupportTaoBao"
                }
                if model.isSupportDouYin {
                    log += "\n      抖音 / isSupportDouYin"
                }
                if model.isSupportDingDing {
                    log += "\n      钉钉 / isSupportDingDing"
                }
                if model.isSupportJingDong {
                    log += "\n      京东 / isSupportJingDong"
                }
                if model.isSupportGmail {
                    log += "\n      Gmail / isSupportGmail"
                }
                if model.isSupportViber {
                    log += "\n      Viber / isSupportViber"
                }
                if model.isSupportYouTube {
                    log += "\n      YouTube / isSupportYouTube"
                }
                if model.isSupportKakaoTalk {
                    log += "\n      KakaoTalk / isSupportKakaoTalk"
                }
                if model.isSupportTelegram {
                    log += "\n      Telegram / isSupportTelegram"
                }
                if model.isSupportHangouts {
                    log += "\n      Hangouts / isSupportHangouts"
                }
                if model.isSupportVkontakte {
                    log += "\n      Vkontakte / isSupportVkontakte"
                }
                if model.isSupportFlickr {
                    log += "\n      Flickr / isSupportFlickr"
                }
                if model.isSupportTumblr {
                    log += "\n      Tumblr / isSupportTumblr"
                }
                if model.isSupportPinterest {
                    log += "\n      Pinterest / isSupportPinterest"
                }
                if model.isSupportTruecaller {
                    log += "\n      Truecaller / isSupportTruecaller"
                }
                if model.isSupportPaytm {
                    log += "\n      Paytm / isSupportPaytm"
                }
                if model.isSupportZalo {
                    log += "\n      Zalo / isSupportZalo"
                }
                if model.isSupportMicrosoftTeams {
                    log += "\n      MicrosoftTeams / isSupportMicrosoftTeams"
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
                log += "\n      设备端\(model.isSupportEdit ? "支持":"不支持")增加/删除"
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
                if model.isSupportDutch {
                    log += "\n      荷兰语 / isSupportDutch"
                }
                if model.isSupportTurkish {
                    log += "\n      土耳其 / isSupportTurkish"
                }
                if model.isSupportRomanian {
                    log += "\n      罗马尼亚 / isSupportRomanian"
                }
                if model.isSupportDanish {
                    log += "\n      丹麦语 / isSupportDanish"
                }
                if model.isSupportSwedish {
                    log += "\n      瑞典语 / isSupportSwedish"
                }
                if model.isSupportCzech {
                    log += "\n      捷克语 / isSupportCzech"
                }
                if model.isSupportBengali {
                    log += "\n      孟加拉语 / isSupportBengali"
                }
                if model.isSupportPersian {
                    log += "\n      波斯语 / isSupportPersian"
                }
                if model.isSupportHebrew {
                    log += "\n      希伯来语 / isSupportHebrew"
                }
                if model.isSupportMalay {
                    log += "\n      马来语 / isSupportMalay"
                }
                if model.isSupportSlovak {
                    log += "\n      斯洛伐克语 / isSupportSlovak"
                }
                if model.isSupportXhosa {
                    log += "\n      科萨语 / isSupportXhosa"
                }
                if model.isSupportSlovenian {
                    log += "\n      斯洛文尼亚语 / isSupportSlovenian"
                }
                if model.isSupportHungarian {
                    log += "\n      匈牙利语 / isSupportHungarian"
                }
                if model.isSupportLithuanian {
                    log += "\n      立陶宛语 / isSupportLithuanian"
                }
                if model.isSupportUrdu {
                    log += "\n      乌尔都语 / isSupportUrdu"
                }
                if model.isSupportBulgarian {
                    log += "\n      保加利亚语 / isSupportBulgarian"
                }
                if model.isSupportCroatian {
                    log += "\n      克罗地亚语 / isSupportCroatian"
                }
                if model.isSupportLatvian {
                    log += "\n      拉脱维亚语 / isSupportLatvian"
                }
                if model.isSupportEstonian {
                    log += "\n      爱沙尼亚语 / isSupportEstonian"
                }
                if model.isSupportKhmer {
                    log += "\n      高棉语 / isSupportKhmer"
                }
            }
        }
        if self.functionList_screenConreol {
            log += "\n背光控制"
            if let model = self.functionDetail_screenControl {
                log += "\n      屏幕亮度最大等级 \(model.screenLevelCount)"
                log += "\n      亮屏时长最大值 \(model.screenTimeLong_max)"
                log += "\n      亮屏时长最小值 \(model.screenTimeLong_min)"
                log += "\n      亮屏时长间隔 \(model.screenTimeLong_interval)"
            }
        }
        if self.functionList_addressBook {
            log += "\n通讯录"
            if let model = self.functionDetail_addressBook {
                log += "\n      通讯录最多支持 \(model.maxContactCount) 个联系人"
            }
        }
        if self.functionList_onlineDial {
            log += "\n在线表盘"
        }
        if self.functionList_customDial {
            log += "\n自定义表盘"
            if let model = self.functionDetail_customDial {
                log += "\n      \(model.isSupportfontColor ? "支持":"不支持")字体颜色设置"
            }
        }
        if self.functionList_localDial {
            log += "\n本地表盘"
            if let model = self.functionDetail_localDial {
                log += "\n      内置 \(model.maxDialCount) 个本地表盘"
            }
        }
        if self.functionList_hrWarning {
            log += "\n心率预警"
            if let model = self.functionDetail_hrWarning {
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
        if self.functionList_screenType {
            log += "\n手表款式"
            if let model = self.functionDetail_screenType {
                log += "\n      手表款式 \(model.supportType)(0方1圆2圆角)"
            }
        }
        if self.functionList_sportCountdown {
            log += "\n运动开始倒计时"
            if let model = self.functionDetail_sportCountdown {
                log += "\n      倒计时时长 \(model.countDownTime) 秒"
            }
        }
        if self.functionList_newPortocol {
            log += "\n支持新协议"
            if let model = self.functionDetail_newPortocol {
                log += "\n      最大mtu长度:\(model.maxMtuCount)"
            }
        }
        if self.functionList_lowBattery {
            log += "\n低电量提醒"
        }
        if self.functionList_exerciseInteraction {
            log += "\n运动交互"
        }
        if self.functionList_clearData {
            log += "\n清除数据"
        }
        if self.functionList_bind {
            log += "\n绑定/解绑"
        }
        if self.functionList_weatherExtend {
            log += "\n天气扩展"
        }
        if self.functionList_newPortocol {
            log += "\n新协议"
        }
        if self.functionList_platformType {
            log += "\n手表平台类型"
            if let model = self.functionDetail_platformType {
                log += "\n平台类型:\(model.platform)"
            }
        }
        if self.functionList_bloodSugar {
            log += "\n血糖检测"
            if let model = self.functionDetail_bloodSugar {
                log += "\n      \(model.isSupportSingleClickData ? "":"不")支持点击测量数据存储"
                log += "\n      \(model.isSupportAllDayData ? "":"不")支持全天测量数据存储"
                log += "\n      一天点击测量存储总条数:\(model.singleClickDataCount)"
                log += "\n      全天测量时间间隔:\(model.allDayDataTimeInterval)分钟"
            }
        }
        if self.functionList_pressure {
            log += "\n压力检测"
            if let model = self.functionDetail_pressure {
                log += "\n      \(model.isSupportSingleClickData ? "":"不")支持点击测量数据存储"
                log += "\n      \(model.isSupportAllDayData ? "":"不")支持全天测量数据存储"
                log += "\n      一天点击测量存储总条数:\(model.singleClickDataCount)"
                log += "\n      全天测量时间间隔:\(model.allDayDataTimeInterval)分钟"
            }
        }
        if self.functionList_electrocardiogram {
            log += "\n心电检测"
            if let model = self.functionDetail_electrocardiogram {
                log += "\n      \(model.isSupportSingleClickData ? "":"不")支持点击测量数据存储"
                log += "\n      \(model.isSupportAllDayData ? "":"不")支持全天测量数据存储"
                log += "\n      一天点击测量存储总条数:\(model.singleClickDataCount)"
                log += "\n      全天测量时间间隔:\(model.allDayDataTimeInterval)分钟"
            }
        }
        if self.functionList_bodyTemperature {
            log += "\n体温检测"
            if let model = self.functionDetail_bodyTemperature {
                log += "\n      \(model.isSupportSingleClickData ? "":"不")支持点击测量数据存储"
                log += "\n      \(model.isSupportAllDayData ? "":"不")支持全天测量数据存储"
                log += "\n      一天点击测量存储总条数:\(model.singleClickDataCount)"
                log += "\n      全天测量时间间隔:\(model.allDayDataTimeInterval)分钟"
            }
        }
        if self.functionList_sosContactPerson {
            log += "\nsos紧急联系人"
        }
        if self.functionList_worshipAlarm {
            log += "\n朝拜闹钟"
        }
        if self.functionList_localPlay {
            log += "\n本地播放"
            if let model = self.functionDetail_localPlay {
                if model.isSupportMp3 {
                    log += "\n      支持MP3格式文件"
                }
                if model.isSupportWav {
                    log += "\n      支持WAV格式文件"
                }
            }
        }
        if self.functionList_locationGps {
            log += "\ngps定位"
            if let model = self.functionDetail_locationGps {
                if model.isSupportAG3352Q {
                    log += "\n      AG3352Q"
                }
            }
        }
        if self.functionList_customSports {
            log += "\n自定义百种运动"
            if let model = self.functionDetail_customSports {
                if model.isSupportFitness {
                    log += "\n      健走"
                }
                if model.isSupportTrailRunning {
                    log += "\n      越野跑"
                }
                if model.isSupportDumbbells {
                    log += "\n      哑铃"
                }
                if model.isSupportRowingMachine {
                    log += "\n      划船机"
                }
                if model.isSupportEllipticalMachine {
                    log += "\n      椭圆机"
                }
                if model.isSupportAerobics {
                    log += "\n      健身操"
                }
                if model.isSupportKayak {
                    log += "\n      皮划艇"
                }
                if model.isSupportRollerSkating {
                    log += "\n      轮滑"
                }
                if model.isSupportPlaygroundRunning {
                    log += "\n      操场跑步"
                }
                if model.isSupportRunToLoseFat {
                    log += "\n      减脂跑步"
                }
                if model.isSupportOutdoorCycling {
                    log += "\n      户外骑行"
                }
                if model.isSupportIndoorCycling {
                    log += "\n      室内骑行"
                }
                if model.isSupportMountainBiking {
                    log += "\n      山地骑行"
                }
                if model.isSupportOrienteering {
                    log += "\n      定向越野"
                }
                if model.isSupportMixedAerobic {
                    log += "\n      混合有氧"
                }
                if model.isSupportCombatExercises {
                    log += "\n      搏击操"
                }
                if model.isSupportCoreTraining {
                    log += "\n      核心训练"
                }
                if model.isSupportCrossTraining {
                    log += "\n      交叉训练"
                }
                if model.isSupportTeamGymnastics {
                    log += "\n      团体操"
                }
                if model.isSupportStrengthTraining {
                    log += "\n      力量训练"
                }
                if model.isSupportIntervalTraining {
                    log += "\n      间歇训练"
                }
                if model.isSupportFlexibilityTraining {
                    log += "\n      柔韧训练"
                }
                if model.isSupportStretching {
                    log += "\n      拉伸"
                }
                if model.isSupportFitnessExercises {
                    log += "\n      健身运动"
                }
                if model.isSupportBalanceTraining {
                    log += "\n      平衡训练"
                }
                if model.isSupportStepTraining {
                    log += "\n      踏步训练"
                }
                if model.isSupportBattleRope {
                    log += "\n      战绳"
                }
                if model.isSupportFreeTraining {
                    log += "\n      自由训练"
                }
                if model.isSupportSkiing {
                    log += "\n      滑雪"
                }
                if model.isSupportRockClimbing {
                    log += "\n      攀岩"
                }
                if model.isSupportFishing {
                    log += "\n      钓鱼"
                }
                if model.isSupportHunting {
                    log += "\n      打猎"
                }
                if model.isSupportSkateboard {
                    log += "\n      滑板"
                }
                if model.isSupportParkour {
                    log += "\n      跑酷"
                }
                if model.isSupportDuneBuggy {
                    log += "\n      沙滩车"
                }
                if model.isSupportDirtBike {
                    log += "\n      越野摩托"
                }
                if model.isSupportHandRollingCar {
                    log += "\n      手摇车"
                }
                if model.isSupportPilates {
                    log += "\n      普拉提"
                }
                if model.isSupportFlyingDarts {
                    log += "\n      飞镖"
                }
                if model.isSupportSnowboarding {
                    log += "\n      双板滑雪"
                }
                if model.isSupportWalkingMachine {
                    log += "\n      漫步机"
                }
                if model.isSupportSkydiving {
                    log += "\n      跳伞"
                }
                if model.isSupportCrossCountrySkiing {
                    log += "\n      越野滑雪"
                }
                if model.isSupportBungeeJumping {
                    log += "\n      蹦极"
                }
                if model.isSupportTheSwing {
                    log += "\n      秋千"
                }
                if model.isSupportFlyingKite {
                    log += "\n      放风筝"
                }
                if model.isSupportHulaHoops {
                    log += "\n      呼啦圈"
                }
                if model.isSupportArchery {
                    log += "\n      射箭"
                }
                if model.isSupportRaceWalking {
                    log += "\n      竞走"
                }
                if model.isSupportRacingCars {
                    log += "\n      赛车"
                }
                if model.isSupportMarathon {
                    log += "\n      马拉松"
                }
                if model.isSupportObstacleCourse {
                    log += "\n      障碍赛"
                }
                if model.isSupportTugOfWar {
                    log += "\n      拔河"
                }
                if model.isSupportDragonBoat {
                    log += "\n      龙舟"
                }
                if model.isSupportHighJump {
                    log += "\n      跳高"
                }
                if model.isSupportSailing {
                    log += "\n      帆船运动"
                }
                if model.isSupportTriathlon {
                    log += "\n      铁人三项"
                }
                if model.isSupportHorseRacing {
                    log += "\n      赛马"
                }
                if model.isSupportBMX {
                    log += "\n      小轮车"
                }
                if model.isSupportParallelBar {
                    log += "\n      双杠"
                }
                if model.isSupportGolf {
                    log += "\n      高尔夫"
                }
                if model.isSupportBowlingBall {
                    log += "\n      保龄球"
                }
                if model.isSupportSquash {
                    log += "\n      壁球"
                }
                if model.isSupportPolo {
                    log += "\n      马球"
                }
                if model.isSupportWallBall {
                    log += "\n      墙球"
                }
                if model.isSupportBilliards {
                    log += "\n      桌球"
                }
                if model.isSupportWaterBalloon {
                    log += "\n      水球"
                }
                if model.isSupportShuttlecock {
                    log += "\n      毽球"
                }
                if model.isSupportIndoorFootball {
                    log += "\n      室内足球"
                }
                if model.isSupportSandbagBall {
                    log += "\n      沙包球"
                }
                if model.isSupportToTheBall {
                    log += "\n      地掷球"
                }
                if model.isSupportJaiAlai {
                    log += "\n      回力球"
                }
                if model.isSupportFloorball {
                    log += "\n      地板球"
                }
                if model.isSupportPicogramBalls {
                    log += "\n      匹克球"
                }
                if model.isSupportBeachVolleyball {
                    log += "\n      沙滩排球"
                }
                if model.isSupportSoftball {
                    log += "\n      垒球"
                }
                if model.isSupportSquareDance {
                    log += "\n      广场舞"
                }
                if model.isSupportBellyDance {
                    log += "\n      肚皮舞"
                }
                if model.isSupportBallet {
                    log += "\n      芭蕾舞"
                }
                if model.isSupportStreetDance {
                    log += "\n      街舞"
                }
                if model.isSupportLatinDance {
                    log += "\n      拉丁舞"
                }
                if model.isSupportJazzDance {
                    log += "\n      爵士舞"
                }
                if model.isSupportPoleDancing {
                    log += "\n      钢管舞"
                }
                if model.isSupportTheDisco {
                    log += "\n      迪斯科"
                }
                if model.isSupportTapDance {
                    log += "\n      踢踏舞"
                }
                if model.isSupportOtherDances {
                    log += "\n      其它舞蹈"
                }
                if model.isSupportBoxing {
                    log += "\n      拳击"
                }
                if model.isSupportWrestling {
                    log += "\n      摔跤"
                }
                if model.isSupportMartialArts {
                    log += "\n      武术"
                }
                if model.isSupportTaiChi {
                    log += "\n      太极"
                }
                if model.isSupportThaiBoxing {
                    log += "\n      泰拳"
                }
                if model.isSupportJudo {
                    log += "\n      柔道"
                }
                if model.isSupportTaekwondo {
                    log += "\n      跆拳道"
                }
                if model.isSupportKarate {
                    log += "\n      空手道"
                }
                if model.isSupportKickboxing {
                    log += "\n      自由搏击"
                }
                if model.isSupportSwordFighting {
                    log += "\n      剑术"
                }
                if model.isSupportJiuJitsu {
                    log += "\n      柔术"
                }
            }
        }
        return log
    }
}

@objc public class ZyFunctionModel_exercise:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportRunOutside = false
    @objc public private(set) var isSupportWalk = false
    @objc public private(set) var isSupportCycling = false
    @objc public private(set) var isSupportBasketball = false
    @objc public private(set) var isSupportFootball = false
    @objc public private(set) var isSupportBadminton = false
    @objc public private(set) var isSupportJumpRope = false
    @objc public private(set) var isSupportSwimming = false
    @objc public private(set) var isSupportRunIndoor = false
    @objc public private(set) var isSupportVolleyball = false
    @objc public private(set) var isSupportWalkFast = false
    @objc public private(set) var isSupportSpinning = false
    @objc public private(set) var isSupportSitUps = false
    @objc public private(set) var isSupportMountainClimbing = false
    @objc public private(set) var isSupportYoga = false
    @objc public private(set) var isSupportDance = false
    @objc public private(set) var isSupportJumpingJacks = false
    @objc public private(set) var isSupportGymnastics = false
    @objc public private(set) var isSupportRowing = false
    @objc public private(set) var isSupportTennis = false
    @objc public private(set) var isSupportHockey = false
    @objc public private(set) var isSupportBaseball = false
    @objc public private(set) var isSupportTableTennis = false
    @objc public private(set) var isSupportCricket = false
    @objc public private(set) var isSupportRugby = false
    
    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<64 {
            let state = (result >> i) & 0x01

            switch i {
            case 0:self.isSupportRunOutside = state == 0 ? false:true
                break
            case 1:self.isSupportWalk = state == 0 ? false:true
                break
            case 2:self.isSupportCycling = state == 0 ? false:true
                break
            case 3:self.isSupportBasketball = state == 0 ? false:true
                break
            case 4:self.isSupportFootball = state == 0 ? false:true
                break
            case 5:self.isSupportBadminton = state == 0 ? false:true
                break
            case 6:self.isSupportJumpRope = state == 0 ? false:true
                break
            case 7:self.isSupportSwimming = state == 0 ? false:true
                break
            case 8:self.isSupportRunIndoor = state == 0 ? false:true
                break
            case 9:self.isSupportVolleyball = state == 0 ? false:true
                break
            case 10:self.isSupportWalkFast = state == 0 ? false:true
                break
            case 11:self.isSupportSpinning = state == 0 ? false:true
                break
            case 12:self.isSupportSitUps = state == 0 ? false:true
                break
            case 13:self.isSupportMountainClimbing = state == 0 ? false:true
                break
            case 14:self.isSupportYoga = state == 0 ? false:true
                break
            case 15:self.isSupportDance = state == 0 ? false:true
                break
            case 16:self.isSupportJumpingJacks = state == 0 ? false:true
                break
            case 17:self.isSupportGymnastics = state == 0 ? false:true
                break
            case 18:self.isSupportRowing = state == 0 ? false:true
                break
            case 19:self.isSupportTennis = state == 0 ? false:true
                break
            case 20:self.isSupportHockey = state == 0 ? false:true
                break
            case 21:self.isSupportBaseball = state == 0 ? false:true
                break
            case 22:self.isSupportTableTennis = state == 0 ? false:true
                break
            case 23:self.isSupportCricket = state == 0 ? false:true
                break
            case 24:self.isSupportRugby = state == 0 ? false:true
                break
            case 25:
                break
            case 26:
                break
            default:
                break
            }
        }
    }
}

@objc public class ZyFunctionModel_customSports:NSObject {
    @objc public private(set) var isSupportFitness = false                      //0 健走
    @objc public private(set) var isSupportTrailRunning = false                 //1 越野跑
    @objc public private(set) var isSupportDumbbells = false                    //2 哑铃
    @objc public private(set) var isSupportRowingMachine = false                //3 划船机
    @objc public private(set) var isSupportEllipticalMachine = false            //4 椭圆机
    @objc public private(set) var isSupportAerobics = false                     //5 健身操
    @objc public private(set) var isSupportKayak = false                        //6 皮划艇
    @objc public private(set) var isSupportRollerSkating = false                //7 轮滑
    @objc public private(set) var isSupportPlaygroundRunning = false            //8 操场跑步
    @objc public private(set) var isSupportRunToLoseFat = false                 //9 减脂跑步
    @objc public private(set) var isSupportOutdoorCycling = false               //10 户外骑行
    @objc public private(set) var isSupportIndoorCycling = false                //11 室内骑行
    @objc public private(set) var isSupportMountainBiking = false               //12 山地骑行
    @objc public private(set) var isSupportOrienteering = false                 //13 定向越野
    @objc public private(set) var isSupportMixedAerobic = false                 //14 混合有氧
    @objc public private(set) var isSupportCombatExercises = false              //15 搏击操
    @objc public private(set) var isSupportCoreTraining = false                 //16 核心训练
    @objc public private(set) var isSupportCrossTraining = false                //17 交叉训练
    @objc public private(set) var isSupportTeamGymnastics = false               //18 团体操
    @objc public private(set) var isSupportStrengthTraining = false             //19 力量训练
    @objc public private(set) var isSupportIntervalTraining = false             //20 间歇训练
    @objc public private(set) var isSupportFlexibilityTraining = false          //21 柔韧训练
    @objc public private(set) var isSupportStretching = false                   //22 拉伸
    @objc public private(set) var isSupportFitnessExercises = false             //23 健身运动
    @objc public private(set) var isSupportBalanceTraining = false              //24 平衡训练
    @objc public private(set) var isSupportStepTraining = false                 //25 踏步训练
    @objc public private(set) var isSupportBattleRope = false                   //26 战绳
    @objc public private(set) var isSupportFreeTraining = false                 //27 自由训练
    @objc public private(set) var isSupportSkiing = false                       //28 滑雪
    @objc public private(set) var isSupportRockClimbing = false                 //29 攀岩
    @objc public private(set) var isSupportFishing = false                      //30 钓鱼
    @objc public private(set) var isSupportHunting = false                      //31 打猎
    @objc public private(set) var isSupportSkateboard = false                   //32 滑板
    @objc public private(set) var isSupportParkour = false                      //33 跑酷
    @objc public private(set) var isSupportDuneBuggy = false                    //34 沙滩车
    @objc public private(set) var isSupportDirtBike = false                     //35 越野摩托
    @objc public private(set) var isSupportHandRollingCar = false               //36 手摇车
    @objc public private(set) var isSupportPilates = false                      //37 普拉提
    @objc public private(set) var isSupportFlyingDarts = false                  //38 飞镖
    @objc public private(set) var isSupportSnowboarding = false                 //39 双板滑雪
    @objc public private(set) var isSupportWalkingMachine = false               //40 漫步机
    @objc public private(set) var isSupportSkydiving = false                    //41 跳伞
    @objc public private(set) var isSupportCrossCountrySkiing = false           //42 越野滑雪
    @objc public private(set) var isSupportBungeeJumping = false                //43 蹦极
    @objc public private(set) var isSupportTheSwing = false                     //44 秋千
    @objc public private(set) var isSupportFlyingKite = false                   //45 放风筝
    @objc public private(set) var isSupportHulaHoops = false                    //46 呼啦圈
    @objc public private(set) var isSupportArchery = false                      //47 射箭
    @objc public private(set) var isSupportRaceWalking = false                  //48 竞走
    @objc public private(set) var isSupportRacingCars = false                   //49 赛车
    @objc public private(set) var isSupportMarathon = false                     //50 马拉松
    @objc public private(set) var isSupportObstacleCourse = false               //51 障碍赛
    @objc public private(set) var isSupportTugOfWar = false                     //52 拔河
    @objc public private(set) var isSupportDragonBoat = false                   //53 龙舟
    @objc public private(set) var isSupportHighJump = false                     //54 跳高
    @objc public private(set) var isSupportSailing = false                      //55 帆船运动
    @objc public private(set) var isSupportTriathlon = false                    //56 铁人三项
    @objc public private(set) var isSupportHorseRacing = false                  //57 赛马
    @objc public private(set) var isSupportBMX = false                          //58 小轮车
    @objc public private(set) var isSupportParallelBar = false                  //59 双杠
    @objc public private(set) var isSupportGolf = false                         //60 高尔夫
    @objc public private(set) var isSupportBowlingBall = false                  //61 保龄球
    @objc public private(set) var isSupportSquash = false                       //62 壁球
    @objc public private(set) var isSupportPolo = false                         //63 马球
    @objc public private(set) var isSupportWallBall = false                     //64 墙球
    @objc public private(set) var isSupportBilliards = false                    //65 桌球
    @objc public private(set) var isSupportWaterBalloon = false                 //66 水球
    @objc public private(set) var isSupportShuttlecock = false                  //67 毽球
    @objc public private(set) var isSupportIndoorFootball = false               //68 室内足球
    @objc public private(set) var isSupportSandbagBall = false                  //69 沙包球
    @objc public private(set) var isSupportToTheBall = false                    //70 地掷球
    @objc public private(set) var isSupportJaiAlai = false                      //71 回力球
    @objc public private(set) var isSupportFloorball = false                    //72 地板球
    @objc public private(set) var isSupportPicogramBalls = false                //73 匹克球
    @objc public private(set) var isSupportBeachVolleyball = false              //74 沙滩排球
    @objc public private(set) var isSupportSoftball = false                     //75 垒球
    @objc public private(set) var isSupportSquareDance = false                  //76 广场舞
    @objc public private(set) var isSupportBellyDance = false                   //77 肚皮舞
    @objc public private(set) var isSupportBallet = false                       //78 芭蕾舞
    @objc public private(set) var isSupportStreetDance = false                  //79 街舞
    @objc public private(set) var isSupportLatinDance = false                   //80 拉丁舞
    @objc public private(set) var isSupportJazzDance = false                    //81 爵士舞
    @objc public private(set) var isSupportPoleDancing = false                  //82 钢管舞
    @objc public private(set) var isSupportTheDisco = false                     //83 迪斯科
    @objc public private(set) var isSupportTapDance = false                     //84 踢踏舞
    @objc public private(set) var isSupportOtherDances = false                  //85 其它舞蹈
    @objc public private(set) var isSupportBoxing = false                       //86 拳击
    @objc public private(set) var isSupportWrestling = false                    //87 摔跤
    @objc public private(set) var isSupportMartialArts = false                  //88 武术
    @objc public private(set) var isSupportTaiChi = false                       //89 太极
    @objc public private(set) var isSupportThaiBoxing = false                   //90 泰拳
    @objc public private(set) var isSupportJudo = false                         //91 柔道
    @objc public private(set) var isSupportTaekwondo = false                    //92 跆拳道
    @objc public private(set) var isSupportKarate = false                       //93 空手道
    @objc public private(set) var isSupportKickboxing = false                   //94 自由搏击
    @objc public private(set) var isSupportSwordFighting = false                //95 剑术
    @objc public private(set) var isSupportJiuJitsu = false                     //96 柔术
    init(val:[UInt8]) {
        
        super.init()
        
        for i in 0..<val.count {
            var state:UInt8 = 0
            let result = val[i]
            for j in 0..<8 {
                state = (result >> i) & 0x01
                
                switch i*8+j {
                case 0:self.isSupportFitness = state == 0 ? false:true
                    break
                case 1:self.isSupportTrailRunning = state == 0 ? false:true
                    break
                case 2:self.isSupportDumbbells = state == 0 ? false:true
                    break
                case 3:self.isSupportRowingMachine = state == 0 ? false:true
                    break
                case 4:self.isSupportEllipticalMachine = state == 0 ? false:true
                    break
                case 5:self.isSupportAerobics = state == 0 ? false:true
                    break
                case 6:self.isSupportKayak = state == 0 ? false:true
                    break
                case 7:self.isSupportRollerSkating = state == 0 ? false:true
                    break
                case 8:self.isSupportPlaygroundRunning = state == 0 ? false:true
                    break
                case 9:self.isSupportRunToLoseFat = state == 0 ? false:true
                    break
                case 10:self.isSupportOutdoorCycling = state == 0 ? false:true
                    break
                case 11:self.isSupportIndoorCycling = state == 0 ? false:true
                    break
                case 12:self.isSupportMountainBiking = state == 0 ? false:true
                    break
                case 13:self.isSupportOrienteering = state == 0 ? false:true
                    break
                case 14:self.isSupportMixedAerobic = state == 0 ? false:true
                    break
                case 15:self.isSupportCombatExercises = state == 0 ? false:true
                    break
                case 16:self.isSupportCoreTraining = state == 0 ? false:true
                    break
                case 17:self.isSupportCrossTraining = state == 0 ? false:true
                    break
                case 18:self.isSupportTeamGymnastics = state == 0 ? false:true
                    break
                case 19:self.isSupportStrengthTraining = state == 0 ? false:true
                    break
                case 20:self.isSupportIntervalTraining = state == 0 ? false:true
                    break
                case 21:self.isSupportFlexibilityTraining = state == 0 ? false:true
                    break
                case 22:self.isSupportStretching = state == 0 ? false:true
                    break
                case 23:self.isSupportFitnessExercises = state == 0 ? false:true
                    break
                case 24:self.isSupportBalanceTraining = state == 0 ? false:true
                    break
                case 25:self.isSupportStepTraining = state == 0 ? false:true
                    break
                case 26:self.isSupportBattleRope = state == 0 ? false:true
                    break
                case 27:self.isSupportFreeTraining = state == 0 ? false:true
                    break
                case 28:self.isSupportSkiing = state == 0 ? false:true
                    break
                case 29:self.isSupportRockClimbing = state == 0 ? false:true
                    break
                case 30:self.isSupportFishing = state == 0 ? false:true
                    break
                case 31:self.isSupportHunting = state == 0 ? false:true
                    break
                case 32:self.isSupportSkateboard = state == 0 ? false:true
                    break
                case 33:self.isSupportParkour = state == 0 ? false:true
                    break
                case 34:self.isSupportDuneBuggy = state == 0 ? false:true
                    break
                case 35:self.isSupportDirtBike = state == 0 ? false:true
                    break
                case 36:self.isSupportHandRollingCar = state == 0 ? false:true
                    break
                case 37:self.isSupportPilates = state == 0 ? false:true
                    break
                case 38:self.isSupportFlyingDarts = state == 0 ? false:true
                    break
                case 39:self.isSupportSnowboarding = state == 0 ? false:true
                    break
                case 40:self.isSupportWalkingMachine = state == 0 ? false:true
                    break
                case 41:self.isSupportSkydiving = state == 0 ? false:true
                    break
                case 42:self.isSupportCrossCountrySkiing = state == 0 ? false:true
                    break
                case 43:self.isSupportBungeeJumping = state == 0 ? false:true
                    break
                case 44:self.isSupportTheSwing = state == 0 ? false:true
                    break
                case 45:self.isSupportFlyingKite = state == 0 ? false:true
                    break
                case 46:self.isSupportHulaHoops = state == 0 ? false:true
                    break
                case 47:self.isSupportArchery = state == 0 ? false:true
                    break
                case 48:self.isSupportRaceWalking = state == 0 ? false:true
                    break
                case 49:self.isSupportRacingCars = state == 0 ? false:true
                    break
                case 50:self.isSupportMarathon = state == 0 ? false:true
                    break
                case 51:self.isSupportObstacleCourse = state == 0 ? false:true
                    break
                case 52:self.isSupportTugOfWar = state == 0 ? false:true
                    break
                case 53:self.isSupportDragonBoat = state == 0 ? false:true
                    break
                case 54:self.isSupportHighJump = state == 0 ? false:true
                    break
                case 55:self.isSupportSailing = state == 0 ? false:true
                    break
                case 56:self.isSupportTriathlon = state == 0 ? false:true
                    break
                case 57:self.isSupportHorseRacing = state == 0 ? false:true
                    break
                case 58:self.isSupportBMX = state == 0 ? false:true
                    break
                case 59:self.isSupportParallelBar = state == 0 ? false:true
                    break
                case 60:self.isSupportGolf = state == 0 ? false:true
                    break
                case 61:self.isSupportBowlingBall = state == 0 ? false:true
                    break
                case 62:self.isSupportSquash = state == 0 ? false:true
                    break
                case 63:self.isSupportPolo = state == 0 ? false:true
                    break
                case 64:self.isSupportWallBall = state == 0 ? false:true
                    break
                case 65:self.isSupportBilliards = state == 0 ? false:true
                    break
                case 66:self.isSupportWaterBalloon = state == 0 ? false:true
                    break
                case 67:self.isSupportShuttlecock = state == 0 ? false:true
                    break
                case 68:self.isSupportIndoorFootball = state == 0 ? false:true
                    break
                case 69:self.isSupportSandbagBall = state == 0 ? false:true
                    break
                case 70:self.isSupportToTheBall = state == 0 ? false:true
                    break
                case 71:self.isSupportJaiAlai = state == 0 ? false:true
                    break
                case 72:self.isSupportFloorball = state == 0 ? false:true
                    break
                case 73:self.isSupportPicogramBalls = state == 0 ? false:true
                    break
                case 74:self.isSupportBeachVolleyball = state == 0 ? false:true
                    break
                case 75:self.isSupportSoftball = state == 0 ? false:true
                    break
                case 76:self.isSupportSquareDance = state == 0 ? false:true
                    break
                case 77:self.isSupportBellyDance = state == 0 ? false:true
                    break
                case 78:self.isSupportBallet = state == 0 ? false:true
                    break
                case 79:self.isSupportStreetDance = state == 0 ? false:true
                    break
                case 80:self.isSupportLatinDance = state == 0 ? false:true
                    break
                case 81:self.isSupportJazzDance = state == 0 ? false:true
                    break
                case 82:self.isSupportPoleDancing = state == 0 ? false:true
                    break
                case 83:self.isSupportTheDisco = state == 0 ? false:true
                    break
                case 84:self.isSupportTapDance = state == 0 ? false:true
                    break
                case 85:self.isSupportOtherDances = state == 0 ? false:true
                    break
                case 86:self.isSupportBoxing = state == 0 ? false:true
                    break
                case 87:self.isSupportWrestling = state == 0 ? false:true
                    break
                case 88:self.isSupportMartialArts = state == 0 ? false:true
                    break
                case 89:self.isSupportTaiChi = state == 0 ? false:true
                    break
                case 90:self.isSupportThaiBoxing = state == 0 ? false:true
                    break
                case 91:self.isSupportJudo = state == 0 ? false:true
                    break
                case 92:self.isSupportTaekwondo = state == 0 ? false:true
                    break
                case 93:self.isSupportKarate = state == 0 ? false:true
                    break
                case 94:self.isSupportKickboxing = state == 0 ? false:true
                    break
                case 95:self.isSupportSwordFighting = state == 0 ? false:true
                    break
                case 96:self.isSupportJiuJitsu = state == 0 ? false:true
                    break
                case 97:
                    break
                case 98:
                    break
                case 99:
                    break
                default:
                    break
                }
                
            }
        }
    }
}

@objc public class ZyFunctionModel_notification:NSObject {
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
    @objc public private(set) var isSupportExtensionNotification = false
    @objc public private(set) var isSupportAlipay = false
    @objc public private(set) var isSupportTaoBao = false
    @objc public private(set) var isSupportDouYin = false
    @objc public private(set) var isSupportDingDing = false
    @objc public private(set) var isSupportJingDong = false
    @objc public private(set) var isSupportGmail = false
    @objc public private(set) var isSupportViber = false
    @objc public private(set) var isSupportYouTube = false
    @objc public private(set) var isSupportKakaoTalk = false
    @objc public private(set) var isSupportTelegram = false
    @objc public private(set) var isSupportHangouts = false
    @objc public private(set) var isSupportVkontakte = false
    @objc public private(set) var isSupportFlickr = false
    @objc public private(set) var isSupportTumblr = false
    @objc public private(set) var isSupportPinterest = false
    @objc public private(set) var isSupportTruecaller = false
    @objc public private(set) var isSupportPaytm = false
    @objc public private(set) var isSupportZalo = false
    @objc public private(set) var isSupportMicrosoftTeams = false
    
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
            case 13:self.isSupportExtensionNotification = state == 0 ? false:true
                break
            case 14:
                break
            case 15:
                break
            case 16:self.isSupportAlipay = state == 0 ? false:true
                break
            case 17:self.isSupportTaoBao = state == 0 ? false:true
                break
            case 18:self.isSupportDouYin = state == 0 ? false:true
                break
            case 19:self.isSupportDingDing = state == 0 ? false:true
                break
            case 20:self.isSupportJingDong = state == 0 ? false:true
                break
            case 21:self.isSupportGmail = state == 0 ? false:true
                break
            case 22:self.isSupportViber = state == 0 ? false:true
                break
            case 23:self.isSupportYouTube = state == 0 ? false:true
                break
            case 24:self.isSupportKakaoTalk = state == 0 ? false:true
                break
            case 25:self.isSupportTelegram = state == 0 ? false:true
                break
            case 26:self.isSupportHangouts = state == 0 ? false:true
                break
            case 27:self.isSupportVkontakte = state == 0 ? false:true
                break
            case 28:self.isSupportFlickr = state == 0 ? false:true
                break
            case 29:self.isSupportTumblr = state == 0 ? false:true
                break
            case 30:self.isSupportPinterest = state == 0 ? false:true
                break
            case 31:self.isSupportTruecaller = state == 0 ? false:true
                break
            case 32:self.isSupportPaytm = state == 0 ? false:true
                break
            case 33:self.isSupportZalo = state == 0 ? false:true
                break
            case 34:self.isSupportMicrosoftTeams = state == 0 ? false:true
                break
            case 35://self.isSupport = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}

@objc public class ZyFunctionModel_language:NSObject {
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
    @objc public private(set) var isSupportDutch = false                        //荷兰语
    @objc public private(set) var isSupportTurkish = false                      //土耳其
    @objc public private(set) var isSupportRomanian = false                     //罗马尼亚
    @objc public private(set) var isSupportDanish = false                       //丹麦语
    @objc public private(set) var isSupportSwedish = false                      //瑞典语
    @objc public private(set) var isSupportCzech = false                        //捷克语
    @objc public private(set) var isSupportBengali = false                      //孟加拉语
    @objc public private(set) var isSupportPersian = false                      //波斯语
    @objc public private(set) var isSupportHebrew = false                       //希伯来语
    @objc public private(set) var isSupportMalay = false                        //马来语
    @objc public private(set) var isSupportSlovak = false                       //斯洛伐克语
    @objc public private(set) var isSupportXhosa = false                        //科萨语
    @objc public private(set) var isSupportSlovenian = false                    //斯洛文尼亚语
    @objc public private(set) var isSupportHungarian = false                    //匈牙利语
    @objc public private(set) var isSupportLithuanian = false                   //立陶宛语
    @objc public private(set) var isSupportUrdu = false                         //乌尔都语
    @objc public private(set) var isSupportBulgarian = false                    //保加利亚语
    @objc public private(set) var isSupportCroatian = false                     //克罗地亚语
    @objc public private(set) var isSupportLatvian = false                      //拉脱维亚语
    @objc public private(set) var isSupportEstonian = false                     //爱沙尼亚语
    @objc public private(set) var isSupportKhmer = false                        //高棉语
    //@objc public private(set) var isSupport = false
    
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
            case 19:self.isSupportDutch = state == 0 ? false:true
                break
            case 20:self.isSupportTurkish = state == 0 ? false:true
                break
            case 21:self.isSupportRomanian = state == 0 ? false:true
                break
            case 22:self.isSupportDanish = state == 0 ? false:true
                break
            case 23:self.isSupportSwedish = state == 0 ? false:true
                break
            case 24:self.isSupportBengali = state == 0 ? false:true
                break
            case 25:self.isSupportCzech = state == 0 ? false:true
                break
            case 26:self.isSupportPersian = state == 0 ? false:true
                break
            case 27:self.isSupportHebrew = state == 0 ? false:true
                break
            case 28:self.isSupportMalay = state == 0 ? false:true
                break
            case 29:self.isSupportSlovak = state == 0 ? false:true
                break
            case 30:self.isSupportXhosa = state == 0 ? false:true
                break
            case 31:self.isSupportSlovenian = state == 0 ? false:true
                break
            case 32:self.isSupportHungarian = state == 0 ? false:true
                break
            case 33:self.isSupportLithuanian = state == 0 ? false:true
                break
            case 34:self.isSupportUrdu = state == 0 ? false:true
                break
            case 35:self.isSupportBulgarian = state == 0 ? false:true
                break
            case 36:self.isSupportCroatian = state == 0 ? false:true
                break
            case 37:self.isSupportLatvian = state == 0 ? false:true
                break
            case 38:self.isSupportEstonian = state == 0 ? false:true
                break
            case 39:self.isSupportKhmer = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}

@objc public class ZyFunctionModel_alarm:NSObject {
    @objc public private(set) var maxAlarmCount = 0         //最多支持多少个闹钟
    @objc public private(set) var isSupportEdit = false     //是否支持增删
    
    init(val:[UInt8]) {
        self.maxAlarmCount = Int(val[0])
        if val.count > 1 {
            self.isSupportEdit = Int(val[1]) == 0 ? false:true
        }
        super.init()
    }
}

@objc public class ZyFunctionModel_screenControl:NSObject {
    @objc public private(set) var screenLevelCount = 0           //支持的亮度等级
    @objc public private(set) var screenTimeLong_max = 0         //亮屏时长最大值
    @objc public private(set) var screenTimeLong_min = 0         //亮屏时长最小值
    @objc public private(set) var screenTimeLong_interval = 1    //亮屏时长间隔
    
    init(val:[UInt8]) {
        self.screenLevelCount = Int(val[0])
        self.screenTimeLong_max = Int(val[1])
        self.screenTimeLong_min = Int(val[2])
        if val.count > 3 {
            self.screenTimeLong_interval = Int(val[3])
        }
        super.init()
    }
}

@objc public class ZyFunctionModel_addressBook:NSObject {
    @objc public private(set) var maxContactCount = 0       //支持的最大联系人数量
    
    init(val:[UInt8]) {
        self.maxContactCount = (Int(val[0]) | Int(val[1]) << 8)
        super.init()
    }
}


@objc public class ZyFunctionModel_localDial:NSObject {
    @objc public private(set) var maxDialCount = 0         //内置表盘个数
    
    init(result:Int) {
        self.maxDialCount = result
        super.init()
    }
}

@objc public class ZyFunctionModel_hrWarning:NSObject {
    @objc public private(set) var maxValue = 0         //最大值
    @objc public private(set) var minValue = 0         //最小值
    
    init(val:[UInt8]) {
        self.maxValue = Int(val[0])
        self.minValue = Int(val[1])
        super.init()
    }
}

@objc public class ZyFunctionModel_goal:NSObject {
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

@objc public class ZyFunctionModel_scrrenType:NSObject {

    @objc public private(set) var supportType = 0                //0:方 1:圆 2:圆角
    
    init(result:Int) {
        self.supportType = result
        super.init()
    }
}

@objc public class ZyFunctionModel_sportCountdown:NSObject {
    
    @objc public private(set) var countDownTime = 0                 //倒计时时长
    
    init(result:Int) {
        self.countDownTime = result
        super.init()
    }
}

class ZyFunctionModel_newPortocol:NSObject {
    
    @objc public private(set) var maxMtuCount = 0                 //最大mtu能发送的数量
    
    init(result:Int) {
        self.maxMtuCount = result
        super.init()
    }
}

@objc public class ZyFunctionModel_platformType:NSObject {
    
    @objc public private(set) var platform = 0                 //0:瑞昱,1:杰理,2:Nordic
    
    init(result:Int) {
        self.platform = result
        super.init()
    }
}

@objc public class ZyFunctionModel_customDial:NSObject {
    
    @objc public private(set) var isSupportfontColor = true       //0:不支持,1:支持
    
    init(result:Int) {
        self.isSupportfontColor = result == 0 ? false:true
        super.init()
    }
}

@objc public class ZyFunctionModel_supportMeasurementDataTypeModel:NSObject {
    
    @objc public private(set) var isSupportSingleClickData = false      //0:不支持,1:支持
    @objc public private(set) var isSupportAllDayData = false           //0:不支持,1:支持
    
    @objc public private(set) var singleClickDataCount = 0              //单次点击测量存储总条数
    @objc public private(set) var allDayDataTimeInterval = 0            //全天数据时间间隔
    
    init(val:[UInt8]) {
        
        for i in 0..<8 {
            let state = (val[0] >> i) & 0x01

            switch i {
            case 0:self.isSupportSingleClickData = state == 0 ? false:true
                break
            case 1:self.isSupportAllDayData = state == 0 ? false:true
                break
            default:
                break
            }
        }
        self.singleClickDataCount = Int(val[1])
        self.allDayDataTimeInterval = Int(val[2])
        super.init()
    }
}

@objc public class ZyPersonalModel:NSObject {
    @objc public var age:Int = 0 {
        didSet {
            if self.age < UInt8.min || self.age > UInt8.max {
                self.age = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var gender:Bool = false
    @objc public var height:Float = 0 {
        didSet {
            if Int(self.height)*10 < UInt16.min || Int(self.height)*10 > UInt16.max {
                self.height = 0
                //print(" UInt16.min = \(UInt16.min) , UInt16.max = \(UInt16.max)")
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var weight:Float = 0 {
        didSet {
            if Int(self.weight)*10 < UInt16.min || Int(self.weight)*10 > UInt16.max {
                self.weight = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    public override init() {
        super.init()
    }
}
@objc public enum ZyWeatherType : Int {
    case overcast               //阴
    case fog                    //雾
    case sunny                  //晴
    case cloudy                 //多云
    case snow                   //雪
    case rain                   //雨
}

@objc public class ZyWeatherModel:NSObject {
    @objc public var dayCount:Int = 0 {
        didSet {
            if self.dayCount < Int8.min || self.dayCount > Int8.max {
                self.dayCount = 0
                //print(" Int8.min = \(Int8.min) , Int8.max = \(Int8.max)")
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var type:ZyWeatherType = ZyWeatherType.sunny {
        didSet {
            if self.type.rawValue < Int8.min || self.type.rawValue > Int8.max {
                self.type = ZyWeatherType.sunny
                print("输入参数超过范围,改为默认值.sunny")
            }
        }
    }
    @objc public var temp:Int = 0 {
        didSet {
            if self.temp < Int8.min || self.temp > Int8.max {
                self.temp = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var airQuality:Int = 0 {
        didSet {
            if self.airQuality < Int8.min || self.airQuality > Int8.max {
                self.airQuality = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    @objc public var minTemp:Int = 0 {
        didSet {
            if self.minTemp < Int8.min || self.minTemp > Int8.max {
                self.minTemp = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var maxTemp:Int = 0 {
        didSet {
            if self.maxTemp < Int8.min || self.maxTemp > Int8.max {
                self.maxTemp = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var tomorrowMinTemp:Int = 0 {
        didSet {
            if self.tomorrowMinTemp < Int8.min || self.tomorrowMinTemp > Int8.max {
                self.tomorrowMinTemp = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var tomorrowMaxTemp:Int = 0 {
        didSet {
            if self.tomorrowMaxTemp < Int8.min || self.tomorrowMaxTemp > Int8.max {
                self.tomorrowMaxTemp = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    public override init() {
        super.init()
    }
}

@objc public enum ZyAlarmType : Int {
    case single
    case cycle
}
@objc public class ZyAlarmModel:NSObject {
    @objc public var isValid:Bool = true
    @objc public var alarmIndex:Int = -1 {
        didSet {
            if self.alarmIndex < UInt8.min || self.alarmIndex > UInt8.max {
                self.alarmIndex = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var alarmOpen:Bool = false
    @objc public var alarmHour:Int = -1 {
        didSet {
            if self.alarmHour < UInt8.min || self.alarmHour > UInt8.max {
                self.alarmHour = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var alarmMinute = -1 {
        didSet {
            if self.alarmMinute < UInt8.min || self.alarmMinute > UInt8.max {
                self.alarmMinute = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var alarmType:ZyAlarmType = .single
    @objc public var alarmRepeatArray:Array<Int>?
    @objc public private(set) var alarmRepeatCount:Int = 0
    
    public override init() {
        super.init()
    }
    
    @objc public init(dic:[String:Any]) {
        super.init()
        
        if dic.keys.contains("index") && dic.keys.contains("repeatCount") && dic.keys.contains("hour") && dic.keys.contains("minute") {
            if let index = dic["index"] as? String {
                self.alarmIndex = Int(UInt8(index) ?? 0)
            }

            self.alarmHour = Int(UInt8(dic["hour"] as! String) ?? 0)
            self.alarmMinute = Int(UInt8(dic["minute"] as! String) ?? 0)
            
            if self.alarmHour == 255 || self.alarmMinute == 255 {
                self.isValid = false
            }
            
            let repeatCount = Int(UInt8(dic["repeatCount"] as! String) ?? 0)
            
            if let repeatString = dic["repeatCount"] as? String {
                self.alarmRepeatCount = Int(UInt8(repeatString) ?? 0)
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

@objc public enum ZyLanguageType : Int {
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
    case Polish
    case Greek
    case Vietnamese
    case Indonesian
    case Thai
    case Dutch
    case Turkish
    case Romanian
    case Danish
    case Swedish
    case Bengali
    case Czech
    case Persian
    case Hebrew
    case Malay
    case Slovak
    case Xhosa
    case Slovenian
    case Hungarian
    case Lithuanian
    case Urdu
    case Bulgarian
    case Croatian
    case Latvian
    case Estonian
    case Khmer
}

@objc public enum ZyNotificationType : Int {
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
    case ExtensionNotificationType
    case Other = 15
}
@objc public enum ZyNotificationExtensionType : Int {
    case Alipay
    case TaoBao
    case DouYin
    case DingDing
    case JingDong
    case Gmail
    case Viber
    case YouTube
    case KakaoTalk
    case Telegram
    case Hangouts
    case Vkontakte
    case Flickr
    case Tumblr
    case Pinterest
    case Truecaller
    case Paytm
    case Zalo
    case MicrosoftTeams
}

@objc public enum ZyPositionType : Int {
    case leftTop
    case leftMiddle
    case letfBottom
    case rightTop
    case rightMiddle
    case rightBottom
    case centerTop
    case centerMiddle
    case centerBottom
}
@objc public enum ZyPositionShowType : Int {
    case close
    case date
    case sleep
    case heartrate
    case step
}
@objc public class ZyCustomDialModel:NSObject {
    @objc public private(set) var colorHex:String = "0xFFFFFF"
    @objc public var color:UIColor = .white
    @objc public var positionType:ZyPositionType = .leftTop
    @objc public var timeUpType:ZyPositionShowType = .close
    @objc public var timeDownType:ZyPositionShowType = .close
    
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
        self.positionType = ZyPositionType.init(rawValue: Int(positionType) ?? 0) ?? .leftTop
        self.timeUpType = ZyPositionShowType.init(rawValue: Int(timeUpType) ?? 0) ?? .close
        self.timeDownType = ZyPositionShowType.init(rawValue: Int(timeDownType) ?? 0) ?? .close
    }
}

@objc public class ZyDialFrameSizeModel:NSObject {
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


@objc public class ZyOnlineDialModel:NSObject {
    @objc public var dialId:Int = -1 
    @objc public var dialImageUrl:String?
    @objc public var dialFileUrl:String?
    @objc public var dialName:String?
    @objc public var dialPreviewUrl:String?
    
    public override init() {
        super.init()
    }
}

@objc public class ZySedentaryModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var timeLong:Int = 0 {
        didSet {
            if self.timeLong < UInt8.min || self.timeLong > UInt8.max {
                self.timeLong = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var timeArray:[ZyStartEndTimeModel] = []
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        let result = Int(dic["isOpen"] as! String) ?? 0
        
        self.isOpen = result == 0 ? false:true
        self.timeLong = Int(dic["timeLong"] as! String) ?? 0
        self.timeArray = dic["timeArray"] as? [ZyStartEndTimeModel] ?? []
    }
}

@objc public class ZyDoNotDisturbModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var timeModel:ZyStartEndTimeModel = ZyStartEndTimeModel.init()
    
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

@objc public class ZyDrinkWaterModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var remindInterval:Int = 0 {
        didSet {
            if self.remindInterval < UInt8.min || self.remindInterval > UInt8.max {
                self.remindInterval = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var timeModel:ZyStartEndTimeModel = ZyStartEndTimeModel.init()
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        let result = Int(dic["isOpen"] as! String) ?? 0
        self.isOpen = result == 0 ? false:true
        self.remindInterval = Int(dic["remindInterval"] as! String) ?? 0
        self.timeModel.startHour = Int(dic["startHour"] as! String) ?? 0
        self.timeModel.startMinute = Int(dic["startMinute"] as! String) ?? 0
        self.timeModel.endHour = Int(dic["endHour"] as! String) ?? 0
        self.timeModel.endMinute = Int(dic["endMinute"] as! String) ?? 0
    }
}

@objc public class ZyLowBatteryModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var remindBattery:Int = 0 {
        didSet {
            if self.remindBattery < UInt8.min || self.remindBattery > UInt8.max {
                self.remindBattery = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var remindCount:Int = 0 {
        didSet {
            if self.remindCount < UInt8.min || self.remindCount > UInt8.max {
                self.remindCount = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var remindInterval:Int = 0 {
        didSet {
            if self.remindInterval < UInt8.min || self.remindInterval > UInt8.max {
                self.remindInterval = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        let result = Int(dic["isOpen"] as! String) ?? 0
        self.isOpen = result == 0 ? false:true
        self.remindBattery = Int(dic["remindBattery"] as! String) ?? 0
        self.remindCount = Int(dic["remindCount"] as! String) ?? 0
        self.remindInterval = Int(dic["remindInterval"] as! String) ?? 0
    }
}

@objc public class ZyHrWaringModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var maxValue:Int = 0 {
        didSet {
            if self.maxValue < UInt8.min || self.maxValue > UInt8.max {
                self.maxValue = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var minValue:Int = 0 {
        didSet {
            if self.minValue < UInt8.min || self.minValue > UInt8.max {
                self.minValue = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
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

@objc public class ZyMenstrualModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var cycleCount:Int = 0 {
        didSet {
            if self.cycleCount < UInt8.min || self.cycleCount > UInt8.max {
                self.cycleCount = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var menstrualCount:Int = 0 {
        didSet {
            if self.menstrualCount < UInt8.min || self.menstrualCount > UInt8.max {
                self.menstrualCount = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    @objc public var year:Int = 0 {
        didSet {
            if self.year < UInt16.min || self.year > UInt16.max {
                self.year = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    @objc public var month:Int = 0 {
        didSet {
            if self.month < UInt8.min || self.month > UInt8.max {
                self.month = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    @objc public var day:Int = 0 {
        didSet {
            if self.day < UInt8.min || self.day > UInt8.max {
                self.day = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    @objc public var advanceDay:Int = 0 {
        didSet {
            if self.advanceDay < UInt8.min || self.advanceDay > UInt8.max {
                self.advanceDay = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    @objc public var remindHour:Int = 0 {
        didSet {
            if self.remindHour < UInt8.min || self.remindHour > UInt8.max {
                self.remindHour = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    @objc public var remindMinute:Int = 0 {
        didSet {
            if self.remindMinute < UInt8.min || self.remindMinute > UInt8.max {
                self.remindMinute = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        let result = Int(dic["isOpen"] as! String) ?? 0
        self.isOpen = result == 0 ? false:true
        self.cycleCount = Int(dic["cycleCount"] as! String) ?? 0
        self.menstrualCount = Int(dic["menstrualCount"] as! String) ?? 0
        self.year = Int(dic["year"] as! String) ?? 0
        self.month = Int(dic["month"] as! String) ?? 0
        self.day = Int(dic["day"] as! String) ?? 0
        self.advanceDay = Int(dic["advanceDay"] as! String) ?? 0
        self.remindHour = Int(dic["remindHour"] as! String) ?? 0
        self.remindMinute = Int(dic["remindMinute"] as! String) ?? 0
    }
}

@objc public class ZyAddressBookModel:NSObject {
    @objc public var name = ""
    @objc public var phoneNumber = ""
    
    public override init() {
        super.init()
    }
}

@objc public class ZyStepModel:NSObject {
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

@objc public class ZyHrModel:NSObject {

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

@objc public class ZySleepModel:NSObject {
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

@objc public enum ZyExerciseType : Int {
    case runOutside                         //跑步/户外跑
    case walk                               //走路
    case cycling                            //骑行
    case basketball                         //篮球
    case football                           //足球
    case badminton                          //羽毛球
    case jumpRope                           //跳绳
    case swimming                           //游泳
    case runIndoor                          //室内跑
    case volleyball                         //排球
    case walkFast                           //健走
    case spinning                           //动感单车
    case sitUps                             //仰卧起坐
    case mountainClimbing                   //登山
    case yoga                               //瑜伽
    case dance                              //舞蹈
    case jumpingJacks                       //开合跳
    case gymnastics                         //体操
    case rowing                             //划船
    case tennis                             //网球
    case hockey                             //曲棍球
    case baseball                           //棒球
    case tableTennis                        //乒乓球
    case cricket                            //板球
    case rugby                              //橄榄球
        
    case fitness = 26                       //0 健走
    case trailRunning = 27                  //1 越野跑
    case dumbbells = 28                     //2 哑铃
    case rowingMachine = 29                 //3 划船机
    case ellipticalMachine = 30             //4 椭圆机
    case aerobics = 31                      //5 健身操
    case kayak = 32                         //6 皮划艇
    case rollerSkating = 33                 //7 轮滑
    case playgroundRunning = 34             //8 操场跑步
    case runToLoseFat = 35                  //9 减脂跑步
    case outdoorCycling = 36                //10 户外骑行
    case indoorCycling = 37                 //11 室内骑行
    case mountainBiking = 38                //12 山地骑行
    case orienteering = 39                  //13 定向越野
    case mixedAerobic = 40                  //14 混合有氧
    case combatExercises = 41               //15 搏击操
    case coreTraining = 42                  //16 核心训练
    case crossTraining = 43                 //17 交叉训练
    case teamGymnastics = 44                //18 团体操
    case strengthTraining = 45              //19 力量训练
    case intervalTraining = 46              //20 间歇训练
    case flexibilityTraining = 47           //21 柔韧训练
    case stretching = 48                    //22 拉伸
    case fitnessExercises = 49              //23 健身运动
    case balanceTraining = 50               //24 平衡训练
    case stepTraining = 51                  //25 踏步训练
    case battleRope = 52                    //26 战绳
    case freeTraining = 53                  //27 自由训练
    case skiing = 54                        //28 滑雪
    case rockClimbing = 55                  //29 攀岩
    case fishing = 56                       //30 钓鱼
    case hunting = 57                       //31 打猎
    case skateboard = 58                    //32 滑板
    case parkour = 59                       //33 跑酷
    case duneBuggy = 60                     //34 沙滩车
    case dirtBike = 61                      //35 越野摩托
    case handRollingCar = 62                //36 手摇车
    case pilates = 63                       //37 普拉提
    case flyingDarts = 64                   //38 飞镖
    case snowboarding = 65                  //39 双板滑雪
    case walkingMachine = 66                //40 漫步机
    case skydiving = 67                     //41 跳伞
    case crossCountrySkiing = 68            //42 越野滑雪
    case bungeeJumping = 69                 //43 蹦极
    case theSwing = 70                      //44 秋千
    case flyingKite = 71                    //45 放风筝
    case hulaHoops = 72                     //46 呼啦圈
    case archery = 73                       //47 射箭
    case raceWalking = 74                   //48 竞走
    case racingCars = 75                    //49 赛车
    case marathon = 76                      //50 马拉松
    case obstacleCourse = 77                //51 障碍赛
    case tugOfWar = 78                      //52 拔河
    case dragonBoat = 79                    //53 龙舟
    case highJump = 80                      //54 跳高
    case sailing = 81                       //55 帆船运动
    case triathlon = 82                     //56 铁人三项
    case horseRacing = 83                   //57 赛马
    case BMX = 84                           //58 小轮车
    case PparallelBar = 85                  //59 双杠
    case golf = 86                          //60 高尔夫
    case bowlingBall = 87                   //61 保龄球
    case squash = 88                        //62 壁球
    case polo = 89                          //63 马球
    case wallBall = 90                      //64 墙球
    case billiards = 91                     //65 桌球
    case waterBalloon = 92                  //66 水球
    case shuttlecock = 93                   //67 毽球
    case indoorFootball = 94                //68 室内足球
    case sandbagBall = 95                   //69 沙包球
    case toTheBall = 96                     //70 地掷球
    case jaiAlai = 97                       //71 回力球
    case floorball = 98                     //72 地板球
    case picogramBalls = 99                 //73 匹克球
    case beachVolleyball = 100              //74 沙滩排球
    case softball = 101                     //75 垒球
    case squareDance = 102                  //76 广场舞
    case bellyDance = 103                   //77 肚皮舞
    case ballet = 104                       //78 芭蕾舞
    case streetDance = 105                  //79 街舞
    case latinDance = 106                   //80 拉丁舞
    case jazzDance = 107                    //81 爵士舞
    case poleDancing = 108                  //82 钢管舞
    case theDisco = 109                     //83 迪斯科
    case tapDance = 110                     //84 踢踏舞
    case otherDances = 111                  //85 其它舞蹈
    case boxing = 112                       //86 拳击
    case wrestling = 113                    //87 摔跤
    case martialArts = 114                  //88 武术
    case taiChi = 115                       //89 太极
    case thaiBoxing = 116                   //90 泰拳
    case judo = 117                         //91 柔道
    case taekwondo = 118                    //92 跆拳道
    case karate = 119                       //93 空手道
    case kickboxing = 120                   //94 自由搏击
    case swordFighting = 121                //95 剑术
    case jiuJitsu = 122                     //96 柔术
    
}

@objc public enum ZyExerciseState : Int {
    case unknow = -1
    case end
    case start
    case `continue`
    case pause
}

@objc public class ZyExerciseModel:NSObject {
    @objc public var type:ZyExerciseType = .runOutside
    @objc public var startTime:String = ""
    @objc public var endTime:String = ""
    @objc public var validTimeLength:Int = 0
    @objc public var heartrate:Int = 0
    @objc public var step:Int = 0
    @objc public var calorie:Int = 0
    @objc public var distance:Int = 0
    @objc public var gpsArray:[[CLLocation]] = .init()
    
    public override init() {
        super.init()
    }
    init(dic:[String:Any]) {
        super.init()
        
        self.type = ZyExerciseType.init(rawValue: (Int(dic["type"] as! String) ?? 0)) ?? .runOutside
        self.startTime = dic["startTime"] as! String
        self.endTime = dic["endTime"] as! String
        self.validTimeLength = Int(dic["validTimeLength"] as! String) ?? 0
        self.heartrate = Int(dic["hr"] as! String) ?? 0
        self.step = Int(dic["step"] as! String) ?? 0
        self.calorie = Int(dic["calorie"] as! String) ?? 0
        self.distance = Int(dic["distance"] as! String) ?? 0
        if let array = dic["gpsArray"] as? [[CLLocation]] {
            self.gpsArray = array
        }
    }
}

@objc public enum ZyMeasurementType : Int {
    case heartrate = 1                      //心率
    case bloodOxygen                        //血氧
    case bloodPressure                      //血压
    case bloodSugar                         //血糖
    case pressure                           //压力
    case bodyTemperature                    //体温
    case electrocardiogram                  //心电
}

@objc public class ZyMeasurementModel:NSObject {
    @objc public var type:ZyMeasurementType = .heartrate
    @objc public var timeInterval:Int = 0
    @objc public var listArray:[ZyMeasurementValueModel] = .init()
    
    public override init() {
        super.init()
    }
}

@objc public class ZyMeasurementValueModel:NSObject {
    @objc public var time:String = "00:00"
    @objc public var value_1:Int = 0
    @objc public var value_2:Int = 0
}

@objc public class ZyStartEndTimeModel:NSObject {
    @objc public var startHour:Int = -1 {
        didSet {
            if self.startHour < UInt8.min || self.startHour > UInt8.max {
                self.startHour = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var startMinute:Int = -1 {
        didSet {
            if self.startMinute < UInt8.min || self.startMinute > UInt8.max {
                self.startMinute = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var endHour:Int = -1 {
        didSet {
            if self.endHour < UInt8.min || self.endHour > UInt8.max {
                self.endHour = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var endMinute:Int = -1 {
        didSet {
            if self.endMinute < UInt8.min || self.endMinute > UInt8.max {
                self.endMinute = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    
    public override init() {
        super.init()
    }
}

@objc public class ZyWorshipTimeModel:NSObject {
    @objc public var timeString = "2000-01-01"
    @objc public var fajr = 0
    @objc public var sunrise = 0
    @objc public var dhuhr = 0
    @objc public var asr = 0
    @objc public var maghrib = 0
    @objc public var isha = 0
    
    public override init() {
        super.init()
    }
}

@objc public class ZyFunctionModel_supportMusicFileTypeModel:NSObject {
    @objc public var isSupportMp3 = false
    @objc public var isSupportWav = false
    
    init(val:[UInt8]) {
        
        for i in 0..<8 {
            let state = (val[0] >> i) & 0x01

            switch i {
            case 0:self.isSupportMp3 = state == 0 ? false:true
                break
            case 1:self.isSupportWav = state == 0 ? false:true
                break
            default:
                break
            }
        }
        super.init()
    }
}

@objc public enum ZyLedFunctionType : Int {
    case unknow = -1                           //未知状态
    case powerIndicator = 0                    //电量提示
    case informationReminder                   //信息提醒
    case btBind                                //BT绑定
    case stepCountingStandardReminder          //计步达标提醒
    //case lowBatteryReminder                    //低电量提醒
}

@objc public class ZyLedFunctionModel:NSObject {
    @objc public var ledType:ZyLedFunctionType = .unknow
    @objc public var ledColor = 0   //bit0:红,bit1:绿,bit2:蓝,bit3:白
    @objc public var firstColor = 0
    @objc public var secondColor = 0
    @objc public var thirdColor = 0
    @objc public var timeLength = 0 //持续时间[1-20]
    @objc public var frequency = 0  //闪烁频次[0-5] 0常亮
    
    public override init() {
        super.init()
    }
    
    @objc public init(dic:[String:Any]) {
        super.init()
        
        if dic.keys.contains("ledType") && dic.keys.contains("ledColor") && dic.keys.contains("timeLength") && dic.keys.contains("frequency") {
            if let index = dic["ledType"] as? Int {
                self.ledType = ZyLedFunctionType.init(rawValue: index) ?? .unknow
            }

            self.ledColor = Int(UInt8(dic["ledColor"] as! Int) )
            self.timeLength = Int(UInt8(dic["timeLength"] as! Int))
            self.frequency = Int(UInt8(dic["frequency"] as! Int))
            
            if dic.keys.contains("firstColor") && dic.keys.contains("secondColor") && dic.keys.contains("thirdColor") {
                self.firstColor = Int(UInt8(dic["firstColor"] as! Int) )
                self.secondColor = Int(UInt8(dic["secondColor"] as! Int))
                self.thirdColor = Int(UInt8(dic["thirdColor"] as! Int))
            }
            
        }else{
            printLog("ZyLedFunctionModel dic初始化异常")
        }
    }
}
@objc public class ZyMotorFunctionModel:NSObject {

    @objc public var ledType:ZyLedFunctionType = .powerIndicator   //范围[0,4]
    @objc public var timeLength = 0 //震动时长 范围[10,50]
    @objc public var frequency = 0  //震动频次 范围[0,5]
    @objc public var level = 0      //震动强度 范围[1,10]
    
    public override init() {
        super.init()
    }
    
    @objc public init(dic:[String:Any]) {
        super.init()
        
        if dic.keys.contains("ledType") && dic.keys.contains("level") && dic.keys.contains("timeLength") && dic.keys.contains("frequency") {
            if let index = dic["ledType"] as? Int {
                self.ledType = ZyLedFunctionType.init(rawValue: index) ?? .unknow
            }

            self.level = Int(UInt8(dic["level"] as! Int))
            self.timeLength = Int(UInt8(dic["timeLength"] as! Int))
            self.frequency = Int(UInt8(dic["frequency"] as! Int))
            
        }else{
            printLog("ZyMotorFunctionModel dic初始化异常")
        }
    }
}

@objc public class ZyFunctionModel_locationGps:NSObject {
    @objc public private(set) var isSupportAG3352Q = false
    
    init(val:[UInt8]) {
        
        for i in 0..<8 {
            let state = (val[0] >> i) & 0x01

            switch i {
            case 0:self.isSupportAG3352Q = state == 0 ? false:true
                break
            default:
                break
            }
        }
        super.init()
    }
}
