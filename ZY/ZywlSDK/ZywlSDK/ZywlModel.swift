//
//  ZyModel.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2022/5/7.
//

import Foundation
import CoreBluetooth
import UIKit

@objc public class ZywlScanModel: NSObject {
    @objc public var name:String?
    @objc public var rssi:Int = 0
    @objc public var peripheral:CBPeripheral?
    @objc public var uuidString:String?
    @objc public var macString:String?
    @objc public var productId:String?
    @objc public var projectId:String?
    @objc public var typeString:String?
}

@objc public class ZywlOwsL04DeviceInformationModel:NSObject {
    
    @objc public var voiceVolume = 0                    //音量 0x00~0x0a(0~10)
    @objc public var noiseControl = 0                   //噪声控制（0x00 轻度降噪，0x01 中度降噪，0x02 重度降噪，0x03 关闭降噪，0x04 通透模式）
    @objc public var noiseReduction = 0                 //降噪环境（0x00 室内，0x01 室外，0x02 交通）
    @objc public var isOpenlowLatency = false           //低延时模式（0x00 关闭，0x01 开启）
    @objc public var isOpenEq = false                   //EQ 功能使能状态, 0x00 为关闭,0x01 为打开
    @objc public var eqType = 0                         //当前 EQ 模式：0x00 表示标准 EQ，0x01 表示摇滚, 0x02 表示流行,0x03表示古典, 0x04 表示乡村, 0x05 表示经典,0x11 用户自定义模式
    @objc public var singleClickLeftFunctionId = 0      //[播放]单击 左耳 功能定义 0x00 表示：播放暂停,0x01 表示：上一曲,0x02 表示：下一曲,0x03 表示：接听来电0x04 表示：挂断来电0x05 表示：拒接来电,0x06 表示: 语音助手,
    @objc public var singleClickRightFunctionId = 0     //[播放]单击 右耳
    @objc public var doubleClickLeftFunctionId = 0      //[播放]双击 左耳
    @objc public var doubleClickRightFunctionId = 0     //[播放]双击 右耳
    @objc public var threeClickLeftFunctionId = 0       //[播放]三击 左耳
    @objc public var threeClickRightFunctionId = 0      //[播放]三击 右耳
    @objc public var longPressLeftFunctionId = 0        //[播放]长按 左耳
    @objc public var longPressRightFunctionId = 0       //[播放]长按 右耳
    @objc public var leftBattery = 0                    //表示左耳电量（0%~100%电量表示 0x00~0x64）
    @objc public var rightBattery = 0                   //表示右耳电量（0%~100%电量表示 0x00~0x64）
    @objc public var boxBattery = 0                     //表示耳机仓电量（0%~100%电量表示 0x00~0x64）
    @objc public var isOpenRecharge = false             //是否在充电（0x00 未充电，0x01 充电中）
    @objc public var isOpenPlayGameMode = true          //游戏模式开关 0x00是开启，0x01是关闭
    @objc public var isOpenShakeSong = true             //摇一摇切歌开关 0x00是开启，0x01是关闭
    @objc public var softwareVersion = ""               //软件版本号 V1.0.1；（字符串格式 6bytes）
    @objc public var softwareSerial = ""                //软件序列号 ZL0001；（字符串格式 6bytes）
    @objc public var bluetoothAddress = ""              //蓝牙地址；（字符串格式 12bytes）
    @objc public var deviceType = 0                     //设备类型（1表示耳机，2表示仓）
}

@objc public class ZywlOwsAlarmModel:NSObject {
    @objc public var type = 0                      //0普通闹钟，1喝水闹钟，2吃药闹钟，3.会议闹钟
    @objc public var isOpen = false                  //0关闭，1开启
    @objc public var hour = 0
    @objc public var minute = 0
    @objc public var repeatCount = 0                    //bit0～bit6，周一～周日 ，0关闭，1开启
}

@objc public class ZywlOwsWeatherModel:NSObject {
    @objc public var type:Int = 0                   //0多云，1雾，2阴天，3雨，4雪，5晴，6沙尘暴，7霾
    @objc public var temperature = 0                //摄氏度
    @objc public var pmValue = 0                    //0～35优，35～75良，75～115轻度污染，大于115严重污染
    @objc public var maxTemp = 0                    //最高温
    @objc public var minTemp = 0                    //最低温
}


@objc public class ZycxFunctionListModel:NSObject {
    @objc public private(set) var functionList_messagePush = false
    @objc public private(set) var functionList_language = false
    @objc public private(set) var functionList_alarm = false
    @objc public private(set) var functionList_sedentary = false
    @objc public private(set) var functionList_vibrationRemind = false
    @objc public private(set) var functionList_doNotDisturb = false
    @objc public private(set) var functionList_lostRemind = false
    @objc public private(set) var functionList_weather = false
    @objc public private(set) var functionList_lightControl = false
    @objc public private(set) var functionList_addressBook = false
    @objc public private(set) var functionList_onlineDial = false
    @objc public private(set) var functionList_customDial = false
    @objc public private(set) var functionList_localDial = false
    @objc public private(set) var functionList_physiologicalCycle = false
    @objc public private(set) var functionList_drinkWater = false
    @objc public private(set) var functionList_photoControl = false
    @objc public private(set) var functionList_musicControl = false
    @objc public private(set) var functionList_findDevice = false
    @objc public private(set) var functionList_powerOff = false
    @objc public private(set) var functionList_restart = false
    @objc public private(set) var functionList_resetFactory = false
    @objc public private(set) var functionList_handUpPhone = false
    @objc public private(set) var functionList_answerPhone = false
    @objc public private(set) var functionList_timeFormat = false
    @objc public private(set) var functionList_screenType = false
    @objc public private(set) var functionList_classicBluetooth = false
    @objc public private(set) var functionList_bindClear = false
    @objc public private(set) var functionList_bind = false
    @objc public private(set) var functionList_platformType = false
    @objc public private(set) var functionList_sos = false
    @objc public private(set) var functionList_localPlay = false
    @objc public private(set) var functionList_editBleName = false
    @objc public private(set) var functionList_forwardingOfHeadphoneData = false
    
    @objc public private(set) var functionDetail_messagePush:ZycxFunctionModel_messagePush?
    @objc public private(set) var functionDetail_language:ZycxFunctionModel_language?
    @objc public private(set) var functionDetail_alarm:ZycxFunctionModel_alarm?
    @objc public private(set) var functionDetail_lightControl:ZycxFunctionModel_lightControl?
    @objc public private(set) var functionDetail_addressBook:ZycxFunctionModel_addressBook?
    @objc public private(set) var functionDetail_customDial:ZycxFunctionModel_customDial?
    @objc public private(set) var functionDetail_localDial:ZycxFunctionModel_localDial?
    @objc public private(set) var functionDetail_screenType:ZycxFunctionModel_screenType?
    @objc public private(set) var functionDetail_platformType:ZycxFunctionModel_platformType?
    @objc public private(set) var functionDetail_localPlay:ZycxFunctionModel_localPlay?

    
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
        
        currentIndex = Int(2+mainLength)//相比就协议多了一个功能项长度
        self.dealDetailFunction(index: currentIndex, val: val)

    }
    
    func dealDetailFunction(index:Int,val:[UInt8]) {
        printLog("dealDetailFunction index =\(index)")
        if index >= val.count {
            printLog("dealDetailFunction 已全部处理完毕")
            printLog("\(self.showAllSupportFunctionLog())")
            ZywlSDKLog.writeStringToSDKLog(string: self.showAllSupportFunctionLog())
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
                self.functionDetail_messagePush = ZycxFunctionModel_messagePush.init(result: functionCount)
                break
            case 1:
                self.functionDetail_language = ZycxFunctionModel_language.init(result: functionCount)
                break
            case 2:
                self.functionDetail_alarm = ZycxFunctionModel_alarm.init(val: functionVal)
                break
            case 3:
                self.functionDetail_lightControl = ZycxFunctionModel_lightControl(val: functionVal)
                break
            case 4:
                self.functionDetail_addressBook = ZycxFunctionModel_addressBook.init(val: functionVal)
                break
            case 5:self.functionDetail_customDial = ZycxFunctionModel_customDial(val: functionVal)
                break
            case 6:self.functionDetail_localDial = ZycxFunctionModel_localDial.init(result: functionCount)
                break
            case 7:self.functionDetail_screenType = ZycxFunctionModel_screenType(result: functionCount)
                break
            case 8:self.functionDetail_platformType = ZycxFunctionModel_platformType.init(result: functionCount)
                break
            case 9:self.functionDetail_localPlay = ZycxFunctionModel_localPlay(val: functionVal)
                break
            case 10:
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
                break
            case 16:
                break
            case 17:
                break
            case 18:
                break
            case 19:
                break
            case 20:
                break
            case 21:
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
            case 36:
                break
            case 37:
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
                break
            case 44:
                break
            case 45:
                break
            case 46:
                break
            case 47:
                break
            case 48:
                break
            case 49:
                break
            case 52:
                break
            case 53:
                break
            case 54:
                break
            case 56:
                break
            case 57:
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
            case 0:self.functionList_messagePush = state == 0 ? false:true
                break
            case 1:self.functionList_language = state == 0 ? false:true
                break
            case 2:self.functionList_alarm = state == 0 ? false:true
                break
            case 3:self.functionList_sedentary = state == 0 ? false:true
                break
            case 4:self.functionList_vibrationRemind = state == 0 ? false:true
                break
            case 5:self.functionList_doNotDisturb = state == 0 ? false:true
                break
            case 6:self.functionList_lostRemind = state == 0 ? false:true
                break
            case 7:self.functionList_weather = state == 0 ? false:true
                break
            case 8:self.functionList_lightControl = state == 0 ? false:true
                break
            case 9:self.functionList_addressBook = state == 0 ? false:true
                break
            case 10:self.functionList_onlineDial = state == 0 ? false:true
                break
            case 11:self.functionList_customDial = state == 0 ? false:true
                break
            case 12:self.functionList_localDial = state == 0 ? false:true
                break
            case 13:self.functionList_physiologicalCycle = state == 0 ? false:true
                break
            case 14:self.functionList_drinkWater = state == 0 ? false:true
                break
            case 15:self.functionList_photoControl = state == 0 ? false:true
                break
            case 16:self.functionList_musicControl = state == 0 ? false:true
                break
            case 17:self.functionList_findDevice = state == 0 ? false:true
                break
            case 18:self.functionList_powerOff = state == 0 ? false:true
                break
            case 19:self.functionList_restart = state == 0 ? false:true
                break
            case 20:self.functionList_resetFactory = state == 0 ? false:true
                break
            case 21:self.functionList_handUpPhone = state == 0 ? false:true
                break
            case 22:self.functionList_answerPhone = state == 0 ? false:true
                break
            case 23:self.functionList_timeFormat = state == 0 ? false:true
                break
            case 24:self.functionList_screenType = state == 0 ? false:true
                break
            case 25:self.functionList_classicBluetooth = state == 0 ? false:true
                break
            case 26:self.functionList_bindClear = state == 0 ? false:true
                break
            case 27:self.functionList_bind = state == 0 ? false:true
                break
            case 28:self.functionList_platformType = state == 0 ? false:true
                break
            case 29:self.functionList_sos = state == 0 ? false:true
                break
            case 30:self.functionList_localPlay = state == 0 ? false:true
                break
            case 31:self.functionList_editBleName = state == 0 ? false:true
                break
            case 32:self.functionList_forwardingOfHeadphoneData = state == 0 ? false:true
                break
            case 33:
                break
            default:
                break
            }
        }
    }

    @objc public func showAllSupportFunctionLog() -> String{
        var log = ""

        if self.functionList_messagePush {
            log += "\n消息推送"
            if let model = self.functionDetail_messagePush {
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
        if self.functionList_vibrationRemind {
            log += "\n振动"
        }
        if self.functionList_doNotDisturb {
            log += "\n勿扰"
        }
        if self.functionList_lostRemind {
            log += "\n防丢"
        }
        if self.functionList_weather {
            log += "\n天气"
        }
        if self.functionList_lightControl {
            log += "\n背光控制"
            if let model = self.functionDetail_lightControl {
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
                log += "\n      \(model.isSupportColorSetup ? "支持":"不支持")字体颜色设置"
                log += "\n      bigWidth:\(model.dialSize.bigWidth)"
                log += "\n      bigHeight:\(model.dialSize.bigHeight)"
                log += "\n      smallWidth:\(model.dialSize.smallWidth)"
                log += "\n      smallHeight:\(model.dialSize.smallHeight)"
                for item in model.supportPositionTypeArray {
                    log += "\n      支持的位置类型:\(item)"
                }
                log += "\n      自定义Y轴起始点:\(model.offsetY)"
                log += "\n      \(model.isShowTimePosition ? "显示":"隐藏")时间位置"
                log += "\n      \(model.isShowTimeUp ? "显示":"隐藏")时间上方"
                log += "\n      \(model.isShowTimeDown ? "显示":"隐藏")时间下方"
            }
        }
        if self.functionList_localDial {
            log += "\n本地表盘"
            if let model = self.functionDetail_localDial {
                log += "\n      内置 \(model.maxDialCount) 个本地表盘"
            }
        }
        if self.functionList_physiologicalCycle {
            log += "\n生理周期"
        }
        if self.functionList_drinkWater {
            log += "\n喝水"
        }
        if self.functionList_photoControl {
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
        if self.functionList_resetFactory {
            log += "\n恢复出厂"
        }
        if self.functionList_handUpPhone {
            log += "\n挂断电话"
        }
        if self.functionList_answerPhone {
            log += "\n接听电话"
        }
        if self.functionList_timeFormat {
            log += "\n时间格式"
        }
        if self.functionList_screenType {
            log += "\n屏幕款式"
            if let model = self.functionDetail_screenType {
                log += "\n      手表款式 \(model.supportType)(0方1圆2圆角)"
            }
        }
        if self.functionList_classicBluetooth {
            log += "\n经典蓝牙"
        }
        if self.functionList_bindClear {
            log += "\n绑定清除数据"
        }
        if self.functionList_bind {
            log += "\n绑定/解绑"
        }
        if self.functionList_platformType {
            log += "\n手表平台类型"
            if let model = self.functionDetail_platformType {
                log += "\n平台类型:\(model.platform)"
            }
        }
        if self.functionList_sos {
            log += "\nsos紧急联系人"
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
        if self.functionList_editBleName {
            log += "\n更改蓝牙名"
        }
        if self.functionList_forwardingOfHeadphoneData {
            log += "\n转发耳机数据"
        }
        return log
    }
}

@objc public class ZycxFunctionModel_messagePush:NSObject {
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
            case 13:self.isSupportAlipay = state == 0 ? false:true
                break
            case 14:self.isSupportTaoBao = state == 0 ? false:true
                break
            case 15:self.isSupportDouYin = state == 0 ? false:true
                break
            case 16:self.isSupportDingDing = state == 0 ? false:true
                break
            case 17:self.isSupportJingDong = state == 0 ? false:true
                break
            case 18:self.isSupportGmail = state == 0 ? false:true
                break
            case 19:self.isSupportViber = state == 0 ? false:true
                break
            case 20:self.isSupportYouTube = state == 0 ? false:true
                break
            case 21:self.isSupportKakaoTalk = state == 0 ? false:true
                break
            case 22:self.isSupportTelegram = state == 0 ? false:true
                break
            case 23:self.isSupportHangouts = state == 0 ? false:true
                break
            case 24:self.isSupportVkontakte = state == 0 ? false:true
                break
            case 25:self.isSupportFlickr = state == 0 ? false:true
                break
            case 26:self.isSupportTumblr = state == 0 ? false:true
                break
            case 27:self.isSupportPinterest = state == 0 ? false:true
                break
            case 28:self.isSupportTruecaller = state == 0 ? false:true
                break
            case 29:self.isSupportPaytm = state == 0 ? false:true
                break
            case 30:self.isSupportZalo = state == 0 ? false:true
                break
            case 31:self.isSupportMicrosoftTeams = state == 0 ? false:true
                break
            case 32://self.isSupport = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}

@objc public class ZycxFunctionModel_language:NSObject {
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

@objc public class ZycxFunctionModel_alarm:NSObject {
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

@objc public class ZycxFunctionModel_lightControl:NSObject {
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

@objc public class ZycxFunctionModel_addressBook:NSObject {
    @objc public private(set) var maxContactCount = 0       //支持的最大联系人数量
    
    init(val:[UInt8]) {
        self.maxContactCount = (Int(val[0]) << 8 | Int(val[1]))
        super.init()
    }
}

@objc public class ZycxFunctionModel_customDial:NSObject {
    @objc public private(set) var isSupportColorSetup = false         //自定义表盘颜色设置，0：不支持，1：支持
    @objc public private(set) var dialSize = ZycxDialFrameSizeModel()
    @objc public private(set) var supportPositionTypeArray:[Int] = .init()
    @objc public private(set) var offsetY = 0
    @objc public private(set) var isShowTimePosition = true
    @objc public private(set) var isShowTimeUp = true
    @objc public private(set) var isShowTimeDown = true
    
    init(val:[UInt8]) {
        
        self.isSupportColorSetup = val[0] == 0 ? false : true
        if val.count > 8 {
            self.dialSize = ZycxDialFrameSizeModel.init(dic: ["bigWidth":"\(Int(val[1]) << 8 | Int(val[2]))","bigHeight":"\(Int(val[3]) << 8 | Int(val[4]))","smallWidth":"\(Int(val[5]) << 8 | Int(val[6]))","smallHeight":"\(Int(val[7]) << 8 | Int(val[8]))"])
        }
        if val.count > 10 {
            let supportCount = (Int(val[10]) << 8 | Int(val[9]))
            for i in 0..<16 {
                let state = (supportCount >> i) & 0x01
                
                switch i {
                case 0:
                    if state == 1 {
                        self.supportPositionTypeArray.append(ZycxPositionType.leftTop.rawValue)
                    }
                    break
                case 1:
                    if state == 1 {
                        self.supportPositionTypeArray.append(ZycxPositionType.leftMiddle.rawValue)
                    }
                    break
                case 2:
                    if state == 1 {
                        self.supportPositionTypeArray.append(ZycxPositionType.letfBottom.rawValue)
                    }
                    break
                case 3:
                    if state == 1 {
                        self.supportPositionTypeArray.append(ZycxPositionType.centerTop.rawValue)
                    }
                    break
                case 4:
                    if state == 1 {
                        self.supportPositionTypeArray.append(ZycxPositionType.centerMiddle.rawValue)
                    }
                    break
                case 5:
                    if state == 1 {
                        self.supportPositionTypeArray.append(ZycxPositionType.centerBottom.rawValue)
                    }
                    break
                case 6:
                    if state == 1 {
                        self.supportPositionTypeArray.append(ZycxPositionType.rightTop.rawValue)
                    }
                    break
                case 7:
                    if state == 1 {
                        self.supportPositionTypeArray.append(ZycxPositionType.rightMiddle.rawValue)
                    }
                    break
                case 8:
                    if state == 1 {
                        self.supportPositionTypeArray.append(ZycxPositionType.rightBottom.rawValue)
                    }
                    break
                default:
                    break
                }
            }
        }
        
        if val.count > 11 {
            self.offsetY = Int(val[11])
        }
        if val.count > 12 {
            let hiddenCount = Int(val[12])
            for i in 0..<8 {
                let state = (hiddenCount >> i) & 0x01
                
                switch i {
                case 0:
                    self.isShowTimePosition = state == 1 ? true : false
                    break
                case 1:
                    self.isShowTimeUp = state == 1 ? true : false
                    break
                case 2:
                    self.isShowTimeDown = state == 1 ? true : false
                    break
                default:
                    break
                }
            }
        }

        super.init()
    }
}

@objc public class ZycxFunctionModel_localDial:NSObject {
    @objc public private(set) var maxDialCount = 0         //内置表盘个数
    
    init(result:Int) {
        self.maxDialCount = result
        super.init()
    }
}

@objc public class ZycxFunctionModel_screenType:NSObject {

    @objc public private(set) var supportType = 0                //0:方 1:圆 2:圆角
    
    init(result:Int) {
        self.supportType = result
        super.init()
    }
}

@objc public class ZycxFunctionModel_platformType:NSObject {
    
    @objc public private(set) var platform = 0                 //0:瑞昱,1:杰理,2:Nordic
    
    init(result:Int) {
        self.platform = result
        super.init()
    }
}

@objc public class ZycxFunctionModel_localPlay:NSObject {
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

@objc public class ZycxDialFrameSizeModel:NSObject {
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

@objc public class ZycxDeviceInfomationModel:NSObject {

    @objc public private(set) var name = ""
    @objc public private(set) var firmwareVersion = ""
    @objc public private(set) var imageVersion = ""
    @objc public private(set) var fontVersion = ""
    @objc public private(set) var productId = ""
    @objc public private(set) var projectId = ""
    @objc public private(set) var mac = ""
    @objc public private(set) var serialNumber = ""
    @objc public private(set) var hardwareVersion = ""
    @objc public private(set) var dialSize = ZycxDialFrameSizeModel()
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        self.name = dic["name"] as! String
        self.firmwareVersion = dic["firmwareVersion"] as! String
        self.imageVersion = dic["imageVersion"] as! String
        self.fontVersion = dic["fontVersion"] as! String
        self.productId = dic["productId"] as! String
        self.projectId = dic["projectId"] as! String
        self.mac = dic["mac"] as! String
        self.serialNumber = dic["serialNumber"] as! String
        self.hardwareVersion = dic["hardwareVersion"] as! String
        self.dialSize = dic["dialSize"] as! ZycxDialFrameSizeModel
    }
    
}

@objc public class ZycxDeviceParametersModel:NSObject {
    @objc public var timezone = 0           //时区东区1-12 ，西区 13-24
    @objc public var timeString = ""        //时间    "yyyy-MM-dd HH:mm:ss"
    @objc public var timeFormat_is12 = false        //时间制式，0：24小时制，1：12小时制
    @objc public var weatherUnit_isH = false        //天气单位  0x00：摄氏度0x01：华氏度
    @objc public var screenLightLevel = 0       //屏幕亮度，范围：0~100%
    @objc public var screenLightTimeLong = 1    //亮屏时间，范围：1~60秒
    @objc public var localDialIndex = 0         //当前本地表盘序号，范围：0~255
    @objc public var languageIndex = 0          //当前语言，详见“语言类型列表说明”
    @objc public var messagePushModel:ZycxDeviceParametersModel_messagePush?
    @objc public var alarmListModel:[ZycxDeviceParametersModel_alarm] = []
    @objc public var customDialModel:ZycxDeviceParametersModel_customDial?
    @objc public var weatherModel:ZycxDeviceParametersModel_weatherListModel?
    @objc public var sosContactModel:ZycxDeviceParametersModel_contactPerson?
    @objc public var addressBookContactListModel:[ZycxDeviceParametersModel_contactPerson] = []
    @objc public var uuidString = ""
    @objc public var vibration = false      //震动，0-关闭 1-开启
    @objc public var sedentaryModel:ZycxDeviceParametersModel_sedentaryModel?
    @objc public var drinkWaterModel:ZycxDeviceParametersModel_drinkWaterModel?
    @objc public var disturbModel:ZycxDeviceParametersModel_disturbModel?
    @objc public var lostRemind = false
    @objc public var physiologicalModel:ZycxDeviceParametersModel_physiologicalModel?
    @objc public var bleName = ""
}

@objc public class ZycxDeviceParametersModel_messagePush:NSObject {
    @objc public private(set) var openCount:Double = 0
    @objc public var isOpenCall = false
    @objc public var isOpenSMS = false
    @objc public var isOpenInstagram = false
    @objc public var isOpenWechat = false
    @objc public var isOpenQQ = false
    @objc public var isOpenLine = false
    @objc public var isOpenLinkedIn = false
    @objc public var isOpenWhatsApp = false
    @objc public var isOpenTwitter = false
    @objc public var isOpenFacebook = false
    @objc public var isOpenMessenger = false
    @objc public var isOpenSkype = false
    @objc public var isOpenSnapchat = false
    @objc public var isOpenAlipay = false
    @objc public var isOpenTaoBao = false
    @objc public var isOpenDouYin = false
    @objc public var isOpenDingDing = false
    @objc public var isOpenJingDong = false
    @objc public var isOpenGmail = false
    @objc public var isOpenViber = false
    @objc public var isOpenYouTube = false
    @objc public var isOpenKakaoTalk = false
    @objc public var isOpenTelegram = false
    @objc public var isOpenHangouts = false
    @objc public var isOpenVkontakte = false
    @objc public var isOpenFlickr = false
    @objc public var isOpenTumblr = false
    @objc public var isOpenPinterest = false
    @objc public var isOpenTruecaller = false
    @objc public var isOpenPaytm = false
    @objc public var isOpenZalo = false
    @objc public var isOpenMicrosoftTeams = false
    
    public override init() {
        super.init()
    }
    
    init(result:Double) {
        self.openCount = result
        
        super.init()
        
        self.setOpenState(result: result)
    }
    
    public func setAllOpen() {
        self.setOpenState(result: 4294967295)
    }
    
    public func setOpenState(result:Double) {
        for i in 0..<64 {
            let state = (Int(result) >> i) & 0x01

            switch i {
            case 0:self.isOpenCall = state == 0 ? false:true
                break
            case 1:self.isOpenSMS = state == 0 ? false:true
                break
            case 2:self.isOpenInstagram = state == 0 ? false:true
                break
            case 3:self.isOpenWechat = state == 0 ? false:true
                break
            case 4:self.isOpenQQ = state == 0 ? false:true
                break
            case 5:self.isOpenLine = state == 0 ? false:true
                break
            case 6:self.isOpenLinkedIn = state == 0 ? false:true
                break
            case 7:self.isOpenWhatsApp = state == 0 ? false:true
                break
            case 8:self.isOpenTwitter = state == 0 ? false:true
                break
            case 9:self.isOpenFacebook = state == 0 ? false:true
                break
            case 10:self.isOpenMessenger = state == 0 ? false:true
                break
            case 11:self.isOpenSkype = state == 0 ? false:true
                break
            case 12:self.isOpenSnapchat = state == 0 ? false:true
                break
            case 13:self.isOpenAlipay = state == 0 ? false:true
                break
            case 14:self.isOpenTaoBao = state == 0 ? false:true
                break
            case 15:self.isOpenDouYin = state == 0 ? false:true
                break
            case 16:self.isOpenDingDing = state == 0 ? false:true
                break
            case 17:self.isOpenJingDong = state == 0 ? false:true
                break
            case 18:self.isOpenGmail = state == 0 ? false:true
                break
            case 19:self.isOpenViber = state == 0 ? false:true
                break
            case 20:self.isOpenYouTube = state == 0 ? false:true
                break
            case 21:self.isOpenKakaoTalk = state == 0 ? false:true
                break
            case 22:self.isOpenTelegram = state == 0 ? false:true
                break
            case 23:self.isOpenHangouts = state == 0 ? false:true
                break
            case 24:self.isOpenVkontakte = state == 0 ? false:true
                break
            case 25:self.isOpenFlickr = state == 0 ? false:true
                break
            case 26:self.isOpenTumblr = state == 0 ? false:true
                break
            case 27:self.isOpenPinterest = state == 0 ? false:true
                break
            case 28:self.isOpenTruecaller = state == 0 ? false:true
                break
            case 29:self.isOpenPaytm = state == 0 ? false:true
                break
            case 30:self.isOpenZalo = state == 0 ? false:true
                break
            case 31:self.isOpenMicrosoftTeams = state == 0 ? false:true
                break
            case 32://self.isSupport = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
    
    public func getCurrentOpenCount() -> Double {
        var count:Double = 0
        for i in 0..<31 {
            switch i {
            case 0:
                count += Double(self.isOpenCall ? (1 << i) : 0)
                break
            case 1:
                count += Double(self.isOpenSMS ? (1 << i) : 0)
                break
            case 2:
                count += Double(self.isOpenInstagram ? (1 << i) : 0)
                break
            case 3:
                count += Double(self.isOpenWechat ? (1 << i) : 0)
                break
            case 4:
                count += Double(self.isOpenQQ ? (1 << i) : 0)
                break
            case 5:
                count += Double(self.isOpenLine ? (1 << i) : 0)
                break
            case 6:
                count += Double(self.isOpenLinkedIn ? (1 << i) : 0)
                break
            case 7:
                count += Double(self.isOpenWhatsApp ? (1 << i) : 0)
                break
            case 8:
                count += Double(self.isOpenTwitter ? (1 << i) : 0)
                break
            case 9:
                count += Double(self.isOpenFacebook ? (1 << i) : 0)
                break
            case 10:
                count += Double(self.isOpenMessenger ? (1 << i) : 0)
                break
            case 11:
                count += Double(self.isOpenSkype ? (1 << i) : 0)
                break
            case 12:
                count += Double(self.isOpenSnapchat ? (1 << i) : 0)
                break
            case 13:
                count += Double(self.isOpenAlipay ? (1 << i) : 0)
                break
            case 14:
                count += Double(self.isOpenTaoBao ? (1 << i) : 0)
                break
            case 15:
                count += Double(self.isOpenDouYin ? (1 << i) : 0)
                break
            case 16:
                count += Double(self.isOpenDingDing ? (1 << i) : 0)
                break
            case 17:
                count += Double(self.isOpenJingDong ? (1 << i) : 0)
                break
            case 18:
                count += Double(self.isOpenGmail ? (1 << i) : 0)
                break
            case 19:
                count += Double(self.isOpenViber ? (1 << i) : 0)
                break
            case 20:
                count += Double(self.isOpenYouTube ? (1 << i) : 0)
                break
            case 21:
                count += Double(self.isOpenKakaoTalk ? (1 << i) : 0)
                break
            case 22:
                count += Double(self.isOpenTelegram ? (1 << i) : 0)
                break
            case 23:
                count += Double(self.isOpenHangouts ? (1 << i) : 0)
                break
            case 24:
                count += Double(self.isOpenVkontakte ? (1 << i) : 0)
                break
            case 25:
                count += Double(self.isOpenFlickr ? (1 << i) : 0)
                break
            case 26:
                count += Double(self.isOpenTumblr ? (1 << i) : 0)
                break
            case 27:
                count += Double(self.isOpenPinterest ? (1 << i) : 0)
                break
            case 28:
                count += Double(self.isOpenTruecaller ? (1 << i) : 0)
                break
            case 29:
                count += Double(self.isOpenPaytm ? (1 << i) : 0)
                break
            case 30:
                count += Double(self.isOpenZalo ? (1 << i) : 0)
                break
            case 31:
                count += Double(self.isOpenMicrosoftTeams ? (1 << i) : 0)
                break
            case 32://self.isSupport = state == 0 ? false:true
                break
            default:
                break
            }
        }
        self.openCount = count
        return count
    }
}

@objc public enum ZycxAlarmType : Int {
    case single
    case cycle
}
@objc public class ZycxDeviceParametersModel_alarm:NSObject {
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
    @objc public var alarmType:ZycxAlarmType = .single
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

@objc public enum ZycxPositionType : Int,CaseIterable {
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
@objc public enum ZycxPositionShowType : Int {
    case close
    case date
    case sleep
    case heartrate
    case step
}
@objc public class ZycxDeviceParametersModel_customDial:NSObject {
    @objc public private(set) var colorHex:String = "0xFFFFFF"
    @objc public var color:UIColor = .white
    @objc public var positionType:ZycxPositionType = .leftTop
    @objc public var timeUpType:ZycxPositionShowType = .close
    @objc public var timeDownType:ZycxPositionShowType = .close
    
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
        self.positionType = ZycxPositionType.init(rawValue: Int(positionType) ?? 0) ?? .leftTop
        self.timeUpType = ZycxPositionShowType.init(rawValue: Int(timeUpType) ?? 0) ?? .close
        self.timeDownType = ZycxPositionShowType.init(rawValue: Int(timeDownType) ?? 0) ?? .close
    }
}

@objc public enum ZycxWeatherType : Int {
    case overcast               //阴
    case fog                    //雾
    case sunny                  //晴
    case cloudy                 //多云
    case snow                   //雪
    case rain                   //雨
}
@objc public class ZycxDeviceParametersModel_weatherListModel:NSObject {
    @objc public var timeString = ""        //时间    "yyyy-MM-dd HH:mm:ss"
    @objc public var weatherArray:[ZycxDeviceParametersModel_weather] = .init()
}
@objc public class ZycxDeviceParametersModel_weather:NSObject {
    @objc public var dayCount:Int = 0 {
        didSet {
            if self.dayCount < Int8.min || self.dayCount > Int8.max {
                self.dayCount = 0
                //print(" Int8.min = \(Int8.min) , Int8.max = \(Int8.max)")
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var type:ZycxWeatherType = ZycxWeatherType.sunny {
        didSet {
            if self.type.rawValue < Int8.min || self.type.rawValue > Int8.max {
                self.type = ZycxWeatherType.sunny
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
    
    public override init() {
        super.init()
    }
}

@objc public class ZycxDeviceParametersModel_contactPerson:NSObject {
    @objc public var name = ""
    @objc public var phoneNumber = ""
    
    public override init() {
        super.init()
    }
}

@objc public class ZycxDeviceParametersModel_sedentaryModel:NSObject{
    @objc public var isOpen:Bool = false
    @objc public var timeLong:Int = 0 {
        didSet {
            if self.timeLong < UInt8.min || self.timeLong > UInt8.max {
                self.timeLong = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var timeArray:[ZycxDeviceParametersModel_timeModel] = []
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        let result = Int(dic["isOpen"] as! String) ?? 0
        
        self.isOpen = result == 0 ? false:true
        self.timeLong = Int(dic["timeLong"] as! String) ?? 0
        self.timeArray = dic["timeArray"] as? [ZycxDeviceParametersModel_timeModel] ?? []
    }
}

@objc public class ZycxDeviceParametersModel_disturbModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var timeModel:ZycxDeviceParametersModel_timeModel = ZycxDeviceParametersModel_timeModel.init()
    
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

@objc public class ZycxDeviceParametersModel_drinkWaterModel:NSObject {
    @objc public var isOpen:Bool = false
    @objc public var remindInterval:Int = 0 {
        didSet {
            if self.remindInterval < UInt8.min || self.remindInterval > UInt8.max {
                self.remindInterval = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var timeModel:ZycxDeviceParametersModel_timeModel = ZycxDeviceParametersModel_timeModel.init()
    
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

@objc public class ZycxDeviceParametersModel_physiologicalModel:NSObject {
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

@objc public class ZycxDeviceParametersModel_timeModel:NSObject {
    @objc public var startHour:Int = 0 {
        didSet {
            if self.startHour < UInt8.min || self.startHour > UInt8.max {
                self.startHour = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var startMinute:Int = 0 {
        didSet {
            if self.startMinute < UInt8.min || self.startMinute > UInt8.max {
                self.startMinute = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var endHour:Int = 0 {
        didSet {
            if self.endHour < UInt8.min || self.endHour > UInt8.max {
                self.endHour = 0
                print("输入参数超过范围,改为默认值0")
            }
        }
    }
    @objc public var endMinute:Int = 0 {
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

@objc public class ZywlOnlineDialModel:NSObject {
    @objc public var dialId:Int = -1
    @objc public var dialImageUrl:String?
    @objc public var dialFileUrl:String?
    @objc public var dialName:String?
    @objc public var dialPreviewUrl:String?
    
    public override init() {
        super.init()
    }
}

@objc public class ZycxHeadphoneFunctionListModel:NSObject {
    @objc public private(set) var functionList_photoControl = false             //拍照控制
    @objc public private(set) var functionList_musicControl = false             //音乐控制
    @objc public private(set) var functionList_findDevice = false               //查找设备
    @objc public private(set) var functionList_powerOff = false                 //关机控制
    @objc public private(set) var functionList_restart = false                  //重启控制
    @objc public private(set) var functionList_resetFactory = false             //恢复出厂控制
    @objc public private(set) var functionList_handUpPhone = false              //挂断电话
    @objc public private(set) var functionList_answerPhone = false              //接听电话
    @objc public private(set) var functionList_eqMode = false                   //eq模式
    @objc public private(set) var functionList_customEq = false                 //自定义eq
    @objc public private(set) var functionList_ambientSoundEffect = false       //环境音设置
    @objc public private(set) var functionList_spaceSoundEffect = false         //空间音效设置
    @objc public private(set) var functionList_inEarPerception = false          //入耳感知播放
    @objc public private(set) var functionList_extremeSpeedMode = false         //极速模式
    @objc public private(set) var functionList_windNoiseResistantMode = false   //抗风噪模式
    @objc public private(set) var functionList_bassToneEnhancement = false      //低音增强
    @objc public private(set) var functionList_lowFrequencyEnhancement = false  //低频增强
    @objc public private(set) var functionList_coupletPattern = false           //对联模式
    @objc public private(set) var functionList_desktopMode = false              //桌面模式
    @objc public private(set) var functionList_shakeSong = false                //摇一摇切歌
    @objc public private(set) var functionList_deviceType = false               //设备类型
    @objc public private(set) var functionList_customButton = false             //自定义按键
    @objc public private(set) var functionList_customButtonType = false         //自定义按键类型
    @objc public private(set) var functionList_soundEffectMode = false          //音效模式
    @objc public private(set) var functionList_patternMode = false              //信号模式
    @objc public private(set) var functionList_resetDefaultCustomButton = false //恢复默认自定义按键

    @objc public private(set) var functionDetail_eqMode:ZycxHeadphoneFunctionModel_eqMode?  //支持eq模式
    @objc public private(set) var functionDetail_customButton:ZycxHeadphoneFunctionModel_customButton?   //自定义按键功能
    @objc public private(set) var functionDetail_ambientSoundEffect:ZycxHeadphoneFunctionModel_ambientSoundEffect?   //环境音
    @objc public private(set) var functionDetail_spaceSoundEffect:ZycxHeadphoneFunctionModel_spaceSoundEffect?   //空间音效
    @objc public private(set) var functionDetail_customButtonType:ZycxHeadphoneFunctionModel_customButtonType?   //自定义按键类型
    @objc public private(set) var functionDetail_soundEffectMode:ZycxHeadphoneFunctionModel_soundEffectMode?     //音效模式
    @objc public private(set) var functionDetail_patternMode:ZycxHeadphoneFunctionModel_patternMode?            //信号模式
    @objc public private(set) var functionDetail_customEq:ZycxHeadphoneFunctionModel_customEqModel?             //自定义eq
    
    init(val:[UInt8]) {
        
        super.init()
        if val.count <= 0 {
            print("功能列表异常无法解析 长度=0")
            return
        }
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
        
        currentIndex = Int(2+mainLength)//相比就协议多了一个功能项长度
        self.dealDetailFunction(index: currentIndex, val: val)

    }
    
    func dealDetailFunction(index:Int,val:[UInt8]) {
        printLog("dealDetailFunction index =\(index)")
        if index >= val.count {
            printLog("dealDetailFunction 已全部处理完毕")
            printLog("\(self.showAllSupportFunctionLog())")
            ZywlSDKLog.writeStringToSDKLog(string: self.showAllSupportFunctionLog())
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
            case 0:self.functionDetail_eqMode = ZycxHeadphoneFunctionModel_eqMode.init(val: functionVal)
                break
            case 1:self.functionDetail_customButton = ZycxHeadphoneFunctionModel_customButton.init(val: functionVal)
                break
            case 2:
                self.functionDetail_ambientSoundEffect = ZycxHeadphoneFunctionModel_ambientSoundEffect.init(result: functionCount)
                //self.functionDetail_customEq = ZycxHeadphoneFunctionModel_customEqModel.init(val: [0x0c,0x0,0x0a,0x00,0x1E,0x00,0x3e,0x00,0x7D,0x00,0xFA,0x01,0xf4,0x03,0xe8,0x07,0xd0,0x0f,0xa0,0x1f,0x40,0x3e,0x80])
                break
            case 3:self.functionDetail_spaceSoundEffect = ZycxHeadphoneFunctionModel_spaceSoundEffect.init(result: functionCount)
                break
            case 4:self.functionDetail_customButtonType = ZycxHeadphoneFunctionModel_customButtonType.init(result: functionCount)
                break
            case 5:self.functionDetail_soundEffectMode = ZycxHeadphoneFunctionModel_soundEffectMode.init(result: functionCount)
                break
            case 6:self.functionDetail_patternMode = ZycxHeadphoneFunctionModel_patternMode.init(result: functionCount)
                break
            case 7:self.functionDetail_customEq = ZycxHeadphoneFunctionModel_customEqModel.init(val: functionVal)
                break
            case 8:
                break
            case 9:
                break
            case 10:
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
                break
            case 16:
                break
            case 17:
                break
            case 18:
                break
            case 19:
                break
            case 20:
                break
            case 21:
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
            case 36:
                break
            case 37:
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
                break
            case 44:
                break
            case 45:
                break
            case 46:
                break
            case 47:
                break
            case 48:
                break
            case 49:
                break
            case 52:
                break
            case 53:
                break
            case 54:
                break
            case 56:
                break
            case 57:
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
            case 0:self.functionList_photoControl = state == 0 ? false:true
                break
            case 1:self.functionList_musicControl = state == 0 ? false:true
                break
            case 2:self.functionList_findDevice = state == 0 ? false:true
                break
            case 3:self.functionList_powerOff = state == 0 ? false:true
                break
            case 4:self.functionList_restart = state == 0 ? false:true
                break
            case 5:self.functionList_resetFactory = state == 0 ? false:true
                break
            case 6:self.functionList_handUpPhone = state == 0 ? false:true
                break
            case 7:self.functionList_answerPhone = state == 0 ? false:true
                break
            case 8:self.functionList_eqMode = state == 0 ? false:true
                break
            case 9:self.functionList_customEq = state == 0 ? false:true
                break
            case 10:self.functionList_ambientSoundEffect = state == 0 ? false:true
                break
            case 11:self.functionList_spaceSoundEffect = state == 0 ? false:true
                break
            case 12:self.functionList_inEarPerception = state == 0 ? false:true
                break
            case 13:self.functionList_extremeSpeedMode = state == 0 ? false:true
                break
            case 14:self.functionList_windNoiseResistantMode = state == 0 ? false:true
                break
            case 15:self.functionList_bassToneEnhancement = state == 0 ? false:true
                break
            case 16:self.functionList_lowFrequencyEnhancement = state == 0 ? false:true
                break
            case 17:self.functionList_coupletPattern = state == 0 ? false:true
                break
            case 18:self.functionList_desktopMode = state == 0 ? false:true
                break
            case 19:self.functionList_shakeSong = state == 0 ? false:true
                break
            case 20:self.functionList_deviceType = state == 0 ? false:true
                break
            case 21:self.functionList_customButton = state == 0 ? false:true
                break
            case 22:self.functionList_customButtonType = state == 0 ? false:true
                break
            case 23:self.functionList_soundEffectMode = state == 0 ? false:true
                break
            case 24:self.functionList_patternMode = state == 0 ? false:true
                break
            case 25:self.functionList_resetDefaultCustomButton = state == 0 ? false:true
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
            default:
                break
            }
        }
    }

    @objc public func showAllSupportFunctionLog() -> String{
        var log = ""

        
        if self.functionList_photoControl {
            log += "\n拍照控制"
        }
        if self.functionList_musicControl {
            log += "\n音乐控制"
        }
        if self.functionList_findDevice {
            log += "\n查找设备"
        }
        if self.functionList_powerOff {
            log += "\n关机"
        }
        if self.functionList_restart {
            log += "\n重启"
        }
        if self.functionList_resetFactory {
            log += "\n恢复出厂设置"
        }
        if self.functionList_handUpPhone {
            log += "\n挂断电话"
        }
        if self.functionList_answerPhone {
            log += "\n接听电话"
        }
        if self.functionList_eqMode {
            log += "\neq模式"
            if let model = self.functionDetail_eqMode {
                if model.isSupportDefault {
                    log += "\n  默认"
                }
                if model.isSupportHeavyBass {
                    log += "\n  重低音"
                }
                if model.isSupportCinema {
                    log += "\n  影院音效"
                }
                if model.isSupportDJ {
                    log += "\n  DJ"
                }
                if model.isSupportPopularity {
                    log += "\n  流行"
                }
                if model.isSupportJazz {
                    log += "\n  爵士"
                }
                if model.isSupportClassical {
                    log += "\n  古典"
                }
                if model.isSupportRockRoll {
                    log += "\n  摇滚"
                }
                if model.isSupportOriginal {
                    log += "\n  原声"
                }
                if model.isSupportNostalgia {
                    log += "\n  怀旧"
                }
                if model.isSupportBeats {
                    log += "\n  律动"
                }
                if model.isSupportDanceMusic {
                    log += "\n  舞曲"
                }
                if model.isSupportElectrons {
                    log += "\n  电子"
                }
                if model.isSupportLiyin {
                    log += "\n  丽音"
                }
                if model.isSupportPureHumanVoice {
                    log += "\n  纯净人声"
                }
                if model.isSupportCustomization {
                    log += "\n  自定义"
                }
            }
        }
        if self.functionList_customEq {
            log += "\n自定义eq音效"
            if let model = self.functionDetail_customEq {
                log += "\n  增益范围\(model.scopeCount)"
                log += "\n  分辨率\(model.accuracyCount)"
                log += "\n  频率数组\(model.frequencyArray)"
            }
        }
        if self.functionList_ambientSoundEffect {
            log += "\n环境音效"
            if let model = self.functionDetail_ambientSoundEffect {
                if model.isSupportPassThrough {
                    log += "\n  通透"
                }
                if model.isSupportNoiseReduction {
                    log += "\n  降噪"
                }
            }
        }
        if self.functionList_spaceSoundEffect {
            log += "\n空间音效"
            if let model = self.functionDetail_spaceSoundEffect {
                if model.isSupportMusic {
                    log += "\n  音乐"
                }
                if model.isSupportCinema {
                    log += "\n  影院"
                }
                if model.isSupportGame {
                    log += "\n  游戏"
                }
            }
        }
        if self.functionList_inEarPerception {
            log += "\n入耳感知播放"
        }
        if self.functionList_extremeSpeedMode {
            log += "\n极速模式"
        }
        if self.functionList_windNoiseResistantMode {
            log += "\n抗风噪模式"
        }
        if self.functionList_bassToneEnhancement {
            log += "\n低音增强"
        }
        if self.functionList_lowFrequencyEnhancement {
            log += "\n低频增强"
        }
        if self.functionList_coupletPattern {
            log += "\n对联模式"
        }
        if self.functionList_desktopMode {
            log += "\n桌面模式"
        }
        if self.functionList_shakeSong {
            log += "\n摇一摇切歌模式"
        }
        if self.functionList_deviceType {
            log += "\n设备类型"
        }
        if self.functionList_customButton {
            log += "\n自定义按键"
            if let model = self.functionDetail_customButton {
                if model.isSupportNoFunction {
                    log += "\n  无功能"
                }
                if model.isSupportPlayPause {
                    log += "\n  播放/暂停"
                }
                if model.isSupportLastSong {
                    log += "\n  上一曲"
                }
                if model.isSupportNextSong {
                    log += "\n  下一曲"
                }
                if model.isSupportVolumeAdd {
                    log += "\n  音量加"
                }
                if model.isSupportVolumeReduction {
                    log += "\n  音量减"
                }
                if model.isSupportCallAnswering {
                    log += "\n  来电接听"
                }
                if model.isSupportCallRejection {
                    log += "\n  来电拒绝"
                }
                if model.isSupportHangUp {
                    log += "\n  挂断电话"
                }
                if model.isSupportEnvironmentSoundSwitch {
                    log += "\n  环境音切换"
                }
                if model.isSupportVoiceAssistant {
                    log += "\n  唤醒语音助手"
                }
                if model.isSupportCallBack {
                    log += "\n  回拨电话"
                }
                if model.isSupportEqSwitch {
                    log += "\n  EQ切换"
                }
                if model.isSupportGameModeSwitch {
                    log += "\n  游戏模式切换"
                }
                if model.isSupportAncModeSwitch {
                    log += "\n  ANC模式切换"
                }
            }
        }
        if self.functionList_customButtonType {
            log += "\n自定义按键类型"
            if let model = self.functionDetail_customButtonType {
                if model.isSupportSingleClick {
                    log += "\n  单击"
                }
                if model.isSupportDoubleClick {
                    log += "\n  双击"
                }
                if model.isSupportThreeClick {
                    log += "\n  三击"
                }
                if model.isSupportLongPress {
                    log += "\n  长按"
                }
                if model.isSupportFourClick {
                    log += "\n  四击"
                }
                if model.isSupportFiveClick {
                    log += "\n  五击"
                }
                if model.isSupportSevenClick {
                    log += "\n  七击"
                }
                if model.isSupportTenClick {
                    log += "\n  十击"
                }
            }
        }
        if self.functionList_soundEffectMode {
            log += "\n音效模式"
            if let model = self.functionDetail_soundEffectMode {
                if model.isSupportSound {
                    log += "\n  音响模式"
                }
                if model.isSupportPrivacy {
                    log += "\n  私密模式"
                }
                if model.isSupportSpaceBass {
                    log += "\n  空间低音"
                }
            }
        }
        if self.functionList_patternMode {
            log += "\n信号模式"
            if let model = self.functionDetail_patternMode {
                if model.isSupportCompatible {
                    log += "\n  兼容模式"
                }
                if model.isSupportThroughWall {
                    log += "\n  穿墙模式"
                }
                if model.isSupportOverspeed {
                    log += "\n  超速模式"
                }
            }
        }
        if self.functionList_resetDefaultCustomButton {
            log += "\n双耳自定义按键恢复默认"
        }
        return log
    }
}

@objc public class ZycxHeadphoneDeviceInfomationModel:NSObject {

    @objc public private(set) var deviceName = ""
    @objc public private(set) var mac_ble = ""
    @objc public private(set) var serialNumber = ""
    @objc public private(set) var hardwareVersion = ""
    @objc public private(set) var softwareVersion = ""
    @objc public private(set) var bleName = ""
    @objc public private(set) var mac_br = ""
    @objc public private(set) var bleName_br = ""
    
    public override init() {
        super.init()
    }
    
    init(dic:[String:Any]) {
        super.init()
        
        self.deviceName = dic["deviceName"] as? String ?? ""
        self.mac_ble = dic["mac_ble"] as? String ?? ""
        self.serialNumber = dic["serialNumber"] as? String ?? ""
        self.hardwareVersion = dic["hardwareVersion"] as? String ?? ""
        self.softwareVersion = dic["softwareVersion"] as? String ?? ""
        self.bleName = dic["bleName"] as? String ?? ""
        self.mac_br = dic["mac_br"] as? String ?? ""
        self.bleName_br = dic["bleName_br"] as? String ?? ""
    }
    
}

@objc public class ZycxHeadphoneDeviceParametersModel:NSObject {
    @objc public var customButtonList:[ZycxHeadphoneDeviceParametersModel_customButton] = .init()           //自定义按键
    @objc public var eqMode = 0        //eq模式 0：默认、1：重低音、2：影院音效、3：DJ、4：流行、5：爵士、6：古典、7：摇滚、8：原声、9：怀旧、10：律动、11：舞曲、12：电子、13：丽音、14：纯净人声、15：自定义
    @objc public var customEqModel:ZycxHeadphoneDeviceParametersModel_customEqModel?        //自定义 EQ 音效
    @objc public var ambientSoundEffect = 0        //环境音，0：关闭/默认、1：通透、2：降噪
    @objc public var spaceSoundEffect = 0       //空间音效，0：关闭/默认、1：音乐、2：影院、3：游戏
    @objc public var inEarPerception = 0    //入耳感知播放，0：关闭/默认 1：开
    @objc public var extremeSpeedMode = 0         //极速模式，0：关闭/默认、1：开
    @objc public var windNoiseResistantMode = 0          //抗风噪模式，0：关闭/默认、1：开
    @objc public var bassToneEnhancement = 0         //低音增强模式，0：关闭/默认、1：开
    @objc public var lowFrequencyEnhancement = 0     //低频增强模式，0：关闭/默认、1：开
    @objc public var coupletPattern = 0     //对联模式，0：关闭/默认、1：开
    @objc public var desktopMode = 0        //桌面模式，0：关闭/默认、1：开
    @objc public var shakeSong = 0          //摇一摇切歌模式 0：关闭/默认 1：开
    @objc public var voiceVolume = 0        //耳机音量 0x0 到 0x16
    @objc public var leftBattery = 0        //左耳耳机电量
    @objc public var rightBattery = 0       //右耳耳机电量
    @objc public var soundEffectMode = 0    //音效模式，0：音响模式、1：私密模式、2：空间低音
    @objc public var patternMode = 0        //信号模式，0：兼容模式、1：穿墙模式、2：超速模式
}

@objc public class ZycxHeadphoneDeviceParametersModel_customButton:NSObject {
    @objc public var headphoneType = 0  //0：左耳，1：右耳
    @objc public var touchType = 0      //0 单击，1 双击，2 三击，3 长按
    @objc public var commandType = 0    //0无功能 1播放/暂停 2上一曲 3下一曲 4音量+ 5音量- 6来电接听 7来电拒绝 8挂断电话 9环境音切换 10唤醒语音助手 11回拨电话 12eq切换 13游戏模式切换 14ANC切换
}

@objc public class ZycxHeadphoneDeviceParametersModel_customEqModel:NSObject {
    @objc public var totalBuff = 0      //范围-12dB~12dB；分辨率 0.1； 0 代表-12dB、120 代表 0dB、240 代表 12dB
    @objc public var eqListArray:[ZycxHeadphoneDeviceParametersModel_customEqItem] = .init()
}
@objc public class ZycxHeadphoneDeviceParametersModel_customEqItem:NSObject {
    @objc public var frequency = 0      //1 代表 1HZ
    @objc public var buff = 0           //范围-12dB~12dB；分辨率 0.1；0 代表-12dB、120 代表 0dB、240 代表 12dB；
    @objc public var Qvalue = 10        //分辨率 0.1；0 代表 0，100 代表 10；
    @objc public var type = 0           //0：直通、1：低架、2：高架 3：低通 4：高通
}
@objc public class ZycxHeadphoneFunctionModel_eqMode:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportDefault = false              //0 默认
    @objc public private(set) var isSupportHeavyBass = false            //1 重低音
    @objc public private(set) var isSupportCinema = false               //2 影院音效
    @objc public private(set) var isSupportDJ = false                   //3 DJ
    @objc public private(set) var isSupportPopularity = false           //4 流行
    @objc public private(set) var isSupportJazz = false                 //5 爵士
    @objc public private(set) var isSupportClassical = false            //6 古典
    @objc public private(set) var isSupportRockRoll = false             //7 摇滚
    @objc public private(set) var isSupportOriginal = false             //8 原声
    @objc public private(set) var isSupportNostalgia = false            //9 怀旧
    @objc public private(set) var isSupportBeats = false                //10 律动
    @objc public private(set) var isSupportDanceMusic = false           //11 舞曲
    @objc public private(set) var isSupportElectrons = false            //12 电子
    @objc public private(set) var isSupportLiyin = false                //13 丽音
    @objc public private(set) var isSupportPureHumanVoice = false       //14 纯净人声
    @objc public private(set) var isSupportCustomization = false        //15 自定义

    init(val:[UInt8]) {
        if val.count >= 4 {
            self.supportCount = (Int(val[0]) << 24 | Int(val[1]) << 16 | Int(val[2]) << 8 | Int(val[3]))
        }else{
            print("ZycxHeadphoneFunctionModel_eqMode 数据长度异常")
        }
        let result = self.supportCount
        super.init()
        
        for i in 0..<32 {
            let state = (result >> i) & 0x01

            switch i {
            case 0:self.isSupportDefault = state == 0 ? false:true
                break
            case 1:self.isSupportHeavyBass = state == 0 ? false:true
                break
            case 2:self.isSupportCinema = state == 0 ? false:true
                break
            case 3:self.isSupportDJ = state == 0 ? false:true
                break
            case 4:self.isSupportPopularity = state == 0 ? false:true
                break
            case 5:self.isSupportJazz = state == 0 ? false:true
                break
            case 6:self.isSupportClassical = state == 0 ? false:true
                break
            case 7:self.isSupportRockRoll = state == 0 ? false:true
                break
            case 8:self.isSupportOriginal = state == 0 ? false:true
                break
            case 9:self.isSupportNostalgia = state == 0 ? false:true
                break
            case 10:self.isSupportBeats = state == 0 ? false:true
                break
            case 11:self.isSupportDanceMusic = state == 0 ? false:true
                break
            case 12:self.isSupportElectrons = state == 0 ? false:true
                break
            case 13:self.isSupportLiyin = state == 0 ? false:true
                break
            case 14:self.isSupportPureHumanVoice = state == 0 ? false:true
                break
            case 15:self.isSupportCustomization = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
    
    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<32 {
            let state = (result >> i) & 0x01

            switch i {
            case 0:self.isSupportDefault = state == 0 ? false:true
                break
            case 1:self.isSupportHeavyBass = state == 0 ? false:true
                break
            case 2:self.isSupportCinema = state == 0 ? false:true
                break
            case 3:self.isSupportDJ = state == 0 ? false:true
                break
            case 4:self.isSupportPopularity = state == 0 ? false:true
                break
            case 5:self.isSupportJazz = state == 0 ? false:true
                break
            case 6:self.isSupportClassical = state == 0 ? false:true
                break
            case 7:self.isSupportRockRoll = state == 0 ? false:true
                break
            case 8:self.isSupportOriginal = state == 0 ? false:true
                break
            case 9:self.isSupportNostalgia = state == 0 ? false:true
                break
            case 10:self.isSupportBeats = state == 0 ? false:true
                break
            case 11:self.isSupportDanceMusic = state == 0 ? false:true
                break
            case 12:self.isSupportElectrons = state == 0 ? false:true
                break
            case 13:self.isSupportLiyin = state == 0 ? false:true
                break
            case 14:self.isSupportPureHumanVoice = state == 0 ? false:true
                break
            case 15:self.isSupportCustomization = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}
@objc public class ZycxHeadphoneFunctionModel_customButton:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportNoFunction = false               //0 无功能
    @objc public private(set) var isSupportPlayPause = false                //1 播放/暂停
    @objc public private(set) var isSupportLastSong = false                 //2 上一曲
    @objc public private(set) var isSupportNextSong = false                 //3 下一曲
    @objc public private(set) var isSupportVolumeAdd = false                //4 音量加
    @objc public private(set) var isSupportVolumeReduction = false          //5 音量减
    @objc public private(set) var isSupportCallAnswering = false            //6 来电接听
    @objc public private(set) var isSupportCallRejection = false            //7 来电拒绝
    @objc public private(set) var isSupportHangUp = false                   //0 挂断电话
    @objc public private(set) var isSupportEnvironmentSoundSwitch = false   //1 环境音切换
    @objc public private(set) var isSupportVoiceAssistant = false           //2 唤醒语音助手
    @objc public private(set) var isSupportCallBack = false                 //3 回拨电话
    @objc public private(set) var isSupportEqSwitch = false                 //4 eq切换
    @objc public private(set) var isSupportGameModeSwitch = false           //5 游戏模式切换
    @objc public private(set) var isSupportAncModeSwitch = false            //6 ANC模式切换

    init(val:[UInt8]) {
        if val.count >= 4 {
            self.supportCount = (Int(val[0]) << 24 | Int(val[1]) << 16 | Int(val[2]) << 8 | Int(val[3]))
        }else{
            print("ZycxHeadphoneFunctionModel_customButton 数据长度异常")
        }
        let result = self.supportCount
        super.init()
        
        for i in 0..<24 {
            let state = (result >> i) & 0x01

            switch i {
            case 0:self.isSupportNoFunction = state == 0 ? false:true
                break
            case 1:self.isSupportPlayPause = state == 0 ? false:true
                break
            case 2:self.isSupportLastSong = state == 0 ? false:true
                break
            case 3:self.isSupportNextSong = state == 0 ? false:true
                break
            case 4:self.isSupportVolumeAdd = state == 0 ? false:true
                break
            case 5:self.isSupportVolumeReduction = state == 0 ? false:true
                break
            case 6:self.isSupportCallAnswering = state == 0 ? false:true
                break
            case 7:self.isSupportCallRejection = state == 0 ? false:true
                break
            case 8:self.isSupportHangUp = state == 0 ? false:true
                break
            case 9:self.isSupportEnvironmentSoundSwitch = state == 0 ? false:true
                break
            case 10:self.isSupportVoiceAssistant = state == 0 ? false:true
                break
            case 11:self.isSupportCallBack = state == 0 ? false:true
                break
            case 12:self.isSupportEqSwitch = state == 0 ? false:true
                break
            case 13:self.isSupportGameModeSwitch = state == 0 ? false:true
                break
            case 14:self.isSupportAncModeSwitch = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
    
    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<24 {
            let state = (result >> i) & 0x01

            switch i {
            case 0:self.isSupportNoFunction = state == 0 ? false:true
                break
            case 1:self.isSupportPlayPause = state == 0 ? false:true
                break
            case 2:self.isSupportLastSong = state == 0 ? false:true
                break
            case 3:self.isSupportNextSong = state == 0 ? false:true
                break
            case 4:self.isSupportVolumeAdd = state == 0 ? false:true
                break
            case 5:self.isSupportVolumeReduction = state == 0 ? false:true
                break
            case 6:self.isSupportCallAnswering = state == 0 ? false:true
                break
            case 7:self.isSupportCallRejection = state == 0 ? false:true
                break
            case 8:self.isSupportHangUp = state == 0 ? false:true
                break
            case 9:self.isSupportEnvironmentSoundSwitch = state == 0 ? false:true
                break
            case 10:self.isSupportVoiceAssistant = state == 0 ? false:true
                break
            case 11:self.isSupportCallBack = state == 0 ? false:true
                break
            case 12:self.isSupportEqSwitch = state == 0 ? false:true
                break
            case 13:self.isSupportGameModeSwitch = state == 0 ? false:true
                break
            case 14:self.isSupportAncModeSwitch = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}
@objc public class ZycxHeadphoneFunctionModel_ambientSoundEffect:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportPassThrough = false                  //0 通透
    @objc public private(set) var isSupportNoiseReduction = false               //1 降噪
    @objc public private(set) var isSupportClose = true                         //2 关闭
    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<8 {
            let state = (result >> i) & 0x01

            switch i {
            case 0:self.isSupportPassThrough = state == 0 ? false:true
                break
            case 1:self.isSupportNoiseReduction = state == 0 ? false:true
                break
            case 2:self.isSupportClose = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}
@objc public class ZycxHeadphoneFunctionModel_spaceSoundEffect:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportMusic = false               //0 音乐
    @objc public private(set) var isSupportCinema = false                //1 影院
    @objc public private(set) var isSupportGame = false                 //2 游戏
    @objc public private(set) var isSupportClose = true                 //2 关闭

    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<8 {
            let state = (result >> i) & 0x01
            switch i {
            case 0:self.isSupportMusic = state == 0 ? false:true
                break
            case 1:self.isSupportCinema = state == 0 ? false:true
                break
            case 2:self.isSupportGame = state == 0 ? false:true
                break
            case 3:self.isSupportClose = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}

@objc public class ZycxHeadphoneFunctionModel_customButtonType:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportSingleClick = false                  //0 单机
    @objc public private(set) var isSupportDoubleClick = false                  //1 双击
    @objc public private(set) var isSupportThreeClick = false                   //2 三击
    @objc public private(set) var isSupportLongPress = true                     //3 长按
    @objc public private(set) var isSupportFourClick = true                     //4 四击
    @objc public private(set) var isSupportFiveClick = true                     //5 五击
    @objc public private(set) var isSupportSevenClick = true                    //6 七击
    @objc public private(set) var isSupportTenClick = true                      //7 十击
    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<8 {
            let state = (result >> i) & 0x01
            switch i {
            case 0:self.isSupportSingleClick = state == 0 ? false:true
                break
            case 1:self.isSupportDoubleClick = state == 0 ? false:true
                break
            case 2:self.isSupportThreeClick = state == 0 ? false:true
                break
            case 3:self.isSupportLongPress = state == 0 ? false:true
                break
            case 4:self.isSupportFourClick = state == 0 ? false:true
                break
            case 5:self.isSupportFiveClick = state == 0 ? false:true
                break
            case 6:self.isSupportSevenClick = state == 0 ? false:true
                break
            case 7:self.isSupportTenClick = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}

@objc public class ZycxHeadphoneFunctionModel_soundEffectMode:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportSound = false                  //0 音响模式
    @objc public private(set) var isSupportPrivacy = false                  //1 私密模式
    @objc public private(set) var isSupportSpaceBass = false                   //2 空间低音

    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<8 {
            let state = (result >> i) & 0x01
            switch i {
            case 0:self.isSupportSound = state == 0 ? false:true
                break
            case 1:self.isSupportPrivacy = state == 0 ? false:true
                break
            case 2:self.isSupportSpaceBass = state == 0 ? false:true
                break
                break
            default:
                break
            }
        }
    }
}

@objc public class ZycxHeadphoneFunctionModel_patternMode:NSObject {
    var supportCount = 0
    @objc public private(set) var isSupportCompatible = false                  //0 兼容
    @objc public private(set) var isSupportThroughWall = false                  //1 穿墙
    @objc public private(set) var isSupportOverspeed = false                   //2 超速

    init(result:Int) {
        self.supportCount = result
        
        super.init()
        
        for i in 0..<8 {
            let state = (result >> i) & 0x01
            switch i {
            case 0:self.isSupportCompatible = state == 0 ? false:true
                break
            case 1:self.isSupportThroughWall = state == 0 ? false:true
                break
            case 2:self.isSupportOverspeed = state == 0 ? false:true
                break
            default:
                break
            }
        }
    }
}

@objc public class ZycxHeadphoneFunctionModel_customEqModel:NSObject {
    @objc public private(set) var scopeCount = 6                                    //增益范围
    @objc public private(set) var accuracyCount = 0                                 //分辨率(调节精度) 0代表0 100代表10
    @objc public private(set) var frequencyArray:[Int] = .init()                    //调节频段 HZ

    init(val:[UInt8]) {
        
        super.init()
        self.frequencyArray.removeAll()
        if val.count > 2 {
            self.scopeCount = Int(val[0])
            self.accuracyCount = (Int(val[1]) << 8 | Int(val[2]))
            let arrayCount = Int(val[3])
            let arrayIndex = 4
            if arrayCount * 2 + arrayIndex == val.count {
                for i in 0..<arrayCount {
                    let value = (Int(val[arrayIndex+i*2]) << 8 | Int(val[arrayIndex+i*2+1]))
                    self.frequencyArray.append(value)
                }
            }else{
                print("ZycxHeadphoneFunctionModel_customEqModel 频段数据解析异常")
                ZywlSDKLog.writeStringToSDKLog(string: "ZycxHeadphoneFunctionModel_customEqModel 频段数据解析异常")
            }
        }else{
            print("ZycxHeadphoneFunctionModel_customEqModel 数据解析异常")
            ZywlSDKLog.writeStringToSDKLog(string: "ZycxHeadphoneFunctionModel_customEqModel 数据解析异常")
        }
    }
}
