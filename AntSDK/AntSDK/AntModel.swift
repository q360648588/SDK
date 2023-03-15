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
    case screenType         = 35            //手表款式
    case sportCountdown     = 37            //运动倒计时
    case lowBattery         = 38            //低电提醒
    case exerciseInteraction   = 39            //app发起运动交互
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
    
    @objc public private(set) var functionDetail_exercise:AntFunctionModel_exercise?
    @objc public private(set) var functionDetail_notification:AntFunctionModel_notification?
    @objc public private(set) var functionDetail_language:AntFunctionModel_language?
    @objc public private(set) var functionDetail_alarm:AntFunctionModel_alarm?
    @objc public private(set) var functionDetail_screenControl:AntFunctionModel_screenControl?
    @objc public private(set) var functionDetail_addressBook:AntFunctionModel_addressBook?
    @objc public private(set) var functionDetail_localDial:AntFunctionModel_localDial?
    @objc public private(set) var functionDetail_hrWarning:AntFunctionModel_hrWarning?
    @objc public private(set) var functionDetail_goal:AntFunctionModel_goal?
    @objc public private(set) var functionDetail_screenType:AntFunctionModel_scrrenType?
    @objc public private(set) var functionDetail_sportCountdown:AntFunctionModel_sportCountdown?
    var functionDetail_newPortocol:AntFunctionModel_newPortocol?
    @objc public private(set) var functionDetail_platformType:AntFunctionModel_platformType?
    @objc public private(set) var functionDetail_customDial:AntFunctionModel_customDial?
    @objc public private(set) var functionDetail_heartrate:AntFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_bloodPressure:AntFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_bloodOxygen:AntFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_bloodSugar:AntFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_pressure:AntFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_electrocardiogram:AntFunctionModel_supportMeasurementDataTypeModel?
    @objc public private(set) var functionDetail_bodyTemperature:AntFunctionModel_supportMeasurementDataTypeModel?
    
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
                self.functionDetail_exercise = AntFunctionModel_exercise.init(result: functionCount)
                break
            case 1:
                break
            case 2:
                break
            case 3:
                self.functionDetail_heartrate = AntFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 4:
                self.functionDetail_bloodPressure = AntFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 5:
                self.functionDetail_bloodOxygen = AntFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 6:
                self.functionDetail_notification = AntFunctionModel_notification.init(result: functionCount)
                break
            case 7:
                break
            case 8:
                self.functionDetail_alarm = AntFunctionModel_alarm.init(val: functionVal)
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
                self.functionDetail_addressBook = AntFunctionModel_addressBook.init(val: functionVal)
                break
            case 18:
                break
            case 19:
                self.functionDetail_customDial = AntFunctionModel_customDial.init(result: functionCount)
                break
            case 20:
                self.functionDetail_localDial = AntFunctionModel_localDial.init(result: functionCount)
                break
            case 21:
                self.functionDetail_hrWarning = AntFunctionModel_hrWarning.init(val: functionVal)
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
                self.functionDetail_screenType = AntFunctionModel_scrrenType.init(result: functionCount)
                break
            case 36:
                break
            case 37:
                self.functionDetail_sportCountdown = AntFunctionModel_sportCountdown.init(result: functionCount)
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
                self.functionDetail_newPortocol = AntFunctionModel_newPortocol.init(result: functionCount)
                break
            case 44:
                self.functionDetail_platformType = AntFunctionModel_platformType.init(result: functionCount)
                break
            case 45:
                break
            case 46:
                self.functionDetail_bloodSugar = AntFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 47:
                self.functionDetail_pressure = AntFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 48:
                self.functionDetail_electrocardiogram = AntFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
                break
            case 49:
                self.functionDetail_bodyTemperature = AntFunctionModel_supportMeasurementDataTypeModel(val: functionVal)
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
                log += "\n\(model.isSupportfontColor ? "支持":"不支持")字体颜色设置"
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
        return log
    }
}

@objc public class AntFunctionModel_exercise:NSObject {
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
    @objc public private(set) var isSupportEdit = false     //是否支持增删
    
    init(val:[UInt8]) {
        self.maxAlarmCount = Int(val[0])
        if val.count > 1 {
            self.isSupportEdit = Int(val[1]) == 0 ? false:true
        }
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

@objc public class AntFunctionModel_addressBook:NSObject {
    @objc public private(set) var maxContactCount = 0       //支持的最大联系人数量
    
    init(val:[UInt8]) {
        self.maxContactCount = (Int(val[0]) | Int(val[1]) << 8)
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

@objc public class AntFunctionModel_hrWarning:NSObject {
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

@objc public class AntFunctionModel_scrrenType:NSObject {

    @objc public private(set) var supportType = 0                //0:方 1:圆 2:圆角
    
    init(result:Int) {
        self.supportType = result
        super.init()
    }
}

@objc public class AntFunctionModel_sportCountdown:NSObject {
    
    @objc public private(set) var countDownTime = 0                 //倒计时时长
    
    init(result:Int) {
        self.countDownTime = result
        super.init()
    }
}

class AntFunctionModel_newPortocol:NSObject {
    
    @objc public private(set) var maxMtuCount = 0                 //最大mtu能发送的数量
    
    init(result:Int) {
        self.maxMtuCount = result
        super.init()
    }
}

@objc public class AntFunctionModel_platformType:NSObject {
    
    @objc public private(set) var platform = 0                 //0:瑞昱,1:杰理,2:Nordic
    
    init(result:Int) {
        self.platform = result
        super.init()
    }
}

@objc public class AntFunctionModel_customDial:NSObject {
    
    @objc public private(set) var isSupportfontColor = true       //0:不支持,1:支持
    
    init(result:Int) {
        self.isSupportfontColor = result == 0 ? false:true
        super.init()
    }
}

@objc public class AntFunctionModel_supportMeasurementDataTypeModel:NSObject {
    
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

@objc public class AntPersonalModel:NSObject {
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
@objc public enum AntWeatherType : Int {
    case overcast               //阴
    case fog                    //雾
    case sunny                  //晴
    case cloudy                 //多云
    case snow                   //雪
    case rain                   //雨
}

@objc public class AntWeatherModel:NSObject {
    @objc public var dayCount:Int = 0 {
        didSet {
            if self.dayCount < Int8.min || self.dayCount > Int8.max {
                self.dayCount = 0
                //print(" Int8.min = \(Int8.min) , Int8.max = \(Int8.max)")
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var type:AntWeatherType = AntWeatherType.sunny {
        didSet {
            if self.type.rawValue < Int8.min || self.type.rawValue > Int8.max {
                self.type = AntWeatherType.sunny
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

@objc public enum AntAlarmType : Int {
    case single
    case cycle
}
@objc public class AntAlarmModel:NSObject {
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
    @objc public var positionType:AntPositionType = .leftTop
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
        self.positionType = AntPositionType.init(rawValue: Int(positionType) ?? 0) ?? .leftTop
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
    @objc public var dialId:Int = -1 {
        didSet {
            if self.dialId < UInt8.min || self.dialId > UInt8.max {
                self.dialId = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var dialImageUrl:String?
    @objc public var dialFileUrl:String?
    @objc public var dialName:String?
    
    public override init() {
        super.init()
    }
}

@objc public class AntSedentaryModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var timeLong:Int = 0 {
        didSet {
            if self.timeLong < UInt8.min || self.timeLong > UInt8.max {
                self.timeLong = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
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

@objc public class AntDrinkWaterModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var remindInterval:Int = 0 {
        didSet {
            if self.remindInterval < UInt8.min || self.remindInterval > UInt8.max {
                self.remindInterval = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var timeModel:AntStartEndTimeModel = AntStartEndTimeModel.init()
    
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

@objc public class AntLowBatteryModel:NSObject {
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

@objc public class AntHrWaringModel:NSObject {
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

@objc public class AntMenstrualModel:NSObject {
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

@objc public class AntAddressBookModel:NSObject {
    @objc public var name = ""
    @objc public var phoneNumber = ""
    
    public override init() {
        super.init()
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

@objc public enum AntExerciseType : Int {
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
}

@objc public enum AntExerciseState : Int {
    case unknow = -1
    case end
    case start
    case `continue`
    case pause
}

@objc public class AntExerciseModel:NSObject {
    @objc public var type:AntExerciseType = .runOutside
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
        
        self.type = AntExerciseType.init(rawValue: (Int(dic["type"] as! String) ?? 0)) ?? .runOutside
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
