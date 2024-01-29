//
//  ZyModel.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2022/5/7.
//

import Foundation
import CoreBluetooth
import UIKit

@objc public class ZyScanModel: NSObject {
    @objc public var name:String?
    @objc public var rssi:Int = 0
    @objc public var peripheral:CBPeripheral?
    @objc public var uuidString:String?
    @objc public var macString:String?
}

@objc public class ZyOwsL04DeviceInformationModel:NSObject {
    
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

@objc public class ZyOwsAlarmModel:NSObject {
    @objc public var type = 0                      //0普通闹钟，1喝水闹钟，2吃药闹钟，3.会议闹钟
    @objc public var isOpen = false                  //0关闭，1开启
    @objc public var hour = 0
    @objc public var minute = 0
    @objc public var repeatCount = 0                    //bit0～bit6，周一～周日 ，0关闭，1开启
}

@objc public class ZyOwsWeatherModel:NSObject {
    @objc public var type:Int = 0                   //0多云，1雾，2阴天，3雨，4雪，5晴，6沙尘暴，7霾
    @objc public var temperature = 0                //摄氏度
    @objc public var pmValue = 0                    //0～35优，35～75良，75～115轻度污染，大于115严重污染
    @objc public var maxTemp = 0                    //最高温
    @objc public var minTemp = 0                    //最低温
}
