//
//  AndXuCommandModule.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2021/7/5.
//

import UIKit
import CoreBluetooth

@objc public enum ZyError : Int {
    case none
    case disconnected
    case invalidCharacteristic
    case invalidLength
    case invalidState
    case notSupport
    case noResponse
    case noMoreData
    case fail
}

@objc public class ZyCommandModule: ZyBaseModule {
    
    @objc public static let shareInstance = ZyCommandModule()
    
    private var semaphoreCount = 1
    private var signalValue = 1
    private var commandSemaphore = DispatchSemaphore(value: 1)
    private var commandListArray:Array<Data> = .init()
    private var isCommandSendState = false
    private var lastSendData:Data?
    private var commandDetectionTimer:Timer?//检测发送的是否有命令回复的定时器
    private var commandDetectionCount = 0
    
    private var otaVersionInfo:[String:Any]?
    private var macString:String?
    
    
    private var receiveGetHeadphoneBattery:((Int,Int,ZyError) -> Void)?
    private var receiveGetBoxBattery:((Int,ZyError) -> Void)?
    private var receiveSetFindHeadphoneDevice:((ZyError) -> Void)?
    private var receiveGetMac:((String?,String?,ZyError) -> Void)?
    private var receiveGetFirmwareVersion:((String?,String?,ZyError) -> Void)?
    private var receiveGetCustomButton:((Int,Int,Int,ZyError) -> Void)?
    private var receiveSetCustomButton:((ZyError) -> Void)?
    private var receiveGetLowLatencyMode:((Int,ZyError) -> Void)?
    private var receiveSetLowLatencyMode:((ZyError) -> Void)?
    private var receiveGetInEarDetection:((Int,ZyError) -> Void)?
    private var receiveSetInEarDetection:((ZyError) -> Void)?
    private var receiveGetEqMode:((Int,ZyError) -> Void)?
    private var receiveSetEqMode:((ZyError) -> Void)?
    private var receiveGetAmbientSound:((Int,ZyError) -> Void)?
    private var receiveSetAmbientSound:((ZyError) -> Void)?
    private var receiveGetHeadsetWearingStatus:((Int,ZyError) -> Void)?
    private var receiveSetResetFactory:((ZyError) -> Void)?
    private var receiveGetDesktopMode:((Int,ZyError) -> Void)?
    private var receiveSetDesktopMode:((ZyError) -> Void)?
    private var receiveGetPanoramicSound:((Int,ZyError) -> Void)?
    private var receiveSetPanoramicSound:((ZyError) -> Void)?
    private var receiveGetLhdcMode:((Int,ZyError) -> Void)?
    private var receiveGetSpeedMode:((Int,ZyError) -> Void)?
    private var receiveSetSpeedMode:((ZyError) -> Void)?
    private var receiveGetResistanceWindNoise:((Int,ZyError) -> Void)?
    private var receiveSetResistanceWindNoise:((ZyError) -> Void)?
    private var receiveGetBassToneEnhancement:((Int,ZyError) -> Void)?
    private var receiveSetBassToneEnhancement:((ZyError) -> Void)?
    private var receiveGetLowFrequencyEnhancement:((Int,ZyError) -> Void)?
    private var receiveSetLowFrequencyEnhancement:((ZyError) -> Void)?
    private var receiveGetCoupletPattern:((Int,ZyError) -> Void)?
    private var receiveSetCoupletPattern:((ZyError) -> Void)?
    
    //OWS
    private var receiveGetOwsDeviceAllInformation:((ZyOwsL04DeviceInformationModel?,ZyError) -> Void)?
    private var receiveGetOwsBoxScreenSize:((Int,Int,ZyError) -> Void)?
    private var receiveGetOwsBleName:((String?,ZyError) -> Void)?
    private var receiveGetOwsMediaVoiceVolume:((Int,ZyError) -> Void)?
    private var receiveGetOwsScreenOutTimeLength:((Int,ZyError) -> Void)?
    private var receiveGetOwsLocalDialIndex:((Int,Int,ZyError) -> Void)?
    private var receiveGetOwsMessageRemind:((Bool,Bool,Bool,ZyError) -> Void)?
    private var receiveGetOwsGameMode:((Bool,ZyError) -> Void)?
    private var receiveGetOwsNoiseControlMode:((Int,ZyError) -> Void)?
    private var receiveGetOwsNoiseReductionMode:((Int,ZyError) -> Void)?
    private var receiveGetOwsShakeSongMode:((Bool,ZyError) -> Void)?
    private var receiveGetOwsSupportFunction:((Int,Int,ZyError) -> Void)?
    private var receiveGetOwsDeviceOriginalName:((String?,ZyError) -> Void)?
    private var receiveGetOwsAlarmArray:((_ modelArray:[ZyOwsAlarmModel],_ error:ZyError)->Void)?
    private var receiveSetOwsClearPairingRecord:((ZyError) -> Void)?
    private var receiveSetOwsResetFactory:((ZyError) -> Void)?
    private var receiveSetOwsTouchButtonFunction:((ZyError) -> Void)?
    private var receiveSetOwsAllTouchButtonReset:((ZyError) -> Void)?
    private var receiveSetOwsFindHeadphones:((ZyError) -> Void)?
    private var receiveSetOwsBleName:((ZyError) -> Void)?
    private var receiveSetOwsMediaVoiceVolume:((ZyError) -> Void)?
    private var receiveSetOwsScreenOutTimeLength:((ZyError) -> Void)?
    private var receiveSetOwsLocalDialIndex:((ZyError) -> Void)?
    private var receiveSetOwsMessageRemind:((ZyError) -> Void)?
    private var receiveSetOwsGameMode:((ZyError) -> Void)?
    private var receiveSetOwsNoiseControlMode:((ZyError) -> Void)?
    private var receiveSetOwsNoiseReductionMode:((ZyError) -> Void)?
    private var receiveSetOwsShakeSong:((ZyError) -> Void)?
    private var receiveSetOwsShakeSongMode:((ZyError) -> Void)?
    private var receiveSetOwsTime:((ZyError) -> Void)?
    private var receiveSetOwsLanguage:((ZyError) -> Void)?
    private var receiveSetOwsAlarmArray:((ZyError) -> Void)?
    private var receiveSetOwsOperationSong:((ZyError) -> Void)?
    private var receiveSetOwsWeather:((ZyError) -> Void)?
    private var receiveReportOwsMediaVoiceVolume:((Int,ZyError) -> Void)?
    private var receiveReportOwsBattery:((Int,Int,Int,ZyError) -> Void)?
    private var receiveGetOwsEqMode:((Bool,Int,ZyError) -> Void)?
    private var receiveSetOwsEqMode:((ZyError) -> Void)?
    private var receiveGetOwsCustomEq:((Int,[Int],ZyError) -> Void)?
    private var receiveSetOwsCustomEq:((ZyError) -> Void)?
    
    
    private var reportOwsModel:((ZyOwsL04DeviceInformationModel?) -> Void)?
    var currentReceiveCommandEndOver = false //当前接收命令状态是否结束   5s没有接收到回复数据默认结束，赋值true
    var sendFailState = false  //命令发送失败状态，true时在信号量需要发命令的地方return待发送的命令
    var owsModel:ZyOwsL04DeviceInformationModel? = nil //设备信息模型
    
    private override init() {
        super.init()
        
        ZyCrashHandler.setup { (stackTrace, completion) in
            
            printLog("CrashHandler",stackTrace);
            
            let date:NSDate = NSDate()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "YYYY/MM/dd hh:mm:ss SS"
            let strNowTime = timeFormatter.string(from: date as Date) as String
            let url:String = String.init(format: "========异常错误报告========\ntime:%@\n%@\n\n\n\n\n%@",strNowTime,stackTrace,ZySDKLog.showLog())
            
            let errorPath = NSHomeDirectory() + "/Documents/ZyCrashLog"
            let fileManager = FileManager.default
            let exit:Bool = fileManager.fileExists(atPath: errorPath)
            if exit == false {
                do{
                    //                创建指定位置上的文件夹
                    try fileManager.createDirectory(atPath: errorPath, withIntermediateDirectories: true, attributes: nil)
                    printLog("Succes to create folder")
                }
                catch{
                    printLog("Error to create folder")
                }
            }
            
            do{
                try url.write(toFile: String.init(format: "%@/%@.txt",errorPath,Date.init().conversionDateToString(DateFormat: "yyyy-MM-dd HH:mm:ss")), atomically: true, encoding: .utf8)
            }catch {
                printLog("崩溃信息写入失败")
            }
            
            completion();
        }
    }
    
    override func deviceReceivedData() {
        self.writeCharacteristic = super.writeCharacteristic
        self.receiveCharacteristic = super.receiveCharacteristic
        self.peripheral = super.peripheral
                
        ZyBleManager.shareInstance.PeripheralUpdateValue { (peripheral, characteristic, error) in
            
            let data = characteristic.value ?? Data.init()
            
            let val = data.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
            }
            
            if val.count <= 0 {
                printLog("characteristic数据为空")
                return
            }
            
            if characteristic == self.receiveCharacteristic {
                printLog("characteristic =",characteristic)
                if characteristic.value?.count ?? 0 > 20 {
                    let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: characteristic.value ?? Data.init(),isSend: true))
                    printLog("characteristic.value =",dataString)
                }
                //获取耳机电量
                if val[0] == 0xaa && val[1] == 0x02 {
                    if let block = self.receiveGetHeadphoneBattery {
                        self.parseGetHeadphoneBattery(val: val, success: block)
                    }
                }
                //获取充电仓电量
                if val[0] == 0xaa && val[1] == 0x27 {
                    if let block = self.receiveGetBoxBattery {
                        self.parseGetBoxBattery(val: val, success: block)
                    }
                }
                //设置查找耳机
                if val[0] == 0xaa && val[1] == 0x10 {
                    if let block = self.receiveSetFindHeadphoneDevice {
                        self.parseSetFindHeadphoneDevice(val: val, success: block)
                    }
                }
                //获取mac
                if val[0] == 0xaa && val[1] == 0x12 {
                    if let block = self.receiveGetMac {
                        self.privateGetMac(val: val, success: block)
                    }
                }
                //获取固件版本号
                if val[0] == 0xaa && val[1] == 0x19 {
                    if let block = self.receiveGetFirmwareVersion {
                        self.parseGetFirmwareVersion(val: val, success: block)
                    }
                }
                //获取自定义按键
                if val[0] == 0xaa && val[1] == 0x21 {
                    if let block = self.receiveGetCustomButton {
                        self.parseGetCustomButton(val: val, success: block)
                    }
                }
                //设置自定义按键
                if val[0] == 0xaa && val[1] == 0x22 {
                    if let block = self.receiveSetCustomButton {
                        self.parseSetCustomButton(val: val, success: block)
                    }
                }
                //获取低延迟模式
                if val[0] == 0xaa && val[1] == 0x23 {
                    if let block = self.receiveGetLowLatencyMode {
                        self.parseGetLowLatencyMode(val: val, success: block)
                    }
                }
                //设置低延迟模式
                if val[0] == 0xaa && val[1] == 0x24 {
                    if let block = self.receiveSetLowLatencyMode {
                        self.parseSetLowLatencyMode(val: val, success: block)
                    }
                }
                //获取入耳检测
                if val[0] == 0xaa && val[1] == 0x25 {
                    if let block = self.receiveGetInEarDetection {
                        self.parseGetInEarDetection(val: val, success: block)
                    }
                }
                //设置入耳检测
                if val[0] == 0xaa && val[1] == 0x26 {
                    if let block = self.receiveSetInEarDetection {
                        self.parseSetInEarDetection(val: val, success: block)
                    }
                }
                //获取EQ模式
                if val[0] == 0xaa && val[1] == 0x30 {
                    if let block = self.receiveGetEqMode {
                        self.parseGetEqMode(val: val, success: block)
                    }
                }
                //设置EQ模式
                if val[0] == 0xaa && val[1] == 0x31 {
                    if let block = self.receiveSetEqMode {
                        self.parseSetEqMode(val: val, success: block)
                    }
                }
                //获取环境音
                if val[0] == 0xaa && val[1] == 0x33 {
                    if let block = self.receiveGetAmbientSound {
                        self.parseGetAmbientSound(val: val, success: block)
                    }
                }
                //设置环境音
                if val[0] == 0xaa && val[1] == 0x34 {
                    if let block = self.receiveSetAmbientSound {
                        self.parseSetAmbientSound(val: val, success: block)
                    }
                }
                //获取耳机佩戴状态
                if val[0] == 0xaa && val[1] == 0x35 {
                    if let block = self.receiveGetHeadsetWearingStatus {
                        self.parseGetHeadsetWearingStatus(val: val, success: block)
                    }
                }
                //设置环境音
                if val[0] == 0xaa && val[1] == 0x37 {
                    if let block = self.receiveSetResetFactory {
                        self.parseSetResetFactory(val: val, success: block)
                    }
                }
                //获取桌面模式
                if val[0] == 0xaa && val[1] == 0x38 {
                    if let block = self.receiveGetDesktopMode {
                        self.parseGetDesktopMode(val: val, success: block)
                    }
                }
                //设置桌面模式
                if val[0] == 0xaa && val[1] == 0x39 {
                    if let block = self.receiveSetDesktopMode {
                        self.parseSetDesktopMode(val: val, success: block)
                    }
                }
                //获取全景声
                if val[0] == 0xaa && val[1] == 0x42 {
                    if let block = self.receiveGetPanoramicSound {
                        self.parseGetPanoramicSound(val: val, success: block)
                    }
                }
                //设置全景声
                if val[0] == 0xaa && val[1] == 0x43 {
                    if let block = self.receiveSetPanoramicSound {
                        self.parseSetPanoramicSound(val: val, success: block)
                    }
                }
                //获取全景声
                if val[0] == 0xaa && val[1] == 0x48 {
                    if let block = self.receiveGetLhdcMode {
                        self.parseGetLhdcMode(val: val, success: block)
                    }
                }
                //获取极速模式
                if val[0] == 0xaa && val[1] == 0x49 {
                    if let block = self.receiveGetSpeedMode {
                        self.parseGetSpeedMode(val: val, success: block)
                    }
                }
                //设置极速模式
                if val[0] == 0xaa && val[1] == 0x50 {
                    if let block = self.receiveSetSpeedMode {
                        self.parseSetSpeedMode(val: val, success: block)
                    }
                }
                //获取抗风噪模式
                if val[0] == 0xaa && val[1] == 0x51 {
                    if let block = self.receiveGetResistanceWindNoise {
                        self.parseGetResistanceWindNoise(val: val, success: block)
                    }
                }
                //设置抗风噪模式
                if val[0] == 0xaa && val[1] == 0x52 {
                    if let block = self.receiveSetResistanceWindNoise {
                        self.parseSetResistanceWindNoise(val: val, success: block)
                    }
                }
                //获取低音增强
                if val[0] == 0xaa && val[1] == 0x53 {
                    if let block = self.receiveGetBassToneEnhancement {
                        self.parseGetBassToneEnhancement(val: val, success: block)
                    }
                }
                //设置低音增强
                if val[0] == 0xaa && val[1] == 0x54 {
                    if let block = self.receiveSetBassToneEnhancement {
                        self.parseSetBassToneEnhancement(val: val, success: block)
                    }
                }
                //获取低频增强
                if val[0] == 0xaa && val[1] == 0x55 {
                    if let block = self.receiveGetLowFrequencyEnhancement {
                        self.parseGetLowFrequencyEnhancement(val: val, success: block)
                    }
                }
                //设置低频增强
                if val[0] == 0xaa && val[1] == 0x56 {
                    if let block = self.receiveSetLowFrequencyEnhancement {
                        self.parseSetLowFrequencyEnhancement(val: val, success: block)
                    }
                }
                //获取对联模式
                if val[0] == 0xaa && val[1] == 0x57 {
                    if let block = self.receiveGetCoupletPattern {
                        self.parseGetCoupletPattern(val: val, success: block)
                    }
                }
                //设置对联模式
                if val[0] == 0xaa && val[1] == 0x58 {
                    if let block = self.receiveSetCoupletPattern {
                        self.parseSetCoupletPattern(val: val, success: block)
                    }
                }
                
                // MARK: - OWS val[0],val[1]固定 a8 03 ，val[4]:CommandId，val[5]:key，val[6]:0手机下发,1耳机上报,2耳机响应Response
                if val[0] == 0xA8 && val[1] == 0x03 && val[6] == 0x02 {
                    
                    let dealVal:[UInt8] = Array(val[8..<val.count-1])
                    let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: Data.init(bytes: dealVal, count: dealVal.count),isSend: true))
                    printLog("characteristic.value =",dataString)
                    
                    //获取设备所有信息
                    if val[4] == 0x01 && val[5] == 0x01 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsDeviceAllInformation {
                                self.parseGetOwsDeviceAllInformation(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsDeviceAllInformation {
                                block(nil,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsDeviceAllInformation长度校验出错"))
                        }
                    }
                    
                    //获取仓屏幕大小
                    if val[4] == 0x01 && val[5] == 0x02 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsBoxScreenSize {
                                self.parseGetOwsBoxScreenSize(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsBoxScreenSize {
                                block(0,0,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsBoxScreenSize长度校验出错"))
                        }
                    }
                    
                    //获取设备蓝牙名称
                    if val[4] == 0x01 && val[5] == 0x03 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsBleName {
                                self.parseGetOwsBleName(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsBleName {
                                block(nil,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsBleName长度校验出错"))
                        }
                    }
                    //获取媒体音量
                    if val[4] == 0x01 && val[5] == 0x04 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsMediaVoiceVolume {
                                self.parseGetOwsMediaVoiceVolume(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsMediaVoiceVolume {
                                block(0,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsMediaVoiceVolume长度校验出错"))
                        }
                    }
                    //获取熄屏时长
                    if val[4] == 0x01 && val[5] == 0x05 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsScreenOutTimeLength {
                                self.parseGetOwsScreenOutTimeLength(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsScreenOutTimeLength {
                                block(0,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsScreenOutTimeLength长度校验出错"))
                        }
                    }
                    //获取本地表盘索引
                    if val[4] == 0x01 && val[5] == 0x06 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsLocalDialIndex {
                                self.parseGetOwsLocalDialIndex(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsLocalDialIndex {
                                block(0,0,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsLocalDialIndex长度校验出错"))
                        }
                    }
                    //获取本地表盘索引
                    if val[4] == 0x01 && val[5] == 0x07 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsMessageRemind {
                                self.parseGetOwsMessageRemind(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsMessageRemind {
                                block(false,false,false,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "OwsMessageRemind长度校验出错"))
                        }
                    }
                    //获取游戏模式开关
                    if val[4] == 0x01 && val[5] == 0x08 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsGameMode {
                                self.parseGetOwsGameMode(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsGameMode {
                                block(false,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "OwsGameMode长度校验出错"))
                        }
                    }
                    //获取降噪模式
                    if val[4] == 0x01 && val[5] == 0x09 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsNoiseControlMode {
                                self.parseGetOwsNoiseControlMode(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsNoiseControlMode {
                                block(0,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsNoiseControlMode长度校验出错"))
                        }
                    }
                    
                    //获取当前噪声环境
                    if val[4] == 0x01 && val[5] == 0x0a {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsNoiseReductionMode {
                                self.parseGetOwsNoiseReductionMode(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsNoiseReductionMode {
                                block(0,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsNoiseReductionMode长度校验出错"))
                        }
                    }
                    
                    //获取摇一摇切歌开关
                    if val[4] == 0x01 && val[5] == 0x0b {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsShakeSongMode {
                                self.parseGetOwsShakeSongMode(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsShakeSongMode {
                                block(false,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsShakeSongMode长度校验出错"))
                        }
                    }
                    
                    //获取设备支持功能
                    if val[4] == 0x01 && val[5] == 0x0c {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsSupportFunction {
                                self.parseGetOwsSupportFunction(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsSupportFunction {
                                block(0,0,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsSupportFunction长度校验出错"))
                        }
                    }
                    
                    //获取设备出货的配对名(原始名称)
                    if val[4] == 0x01 && val[5] == 0x0d {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsDeviceOriginalName {
                                self.parseGetOwsDeviceOriginalName(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsDeviceOriginalName {
                                block(nil,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsDeviceOriginalName长度校验出错"))
                        }
                    }
                    
                    //获取闹钟
                    if val[4] == 0x01 && val[5] == 0x0e {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsAlarmArray {
                                self.parseGetOwsAlarmArray(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsAlarmArray {
                                block([],.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsAlarmArray长度校验出错"))
                        }
                    }
                    
                    //清除耳机配对记录
                    if val[4] == 0x02 && val[5] == 0x01 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsClearPairingRecord {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsClearPairingRecord {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsClearPairingRecord长度校验出错"))
                        }
                    }
                    
                    //设置回复出厂设置
                    if val[4] == 0x02 && val[5] == 0x02 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsResetFactory {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsResetFactory {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsResetFactory长度校验出错"))
                        }
                    }
                    
                    //设置[播放]按键功能
                    if val[4] == 0x02 && val[5] == 0x03{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsTouchButtonFunction {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsTouchButtonFunction {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsTouchButtonFunction长度校验出错"))
                        }
                    }
                    
                    //将所有按键恢复默认配置
                    if val[4] == 0x02 && val[5] == 0x04{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsAllTouchButtonReset {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsAllTouchButtonReset {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsAllTouchButtonReset长度校验出错"))
                        }
                    }
                    
                    //寻找耳机
                    if val[4] == 0x02 && val[5] == 0x05{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsFindHeadphones {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsFindHeadphones {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsFindHeadphones长度校验出错"))
                        }
                    }
                    
                    //修改蓝牙名称
                    if val[4] == 0x02 && val[5] == 0x06{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsBleName {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsBleName {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsBleName长度校验出错"))
                        }
                    }
                    
                    //设置耳机媒体音量
                    if val[4] == 0x02 && val[5] == 0x07{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsMediaVoiceVolume {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsMediaVoiceVolume {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsMediaVoiceVolume长度校验出错"))
                        }
                    }
                    
                    //设置熄屏时长
                    if val[4] == 0x02 && val[5] == 0x08{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsScreenOutTimeLength {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsScreenOutTimeLength {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsScreenOutTimeLength长度校验出错"))
                        }
                    }
                    
                    //设置本地表盘
                    if val[4] == 0x02 && val[5] == 0x09{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsLocalDialIndex {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsLocalDialIndex {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsLocalDialIndex长度校验出错"))
                        }
                    }
                    
                    //设置消息提醒开关
                    if val[4] == 0x02 && val[5] == 0x0a{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsMessageRemind {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsMessageRemind {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsMessageRemind长度校验出错"))
                        }
                    }
                    
                    //设置游戏模式开关
                    if val[4] == 0x02 && val[5] == 0x0b{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsGameMode {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsGameMode {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsGameMode长度校验出错"))
                        }
                    }
                    
                    //设置降噪控制
                    if val[4] == 0x02 && val[5] == 0x0c{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsNoiseControlMode {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsNoiseControlMode {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsNoiseControlMode长度校验出错"))
                        }
                    }

                    //设置降噪控制
                    if val[4] == 0x02 && val[5] == 0x0d{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsNoiseReductionMode {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsNoiseReductionMode {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsNoiseReductionMode长度校验出错"))
                        }
                    }
                    
                    //摇一摇切歌
                    if val[4] == 0x02 && val[5] == 0x0e{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsShakeSong {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsShakeSong {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsShakeSong长度校验出错"))
                        }
                    }
                    
                    //摇一摇切歌开关
                    if val[4] == 0x02 && val[5] == 0x0f{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsShakeSongMode {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsShakeSongMode {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsShakeSong长度校验出错"))
                        }
                    }
                    
                    //设置当前时间
                    if val[4] == 0x02 && val[5] == 0x10{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsTime {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsTime {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsTime长度校验出错"))
                        }
                    }
                    
                    //设置当前语言
                    if val[4] == 0x02 && val[5] == 0x11{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsLanguage {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsLanguage {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsLanguage长度校验出错"))
                        }
                    }
                    
                    //设置闹钟
                    if val[4] == 0x02 && val[5] == 0x13{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsAlarmArray {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsAlarmArray {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsAlarmArray长度校验出错"))
                        }
                    }
                    
                    //设置歌曲
                    if val[4] == 0x02 && val[5] == 0x14{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsOperationSong {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsOperationSong {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsOperationSong长度校验出错"))
                        }
                    }
                    
                    //设置天气
                    if val[4] == 0x02 && val[5] == 0x14{
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsWeather {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsWeather {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsWeather长度校验出错"))
                        }
                    }
                    
                    //上报耳机媒体音量
                    if val[4] == 0x03 && val[5] == 0x01 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveReportOwsMediaVoiceVolume {
                                self.parseGetOwsMediaVoiceVolume(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveReportOwsMediaVoiceVolume {
                                block(0,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "ReportOwsMediaVoiceVolume长度校验出错"))
                        }
                    }
                    
                    //上报电量
                    if val[4] == 0x03 && val[5] == 0x02 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveReportOwsBattery {
                                self.parseReportOwsBattery(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveReportOwsBattery {
                                block(0,0,0,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "ReportOwsMediaVoiceVolume长度校验出错"))
                        }
                    }
                    
                    //获取EQ
                    if val[4] == 0x04 && val[5] == 0x01 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsEqMode {
                                self.parseGetOwsEqMode(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsEqMode {
                                block(false,0,.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsEqMode长度校验出错"))
                        }
                    }
                    //设置EQ
                    if val[4] == 0x04 && val[5] == 0x02 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsEqMode {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsEqMode {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsEqMode长度校验出错"))
                        }
                    }
                    
                    //获取自定义EQ
                    if val[4] == 0x04 && val[5] == 0x03 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveGetOwsCustomEq {
                                self.parseGetOwsCustomEq(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveGetOwsCustomEq {
                                block(0,[],.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsCustomEq长度校验出错"))
                        }
                    }
                    
                    //设置自定义EQ
                    if val[4] == 0x04 && val[5] == 0x04 {
                        if self.checkOwsLength(val: val) {
                            if let block = self.receiveSetOwsCustomEq {
                                self.parseSetGeneralSettingsReply(val: dealVal, success: block)
                            }
                        }else{
                            
                            if let block = self.receiveSetOwsCustomEq {
                                block(.invalidLength)
                            }
                            //printLog("第\(#line)行" , "\(#function)")
                            self.signalCommandSemaphore()
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsCustomEq长度校验出错"))
                        }
                    }
                }
                
         
                
                
                
            }
        }
    }
    
    func checkLength(val:[UInt8]) -> Bool {
        var result = false
        //printLog("长度校验 = ",(Int(val[2]) | Int(val[3]) << 8 ))
        if (Int(val[2]) | Int(val[3]) << 8 ) == val.count {
            result = true
        }
        return result
    }
    
    func checkOwsLength(val:[UInt8]) -> Bool {
        var result = false
        
        if (Int(val[2]) << 8  | Int(val[3])) == val.count - 4 && val[7] == val.count - 9 {
            result = true
        }
        
        return result
    }
    
    func writeData(data:Data) {
        //此方法目前是升级在用 不做信号量等待
        if self.writeCharacteristic != nil {
            
            let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
            ZySDKLog.writeStringToSDKLog(string: "发送:"+dataString)
            printLog("send",dataString)
            self.peripheral?.writeValue(data, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
        }else{
            
            ZySDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
            printLog("写特征为空")
            
        }
    }
    
    @objc public func checkCurrentCommamdIsNeedWait() -> Bool {
        printLog("self.semaphoreCount =",self.semaphoreCount)
        printLog("self.commandListArray.count =",self.commandListArray.count)
        return self.commandListArray.count <= 0 ? false : true
    }
    
    func writeDataAndBackError(data:Data) -> ZyError {
        if self.peripheral?.state != .connected {
            
            return .disconnected
            
        }else{
            
            if self.writeCharacteristic != nil && self.peripheral != nil {

                self.commandListArray.append(data)
                if !self.isCommandSendState {
                    self.isCommandSendState = true
                    self.sendListArrayData()
                }
                
                return .none
            }else{
                
                ZySDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
                printLog("写特征为空")
                
                return .invalidCharacteristic
            }
        }
    }
    
    func sendListArrayData() {
        
        if self.commandListArray.count > 0 {
            //取出数组第一条data
            if let data = self.commandListArray.first {
                if self.peripheral?.state == .connected && self.writeCharacteristic != nil && self.peripheral != nil {
                    DispatchQueue.global().async {

                        self.semaphoreCount -= 1
                        let result = self.commandSemaphore.wait(timeout: DispatchTime.now()+5)
                        if result == .timedOut {
                            self.semaphoreCount += 1
                            let lastString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: self.lastSendData ?? .init(),isSend: true))
                            printLog("result = \(result) , self.lastSendData = \(lastString)")
                            ZySDKLog.writeStringToSDKLog(string: "发送超时的命令:"+lastString)
                            printLog("timedOut -> self.semaphoreCount =",self.semaphoreCount)
                        }
                        
                        let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
                        ZySDKLog.writeStringToSDKLog(string: "发送:"+dataString)
                                            
                        DispatchQueue.main.async {

                            printLog("send",dataString)
                            printLog("发送命令 -> self.semaphoreCount =",self.semaphoreCount)
                            self.peripheral?.writeValue(data, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
                            self.lastSendData = data
                            
                            //定时器计数重置
                            self.commandDetectionCount = 0
                            if self.commandDetectionTimer == nil {
                                //检测命令发送之后是否有回复，在deviceReceivedData方法内有数据则把此定时器销毁。如果没有回复，那么5s之后把信号量回复默认值
                                self.commandDetectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.commandDetectionTimerMethod), userInfo: nil, repeats: true)
                            }
                            
                            //移除发送的第一条data
                            if self.commandListArray.count > 0 {
                                self.commandListArray.remove(at: 0)
                                self.sendListArrayData()
                            }
                        }
                    }
                }
            }
        }else{
            self.isCommandSendState = false
        }
    }
        
    // MARK: - 检测命令定时器方法
    @objc public func commandDetectionTimerMethod() {
        //printLog("commandDetectionTimerMethod commandDetectionCount \(commandDetectionCount)")
        if self.commandDetectionCount >= 50 {
            //用信号量+1，只放一条命令过。如果用重置信号量会导致后续的命令全部怼出去，如果还有丢的命令也无法发现
            self.signalCommandSemaphore()
            //取消定时器
            self.commandDetectionTimerInvalid()
            //此次接收回复命令结束
        }
        self.commandDetectionCount += 1
    }

    // MARK: - 检测命令定时器销毁
    func commandDetectionTimerInvalid() {
        if self.commandDetectionTimer != nil {
            self.commandDetectionTimer?.invalidate()
            self.commandDetectionTimer = nil
            //printLog("commandDetectionTimerInvalid 定时器销毁 \(self.commandDetectionTimer)")
        }
    }
    
    // MARK: - 检测信号量+1
    func signalCommandSemaphore() {
        if self.semaphoreCount < 1 {
            self.signalValue = self.commandSemaphore.signal()
            self.semaphoreCount += 1
        }
        //ZySDKLog.writeStringToSDKLog(string: "signalCommandSemaphore 自定义值:\(self.semaphoreCount)")
        //ZySDKLog.writeStringToSDKLog(string: "signalCommandSemaphore signal值:\(self.signalValue)")
        //printLog("signalCommandSemaphore signalValue = \(self.signalValue)")
        printLog("signalCommandSemaphore -> self.semaphoreCount =",self.semaphoreCount)
    }
    
    // MARK: - 检测命令信号量重置
    func resetCommandSemaphore(showLog:Bool? = false) {
        self.otaVersionInfo = nil
        self.macString = nil
        //目前SDK内部重置会在重连、断开连接、关闭蓝牙三个地方调用
        let resetCount = 1-self.semaphoreCount
        if showLog == true {
            ZySDKLog.writeStringToSDKLog(string: "同步异常处理，取消后续命令发送")
        }else{
            ZySDKLog.writeStringToSDKLog(string: "重连、断开连接、关闭蓝牙，取消后续命令发送")
        }
        
        //ZySDKLog.writeStringToSDKLog(string: "resetCommandSemaphore 恢复之前值:\(self.semaphoreCount)")
        //ZySDKLog.writeStringToSDKLog(string: "resetCommandSemaphore signal值:\(self.signalValue)")
        printLog("resetCommandSemaphore resetCount->",resetCount)
        for _ in 0..<resetCount {
            self.signalCommandSemaphore()
        }
        //ZySDKLog.writeStringToSDKLog(string: "resetCommandSemaphore 恢复之后值:\(self.semaphoreCount)")
        //ZySDKLog.writeStringToSDKLog(string: "resetCommandSemaphore signal值:\(self.signalValue)")
        
        if self.semaphoreCount < 1 {
            for _ in 0..<1-self.semaphoreCount {
                self.signalCommandSemaphore()
            }
        }
        //重置之后网络请求的isRequesting置为false
        self.isCommandSendState = false
        self.lastSendData = nil
        self.commandListArray.removeAll()
    }
    
    // MARK: - 重置命令等待，待发命令全部移除不发送
    @objc public func resetWaitCommand() {
        self.sendFailState = true
        self.resetCommandSemaphore(showLog: true)
    }
    
    // MARK: - 获取耳机电量
    @objc public func getHeadphoneBattery(_ success:@escaping((_ leftHeadphone:Int,_ rightHeadphone:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x02]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetHeadphoneBattery = success
        }else{
            success(0,0,state)
        }
        /*
         App请求 Device响应 说明
         BA 02  AA 02 XX 00 XX 01   获取⽿机电量
         说明1：保证获取电量准确，APP在判断获取左右⽿的电量值有0时，需重新发⼀次获取电量指令，⽿机 不在线返回
         0。 读3次间隔2s，都是0就是不在线
         说明2：XX表示剩余电量百分⽐，取值范围0-100; 00: 当前左⽿电量，01 - 当前右⽿电量。
         */
    }
    
    private func parseGetHeadphoneBattery(val:[UInt8],success:@escaping((_ leftHeadphone:Int,_ rightHeadphone:Int,ZyError)->Void)) {

        if val.count >= 6 {
            let leftBattery = Int(val[2])
            let rightBattery = Int(val[4])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "leftBattery:%d,rightBattery:%d", leftBattery,rightBattery))
            success(leftBattery,rightBattery,.none)
        }else{
            success(0,0,.invalidLength)
        }
                
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取充电仓电量
    @objc public func getBoxBattery(_ success:@escaping((_ boxBattery:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x27]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetBoxBattery = success
        }else{
            success(0,state)
        }
        /*
         App请求 Device响应 说明
         BA 02  AA 02 XX 00 XX 01   获取⽿机电量
         说明1：保证获取电量准确，APP在判断获取左右⽿的电量值有0时，需重新发⼀次获取电量指令，⽿机 不在线返回
         0。 读3次间隔2s，都是0就是不在线
         说明2：XX表示剩余电量百分⽐，取值范围0-100; 00: 当前左⽿电量，01 - 当前右⽿电量。
         */
    }
    
    private func parseGetBoxBattery(val:[UInt8],success:@escaping((_ value:Int,ZyError)->Void)) {

        if val.count >= 6 {
            let batteryValue = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "batteryValue:%d", batteryValue))
            success(batteryValue,.none)
        }else{
            success(0,.invalidLength)
        }
                
        self.signalCommandSemaphore()
    }
    
    // MARK: - 查找设备
    @objc public func setFindHeadphoneDevice(type:Int,isOpen:Bool,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x10,UInt8(type),UInt8(isOpen ? 1 : 0)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetFindHeadphoneDevice = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 10 00 01    AA 10 01/00 (01:成功 00:失败)   开始查找左⽿设备
         BA 10 01 01    AA 10 01/00 (01:成功 00:失败)   开始查找右⽿设备
         BA 10 00 00    AA 10 01/00 (01:成功 00:失败)   停⽌查找左⽿设备
         BA 10 01 00    AA 10 01/00 (01:成功 00:失败)   停⽌查找右⽿设备
         BA 10 02 01    AA 10 01/00 (01:成功 00:失败)   开始查找双⽿设备
         BA 10 02 00    AA 10 01/00 (01:成功 00:失败)   停⽌查找双⽿设备
         
         备注：双⽿查找切换成单⽿查找时，⼀定要先发送 双⽿停⽌
         */
    }
    
    private func parseSetFindHeadphoneDevice(val:[UInt8],success:@escaping((ZyError)->Void)) {

        if val.count >= 3 {
            let state = Int(val[2])
            if state == 1 {
                success(.none)
            }else{
                success(.fail)
            }
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d", state))
        }else{
            success(.invalidLength)
        }
                
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取mac
    @objc public func getMac(_ success:@escaping((_ leftMac:String?,_ rightMac:String?,ZyError)->Void)) {
        
        var val:[UInt8] = [0xBA,0x12]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetMac = success
        }else{
            success(nil,nil,state)
        }
        /*
         App请求 Device响应 说明
         BA 12  AA 12 AABBCCDDEEFF AABBCCDDEEFE XX  获取⽿机信息
         
         AABBCCDDEEFF:⽿机mac地址(⼩端)
         AABBCCDDEEFE:⽿机mac地址(⼩端)
         xx: 01-本机是右⽿ 00-本机是左⽿
         注：若单⽿模式下，⽆法获取配对另⼀只⽿机mac地址时，补填00:00:00:00:00:00
         */
    }
    
    private func privateGetMac(val:[UInt8],success:@escaping((_ leftMac:String?,_ rightMac:String?,ZyError)->Void)) {
        let state = String.init(format: "%02x", val[4])
        if val.count >= 14 {
            
            let leftArray = val[2...7]
            let rightArray = val[8...13]
            
            var leftString = ""
            var rightString = ""
            
            for i in 0..<leftArray.count {
                leftString += String.init(format: "%d", leftArray[i])
                if i != leftArray.count - 1 {
                    leftString += ":"
                }
                
                rightString += String.init(format: "%d", rightArray[i])
                if i != rightArray.count - 1 {
                    rightString += ":"
                }
            }
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "leftString:%@,rightString:%@", leftString,rightString))
            success(leftString,rightString,.none)
            
        }else{
            success(nil,nil,.invalidLength)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取固件版本号
    @objc public func getFirmwareVersion(_ success:@escaping((_ leftVersion:String?,_ rightVersion:String?,ZyError)->Void)) {
        
        var val:[UInt8] = [0xBA,0x19]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetFirmwareVersion = success
        }else{
            success(nil,nil,state)
        }
        /*
         App请求 Device响应 说明
         BA 19  AA 19 MASTER L_VER_H L_VER_L R_VER_H R_VER_L    获取⽿机版本号
         
         MASTER: 双⽿同时连接返回00(主机:左⽿)或者01(主机:右⽿)，单⽿连接返回02；若⽿机不区分左右⽿(如穿戴式
         ⽿机)则默认返回00
         L_VER_H, L_VER_L：左⽿版本号⾼低字节，举例1102, 表示版本号为1.1.2;
         R_VER_H, R_VER_L：右⽿版本号⾼低字节，举例1102, 表示版本号为1.1.2;
         1.双⽿连接时左右⽿版本号均需要保持⼀致且返回
         2.单⽿连接时候对应不存在的副机版本号返回为0x0000
         示例1:存在双⽿(如⼊⽿式⽿机)
         1.双⽿同时连接：
         AA190011021102 该返回说明:1.双⽿均连接 2.左⽿是主机 3.左右⽿版本号⼀致均返回
         2.单⽿(左⽿)连接
         AA190211020000 该返回说明:1.仅单⽿连接 2.左⽿版本号正常返回,右⽿返回0000
         示例2：不区分单双⽿(如穿戴式⽿机)
         AA190011021102 该返回说明:1.默认⽿机连接返回00 2.版本号保持⼀致全部返回
         */
    }
    
    private func parseGetFirmwareVersion(val:[UInt8],success:@escaping((_ leftVersion:String?,_ rightVersion:String?,ZyError)->Void)) {

        if val.count >= 7 {
            
            let type = val[2]
            let letftValue = val[3]
            let leftHightString = String.init(format: "%d", letftValue / 16)
            let leftLowString = String.init(format: "%d", letftValue % 16)
            let leftAlternateString = String.init(format: "%d", val[4])
            let leftVersion = String.init(format: "%@.%@.%@", leftHightString,leftLowString,leftAlternateString)
            
            let rightValue = val[5]
            let rightHightString = String.init(format: "%d", rightValue / 16)
            let rightLowString = String.init(format: "%d", rightValue % 16)
            let rightAlternateString = String.init(format: "%d", val[6])
            let rightVersion = String.init(format: "%@.%@.%@", rightHightString,rightLowString,rightAlternateString)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "leftVersion:%@,rightVersion:%@", leftVersion,rightVersion))
            success(leftVersion == "0.0.0" ? nil : leftVersion,rightVersion == "0.0.0" ? nil : rightVersion,.none)
            
        }else{
            success(nil,nil,.invalidLength)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取自定义按键
    @objc public func getCustomButton(handGestureId:Int,success:@escaping((_ handGestureId:Int,_ leftFuncId:Int,_ rightFuncId:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x21,UInt8(handGestureId)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetCustomButton = success
        }else{
            success(0,0,0,state)
        }
        /*
         ⾃定义功能：
         序号 功能
         0      ⽆功能
         1      播放/暂停
         2      上⼀曲
         3      下⼀曲
         4      激活语⾳助⼿
         5      普通模式/低延迟模式切换
         6      环境⾳
         7      全景声
         8      游戏⾳效
         9      急速模式
         10     灯效切换
         11     增⼤⾳量
         12     降低⾳量
         13     低⾳增强
         
         ⼿势：
         序号 功能
         0  双击
         1  三击
         2  ⻓按
         3  单击
         
         App请求 Device响应 说明
         BA 21 EVENT    AA 21 EVENT L_FUNC_ID R_FUNC_ID     按键配置查询
         Event对应上⾯⼿势；
         L_FUNC_ID/R_FUNC_ID对应上⾯功能；
         */
    }
    
    private func parseGetCustomButton(val:[UInt8],success:@escaping((_ handGestureId:Int,_ leftFuncId:Int,_ rightFuncId:Int,ZyError)->Void)) {
        if val.count >= 5 {
            let handGestureId = Int(val[2])
            let leftFuncId = Int(val[3])
            let rightFuncId = Int(val[4])
            success(handGestureId,leftFuncId,rightFuncId,.none)
        }else{
            success(0,0,0,.fail)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置自定义按键
    @objc public func setCustomButton(handGestureId:Int,leftFuncId:Int,rightFuncId:Int,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x22,UInt8(handGestureId),UInt8(leftFuncId),UInt8(rightFuncId)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetCustomButton = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 22 EVENT L_FUNC_ID R_FUNC_ID    AA 22 XX    按键配置设置
         
         XX: 01-成功 00-失败
         */
    }
    
    private func parseSetCustomButton(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = val[2]
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 0x01 {
                success(.none)
            }else{
                success(.fail)
            }
        }else{
            success(.fail)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 低延迟模式查询
    @objc public func getLowLatencyMode(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x23]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLowLatencyMode = success
        }else{
            success(0,state)
        }
        /*
         App请求 Device响应 说明
         BA 23 AA 23 XX 按键配置设置
         XX: 01-低延迟 00-普通模式
         */
    }
    
    private func parseGetLowLatencyMode(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            success(state,.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 低延迟模式设置
    @objc public func setLowLatencyMode(type:Int,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x24,UInt8(type)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLowLatencyMode = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 24 XX AA 24 YY 按键配置设置
         
         XX: 01-低延迟模式 00-普通模式
         YY: 01-成功 00-失败
         */
    }
    
    private func parseSetLowLatencyMode(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1 {
                success(.none)
            }else{
                success(.fail)
            }
            
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 入耳检测查询
    @objc public func getInEarDetection(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x25]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetInEarDetection = success
        }else{
            success(0,state)
        }
        /*
         App请求 Device响应 说明
         BA 25 AA 25 XX ⼊⽿检测开关查询
         
         XX: 01-成功 00-失败
         */
    }
    private func parseGetInEarDetection(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            success(state,.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 入耳检测设置
    @objc public func setInEarDetection(type:Int,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x26,UInt8(type)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetInEarDetection = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 26 XX   AA 26 YY    ⼊⽿检测开关设置
         XX: 01-⼊⽿检测开 00-⼊⽿检测关
         YY: 01-成功 00-失败
         */
    }
    
    private func parseSetInEarDetection(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1 {
                success(.none)
            }else{
                success(.fail)
            }
            
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取EQ类型
    @objc public func getEqMode(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x30]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetEqMode = success
        }else{
            success(0,state)
        }
        /*
         EQ类型(EQ_TYPE)：
         序号 功能
         0      默认 / 正常
         1      超重低⾳ / 电竞 / ⼈声模式
         2      影院⾳效 / 环绕空间 / 户外模式
         3      HIFI现场 / 重低⾳
         4      清澈⼈声
         5      DJ⾳效
         6      流⾏
         7      爵⼠
         8      古典
         9      ⾼⾳增强
         10     原声
         11     摇滚经典
         101    ⾃定义
         App请求 Device响应 说明
         BA 30  AA 30 EQ_TYPE   当前EQ类型查询
         EQ_TYPE对应上⾯EQ类型
         */
    }
    private func parseGetEqMode(val:[UInt8],success:@escaping((Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            success(state,.none)
            
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置EQ类型
    @objc public func setEqMode(type:Int,customEqValue:[Float],success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x31,UInt8(type)]
        let startFreq = 100
        for i in 0..<customEqValue.count {
            let freqValue = startFreq * (1 << i)
            let value = customEqValue[i]
            let gainValue = Int(value * 10) + 120
            let qValue = 10
            let filterValue = 1
            print("freqValue = \(freqValue),freqValue[UInt8] = \(UInt8((freqValue ) & 0xff)),\(UInt8((freqValue >> 8) & 0xff)),value = \(value),gainValue = \(gainValue),gainValue[UInt8] = \(UInt8((gainValue ) & 0xff)),\(UInt8((gainValue >> 8) & 0xff))")
            val.append(UInt8((freqValue ) & 0xff))
            val.append(UInt8((freqValue >> 8) & 0xff))
            val.append(UInt8((gainValue ) & 0xff))
            val.append(UInt8((gainValue >> 8) & 0xff))
            val.append(UInt8((qValue ) & 0xff))
            val.append(UInt8((qValue >> 8) & 0xff))
            val.append(UInt8((filterValue ) & 0xff))
            val.append(UInt8((filterValue >> 8) & 0xff))
        }
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetEqMode = success
        }else{
            success(state)
        }
        /*
         EQ参数设置
         typedef struct
         {
         Int16 freq; //20~20000 频点 ⽬前定义固定
         Int16 gain; //-120~120 0.1步进 ⽤户⾃定义
         Int16 Q_value; //3~300 0.1步进 固定10
         Int16 Filter; //固定1
         }CFG_Type_PEQ_Band;
         CFG_Type_PEQ_Band PEQ_Band[]; //最多⽀持14段
         
         App请求 Device响应 说明
         BA 31 EQ_TYPE PEQ_Band[]   AA 31 01/00(成功/失败   EQ设置
         BA 31 EQ_TYPE EQ_MODEL PEQ_Band[]  AA 31 01/00(成功/失败   ⽬前单独针对Storm1的默认12种EQ设置命令，其他所有情形请⽤上⾯第⼀条命令
         EQ_MODEL: 普通EQ:00 / ANC EQ:01
         PEQ_Band[]:对应每种⾳效下所有频点数据集，具体⻅下⾯示例。
         
         举例：
         设置⾃定义⾳效：
         频点为：100， 200， 400， 800， 1600， 3200， 6400， 12800
         增益为：-3.1， 2.5， 10， 0， -2.4， 0， -1， 0，
         Q值均为10
         滤波器类型为1，直通
         数据下发为：0xBA 0x31 0x65(EQ_TYPE)
          0x64, 0x00, 0x59( -3.1值=增益*10+120),0x00 0x0a, 0x00, 0x1,0x00,// 第⼀个频点数据
          0xC8, 0x00, 0x91,0x00 0x0a, 0x00, 0x1,0x00,// 第⼆个频点数据
          ...
          其他频点类似
         */
    }
    
    private func parseSetEqMode(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(.none)
            }else{
                success(.fail)
            }
            
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 环境音获取
    @objc public func getAmbientSound(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x33]
        let data = Data.init(bytes: &val, count: val.count)

        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetAmbientSound = success
        }else{
            success(0,state)
        }
        /*
         序号 功能
         0  正常模式/关闭降噪
         1  降噪模式
         2  通透模式
         备注: 1.MODEL_TYPE为0/2情形下，MODEL_LEVEL该值默认为FF;
          2.MODEL_TYPE为1情形下：101:通勤 102:室内 103:户外 104:⾃适应 105:轻度 106:深度 107:普通
         1-10为⾃定义;
          3.MODEL_TYPE为1情形下,若MODEL_LEVEL只有⼀个等级的降噪情形下，默认MODEL_LEVEL为FF
         
         App请求 Device响应 说明
         BA 33  AA 33 MODEL_TYPE MODEL_LEVEL    当前模式查询
         */
    }
    
    private func parseGetAmbientSound(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            success(state,.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 环境音设置
    @objc public func setAmbientSound(type:Int ,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x34,UInt8(type),0xFF]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetAmbientSound = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 34 MODEL_TYPE MODEL_LEVEL   AA 34 XX(01:成功 00:失败)   模式设置
         */
    }
    
    private func parseSetAmbientSound(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(.none)
            }else{
                success(.fail)
            }
            
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 耳机佩戴状态查询
    @objc public func getHeadsetWearingStatus(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x35]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetHeadsetWearingStatus = success
        }else{
            success(0,state)
        }
        /*
         App请求 Device响应 说明
         BA 35 AA 35 XX(01:成功 00:失败) ⽿机佩戴状态查询
         备注：app未主动查询时,⽿机需主动上报佩戴状态
         */
    }
    
    private func parseGetHeadsetWearingStatus(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(state,.none)
            }else{
                success(0,.fail)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置恢复出厂
    @objc public func setResetFactory(_ success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x37]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetResetFactory = success
        }else{
            success(state)
        }
        /*
         查询⽿机是否⽀持"恢复出⼚设置"功能
         App请求 Device响应 说明
         BA 36  AA 36 XX(01:⽀持 00:不⽀持)  ---
         设置"恢复出⼚设置"
         App请求 Device响应 说明
         BA 37  AA 37 XX(01:成功 00:失败)   ---
         */
    }
    
    private func parseSetResetFactory(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(.none)
            }else{
                success(.fail)
            }
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 桌面模式获取
    @objc public func getDesktopMode(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x38]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDesktopMode = success
        }else{
            success(0,state)
        }
        /*
         App请求 Device响应 说明
         BA 38  AA 38 XX(01:开启 00:关闭)   ---
         */
    }
    
    private func parseGetDesktopMode(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(state,.none)
            }else{
                success(0,.fail)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 桌面模式设置
    @objc public func setDesktopMode(type:Int ,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x39,UInt8(type)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDesktopMode = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 39 XX(01:开启 00:关闭)  AA 39 XX(01:成功 00:失败)   ---
         */
    }
    private func parseSetDesktopMode(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(.none)
            }else{
                success(.fail)
            }
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 全景声获取
    @objc public func getPanoramicSound(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x42]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetPanoramicSound = success
        }else{
            success(0,state)
        }
        /*
         全景声模式：
         SOUND_MODEL VALUE 说明
         正常模式/默认⾳效  00  ---
         ⾳乐模式   01  ---
         影院模式   02  ---
         游戏模式/游戏⾳效  03  ---
         
         App请求 Device响应 说明
         BA 42 AA 42 SOUND_MODEL(⻅上表格对应值) ---
         */
    }
    
    private func parseGetPanoramicSound(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            success(state,.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 全景声设置
    @objc public func setPanoramicSound(type:Int ,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x43,UInt8(type)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetPanoramicSound = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 43 SOUND_MODEL  AA 43 XX(01:成功 00:失败)   ---
         */
    }
    private func parseSetPanoramicSound(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(.none)
            }else{
                success(.fail)
            }
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - LHDC模式查询
    @objc public func getLhdcMode(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x48]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLhdcMode = success
        }else{
            success(0,state)
        }
        /*
         App请求 Device响应 说明
         BA 48  AA 48 XX    XX=0A表示⽀持LHDC功能，其他则表示不⽀持LHDC功能
         */
    }
    
    private func parseGetLhdcMode(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(state,.none)
            }else{
                success(0,.fail)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 极速模式获取
    @objc public func getSpeedMode(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x49]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetSpeedMode = success
        }else{
            success(0,state)
        }
        /*
         MODEL_STATE VALUE 说明
         极速模式开启     01  查询和设置均为该值
         极速模式关闭     00  查询和设置均为该值
         App请求 Device响应 说明
         BA 49  AA 49 XX    XX=01/00(01:开启 00:关闭)
         */
        
    }
    
    private func parseGetSpeedMode(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(state,.none)
            }else{
                success(0,.fail)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 桌面模式设置
    @objc public func setSpeedMode(type:Int ,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x49,UInt8(type)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSpeedMode = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 50 XX(01:开启 00:关闭) AA 50 YY(01:成功 00:失败) ---
         */
    }
    private func parseSetSpeedMode(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(.none)
            }else{
                success(.fail)
            }
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 抗风噪模式获取
    @objc public func getResistanceWindNoise(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x51]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetResistanceWindNoise = success
        }else{
            success(0,state)
        }
        /*
         MODEL_STATE VALUE 说明
         抗⻛噪开启 01 查询和设置均为该值
         抗⻛噪关闭 00 查询和设置均为该值
         
         App请求 Device响应 说明
         BA 51  AA 51 XX    XX=01/00(01:开启 00:关闭)
         */
    }
    
    private func parseGetResistanceWindNoise(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(state,.none)
            }else{
                success(0,.fail)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 抗风噪设置
    @objc public func setResistanceWindNoise(type:Int ,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x52,UInt8(type)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDesktopMode = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 34 MODEL_TYPE MODEL_LEVEL   AA 34 XX(01:成功 00:失败)   模式设置
         */
    }
    private func parseSetResistanceWindNoise(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(.none)
            }else{
                success(.fail)
            }
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 低音增强获取
    @objc public func getBassToneEnhancement(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x53]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetBassToneEnhancement = success
        }else{
            success(0,state)
        }
        /*
         MODEL_STATE VALUE 说明
         低⾳增强开启     01  查询和设置均为该值
         低⾳增强关闭     00  查询和设置均为该值
         
         App请求 Device响应 说明
         BA 53 AA 53 XX XX=01/00(01:开启 00:关闭)
         */
    }
    
    private func parseGetBassToneEnhancement(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(state,.none)
            }else{
                success(0,.fail)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 低音增强设置
    @objc public func setBassToneEnhancement(type:Int ,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x54,UInt8(type)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetBassToneEnhancement = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 54 XX(01:开启 00:关闭)  AA 54 YY(01:成功 00:失败)   ---
         */
    }
    private func parseSetBassToneEnhancement(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(.none)
            }else{
                success(.fail)
            }
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 低频增强获取
    @objc public func getLowFrequencyEnhancement(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x55]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLowFrequencyEnhancement = success
        }else{
            success(0,state)
        }
        /*
         MODEL_STATE VALUE 说明
         低频增强开启 01 查询和设置均为该值
         低频增强关闭 00 查询和设置均为该值
         
         App请求 Device响应 说明
         BA 55  AA 55 XX    XX=MODEL_STATE
         */
    }
    
    private func parseGetLowFrequencyEnhancement(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(state,.none)
            }else{
                success(0,.fail)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 低频增强设置
    @objc public func setLowFrequencyEnhancement(type:Int ,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x56,UInt8(type)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLowFrequencyEnhancement = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 56 XX   AA 56 YY    XX=MODEL_STATE YY=(01:成功 00:失败)
         */
    }
    private func parseSetLowFrequencyEnhancement(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(.none)
            }else{
                success(.fail)
            }
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 对联模式获取
    @objc public func getCoupletPattern(_ success:@escaping((_ type:Int,ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x57]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetCoupletPattern = success
        }else{
            success(0,state)
        }
    }
    
    private func parseGetCoupletPattern(val:[UInt8],success:@escaping((_ type:Int,ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(state,.none)
            }else{
                success(0,.fail)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 对联模式设置
    @objc public func setCoupletPattern(type:Int ,success:@escaping((ZyError)->Void)) {
        var val:[UInt8] = [0xBA,0x58,UInt8(type)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDesktopMode = success
        }else{
            success(state)
        }
        /*
         App请求 Device响应 说明
         BA 34 MODEL_TYPE MODEL_LEVEL   AA 34 XX(01:成功 00:失败)   模式设置
         */
    }
    private func parseSetCoupletPattern(val:[UInt8],success:@escaping((ZyError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            if state == 1{
                success(.none)
            }else{
                success(.fail)
            }
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    
    
    // MARK: - OWS设备
    /*
     SOF        Gaia        Length      CommandID       Key     PDUtype     Payloadsize     Payload     crc
     1byte      1byte       2byte       1byte           1byte   1byte       1byte           Nbyte       1byte
     
     ⚫ SOF:start of frame,协议头，固定为 0xA8
     ⚫ Gaia Version 固定为 0x03
     ⚫ Length 大端格式 如：长度为30传入0x001e
     APP→DEV:
     Length = CommandID 至 crc 的总长度
     SPP 指令必须要补齐至少 7 个字节,不足补 0x00
     DEV→APP:
     Length = CommandID 至 crc 的总长度
     ⚫ CommandID 为功能主命令
     ⚫ Key为功能副命令
     ⚫ PDU Type
     0x00 手机下发的命令
     0x01 耳机上报给 APP 的 Notify 信息
     0x02 耳机针对 APP 下发指令的 Response
     ⚫ Payload size
     Payload 的长度
     ⚫ Payload 数据内容
     ⚫ CRC-8/MAXIM 参数模型： x8+x5+x4+1
     
     CommandID              Key (sub cmd)
     读取设备信息0x01         0x01            获取设备所有信息
                            0x02            获取仓的屏幕大小
                            0x03            获取设备蓝牙名称
                            0x04            获取耳机媒体音量
                            0x05            获取仓的熄屏时长
                            0x06            获取本地表盘索引
                            0x07            获取消息提醒开关
                            0x08            获取游戏模式，摇一摇切歌开关
                            0x09            获取噪声模式
                            0x0a            获取当前噪声环境
     
     功能设置0x02             0x01           清除耳机的配对记录
                            0x02            恢复出厂设置
                            0x03            设置[播放]按键功能
                            0x04            将所有按键恢复默认配置
                            0x05            寻找耳机
                            0x06            修改蓝牙名称
                            0x07            设置耳机媒体音量
                            0x08            设置仓的熄屏时长
                            0x09            设置本地表盘序号
                            0x0a            设置消息提醒开关
                            0x0b            设置游戏模式，摇一摇切歌开关
                            0x0c            设置噪声模式
                            0x0d            设置噪声环境
     
     状态上报0x03             0x01           上报耳机媒体音量
                            0x02            上报耳机电量
     
     eq设置0x04              0x01            获取耳机 EQ 使能状态
                            0x02            设置耳机 EQ 模式
                            0x03            获取自定义 EQ
                            0x04            设置自定义 EQ
     文件传输 0x05
     */
    func owsCrc8Data(val:[UInt8]) -> Data {
        let crc8 = self.CRC8(val: val)
        var newVal = Array(val)
        newVal.append(crc8)
        let data = Data.init(bytes: newVal, count: newVal.count)
        return data
    }
    // MARK: - 获取设备所有信息
    /*
     方向        SOF     Gaia     Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV    0xA8    0x03      0x0006    0x01        0x01    0x00        0x01         0x00         1byte
     DEV→APP    0xA8    0x03      0x002e    0x01        0x01    0x02        0x29                      1byte
     
     其中响应数据域 Payload：
     Byte1: 音量 0x00~0x0a(0~10)
     Byte2: 噪声控制（0x00 轻度降噪，0x01 中度降噪，0x02 重度降噪，0x03 关闭降噪，0x04 通透模式）
     Byte3: 降噪环境（0x00 室内，0x01 室外，0x02 交通）
     Byte4: 低延时模式（0x00 关闭，0x01 开启）
     Byte5: EQ 功能使能状态, 0x00 为关闭,0x01 为打开
     Byte6：当前 EQ 模式：0x00 表示标准 EQ，0x01 表示摇滚, 0x02 表示流行,0x03
     表示古典, 0x04 表示乡村, 0x05 表示经典,0x11 用户自定义模式
     Byte7: [播放]单击 左耳 功能定义：
     0x00 表示：播放暂停,
     0x01 表示：上一曲,
     0x02 表示：下一曲,
     0x03 表示：接听来电
     0x04 表示：挂断来电
     0x05 表示：拒接来电,
     0x06 表示: 语音助手,
     Byte8: [播放]单击 右耳 功能定义：参照Byte6
     Byte9: [播放]双击 左耳 功能定义：参照Byte6
     Byte10: [播放]双击 右耳 功能定义：参照Byte6
     Byte11: [播放]三击 左耳 功能定义：参照Byte6
     Byte12: [播放]三击 右耳 功能定义：参照Byte6
     Byte13: [播放]长按 左耳 功能定义：参照Byte6
     Byte14: [播放]长按 右耳 功能定义：参照Byte6
     Byte15：表示左耳电量（0%~100%电量表示 0x00~0x64）；
     Byte16：表示右耳电量（0%~100%电量表示 0x00~0x64）；
     Byte17：表示耳机仓电量（0%~100%电量表示 0x00~0x64）；
     Byte18：是否在充电（0x00 未充电，0x01 充电中）；
     Byte19：游戏模式开关 0x00是开启，0x01是关闭；
     Byte20：摇一摇切歌开关 0x00是开启，0x01是关闭；
     Byte21~Byte26：软件版本号 V1.0.1；（字符串格式 6bytes）
     Byte27~Byte29：软件序列号 ab0101；（ 3bytes）
     Byte30~Byte41：蓝牙地址；（字符串格式 12bytes）
     
     */
    @objc public func getOwsDeviceAllInformation(_ success:@escaping((_ model:ZyOwsL04DeviceInformationModel?,ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x01,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsDeviceAllInformation = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetOwsDeviceAllInformation(val:[UInt8],success:@escaping((ZyOwsL04DeviceInformationModel?,ZyError)->Void)) {
        
        if val.count >= 44 {
            let model = ZyOwsL04DeviceInformationModel()
            model.voiceVolume = Int(val[0])
            model.noiseControl = Int(val[1])
            model.noiseReduction = Int(val[2])
            model.isOpenlowLatency = val[3] == 0 ? false : true
            model.isOpenEq = val[4] == 0 ? false : true
            model.eqType = Int(val[5])
            model.singleClickLeftFunctionId = Int(val[6])
            model.singleClickRightFunctionId = Int(val[7])
            model.doubleClickLeftFunctionId = Int(val[8])
            model.doubleClickRightFunctionId = Int(val[9])
            model.threeClickLeftFunctionId = Int(val[10])
            model.threeClickRightFunctionId = Int(val[11])
            model.longPressLeftFunctionId = Int(val[12])
            model.longPressRightFunctionId = Int(val[13])
            model.leftBattery = Int(val[14])
            model.rightBattery = Int(val[15])
            model.boxBattery = Int(val[16])
            model.isOpenRecharge = val[17] == 0 ? false : true
            model.isOpenPlayGameMode = val[18] == 0 ? true : false
            model.isOpenShakeSong = val[19] == 0 ? true : false
            let versionData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                let byte = bytes.baseAddress! + 20
                return Data.init(bytes: byte, count: 6)
            })
            if let versionString = String.init(data: versionData, encoding: .utf8) {
                model.softwareVersion = versionString
            }
            let softwareData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                let byte = bytes.baseAddress! + 26
                return Data.init(bytes: byte, count: 6)
            })
            if let serialString = String.init(data: softwareData, encoding: .utf8) {
                model.softwareSerial = serialString
            }
            let addressData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                let byte = bytes.baseAddress! + 32
                return Data.init(bytes: byte, count: 12)
            })
            if let addressString = String.init(data: addressData, encoding: .utf8) {
                model.bluetoothAddress = addressString
            }
            model.deviceType = Int(val[44])
            self.owsModel = model
            success(model,.none)
        }else{
            success(nil,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取仓屏幕大小
    /*
     方向         SOF    Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV    0xA8    0x03    0x0006    0x01          0x02    0x00        0x01        0x00        1byte
     DEV→APP    0xA8    0x03    0x0009    0x01          0x02    0x02        0x04                    1byte
     
     其中数据域 Payload：（大端格式）
       Byte1和Byte2 表示宽  如320  则0x01,0x40
       Byte3和Byte4 表示高  如240  则0x00,0xf0
     
     */
    @objc public func getOwsBoxScreenSize(_ success:@escaping((_ width:Int,_ height:Int,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x02,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsBoxScreenSize = success
        }else{
            success(0,0,state)
        }
    }
    
    func parseGetOwsBoxScreenSize(val:[UInt8],success:@escaping((_ width:Int,_ height:Int,_ error:ZyError)->Void)) {
        if val.count >= 4 {
            let width = (Int(val[0]) << 8 | Int(val[1]))
            let height = (Int(val[2]) << 8 | Int(val[3]))
            success(width,height,.none)
        }else{
            success(0,0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取设备蓝牙名称
    /*
     方向         SOF    Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV    0xA8    0x03    0x0006      0x01        0x03    0x00        0x01        0x00        1byte
     DEV→APP    0xA8    0x03                0x01        0x03    0x02                                1byte
     
     其中数据域 Payload：,最多 30 个字节
     */
    @objc public func getOwsBleName(_ success:@escaping((_ name:String?,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x03,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsBleName = success
        }else{
            success(nil,state)
        }
    }
    
    func parseGetOwsBleName(val:[UInt8],success:@escaping((_ name:String?,_ error:ZyError)->Void)) {
        let bleNameData = val.withUnsafeBufferPointer({ (bytes) -> Data in
            let byte = bytes.baseAddress!
            return Data.init(bytes: byte, count: val.count)
        })
        if let nameString = String.init(data: bleNameData, encoding: .utf8) {
            success(nameString,.none)
        }else{
            success(nil,.fail)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取耳机媒体音量
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x01         0x04    0x00        0x01          0x00       1byte
     DEV→APP     0xA8    0x03    0x0006    0x01         0x04    0x02        0x01                     1byte
     其中数据域 Payload：
     Byte1:Volume 变化范围 0x00~0x0a(0~10)
     */
    @objc public func getOwsMediaVoiceVolume(_ success:@escaping((_ value:Int,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x04,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsMediaVoiceVolume = success
        }else{
            success(0,state)
        }
    }
    
    func parseGetOwsMediaVoiceVolume(val:[UInt8],success:@escaping((_ value:Int,_ error:ZyError)->Void)) {
        if val.count >= 1 {
            let value = Int(val[0])
            self.owsModel?.voiceVolume = value
            success(value,.none)
            if let block = self.reportOwsModel {
                block(self.owsModel)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取熄屏时长
    /*
    方向          SOF    Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
    APP→DEV     0xA8    0x03    0x0006      0x01       0x05    0x00         0x01          0x00      1byte
    DEV→APP     0xA8    0x03    0x0006      0x01       0x05    0x02         0x01          0xRR      1byte
     其中数据域 Payload：
     Byte1:亮度值 0x05,0x0a,0x0f,0x14,0x19,0x1e
           解析后 5s，10s, 15s, 20s, 25s, 30s
    */
    @objc public func getOwsScreenOutTimeLength(_ success:@escaping((_ value:Int,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x05,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsScreenOutTimeLength = success
        }else{
            success(0,state)
        }
    }
    
    func parseGetOwsScreenOutTimeLength(val:[UInt8],success:@escaping((_ value:Int,_ error:ZyError)->Void)) {
        if val.count >= 1 {
            let value = Int(val[0])
            success(value,.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取本地表盘索引
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006     0x01        0x06    0x00        0x01           0x00       1byte
     DEV→APP     0xA8    0x03    0x0007     0x01        0x06    0x02        0x02                      1byte
     
     其中数据域 Payload：
     Byte1:本地表盘的总数量，如5个，则0x05
     Byte2:当前仓背景的索引序号，如第二个，则0x02
     */
    @objc public func getOwsLocalDialIndex(_ success:@escaping((_ index:Int,_ totalCount:Int,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x06,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsLocalDialIndex = success
        }else{
            success(0,0,state)
        }
    }
    
    func parseGetOwsLocalDialIndex(val:[UInt8],success:@escaping((_ index:Int,_ totalCount:Int,_ error:ZyError)->Void)) {
        if val.count >= 2 {
            let totalCount = Int(val[0])
            let index = Int(val[1])
            success(index,totalCount,.none)
        }else{
            success(0,0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取消息提醒开关
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x01         0x07    0x00        0x01           0x00       1byte
     DEV→APP     0xA8    0x03    0x0008    0x01         0x07    0x02        0x03                      1byte
     
     其中数据域 Payload：
     Byte1:来电提醒，0是关，1是开
     Byte2:短信提醒，0是关，1是开
     Byte3:其它app提醒，0是关，1是开
     */
    @objc public func getOwsMessageRemind(_ success:@escaping((_ isOpencall:Bool,_ isOpenSms:Bool,_ isOpenOther:Bool,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x07,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsMessageRemind = success
        }else{
            success(false,false,false,state)
        }
    }
    
    func parseGetOwsMessageRemind(val:[UInt8],success:@escaping((_ isOpencall:Bool,_ isOpenSms:Bool,_ isOpenOther:Bool,_ error:ZyError)->Void)) {
        if val.count >= 3 {
            let isOpencall = val[0] == 0 ? false:true
            let isOpenSms = val[1] == 0 ? false:true
            let isOpenOther = val[2] == 0 ? false:true
            success(isOpencall,isOpenSms,isOpenOther,.none)
        }else{
            success(false,false,false,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取游戏模式开关
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x01         0x08    0x00        0x01          0x00      1byte
     DEV→APP     0xA8    0x03    0x0006    0x01         0x08    0x02        0x01                    1byte
     
     其中数据域 Payload：
     Byte1:游戏模式开关，0x00关，0x01开
     */
    @objc public func getOwsGameMode(_ success:@escaping((_ isOpen:Bool,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x08,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsGameMode = success
        }else{
            success(false,state)
        }
    }
    
    func parseGetOwsGameMode(val:[UInt8],success:@escaping((_ isOpen:Bool,_ error:ZyError)->Void)) {
        if val.count >= 1 {
            let isOpen = val[0] == 0 ? false:true
            success(isOpen,.none)
            self.owsModel?.isOpenPlayGameMode = isOpen
            if let block = self.reportOwsModel {
                block(self.owsModel)
            }
        }else{
            success(false,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取降噪模式
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x01         0x09    0x00        0x01          0x00      1byte
     DEV→APP     0xA8    0x03    0x0006    0x01         0x09    0x02        0x01                    1byte
     
     其中数据域 Payload：
     Byte1: 噪声控制（0x00 轻度降噪，0x01 中度降噪，0x02 重度降噪，0x03 关闭降噪，0x04 通透模式，0xff 不支持）
     */
    @objc public func getOwsNoiseControlMode(_ success:@escaping((_ type:Int,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x09,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsNoiseControlMode = success
        }else{
            success(0,state)
        }
    }
    
    func parseGetOwsNoiseControlMode(val:[UInt8],success:@escaping((_ type:Int,_ error:ZyError)->Void)) {
        if val.count >= 1 {
            let type = Int(val[0])
            success(type,.none)
            self.owsModel?.noiseControl = type
            if let block = self.reportOwsModel {
                block(self.owsModel)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取噪声环境
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x01         0x0a    0x00        0x01          0x00      1byte
     DEV→APP     0xA8    0x03    0x0006    0x01         0x0a    0x02        0x01                    1byte
     
     其中数据域 Payload：
     Byte1: 噪声环境（0x00 室内，0x01 室外，0x02 交通，0xff 不支持）
     */
    @objc public func getOwsNoiseReductionMode(_ success:@escaping((_ type:Int,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x0a,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsNoiseReductionMode = success
        }else{
            success(0,state)
        }
    }
    
    func parseGetOwsNoiseReductionMode(val:[UInt8],success:@escaping((_ type:Int,_ error:ZyError)->Void)) {
        if val.count >= 1 {
            let type = Int(val[0])
            success(type,.none)
            self.owsModel?.noiseReduction = type
            if let block = self.reportOwsModel {
                block(self.owsModel)
            }
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取摇一摇切歌开关
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x01         0x0b    0x00        0x01          0x00      1byte
     DEV→APP     0xA8    0x03    0x0006    0x01         0x0b    0x02        0x01                    1byte
     
     其中数据域 Payload：
     Byte1:摇一摇开关，0x00关，0x01开
     */
    @objc public func getOwsShakeSongMode(_ success:@escaping((_ isOpen:Bool,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x0b,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsShakeSongMode = success
        }else{
            success(false,state)
        }
    }
    
    func parseGetOwsShakeSongMode(val:[UInt8],success:@escaping((_ isOpen:Bool,_ error:ZyError)->Void)) {
        if val.count >= 1 {
            let isOpen = val[0] == 0 ? false : true
            success(isOpen,.none)
            self.owsModel?.isOpenShakeSong = isOpen
            if let block = self.reportOwsModel {
                block(self.owsModel)
            }
        }else{
            success(false,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取设备支持功能
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x01         0x0c    0x00        0x01          0x00      1byte
     DEV→APP     0xA8    0x03    0x0007    0x01         0x0c    0x02        0x02                    1byte
     
     其中数据域 Payload：
     说明：按bit位表示  （0表示不支持  1表示支持）
     Byte1: bit0 是否支持音量调节
            bit1 是否支持音效模式(也就是本地预设eq)
            bit2 是否支持自定义eq
            bit3 是否支持降噪设置(环境设置+降噪模式)
            bit4 是否支持游戏模式
            bit5 是否支持摇一摇切歌
            bit6 是否支持修改蓝牙名称
            bit7 是否支持查找设备
     Byte2: bit0 是否支持与仓的交互
     */
    @objc public func getOwsSupportFunction(_ success:@escaping((_ functionCount1:Int,_ functionCount2:Int,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x0c,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsSupportFunction = success
        }else{
            success(0,0,state)
        }
    }
    
    func parseGetOwsSupportFunction(val:[UInt8],success:@escaping((_ functionCount1:Int,_ functionCount2:Int,_ error:ZyError)->Void)) {
        if val.count >= 2 {
            let functionCount1 = Int(val[0])
            let functionCount2 = Int(val[1])
            success(functionCount1,functionCount2,.none)
        }else{
            success(0,0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取设备出货的配对名(原始名称)
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x01         0x0d    0x00        0x01          0x00      1byte
     DEV→APP     0xA8    0x03              0x01         0x0d    0x02                                1byte
     
     其中数据域 Payload：,最多 30 个字节
     */
    @objc public func getOwsDeviceOriginalName(_ success:@escaping((_ name:String?,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x0d,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsDeviceOriginalName = success
        }else{
            success(nil,state)
        }
    }
    
    func parseGetOwsDeviceOriginalName(val:[UInt8],success:@escaping((_ name:String?,_ error:ZyError)->Void)) {
        let bleNameData = val.withUnsafeBufferPointer({ (bytes) -> Data in
            let byte = bytes.baseAddress!
            return Data.init(bytes: byte, count: val.count)
        })
        if let nameString = String.init(data: bleNameData, encoding: .utf8) {
            success(nameString,.none)
        }else{
            success(nil,.fail)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取闹钟
    /*
     方向         SOF     Gaia    Length      CommandID       Key     PDUtype    Payloadsize    Payload   crc
     APP→DEV     0xA8    0x03     0x0006        0x01         0x0e       0x00        0x01        0x00     1byte
     DEV→APP     0xA8    0x03                   0x01         0x0e       0x02                             1byte
     
     其中数据域 Payload:
     Byte1  闹钟数量
     备注（Byte2～Byte6为一个闹钟5个字节，如果有N组就是N*5）
     Byte2 闹钟类型 （0普通闹钟，1喝水闹钟，2吃药闹钟，3.会议闹钟）
     Byte3 闹钟开关  (0关闭，1开启)
     Byte4 小时
     Byte5 分钟
     Byte6 重复 （bit0～bit6，周一～周日 ，0关闭，1开启）
     */
    @objc public func getOwsAlarmArray(_ success:@escaping((_ modelArray:[ZyOwsAlarmModel],_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x0d,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsAlarmArray = success
        }else{
            success([],state)
        }
    }
    
    func parseGetOwsAlarmArray(val:[UInt8],success:@escaping((_ modelArray:[ZyOwsAlarmModel],_ error:ZyError)->Void)) {
        
        var alarmArray = [ZyOwsAlarmModel]()
        let alarmCount = Int(val[0])
        if val.count == alarmCount * 5 + 1 {
            for i in 0..<alarmCount {
                let model = ZyOwsAlarmModel.init()
                model.type = Int(val[i*5+1])
                model.isOpen = val[i*5+2] == 0 ? false : true
                model.hour = Int(val[i*5+3])
                model.minute = Int(val[i*5+4])
                model.repeatCount = Int(val[i*5+5])
            }
        }else{
            success([],.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 清除耳机的配对记录
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x01    0x00        0x01            0x00      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x01    0x02        0x01            0xRR      1byte
     
     0xRR = 0x00 代表指令执行成功,
     0xRR = 0x01 代表指令执行失败,
     0xRR = 0x02 crc校验失败,
     下面指令中0xRR同上
     */
    @objc public func setOwsClearPairingRecord(_ success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x01,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsClearPairingRecord = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 恢复出厂设置
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x02    0x00        0x01            0x00      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x02    0x02        0x01            0xRR      1byte
     
     0xRR = 0x00 代表指令执行成功,
     0xRR = 0x01 代表指令执行失败,
     0xRR = 0x02 crc校验失败,
     下面指令中0xRR同上
     */
    @objc public func setOwsResetFactory(_ success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x02,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsResetFactory = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置[播放]按键功能
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0008    0x02         0x03    0x00        0x03                      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x03    0x02        0x01            0xRR      1byte
     
     其中数据域 Payload：
     Byte1: 0x00 表示左耳，0x01 表示右耳
     Byte2: 0x00 表示：单击；
            0x01 表示：双击；
            0x02 表示：三击；
            0x03 表示：长按；
     Byte3: 0x00 表示：播放暂停,
            0x01 表示：上一曲,
            0x02 表示：下一曲,
            0x03 表示：接听来电
            0x04 表示：挂断来电
            0x05 表示：拒接来电,
            0x06 表示: 语音助手,
            0x07 表示: 音量+,
            0x08 表示: 音量-,
     */
    @objc public func setOwsTouchButtonFunction(handId:Int,touchId:Int,functionId:Int,_ success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x08,0x02,0x03,0x00,0x03,UInt8(handId),UInt8(touchId),UInt8(functionId)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsTouchButtonFunction = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 所有按键恢复默认配置
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x04    0x00        0x01            0x00      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x04    0x02        0x01            0xRR      1byte
     
     0xRR = 0x00 代表指令执行成功,
     0xRR = 0x01 代表指令执行失败,
     0xRR = 0x02 crc校验失败,
     下面指令中0xRR同上
     */
    @objc public func setOwsAllTouchButtonReset(_ success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x04,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsAllTouchButtonReset = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 寻找耳机
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x05    0x00        0x01                      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x05    0x02        0x01            0xRR      1byte
     
     其中数据域 Payload：
     Byte1：0x00 表示开始，0x01 表示结束
     */
    @objc public func setOwsFindHeadphones(isOpen:Bool,_ success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x05,0x00,0x01,UInt8(isOpen == true ? 0 : 1)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsFindHeadphones = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 修改蓝牙名
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03              0x02         0x06    0x00                                  1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x06    0x02        0x01            0xRR      1byte
     
     其中数据域 Payload：
     Byte1：0x00 表示开始，0x01 表示结束
     */
    @objc public func setOwsBleName(name:String,_ success:@escaping((_ error:ZyError)->Void)) {
        if let nameData = name.data(using: .utf8) {
            var val:[UInt8] = [0xA8,0x03,0x00,UInt8(nameData.count+6),0x02,0x06,0x00,UInt8(nameData.count)]
            let nameVal = nameData.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: nameData.count))
            }
            val.append(contentsOf: nameVal)
            let data = self.owsCrc8Data(val: val)
            
            let state = self.writeDataAndBackError(data: data)
            if state == .none {
                self.receiveSetOwsBleName = success
            }else{
                success(state)
            }
        }else{
            print("name.data(using: .utf8)获取失败")
            success(.fail)
        }
    }
    
    // MARK: - 设置耳机媒体音量
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x07    0x00        0x01                      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x07    0x02        0x01            0xRR      1byte
     
     其中数据域 Payload：
     Byte1:Volume 变化范围 0x00~0x10(0~16)
     */
    @objc public func setOwsMediaVoiceVolume(value:Int,_ success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x07,0x00,0x01,UInt8(value)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsMediaVoiceVolume = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置熄屏时长
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x08    0x00        0x01                      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x08    0x02        0x01            0xRR      1byte
     
     其中数据域 Payload：
     Byte1:亮度值 0x05,0x0a,0x0f,0x14,0x19,0x1e
           解析后 5s，10s, 15s, 20s, 25s, 30s
     */
    @objc public func setOwsScreenOutTimeLength(value:Int,_ success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x08,0x00,0x01,UInt8(value)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsScreenOutTimeLength = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置本地表盘序号
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x09    0x00        0x01                      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x09    0x02        0x01            0xRR      1byte
     
     其中数据域 Payload：
     Byte1:设置仓当前背景的索引序号，如第二个，则0x02
     */
    @objc public func setOwsLocalDialIndex(_ value:Int,_ success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x09,0x00,0x01,UInt8(value)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsLocalDialIndex = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置消息提醒开关
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0008    0x02         0x0a    0x00        0x03                      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x0a    0x02        0x01            0xRR      1byte
     
     其中数据域 Payload：
     Byte1:来电提醒，0是关，1是开
     Byte2:短信提醒，0是关，1是开
     Byte3:其它app提醒，0是关，1是开
     */
    @objc public func setOwsMessageRemind(isOpencall:Bool,isOpenSms:Bool,isOpenOther:Bool,success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x08,0x02,0x0a,0x00,0x03,UInt8(isOpencall ? 1 : 0),UInt8(isOpenSms ? 1 : 0),UInt8(isOpenOther ? 1 : 0)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsMessageRemind = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置游戏模式开关
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0008    0x02         0x0b    0x00        0x01                      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x0b    0x02        0x01            0xRR      1byte
     
     其中数据域 Payload：
     Byte1:0x00关闭，0x01开启
     */
    @objc public func setOwsGameMode(isOpen:Bool,success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x0b,0x00,0x01,UInt8(isOpen ? 1 : 0)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsGameMode = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置降噪模式
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x0c    0x00        0x01                    1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x0c    0x02        0x01          0xRR      1byte
     
     其中数据域 Payload：
     Byte1: 噪声控制（0x00 轻度降噪，0x01 中度降噪，0x02 重度降噪，0x03 关闭降噪，0x04 通透模式，0xff 不支持）
     */
    @objc public func setOwsNoiseControlMode(type:Int, success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x0c,0x00,0x01,UInt8(type)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsNoiseControlMode = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 获取噪声环境
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x0d    0x00        0x01                    1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x0d    0x02        0x01          0xRR      1byte
     
     其中数据域 Payload：
     Byte1: 噪声环境（0x00 室内，0x01 室外，0x02 交通，0xff 不支持）
     */
    @objc public func getOwsNoiseReductionMode(type:Int, success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x0d,0x00,0x01,UInt8(type)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsNoiseReductionMode = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 摇一摇切歌
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x0e    0x00        0x01          0x00      1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x0e    0x02        0x01          0xRR      1byte
     */
    @objc public func setOwsShakeSong(_ success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x0e,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsShakeSong = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置摇一摇切歌开关
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x0f    0x00        0x01                    1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x0f    0x02        0x01          0xRR      1byte
     
     其中数据域 Payload：
     Byte1:摇一摇开关，0x00关，0x01开
     */
    @objc public func setOwsShakeSongMode(isOpen:Bool, success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x0f,0x00,0x01,UInt8(isOpen ? 1 : 0)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsShakeSongMode = success
        }else{
            success(state)
        }
    }

    // MARK: - 设置(同步)当前时间
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x10    0x00        0x06                    1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x10    0x02        0x01          0xRR      1byte
     
     其中数据域 Payload：(举例2023年1月23日10点10分30秒)
     Byte1～Byte2: 0x07，0xe8
     Byte3:0x01
     Byte4:0x17
     Byte5:0x0a
     Byte6:0x0a
     Byte7:0x1e
     */
    @objc public func setOwsTime(time:Any? = nil,success:@escaping((ZyError) -> Void)) {
        
        var date = Date.init()
        
        if time is Date {
            
            date = time as! Date
            
        }else if time is String {
            
            let format = DateFormatter.init()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let timeArray = (time as! String).components(separatedBy: " ")
            if timeArray.count == 2 {
                
                date = format.date(from: time as! String) ?? .init()
                
            }else if timeArray.count == 3 {
                
                let newTime:String = timeArray[0] + timeArray[1]
                date = format.date(from: newTime) ?? .init()
                
            }else{
                
                
            }
        }
        
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x10,0x00,0x06,0x00,UInt8(year),UInt8(year >> 8),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsTime = success
        }else{
            success(state)
        }
        
    }
    
    // MARK: - 设置(同步)当前时间
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x11    0x00        0x01                    1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x11    0x02        0x01          0xRR      1byte
     
     其中数据域 Payload：
     Byte1
     英文 0x00
     中文简体 0x01
     中文繁体 0x02
     德语 0x03
     法语 0x04
     俄语 0x05
     西班牙语 0x06
     意大利语 0x07
     葡萄牙语 0x08
     阿拉伯语 0x09
     */
    @objc public func setOwsLanguage(type:Int,success:@escaping((ZyError) -> Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x11,0x00,0x01,UInt8(type)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsLanguage = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置闹钟
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03              0x02         0x13    0x00                                1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x13    0x02        0x01          0xRR      1byte
     
     其中数据域 Payload：
     Byte1 闹钟数量 （不超过12个）
     备注 如果闹钟数量设为0，表示删除所有闹钟 (0xa80300060213000100+crc)
     备注（Byte2～Byte6为一个闹钟5个字节，如果有N组就是N*5）
     备注 （Byte6 重复中，如果bit0～bit6全部为关闭则表示单次闹钟）
     Byte2 闹钟类型 （0普通闹钟，1喝水闹钟，2吃药闹钟，3.会议闹钟）
     Byte3 闹钟开关  (0关闭，1开启)
     Byte4 小时
     Byte5 分钟
     Byte6 重复 （bit0～bit6，周一～周日 ，0关闭，1开启）
     */
    @objc public func setOwsAlarmArray(modelArray:[ZyOwsAlarmModel],success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = .init()
        
        if modelArray.count > 0 {
            var modelVal:[UInt8] = .init()
            modelVal.append(UInt8(modelArray.count))
            for item in modelArray {
                modelVal.append(UInt8(item.type))
                modelVal.append(UInt8(item.isOpen ? 0x01 : 0x00))
                modelVal.append(UInt8(item.hour))
                modelVal.append(UInt8(item.minute))
                modelVal.append(UInt8(item.repeatCount))
            }
            val = [0xA8,0x03,0x00,UInt8(modelVal.count+6),0x02,0x06,0x00,UInt8(modelVal.count)]
        }else {
            val = [0xA8,0x03,0x00,0x06,0x02,0x13,0x00,0x01,0x00]
        }

        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsAlarmArray = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置(操作)歌曲
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03    0x0006    0x02         0x14    0x00        0x01                    1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x14    0x02        0x01          0xRR      1byte
     
     其中数据域 Payload：
     Byte1
     暂停 0
     播放 1
     上一曲 2
     下一曲 3
     */
    @objc public func setOwsOperationSong(type:Int,success:@escaping((ZyError) -> Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x02,0x14,0x00,0x01,UInt8(type)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsOperationSong = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置(同步)天气
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload     crc
     APP→DEV     0xA8    0x03              0x02         0x15    0x00                                1byte
     DEV→APP     0xA8    0x03    0x0006    0x02         0x15    0x02        0x01          0xRR      1byte
     
     其中数据域 Payload：
     Byte1 城市名称长度
     Byte2～ByteN 城市名称  （UTF8格式）
     ByteN+1 天气数量 （一般会设置7天）
     备注（ByteN+2～ByteN+6为一组天气5个字节，如果有N组就是N*5）
     备注 第一天为当天天气，后面的属于未来天气
     ByteN+2 天气状态（0多云，1雾，2阴天，3雨，4雪，5晴，6沙尘暴，7霾）
     ByteN+3 实时温度值 （摄氏度）
     ByteN+4 PM2.5  （0～35优，35～75良，75～115轻度污染，大于115严重污染）
     ByteN+5 最低温
     ByteN+6 最高温
     */
    @objc public func setOwsWeather(city:String? = nil,modelArray:[ZyOwsWeatherModel],success:@escaping((ZyError) -> Void)) {
        
        var modelVal:[UInt8] = .init()
        
        if let city = city {
            if let cityData = city.data(using: .utf8) {
                modelVal.append(UInt8(cityData.count))
                let cityVal = cityData.withUnsafeBytes { (byte) -> [UInt8] in
                    let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: cityData.count))
                }
                modelVal.append(contentsOf: cityVal)
            }
        }else{
            if let cityData = " ".data(using: .utf8) {
                modelVal.append(UInt8(cityData.count))
                let cityVal = cityData.withUnsafeBytes { (byte) -> [UInt8] in
                    let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: cityData.count))
                }
                modelVal.append(contentsOf: cityVal)
            }
        }
        modelVal.append(UInt8(modelArray.count))
        for item in modelArray {
            modelVal.append(UInt8(item.type))
            modelVal.append(UInt8(item.temperature))
            modelVal.append(UInt8(item.pmValue))
            modelVal.append(UInt8(item.minTemp))
            modelVal.append(UInt8(item.maxTemp))
        }
        
        
        var val:[UInt8] = [0xA8,0x03,0x00,UInt8(modelVal.count + 6),0x02,0x15,0x00,UInt8(modelVal.count)]
        val.append(contentsOf: modelVal)
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsWeather = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 设置的通用回复
    func parseSetGeneralSettingsReply(val:[UInt8],success:@escaping((_ error:ZyError)->Void)) {
        if val.count >= 1 {
            let state = val[0]
            if state == 0 {
                success(.none)
            }else{
                success(.fail)
            }
        }else{
            success(.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 上报耳机媒体音量
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     DEV→APP     0xA8    0x03    0x0006    0x03         0x01    0x02        0x01                     1byte
     其中数据域 Payload：
     Byte1:Volume 变化范围 0x00~0x0a(0~10)
     */
    @objc public func reportOwsMediaVoiceVolume(success:@escaping((_ volume:Int,_ error:ZyError) -> Void)) {
        self.receiveReportOwsMediaVoiceVolume = success
    }
    
    // MARK: - 上报电量
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     DEV→APP     0xA8    0x03    0x0008    0x03         0x02    0x02        0x03                     1byte
     其中数据域 Payload：
     Byte1：表示左耳电量（0%~100%电量表示 0x00~0x64）
     Byte2：表示右耳电量（0%~100%电量表示 0x00~0x64）
     Byte3：表示耳机仓电量（0%~100%电量表示 0x00~0x64）
     */
    @objc public func reportOwsBattery(success:@escaping((_ leftBattery:Int,_ rightBattery:Int,_ boxBattery:Int,_ error:ZyError) -> Void)) {
        self.receiveReportOwsBattery = success
    }
    
    func parseReportOwsBattery(val:[UInt8],success:@escaping((_ leftBattery:Int,_ rightBattery:Int,_ boxBattery:Int,_ error:ZyError) -> Void)) {
        if val.count >= 3 {
            let leftBattery = Int(val[0])
            let rightBattery = Int(val[0])
            let boxBattery = Int(val[0])
            success(leftBattery,rightBattery,boxBattery,.none)
            
            self.owsModel?.leftBattery = leftBattery
            self.owsModel?.rightBattery = rightBattery
            self.owsModel?.boxBattery = boxBattery
            if let block = self.reportOwsModel {
                block(self.owsModel)
            }
        }else{
            success(0,0,0,.invalidLength)
        }
    }
    
    @objc public func reportOwsModel(success:@escaping((_ owsModel:ZyOwsL04DeviceInformationModel?) -> Void)) {
        self.reportOwsModel = success
    }
    
    // MARK: - 获取耳机eq状态
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x04         0x01    0x00        0x01          0x00       1byte
     DEV→APP     0xA8    0x03    0x0007    0x04         0x01    0x02        0x03                     1byte
     
     其中数据域 Payload：
     Byte1: 0x00 当前的 EQ 功能为关闭;
     0x01 当前 EQ 功能为打开
     Byte2: 当前耳机的预设 EQ 模式
     0x00 表示标准，
     0x01 表示摇滚,
      0x02 表示流行,
     0x03 表示爵士,
     0x04 表示乡村,
     0x05 表示经典,
     0x11 用户自定义模式
     */
    @objc public func getOwsEqMode(_ success:@escaping((_ isOpen:Bool,_ type:Int,_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x04,0x01,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsEqMode = success
        }else{
            success(false,0,state)
        }
    }
    
    func parseGetOwsEqMode(val:[UInt8],success:@escaping((_ isOpen:Bool,_ type:Int,_ error:ZyError)->Void)) {
        if val.count >= 2 {
            let isOpen = val[0] == 0 ? false : true
            let type = Int(val[1])
            success(isOpen,type,.none)
            self.owsModel?.isOpenEq = isOpen
            self.owsModel?.eqType = type
            if let block = self.reportOwsModel {
                block(self.owsModel)
            }
        }else{
            success(false,0,.invalidLength)
        }
    }
    
    // MARK: - 设置耳机eq模式
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x04         0x02    0x00        0x01                     1byte
     DEV→APP     0xA8    0x03    0x0006    0x04         0x02    0x02        0x03          0x00       1byte
     */
    @objc public func setOwsEqMode(isOpen:Bool,type:Int,success:@escaping((_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x07,0x04,0x02,0x00,0x02,UInt8(isOpen ? 1 : 0),UInt8(type)]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsEqMode = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 获取自定义EQ
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0006    0x04         0x03    0x00        0x01          0x00       1byte
     DEV→APP     0xA8    0x03    0x0010    0x04         0x03    0x02        0x0b                     1byte
     其中数据域 Payload：
     Byte1: 如果有用户自定义 EQ 模式 1 则填入 0x11，没有则填入0xff
     Byte2~Byte11:
     当前用户自定义 EQ 模式十个频点的值, 请将-12DB 到 12DB 量化到
     0~240(十进制)发送给 DEV, 比如 0DB 对应 60 。如果用户没有设置全部填    入0x00
     */
    @objc public func getOwsCustomEq(_ success:@escaping((_ type:Int,_ valueArray:[Int],_ error:ZyError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x04,0x03,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsCustomEq = success
        }else{
            success(0,[],state)
        }
    }
    
    func parseGetOwsCustomEq(val:[UInt8],success:@escaping((_ type:Int,_ valueArray:[Int],_ error:ZyError)->Void)) {
        if val.count >= 11 {
            let index = Int(val[0])
            var valueArray = Array<Int>()
            let newVal = Array(val[1..<11])
            valueArray = newVal.map({Int($0)})
            success(index,valueArray,.none)
        }else{
            success(0,[],.invalidLength)
        }
    }
    
    // MARK: - 设置自定义EQ
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0010    0x04         0x04    0x00        0x0b                     1byte
     DEV→APP     0xA8    0x03    0x0006    0x04         0x04    0x02        0x01                     1byte
     
     其中数据域 Payload：
     Byte1: 0x11 用户自定义 EQ 模式 ID
     Byte2~Byte11:
     当前用户自定义 EQ 模式十个频点的值, 请将-12DB 到 12DB 量化到
     0~240(十进制)发送给 DEV, 比如 0DB 对应 60
     */
    @objc public func setOwsCustomEq(valueArray:[Float],success:@escaping((_ error:ZyError)->Void)) {
        
        let intArray = valueArray.map({Int($0 * 10) + 120})
        var newArray = [UInt8]()
        if intArray.count == 10 {
            newArray = intArray.map({UInt8($0)})
        }else if intArray.count < 10 {
            newArray = intArray.map({UInt8($0)})
            for i in intArray.count..<10 {
                newArray.append(0)
            }
        }else{
            newArray = Array(intArray[0..<10]).map({UInt8($0)})
        }
        
        var val:[UInt8] = [0xA8,0x03,0x00,0x10,0x04,0x04,0x00,0x0b,0x11]
        val.append(contentsOf: newArray)
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetOwsCustomEq = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 文件传输
    /*
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload      crc
     APP→DEV     0xA8    0x03    0x0014    0x05         0x01    0x00        0x0f                    1byte
     DEV→APP     0xA8    0x03    0x000e    0x05         0x02    0x02        0x09                    1byte
     
     Payload
     APP→DEV
     文件标识(2Byte)  0xAFBC
     传输类型(1Byte)  0x01第定义表盘  0x02 ota升级
     屏幕宽(2Byte)  如320 则0x140
     屏幕高(2Byte)  如320 则0x140
     文件大小(4Byte)  要传输的文件总字节长度 如102400 则0x19000
     文件数据偏移(4Byte) 传入0
     
     DEV→APP
     允许传输状态(1Byte)   0不允许  1允许
     允许数据传输块大小(4Byte)  如1024 则0x400 （单次传输大小由嵌入式软件决定，app做分包处理，单包的大小根据手机蓝牙的可最大传输长度或由软件定义mtu）
     文件数据偏移(4Byte)  传入0 （允许时传入0，后面需根据传输块大小累加）
     
     传输数据块
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload
     APP→DEV     0xA8    0x03               0x05        0x03    0x00
     DEV→APP     0xA8    0x03               0x05        0x04    0x02
     
     APP→DEV
     传输数据块大小（4Bytes） 如1024 则0x400
     文件数据偏移（4Bytes） 传入设备返回的
     数据块内容（NBytes）

     DEV→APP
     响应数据传输状态 (1Byte)  0x00: 错误  0x01: 正确
     文件数据偏移（4Bytes）  做累加，如第一次是0，第二次是1024，第三次是2048，...            最后一次需传入app写入的文件总长度
     
     方向         SOF     Gaia    Length    CommandID    Key    PDUtype    Payloadsize    Payload         crc
     DEV→APP     0xA8    0x03    0x000e    0x05         0x05    0x02        0x09                        1byte
     
     Payload
     报告升级状态(1Byte)
     0x00: 传输成功
     0x01: 超时
     0x02: CRC错误
     0x03: 无效长度
     0x04: 忙状态
     0x05: 固件大小不对
     0x06: 升级类型不对
     0x07: 固件错误数据
     0x08: 其它错误
     */
    
}
