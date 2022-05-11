//
//  AndXuCommandModule.swift
//  AntSDK
//
//  Created by 猜猜我是谁 on 2021/7/5.
//

import UIKit
import CoreBluetooth
import Alamofire

@objc public enum AntError : Int {
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

@objc public class AntCommandModule: AntBaseModule {
    
    @objc public static let shareInstance = AntCommandModule()
    
    private var semaphoreCount = 1
    private var commandSemaphore = DispatchSemaphore(value: 1)
    private var commandDetectionTimer:Timer?//检测发送的是否有命令回复的定时器
    private var commandDetectionCount = 0
    
    private var healthDataDetectionTimer:Timer?//检测健康数据接收超时的定时器
    private var healthDataDetectionCount = 0
    
    private var screenBigWidth = 0
    private var screenBigHeight = 0
    private var screenSmallWidth = 0
    private var screenSmallHeight = 0
    
    var receiveGetDeviceNameBlock:((String?,AntError) -> Void)?
    var receiveGetFirmwareVersionBlock:((String?,AntError) -> Void)?
    var receiveGetMacBlock:((String?,AntError) -> Void)?
    var receiveGetBatteryBlock:((String?,AntError) -> Void)?
    var receiveSetTimeBlock:((AntError) -> Void)?
    var receiveGetDeviceSupportListBlock:((AntFunctionListModel?,AntError) -> Void)?
    var receiveGetDeviceSupportFunctionDetailBlock:(([String:Any],AntError) -> Void)?
    var receiveGetDeviceOtaVersionInfo:(([String:Any],AntError) -> Void)?
    var receiveGetSerialNumberBlock:((String?,AntError) -> Void)?
    var receiveGetPersonalInformationBlock:((AntPersonalModel?,AntError) -> Void)?
    var receiveSetPersonalInformationBlock:((AntError) -> Void)?
    var receiveGetTimeFormatBlock:((Int,AntError) -> Void)?
    var receiveSetTimeFormatBlock:((AntError) -> Void)?
    var receiveGetMetricSystemBlock:((Int,AntError) -> Void)?
    var receiveSetMetricSystemBlock:((AntError) -> Void)?
    var receiveSetWeatherBlock:((AntError) -> Void)?
    var receiveSetInterCameraBlock:((AntError) -> Void)?
    var receiveSetFindDeviceBlock:((AntError) -> Void)?
    var receiveGetLightScreenBlock:((Int,AntError) -> Void)?
    var receiveSetLightScreenBlock:((AntError) -> Void)?
    var receiveGetScreenLevelBlock:((Int,AntError) -> Void)?
    var receiveSetScreenLevelBlock:((AntError) -> Void)?
    var receiveGetScreenTimeLongBlock:((Int,AntError) -> Void)?
    var receiveSetScreenTimeLongBlock:((AntError) -> Void)?
    var receiveGetLocalDialBlock:((Int,AntError) -> Void)?
    var receiveSetLocalDialBlock:((AntError) -> Void)?
    var receiveGetAlarmBlock:((AntAlarmModel?,AntError) -> Void)?
    var receiveSetAlarmBlock:((AntError) -> Void)?
    var receiveGetDeviceLanguageBlock:((Int,AntError) -> Void)?
    var receiveSetDeviceLanguageBlock:((AntError) -> Void)?
    var receiveGetStepGoalBlock:((Int,AntError) -> Void)?
    var receiveSetStepGoalBlock:((AntError) -> Void)?
    var receiveGetDispalyModeBlock:((Int,AntError) -> Void)?
    var receiveSetDispalyModeBlock:((AntError) -> Void)?
    var receiveGetWearingWayBlock:((Int,AntError) -> Void)?
    var receiveSetWearingWayBlock:((AntError) -> Void)?
    var receiveSetSingleMeasurementBlock:((AntError) -> Void)?
    var receiveSetExerciseModeBlock:((AntError) -> Void)?
    var receiveGetExerciseModeBlock:((Int,AntError) -> Void)?
    var receiveSetDeviceModeBlock:((AntError) -> Void)?
    var receiveSetPhoneModeBlock:((AntError) -> Void)?
    var receiveGetWeatherUnitBlock:((Int,AntError) -> Void)?
    var receiveSetWeatherUnitBlock:((AntError) -> Void)?
    var receiveSetReportRealtimeDataBlock:((AntError) -> Void)?
    var receiveGetCustomDialEditBlock:((AntCustomDialModel?,AntError) -> Void)?
    var receiveSetCustomDialEditBlock:((AntError) -> Void)?
    var receiveSetPhoneStateBlock:((AntError) -> Void)?
    var receiveGetCustonDialFrameSizeBlock:((AntDialFrameSizeModel?,AntError) -> Void)?
    var receiveGet24HrMonitorBlock:((Int,AntError) -> Void)?
    var receiveSet24HrMonitorBlock:((AntError) -> Void)?
    
    var receiveGetNotificationRemindBlock:(([Int],AntError) -> Void)?
    var receiveSetNotificationRemindBlock:((AntError) -> Void)?
    var receiveGetSedentaryBlock:((AntSedentaryModel?,AntError) -> Void)?
    var receiveSetSedentaryBlock:((AntError) -> Void)?
    var receiveGetLostBlock:((Int,AntError) -> Void)?
    var receiveSetLostBlock:((AntError) -> Void)?
    var receiveGetDoNotDisturbBlock:((AntDoNotDisturbModel?,AntError) -> Void)?
    var receiveSetDoNotDisturbBlock:((AntError) -> Void)?
    var receiveGetHrWaringBlock:((AntHrWaringModel?,AntError) -> Void)?
    var receiveSetHrWaringBlock:((AntError) -> Void)?
    var receiveGetMenstrualCycleBlock:(([String:Any],AntError) -> Void)?
    var receiveSetMenstrualCycleBlock:((AntError) -> Void)?
    var receiveGetWashHandBlock:(([String:Any],AntError) -> Void)?
    var receiveSetWashHandBlock:((AntError) -> Void)?
    var receiveGetDrinkWaterBlock:(([String:Any],AntError) -> Void)?
    var receiveSetDrinkWaterBlock:((AntError) -> Void)?
    //    var receiveSetSyncHealthDataBlock:(day:String,type:String,success:(([String:Any],AntError) -> Void))?
    var receiveSetSyncStepDataBlock:(day:String,type:String,success:((Any?,AntError) -> Void))?
    var receiveSetSyncSleepDataBlock:(day:String,type:String,success:((Any?,AntError) -> Void))?
    var receiveSetSyncHeartrateDataBlock:(day:String,type:String,success:((Any?,AntError) -> Void))?
    var receiveSetSyncExerciseDataBlock:((AntExerciseModel?,AntError) -> Void)?
    var receiveSetPowerTurnOffBlock:((AntError) -> Void)?
    var receiveSetFactoryDataResetBlock:((AntError) -> Void)?
    var receiveSetMotorVibrationBlock:((AntError) -> Void)?
    var receiveSetRestartBlock:((AntError) -> Void)?
    var receiveReportRealTiemStepBlock:((AntStepModel?,AntError) -> Void)?
    var receiveReportRealTiemHrBlock:(([String:Any],AntError) -> Void)?
    var receiveReportSingleMeasurementResultBlock:(([String:Any],AntError) -> Void)?
    var receiveReportSingleExerciseEndBlock:((AntError) -> Void)?
    var receiveReportFindPhoneBlock:((AntError) -> Void)?
    var receiveReportEndFindPhoneBlock:((AntError) -> Void)?
    var receiveReportTakePicturesBlock:((AntError) -> Void)?
    var receiveReportMusicControlBlock:((Int,AntError) -> Void)?
    var receiveReportCallControlBlock:((Int,AntError) -> Void)?
    var receiveReportScreenLevelBlock:((Int,AntError) -> Void)?
    var receiveReportScreenTimeLongBlock:((Int,AntError) -> Void)?
    var receiveReportLightScreenBlock:((Int,AntError) -> Void)?
    var receiveReportDeviceVibrationBlock:((Int,AntError) -> Void)?
    var receiveSetSubpackageInformationInteractionBlock:(([String:Any],AntError) -> Void)?
    var receiveSetStartUpgradeBlock:((AntError) -> Void)?
    var receiveSetStartUpgradeProgressBlock:((Float) -> Void)?
    var receiveSetStopUpgradeBlock:((AntError) -> Void)?
    var receiveCheckUpgradeStateBlock:(([String:Any],AntError) -> Void)?
    //    var receive:((String) -> Void)?
    //    var receive:((String) -> Void)?
    //    var receive:((String) -> Void)?
    //    var receive:((String) -> Void)?
    //    var receive:((String) -> Void)?
    //    var receive:((String) -> Void)?
    
    
    var stepMaxData:Data?
    var isStepDetailData = false
    var stepMaxIndex = 0
    var stepDataLength = 0
    var stepCRC16 = 0
    
    var sleepMaxData:Data?
    var isSleepDetailData = false
    var sleepMaxIndex = 0
    var sleepDataLength = 0
    var sleepCRC16 = 0
    
    var hrMaxData:Data?
    var isHrDetailData = false
    var hrMaxIndex = 0
    var hrDataLength = 0
    var hrCRC16 = 0
    
    var exerciseMaxData:Data?
    var isExerciseDetailData = false
    var exerciseMaxIndex = 0
    var exerciseDataLength = 0
    var exerciseCRC16 = 0
    
    var otaData:Data?
    var otaStartIndex = 0
    var otaMaxSingleCount = 0
    var otaPackageCount = 0
    var otaCheckFailResendData:Data?
    var otaContinueDataLength = 0
    var failCheckCount = 0
    var currentReceiveCommandEndOver = false //当前接收命令状态是否结束   5s没有接收到回复数据默认结束，赋值true

    private override init() {
        super.init()
        
        AntCrashHandler.setup { (stackTrace, completion) in
            
            printLog("CrashHandler",stackTrace);
            
            let date:NSDate = NSDate()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "YYYY/MM/dd hh:mm:ss SS"
            let strNowTime = timeFormatter.string(from: date as Date) as String
            let url:String = String.init(format: "========异常错误报告========\ntime:%@\n%@\n\n\n\n\n%@",strNowTime,stackTrace,AntSDKLog.showLog())
            
            let errorPath = NSHomeDirectory() + "/Documents/AntCrashLog"
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
                
        AntBleManager.shareInstance.PeripheralUpdateValue { (peripheral, characteristic, error) in
                        
            let data = characteristic.value ?? Data.init()
            
            let val = data.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
            }
            
            if val.count <= 0 {
                printLog("characteristic数据为空")
                return
            }
            
            //升级部分的命令是没有添加堵塞定时器的，所以收到回复命令之后不要关闭定时器。设备上报的也不需要关闭定时器
            if val[0] >= 0 && val[0] < 5 {
                //有数据回复取消定时器
                self.commandDetectionTimerInvalid()
            }
            
//            if !(val[0] == 0x80 && val[1] == 0x80) {
                printLog("characteristic =",characteristic)
//            }
            
            if characteristic.value?.count ?? 0 > 20 {
                let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: characteristic.value ?? Data.init(),isSend: true))
                printLog("characteristic.value =",dataString)
            }
            
            if characteristic == self.receiveCharacteristic {
//                if !(val[0] == 0x80 && val[1] == 0x80) {
                    AntSDKLog.writeStringToSDKLog(string: String.init(format: "接收:%@", self.convertDataToSpaceHexStr(data: characteristic.value!,isSend: false)))
//                }
                
                //设备信息
                //获取设备名称
                if val[0] == 0x00 && val[1] == 0x80 {
                    
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetDeviceNameBlock {
                            self.parseGetDeviceName(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveGetDeviceNameBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDeviceName长度校验出错"))
                    }
                    
                }
                
                //获取固件版本号
                if val[0] == 0x00 && val[1] == 0x82 {
                    
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetFirmwareVersionBlock {
                            self.parseGetFirmwareVersion(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetFirmwareVersionBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetFirmwareVersion长度校验出错"))
                    }
                    
                }
                
                //获取序列号
                if val[0] == 0x00 && val[1] == 0x84 {
                    
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetSerialNumberBlock {
                            self.parseGetSerialNumber(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetSerialNumberBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetSerialNumber长度校验出错"))
                    }
                    
                }
                
                //设置序列号
                if val[0] == 0x00 && val[1] == 0x85 {
                    
                    
                }
                
                //获取mac地址
                if val[0] == 0x00 && val[1] == 0x86 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetMacBlock {
                            self.parseGetMac(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetMacBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetMac 长度校验出错"))
                    }
                }
                
                //获取电量
                if val[0] == 0x00 && val[1] == 0x88 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetBatteryBlock {
                            self.parseGetBattery(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetBatteryBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetBattery长度校验出错"))
                    }
                    
                }
                
                //设置时间
                if val[0] == 0x00 && val[1] == 0x89 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetTimeBlock {
                            self.parseSetTime(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetTimeBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetTime长度校验出错"))
                    }
                }
                
                //获取设备支持的功能列表
                if val[0] == 0x00 && val[1] == 0x8a {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetDeviceSupportListBlock {
                            self.parseGetDeviceSupportList(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetDeviceSupportListBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDeviceSupportList长度校验出错"))
                    }
                    
                }
                
                //获取支持的功能详情
                if val[0] == 0x00 && val[1] == 0x8c {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetDeviceSupportFunctionDetailBlock {
                            self.parseGetDeviceSupportFunctionDetail(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetDeviceSupportFunctionDetailBlock {
                            block([:],.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDeviceSupportFunctionDetail长度校验出错"))
                    }
                    
                }
                
                
                if val[0] == 0x00 && val[1] == 0x8E {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetDeviceOtaVersionInfo {
                            self.parseGetDeviceOtaVersionInfo(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetDeviceOtaVersionInfo {
                            block([:],.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetBattery长度校验出错"))
                    }
                    
                }
                
                //设备设置
                //获取个人信息
                if val[0] == 0x01 && val[1] == 0x80 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetPersonalInformationBlock {
                            self.parseGetPersonalInformation(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetPersonalInformationBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetPersonalInformation长度校验出错"))
                    }
                    
                }
                
                //设置个人信息
                if val[0] == 0x01 && val[1] == 0x81 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetPersonalInformationBlock {
                            self.parseSetPersonalInformation(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetPersonalInformationBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetPersonalInformation长度校验出错"))
                    }
                    
                }
                
                //获取时间制式
                if val[0] == 0x01 && val[1] == 0x82 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetTimeFormatBlock {
                            self.parseGetTimeFormat(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetTimeFormatBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetTimeFormat长度校验出错"))
                    }
                    
                }
                
                //设置时间制式
                if val[0] == 0x01 && val[1] == 0x83 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetTimeFormatBlock {
                            self.parseSetTimeFormat(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetTimeFormatBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetTimeFormat长度校验出错"))
                    }
                    
                }
                
                //获取公英制
                if val[0] == 0x01 && val[1] == 0x84 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetMetricSystemBlock {
                            self.parseGetMetricSystem(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetMetricSystemBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetMetricSystem长度校验出错"))
                    }
                    
                }
                
                //设置公英制
                if val[0] == 0x01 && val[1] == 0x85 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetMetricSystemBlock {
                            self.parseSetMetricSystem(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetMetricSystemBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetMetricSystem长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x01 && val[1] == 0x86 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //设置天气
                if val[0] == 0x01 && val[1] == 0x87 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetWeatherBlock {
                            self.parseSetWeather(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetWeatherBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetWeather长度校验出错"))
                    }
                    
                }
                if val[0] == 0x01 && val[1] == 0x88 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //设备进入拍照模式
                if val[0] == 0x01 && val[1] == 0x89 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetInterCameraBlock {
                            self.parseSetInterCamera(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetInterCameraBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetInterCamera长度校验出错"))
                    }
                    
                }
                if val[0] == 0x01 && val[1] == 0x8a {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //寻找手环
                if val[0] == 0x01 && val[1] == 0x8b {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetFindDeviceBlock {
                            self.parseSetFindDevice(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetFindDeviceBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetFindDevice长度校验出错"))
                    }
                    
                }
                
                //获取抬腕亮屏
                if val[0] == 0x01 && val[1] == 0x8c {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetLightScreenBlock {
                            self.parseGetLightScreen(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetLightScreenBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLightScreen长度校验出错"))
                    }
                    
                }
                
                //设置抬腕亮屏
                if val[0] == 0x01 && val[1] == 0x8d {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetLightScreenBlock {
                            self.parseSetLightScreen(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveSetLightScreenBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetLightScreen长度校验出错"))
                    }
                    
                }
                
                //获取屏幕亮度
                if val[0] == 0x01 && val[1] == 0x8e {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetScreenLevelBlock {
                            self.parseGetScreenLevel(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveGetScreenLevelBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetScreenLevel长度校验出错"))
                    }
                    
                }
                
                //设置屏幕亮度
                if val[0] == 0x01 && val[1] == 0x8f {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetScreenLevelBlock {
                            self.parseSetScreenLevel(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetScreenLevelBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetScreenLevel长度校验出错"))
                    }
                    
                }
                
                //获取屏幕时长
                if val[0] == 0x01 && val[1] == 0xb2 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetScreenTimeLongBlock {
                            self.parseGetScreenTimeLong(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveGetScreenTimeLongBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetScreenTimeLong长度校验出错"))
                    }
                    
                }
                
                //设置屏幕时长
                if val[0] == 0x01 && val[1] == 0xb3 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetScreenTimeLongBlock {
                            self.parseSetScreenTimeLong(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetScreenTimeLongBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetScreenTimeLong长度校验出错"))
                    }
                    
                }
                
                
                //获取本地表盘
                if val[0] == 0x01 && val[1] == 0x90 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetLocalDialBlock {
                            self.parseGetLocalDial(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetLocalDialBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLocalDial长度校验出错"))
                    }
                    
                }
                
                //设置本地表盘
                if val[0] == 0x01 && val[1] == 0x91 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetLocalDialBlock {
                            self.parseSetLocalDial(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetLocalDialBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLocalDial长度校验出错"))
                    }
                    
                }
                
                //获取闹钟
                if val[0] == 0x01 && val[1] == 0x92 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetAlarmBlock {
                            self.parseGetAlarm(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetAlarmBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetAlarm长度校验出错"))
                    }
                    
                }
                
                //设置闹钟
                if val[0] == 0x01 && val[1] == 0x93 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetAlarmBlock {
                            self.parseSetAlarm(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetAlarmBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetAlarm长度校验出错"))
                    }
                    
                }
                
                //获取设备语言
                if val[0] == 0x01 && val[1] == 0x94 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetDeviceLanguageBlock {
                            self.parseGetDeviceLanguage(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetDeviceLanguageBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDeviceLanguage长度校验出错"))
                    }
                    
                }
                
                //设置设备语言
                if val[0] == 0x01 && val[1] == 0x95 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetDeviceLanguageBlock {
                            self.parseSetDeviceLanguage(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetDeviceLanguageBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDeviceLanguage长度校验出错"))
                    }
                    
                }
                
                //获取目标步数
                if val[0] == 0x01 && val[1] == 0x96 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetStepGoalBlock {
                            self.parseGetStepGoal(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetStepGoalBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetStepGoal长度校验出错"))
                    }
                    
                }
                
                //设置目标步数
                if val[0] == 0x01 && val[1] == 0x97 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetStepGoalBlock {
                            self.parseSetStepGoal(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetStepGoalBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetStepGoal长度校验出错"))
                    }
                    
                }
                
                //获取显示方式
                if val[0] == 0x01 && val[1] == 0x98 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetDispalyModeBlock {
                            self.parseGetDispalyMode(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetDispalyModeBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDispalyMode长度校验出错"))
                    }
                    
                }
                
                //设置显示方式
                if val[0] == 0x01 && val[1] == 0x99 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetDispalyModeBlock {
                            self.parseSetDispalyMode(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetDispalyModeBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDispalyMode长度校验出错"))
                    }
                    
                }
                
                //获取佩戴方式
                if val[0] == 0x01 && val[1] == 0x9a {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetWearingWayBlock {
                            self.parseGetWearingWay(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetWearingWayBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetWearingWay长度校验出错"))
                    }
                    
                }
                
                //设置佩戴方式
                if val[0] == 0x01 && val[1] == 0x9b {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetWearingWayBlock {
                            self.parseSetWearingWay(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetWearingWayBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetWearingWay长度校验出错"))
                    }
                    
                }
                if val[0] == 0x01 && val[1] == 0x9c {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //设置单次测量
                if val[0] == 0x01 && val[1] == 0x9d {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetSingleMeasurementBlock {
                            self.parseSetSingleMeasurement(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetSingleMeasurementBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSingleMeasurement长度校验出错"))
                    }
                    
                }
                
                //获取锻炼模式
                if val[0] == 0x01 && val[1] == 0x9e {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetExerciseModeBlock {
                            self.parseGetExerciseMode(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetExerciseModeBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetExerciseMode 长度校验出错"))
                    }
                    
                }
                
                //设置锻炼模式
                if val[0] == 0x01 && val[1] == 0x9f {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetExerciseModeBlock {
                            self.parseSetExerciseMode(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetExerciseModeBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetExerciseMode长度校验出错"))
                    }
                    
                }
                
                //设置设备模式
                if val[0] == 0x01 && val[1] == 0xa1 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetDeviceModeBlock {
                            self.parseSetDeviceMode(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetDeviceModeBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDeviceMode长度校验出错"))
                    }
                    
                }
                
                //设置手机类型
                if val[0] == 0x01 && val[1] == 0xa5 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetPhoneModeBlock {
                            self.parseSetPhoneMode(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetPhoneModeBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetPhoneMode长度校验出错"))
                    }
                    
                }
                
                //获取天气单位
                if val[0] == 0x01 && val[1] == 0xa8 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetWeatherUnitBlock {
                            self.parseGetWeatherUnit(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetWeatherUnitBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetWeatherUnit长度校验出错"))
                    }
                    
                }
                
                //设置天气单位
                if val[0] == 0x01 && val[1] == 0xa9 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetWeatherUnitBlock {
                            self.parseSetWeatherUnit(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetWeatherUnitBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetWeatherUnit长度校验出错"))
                    }
                }
                
                //设置实时数据上报开关
                if val[0] == 0x01 && val[1] == 0xab {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetReportRealtimeDataBlock {
                            self.parseSetReportRealtimeData(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetReportRealtimeDataBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetReportRealtimeData长度校验出错"))
                    }
                }
                
                //获取自定义表盘
                if val[0] == 0x01 && val[1] == 0xac {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetCustomDialEditBlock {
                            self.parseGetCustomDialEdit(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetCustomDialEditBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetReportRealtimeData长度校验出错"))
                    }
                }
            
                //设置自定义表盘
                if val[0] == 0x01 && val[1] == 0xad {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetCustomDialEditBlock {
                            self.parseSetCustomDialEdit(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetCustomDialEditBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetReportRealtimeData长度校验出错"))
                    }
                }
                
                //设置电话状态
                if val[0] == 0x01 && val[1] == 0xaf {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetPhoneStateBlock {
                            self.parseSetPhoneState(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetPhoneStateBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetReportRealtimeData长度校验出错"))
                    }
                }
                
                //获取自定义表盘尺寸 0x30
                if val[0] == 0x01 && val[1] == 0xb0 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetCustonDialFrameSizeBlock {
                            self.parseGetCustonDialFrameSize(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetCustonDialFrameSizeBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetNotificationRemind长度校验出错"))
                    }
                }
                
                //获取24小时心率监测
                if val[0] == 0x01 && val[1] == 0xb4 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGet24HrMonitorBlock {
                            self.parseGet24HrMonitor(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGet24HrMonitorBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "rGet24HrMonitor长度校验出错"))
                    }
                }
                
                //设置24小时心率监测
                if val[0] == 0x01 && val[1] == 0xb5 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSet24HrMonitorBlock {
                            self.parseSet24HrMonitor(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSet24HrMonitorBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "Set24HrMonitor长度校验出错"))
                    }
                    
                }
                                
                //获取消息提醒
                if val[0] == 0x02 && val[1] == 0x80 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetNotificationRemindBlock {
                            self.parseGetNotificationRemind(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetNotificationRemindBlock {
                            block([],.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetNotificationRemind长度校验出错"))
                    }
                    
                }
                
                //设置消息提醒
                if val[0] == 0x02 && val[1] == 0x81 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetNotificationRemindBlock {
                            self.parseSetNotificationRemind(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetNotificationRemindBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetNotificationRemind长度校验出错"))
                    }
                    
                }
                
                //获取久坐提醒
                if val[0] == 0x02 && val[1] == 0x82 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetSedentaryBlock {
                            self.parseGetSedentary(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetSedentaryBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetSedentary长度校验出错"))
                    }
                    
                }
                
                //设置久坐提醒
                if val[0] == 0x02 && val[1] == 0x83 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetSedentaryBlock {
                            self.parseSetSedentary(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetSedentaryBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSedentary长度校验出错"))
                    }
                    
                }
                
                //获取防丢提醒
                if val[0] == 0x02 && val[1] == 0x84 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetLostBlock {
                            self.parseGetLost(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetLostBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLost长度校验出错"))
                    }
                    
                }
                
                //设置防丢提醒
                if val[0] == 0x02 && val[1] == 0x85 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetLostBlock {
                            self.parseSetLost(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetLostBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetLost长度校验出错"))
                    }
                    
                }
                
                //获取勿扰
                if val[0] == 0x02 && val[1] == 0x86 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetDoNotDisturbBlock {
                            self.parseGetDoNotDisturb(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetDoNotDisturbBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDoNotDisturb长度校验出错"))
                    }
                    
                }
                
                //设置勿扰
                if val[0] == 0x02 && val[1] == 0x87 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetDoNotDisturbBlock {
                            self.parseSetDoNotDisturb(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetDoNotDisturbBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDoNotDisturb长度校验出错"))
                    }
                    
                }
                
                //获取心率预警
                if val[0] == 0x02 && val[1] == 0x88 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetHrWaringBlock {
                            self.parseGetHrWaring(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetHrWaringBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetHrWaring长度校验出错"))
                    }
                    
                }
                
                //设置心率预警
                if val[0] == 0x02 && val[1] == 0x89 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetHrWaringBlock {
                            self.parseSetHrWaring(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetHrWaringBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetHrWaring长度校验出错"))
                    }
                    
                }
                
                //获取生理周期
                if val[0] == 0x02 && val[1] == 0x8a {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetMenstrualCycleBlock {
                            self.parseGetMenstrualCycle(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetMenstrualCycleBlock {
                            block([:],.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetMenstrualCycle长度校验出错"))
                    }
                    
                }
                
                //设置生理周期
                if val[0] == 0x02 && val[1] == 0x8b {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetMenstrualCycleBlock {
                            self.parseSetMenstrualCycle(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetMenstrualCycleBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetMenstrualCycle长度校验出错"))
                    }
                    
                }
                
                //获取洗手提醒
                if val[0] == 0x02 && val[1] == 0x8c {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetWashHandBlock {
                            self.parseGetWashHand(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetWashHandBlock {
                            block([:],.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetWashHand长度校验出错"))
                    }
                    
                }
                
                //设置洗手提醒
                if val[0] == 0x02 && val[1] == 0x8d {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetWashHandBlock {
                            self.parseSetWashHand(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetWashHandBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetWashHand长度校验出错"))
                    }
                    
                }
                
                //获取喝水提醒
                if val[0] == 0x02 && val[1] == 0x8e {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetDrinkWaterBlock {
                            self.parseGetDrinkWater(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetDrinkWaterBlock {
                            block([:],.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDrinkWater长度校验出错"))
                    }
                    
                }
                
                //设置喝水提醒
                if val[0] == 0x02 && val[1] == 0x8f {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetDrinkWaterBlock {
                            self.parseSetDrinkWater(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetDrinkWaterBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDrinkWater长度校验出错"))
                    }
                    
                }
                
                //同步健康数据 0x00
                if val[0] == 0x03 && val[1] == 0x80 {
                    
                    if self.checkLength(val: [UInt8](val)) {
                        if val[4] == 0 {
                            if let block = self.receiveSetSyncStepDataBlock {
                                if val.count >= 7 {
                                    let type = val[5]
                                    let dayCount = val[6]
                                    block.success(nil,.noMoreData)
                                }else{
                                    block.success(nil,.noMoreData)
                                }
                            }
                            if let block = self.receiveSetSyncSleepDataBlock {
                                if val.count >= 7 {
                                    let type = val[5]
                                    let dayCount = val[6]
                                    block.success(nil,.noMoreData)
                                }else{
                                    block.success(nil,.noMoreData)
                                }
                            }
                            if let block = self.receiveSetSyncHeartrateDataBlock {
                                if val.count >= 7 {
                                    let type = val[5]
                                    let dayCount = val[6]
                                    block.success(nil,.noMoreData)
                                }else{
                                    block.success(nil,.noMoreData)
                                }
                            }
                            self.signalCommandSemaphore()
                            AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncHealthData 数据状态错误"))
                            return
                        }
                    }
                    
                    if val.count == 20 {
                        
                        if ((Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24) == 96 || (Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24) == 108) && val[6] == 1 && val[7] == 1 {
                            self.isStepDetailData = true
                            self.addHealthDataTimer()
                            let maxDataCount = (Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24)
                            let indexCount =  1 + (maxDataCount + 8) / 16 //应该能接收的所有包序号
                            self.stepMaxIndex = indexCount
                            self.stepDataLength = maxDataCount
                            self.stepCRC16 = (Int(val[10]) | Int(val[11]) << 8)
                            printLog("stepMaxIndex ->",self.stepMaxIndex)
                            printLog("self.stepCRC16 ->",self.stepCRC16)
                            printLog("self.stepCRC16 ->%04x",String.init(format: "%04x", self.stepCRC16))
                            self.stepMaxData = nil
                            
                            self.stepMaxData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                                let byte = bytes.baseAddress! + 13
                                return Data.init(bytes: byte, count: val.count-13)
                            })
                            return
                        }
                        
                        if (Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24) == 360 && val[6] == 1 && val[7] == 3 {
                            self.isSleepDetailData = true
                            self.addHealthDataTimer()
                            let maxDataCount = (Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24)
                            let indexCount =  1 + (maxDataCount + 8) / 16 //应该能接收的所有包序号
                            self.sleepMaxIndex = indexCount
                            self.sleepDataLength = maxDataCount
                            self.sleepCRC16 = (Int(val[10]) | Int(val[11]) << 8)
                            printLog("sleepMaxIndex ->",self.sleepMaxIndex)
                            printLog("self.sleepCRC16 ->",self.sleepCRC16)
                            printLog("self.sleepCRC16 ->%04x",String.init(format: "%04x", self.sleepCRC16))
                            self.sleepMaxData = nil
                            
                            self.sleepMaxData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                                let byte = bytes.baseAddress! + 13
                                return Data.init(bytes: byte, count: val.count-13)
                            })
                            return
                        }
                        
                        if (Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24) == 288 && val[6] == 1 && val[7] == 2 {
                            self.isHrDetailData = true
                            self.addHealthDataTimer()
                            let maxDataCount = (Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24)
                            let indexCount =  1 + (maxDataCount + 8) / 16 //应该能接收的所有包序号
                            self.hrMaxIndex = indexCount
                            self.hrDataLength = maxDataCount
                            self.hrCRC16 = (Int(val[10]) | Int(val[11]) << 8)
                            printLog("hrMaxIndex ->",self.hrMaxIndex)
                            printLog("self.hrCRC16 ->",self.hrCRC16)
                            printLog("self.hrCRC16 ->%04x",String.init(format: "%04x", self.hrCRC16))
                            self.hrMaxData = nil
                            
                            self.hrMaxData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                                let byte = bytes.baseAddress! + 13
                                return Data.init(bytes: byte, count: val.count-13)
                            })
                            return
                        }
                    }
                    
                    if self.isStepDetailData {

                        let newData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                            let byte = bytes.baseAddress! + 4
                            return Data.init(bytes: byte, count: val.count-4)
                        })
                        
                        self.stepMaxData?.append(newData)
                        
                        if (Int(val[2]) | Int(val[3]) << 8 ) >= self.stepMaxIndex-1 {
                            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.receiveHealthDataTimeOut), object: nil)
                            
                            self.isStepDetailData = false
                            printLog("isStepDetailData接收完成")
                            
                            printLog("length =",self.stepMaxData!.count,"stepMaxData ->",self.convertDataToHexStr(data: self.stepMaxData!))
                            
                            let crc16:UInt16 = self.CRC16(data: self.stepMaxData!)
                            
                            printLog("crc16 ->",crc16)
                            
                            printLog("crc16 ->02x",String.init(format: "%02x", crc16))
                            
                            if self.stepDataLength == self.stepMaxData!.count && self.stepCRC16 == crc16 {
                                
                                let stepVal = self.stepMaxData!.withUnsafeBytes({ (bytes) -> [UInt8] in
                                    let b = (bytes.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                                    return [UInt8](UnsafeBufferPointer.init(start: b, count: (self.stepMaxData?.count ?? 0)))
                                })
                                
                                if let block = self.receiveSetSyncStepDataBlock {
                                    self.parseSetSyncHealthData(val: stepVal, type: block.type, day: block.day, success: block.success)
                                }
                                
                                
                            }else{
                                
                                if self.stepDataLength != self.stepMaxData!.count {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncHealthData长度校验出错"))
                                }
                                
                                if self.stepCRC16 != crc16 {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@ 第一包给的0x%04x,所有接收校验的0x%04x", "同步步数数据 CRC16校验出错",self.stepCRC16,crc16))
                                }
                                
                                if let block = self.receiveSetSyncStepDataBlock {
                                    block.success(nil,.invalidLength)
                                }
                            }
                        }else{
                            //数据长度不够的时候又没有再接收到数据  添加容错机制
                            //5s之后判断此次接收命令的状态是否结束
                            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.receiveHealthDataTimeOut), object: nil)
                            self.perform(#selector(self.receiveHealthDataTimeOut), with: nil, afterDelay: 5)
                        }
                    }
                    
                    if self.isSleepDetailData {

                        let newData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                            let byte = bytes.baseAddress! + 4
                            return Data.init(bytes: byte, count: val.count-4)
                        })
                        
                        self.sleepMaxData?.append(newData)
                        
                        if (Int(val[2]) | Int(val[3]) << 8 ) >= self.sleepMaxIndex-1 {
                            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.receiveHealthDataTimeOut), object: nil)
                            
                            self.isSleepDetailData = false
                            printLog("isSleepDetailData接收完成")
                            
                            printLog("length =",self.sleepMaxData!.count,"sleepMaxData ->",self.convertDataToHexStr(data: self.sleepMaxData!))
                            
                            let crc16:UInt16 = self.CRC16(data: self.sleepMaxData!)
                            
                            printLog("crc16 ->",crc16)
                            
                            printLog("crc16 ->02x",String.init(format: "%02x", crc16))
                            
                            if self.sleepDataLength == self.sleepMaxData!.count && self.sleepCRC16 == crc16 {
                                
                                let sleepVal = self.sleepMaxData!.withUnsafeBytes({ (bytes) -> [UInt8] in
                                    let b = (bytes.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                                    return [UInt8](UnsafeBufferPointer.init(start: b, count: (self.sleepMaxData?.count ?? 0)))
                                })
                                
                                if let block = self.receiveSetSyncSleepDataBlock {
                                    self.parseSetSyncHealthData(val: sleepVal, type: block.type, day: block.day, success: block.success)
                                }
                                
                            }else{
                                
                                if self.sleepDataLength != self.sleepMaxData!.count {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncHealthData长度校验出错"))
                                }
                                
                                if self.sleepCRC16 != crc16 {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@ 第一包给的0x%04x,所有接收校验的0x%04x", "同步步数数据 CRC16校验出错",self.sleepCRC16,crc16))
                                }
                                
                                if let block = self.receiveSetSyncSleepDataBlock {
                                    block.success([:],.invalidLength)
                                }
                            }
                            
                            
                        }else{
                            //数据长度不够的时候又没有再接收到数据  添加容错机制
                            //5s之后判断此次接收命令的状态是否结束
                            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.receiveHealthDataTimeOut), object: nil)
                            self.perform(#selector(self.receiveHealthDataTimeOut), with: nil, afterDelay: 5)
                        }
                    }
                    
                    if self.isHrDetailData {
                        
                        let newData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                            let byte = bytes.baseAddress! + 4
                            return Data.init(bytes: byte, count: val.count-4)
                        })
                        
                        self.hrMaxData?.append(newData)
                        
                        if (Int(val[2]) | Int(val[3]) << 8 ) >= self.hrMaxIndex-1 {
                            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.receiveHealthDataTimeOut), object: nil)
                            
                            self.isHrDetailData = false
                            printLog("isHrDetailData接收完成")
                            
                            printLog("length =",self.hrMaxData!.count,"hrMaxData ->",self.convertDataToHexStr(data: self.hrMaxData!))
                            
                            let crc16:UInt16 = self.CRC16(data: self.hrMaxData!)
                            
                            printLog("crc16 ->",crc16)
                            
                            printLog("crc16 ->02x",String.init(format: "%02x", crc16))
                            
                            if self.hrDataLength == self.hrMaxData!.count && self.hrCRC16 == crc16 {
                                
                                let hrVal = self.hrMaxData!.withUnsafeBytes({ (bytes) -> [UInt8] in
                                    let b = (bytes.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                                    return [UInt8](UnsafeBufferPointer.init(start: b, count: (self.hrMaxData?.count ?? 0)))
                                })
                                
                                if let block = self.receiveSetSyncHeartrateDataBlock {
                                    self.parseSetSyncHealthData(val: hrVal, type: block.type, day: block.day, success: block.success)
                                }
                                
                            }else{
                                
                                if self.hrDataLength != self.hrMaxData!.count {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncHealthData长度校验出错"))
                                }
                                
                                if self.hrCRC16 != crc16 {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@ 第一包给的0x%04x,所有接收校验的0x%04x", "同步步数数据 CRC16校验出错",self.hrCRC16,crc16))
                                }
                                
                                if let block = self.receiveSetSyncHeartrateDataBlock {
                                    block.success([:],.invalidLength)
                                }
                            }
                            
                            
                        }else{
                            //数据长度不够的时候又没有再接收到数据  添加容错机制
                            //5s之后判断此次接收命令的状态是否结束
                            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.receiveHealthDataTimeOut), object: nil)
                            self.perform(#selector(self.receiveHealthDataTimeOut), with: nil, afterDelay: 5)
                        }
                    }
                    
                }
                
                //同步锻炼数据
                if val[0] == 0x03 && val[1] == 0x82 {
                    
                    if self.checkLength(val: [UInt8](val)) {
                        if val[4] == 0 {
                            
                            if let block = self.receiveSetSyncExerciseDataBlock {
                                block(nil,.noMoreData)
                            }
                            self.signalCommandSemaphore()
                            AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncExerciseData 数据状态错误"))
                            return
                        }
                    }
                    
                    if val.count == 20 {
                        
                        if ((Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24) == 32 || (Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24) == 24) && val[6] == 1 && val[7] == 4 {
                            self.isExerciseDetailData = true
                            let maxDataCount = (Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24)
                            let indexCount =  1 + (maxDataCount + 8) / 16 //应该能接收的所有包序号
                            self.exerciseMaxIndex = indexCount
                            self.exerciseDataLength = maxDataCount
                            self.exerciseCRC16 = (Int(val[10]) | Int(val[11]) << 8)
                            printLog("exerciseMaxIndex ->",self.exerciseMaxIndex)
                            printLog("self.exerciseCRC16 ->",self.exerciseCRC16)
                            printLog("self.exerciseCRC16 ->%04x",String.init(format: "%04x", self.exerciseCRC16))
                            self.exerciseMaxData = nil
                            
                            self.exerciseMaxData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                                let byte = bytes.baseAddress! + 13
                                return Data.init(bytes: byte, count: val.count-13)
                            })
                            return
                        }
                    }
                    
                    if self.isExerciseDetailData {
                        
                        let newData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                            let byte = bytes.baseAddress! + 4
                            return Data.init(bytes: byte, count: val.count-4)
                        })
                        
                        self.exerciseMaxData?.append(newData)
                        
                        if (Int(val[2]) | Int(val[3]) << 8 ) >= self.exerciseMaxIndex-1 {
                            
                            self.isExerciseDetailData = false
                            printLog("isExerciseDetailData接收完成")
                            
                            printLog("length =",self.exerciseMaxData!.count,"exerciseMaxData ->",self.convertDataToHexStr(data: self.exerciseMaxData!))
                            
                            let crc16:UInt16 = self.CRC16(data: self.exerciseMaxData!)
                            
                            printLog("crc16 ->",crc16)
                            
                            printLog("crc16 ->02x",String.init(format: "%02x", crc16))
                            
                            if self.exerciseDataLength == self.exerciseMaxData!.count && self.exerciseCRC16 == crc16 {
                                
                                let exVal = self.exerciseMaxData!.withUnsafeBytes({ (bytes) -> [UInt8] in
                                    let b = (bytes.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                                    return [UInt8](UnsafeBufferPointer.init(start: b, count: (self.exerciseMaxData?.count ?? 0)))
                                })
                                
                                if let block = self.receiveSetSyncExerciseDataBlock {
                                    self.parseSetSyncExerciseData(val: exVal, success: block)
                                }
                                
                            }else{
                                
                                if self.exerciseDataLength != self.exerciseMaxData!.count {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncExerciseData长度校验出错"))
                                }
                                
                                if self.exerciseCRC16 != crc16 {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@ 第一包给的0x%04x,所有接收校验的0x%04x", "同步锻炼数据 CRC16校验出错",self.exerciseCRC16,crc16))
                                }
                            }
                        }
                    }
                }
                
                //关机
                if val[0] == 0x04 && val[1] == 0x81 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetPowerTurnOffBlock {
                            self.parseSetPowerTurnOff(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveSetPowerTurnOffBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetPowerTurnOff长度校验出错"))
                    }
                    
                }
                
                //恢复出厂设置
                if val[0] == 0x04 && val[1] == 0x83 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetFactoryDataResetBlock {
                            self.parseSetFactoryDataReset(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetFactoryDataResetBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetFactoryDataReset长度校验出错"))
                    }
                    
                }
                
                //马达震动
                if val[0] == 0x04 && val[1] == 0x85 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetMotorVibrationBlock {
                            self.parseSetMotorVibration(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveSetMotorVibrationBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetMotorVibration长度校验出错"))
                    }
                    
                }
                
                //重新启动
                if val[0] == 0x04 && val[1] == 0x07 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetRestartBlock {
                            self.parseSetRestart(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveSetRestartBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetRestart长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x80 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportRealTiemStepBlock {
                            self.parseReportRealTimeStepData(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportRealTiemStepBlock {
                            block(nil,.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x82 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportRealTiemHrBlock {
                            self.parseReportRealTimeHrData(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportRealTiemHrBlock {
                            block([:],.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x84 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportSingleMeasurementResultBlock {
                            self.parseReportSingleMeasurementResultData(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportSingleMeasurementResultBlock {
                            block([:],.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x86 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportSingleExerciseEndBlock {
                            self.parseReportSingleExerciseEndData(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveReportSingleExerciseEndBlock {
                            block(.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x88 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportFindPhoneBlock {
                            self.parseReportFindPhoneData(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportFindPhoneBlock {
                            block(.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x89 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportEndFindPhoneBlock {
                            self.parseReportEndFindPhoneData(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportEndFindPhoneBlock {
                            block(.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x8a {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportTakePicturesBlock {
                            self.parseReportTakePicturesData(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveReportTakePicturesBlock {
                            block(.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x8c {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportMusicControlBlock {
                            self.parseReportMusicControlData(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportMusicControlBlock {
                            block(-1,.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x8e {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportCallControlBlock {
                            self.parseReportCallControlData(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportCallControlBlock {
                            block(-1,.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                }
                
                if val[0] == 0x80 && val[1] == 0x90 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportScreenLevelBlock {
                            self.parseReportScreenLevel(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportScreenLevelBlock {
                            block(-1,.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x92 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportScreenTimeLongBlock {
                            self.parseReportScreenTimeLong(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportScreenTimeLongBlock {
                            block(-1,.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x94 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportLightScreenBlock {
                            self.parseReportLightScreen(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportLightScreenBlock {
                            block(-1,.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x96 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportDeviceVibrationBlock {
                            self.parseReportDeviceVibration(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportDeviceVibrationBlock {
                            block(-1,.invalidLength)
                        }
                        
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                
                //2.3.1.分包信息交互(APP) 0x00
                if val[0] == 0x05 && val[1] == 0x80 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetSubpackageInformationInteractionBlock {
                            self.parseSetSubpackageInformationInteractionData(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveSetSubpackageInformationInteractionBlock {
                            block([:],.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //2.3.2.分包信息交互(设备端) 0x01
                if val[0] == 0x05 && val[1] == 0x81 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //2.3.3.启动升级 0x02
                if val[0] == 0x05 && val[1] == 0x82 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetStartUpgradeBlock, let progress = self.receiveSetStartUpgradeProgressBlock {
                            self.parseSetStartUpgradeData(val: val, progress: progress, success: block)
                        }
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //2.3.3.停止升级 0x03
                if val[0] == 0x05 && val[1] == 0x83 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetStopUpgradeBlock {
                            self.parseSetStopUpgradeData(val: val, success: block)
                        }
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //组校验
                if val[0] == 0x05 && val[1] == 0x85 {
                    if self.checkLength(val: [UInt8](val)) {
                            
                        let otaVal = self.otaData?.withUnsafeBytes{ (byte) -> [UInt8] in
                            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                            return [UInt8](UnsafeBufferPointer.init(start: b, count: self.otaData?.count ?? 0))
                        } ?? []
                        
                        if val[5] == 0 {
                            //校验成功  发送下一组
                            self.otaStartIndex += 1
                            self.dealUpgradeData(maxSingleCount: self.otaMaxSingleCount, packageCount:  self.otaPackageCount, packageIndex: self.otaStartIndex, val: otaVal, progress: self.receiveSetStartUpgradeProgressBlock!, success: self.receiveSetStartUpgradeBlock!)
                            
                            self.otaCheckFailResendData = nil
                            self.failCheckCount = 0
                        }else if val[5] == 1 {
                            //所有数据接收完成
                            self.otaCheckFailResendData = nil
                            self.failCheckCount = 0
                            self.otaStartIndex = 0
                            self.otaData = nil
                            printLog("self.otaData = nil")
                            
                        }else if val[5] == 5 {
                            //存在重传数据
                            if self.otaCheckFailResendData == data {//重传数据已发送过一次直接失败
                                
                                if let block = self.receiveSetStartUpgradeBlock {
                                    block(.fail)
                                    self.otaCheckFailResendData = nil
                                    self.otaData = nil
                                    printLog("self.otaData = nil")
                                    self.failCheckCount = 0
                                }
                                
                            }else{
                                
                                self.ResendUpgradeData(maxSingleCount: self.otaMaxSingleCount, packageCount: self.otaPackageCount, resendVal: val, val: otaVal, progress: self.receiveSetStartUpgradeProgressBlock!, success: self.receiveSetStartUpgradeBlock!)
                                if self.failCheckCount >= 2 {
                                    self.otaCheckFailResendData = data
                                    self.failCheckCount = 0
                                }
                                self.failCheckCount += 1
                                
                            }
                            
                        }else {
                            self.otaStartIndex = 0
                            if let block = self.receiveSetStartUpgradeBlock {
                                block(.fail)
                                self.otaCheckFailResendData = nil
                                self.failCheckCount = 0
                                self.otaData = nil
                                printLog("self.otaData = nil")
                            }
                        }
                        
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                }
                
                //升级结果
                if val[0] == 0x05 && val[1] == 0x86 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetStartUpgradeBlock {
                            self.parseGetUpgradeResultData(val: val, success: block)
                        }
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x05 && val[1] == 0x87 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if val[5] == 0 {
                            if let block = self.receiveCheckUpgradeStateBlock {
                                block([:],.none)
                            }
                        }else if val[5] == 1 {
                            
                            self.otaMaxSingleCount = (Int(val[10]) | Int(val[11]) << 8 )
                            self.otaPackageCount = Int(val[12])
                            //给的包号是otaMaxSingleCount为1包，转换为otaStartIndex需要 包号/每组包数
                            let packageIndex = (Int(val[14]) | Int(val[15]) << 8 | Int(val[16]) << 16 | Int(val[17]) << 24)
                            self.otaStartIndex = packageIndex / self.otaPackageCount
                            self.otaContinueDataLength = (Int(val[7]) | Int(val[8]) << 8 | Int(val[9]) << 16 )
                            
                            printLog("继续升级信息:单包最大字节数",self.otaMaxSingleCount,"每组包数:",self.otaPackageCount,"包号:",packageIndex,"文件长度:",self.otaContinueDataLength)
                            
                            if self.otaData != nil {
                                
                                let otaVal = self.otaData!.withUnsafeBytes{ (byte) -> [UInt8] in
                                    let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                                    return [UInt8](UnsafeBufferPointer.init(start: b, count: self.otaData!.count))
                                }
                                if self.otaContinueDataLength != self.otaData!.count {
                                    printLog("otaContinueDataLength =",self.otaContinueDataLength,"otaData.count =",self.otaData!.count,"数据不一致")
                                }else{
                                    self.dealUpgradeData(maxSingleCount: self.otaMaxSingleCount, packageCount:  self.otaPackageCount, packageIndex: self.otaStartIndex, val: otaVal, progress: self.receiveSetStartUpgradeProgressBlock!, success: self.receiveSetStartUpgradeBlock!)
                                }
                                
                            }else{
                                
                                if let block = self.receiveCheckUpgradeStateBlock {
                                    block(["type":"\(val[6])"],.none)
                                }
                                
                            }
                        }
                        
                    }else{
                        
                        printLog("第\(#line)行","self.semaphoreCount =",self.semaphoreCount)
                        AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    //printLog("第\(#line)行" , "\(#function)")
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
    
    func writeData(data:Data) {
        //此方法目前是升级在用 不做信号量等待
        if self.writeCharacteristic != nil {
            
            let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
            AntSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
            printLog("send",dataString)
            self.peripheral?.writeValue(data, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
        }else{
            
            AntSDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
            printLog("写特征为空")
            
        }
    }
    
    func writeDataAndBackError(data:Data) -> AntError {
        
        if self.peripheral?.state != .connected {
            
            return .disconnected
            
        }else{
            
            if self.writeCharacteristic != nil && self.peripheral != nil {

                DispatchQueue.global().async {

                    //printLog("send dataString -> wait 之前 self.semaphoreCount =",self.semaphoreCount)
                    self.semaphoreCount -= 1
                    self.commandSemaphore.wait()

                    let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
                    AntSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
                                        
                    DispatchQueue.main.async {

                        printLog("send",dataString)
                        //printLog("发送命令 -> self.semaphoreCount =",self.semaphoreCount)
                        self.peripheral?.writeValue(data, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
                        //定时器计数重置
                        self.commandDetectionCount = 0
                        if self.commandDetectionTimer == nil {
                            //检测命令发送之后是否有回复，在deviceReceivedData方法内有数据则把此定时器销毁。如果没有回复，那么5s之后把信号量回复默认值
                            self.commandDetectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.commandDetectionTimerMethod), userInfo: nil, repeats: true)
                        }
                    }
                }
                return .none
            }else{
                
                AntSDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
                printLog("写特征为空")
                
                return .invalidCharacteristic
            }
        }
    }
    
    // MARK: - 检测命令定时器方法
    @objc func commandDetectionTimerMethod() {
        if self.commandDetectionCount >= 50 {
            //用信号量+1，只放一条命令过。如果用重置信号量会导致后续的命令全部怼出去，如果还要丢的命令也无法发现
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
            //printLog("commandDetectionTimerInvalid 定时器销毁")
        }
    }
    
    // MARK: - 健康数据接收状态定时器开启
    func addHealthDataTimer() {
        self.healthDataDetectionCount = 0
        self.currentReceiveCommandEndOver = false
        if self.healthDataDetectionTimer == nil {
            self.healthDataDetectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.healthDataDetectionTimerMethod), userInfo: nil, repeats: true)
        }
    }
    
    // MARK: - 健康数据接收状态定时器方法
    @objc func healthDataDetectionTimerMethod() {
        if self.healthDataDetectionCount >= 30 {
            //取消定时器
            self.healthDataDetectionTimerInvalid()
            //此次健康数据接收结束
            self.currentReceiveCommandEndOver = true
        }
        self.healthDataDetectionCount += 1
    }
    
    // MARK: - 健康数据接收状态定时器销毁
    @objc func healthDataDetectionTimerInvalid() {
        if self.healthDataDetectionTimer != nil {
            self.healthDataDetectionTimer?.invalidate()
            self.healthDataDetectionTimer = nil
            //printLog("healthDataDetectionTimer 定时器销毁")
        }
    }
    
    
    // MARK: - 健康数据超时之后的方法
    @objc func receiveHealthDataTimeOut() {
        //printLog("receiveHealthDataTimeOut ->self.currentReceiveCommandEndOver =",self.currentReceiveCommandEndOver)
        if self.currentReceiveCommandEndOver {
            printLog("健康数据超时异常")
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncHealthData长度校验出错"))
            if let block = self.receiveSetSyncStepDataBlock {
                self.isStepDetailData = false
                self.signalCommandSemaphore()
                //printLog("健康数据5s未接收到 ->receiveSetSyncStepDataBlock")
                block.success(nil,.invalidLength)
            }
            if let block = self.receiveSetSyncSleepDataBlock {
                self.isSleepDetailData = false
                self.signalCommandSemaphore()
                //printLog("健康数据5s未接收到 ->receiveSetSyncSleepDataBlock")
                block.success(nil,.invalidLength)
            }
            if let block = self.receiveSetSyncHeartrateDataBlock {
                self.isHrDetailData = false
                self.signalCommandSemaphore()
                //printLog("健康数据5s未接收到 ->receiveSetSyncHeartrateDataBlock")
                block.success(nil,.invalidLength)
            }
        }
        
    }
    
    // MARK: - 检测信号量+1
    func signalCommandSemaphore() {
        if self.semaphoreCount < 1 {
            self.commandSemaphore.signal()
            self.semaphoreCount += 1
        }
        //printLog("signalCommandSemaphore -> self.semaphoreCount =",self.semaphoreCount)
    }
    
    // MARK: - 检测命令信号量重置
    func resetCommandSemaphore() {
        //目前SDK内部重置会在重连、断开连接、关闭蓝牙三个地方调用
        let resetCount = 1-self.semaphoreCount
        printLog("resetCommandSemaphore resetCount->",resetCount)
        for _ in 0..<resetCount {
            self.signalCommandSemaphore()
        }
    }
    
    // MARK: - 设备信息 0x00
    // MARK: - 获取设备名称 0x00
    @objc public func GetDeviceName(_ success:@escaping((String?,AntError)->Void)) {
        
        var val:[UInt8] = [0x00,0x00,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetDeviceNameBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDeviceNameBlock = success
        }else{
            
            success(nil,state)
        }
        
    }
    
    private func parseGetDeviceName(val:[UInt8],success:@escaping((String?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            let newVal = val[5...(val.count-1)]
            let newData = newVal.withUnsafeBufferPointer { (bytes) -> Data in
                return Data.init(buffer: bytes)
            }
            let string = String.init(data: newData, encoding: .utf8) ?? "nil"//String.init(format: "%@", newData as CVarArg)
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(string, .none)
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取固件版本号 0x02
    @objc public func GetFirmwareVersion(_ success:@escaping((String?,AntError)->Void)) {
        
        var val:[UInt8] = [0x00,0x02,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetFirmwareVersionBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetFirmwareVersionBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetFirmwareVersion(val:[UInt8],success:@escaping((String?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let versionData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                let byte = bytes.baseAddress! + 5
                return Data.init(bytes: byte, count: val.count-5)
            })
            
            let string = String.init(data: versionData, encoding: .utf8)
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string ?? ""))
            success(string,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取序列号 0x04
    @objc public func GetSerialNumber(_ success:@escaping((String?,AntError)->Void)) {
        
        var val:[UInt8] = [0x00,0x04,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetSerialNumberBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetSerialNumberBlock = success
        }else{
            
            success(nil,state)
        }
    }
    
    private func parseGetSerialNumber(val:[UInt8],success:@escaping((String?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let newVal = val[5...(val.count-1)]
            let newData = newVal.withUnsafeBufferPointer { (bytes) -> Data in
                return Data.init(buffer: bytes)
            }
            let string = String.init(data: newData, encoding: .utf8) ?? "nil"//String.init(format: "%@", newData as CVarArg)
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(string,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取mac地址 0x06
    @objc public func GetMac(_ success:@escaping((String?,AntError)->Void)) {
        
        var val:[UInt8] = [0x00,0x06,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetMacBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetMacBlock = success
        }else{
            
            success(nil,state)
            
        }
        
    }
    
    private func parseGetMac(val:[UInt8],success:@escaping((String?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let string = String.init(format: "%02x:%02x:%02x:%02x:%02x:%02x",val[10],val[9],val[8],val[7],val[6],val[5])
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(string,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取电量 0x08
    @objc public func GetBattery(_ success:@escaping((String?,AntError)->Void)) {
        
        var val:[UInt8] = [0x00,0x08,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetBatteryBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetBatteryBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetBattery(val:[UInt8],success:@escaping((String?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let string = String.init(format: "%02d",val[5])
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(string,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置时间 0x09
    @objc public func SetTime(time:Any? = nil,success:@escaping((AntError) -> Void)) {
        
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
        
        let calendar = NSCalendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        var val:[UInt8] = [0x00,0x09,0x0b,0x00,UInt8(year/100),UInt8(year%100),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetTimeBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetTimeBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetTime(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取设备支持的功能列表 0x0a
    @objc public func GetDeviceSupportList(_ success:@escaping((AntFunctionListModel?,AntError)->Void)) {
        
        
        var val:[UInt8] = [0x00,0x0a,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDeviceSupportListBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetDeviceSupportList(val:[UInt8],success:@escaping((AntFunctionListModel?,AntError)->Void)) {
        /*
         bit0 锻炼功能
         bit1 计步功能（24 小时详情）
         bit2 睡眠（24 小时详情）
         bit3 心率检测（24 小时详情）
         bit4 血压检测（24 小时详情）
         bit5 血氧检测（24 小时详情）
         Bit6 消息推送
         Bit7 来电提醒
         Bit8 闹钟提醒
         Bit9 久坐提醒
         Bit10 目标提醒
         Bit11 振动提醒
         Bit12 勿扰模式
         Bit13 电池电量百分比
         Bit14 天气
         Bit15 多国语言
         Bit16 背光时长
         Bit17 背光亮度
         Bit18 在线表盘
         Bit19 自定义表盘
         Bit20 指针表盘
         Bit21 ota 升级
         Bit22 生理周期
         Bit23 摇一摇拍照
         Bit24 抬腕亮屏
         Bit25 全天心率
         Bit26 拍照控制
         Bit27 音乐控制
         Bit28 查找手环
         Bit29 关机控制
         Bit30 重启控制
         Bit31 恢复出厂控制
         */
        let state = String.init(format: "%02x", val[4])
        var string = ""
        var funcList_1 = 0
        var funcList_2 = 0
        
        if val[4] == 1 {
            
            let listFunctionCount = val.count - 5
            for i in 0...listFunctionCount/8 {
                var listValue = 0
                for j in 0..<8 {
                    //在数组范围内
                    if 5+i*8+j < val.count {
                        listValue |= (Int(val[5+i*8+j]) << (j*8))
                    }
                }
                if i == 0 {
                    funcList_1 = listValue
                }else if i == 1 {
                    funcList_2 = listValue
                }
            }
            string = self.dealFuncListLog(result: funcList_1,index: 0)
            if funcList_2 > 0 {
                string += self.dealFuncListLog(result: funcList_2,index: 1)
            }
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = AntFunctionListModel.init(result: funcList_1)
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    func dealFuncListLog(result:Int,index:Int) -> String{
        var string = ""
        for i in 0..<64 {
            let state = (result >> i) & 0x01
            string += "\nbit\(i+index*64) = \(state)"
        }
        return string
    }
    
    // MARK: - 获取支持的功能详情 0x0c
    @objc public func GetDeviceSupportFunctionDetail(index:Int,success:@escaping(([String:Any],AntError)->Void)) {
        
        
        var val:[UInt8] = [0x00,0x0c,0x05,0x00,UInt8(index)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDeviceSupportFunctionDetailBlock = success
        }else{
            success([:],state)
        }
        
        self.receiveGetDeviceSupportFunctionDetailBlock = success
    }
    
    private func parseGetDeviceSupportFunctionDetail(val:[UInt8],success:@escaping(([String:Any],AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let string = String.init(format: "获取支持的功能详情内容待定")
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(["xxxx":"获取支持的功能详情内容待定"],.none)
            
        }else{
            success([:],.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取产品、固件、资源等版本信息 0x0E
    @objc public func GetDeviceOtaVersionInfo(_ success:@escaping(([String:Any],AntError)->Void)) {
        
        var val:[UInt8] = [0x00,0x0E,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        //self.receiveGetDeviceOtaVersionInfo = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDeviceOtaVersionInfo = success
        }else{
            success([:],state)
        }
    }
    
    private func parseGetDeviceOtaVersionInfo(val:[UInt8],success:@escaping(([String:Any],AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let product = (Int(val[5]) | Int(val[6]) << 8 )
            let project = (Int(val[7]) | Int(val[8]) << 8 )
            let boot = String.init(format: "%d.%d", val[9],val[10])
            let firmware = String.init(format: "%d.%d", val[11],val[12])
            let library = String.init(format: "%d.%d", val[13],val[14])
            let font = String.init(format: "%d.%d", val[15],val[16])
            
            let string = String.init(format: "\nproduct:%d\nproject:%d\nfirmware:%@\nlibrary:%@\nfont:%@", product,project,firmware,library,font)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(["product":"\(product)","project":"\(project)","boot":boot,"firmware":firmware,"library":library,"font":font],.none)
            
        }else{
            success([:],.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设备设置 0x01
    // MARK: - 获取个人信息 0x00
    @objc public func GetPersonalInformation(_ success:@escaping((AntPersonalModel?,AntError) -> Void)) {
        
        
        var val:[UInt8] = [0x01,0x00,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetPersonalInformationBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetPersonalInformationBlock = success
        }else{
            success(nil,state)
        }
        
    }
    
    private func parseGetPersonalInformation(val:[UInt8],success:@escaping((AntPersonalModel?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let age = val[5]
            let gender = val[6]
            let height = (Int(val[7]) | Int(val[8]) << 8)
            let weight = (Int(val[9]) | Int(val[10]) << 8)
            
            let heightString = String.init(format: "%.1f", Float(height)/10.0)
            let weightString = String.init(format: "%.1f", Float(weight)/10.0)
            
            let string = String.init(format: "年龄:%d,性别:%@,身高:%@,体重:%@", age,gender == 0 ? "男":"女",heightString,weightString)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = AntPersonalModel.init()
            model.age = Int(age)
            model.gender = gender == 0 ? false:true
            model.height = Float(height)/10.0
            model.weight = Float(weight)/10.0
            
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置个人信息 0x01
    @objc public func SetPersonalInformation(model:AntPersonalModel,success:@escaping((AntError) -> Void)) {
        
        let heightFloat = Int(model.height * 10)
        let weightFloat = Int(model.weight * 10)
        let gender = model.gender == false ? 0 : 1
        
        var val:[UInt8] = [0x01,0x01,0x0a,0x00,UInt8(model.age),UInt8(gender),UInt8((heightFloat ) & 0xff), UInt8((heightFloat >> 8) & 0xff),UInt8((weightFloat ) & 0xff), UInt8((weightFloat >> 8) & 0xff)]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetPersonalInformationBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetPersonalInformationBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetPersonalInformation(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取时间制式 0x02
    @objc public func GetTimeFormat(_ success:@escaping((Int,AntError) -> Void)) {
        
        
        var val:[UInt8] = [0x01,0x02,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetTimeFormatBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetTimeFormatBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetTimeFormat(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let timeFormat = val[5]
            let string = String.init(format: "时间制:%@",timeFormat == 0 ? "24小时制":"12小时制")
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(timeFormat),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置时间制式 0x03
    @objc public func SetTimeFormat(format:Int,success:@escaping((AntError) -> Void)) {
        
        
        var val:[UInt8] = [0x01,0x03,0x05,0x00,UInt8(format)]
        let data = Data.init(bytes: &val, count: val.count)
        
        //self.receiveSetTimeFormatBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetTimeFormatBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetTimeFormat(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let string = ""
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取公英制 0x04
    @objc public func GetMetricSystem(_ success:@escaping((Int,AntError) -> Void)) {
        
        
        var val:[UInt8] = [0x01,0x04,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetMetricSystemBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetMetricSystemBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetMetricSystem(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let metricSystem = val[5]
            let string = String.init(format: "公英制:%@",metricSystem == 0 ? "公制":"英制")
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(metricSystem),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置公英制 0x05
    @objc public func SetMetricSystem(metric:Int,success:@escaping((AntError) -> Void)) {
        
        
        var val:[UInt8] = [0x01,0x05,0x05,0x00,UInt8(metric)]
        let data = Data.init(bytes: &val, count: val.count)
        
        //self.receiveSetMetricSystemBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetMetricSystemBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetMetricSystem(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置天气 0x07
    @objc public func SetWeather(model:AntWeatherModel,success:@escaping((AntError) -> Void)) {
        
        var val:[Int8] = [
            0x01,
            0x07,
            0x0C,
            0x00,
            Int8(model.dayCount),
            Int8(model.type.rawValue),
            Int8(model.temp),
            Int8(model.airQuality),
            Int8(model.minTemp),
            Int8(model.maxTemp),
            Int8(model.tomorrowMinTemp),
            Int8(model.tomorrowMaxTemp),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetWeatherBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetWeatherBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetWeather(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置进入拍照模式 0x09
    @objc public func SetInterCamera(success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x09,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetInterCameraBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetInterCameraBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetInterCamera(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 寻找手环 0x0b
    @objc public func SetFindDevice(success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x0b,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetFindDeviceBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetFindDeviceBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetFindDevice(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取抬腕亮屏 0x0c
    @objc public func GetLightScreen(_ success:@escaping((Int,AntError) -> Void)) {
        
        
        var val:[UInt8] = [0x01,0x0c,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetLightScreenBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLightScreenBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetLightScreen(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let string = String.init(format: "%@",isOpen == 0 ? "关闭":"开启")
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(isOpen),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置抬腕亮屏 0x0d
    @objc public func SetLightScreen(isOpen:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x0d,
            0x05,
            0x00,
            UInt8(isOpen)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetLightScreenBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLightScreenBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetLightScreen(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取屏幕亮度 0x0e
    @objc public func GetScreenLevel(_ success:@escaping((Int,AntError) -> Void)) {
        
        var val:[UInt8] = [0x01,0x0e,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetScreenLevelBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetScreenLevelBlock = success
        }else{
            success(0,state)
        }
        
    }
    
    private func parseGetScreenLevel(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let level = val[5]
            let string = String.init(format: "亮度:%d",level)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(level),.none)
            
        }else{
            success(0,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置屏幕亮度 0x0f
    @objc public func SetScreenLevel(value:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x0f,
            0x05,
            0x00,
            UInt8(value),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetScreenLevelBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetScreenLevelBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetScreenLevel(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取屏幕时长 0x32
    @objc public func GetScreenTimeLong(_ success:@escaping((Int,AntError) -> Void)) {
        
        var val:[UInt8] = [0x01,0x32,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetScreenTimeLongBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetScreenTimeLongBlock = success
        }else{
            success(0,state)
        }
        
    }
    
    private func parseGetScreenTimeLong(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let timeLong = val[5]
            let string = String.init(format: "时长:%d",timeLong)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(timeLong),.none)
            
        }else{
            success(0,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置屏幕时长 0x33
    @objc public func SetScreenTimeLong(value:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x33,
            0x05,
            0x00,
            UInt8(value),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetScreenLevelBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetScreenTimeLongBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetScreenTimeLong(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取本地表盘 0x10
    @objc public func GetLocalDial(_ success:@escaping((Int,AntError) -> Void)) {
        
        var val:[UInt8] = [0x01,0x10,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetLocalDialBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLocalDialBlock = success
        }else{
            success(-1,state)
        }
    }
    
    private func parseGetLocalDial(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let index = val[5]
            let string = String.init(format: "本地表盘:%d",index)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(index),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置本地表盘 0x11
    @objc public func SetLocalDial(index:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x11,
            0x05,
            0x00,
            UInt8(index)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetLocalDialBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLocalDialBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetLocalDial(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取闹钟 0x12
    @objc public func GetAlarm(index:Int,success:@escaping((AntAlarmModel?,AntError) -> Void)) {
        
        var val:[UInt8] = [0x01,0x12,0x05,0x00,UInt8(index)]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetAlarmBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetAlarmBlock = success
        }else{
            success(nil,state)
        }
        
    }
    
    private func parseGetAlarm(val:[UInt8],success:@escaping((AntAlarmModel?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            //            let alarm = AntAlarmModel.init()
            
            let index = val[5]
            let repeatCount = val[6]
            let hour = val[7]
            let minute = val[8]
            let string = String.init(format: "序号:%d,重复:%d,小时:%d,分钟:%d",index,repeatCount,hour,minute)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = AntAlarmModel.init(dic: ["index":"\(index)","repeatCount":"\(repeatCount)","hour":String.init(format: "%02d", hour),"minute":String.init(format: "%02d", minute)])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置闹钟 0x13
    @objc public func SetAlarm(index:String,repeatCount:String,hour:String,minute:String,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x13,
            0x08,
            0x00,
            (UInt8(index) ?? 0),
            (UInt8(repeatCount) ?? 0),
            (UInt8(hour) ?? 0),
            (UInt8(minute) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetAlarmBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetAlarmBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetAlarm(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    @objc public func SetAlarmModel(model:AntAlarmModel,success:@escaping((AntError) -> Void)) {
        
        let index = model.alarmIndex
        var repeatCount = 0
        if model.alarmOpen {
            repeatCount += (1 << 7)
        }
        
        for i in stride(from: 0, to: model.alarmRepeatArray?.count ?? 0, by: 1) {
            let value = model.alarmRepeatArray?[i] ?? 0
            repeatCount += (value << i)
        }
        
        if model.alarmRepeatCount > 0 {
            repeatCount = model.alarmRepeatCount
        }
        
        let hour = model.alarmHour
        let minute = model.alarmMinute
        
        var val:[UInt8] = [
            0x01,
            0x13,
            0x08,
            0x00,
            UInt8(index),
            (UInt8(repeatCount)),
            (UInt8(hour) ?? 0),
            (UInt8(minute) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetAlarmBlock = success
        }else{
            success(state)
        }
        
    }
    
    // MARK: - 获取设备语言 0x14
    @objc public func GetDeviceLanguage(_ success:@escaping((Int,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x14,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetDeviceLanguageBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDeviceLanguageBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetDeviceLanguage(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let index = val[5]
            let string = String.init(format: "序号:%d",index)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(index),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置设备语言 0x15
    @objc public func SetDeviceLanguage(index:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x15,
            0x05,
            0x00,
            UInt8(index)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetDeviceLanguageBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDeviceLanguageBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetDeviceLanguage(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取目标步数 0x16
    @objc public func GetStepGoal(_ success:@escaping((Int,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x16,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetStepGoalBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetStepGoalBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetStepGoal(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let goalCount = (Int(val[5]) | Int(val[6]) << 8 | Int(val[7]) << 16 | Int(val[8]) << 24 )
            let string = String.init(format: "%d",goalCount)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(goalCount),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置目标步数 0x17
    @objc public func SetStepGoal(target:Int,success:@escaping((AntError) -> Void)) {
        
        let goal:Int = target
        var val:[UInt8] = [
            0x01,
            0x17,
            0x08,
            0x00,
            UInt8((goal ) & 0xff),
            UInt8((goal >> 8) & 0xff),
            UInt8((goal >> 16) & 0xff),
            UInt8((goal >> 24) & 0xff)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetStepGoalBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetStepGoalBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetStepGoal(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取显示方式 0x18
    @objc public func GetDispalyMode(_ success:@escaping((Int,AntError) -> Void)) {
        //vertical竖   horizontal横
        var val:[UInt8] = [
            0x01,
            0x18,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetDispalyModeBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDispalyModeBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetDispalyMode(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isV = val[5]
            let string = String.init(format: "%@",isV == 0 ? "0横屏":"1竖屏")
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,isV))
            success(Int(isV),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置显示方式 0x19
    @objc public func SetDispalyMode(isVertical:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x19,
            0x05,
            0x00,
            UInt8(isVertical)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetDispalyModeBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDispalyModeBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetDispalyMode(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取佩戴方式 0x1a
    @objc public func GetWearingWay(_ success:@escaping((Int,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x1a,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetWearingWayBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetWearingWayBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetWearingWay(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isLeft = val[5]
            let string = String.init(format: "%@",isLeft == 0 ? "0左手":"1右手")
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(isLeft),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置佩戴方式 0x1b
    @objc public func SetWearingWay(isLeftHand:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x1b,
            0x05,
            0x00,
            UInt8(isLeftHand)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetWearingWayBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetWearingWayBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetWearingWay(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置单次测量 0x1d
    @objc public func SetSingleMeasurement(type:Int,isOpen:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x1d,
            0x06,
            0x00,
            UInt8(type),
            UInt8(isOpen)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetSingleMeasurementBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSingleMeasurementBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetSingleMeasurement(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取锻炼模式 0x1e
    @objc public func GetExerciseMode(_ success:@escaping((Int,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x1e,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetExerciseModeBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetExerciseMode(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let type = val[5]
            let string = String.init(format: "%d",type)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(type),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置锻炼模式 0x1f
    @objc public func SetExerciseMode(type:Int,isOpen:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x1f,
            0x06,
            0x00,
            UInt8(type),
            UInt8(isOpen)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetExerciseModeBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetExerciseModeBlock = success
        }else{
            success(state)
        }
        
    }

    private func parseSetExerciseMode(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置设备模式 0x21
    @objc public func SetDeviceMode(type:Int,isOpen:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x21,
            0x06,
            0x00,
            UInt8(type),
            UInt8(isOpen)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetDeviceModeBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDeviceModeBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetDeviceMode(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置手机类型 0x25
    @objc public func SetPhoneMode(type:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x25,//
            0x05,
            0x00,
            UInt8(type),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetPhoneModeBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetPhoneModeBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetPhoneMode(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取天气单位 0x28
    @objc public func GetWeatherUnit(_ success:@escaping((Int,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x28,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetWeatherUnitBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetWeatherUnit(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isC = val[5]
            let string = String.init(format: "%@",isC == 0 ? "0摄氏度":"1华氏度")
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(isC),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置天气单位 0x29
    @objc public func SetWeatherUnit(type:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x29,
            0x05,
            0x00,
            UInt8(type),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetPhoneModeBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetWeatherUnitBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetWeatherUnit(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
        
        if val[4] == 1 {
            
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置实时数据上报开关 0x2B
    @objc public func SetReportRealtimeData(isOpen:Int,success:@escaping((AntError) -> Void)) {
        var val:[UInt8] = [
            0x01,
            0x2B,
            0x05,
            0x00,
            UInt8(isOpen),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        //self.receiveSetPhoneModeBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetReportRealtimeDataBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetReportRealtimeData(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取自定义表盘 0x2C
    @objc public func GetCustomDialEdit(_ success:@escaping((AntCustomDialModel?,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x2c,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetCustomDialEditBlock = success
        }else{
            success(nil,state)
        }
        
    }
    
    private func parseGetCustomDialEdit(val:[UInt8],success:@escaping((AntCustomDialModel?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let colorHex = String.init(format: "0x%02x", (Int(val[5]) | Int(val[6]) << 8 | Int(val[7]) << 16))
            let position = val[8]
            let timeUpType = val[9]
            let timeDownType = val[10]

            let hexString = colorHex.trimmingCharacters(in: .whitespacesAndNewlines)
            let scanner = Scanner(string: hexString)
             
            var colorInt: UInt32 = 0xFFFFFF
            scanner.scanHexInt32(&colorInt)
             
            let mask = 0x000000FF
            let r = Int(colorInt >> 16) & mask
            let g = Int(colorInt >> 8) & mask
            let b = Int(colorInt) & mask
             
            let red   = CGFloat(r) / 255.0
            let green = CGFloat(g) / 255.0
            let blue  = CGFloat(b) / 255.0
             
            let color = UIColor.init(red: red, green: green, blue: blue, alpha: 1)
            
            let string = String.init(format: "字体颜色:%@,显示位置:%d,时间上方:%d,时间下方:%d",colorHex,position,timeUpType,timeDownType)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = AntCustomDialModel.init(dic: ["colorHex":colorHex,"color":color,"positionType":"\(position)","timeUpType":"\(timeUpType)","timeDownType":"\(timeDownType)"])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置自定义表盘 0x2D
    @objc public func SetCustomDialEdit(color:UIColor,positionType:String,timeUpType:String,timeDownType:String,success:@escaping((AntError) -> Void)) {
        
        let uint8Max = CGFloat(UInt8.max)
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var alpha:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        let intR:UInt8 = UInt8(r * uint8Max)
        let intG:UInt8 = UInt8(g * uint8Max)
        let intB:UInt8 = UInt8(b * uint8Max)
        
        var val:[UInt8] = [
            0x01,
            0x2d,
            0x0a,
            0x00,
            intB,
            intG,
            intR,
            UInt8(positionType) ?? 0,
            UInt8(timeUpType) ?? 0,
            UInt8(timeDownType) ?? 0,
        ]
        let data = Data.init(bytes: &val, count: val.count)
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetCustomDialEditBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetCustomDialEdit(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
        
        if val[4] == 1 {
            
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    @objc public func SetCustomDialEdit(model:AntCustomDialModel,success:@escaping((AntError) -> Void)) {
        
        let uint8Max = CGFloat(UInt8.max)
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var alpha:CGFloat = 0
        model.color.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        let intR:UInt8 = UInt8(r * uint8Max)
        let intG:UInt8 = UInt8(g * uint8Max)
        let intB:UInt8 = UInt8(b * uint8Max)
        
        var val:[UInt8] = [
            0x01,
            0x2d,
            0x0a,
            0x00,
            intB,
            intG,
            intR,
            UInt8(model.positionType.rawValue),
            UInt8(model.timeUpType.rawValue),
            UInt8(model.timeDownType.rawValue),
        ]
        let data = Data.init(bytes: &val, count: val.count)
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetCustomDialEditBlock = success
        }else{
            success(state)
        }
        
    }
    
    // MARK: - 设置自定义表盘图片
    @objc public func SetCustomDialEdit(image:UIImage,progress:@escaping((Float) -> Void),success:@escaping((AntError) -> Void)) {
        
        self.GetCustonDialFrameSize { frameSuccess, error in
            if error == .none {
                let bigWidth = frameSuccess?.bigWidth ?? 0
                let bigheight = frameSuccess?.bigHeight ?? 0
                let smallWidth = frameSuccess?.smallWidth ?? 0
                let smallHeight = frameSuccess?.smallHeight ?? 0
                
                if CGFloat(bigWidth) == image.size.width && CGFloat(bigheight) == image.size.height {
                    self.screenBigWidth = bigWidth
                    self.screenBigHeight = bigheight
                    self.screenSmallWidth = smallWidth
                    self.screenSmallHeight = smallHeight
                    
                    let sendData = self.createSendDialOtaFile(image: image)
                    printLog("sendData.count =",sendData.count)
                    
//                    测试代码
//                    let path = NSHomeDirectory() + "/Documents/test.bin"
//                    if FileManager.createFile(filePath: path).isSuccess {
//
//                        FileManager.default.createFile(atPath: path, contents: sendData, attributes: nil)
//                    }
                    
                    self.setOtaStartUpgrade(type: 5, localFile: sendData, isContinue: false, progress: progress, success: success)
                }else{
                    printLog("图片尺寸跟设备尺寸不一致。请检查图片是否正确 image.size =",image.size)
                    success(.fail)
                }

            }else{
                printLog("获取设备尺寸失败")
                success(.fail)
            }
        }
    }

    func createSendDialOtaFile(image:UIImage) -> Data {
        
        let data = self.createSendImageFile(image: image)
        
        let date = Date.init()
        let calendar = NSCalendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        var otaFileHeadData:[UInt8] = Array.init()
        
        let oldCount = AntCommandModule.shareInstance.CRC32(data: data)
        let newCount = AntCommandModule.shareInstance.CRC32(data: data)
        
        //固定数据  0xAA,0x55,0x01,0x05
        let otaHead:[UInt8] = [0xAA,0x55,0x01,0x05]
        //日期/时间  6字节；格式YY-MM-DD HH:MM:SS(BCD码)
        let time:[UInt8] = [0x22,UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)]
        //压缩方式  1字节；0-无压缩 1-fastlz
        let type:UInt8 = 0
        //文件长度    4字节；未经过处理的原始文件长度
        let fileLength_old = [UInt8((data.count ) & 0xff),UInt8((data.count >> 8) & 0xff),UInt8((data.count >> 16) & 0xff),UInt8((data.count >> 24) & 0xff)]
        //文件完整性校验    4字节；对整个原始文件进行校验；CRC-32 多项式：0x104C11DB7、初始值：0xFFFFFFFF、结果异或值：0xFFFFFFFF、输入反转：true、输出反转：true
        let fileCrc32_old = [UInt8((oldCount) & 0xff),UInt8((oldCount >> 8) & 0xff),UInt8((oldCount >> 16) & 0xff),UInt8((oldCount >> 24) & 0xff)]
        //文件长度    4字节；处理完之后的文件长度
        let fileLength_new = [UInt8((data.count ) & 0xff),UInt8((data.count >> 8) & 0xff),UInt8((data.count >> 16) & 0xff),UInt8((data.count >> 24) & 0xff)]
        //文件完整性校验    4字节；对整个处理完之后的文件进行校验；CRC-32 多项式：0x104C11DB7、初始值：0xFFFFFFFF、结果异或值：0xFFFFFFFF、输入反转：true、输出反转：true
        let fileCrc32_new = [UInt8((newCount) & 0xff),UInt8((newCount >> 8) & 0xff),UInt8((newCount >> 16) & 0xff),UInt8((newCount >> 24) & 0xff)]
        //固定数据    固定33个0xFF;
        var arrLength_33:[UInt8] = Array.init()
        for _ in 0..<33 {
            arrLength_33.append(0xff)
        }
        //文件头完整性校验    4字节； CRC-32 多项式：0x104C11DB7、初始值：0xFFFFFFFF、结果异或值：0xFFFFFFFF、输入反转：true、输出反转：true
        otaFileHeadData.append(contentsOf: otaHead)
        otaFileHeadData.append(contentsOf: time)
        otaFileHeadData.append(type)
        otaFileHeadData.append(contentsOf: fileLength_old)
        otaFileHeadData.append(contentsOf: fileCrc32_old)
        otaFileHeadData.append(contentsOf: fileLength_new)
        otaFileHeadData.append(contentsOf: fileCrc32_new)
        otaFileHeadData.append(contentsOf: arrLength_33)
        
        let headCrc32 = AntCommandModule.shareInstance.CRC32(val: otaFileHeadData)
        let fileCrc32 = [UInt8((headCrc32) & 0xff),UInt8((headCrc32 >> 8) & 0xff),UInt8((headCrc32 >> 16) & 0xff),UInt8((headCrc32 >> 24) & 0xff)]
        
        otaFileHeadData.append(contentsOf: fileCrc32)
        
        var finalData = Data.init(bytes: &otaFileHeadData, count: otaFileHeadData.count)
        finalData.append(data)
        
        let count = finalData.count/1024+((finalData.count%1024) != 0 ? 1:0)
        var startCount = 0
        for i in stride(from: 0, to: count, by: 1) {
            let endCount = (i+1)*1024 < finalData.count ? (i+1)*1024 : finalData.count
            let subData = finalData[startCount..<endCount]
            //printLog("otaFile =",self.convertDataToHexStr(data: subData))
            startCount = endCount
        }
        return finalData
    }
    
    func createSendImageFile(image:UIImage) -> Data {
                
        let smallImage = image.changeSize(size: .init(width: self.screenSmallWidth, height: self.screenSmallHeight))
        let data_80_80:Data = self.createImageBin(image: smallImage)

        let bigImage = image//.changeSize(size: .init(width: 240, height: 240))
        let data_240_240:Data = self.createImageBin(image: bigImage)
        
//        let bigPath = NSHomeDirectory() + "/Documents/test_big.bin"
//        let smallPath = NSHomeDirectory() + "/Documents/test_small.bin"
//        if FileManager.createFile(filePath: bigPath).isSuccess {
//
//            FileManager.default.createFile(atPath: bigPath, contents: data_240_240, attributes: nil)
//        }
//        if FileManager.createFile(filePath: smallPath).isSuccess {
//            
//            FileManager.default.createFile(atPath: smallPath, contents: data_80_80, attributes: nil)
//        }
        
        let bgCount = 1372+data_80_80.count
        
        var imageFileHeadData:[UInt8] = Array.init()
        
        //3.1.1、配置信息(长度:372字节)
        //固定数据    0xA4,0x96,0x16,0xE6,0x84,0x87,0x57,0x00
        let imgHead:[UInt8] = [0xA4,0x96,0x16,0xE6,0x84,0x87,0x57,0x00]
        //表盘ID    2字节，小端
        let idArr:[UInt8] = [0x00,0x00]
        //固定数据    0x01,0x02,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x00
        let fixedArr:[UInt8] = [0x01,0x02,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x00]
        //图片宽度    2字节，小端
        let width:[UInt8] = [UInt8((self.screenBigWidth) & 0xff),UInt8((self.screenBigWidth >> 8) & 0xff)]
        //图片高度    2字节，小端
        let height:[UInt8] = [UInt8((self.screenBigHeight) & 0xff),UInt8((self.screenBigHeight >> 8) & 0xff)]
        //固定数据    固定348个0xFF
        var arrLength_348:[UInt8] = Array.init()
        for _ in 0..<348 {
            arrLength_348.append(0xff)
        }
        
        //3.1.2、图片地址数组(长度:1000字节)
        //固定数据    0x5C,0x05,0x00,0x00
        let addrHead:[UInt8] = [0x5C,0x05,0x00,0x00]
        //背景地址    4字节，小端 背景地址=1372+缩略图大小
        let bgAddr:[UInt8] = [UInt8((bgCount ) & 0xff),UInt8((bgCount >> 8) & 0xff),UInt8((bgCount >> 16) & 0xff),UInt8((bgCount >> 24) & 0xff)]
        //固定数据    固定992个0xFF
        var arrLength_992:[UInt8] = Array.init()
        for _ in 0..<992 {
            arrLength_992.append(0xff)
        }
        
        imageFileHeadData.append(contentsOf: imgHead)
        imageFileHeadData.append(contentsOf: idArr)
        imageFileHeadData.append(contentsOf: fixedArr)
        imageFileHeadData.append(contentsOf: width)
        imageFileHeadData.append(contentsOf: height)
        imageFileHeadData.append(contentsOf: arrLength_348)
        imageFileHeadData.append(contentsOf: addrHead)
        imageFileHeadData.append(contentsOf: bgAddr)
        imageFileHeadData.append(contentsOf: arrLength_992)
        
        var finalData = Data.init(bytes: &imageFileHeadData, count: imageFileHeadData.count)
        finalData.append(data_80_80)
        finalData.append(data_240_240)
        printLog("finalData.count =",finalData.count)
        
//        let count = finalData.count/1024+((finalData.count%1024) != 0 ? 1:0)
//        var startCount = 0
//        for i in stride(from: 0, to: count, by: 1) {
//            let endCount = (i+1)*1024 < finalData.count ? (i+1)*1024 : finalData.count
//            let subData = finalData[startCount..<endCount]
//            printLog("imageFile =",self.convertDataToHexStr(data: subData))
//            startCount = endCount
//        }

        return finalData
    }
    
    func createImageBin(image:UIImage) -> Data {
        
        //printLog("image =",image)
        var imgDataArray:[UInt8] = Array.init()
//        for i in 0..<Int(image.size.height) {
//            for j in 0..<Int(image.size.width) {
//                let dic = image.getPixelColor(pos: .init(x: i, y: j))
//                imgDataArray.append(contentsOf: self.colorRgb565(red: Int(dic.red), green: Int(dic.green), blue: Int(dic.blue)))
//            }
//        }
                
        let data = image.toByteArray()
        let count = data.count/4+((data.count%4) != 0 ? 1:0)
        var startCount = 0
        for i in stride(from: 0, to: count, by: 1) {

            let endCount = (i+1)*4 < data.count ? (i+1)*4 : data.count
            let subData = data[startCount..<endCount]

            startCount = endCount

            let subVal = subData.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: subData.count))
            }

            imgDataArray.append(contentsOf: self.colorRgb565(red: Int(subVal[1]), green: Int(subVal[2]), blue: Int(subVal[3])))

        }
        
        let imgData = Data.init(bytes: &imgDataArray, count: imgDataArray.count)
        return imgData
    }
    
    // MARK: - 设置电话状态 0x2E
    @objc public func SetPhoneState(state:String,success:@escaping((AntError) -> Void)) {
        var val:[UInt8] = [
            0x01,
            0x2f,
            0x05,
            0x00,
            (UInt8(state) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetPhoneStateBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetPhoneState(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
        
        if val[4] == 1 {
            
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: -  获取自定义表盘尺寸 0x30
    @objc public func GetCustonDialFrameSize(_ success:@escaping((AntDialFrameSizeModel?,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x30,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetCustonDialFrameSizeBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetCustonDialFrameSize(val:[UInt8],success:@escaping((AntDialFrameSizeModel?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let bigWidth = (Int(val[5]) | Int(val[6]) << 8)
            let bigheight = (Int(val[7]) | Int(val[8]) << 8)
            let smallWidth = (Int(val[9]) | Int(val[10]) << 8)
            let smallHeight = (Int(val[11]) | Int(val[12]) << 8)
            
            let string = String.init(format: "%dx%d,%dx%d",bigWidth,bigheight,smallWidth,smallHeight)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = AntDialFrameSizeModel.init(dic: ["bigWidth":"\(bigWidth)","bigHeight":"\(bigheight)","smallWidth":"\(smallWidth)","smallHeight":"\(smallHeight)"])
            
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取24小时心率监测 0x34
    @objc public func Get24HrMonitor(_ success:@escaping((Int,AntError) -> Void)) {
        var val:[UInt8] = [
            0x01,
            0x34,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGet24HrMonitorBlock = success
        }else{
            success(-1,state)
        }
    }
    
    private func parseGet24HrMonitor(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = String.init(format: "%d",val[5])
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,isOpen))
            success(Int(val[5]),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置24小时心率监测 0x35
    @objc public func Set24HrMonitor(isOpen:Int,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x35,
            0x05,
            0x00,
            UInt8(isOpen)
            
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetNotificationRemindBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSet24HrMonitorBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSet24HrMonitor(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设备提醒 0x02
    // MARK: - 获取消息提醒 0x00
    @objc public func GetNotificationRemind(_ success:@escaping(([Int],AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x00,//
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetNotificationRemindBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetNotificationRemindBlock = success
        }else{
            success([],state)
        }
        
    }
    
    private func parseGetNotificationRemind(val:[UInt8],success:@escaping(([Int],AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let openSwitch = (Int(val[5]) | Int(val[6]) << 8)
            let string = String.init(format: "%d",openSwitch)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            let arr = self.getNotificationTypeArrayWithIntString(countString: "\(openSwitch)")
            success(arr,.none)
            
        }else{
            success([],.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置消息提醒 0x01
    @objc public func SetNotificationRemind(isOpen:String,success:@escaping((AntError) -> Void)) {
        
        let switchCount = Int(isOpen) ?? 0
        var val:[UInt8] = [
            0x02,
            0x01,
            0x06,
            0x00,
            UInt8(switchCount & 0xff),
            UInt8((switchCount >> 8) & 0xff)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetNotificationRemindBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetNotificationRemindBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetNotificationRemind(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    @objc public func SetNotificationRemindArray(array:[Int],success:@escaping((AntError) -> Void)) {
        
        var switchCount = 0
        for i in stride(from: 0, to: array.count, by: 1) {
            switchCount += 1 << (array[i])
        }
        printLog("switchCount =",switchCount)
        var val:[UInt8] = [
            0x02,
            0x01,
            0x06,
            0x00,
            UInt8(switchCount & 0xff),
            UInt8((switchCount >> 8) & 0xff)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetNotificationRemindBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetNotificationRemindBlock = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 获取久坐提醒 0x02
    @objc public func GetSedentary(_ success:@escaping((AntSedentaryModel?,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x02,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetSedentaryBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetSedentaryBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetSedentary(val:[UInt8],success:@escaping((AntSedentaryModel?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let timeLong = val[6]
            let count = val[7]
            
            var modelArray:[AntStartEndTimeModel] = Array.init()
            
            for i in 0..<Int(count) {
                let model = AntStartEndTimeModel.init()
                model.startHour = Int(val[8+i*4])
                model.startMinute = Int(val[9+i*4])
                model.endHour = Int(val[10+i*4])
                model.endMinute = Int(val[11+i*4])
                modelArray.append(model)
            }
            
            let string = String.init(format: "开关:%d,时长:%d,时段数量：%d,时段数组",isOpen,timeLong,count,modelArray)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = AntSedentaryModel.init(dic: ["isOpen":"\(isOpen)","timeLong":"\(timeLong)","timeArray":modelArray])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置久坐提醒 0x03
    @objc public func SetSedentary(isOpen:String,timeLong:String,timeArray:[AntStartEndTimeModel],success:@escaping((AntError) -> Void)) {
        
        let headVal:[UInt8] = [
            0x02,
            0x03,
            UInt8(((timeArray.count * 4)+7) & 0xff),
            UInt8((((timeArray.count * 4)+7) >> 8) & 0xff),
            (UInt8(isOpen) ?? 0),
            (UInt8(timeLong) ?? 0),
            UInt8(timeArray.count),
        ]
        
        var timeVal:[UInt8] = Array.init()
        for i in 0..<timeArray.count {
            let model = timeArray[i]
            let startHour = UInt8(model.startHour)
            let startMinute = UInt8(model.startMinute)
            let endHour = UInt8(model.endHour)
            let endMinute = UInt8(model.endMinute)
            timeVal.append(startHour)
            timeVal.append(startMinute)
            timeVal.append(endHour)
            timeVal.append(endMinute)
        }
        
        let val:[UInt8] = headVal + timeVal
        
        let data = Data.init(bytes: val, count: val.count)
        
        //self.receiveSetSedentaryBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSedentaryBlock = success
        }else{
            success(state)
        }
    }
    
    @objc public func SetSedentary(model:AntSedentaryModel,success:@escaping((AntError) -> Void)) {
        
        let isOpen = model.isOpen
        let headVal:[UInt8] = [
            0x02,
            0x03,
            UInt8(((model.timeArray.count * 4)+7) & 0xff),
            UInt8((((model.timeArray.count * 4)+7) >> 8) & 0xff),
            isOpen == false ? 0:1,
            UInt8(model.timeLong),
            UInt8(model.timeArray.count),
        ]
        
        var timeVal:[UInt8] = Array.init()
        for i in 0..<model.timeArray.count {
            let timeModel = model.timeArray[i]
            let startHour = UInt8(timeModel.startHour)
            let startMinute = UInt8(timeModel.startMinute)
            let endHour = UInt8(timeModel.endHour)
            let endMinute = UInt8(timeModel.endMinute)
            timeVal.append(startHour)
            timeVal.append(startMinute)
            timeVal.append(endHour)
            timeVal.append(endMinute)
        }
        
        let val:[UInt8] = headVal + timeVal
        
        let data = Data.init(bytes: val, count: val.count)
        
        //self.receiveSetSedentaryBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSedentaryBlock = success
        }else{
            success(state)
        }
    }
    
    @objc public func SetSedentary(isOpen:String,timeLong:String,startHour:String,startMinute:String,endHour:String,endMinute:String,success:@escaping((AntError) -> Void)) {
        
        let val:[UInt8] = [
            0x02,
            0x03,
            11,
            0x00,
            (UInt8(isOpen) ?? 0),
            (UInt8(timeLong) ?? 0),
            0x01,
            (UInt8(startHour) ?? 0),
            (UInt8(startMinute) ?? 0),
            (UInt8(endHour) ?? 0),
            (UInt8(endMinute) ?? 0)
        ]
        
        let data = Data.init(bytes: val, count: val.count)
        
        //self.receiveSetSedentaryBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSedentaryBlock = success
        }else{
            success(state)
        }
    }
    
    
    private func parseSetSedentary(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取防丢提醒 0x04
    @objc public func GetLost(_ success:@escaping((Int,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x04,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetLostBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLostBlock = success
        }else{
            success(-1,state)
        }
    }
    
    private func parseGetLost(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let string = String.init(format: "开关:%d")
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(isOpen),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置防丢提醒 0x05
    @objc public func SetLost(isOpen:String,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x05,
            0x05,
            0x00,
            (UInt8(isOpen) ?? 0),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetLostBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLostBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetLost(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取勿扰 0x06
    @objc public func GetDoNotDisturb(_ success:@escaping((AntDoNotDisturbModel?,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x06,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetDoNotDisturbBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDoNotDisturbBlock = success
        }else{
            success(nil,state)
        }
        
    }
    
    private func parseGetDoNotDisturb(val:[UInt8],success:@escaping((AntDoNotDisturbModel?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let startHour = val[6]
            let startMinute = val[7]
            let endHour = val[8]
            let endMinute = val[9]
            let string = String.init(format: "开关:%d,开始时间：%d:%d,结束时间：%d:%d",isOpen,startHour,startMinute,endHour,endMinute)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = AntDoNotDisturbModel.init(dic: ["isOpen":"\(isOpen)","startHour":String.init(format: "%02d", startHour),"startMinute":String.init(format: "%02d", startMinute),"endHour":String.init(format: "%02d", endHour),"endMinute":String.init(format: "%02d", endMinute)])
            
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置勿扰 0x07
    @objc public func SetDoNotDisturb(isOpen:String,startHour:String,startMinute:String,endHour:String,endMinute:String,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x07,
            0x09,
            0x00,
            (UInt8(isOpen) ?? 0),
            (UInt8(startHour) ?? 0),
            (UInt8(startMinute) ?? 0),
            (UInt8(endHour) ?? 0),
            (UInt8(endMinute) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetDoNotDisturbBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDoNotDisturbBlock = success
        }else{
            success(state)
        }
    }
    
    @objc public func SetDoNotDisturb(model:AntDoNotDisturbModel,success:@escaping((AntError) -> Void)) {
        
        let isOpen = model.isOpen
        var val:[UInt8] = [
            0x02,
            0x07,
            0x09,
            0x00,
            isOpen == false ? 0:1,
            UInt8(model.timeModel.startHour),
            UInt8(model.timeModel.startMinute),
            UInt8(model.timeModel.endHour),
            UInt8(model.timeModel.endMinute)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        //self.receiveSetDoNotDisturbBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDoNotDisturbBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetDoNotDisturb(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取心率预警 0x08
    @objc public func GetHrWaring(_ success:@escaping((AntHrWaringModel?,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x08,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetHrWaringBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetHrWaringBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetHrWaring(val:[UInt8],success:@escaping((AntHrWaringModel?,AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let maxValue = val[6]
            let minValue = val[7]
            let string = String.init(format: "开关:%d,最大值：%d,最小值:%d",isOpen,maxValue,minValue)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = AntHrWaringModel.init(dic: ["isOpen":"\(isOpen)","maxHr":"\(maxValue)","minHr":"\(minValue)"])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置心率预警 0x09
    @objc public func SetHrWaring(isOpen:String,maxHr:String,minHr:String,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x09,
            0x07,
            0x00,
            (UInt8(isOpen) ?? 0),
            (UInt8(maxHr) ?? 0),
            (UInt8(minHr) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetHrWaringBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetHrWaringBlock = success
        }else{
            success(state)
        }
        
    }
    
    @objc public func SetHrWaring(model:AntHrWaringModel,success:@escaping((AntError) -> Void)) {
        
        let isOpen = model.isOpen
        var val:[UInt8] = [
            0x02,
            0x09,
            0x07,
            0x00,
            isOpen == false ? 0:1,
            UInt8(model.maxValue),
            UInt8(model.minValue)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetHrWaringBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetHrWaringBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetHrWaring(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取生理周期 0x0a
    @objc public func GetMenstrualCycle(_ success:@escaping(([String:Any],AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x0a,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetMenstrualCycleBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetMenstrualCycleBlock = success
        }else{
            success([:],state)
        }
    }
    
    private func parseGetMenstrualCycle(val:[UInt8],success:@escaping(([String:Any],AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let type = val[5]
            let cycleCount = val[6]
            let menstrualCount = val[7]
            let lastMonth = val[8]
            let lastDay = val[9]
            let remindHour = val[10]
            let remindMinute = val[11]
            let string = String.init(format: "提醒模式:%d,周期天数:%d,经期天数:%d,上次经期月:%d,上次经期日:%d,提醒时间：%d:%d",type,cycleCount,menstrualCount,lastMonth,lastDay,remindHour,remindMinute)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(["ttt":"\(string)"],.none)
            
        }else{
            success([:],.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置生理周期 0x0b
    @objc public func SetMenstrualCycle(type:String,cycleCount:String,menstrualCount:String,lastMonth:String,lastDay:String,remindHour:String,remindMinute:String,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x0b,
            0x05,
            0x00,
            (UInt8(type) ?? 0),
            (UInt8(cycleCount) ?? 0),
            (UInt8(menstrualCount) ?? 0),
            (UInt8(lastMonth) ?? 0),
            (UInt8(lastDay) ?? 0),
            (UInt8(remindHour) ?? 0),
            (UInt8(remindMinute) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetMenstrualCycleBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetMenstrualCycleBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetMenstrualCycle(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取洗手提醒 0x0c
    @objc public func GetWashHand(_ success:@escaping(([String:Any],AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x0c,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetWashHandBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetWashHandBlock = success
        }else{
            success([:],state)
        }
    }
    
    private func parseGetWashHand(val:[UInt8],success:@escaping(([String:Any],AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let startHour = val[6]
            let startMinute = val[7]
            let targetCount = val[8]
            let remindInterval = val[9]
            let string = String.init(format: "开关:%d,开始小时:%d,开始分钟:%d,目标次数:%d,提醒间隔:%d",isOpen,startHour,startMinute,targetCount,remindInterval)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(["ttt":"\(string)"],.none)
            
        }else{
            success([:],.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置洗手提醒 0x0d
    @objc public func SetWashHand(isOpen:String,startHour:String,startMinute:String,targetCount:String,remindInterval:String,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x0d,
            0x05,
            0x00,
            (UInt8(isOpen) ?? 0),
            (UInt8(startHour) ?? 0),
            (UInt8(startMinute) ?? 0),
            (UInt8(targetCount) ?? 0),
            (UInt8(remindInterval) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetWashHandBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetWashHandBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetWashHand(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取喝水提醒 0x0e
    @objc public func GetDrinkWater(_ success:@escaping(([String:Any],AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x0e,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveGetDrinkWaterBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDrinkWaterBlock = success
        }else{
            success([:],state)
        }
    }
    
    private func parseGetDrinkWater(val:[UInt8],success:@escaping(([String:Any],AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let startHour = val[6]
            let startMinute = val[7]
            let endHour = val[8]
            let endMinute = val[9]
            let remindCount = val[10]
            let remindInterval = val[11]
            let string = String.init(format: "开关:%d,开始时间：%d:%d,结束时间：%d:%d,提醒次数:%d,提醒间隔:%d",isOpen,startHour,startMinute,endHour,endMinute,remindCount,remindInterval)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(["ttt":"\(string)"],.none)
            
        }else{
            success([:],.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置喝水提醒 0x0f
    @objc public func SetDrinkWater(isOpen:String,startHour:String,startMinute:String,endHour:String,endMinute:String,remindCount:String,remindInterval:String,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x0f,
            0x0b,
            0x00,
            (UInt8(isOpen) ?? 0),
            (UInt8(startHour) ?? 0),
            (UInt8(startMinute) ?? 0),
            (UInt8(endHour) ?? 0),
            (UInt8(endMinute) ?? 0),
            (UInt8(remindCount) ?? 0),
            (UInt8(remindInterval) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetDrinkWaterBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDrinkWaterBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetDrinkWater(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 同步数据 0x03
    // MARK: - 同步健康数据 0x00
    @objc public func SetSyncHealthData(type:String,dayCount:String,success:@escaping((Any?,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x03,
            0x00,
            0x06,
            0x00,
            (UInt8(type) ?? 0),
            (UInt8(dayCount) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetSyncHealthDataBlock = (dayCount,type,success)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            if type == "1" {
                self.receiveSetSyncStepDataBlock = (dayCount,type,success)
                self.receiveSetSyncSleepDataBlock = nil
                self.receiveSetSyncHeartrateDataBlock = nil
            }else if type == "3" {
                self.receiveSetSyncSleepDataBlock = (dayCount,type,success)
                self.receiveSetSyncStepDataBlock = nil
                self.receiveSetSyncHeartrateDataBlock = nil
            }else if type == "2" {
                self.receiveSetSyncHeartrateDataBlock = (dayCount,type,success)
                self.receiveSetSyncStepDataBlock = nil
                self.receiveSetSyncSleepDataBlock = nil
            }
            
        }else{
            success([:],state)
        }
    }
    
    private func parseSetSyncHealthData(val:[UInt8],type:String,day:String,success:@escaping((Any?,AntError) -> Void)) {
        //        let state = String.init(format: "%02x", val[4])
        //        AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        AntSDKLog.writeStringToSDKLog(string: String.init(format: "parseSetSyncHealthData待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        
        var typeString = ""
        if type == "1" {
            
            typeString = "步数"
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "第%@天,类型:%@", day,typeString))
            var totalStep = 0
            var detailArray = [Int].init()
            for i in stride(from: 0, to: (val.count-12)/4, by: 1) {
                
                var stepTotalCount = 0
                var stepArray = [Int].init()
                
                for j in stride(from: 0, to: 2, by: 1) {
                    let step = (Int(val[i*4+j*2]) | Int(val[i*4+j*2+1]) << 8)
                    //printLog("step ->",step)
                    stepTotalCount += step
                    stepArray.append(step)
                    
                    totalStep += step
                    detailArray.append(step)
                }
                
                let str = String.init(format: "开始小时:%d,步数:%d", i,stepTotalCount)
                AntSDKLog.writeStringToSDKLog(string: str)
                AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@", stepArray))
            }
            
            var step = 0
            var calorie = 0
            var distance = 0
            if val.count >= 108 {
                printLog(val)
                
                step = (Int(val[96]) | Int(val[97]) << 8 | Int(val[98]) << 16 | Int(val[99]) << 24)
                calorie = (Int(val[100]) | Int(val[101]) << 8 | Int(val[102]) << 16 | Int(val[103]) << 24)
                distance = (Int(val[104]) | Int(val[105]) << 8 | Int(val[106]) << 16 | Int(val[107]) << 24)
            }
            
            let model = AntStepModel.init(dic: ["dayCount":day.count == 0 ? "0":day,"type":type,"totalStep":"\(totalStep)","detailArray":detailArray,"step":"\(step)","calorie":"\(calorie)","distance":"\(distance)"])
            success(model,.none)
            
        }else if type == "2" {
            
            typeString = "心率"
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "第%@天,类型:%@", day,typeString))
            
            var hrArray = [Int].init()
            for i in stride(from: 0, to: val.count, by: 1) {
                hrArray.append(Int(val[i]))
            }
            //printLog("hrArray =",hrArray)
            AntSDKLog.writeStringToSDKLog(string: "心率数据")
            AntSDKLog.writeStringToSDKLog(string: "\(hrArray)")
            
            let model = AntHrModel.init(dic: ["dayCount":day.count == 0 ? "0":day,"type":type,"detailArray":hrArray])
            success(model,.none)
            
        }else if type == "3" {
            
            typeString = "睡眠"
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "第%@天,类型:%@", day,typeString))
            
            var sleepArray = [Int].init()
            var originalArray:[Dictionary<String,Array<Int>>] = [[String:Array<Int>]].init()
            for i in stride(from: 0, to: val.count, by: 1) {
                let sleepCount = val[i]
                
                let state_1 = (sleepCount >> 7 & 0x1) << 1 | (sleepCount >> 6 & 0x1)
                let state_2 = (sleepCount >> 5 & 0x1) << 1 | (sleepCount >> 4 & 0x1)
                let state_3 = (sleepCount >> 3 & 0x1) << 1 | (sleepCount >> 2 & 0x1)
                let state_4 = (sleepCount >> 1 & 0x1) << 1 | (sleepCount >> 0 & 0x1)
                
                sleepArray.append(Int(state_1))
                sleepArray.append(Int(state_2))
                sleepArray.append(Int(state_3))
                sleepArray.append(Int(state_4))
                
                let string = String.init(format: "index_%d:0x%02x", i,sleepCount)
                let dic:Dictionary<String,Array<Int>> = [string:[Int(state_1),Int(state_2),Int(state_3),Int(state_4)]]
                originalArray.append(dic)
            }
            
            //{"end":"20:45","start":"20:09","total":"36","type":"1"}
            var modelArray = [[String:String]].init()
            var startIndex = 0
            var isAwakeSameState = false
            var islightSameState = false
            var isDeepSameState = false
            var isInvalidSameState = false
            var totalDeep = 0
            var totalLight = 0
            var totalAwake = 0
            var totalInvalid = 0
            for i in stride(from: 0, to: sleepArray.count-1, by: 1) {
                
                let state = sleepArray[i]
                let nextState = sleepArray[i+1]
                
                var start = ""
                var end = ""
                
                if state == 0 {//清醒
                    if !isAwakeSameState {
                        //开始记录第一个状态点
                        isAwakeSameState = true
                        startIndex = i
                    }
                    
                    if state != nextState {
                        //跟下一个状态不一致时保存开始到当前的序号
                        isAwakeSameState = false
                        if startIndex > 720 {
                            start = String.init(format: "%02d:%02d", (startIndex-720)/60,(startIndex-720)%60)
                        }else{
                            start = String.init(format: "%02d:%02d", (startIndex+720)/60,(startIndex+720)%60)
                        }
                        if i > 720 {
                            end = String.init(format: "%02d:%02d", (i-720)/60,(i-720)%60)
                        }else{
                            end = String.init(format: "%02d:%02d", (i+720)/60,(i+720)%60)
                        }
                        
                        let total = String.init(format: "%d", i - startIndex + 1)
                        let type = String.init(format: "%d", state)
                        
                        modelArray.append(["start":start,"end":end,"total":total,"type":type])
                    }
                    totalAwake += 1
                }else if state == 1 {//浅睡
                    if !islightSameState {
                        //开始记录第一个状态点
                        islightSameState = true
                        startIndex = i
                    }
                    
                    if state != nextState {
                        //跟下一个状态不一致时保存开始到当前的序号
                        islightSameState = false
                        if startIndex > 720 {
                            start = String.init(format: "%02d:%02d", (startIndex-720)/60,(startIndex-720)%60)
                        }else{
                            start = String.init(format: "%02d:%02d", (startIndex+720)/60,(startIndex+720)%60)
                        }
                        if i > 720 {
                            end = String.init(format: "%02d:%02d", (i-720)/60,(i-720)%60)
                        }else{
                            end = String.init(format: "%02d:%02d", (i+720)/60,(i+720)%60)
                        }
                        let total = String.init(format: "%d", i - startIndex + 1)
                        let type = String.init(format: "%d", state)
                        
                        modelArray.append(["start":start,"end":end,"total":total,"type":type])
                    }
                    totalLight += 1
                    
                }else if state == 2 {//深睡
                    if !isDeepSameState {
                        //开始记录第一个状态点
                        isDeepSameState = true
                        startIndex = i
                    }
                    
                    if state != nextState {
                        //跟下一个状态不一致时保存开始到当前的序号
                        isDeepSameState = false
                        if startIndex > 720 {
                            start = String.init(format: "%02d:%02d", (startIndex-720)/60,(startIndex-720)%60)
                        }else{
                            start = String.init(format: "%02d:%02d", (startIndex+720)/60,(startIndex+720)%60)
                        }
                        if i > 720 {
                            end = String.init(format: "%02d:%02d", (i-720)/60,(i-720)%60)
                        }else{
                            end = String.init(format: "%02d:%02d", (i+720)/60,(i+720)%60)
                        }
                        let total = String.init(format: "%d", i - startIndex + 1)
                        let type = String.init(format: "%d", state)
                        
                        modelArray.append(["start":start,"end":end,"total":total,"type":type])
                    }
                    totalDeep += 1
                }else{//无效数据
                    if !isInvalidSameState {
                        //开始记录第一个状态点
                        isInvalidSameState = true
                        startIndex = i
                    }
                    
                    if state != nextState {
                        //跟下一个状态不一致时保存开始到当前的序号
                        isInvalidSameState = false
                        if startIndex > 720 {
                            start = String.init(format: "%02d:%02d", (startIndex-720)/60,(startIndex-720)%60)
                        }else{
                            start = String.init(format: "%02d:%02d", (startIndex+720)/60,(startIndex+720)%60)
                        }
                        if i > 720 {
                            end = String.init(format: "%02d:%02d", (i-720)/60,(i-720)%60)
                        }else{
                            end = String.init(format: "%02d:%02d", (i+720)/60,(i+720)%60)
                        }
                        let total = String.init(format: "%d", i - startIndex + 1)
                        let type = String.init(format: "%d", state)
                        
                        //modelArray.append(["start":start,"end":end,"total":total,"type":type])
                    }
                    totalInvalid += 1
                }
                
                //循环到最后一个数据
                if i == sleepArray.count-2 {
                    //判断最后一个数据跟最后一个状态是否一致
                    if state == nextState {
                        //一致把最后一个状态加入最后一组数据
                        isAwakeSameState = false
                        if startIndex > 720 {
                            start = String.init(format: "%02d:%02d", (startIndex-720)/60,(startIndex-720)%60)
                        }else{
                            start = String.init(format: "%02d:%02d", (startIndex+720)/60,(startIndex+720)%60)
                        }
                        if i > 720 {
                            end = String.init(format: "%02d:%02d", (i-720+1)/60,(i-720+1)%60)
                        }else{
                            end = String.init(format: "%02d:%02d", (i+720+1)/60,(i+720+1)%60)
                        }
                        let total = String.init(format: "%d", (i+1) - startIndex + 1)
                        let type = String.init(format: "%d", state)
                        if type != "3" {
                            modelArray.append(["start":start,"end":end,"total":total,"type":type])
                        }
                    }else{
                        //不一致的，最后一个状态为单独一组
                        let start = String.init(format: "%02d:%02d", i/60,i%60)
                        let end = String.init(format: "%02d:%02d", (i+1)/60,(i+1)%60)
                        let total = String.init(format: "%d", 1)
                        let type = String.init(format: "%d", nextState)
                        if type != "3" {
                            modelArray.append(["start":start,"end":end,"total":total,"type":type])
                        }
                    }
                    if nextState == 0 {
                        totalAwake += 1
                    }else if nextState == 1 {
                        totalLight += 1
                    }else if nextState == 2 {
                        totalDeep += 1
                    }else{
                        totalInvalid += 1
                    }
                }
                
            }
            
            //AntSDKLog.writeStringToSDKLog(string: "原始数据")
            //AntSDKLog.writeStringToSDKLog(string: "\(originalArray)")
            //AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@\n\n\n", originalArray))
            
            //AntSDKLog.writeStringToSDKLog(string: "1440未整合数据")
            //AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@\n\n\n", sleepArray))
            
            //AntSDKLog.writeStringToSDKLog(string: "睡眠整合数据")
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "%@\n\n\n", modelArray))
            
            printLog("originalArray =",originalArray)
            printLog("sleepArray =",sleepArray,sleepArray.count)
            printLog("modelArray =",modelArray)
            
            let model = AntSleepModel.init(dic: ["dayCount":day.count == 0 ? "0":day,"type":type,"deep":"\(totalDeep)","light":"\(totalLight)","awake":"\(totalAwake)","originalArray":sleepArray,"detailArray":modelArray])
            success(model,.none)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 同步锻炼数据 0x02
    @objc public func SetSyncExerciseData(type:String,numberCount:String,success:@escaping((AntExerciseModel?,AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x03,
            0x02,
            0x06,
            0x00,
            (UInt8(type) ?? 0),
            (UInt8(numberCount) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        
        //self.receiveSetSyncExerciseDataBlock = success
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSyncExerciseDataBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseSetSyncExerciseData(val:[UInt8],success:@escaping((AntExerciseModel?,AntError) -> Void)) {
        //        let state = String.init(format: "%02x", val[4])
        //        AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
        //        success("\(state)")
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "parseSetSyncExerciseData待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        
        let startTime = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", (Int(val[0]) | (Int(val[1]) << 8)),val[2],val[3],val[5],val[6],val[7])
        let type = val[8]
        let hr = val[9]
        let validTimeLength = (Int(val[10]) | Int(val[11]) << 8)
        let step = (Int(val[12]) | Int(val[13]) << 8 | Int(val[14]) << 16 | Int(val[15]) << 24)
        let endTime = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", (Int(val[16]) | (Int(val[17]) << 8)),val[18],val[19],val[21],val[22],val[23])
        var calorie = 0
        var distance = 0
        if val.count >= 31 {
            calorie = (Int(val[24]) | Int(val[25]) << 8 | Int(val[26]) << 16 | Int(val[27]) << 24)
            distance = (Int(val[28]) | Int(val[29]) << 8 | Int(val[30]) << 16 | Int(val[31]) << 24)
        }
        
        let model = AntExerciseModel.init(dic: ["startTime":startTime,"type":"\(type)","hr":"\(hr)","validTimeLength":"\(validTimeLength)","step":"\(step)","endTime":"\(endTime)","calorie":"\(calorie)","distance":"\(distance)"])
        success(model,.none)
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 测试命令 0x04
    // MARK: - 关机 0x01
    @objc public func SetPowerTurnOff(success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x04,
            0x01,
            0x04,
            0x00
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        self.writeData(data: data)
        self.receiveSetPowerTurnOffBlock = success
        
        //        let state = self.writeDataAndBackError(data: data)
        //        if state == .none {
        //            self.receiveSetPowerTurnOffBlock = success
        //        }else{
        //            success(state)
        //        }
    }
    
    private func parseSetPowerTurnOff(val:[UInt8],success:@escaping((AntError) -> Void)) {
        if val.count > 4 {
            if val[4] == 1 {
                let state = String.init(format: "%02x", val[4])
                AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
                success(.none)
                
            }else{
                success(.invalidState)
            }
        }else{
            success(.invalidLength)
        }
        
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 恢复出厂设置 0x03
    @objc public func SetFactoryDataReset(success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x04,
            0x03,
            0x04,
            0x00
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        self.writeData(data: data)
        self.receiveSetFactoryDataResetBlock = success
        
        //        let state = self.writeDataAndBackError(data: data)
        //        if state == .none {
        //            self.receiveSetFactoryDataResetBlock = success
        //        }else{
        //            success(state)
        //        }
    }
    
    private func parseSetFactoryDataReset(val:[UInt8],success:@escaping((AntError) -> Void)) {
        
        if val[4] == 1 {
            
            let state = String.init(format: "%02x", val[4])
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 马达震动 0x05
    @objc public func SetMotorVibration(type:String,success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x04,
            0x05,
            0x05,
            0x00,
            (UInt8(type) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        self.writeData(data: data)
        self.receiveSetMotorVibrationBlock = success
        
        //        let state = self.writeDataAndBackError(data: data)
        //        if state == .none {
        //            self.receiveSetMotorVibrationBlock = success
        //        }else{
        //            success(state)
        //        }
        
    }
    
    private func parseSetMotorVibration(val:[UInt8],success:@escaping((AntError) -> Void)) {
        
        if val.count > 4 {
            if val[4] == 1 {
                
                let state = String.init(format: "%02x", val[4])
                AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
                success(.none)
                
            }else{
                success(.invalidState)
            }
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 重新启动0x07
    @objc public func setRestart(success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x04,
            0x07,
            0x04,
            0x00
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        self.writeData(data: data)
        self.receiveSetRestartBlock = success
        
        //        let state = self.writeDataAndBackError(data: data)
        //        if state == .none {
        //            self.receiveSetRestartBlock = success
        //        }else{
        //            success(state)
        //        }
    }
    
    private func parseSetRestart(val:[UInt8],success:@escaping((AntError) -> Void)) {
        
        if val[4] == 1 {
            
            let state = String.init(format: "%02x", val[4])
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 实时步数
    @objc public func ReportRealTimeStep(success:@escaping((AntStepModel?,AntError) -> Void)) {
        self.receiveReportRealTiemStepBlock = success
    }
    
    private func parseReportRealTimeStepData(val:[UInt8],success:@escaping((AntStepModel?,AntError) -> Void)) {
        
        if val[4] == 1 {
            
            let step = (Int(val[5]) | Int(val[6]) << 8 | Int(val[7]) << 16 | Int(val[8]) << 24)
            var distance = 0
            var calorie = 0
            
            if val.count >= 13 {
                calorie = (Int(val[11]) | Int(val[12]) << 8)//(Int(val[9]) | Int(val[10]) << 8 | Int(val[11]) << 16 | Int(val[12]) << 24)
                distance = (Int(val[9]) | Int(val[10]) << 8)//(Int(val[13]) | Int(val[14]) << 8 | Int(val[15]) << 16 | Int(val[16]) << 24)
            }
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "实时步数 步数:%d,距离:%d,卡路里:%d",step,distance,calorie))//
            
            let model = AntStepModel.init(dic: ["step":"\(step)","distance":"\(distance)","calorie":"\(calorie)"])
            success(model,.none)//
            
        }else{
            success(nil,.invalidState)
        }
        
    }
    
    // MARK: - 实时心率
    @objc public func ReportRealTimeHr(success:@escaping(([String:Any],AntError) -> Void)) {
        self.receiveReportRealTiemHrBlock = success
    }
    
    private func parseReportRealTimeHrData(val:[UInt8],success:@escaping(([String:Any],AntError) -> Void)) {
        
        if val[4] == 1 {
            
            let hr = val[5]
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "实时心率 心率:%d",hr))
            success(["hr":"\(hr)"],.none)
            
        }else{
            success([:],.invalidState)
        }
    }
    
    // MARK: - 单次测量结果
    @objc public func ReportSingleMeasurementResult(success:@escaping(([String:Any],AntError) -> Void)) {
        self.receiveReportSingleMeasurementResultBlock = success
    }
    
    private func parseReportSingleMeasurementResultData(val:[UInt8],success:@escaping(([String:Any],AntError) -> Void)) {
        
        let type = val[5]
        let value1 = val[6]
        let value2 = val[7]
        
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "单次测量结果 类型:%d,测量值1:%d,测量值2:%d",type,value1,value2))
        
        if val[4] == 2 {

            success(["type":"\(type)","value1":"\(value1)","value2":"\(value2)"],.none)
            
        }else{
            success(["type":"\(type)","value1":"\(value1)","value2":"\(value2)"],.fail)
        }
    }
    
    // MARK: - 单次锻炼结束标识
    @objc public func ReportSingleExerciseEnd(success:@escaping((AntError) -> Void)) {
        self.receiveReportSingleExerciseEndBlock = success
    }
    
    private func parseReportSingleExerciseEndData(val:[UInt8],success:@escaping((AntError) -> Void)) {
        
        if val[4] == 1 {
            
            success(.none)
            if val.count >= 6 {
                AntSDKLog.writeStringToSDKLog(string: String.init(format: "单次锻炼模式结束 类型:%d",val[5]))
            }
            
        }else{
            success(.invalidState)
        }
    }
    
    // MARK: - 找手机
    @objc public func ReportFindPhone(success:@escaping((AntError) -> Void)) {
        self.receiveReportFindPhoneBlock = success
    }
    
    private func parseReportFindPhoneData(val:[UInt8],success:@escaping((AntError) -> Void)) {
        
        success(.none)
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "找手机"))
        
    }
    
    // MARK: - 结束找手机
    @objc public func ReportEndFindPhone(success:@escaping((AntError) -> Void)) {
        self.receiveReportEndFindPhoneBlock = success
    }
    
    private func parseReportEndFindPhoneData(val:[UInt8],success:@escaping((AntError) -> Void)) {
        
        success(.none)
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "结束找手机"))
        
    }
    
    // MARK: - 拍照
    @objc public func ReportTakePictures(success:@escaping((AntError) -> Void)) {
        self.receiveReportTakePicturesBlock = success
    }
    
    private func parseReportTakePicturesData(val:[UInt8],success:@escaping((AntError) -> Void)) {
        
        success(.none)
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "拍照"))
        
    }
    
    // MARK: - 音乐控制
    @objc public func ReportMusicControl(success:@escaping((Int,AntError) -> Void)) {
        self.receiveReportMusicControlBlock = success
    }
    
    private func parseReportMusicControlData(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        
        let type = val[5]
        
        success(Int(type),.none)
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "音乐控制 类型:%d",type))
        
    }
    
    // MARK: - 来电控制 0x8E
    @objc public func ReportCallControl(success:@escaping((Int,AntError) -> Void)) {
        self.receiveReportCallControlBlock = success
    }
    
    private func parseReportCallControlData(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        
        let type = val[5]
        
        success(Int(type),.none)
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "来电控制 类型:%d",type))
        
    }
    
    // MARK: - 上报屏幕亮度 0x90
    @objc public func ReportScreenLevel(success:@escaping((Int,AntError) -> Void)) {
        self.receiveReportScreenLevelBlock = success
    }
    
    private func parseReportScreenLevel(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        
        let level = val[5]
        
        success(Int(level),.none)
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "屏幕亮度 等级:%d",level))
        
    }
    
    // MARK: - 上报屏幕时长 0x92
    @objc public func ReportScreenTimeLong(success:@escaping((Int,AntError) -> Void)) {
        self.receiveReportScreenTimeLongBlock = success
    }
    
    private func parseReportScreenTimeLong(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        
        let timeLong = val[5]
        
        success(Int(timeLong),.none)
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "亮屏时长:%d",timeLong))
        
    }
    
    // MARK: - 上报抬腕亮屏开关
    @objc public func ReportLightScreen(success:@escaping((Int,AntError) -> Void)) {
        self.receiveReportLightScreenBlock = success
    }
    
    private func parseReportLightScreen(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        
        let isOpen = val[5]
        
        success(Int(isOpen),.none)
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "抬腕亮屏 开关:%d",isOpen == 0 ? "关":"开"))
        
    }
    
    // MARK: - 上报设备震动开关
    @objc public func ReportDeviceVibration(success:@escaping((Int,AntError) -> Void)) {
        self.receiveReportDeviceVibrationBlock = success
    }
    
    private func parseReportDeviceVibration(val:[UInt8],success:@escaping((Int,AntError) -> Void)) {
        
        let isOpen = val[5]
        
        success(Int(isOpen),.none)
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "设备震动 开关:%d",isOpen == 0 ? "关":"开"))
        
    }
    
    // MARK: - ota升级
    @objc public func setOtaStartUpgrade(type:Int,localFile:Any,isContinue:Bool,progress:@escaping((Float) -> Void),success:@escaping((AntError) -> Void)) {
        //所有ota相关的命令不用信号量等待机制   直接用writeData方法发送
        if isContinue {
            self.setStartUpgrade(type: type, localFile: localFile, maxCount: 20,isContinue: true, progress: progress, success: success)
        }else{
            self.otaStartIndex = 0
            
            self.setStopUpgrade { error in
                if error == .none {
                    self.SetSubpackageInformationInteraction(maxSend: 1024, maxReceive: 1024) { subpackageInfo, error in
                        if error == .none {
                            if let maxSend = subpackageInfo["maxSend"] as? String {
                                if let maxCount = Int(maxSend) {
                                    if maxCount > 20 {
                                        self.setStartUpgrade(type: type, localFile: localFile, maxCount: maxCount,isContinue: false, progress: progress, success: success)
                                    }else{
                                        printLog("升级重启 获取长度异常 等待重新获取")
                                        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                                            self.setOtaStartUpgrade(type: type, localFile: localFile, isContinue: isContinue, progress: progress, success: success)
                                        }
                                    }
                                }else{
                                    printLog("升级重启 获取长度异常 等待重新获取")
                                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                                        self.setOtaStartUpgrade(type: type, localFile: localFile, isContinue: isContinue, progress: progress, success: success)
                                    }
                                }
                            }else{
                                printLog("升级重启 获取长度异常 等待重新获取")
                                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                                    self.setOtaStartUpgrade(type: type, localFile: localFile, isContinue: isContinue, progress: progress, success: success)
                                }
                            }
                        }
                    }
                }
            }
        }
            
        //        self.otaMaxSingleCount = 145
        //        self.otaPackageCount = 50
        //        let otaVal = self.otaData!.withUnsafeBytes{ (byte) -> [UInt8] in
        //            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
        //            return [UInt8](UnsafeBufferPointer.init(start: b, count: self.otaData!.count))
        //        }
        //        self.otaStartIndex += 1
        //        self.dealUpgradeData(maxSingleCount: self.otaMaxSingleCount, packageCount:  self.otaPackageCount, packageIndex: self.otaStartIndex-1, val: otaVal, progress: self.receiveSetStartUpgradeProgressBlock!, success: self.receiveSetStartUpgradeBlock!)
    }
    
    // MARK: - 分包信息交互(APP) 0x00
    @objc public func SetSubpackageInformationInteraction(maxSend:Int,maxReceive:Int,success:@escaping(([String:Any],AntError) -> Void)) {
        var val:[UInt8] = [
            0x05,
            0x00,
            0x0a,
            0x00,
            UInt8((maxSend ) & 0xff),
            UInt8((maxSend >> 8) & 0xff),
            UInt8((maxReceive ) & 0xff),
            UInt8((maxReceive >> 8) & 0xff)
        ]
        let check = CRC16(val: val)
        val.append(UInt8((check ) & 0xff))
        val.append(UInt8((check >> 8) & 0xff))
        
        let data = Data.init(bytes: &val, count: val.count)
        self.writeData(data: data)
        self.receiveSetSubpackageInformationInteractionBlock = success
        
    }
    
    private func parseSetSubpackageInformationInteractionData(val:[UInt8],success:@escaping(([String:Any],AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 0 {
            
            let maxSend = (Int(val[5]) | Int(val[6]) << 8)
            let maxReceive = (Int(val[7]) | Int(val[8]) << 8)
            printLog("最大发送长度 =",maxSend)
            printLog("最大接收长度 =",maxReceive)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(["maxSend":"\(maxSend)","maxReceive":"\(maxReceive)"],.none)
            
        }else{
            success([:],.invalidState)
        }
    }
    
    // MARK: - 分包信息交互(APP) 0x01
    @objc public func replySubpackageInformationInteraction(state:Int,maxSend:Int,maxReceive:Int,success:@escaping((AntError) -> Void)) {
        var val:[UInt8] = [
            0x05,
            0x81,
            0x0b,
            0x00,
            UInt8(state),
            UInt8((maxSend ) & 0xff),
            UInt8((maxSend >> 8) & 0xff),
            UInt8((maxReceive ) & 0xff),
            UInt8((maxReceive >> 8) & 0xff)
        ]
        let check = CRC16(val: val)
        val.append(UInt8((check ) & 0xff))
        val.append(UInt8((check >> 8) & 0xff))
        
        let data = Data.init(bytes: &val, count: val.count)
        self.writeData(data: data)
        //            self.receiveReplySubpackageInformationInteractionBlock = success
        
    }
    
    private func parseReplySubpackageInformationInteractionData(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
    }
    
    // MARK: - 开始升级
    @objc public func setStartUpgrade(type:Int,localFile:Any,maxCount:Int,isContinue:Bool,progress:@escaping((Float) -> Void),success:@escaping((AntError) -> Void)) {
        
        var fileData:Data?
        if localFile is String {
            let file:String = localFile as! String
            if file.hasPrefix("file://") {
                guard let url = URL.init(string: file) else {
                    //printLog("\(file) 格式错误")
                    return
                }
                fileData = try? Data.init(contentsOf: url)
            }else {
                let url = URL.init(fileURLWithPath: file)
                fileData = try? Data.init(contentsOf: url)
            }
        }
        if localFile is URL {
            let file:URL = localFile as! URL
            fileData = try! Data.init(contentsOf: file)
        }
        if localFile is Data {
            let file:Data = localFile as! Data
            fileData = file
        }
        
        if fileData == nil {
            printLog("\(localFile) 获取的文件为空，请检查路径")
            success(.notSupport)
            return
        }
        
        let fileLength = fileData!.count
        
        if isContinue {
            self.otaData = fileData!
            self.receiveSetStartUpgradeBlock = success
            self.receiveSetStartUpgradeProgressBlock = progress
            
            let otaVal = self.otaData!.withUnsafeBytes{ (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: self.otaData!.count))
            }
            
            if self.otaContinueDataLength != self.otaData!.count {
                printLog("setStartUpgrade ->otaContinueDataLength =",otaContinueDataLength,"self.otaData!.count =",self.otaData!.count,"数据不一致")
                success(.fail)
            }else{
                self.dealUpgradeData(maxSingleCount: self.otaMaxSingleCount, packageCount: self.otaPackageCount, packageIndex: self.otaStartIndex, val: otaVal, progress: progress, success: success)
            }
            
        }else{
            
            var val:[UInt8] = [
                0x05,
                0x02,
                0x0d,
                0x00,
                UInt8(type),
                UInt8((fileLength ) & 0xff),
                UInt8((fileLength >> 8) & 0xff),
                UInt8((fileLength >> 16) & 0xff),
                UInt8((fileLength >> 24) & 0xff),
                UInt8((maxCount ) & 0xff),
                UInt8((maxCount >> 8) & 0xff),
            ]
            
            let check = CRC16(val: val)
            val.append(UInt8((check ) & 0xff))
            val.append(UInt8((check >> 8) & 0xff))
            
            let data = Data.init(bytes: &val, count: val.count)
            self.writeData(data: data)
            self.receiveSetStartUpgradeBlock = success
            self.receiveSetStartUpgradeProgressBlock = progress
            self.otaData = fileData!
            
        }
        
    }
    
    private func parseSetStartUpgradeData(val:[UInt8],progress:@escaping((Float) -> Void),success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 0 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            
            let result = val[5]
            printLog("result =",result)
            if result == 0 {
                let maxSingleCount = (Int(val[6]) | Int(val[7]) << 8 )
                let packageCount = (Int(val[8]) | Int(val[9]) << 8 )
                
                self.otaMaxSingleCount = maxSingleCount
                self.otaPackageCount = packageCount
                
                let otaVal = self.otaData!.withUnsafeBytes{ (byte) -> [UInt8] in
                    let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: self.otaData!.count))
                }
                self.dealUpgradeData(maxSingleCount: maxSingleCount, packageCount: packageCount, packageIndex: 0, val: otaVal,progress: progress, success: success)
            }
            
        }else{
            success(.invalidState)
        }
    }
    
    private func dealUpgradeData(maxSingleCount:Int,packageCount:Int,packageIndex:Int,val:[UInt8],progress:@escaping((Float) -> Void),success:@escaping((AntError) -> Void)) {
        if val.count <= 0 {
            printLog("未知错误 val.count=0")
            success(.fail)
            return
        }
        //理论应该发送的长度
        let needSendCount = maxSingleCount * packageCount
        
        //开始截取的序号
        let startIndex = packageIndex == 0 ? 0 : ((packageIndex)*needSendCount)
        printLog("startIndex ->",startIndex)
        var totalLength = ((packageIndex+1)*needSendCount) > val.count ? (val.count-((packageIndex)*needSendCount)+((packageIndex)*needSendCount)) : ((packageIndex+1)*needSendCount)
        
        printLog("totalLength ->",totalLength)
        if startIndex >= totalLength {
            success(.fail)
            return
        }
        let sendVal:[UInt8] = Array.init(val[startIndex..<(totalLength)])
        printLog("待发组数据 sendData =",self.convertDataToSpaceHexStr(data: Data.init(bytes: sendVal, count: sendVal.count), isSend: true))
        
        //总包数
        let totalPackageCount = sendVal.count%maxSingleCount == 0 ? sendVal.count/maxSingleCount : (sendVal.count / maxSingleCount + 1)
        printLog("当前组总包数 totalPackageCount =",totalPackageCount)
        
        //给设备发的包序号，需要一直累加的
        let dataPackageIndex = packageIndex * packageCount
        
        for i in stride(from: 0, to: totalPackageCount, by: 1) {
            let index = i*maxSingleCount
            let endIndex = ((i+1)*maxSingleCount) > sendVal.count ? (sendVal.count-((i)*maxSingleCount)+i*maxSingleCount) : ((i+1)*maxSingleCount)
            printLog("index =",index,"endIndex =",endIndex)
            
            let sendPackageIndex = (dataPackageIndex+i)
            printLog("数据包号 =",sendPackageIndex)
            
            //分包数据长度 + 固定头部4byte + 包号4byte + crc16校验2byte
            let count = (endIndex-index) + 4 + 4 + 2
            
            let headData:[UInt8] = [0x05,0x04,UInt8(((count ) & 0xff)),UInt8((count >> 8) & 0xff),UInt8(sendPackageIndex & 0xff),UInt8((sendPackageIndex >> 8) & 0xff),UInt8((sendPackageIndex >> 16) & 0xff),UInt8((sendPackageIndex >> 24) & 0xff)]
            let contentData:[UInt8] = Array.init(sendVal[index..<(endIndex)])
            var send = headData + contentData
            let check = CRC16(val: send)
            send.append(UInt8((check ) & 0xff))
            send.append(UInt8((check >> 8) & 0xff))
            
            let data = Data.init(bytes: &send, count: send.count)
            self.writeData(data: data)
        }
        
        //组校验
        var checkVal:[UInt8] = [
            0x05,
            0x05,
            0x06,
            0x00
        ]
        
        let check = CRC16(val: checkVal)
        checkVal.append(UInt8((check ) & 0xff))
        checkVal.append(UInt8((check >> 8) & 0xff))
        
        let data = Data.init(bytes: &checkVal, count: checkVal.count)
        self.writeData(data: data)
        
        progress(Float(totalLength)/Float(val.count) * 100.0)
        printLog("当前数据组结束序号 ->",totalLength)
        AntSDKLog.writeStringToSDKLog(string: String.init(format: "当前数据组结束序号 ->:%d", totalLength))
    }
    
    // MARK: - 重发包号数据
    private func ResendUpgradeData(maxSingleCount:Int,packageCount:Int,resendVal:[UInt8],val:[UInt8],progress:@escaping((Float) -> Void),success:@escaping((AntError) -> Void)) {
        
        //重传总包数
        let resendTotalCount = (Int(resendVal[6]) | Int(resendVal[7]) << 8 | Int(resendVal[8]) << 16 | Int(resendVal[9]) << 24 )
        
        //单包长度
        let count = maxSingleCount + 4 + 4 + 2
        
        for i in stride(from: 0, to: resendTotalCount, by: 1) {
            
            //重传包序号
            let resendIndex = (Int(resendVal[10+i*4]) | Int(resendVal[11+i*4]) << 8 | Int(resendVal[12+i*4]) << 16 | Int(resendVal[13+i*4]) << 24 )
            printLog("重传包序号 =",resendIndex)
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "重传包序号 ->:%d", resendIndex))
            
            //取开始跟结束的index
            let startIndex = resendIndex*maxSingleCount
            let endIndex = ((resendIndex+1)*maxSingleCount) > val.count ? (val.count-((resendIndex)*maxSingleCount)+resendIndex*maxSingleCount) : ((resendIndex+1)*maxSingleCount)
            printLog("startIndex =",startIndex,"endIndex =",endIndex)
            
            //头数据
            let headData:[UInt8] = [0x05,0x04,UInt8(((count ) & 0xff)),UInt8((count >> 8) & 0xff),UInt8(resendIndex & 0xff),UInt8((resendIndex >> 8) & 0xff),UInt8((resendIndex >> 16) & 0xff),UInt8((resendIndex >> 24) & 0xff)]
            //重发的数据
            let contentData:[UInt8] = Array.init(val[startIndex..<(endIndex)])
            var send = headData + contentData
            let check = CRC16(val: send)
            send.append(UInt8((check ) & 0xff))
            send.append(UInt8((check >> 8) & 0xff))
            
            let data = Data.init(bytes: &send, count: send.count)
            self.writeData(data: data)
        }
        
        //组校验
        var checkVal:[UInt8] = [
            0x05,
            0x05,
            0x06,
            0x00
        ]
        
        let check = CRC16(val: checkVal)
        checkVal.append(UInt8((check ) & 0xff))
        checkVal.append(UInt8((check >> 8) & 0xff))
        
        let data = Data.init(bytes: &checkVal, count: checkVal.count)
        self.writeData(data: data)
        
    }
    
    // MARK: - 停止升级
    @objc public func setStopUpgrade(success:@escaping((AntError) -> Void)) {
        
        var val:[UInt8] = [
            0x05,
            0x03,
            0x06,
            0x00,
        ]
        
        let check = CRC16(val: val)
        val.append(UInt8((check ) & 0xff))
        val.append(UInt8((check >> 8) & 0xff))
        
        let data = Data.init(bytes: &val, count: val.count)
        
        self.writeData(data: data)
        self.receiveSetStopUpgradeBlock = success

    }
    
    private func parseSetStopUpgradeData(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 0 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            
            let result = val[5]
            printLog("result =",result)
            
            success(.none)
            
        }else{
            success(.invalidState)
        }
    }
    
    // MARK: - 升级结果
    private func parseGetUpgradeResultData(val:[UInt8],success:@escaping((AntError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 0 {
            
            AntSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            
            let result = val[5]
            printLog("result =",result)
            let type = val[6]
            let fileLength = (Int(val[7]) | Int(val[8]) << 8 | Int(val[9]) << 16 | Int(val[10]) << 24 )
            printLog("type =",type)
            printLog("fileLength =",fileLength)
            
            if result == 0 {
                success(.none)
            }else{
                success(.fail)
            }
            
        }else{
            success(.invalidState)
        }
    }
    
    @objc public func checkUpgradeState(success:@escaping(([String:Any],AntError) -> Void)) {
        var val:[UInt8] = [
            0x05,
            0x07,
            0x06,
            0x00,
        ]
        
        let check = CRC16(val: val)
        val.append(UInt8((check ) & 0xff))
        val.append(UInt8((check >> 8) & 0xff))
        
        let data = Data.init(bytes: &val, count: val.count)
        self.writeData(data: data)
        self.receiveCheckUpgradeStateBlock = success
        
    }
    
    // MARK: - 服务器相关的接口
    // MARK: - 获取OTA版本信息
    @objc public func getServerOtaDeviceInfo(success:@escaping(([String:Any],AntError) -> Void)) {
        
        var product = ""
        var project = ""
        var firmware = ""
        var library = ""
        var font = ""
        var mac = ""
        
        let group = DispatchGroup()
        group.enter()
        self.GetDeviceOtaVersionInfo { versionSuccess, error in
            if error == .none {
                printLog("GetDeviceOtaVersionInfo ->",versionSuccess)
                
                product = versionSuccess["product"] as! String
                project = versionSuccess["project"] as! String
                firmware = versionSuccess["firmware"] as! String
                library = versionSuccess["library"] as! String
                font = versionSuccess["font"] as! String
                
                let firmwareArray = firmware.components(separatedBy: ".")
                let firmwareFirst:String = firmwareArray.first ?? "0"
                let firmwareLast:String = firmwareArray.last ?? "0"
                let libraryArray = library.components(separatedBy: ".")
                let libraryFirst:String = libraryArray.first ?? "0"
                let libraryLast:String = libraryArray.last ?? "0"
                let fontArray = font.components(separatedBy: ".")
                let fontFirst:String = fontArray.first ?? "0"
                let fontLast:String = fontArray.last ?? "0"
            }
            group.leave()
        }

        group.enter()
        self.GetMac { macSuccess, error in
            if error == .none {
                if let string = macSuccess {
                    mac = string
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            
            //let url = AntNetworkManager.shareInstance.basicUrl+"/api/ota/get?"+String.init(format: "productId=%@&projectId=%@&firmwareId=%@&firmwareIdSecond=%@&imageId=%@&imageIdSecond=%@&fontId=%@&fontIdSecond=%@",product,project,firmwareFirst,firmwareLast,libraryFirst,libraryLast,fontFirst,fontLast)
            
            //http://www.antjuyi.com/api/ota/getNewVersionByAddress?productId=0&projectId=0&firmwareId=0.0&imageId=0.0&fontId=0.0&address=xx:xx:xx:xx:xx:xx
            let url = AntNetworkManager.shareInstance.basicUrl+"/api/ota/getNewVersionByAddress?"+String.init(format: "productId=%@&projectId=%@&firmwareId=%@&imageId=%@&fontId=%@&address=%@",product,project,firmware,library,font,mac)
            AntNetworkManager.shareInstance.get(url: url, isNeedToken: false) { info in
                printLog("info =",info)
                success(info,.none)
            } fail: { error in
                printLog("error =",error)
                success([:],.fail)
            }
        }

    }
    
    // MARK: - 自动获取OTA版本信息及下载升级
    var currentSyncOtaIndex = 0
    var lastCompleteOtaIndex = -1
    @objc public func setAutoServerOtaDeviceInfo(progress:@escaping((Float) -> Void),success:@escaping((AntError) -> Void)) {
        self.currentSyncOtaIndex = 0
        
        self.getServerOtaDeviceInfo { dic, error in
            //printLog("dic =",dic,"error =",dic)
            if error == .none {
                //["data": Optional([["version": Optional(0.2), "url": Optional(http://oss.antjuyi.com/ota/firmware/P22pro_v0.2.bin), "type": Optional(1)], ["type": Optional(2), "url": Optional(http://oss.antjuyi.com/ota/image/P22pro_v0.2.bin), "version": Optional(0.2)], ["version": Optional(0.2), "url": Optional(http://oss.antjuyi.com/ota/font/P22pro_v0.2.bin), "type": Optional(3)]]), "message": Optional(当前有新版本), "code": Optional(200)]
                
                if let code = dic["code"] as? Int {
                    if code == 200 {

                        if var dataArray = dic["data"] as? Array<Dictionary<String,Any>> {

                            //固件最先升级
                            if let index = dataArray.firstIndex(where: { dic in
                                if let type = dic["type"] as? Int {
                                    return type == 1
                                }
                                return false
                            }) {
                                let model = dataArray[index]
                                dataArray.remove(at: index)
                                dataArray.insert(model, at: 0)
                            }
                            
                            let versionArray = dataArray.map { versionDic in
                                versionDic["version"]
                            }
                            printLog("versionArray =",versionArray)

                            //ota过程中单个类型升级完之后断开的重连方法
                            self.syncOtaReconnectDevice {
                                printLog("--->>>  syncOtaReconnectDevice  ->isSyncOtaData =",self.isSyncOtaData,"self.currentSyncOtaIndex =",self.currentSyncOtaIndex,"self.lastCompleteOtaIndex =",self.lastCompleteOtaIndex)

                                do{
                                    if self.lastCompleteOtaIndex >= 0 {
                                        let completeVersionDic = dataArray[self.lastCompleteOtaIndex]
                                        //上一个升级完成的类型
                                        let completeType = completeVersionDic["type"] as! Int
                                        //获取到上一个完成的版本号
                                        let completeVersion = completeVersionDic["version"] as! String

                                        printLog("completeVersionDic =",completeVersionDic)
                                        printLog("上一个升级完成的类型 completeType=",completeType,"上一个完成的版本号 completeVersion =",completeVersion)

                                        if self.lastCompleteOtaIndex < dataArray.count-1 {
                                            self.serverOtaMethod(indexCount: self.lastCompleteOtaIndex+1, dataArray: dataArray, progress: progress, success: success)
                                            //升级过程中异常断开的走正常断开重连检测升级的流程。只有升级单个文件完成设备主动断开连接之后再从此ota重连方法发送下一个升级类型
                                            self.isSyncOtaData = false
                                        }
                                    }else{
                                        self.serverOtaMethod(indexCount: 0, dataArray: dataArray, progress: progress, success: success)
                                    }
                                }
                                
                                /*
                                self.GetDeviceOtaVersionInfo { versionSuccess, error in
                                    if error == .none {

                                        let firmware = versionSuccess["firmware"] as! String
                                        let library = versionSuccess["library"] as! String
                                        let font = versionSuccess["font"] as! String

                                        printLog("firmware ->",firmware)
                                        printLog("library ->",library)
                                        printLog("font ->",font)

                                        let completeVersionDic = dataArray[self.lastCompleteOtaIndex]
                                        //上一个升级完成的类型
                                        let completeType = completeVersionDic["type"] as! Int
                                        //获取到上一个完成的版本号
                                        let completeVersion = completeVersionDic["version"] as! String

                                        printLog("completeVersionDic =",completeVersionDic)
                                        printLog("上一个升级完成的类型 completeType=",completeType,"上一个完成的版本号 completeVersion =",completeVersion)

                                        //上一个升级完成之后如果版本号没有改变直接报错返回
                                        if completeType == 1 {

                                            if completeVersion != firmware {
                                                //关闭OTA重连
                                                self.isSyncOtaData = false
                                                //断开连接并打开正常的重连方法
                                                if let peripheral = self.peripheral {
                                                    AntBleManager.shareInstance.disconnect(peripheral: peripheral)
                                                }
                                                self.ant_ReconnectTimer?.fireDate = .distantPast
                                                success(.fail)
                                                return
                                            }

                                        }else if completeType == 2 {

                                            if completeVersion != library {
                                                //关闭OTA重连
                                                self.isSyncOtaData = false
                                                //断开连接并打开正常的重连方法
                                                if let peripheral = self.peripheral {
                                                    AntBleManager.shareInstance.disconnect(peripheral: peripheral)
                                                }
                                                self.ant_ReconnectTimer?.fireDate = .distantPast
                                                success(.fail)
                                                return
                                            }

                                        }else if completeType == 3 {

                                            if completeVersion != firmware {
                                                //关闭OTA重连
                                                self.isSyncOtaData = false
                                                //断开连接并打开正常的重连方法
                                                if let peripheral = self.peripheral {
                                                    AntBleManager.shareInstance.disconnect(peripheral: peripheral)
                                                }
                                                self.ant_ReconnectTimer?.fireDate = .distantPast
                                                success(.fail)
                                                return
                                            }

                                        }

                                        for i in 0..<dataArray.count {
                                            let dataDic = dataArray[i]
                                            let versionString = dataDic["version"] as! String
                                            let type_int = dataDic["type"] as! Int

                                            if type_int == 1 {

                                                if firmware != versionString {
                                                    if let index = dataArray.firstIndex(where: { dic in
                                                        if let type = dic["type"] as? Int {
                                                            return type == 1
                                                        }
                                                        return false
                                                    }) {
                                                        self.currentSyncOtaIndex = index
                                                    }
                                                    break
                                                }

                                            }
                                            if type_int == 2 {
                                                if library != versionString {
                                                    if let index = dataArray.firstIndex(where: { dic in
                                                        if let type = dic["type"] as? Int {
                                                            return type == 2
                                                        }
                                                        return false
                                                    }) {
                                                        self.currentSyncOtaIndex = index
                                                    }
                                                    break
                                                }
                                            }
                                            if type_int == 3 {
                                                if font != versionString {
                                                    if let index = dataArray.firstIndex(where: { dic in
                                                        if let type = dic["type"] as? Int {
                                                            return type == 3
                                                        }
                                                        return false
                                                    }) {
                                                        self.currentSyncOtaIndex = index
                                                    }
                                                    break
                                                }
                                            }
                                        }
                                        //只能放此处赋值，下面的方法会循环调用。如果下面方法优先调用了再断开重连，上一次成功的序号会改变导致获取错误
                                        self.lastCompleteOtaIndex = self.currentSyncOtaIndex
                                        self.serverOtaMethod(indexCount: self.currentSyncOtaIndex, dataArray: dataArray, progress: progress, success: success)
                                    }
                                }
                                 */
                            }
                            //只能放此处赋值，下面的方法会循环调用。如果下面方法优先调用了再断开重连，上一次成功的序号会改变导致获取错误
                            self.lastCompleteOtaIndex = -1
                            self.serverOtaMethod(indexCount: 0, dataArray: dataArray, progress: progress, success: success)
                            
                        }else{
                            printLog("data错误 ->",dic["data"] as Any)
                            success(.fail)
                        }

                    }else{
                        printLog("code != 200",dic["code"] as Any)
                        if code == 217 {
                            success(.none)
                        }else{
                            success(.fail)
                        }
                    }
                }else{
                    printLog("code错误 ->",dic["code"] as Any)
                    success(.fail)
                }
            }else{
                printLog("getServerOtaDeviceInfo error")
                success(.fail)
            }
        }
    }
    
    func serverOtaMethod(indexCount:Int,dataArray:Array<Dictionary<String,Any>>,progress:@escaping((Float) -> Void),success:@escaping((AntError) -> Void))
    {
        if indexCount < dataArray.count {
            let modelDic = dataArray[indexCount]

            let otaPath = NSHomeDirectory() + "/Documents/OtaFile/"

            if let url = modelDic["url"] as? String {

                self.downloadBinFile(url: url, filePath: otaPath) { fileString, error in

                    if error == .none {

                        if let type = modelDic["type"] as? Int {
                            if type > 0 && type < 4 {

                                self.setOtaStartUpgrade(type: type, localFile: fileString, isContinue: false) { otaProgress in

                                    DispatchQueue.main.async {

                                        let indexProgress:Float = Float(indexCount)/Float(dataArray.count)*100
                                        let currentProgress = indexProgress+otaProgress/Float(dataArray.count)

                                        printLog(" --- >>>  indexCount =",indexCount,"self.currentSyncOtaIndex ->",self.currentSyncOtaIndex,"otaProgress =",otaProgress,"indexProgress =",indexProgress)

                                        progress(currentProgress)
                                    }

                                } success: { otaError in

                                    DispatchQueue.main.async {
                                        if otaError == .none {

                                            if indexCount == dataArray.count - 1 {
                                                self.isSyncOtaData = false
                                                //断开连接并打开正常的重连方法
                                                if let peripheral = self.peripheral {
                                                    AntBleManager.shareInstance.disconnect(peripheral: peripheral)
                                                }
                                                self.ant_ReconnectTimer?.fireDate = .distantPast
                                                success(otaError)
                                            }else {
                                                self.isSyncOtaData = true
                                                self.currentSyncOtaIndex = indexCount+1
                                                self.lastCompleteOtaIndex = indexCount
                                                //固件升级完成之后会重启，过程比较久大概要10s+。这里给20s    因为重启完成之后还需要等待几秒再获取ota收发长度  不等待直接获取长度不对可能会闪退(正常1024，重启马上获取长度20)
                                                //DispatchQueue.main.asyncAfter(deadline: .now()+20) {
                                                    self.serverOtaMethod(indexCount: indexCount+1, dataArray: dataArray, progress: progress, success: success)
                                                //}

                                            }

                                        }else{
                                            printLog("ota失败 ->",modelDic["type"] as Any,modelDic["url"] as Any)
                                            success(.fail)
                                        }
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    printLog("type类型不在范围")
                                    success(.fail)
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                printLog("type错误 ->",modelDic["type"] as Any)
                                success(.fail)
                            }
                        }
                    }else{
                        success(error)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    printLog("url错误 ->",modelDic["url"] as Any)
                    success(.fail)
                }
            }
        }else{
            //服务器接口升级完之后要把此特殊的重连回调关掉  不关掉会导致正常的重连回调无法使用
            self.isSyncOtaData = false
            //断开连接并打开正常的重连方法
            if let peripheral = self.peripheral {
                AntBleManager.shareInstance.disconnect(peripheral: peripheral)
            }
            self.ant_ReconnectTimer?.fireDate = .distantPast
            success(.none)
        }
    }
    // MARK: - 同步服务器ota超时方法
    @objc func getOtaSyncStateFail() {
        if let block = self.receiveSetStartUpgradeBlock {
            block(.fail)
        }
    }
    
    // MARK: - 获取在线表盘  旧接口，获取全部
    @objc public func getOnlineDialList(success:@escaping(([AntOnlineDialModel],AntError) -> Void)) {
        let url = AntNetworkManager.shareInstance.basicUrl+"/api/online/get?"+String.init(format: "productId=%@&projectId=%@","0","0")
        /*
         {
             "code": 200,
             "message": "获取数据成功",
             "data": {
                 "list": [
                     {
                         "id": 1,
                         "imageUrl": "http://oss.antjuyi.com/online/240x240/image/v0.1_dial_1.png",
                         "binUrl": "http://oss.antjuyi.com/online/240x240/bin/v0.1_dial_1.bin",
                         "name": "春风得意",
                         "downloadCount": 1000,
                         "createAt": "2022-01-17T03:21:24.000+0000",
                         "updateAt": "2022-01-17T03:21:27.000+0000"
                     }
                 ]
             }
         }
         */
        AntNetworkManager.shareInstance.get(url: url, isNeedToken: false) { info in
                        
            let dic = info
            if let code = dic["code"] as? Int {
                if code == 200 {
                    
                    if let dataDic = dic["data"] as? Dictionary<String,Any> {
                        
                        var dialArray:[AntOnlineDialModel] = Array.init()
                        
                        if let listArray = dataDic["list"] as? Array<Dictionary<String,Any>> {
                            for item in listArray {
                                let dialModel = AntOnlineDialModel.init()
                                if let id = item["id"] as? Int {
                                    dialModel.dialId = id
                                }
                                if let imageUrl = item["imageUrl"] as? String {
                                    dialModel.dialImageUrl = imageUrl
                                }
                                if let binUrl = item["binUrl"] as? String {
                                    dialModel.dialFileUrl = binUrl
                                }
                                if let name = item["name"] as? String {
                                    dialModel.dialName = name
                                }
                                dialArray.append(dialModel)
                            }
                        }
                        success(dialArray,.none)
                    }else{
                        printLog("data错误 ->",dic["data"] as Any)
                        success([],.fail)
                    }
                    
                }else{
                    printLog("code != 200",dic["code"] as Any)
                    success([],.fail)
                }
            }else{
                printLog("code错误 ->",dic["code"] as Any)
                success([],.fail)
            }

        } fail: { error in
            printLog("error =",error as Any)
            success([],.fail)
        }
    }
    // MARK: - 获取在线表盘 新接口，分页获取
    @objc public func getOnlineDialList(pageIndex:Int,pageSize:Int,success:@escaping(([AntOnlineDialModel],AntError) -> Void)) {
    //http://www.antjuyi.com/api/online/getNew?productId=0&projectId=0&pageIndex=1&pageSize=5
        let url = AntNetworkManager.shareInstance.basicUrl+"/api/online/getNew?"+String.init(format: "productId=%@&projectId=%@&pageIndex=%d&pageSize=%d","0","0",pageIndex,pageSize)
        /*
         {
             "code": 200,
             "message": "获取数据成功",
             "data": {
                 "list": [
                     {
                         "id": 1,
                         "imageUrl": "http://oss.antjuyi.com/online/240x240/image/v0.1_dial_1.png",
                         "binUrl": "http://oss.antjuyi.com/online/240x240/bin/v0.1_dial_1.bin",
                         "name": "春风得意",
                         "downloadCount": 1000,
                         "createAt": "2022-01-17T03:21:24.000+0000",
                         "updateAt": "2022-01-17T03:21:27.000+0000"
                     }
                 ]
             }
         }
         */
        AntNetworkManager.shareInstance.get(url: url, isNeedToken: false) { info in
                        
            let dic = info
            if let code = dic["code"] as? Int {
                if code == 200 {
                    
                    if let dataDic = dic["data"] as? Dictionary<String,Any> {
                        
                        var dialArray:[AntOnlineDialModel] = Array.init()
                        
                        if let listArray = dataDic["list"] as? Array<Dictionary<String,Any>> {
                            for item in listArray {
                                let dialModel = AntOnlineDialModel.init()
                                if let id = item["id"] as? Int {
                                    dialModel.dialId = id
                                }
                                if let imageUrl = item["imageUrl"] as? String {
                                    dialModel.dialImageUrl = imageUrl
                                }
                                if let binUrl = item["binUrl"] as? String {
                                    dialModel.dialFileUrl = binUrl
                                }
                                if let name = item["name"] as? String {
                                    dialModel.dialName = name
                                }
                                dialArray.append(dialModel)
                            }
                        }
                        success(dialArray,.none)
                    }else{
                        printLog("data错误 ->",dic["data"] as Any)
                        success([],.fail)
                    }
                    
                }else{
                    printLog("code != 200",dic["code"] as Any)
                    success([],.fail)
                }
            }else{
                printLog("code错误 ->",dic["code"] as Any)
                success([],.fail)
            }

        } fail: { error in
            printLog("error =",error as Any)
            success([],.fail)
        }
    }
    
    // MARK: - 同步在线表盘
    @objc public func setOnlienDialFile(model:Any,progress:@escaping((Float) -> Void),success:@escaping((AntError) -> Void)) {
        
        let fileDownPath = NSHomeDirectory() + "/Documents/onlineDialFile/"
        
        if let model = model as? AntOnlineDialModel {
            
            if let url = model.dialFileUrl {
                self.downloadBinFile(url: url, filePath: fileDownPath) { fileString, error in
                    if error == .none {
                        
                        self.setOtaStartUpgrade(type: 4, localFile: fileString, isContinue: false, progress: progress, success: success)
                        
                    }
                }
            }else{
                printLog("参数model -> AntOnlineDialModel -> dialFileUrl错误")
                success(.fail)
            }

        }else if let model = model as? String {
            
            if model.lowercased().hasPrefix("file:") {
                
                self.setOtaStartUpgrade(type: 4, localFile: model, isContinue: false, progress: progress, success: success)
                
            }else if model.lowercased().hasPrefix("http") {
                
                self.downloadBinFile(url: model, filePath: fileDownPath) { fileString, error in
                    if error == .none {
                        
                        self.setOtaStartUpgrade(type: 4, localFile: fileString, isContinue: false, progress: progress, success: success)
                        
                    }
                }
            }else{
                printLog("参数model -> String -> 仅支持字符串头部字符包含file或http的")
                success(.fail)
            }
            
        }else if let model = model as? URL {
            
            if model.isFileURL {
                
                self.setOtaStartUpgrade(type: 4, localFile: model, isContinue: false, progress: progress, success: success)
                
            }else {
                
                self.downloadBinFile(url: String.init(format: "%@", model as CVarArg), filePath: fileDownPath) { fileString, error in
                    if error == .none {
                        
                        self.setOtaStartUpgrade(type: 4, localFile: fileString, isContinue: false, progress: progress, success: success)
                        
                    }
                }
            }
            
        }else if let model = model as? Data {
            
            self.setOtaStartUpgrade(type: 4, localFile: model, isContinue: false, progress: progress, success: success)
            
        }else{
            
            printLog("参数model -> 仅支持 AntOnlineDialModel 、String 、 URL 、Data 类型")
            success(.fail)
            
        }
        
    }
    
    func downloadBinFile(url:String,filePath:String,success:@escaping((String,AntError) -> Void)) {
        var fileString = ""
        let destination:Alamofire.DownloadRequest.DownloadFileDestination/*Destination*/ = { (_, _) in
            let binFileArray = url.components(separatedBy: "/")
            
            fileString = filePath + (binFileArray.last ?? "default.bin")
            let fileRUL = URL.init(fileURLWithPath: fileString)//拼接处完整的路径
            printLog("fileString ->",fileString)
            return (fileRUL, [.removePreviousFile,.createIntermediateDirectories])
        }
        
        printLog("开始下载 url ->",url,"destination ->",destination)
        Alamofire.download(url, to: destination).downloadProgress { (progress) in
            printLog("progress =",progress)
            DispatchQueue.main.async {
                
                if progress.fractionCompleted < 1 {
                    
                    //printLog("progress->",Float(progress.fractionCompleted))
                    printLog("下载progress->",progress)
                }
                
                if progress.fractionCompleted == 1 {
                    printLog("Completed")
                    
                }
            }
        }.response { (defaultDownloadResponse) in
            //printLog("defaultDownloadResponse = ",defaultDownloadResponse)
            if let destinationUrl = defaultDownloadResponse.destinationURL/*fileURL*/ {
                DispatchQueue.main.async {
                    
                    printLog("destination url -****",destinationUrl.absoluteString)
                    printLog("fileString -****",fileString)
                    
                    success(fileString,.none)
                    
                }
            }
            if let error = defaultDownloadResponse.error {
                DispatchQueue.main.async {
                    printLog("Download Failed with error - \(error)")
                    success("",.fail)
                }
            }
        }
    }
    
    @objc public func testMultiplePackages(cmdClass:Int,cmdId:Int,totalLength:Int,subpackageLength:Int) {
        
        var valArray:[UInt8] = []
        let count = totalLength
        for i in stride(from: 0, to: count/255+(count%255 == 0 ? 0:1), by: 1) {
            for j in stride(from: 0, to: 255, by: 1) {
                if i*255+j < count {
                    let val:UInt8 = UInt8.init(j)
                    valArray.append(val)
                }
            }
        }
        let data = valArray.withUnsafeBufferPointer { (bytes) -> Data in
            return Data.init(buffer: bytes)
        }
        printLog("dasdasdasdasa ->",data)
        let indexCount = 1 + (data.count + 8) / 16 //应该能接收的所有包序号
        let lastLength = (data.count - 7) % 16
        printLog("indexCount ->",indexCount,"lastLength->",lastLength)
        
        if subpackageLength == 0 {
            
            let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
            AntSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
            printLog("send",dataString)
            //            printLog("((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0)",((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? "withoutResponse" : "withResponse")
            self.peripheral?.writeValue(data, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
            
        }else{
            
            for i in stride(from: 0, to: indexCount, by: 1) {
                var valArray:[UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                valArray[0] = UInt8(cmdClass)
                valArray[1] = UInt8(cmdId)
                if i == 0 {
                    valArray[2] = UInt8((data.count ) & 0xff)
                    valArray[3] = UInt8((data.count >> 8) & 0xff)
                    valArray[4] = UInt8((data.count >> 16) & 0xff)
                    valArray[5] = UInt8((data.count >> 24) & 0xff)
                    valArray[6] = 1
                    valArray[7] = 1
                    valArray[8] = UInt8((i) & 0xff)
                    valArray[9] = UInt8((i >> 8) & 0xff)
                    valArray[10] = UInt8((CRC16(data: data) & 0xff) & 0xff)
                    valArray[11] = UInt8(CRC16(data: data) >> 8 )
                    valArray[12] = UInt8(lastLength)
                    let vArray = data.withUnsafeBytes { (byte) -> [UInt8] in
                        let b = (byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                        return [UInt8](UnsafeBufferPointer.init(start: b, count: 7))
                    }
                    valArray.replaceSubrange(valArray.index(0, offsetBy: 13)..<valArray.endIndex, with: vArray)
                    
                }else{
                    
                    valArray[2] = UInt8(i & 0xff)
                    valArray[3] = UInt8((i >> 8) & 0xff)
                    
                    let vArray = data.withUnsafeBytes { (byte) -> [UInt8] in
                        
                        if data.count - ((i-1)*16) - 7 >= 16 {
                            let b = (byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))! + (i-1)*16+7
                            return [UInt8](UnsafeBufferPointer.init(start: b, count: 16))
                        }else{
                            let b = (byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))! + (i-1)*16+7
                            return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count - ((i-1)*16) - 7))
                        }
                    }
                    valArray.replaceSubrange(valArray.index(0, offsetBy: 4)..<valArray.endIndex, with: vArray)
                }
                
                let newData = valArray.withUnsafeBufferPointer { (bytes) -> Data in
                    return Data.init(buffer: bytes)
                }
                
                let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: newData,isSend: true))
                AntSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
                printLog("send",dataString)
                //                printLog("((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0)",((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? "withoutResponse" : "withResponse")
                self.peripheral?.writeValue(newData, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
                Thread.sleep(forTimeInterval: 0.2)
            }
        }
        
    }
    
    @objc public func testUtf8StringData(cmdClass: Int, cmdId: Int,type:String, sendString:String) {
        
        for scalar in sendString.unicodeScalars {
            printLog(String.init(scalar.value, radix: 16, uppercase: false))
        }
        
        let data:Data = sendString.data(using: .utf8) ?? Data.init()
        printLog("data ->",String.init(format: "%@", data as CVarArg))
        
        printLog("crc16 =",self.CRC16(data: data))
        
        let str = String.init(data: data, encoding: .utf8)
        printLog("str ->",str!)
        
        let indexCount = 1 + (data.count + 8) / 16//应该能接收的所有包序号
        let lastLength = (data.count - 7) > 0 ? ((data.count - 7) % 16) : data.count
        
        for i in stride(from: 0, to: indexCount, by: 1) {
            var valArray:[UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]//Array.init()//(arrayLiteral: 20)
            valArray[0] = UInt8(cmdClass)
            valArray[1] = UInt8(cmdId)
            if i == 0 {
                valArray[2] = UInt8((data.count ) & 0xff)
                valArray[3] = UInt8((data.count >> 8) & 0xff)
                valArray[4] = UInt8((data.count >> 16) & 0xff)
                valArray[5] = UInt8((data.count >> 24) & 0xff)
                valArray[6] = 1
                valArray[7] = UInt8(type) ?? 1
                valArray[8] = UInt8((i) & 0xff)
                valArray[9] = UInt8((i >> 8) & 0xff)
                valArray[10] = 1
                valArray[11] = 1
                valArray[12] = UInt8(lastLength)
                let vArray = data.withUnsafeBytes { (byte) -> [UInt8] in
                    let b = (byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: 7))
                }
                valArray.replaceSubrange(valArray.index(0, offsetBy: 13)..<valArray.endIndex, with: vArray)
                
            }else{
                
                valArray[2] = UInt8(i & 0xff)
                valArray[3] = UInt8((i >> 8) & 0xff)
                
                let vArray = data.withUnsafeBytes { (byte) -> [UInt8] in
                    
                    if data.count - ((i-1)*16) - 7 >= 16 {
                        let b = (byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))! + (i-1)*16+7
                        return [UInt8](UnsafeBufferPointer.init(start: b, count: 16))
                    }else{
                        let b = (byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))! + (i-1)*16+7
                        return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count - ((i-1)*16) - 7))
                    }
                }
                valArray.replaceSubrange(valArray.index(0, offsetBy: 4)..<valArray.endIndex, with: vArray)
            }
            
            let newData = valArray.withUnsafeBufferPointer { (bytes) -> Data in
                return Data.init(buffer: bytes)
            }
            
            let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: newData,isSend: true))
            AntSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
            printLog("send",dataString)
            //                printLog("((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0)",((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? "withoutResponse" : "withResponse")
            self.peripheral?.writeValue(newData, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
    
    @objc public func testUnicodeStringData(cmdClass: Int, cmdId: Int, type:String, sendString:String) {
        var value:[UInt8] = Array.init()
        for scalar in sendString.unicodeScalars {
            let str = String.init(scalar.value, radix: 16, uppercase: false)
            printLog(str)
            let val = self.hexStringToInt(from: str)
            printLog("val ->",val)
            if val <= 0xff  {
                let v:UInt8 = UInt8(val)
                value.append(v)
            }else if val > 0xff && val <= 0xffff {
                let v1:UInt8 = UInt8((val >> 8) & 0xff)
                value.append(v1)
                let v:UInt8 = UInt8((val) & 0xff)
                value.append(v)
            }else if val > 0xffff && val <= 0xffffff {
                let v2:UInt8 = UInt8((val >> 16) & 0xff)
                value.append(v2)
                let v1:UInt8 = UInt8((val >> 8) & 0xff)
                value.append(v1)
                let v:UInt8 = UInt8((val) & 0xff)
                value.append(v)
            }else if val > 0xffffff{
                let v3:UInt8 = UInt8((val >> 24) & 0xff)
                value.append(v3)
                let v2:UInt8 = UInt8((val >> 16) & 0xff)
                value.append(v2)
                let v1:UInt8 = UInt8((val >> 8) & 0xff)
                value.append(v1)
                let v:UInt8 = UInt8((val) & 0xff)
                value.append(v)
            }
            
        }
        
        let data = value.withUnsafeBufferPointer { (bytes) -> Data in
            return Data.init(buffer: bytes)
        }
        
        printLog("valueData =",String.init(format: "%@", data as CVarArg))
        
        let indexCount = 1 + (data.count + 8) / 16//应该能接收的所有包序号
        let lastLength = (data.count - 7) > 0 ? ((data.count - 7) % 16) : data.count
        
        for i in stride(from: 0, to: indexCount, by: 1) {
            var valArray:[UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]//Array.init()//(arrayLiteral: 20)
            valArray[0] = UInt8(cmdClass)
            valArray[1] = UInt8(cmdId)
            if i == 0 {
                valArray[2] = UInt8((data.count ) & 0xff)
                valArray[3] = UInt8((data.count >> 8) & 0xff)
                valArray[4] = UInt8((data.count >> 16) & 0xff)
                valArray[5] = UInt8((data.count >> 24) & 0xff)
                valArray[6] = 1
                valArray[7] = UInt8(type) ?? 1
                valArray[8] = UInt8((i) & 0xff)
                valArray[9] = UInt8((i >> 8) & 0xff)
                valArray[10] = 1
                valArray[11] = 1
                valArray[12] = UInt8(lastLength)
                let vArray = data.withUnsafeBytes { (byte) -> [UInt8] in
                    let b = (byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: 7))
                }
                valArray.replaceSubrange(valArray.index(0, offsetBy: 13)..<valArray.endIndex, with: vArray)
                
            }else{
                
                valArray[2] = UInt8(i & 0xff)
                valArray[3] = UInt8((i >> 8) & 0xff)
                
                let vArray = data.withUnsafeBytes { (byte) -> [UInt8] in
                    
                    if data.count - ((i-1)*16) - 7 >= 16 {
                        let b = (byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))! + (i-1)*16+7
                        return [UInt8](UnsafeBufferPointer.init(start: b, count: 16))
                    }else{
                        let b = (byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))! + (i-1)*16+7
                        return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count - ((i-1)*16) - 7))
                    }
                }
                valArray.replaceSubrange(valArray.index(0, offsetBy: 4)..<valArray.endIndex, with: vArray)
            }
            
            let newData = valArray.withUnsafeBufferPointer { (bytes) -> Data in
                return Data.init(buffer: bytes)
            }
            
            let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: newData,isSend: true))
            AntSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
            printLog("send",dataString)
            //                printLog("((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0)",((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? "withoutResponse" : "withResponse")
            self.peripheral?.writeValue(newData, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
}
