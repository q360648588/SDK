//
//  AndXuCommandModule.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2021/7/5.
//

import UIKit
import CoreBluetooth
import Alamofire
import JL_BLEKit
import CoreLocation

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
    
    private var healthDataDetectionTimer:Timer?//检测健康数据接收超时的定时器
    private var healthDataDetectionCount = 0
    
    private var screenBigWidth = 0
    private var screenBigHeight = 0
    private var screenSmallWidth = 0
    private var screenSmallHeight = 0
    
    private var otaVersionInfo:[String:Any]?
    private var macString:String?
    
    var receiveGetDeviceNameBlock:((String?,ZyError) -> Void)?
    var receiveGetFirmwareVersionBlock:((String?,ZyError) -> Void)?
    var receiveGetMacBlock:((String?,ZyError) -> Void)?
    var receivePrivateGetMacBlock:((String?,ZyError) -> Void)?
    var receiveGetBatteryBlock:((String?,ZyError) -> Void)?
    var receiveSetTimeBlock:((ZyError) -> Void)?
    var receiveGetDeviceSupportListBlock:((ZyFunctionListModel?,ZyError) -> Void)?
    var receiveGetDeviceSupportFunctionDetailBlock:(([String:Any],ZyError) -> Void)?
    var receiveGetDeviceOtaVersionInfo:(([String:Any],ZyError) -> Void)?
    var receivePrivateGetDeviceOtaVersionInfo:(([String:Any],ZyError) -> Void)?
    var receiveGetSerialNumberBlock:((String?,ZyError) -> Void)?
    var receiveGetPersonalInformationBlock:((ZyPersonalModel?,ZyError) -> Void)?
    var receiveSetPersonalInformationBlock:((ZyError) -> Void)?
    var receiveGetTimeFormatBlock:((Int,ZyError) -> Void)?
    var receiveSetTimeFormatBlock:((ZyError) -> Void)?
    var receiveGetMetricSystemBlock:((Int,ZyError) -> Void)?
    var receiveSetMetricSystemBlock:((ZyError) -> Void)?
    var receiveSetWeatherBlock:((ZyError) -> Void)?
    var receiveSetEnterCameraBlock:((ZyError) -> Void)?
    var receiveSetFindDeviceBlock:((ZyError) -> Void)?
    var receiveGetLightScreenBlock:((Int,ZyError) -> Void)?
    var receiveSetLightScreenBlock:((ZyError) -> Void)?
    var receiveGetScreenLevelBlock:((Int,ZyError) -> Void)?
    var receiveSetScreenLevelBlock:((ZyError) -> Void)?
    var receiveGetScreenTimeLongBlock:((Int,ZyError) -> Void)?
    var receiveSetScreenTimeLongBlock:((ZyError) -> Void)?
    var receiveGetLocalDialBlock:((Int,ZyError) -> Void)?
    var receiveSetLocalDialBlock:((ZyError) -> Void)?
    var receiveGetAlarmBlock:((ZyAlarmModel?,ZyError) -> Void)?
    var receiveSetAlarmBlock:((ZyError) -> Void)?
    var receiveGetDeviceLanguageBlock:((Int,ZyError) -> Void)?
    var receiveSetDeviceLanguageBlock:((ZyError) -> Void)?
    var receiveGetStepGoalBlock:((Int,ZyError) -> Void)?
    var receiveSetStepGoalBlock:((ZyError) -> Void)?
    var receiveGetDispalyModeBlock:((Int,ZyError) -> Void)?
    var receiveSetDispalyModeBlock:((ZyError) -> Void)?
    var receiveGetWearingWayBlock:((Int,ZyError) -> Void)?
    var receiveSetWearingWayBlock:((ZyError) -> Void)?
    var receiveSetSingleMeasurementBlock:((ZyError) -> Void)?
    var receiveSetExerciseModeBlock:((ZyError) -> Void)?
    var receiveGetExerciseModeBlock:((ZyExerciseType,ZyExerciseState,ZyError) -> Void)?
    var receiveSetDeviceModeBlock:((ZyError) -> Void)?
    var receiveSetPhoneModeBlock:((ZyError) -> Void)?
    var receiveGetWeatherUnitBlock:((Int,ZyError) -> Void)?
    var receiveSetWeatherUnitBlock:((ZyError) -> Void)?
    var receiveSetReportRealtimeDataBlock:((ZyError) -> Void)?
    var receiveGetCustomDialEditBlock:((ZyCustomDialModel?,ZyError) -> Void)?
    var receiveSetCustomDialEditBlock:((ZyError) -> Void)?
    var receiveSetPhoneStateBlock:((ZyError) -> Void)?
    var receiveGetCustonDialFrameSizeBlock:((ZyDialFrameSizeModel?,ZyError) -> Void)?
    var receiveGet24HrMonitorBlock:((Int,ZyError) -> Void)?
    var receiveSet24HrMonitorBlock:((ZyError) -> Void)?
    var receiveSetEnterOrExitCameraBlock:((ZyError) -> Void)?
    var receiveSetDeviceUUIDBlock:((ZyError) -> Void)?
    var receiveSetExerciseDataToDeviceBlock:((ZyError) -> Void)?
    var receiveSetClearAllDataBlock:((ZyError) -> Void)?
    var receiveSetBindBlock:((ZyError) -> Void)?
    var receiveSetUnbindBlock:((ZyError) -> Void)?
    
    var receiveGetNotificationRemindBlock:(([Int],[Int],ZyError) -> Void)?
    var receiveSetNotificationRemindBlock:((ZyError) -> Void)?
    var receiveGetSedentaryBlock:((ZySedentaryModel?,ZyError) -> Void)?
    var receiveSetSedentaryBlock:((ZyError) -> Void)?
    var receiveGetLostBlock:((Int,ZyError) -> Void)?
    var receiveSetLostBlock:((ZyError) -> Void)?
    var receiveGetDoNotDisturbBlock:((ZyDoNotDisturbModel?,ZyError) -> Void)?
    var receiveSetDoNotDisturbBlock:((ZyError) -> Void)?
    var receiveGetHrWaringBlock:((ZyHrWaringModel?,ZyError) -> Void)?
    var receiveSetHrWaringBlock:((ZyError) -> Void)?
    var receiveGetMenstrualCycleBlock:((ZyMenstrualModel?,ZyError) -> Void)?
    var receiveSetMenstrualCycleBlock:((ZyError) -> Void)?
    var receiveGetWashHandBlock:(([String:Any],ZyError) -> Void)?
    var receiveSetWashHandBlock:((ZyError) -> Void)?
    var receiveGetDrinkWaterBlock:((ZyDrinkWaterModel?,ZyError) -> Void)?
    var receiveSetDrinkWaterBlock:((ZyError) -> Void)?
    var receiveSetAddressBookBlock:((ZyError) -> Void)?
    var receiveGetLowBatteryRemindBlock:((ZyLowBatteryModel?,ZyError) -> Void)?
    var receiveSetLowBatteryRemindBlock:((ZyError) -> Void)?
        //    var receiveSetSyncHealthDataBlock:(day:String,type:String,success:(([String:Any],ZyError) -> Void))?
    var receiveSetSyncStepDataBlock:(day:String,type:String,success:((Any?,ZyError) -> Void))?
    var receiveSetSyncSleepDataBlock:(day:String,type:String,success:((Any?,ZyError) -> Void))?
    var receiveSetSyncHeartrateDataBlock:(day:String,type:String,success:((Any?,ZyError) -> Void))?
    var receiveSetSyncExerciseDataBlock:((ZyExerciseModel?,ZyError) -> Void)?
    var receiveSetPowerTurnOffBlock:((ZyError) -> Void)?
    var receiveSetFactoryDataResetBlock:((ZyError) -> Void)?
    var receiveSetMotorVibrationBlock:((ZyError) -> Void)?
    var receiveSetRestartBlock:((ZyError) -> Void)?
    var receiveReportRealTiemStepBlock:((ZyStepModel?,ZyError) -> Void)?
    var receiveReportRealTiemHrBlock:(([String:Any],ZyError) -> Void)?
    var receiveReportSingleMeasurementResultBlock:(([String:Any],ZyError) -> Void)?
    var receiveReportExerciseStateBlock:((ZyExerciseState,ZyError) -> Void)?
    var receiveReportFindPhoneBlock:((ZyError) -> Void)?
    var receiveReportEndFindPhoneBlock:((ZyError) -> Void)?
    var receiveReportTakePicturesBlock:((ZyError) -> Void)?
    var receiveReportMusicControlBlock:((Int,ZyError) -> Void)?
    var receiveReportCallControlBlock:((Int,ZyError) -> Void)?
    var receiveReportScreenLevelBlock:((Int,ZyError) -> Void)?
    var receiveReportScreenTimeLongBlock:((Int,ZyError) -> Void)?
    var receiveReportLightScreenBlock:((Int,ZyError) -> Void)?
    var receiveReportDeviceVibrationBlock:((Int,ZyError) -> Void)?
    var receiveReportNewRealtimeDataBlock:((ZyStepModel?,Int,Int,Int,Int,ZyError) -> Void)?
    var receiveReportExerciseInteractionDataBlock:((Int,Int,Int,ZyError) -> Void)?
    var receiveReportDoNotDisturb:((ZyDoNotDisturbModel?,ZyError) -> Void)?
    var receiveSetSubpackageInformationInteractionBlock:(([String:Any],ZyError) -> Void)?
    var receiveSetStartUpgradeBlock:((ZyError) -> Void)?
    var receiveSetStartUpgradeProgressBlock:((Float) -> Void)?
    var receiveSetStopUpgradeBlock:((ZyError) -> Void)?
    var receiveCheckUpgradeStateBlock:(([String:Any],ZyError) -> Void)?
    var receiveNewSetSyncHealthDataBlock:((Any?,ZyError) -> Void)?
    var receiveSetSyncMeasurementDataBlock:((Any?,ZyError) -> Void)?
    var receiveNewSetWeatherBlock:((ZyError) -> Void)?
    var receiveNewSetAlarmArrayBlock:((ZyError) -> Void)?
    var receiveNewGetAlarmArrayBlock:(([ZyAlarmModel],ZyError) -> Void)?
    var receiveSetSleepGoalBlock:((ZyError) -> Void)?
    var receiveGetSleepGoalBlock:((Int,ZyError) -> Void)?
    var receiveSetFactoryAndPowerOffBlock:((ZyError) -> Void)?
    var receiveReportEnterOrExitCameraBlock:((Int,ZyError) -> Void)?
    var receiveSetSosContactPersonBlock:((ZyError) -> Void)?
    var receiveGetSosContactPersonBlock:((ZyAddressBookModel?,ZyError) -> Void)?
    var receiveCycleMeasurementParameters:((ZyError) -> Void)?
    var receiveGetCycleMeasurementParametersBlock:(([ZyCycleMeasurementModel]?,ZyError) -> Void)?
    var receiveGetWorshipStartTimeBlock:((String?,Int,ZyError) -> Void)?
    var receiveReportWorshipStartTime:((String?,Int,ZyError) -> Void)?
    var receiveSetTimeZoneBlock:((ZyError) -> Void)?
    var receiveGetAssistedPositioningStateBlock:((Int,ZyError) -> Void)?
    var receiveReportLocationInfo:((ZyError) -> Void)?
    var receiveSetLedSetupBlock:((ZyError) -> Void)?
    var receiveSetMotorShakeFunctionBlock:((ZyError) -> Void)?
    var receiveGetLedSetupBlock:(([ZyLedFunctionModel],ZyError) -> Void)?
    var receiveGetMotorShakeFunctionBlock:(([ZyMotorFunctionModel],ZyError) -> Void)?
    var receiveReportAlarmArray:(([ZyAlarmModel],ZyError) -> Void)?
    var receiveSetLedSetupSingleBlock:((ZyError) -> Void)?
    var receiveSetMotorShakeFunctionSingleBlock:((ZyError) -> Void)?
    var receiveGetLedSetupSingleBlock:((ZyLedFunctionModel?,ZyError) -> Void)?
    var receiveGetMotorShakeFunctionSingleBlock:((ZyMotorFunctionModel?,ZyError) -> Void)?
    var receiveSetPowerConsumptionDataBlock:((ZyError) -> Void)?
    var receiveReportPowerConsumptionData:(([String:String],ZyError) -> Void)?
    var receiveReportTreatmentStatus:((Int,ZyError) -> Void)?
    var receiveReportLocationPrimitiveTransmission:((Data,ZyError) -> Void)?
    var receiveReportAssistedPositioning:((Int,ZyError) -> Void)?
    var receiveGetCustomSportsModeBlock:((ZyExerciseType,ZyError) -> Void)?
    var receiveReportLanguageType:((Int,ZyError) -> Void)?
    var receiveGetLedCustomSetupBlock:((ZyLedFunctionModel?,ZyError) -> Void)?
    var receiveSetLedCustomSetupBlock:((ZyError) -> Void)?
    var receiveGetMotorShakeCustomBlock:((ZyMotorFunctionModel?,ZyError) -> Void)?
    var receiveSetMotorShakeCustomBlock:((ZyError) -> Void)?
    var receiveSetBleNameBlock:((ZyError) -> Void)?
    var receiveSetCustomBloodSugarScopeBlock:((ZyError) -> Void)?
    var receiveGetCustomBloodSugarScopeBlock:(([ZyCustomBloodSugar],ZyError) -> Void)?
    var receiveSetMessageRemindTypeBlock:((ZyError) -> Void)?
    var receiveGetMessageRemindTypeBlock:((Int,ZyError) -> Void)?
    var receiveSetBusinessCardBlock:((ZyError) -> Void)?
    var receiveGetBusinessCardBlock:(([ZyBusinessCardModel],ZyError) -> Void)?
    var receiveSetTreatmentInfomationBlock:((ZyError) -> Void)?
    var receiveGetTreatmentInfomationBlock:((ZyTreatmentModel?,ZyError) -> Void)?
    var receiveSetLocationPrimitiveTransmissionBlock:((ZyError) -> Void)?
    var receiveSetDiveDeepBlock:((ZyError) -> Void)?
    var receiveGetDiveDeepBlock:((Int,Int,ZyError) -> Void)?
    var receiveSetDivePressureBlock:((Int,ZyError) -> Void)?
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
    
    var newProtocalData:Data?
    var isNewProtocalData = false
    var newProtocalMaxIndex = 0
    var newProtocalLength = 0
    var newProtocalCRC16 = 0
    
    var deviceSupportMaxData:Data?
    var isDeviceSupportData = false
    var deviceSupportMaxIndex = 0
    var deviceSupportDataLength = 0
    var deviceSupportCRC16 = 0
    
    var otaData:Data?
    var otaStartIndex = 0
    var otaMaxSingleCount = 0
    var otaPackageCount = 0
    var otaCheckFailResendData:Data?
    var otaContinueDataLength = 0
    var failCheckCount = 0
    var currentReceiveCommandEndOver = false //当前接收命令状态是否结束   5s没有接收到回复数据默认结束，赋值true
    var sendFailState = false  //命令发送失败状态，true时在信号量需要发命令的地方return待发送的命令
    var serverVersionInfoDic = [String:Any]()
    
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
//            let val:[UInt8] = [0xaa,0x09,0x15,0x00,0x01,0x05,0x00,0x10,0x00,0x03,0x04,0x00,0x80,0x14,0x1c,0x04,0x01,0x80,0x14,0x21,0x04,0x02,0x80,0x14,0x21,0xb2,0xa0,0xE]
            
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
                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "接收:%@", self.convertDataToSpaceHexStr(data: characteristic.value!,isSend: false)))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDeviceName长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetFirmwareVersion长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetSerialNumber长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetMac 长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetBattery长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetTime长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetBattery长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetPersonalInformation长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetPersonalInformation长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetTimeFormat长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetTimeFormat长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetMetricSystem长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetMetricSystem长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x01 && val[1] == 0x86 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //设置天气
                if val[0] == 0x01 && (val[1] == 0x87 || val[1] == 0xc3)  {
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetWeather长度校验出错"))
                    }
                    
                }
                if val[0] == 0x01 && val[1] == 0x88 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //设备进入拍照模式
                if val[0] == 0x01 && val[1] == 0x89 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetEnterCameraBlock {
                            self.parseSetEnterCamera(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetEnterCameraBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetEnterCamera长度校验出错"))
                    }
                    
                }
                if val[0] == 0x01 && val[1] == 0x8a {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetFindDevice长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLightScreen长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetLightScreen长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetScreenLevel长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetScreenLevel长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetScreenTimeLong长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetScreenTimeLong长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLocalDial长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLocalDial长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetAlarm长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetAlarm长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDeviceLanguage长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDeviceLanguage长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetStepGoal长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetStepGoal长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDispalyMode长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDispalyMode长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetWearingWay长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetWearingWay长度校验出错"))
                    }
                    
                }
                if val[0] == 0x01 && val[1] == 0x9c {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSingleMeasurement长度校验出错"))
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
                            block(.runOutside,.unknow,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetExerciseMode 长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetExerciseMode长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDeviceMode长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetPhoneMode长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetWeatherUnit长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetWeatherUnit长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetReportRealtimeData长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetReportRealtimeData长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetReportRealtimeData长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetReportRealtimeData长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetCustonDialFrameSize长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "rGet24HrMonitor长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "Set24HrMonitor长度校验出错"))
                    }
                }
                
                //设置进入或退出拍照模式
                if val[0] == 0x01 && val[1] == 0xb7 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetEnterOrExitCameraBlock {
                            self.parseSetEnterOrExitCamera(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetEnterOrExitCameraBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetEnterOrExitCamera长度校验出错"))
                    }
                }
                
                //设置UUID
                if val[0] == 0x01 && val[1] == 0xb9 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetDeviceUUIDBlock {
                            self.parseSetDeviceUUID(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetDeviceUUIDBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDeviceUUID长度校验出错"))
                    }
                }
                
                //app同步数据至设备
                if val[0] == 0x01 && val[1] == 0xbb {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetExerciseDataToDeviceBlock {
                            self.parseSetExerciseDataToDevice(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetExerciseDataToDeviceBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSportsDataToDevice长度校验出错"))
                    }
                }
                
                //设置清除所有数据
                if val[0] == 0x01 && val[1] == 0xbd {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetClearAllDataBlock {
                            self.parseSetClearAllData(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetClearAllDataBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetClearAllData长度校验出错"))
                    }
                }
                
                //绑定
                if val[0] == 0x01 && val[1] == 0xbf {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetBindBlock {
                            self.parseSetBind(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetBindBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetBind长度校验出错"))
                    }
                }
                
                //解绑
                if val[0] == 0x01 && val[1] == 0xc1 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetUnbindBlock {
                            self.parseSetUnbind(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetUnbindBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetUnbind长度校验出错"))
                    }
                }
                
                if val[0] == 0x01 && val[1] == 0xc4 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetDiveDeepBlock {
                            self.parseSetDiveDeep(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetDiveDeepBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDiveDeep长度校验出错"))
                    }
                }
                
                if val[0] == 0x01 && val[1] == 0xc5 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetDiveDeepBlock {
                            self.parseGetDiveDeep(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetDiveDeepBlock {
                            block(-1,-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDiveDeep长度校验出错"))
                    }
                }
                
                if val[0] == 0x01 && val[1] == 0xc6 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetDivePressureBlock {
                            self.parseSetDivePressure(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetDivePressureBlock {
                            block(-1,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDivePressure长度校验出错"))
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
                            block([],[],.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetNotificationRemind长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetNotificationRemind长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetSedentary长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSedentary长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLost长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetLost长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDoNotDisturb长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDoNotDisturb长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetHrWaring长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetHrWaring长度校验出错"))
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
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetMenstrualCycle长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetMenstrualCycle长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetWashHand长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetWashHand长度校验出错"))
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
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDrinkWater长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetDrinkWater长度校验出错"))
                    }
                    
                }
                
                //同步联系人
                if val[0] == 0x02 && val[1] == 0x93 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetAddressBookBlock {
                            self.parseSetAddressBook(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetAddressBookBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetAddress长度校验出错"))
                    }
                    
                }
                
                //获取低电提醒
                if val[0] == 0x02 && val[1] == 0x94 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetLowBatteryRemindBlock {
                            self.parseGetLowBatteryRemind(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetLowBatteryRemindBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLowBatteryRemind长度校验出错"))
                    }
                    
                }
                
                //设置低电提醒
                if val[0] == 0x02 && val[1] == 0x95 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetLowBatteryRemindBlock {
                            self.parseSetLowBatteryRemind(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetLowBatteryRemindBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetLowBatteryRemind长度校验出错"))
                    }
                }
                
                //获取LED单个设置
                if val[0] == 0x02 && (val[1] == 0x96 || val[1] == 0x98) {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetLedSetupSingleBlock {
                            self.parseGetLedSetupSingle(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetLedSetupSingleBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLedSetupSingle长度校验出错"))
                    }
                    
                }
                
                //设置LED单个设置
                if val[0] == 0x02 && (val[1] == 0x97 || val[1] == 0x99) {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetLedSetupSingleBlock {
                            self.parseSetLedSetupSingle(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetLedSetupSingleBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetLedSetupSingle长度校验出错"))
                    }
                    
                }
                
                //获取马达震动单个设置
                if val[0] == 0x02 && val[1] == 0x9A {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetMotorShakeFunctionSingleBlock {
                            self.parseGetMotorShakeFunctionSingle(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetMotorShakeFunctionSingleBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetMotorShakeFunctionSingle长度校验出错"))
                    }
                    
                }
                
                //设置马达震动单个设置
                if val[0] == 0x02 && val[1] == 0x9B {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetMotorShakeFunctionSingleBlock {
                            self.parseSetMotorShakeFunctionSingle(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetMotorShakeFunctionSingleBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetMotorShakeFunctionSingle长度校验出错"))
                    }
                    
                }
                
                //获取LED自定义设置
                if val[0] == 0x02 && val[1] == 0x9c {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetLedCustomSetupBlock {
                            self.parseGetLedCustomSetup(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetLedCustomSetupBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetLedCustomSetup长度校验出错"))
                    }
                }
                
                //设置LED自定义设置
                if val[0] == 0x02 && val[1] == 0x9d {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetLedCustomSetupBlock {
                            self.parseSetLedCustomSetup(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetLedCustomSetupBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetLedCustomSetup长度校验出错"))
                    }
                    
                }
                
                //获取自定义震动
                if val[0] == 0x02 && val[1] == 0x9E {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveGetMotorShakeCustomBlock {
                            self.parseGetMotorShakeCustom(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveGetMotorShakeCustomBlock {
                            block(nil,.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetMotorShakeCustom长度校验出错"))
                    }
                    
                }
                
                //设置自定义震动
                if val[0] == 0x02 && val[1] == 0x9F {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveSetMotorShakeCustomBlock {
                            self.parseSetMotorShakeCustom(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveSetMotorShakeCustomBlock {
                            block(.invalidLength)
                        }
                        //printLog("第\(#line)行" , "\(#function)")
                        self.signalCommandSemaphore()
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetMotorShakeCustom长度校验出错"))
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
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncHealthData 数据状态错误"))
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
                                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncHealthData长度校验出错"))
                                }
                                
                                if self.stepCRC16 != crc16 {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@ 第一包给的0x%04x,所有接收校验的0x%04x", "同步步数数据 CRC16校验出错",self.stepCRC16,crc16))
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
                                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncHealthData长度校验出错"))
                                }
                                
                                if self.sleepCRC16 != crc16 {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@ 第一包给的0x%04x,所有接收校验的0x%04x", "同步步数数据 CRC16校验出错",self.sleepCRC16,crc16))
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
                                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncHealthData长度校验出错"))
                                }
                                
                                if self.hrCRC16 != crc16 {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@ 第一包给的0x%04x,所有接收校验的0x%04x", "同步步数数据 CRC16校验出错",self.hrCRC16,crc16))
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
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncExerciseData 数据状态错误"))
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
                                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncExerciseData长度校验出错"))
                                }
                                
                                if self.exerciseCRC16 != crc16 {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@ 第一包给的0x%04x,所有接收校验的0x%04x", "同步锻炼数据 CRC16校验出错",self.exerciseCRC16,crc16))
                                }
                            }
                        }
                    }
                }
                
                //获取设备支持的功能列表
                if val[0] == 0x03 && val[1] == 0x84 {
                    
                    if self.checkLength(val: [UInt8](val)) {
                        if val.count > 4 {
                            if val[4] == 0 {
                                
                                if let block = self.receiveGetDeviceSupportListBlock {
                                    block(nil,.noMoreData)
                                }
                                self.signalCommandSemaphore()
                                ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDeviceSupportList 数据状态错误"))
                                return
                            }
                        }
                    }
                    
                    if val.count > 13 {
                        
                        //所有长度不定，不能以长度来判断
                        if val[6] == 1 && val[7] == 6 {
                            self.isDeviceSupportData = true
                            let maxDataCount = (Int(val[2]) | Int(val[3]) << 8  | Int(val[4]) << 16  | Int(val[5]) << 24)
                            let indexCount =  1 + (maxDataCount + 8) / 16 //应该能接收的所有包序号
                            self.deviceSupportMaxIndex = indexCount
                            self.deviceSupportDataLength = maxDataCount
                            self.deviceSupportCRC16 = (Int(val[10]) | Int(val[11]) << 8)
                            printLog("deviceSupportMaxIndex ->",self.deviceSupportMaxIndex)
                            printLog("self.deviceSupportCRC16 ->",self.deviceSupportCRC16)
                            printLog("self.deviceSupportCRC16 ->%04x",String.init(format: "%04x", self.deviceSupportCRC16))
                            self.exerciseMaxData = nil
                            
                            self.deviceSupportMaxData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                                let byte = bytes.baseAddress! + 13
                                return Data.init(bytes: byte, count: val.count-13)
                            })
                            return
                        }
                    }
                    
                    if self.isDeviceSupportData {
                        
                        let newData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                            let byte = bytes.baseAddress! + 4
                            return Data.init(bytes: byte, count: val.count-4)
                        })
                        
                        self.deviceSupportMaxData?.append(newData)
                        printLog("(Int(val[2]) | Int(val[3]) << 8 ) =\((Int(val[2]) | Int(val[3]) << 8 )),self.deviceSupportMaxIndex-1 =\(self.deviceSupportMaxIndex-1)")
                        if (Int(val[2]) | Int(val[3]) << 8 ) >= self.deviceSupportMaxIndex-1 {
                            
                            self.isDeviceSupportData = false
                            printLog("isDeviceSupportData接收完成")
                            
                            printLog("length =",self.deviceSupportMaxData!.count,"deviceSupportMaxData ->",self.convertDataToHexStr(data: self.deviceSupportMaxData!))
                            
                            let crc16:UInt16 = self.CRC16(data: self.deviceSupportMaxData!)
                            
                            printLog("crc16 ->",crc16)
                            
                            printLog("crc16 ->02x",String.init(format: "%02x", crc16))
                            
                            if self.deviceSupportDataLength == self.deviceSupportMaxData!.count && self.deviceSupportCRC16 == crc16 {
                                
                                let dsVal = self.deviceSupportMaxData!.withUnsafeBytes({ (bytes) -> [UInt8] in
                                    let b = (bytes.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                                    return [UInt8](UnsafeBufferPointer.init(start: b, count: (self.deviceSupportMaxData?.count ?? 0)))
                                })
                                
                                if let block = self.receiveGetDeviceSupportListBlock {
                                    self.parseGetDeviceSupportList(val: dsVal, success: block)
                                }
                                
                            }else{
                                
                                if self.deviceSupportDataLength != self.deviceSupportMaxData!.count {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetDeviceSupportList长度校验出错"))
                                }
                                
                                if self.deviceSupportCRC16 != crc16 {
                                    //printLog("第\(#line)行" , "\(#function)")
                                    self.signalCommandSemaphore()
                                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@ 第一包给的0x%04x,所有接收校验的0x%04x", "获取功能列表 CRC16校验出错",self.deviceSupportCRC16,crc16))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetPowerTurnOff长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetFactoryDataReset长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetMotorVibration长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetRestart长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x86 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportExerciseStateBlock {
                            self.parseReportExerciseStateData(val: val, success: block)
                        }
                        
                    }else{
                        if let block = self.receiveReportExerciseStateBlock {
                            block(.unknow,.invalidLength)
                        }
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x98 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportNewRealtimeDataBlock {
                            self.parseReportNewRealtimeData(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportNewRealtimeDataBlock {
                            block(nil,-1,-1,-1,-1,.invalidLength)
                        }
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                if val[0] == 0x80 && val[1] == 0x9c {
                    if self.checkLength(val: [UInt8](val)) {
                        
                        if let block = self.receiveReportExerciseInteractionDataBlock {
                            self.parseReportExerciseInteractionData(val: val, success: block)
                        }
                        
                    }else{
                        
                        if let block = self.receiveReportExerciseInteractionDataBlock {
                            block(-1,-1,-1,.invalidLength)
                        }
                        
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    
                }
                
                //2.3.2.分包信息交互(设备端) 0x01
                if val[0] == 0x05 && val[1] == 0x81 {
                    if self.checkLength(val: [UInt8](val)) {
                        
                    }else{
                        //printLog("第\(#line)行" , "\(#function)")
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                                
                                self.resendUpgradeData(maxSingleCount: self.otaMaxSingleCount, packageCount: self.otaPackageCount, resendVal: val, val: otaVal, progress: self.receiveSetStartUpgradeProgressBlock!, success: self.receiveSetStartUpgradeBlock!)
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
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
                        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "长度校验出错"))
                    }
                    //printLog("第\(#line)行" , "\(#function)")
                }
                
                if val[0] == 0xaa && self.functionListModel?.functionList_newPortocol == true {
                    
                    let firstBit = Int(val[3])
                    var maxMtuCount = 0
                    if let model = self.functionListModel?.functionDetail_newPortocol {
                        maxMtuCount = model.maxMtuCount
                    }

                    let crc16 = (Int(val[val.count-2]) | Int(val[val.count-1]) << 8)
                    
                    if firstBit > 0 {

                        let totalCount = (Int(val[4]) | Int(val[5]) << 8 )
                        let currentCount = (Int(val[6]) | Int(val[7]) << 8 )

                        let newData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                            let byte = bytes.baseAddress! + 8
                            return Data.init(bytes: byte, count: val.count-10)
                        })
                        
                        let testArray = Array(val[0..<val.count-2])
                        if self.CRC16(val: testArray) == crc16 {
                            if self.newProtocalData == nil {
                                self.newProtocalData = Data()
                            }
                            self.newProtocalData?.append(newData)
                        }else{
                            print("testArray = \(testArray),count = \(testArray.count),crc16 = \(self.CRC16(val: testArray)),\(String.init(format: "%04x", self.CRC16(val: testArray)))")
                            let errorString = String.init(format: "第%d包crc16校验出错,app计算的:%02x,设备返回的:%02x", currentCount,self.CRC16(val: val),crc16)
                            print("errorString")
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: errorString))
                        }

                        if totalCount == currentCount + 0 {
                            let totalLength = (Int(val[2]) | (firstBit-128) << 8)
                            guard self.newProtocalData != nil else {
                                print("self.newProtocalData 数据错误")
                                return
                            }
                            if self.newProtocalData!.count == totalLength {

                                let newVal = self.newProtocalData!.withUnsafeBytes({ (bytes) -> [UInt8] in
                                    let b = (bytes.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                                    return [UInt8](UnsafeBufferPointer.init(start: b, count: (self.newProtocalData?.count ?? 0)))
                                })

                                if val[1] == 0x05 { //同步数据id 0x05
                                    if let block = self.receiveNewSetSyncHealthDataBlock {
                                        self.parseSetNewSyncHealthData(val: newVal, success: block)
                                    }
                                }
                                
                                if val[1] == 0x06 { //同步测量数据 0x06
                                    if let block = self.receiveSetSyncMeasurementDataBlock {
                                        self.parseSyncMeasurementData(val: newVal, success: block)
                                    }
                                }
                                
                                if val[1] == 0x04 {
                                    var currentIndex = 1
                                    while currentIndex < val.count - 2 {
                                        let cmd_id = (Int(newVal[currentIndex]) | Int(newVal[currentIndex+1]) << 8)
                                        let cmd_length = (Int(newVal[currentIndex+2]) | Int(newVal[currentIndex+3]) << 8)
                                        
                                        switch cmd_id {
                                        case 5:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveNewGetAlarmArrayBlock {
                                                self.parseGetNewAlarmArray(val: newVal, success: block)
                                            }
                                            break
                                        case 0x18:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetDoNotDisturbBlock {
                                                self.parseGetDoNotDisturb(val: newVal, success: block)
                                            }
                                            break
                                        case 0x19:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetSleepGoalBlock {
                                                self.parseGetSleepGoal(val: newVal, success: block)
                                            }
                                            break
                                        case 0x1a:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetSosContactPersonBlock {
                                                self.parseGetSosContactPerson(val: newVal, success: block)
                                            }
                                            break
                                        case 0x1b:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetCycleMeasurementParametersBlock {
                                                self.parseGetCycleMeasurementParameters(val: newVal, success: block)
                                            }
                                            break
                                        case 0x1d:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetWorshipStartTimeBlock {
                                                self.parseGetWorshipStartTime(val: newVal, success: block)
                                            }
                                            break
                                        case 0x1e:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetLedSetupBlock {
                                                self.parseGetLedSetup(val: newVal, success: block)
                                            }
                                            break
                                        case 0x1f:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetMotorShakeFunctionBlock {
                                                self.parseGetMotorShakeFunction(val: newVal, success: block)
                                            }
                                            break
                                        case 0x20:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetCustomSportsModeBlock {
                                                self.parseGetCustomSportsMode(val: newVal, success: block)
                                            }
                                            break
                                        case 0x22:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetCustomBloodSugarScopeBlock {
                                                self.parseGetCustomBloodSugarScope(val: newVal, success: block)
                                            }
                                            break
                                        case 0x23:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetMessageRemindTypeBlock {
                                                self.parseGetMessageRemindType(val: newVal, success: block)
                                            }
                                            break
                                        case 0x24:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetBusinessCardBlock {
                                                self.parseGetBusinessCard(val: newVal, success: block)
                                            }
                                            break
                                        case 0x25:
                                            let newVal = Array(newVal[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                            if let block = self.receiveGetTreatmentInfomationBlock {
                                                self.parseGetTreatmentInfomation(val: newVal, success: block)
                                            }
                                            break
                                            
                                        default:
                                            break
                                        }
                                        
                                        currentIndex += (4+cmd_length)
                                    }
                                }
                                
                                if val[1] == 0x03 {

                                    let resultArray = Array(val[4..<val.count-2])
                                    var currentIndex = 1
                                    while currentIndex < resultArray.count {
                                        let cmd_id = (Int(resultArray[currentIndex]) | Int(resultArray[currentIndex+1]) << 8)
                                        let result = resultArray[currentIndex+2]

                                        switch cmd_id {
                                        case 0:
                                            break
                                        case 4:
                                            if let block = self.receiveNewSetWeatherBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 5:
                                            if let block = self.receiveNewSetAlarmArrayBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x0f:
                                            if let block = self.receiveSetTimeZoneBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x18:
                                            if let block = self.receiveSetDoNotDisturbBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x19:
                                            if let block = self.receiveSetSleepGoalBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x1a:
                                            if let block = self.receiveSetSosContactPersonBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x1b:
                                            if let block = self.receiveCycleMeasurementParameters {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x1e:
                                            if let block = self.receiveSetLedSetupBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x1f:
                                            if let block = self.receiveSetMotorShakeFunctionBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x21:
                                            if let block = self.receiveSetBleNameBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x22:
                                            if let block = self.receiveSetCustomBloodSugarScopeBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x23:
                                            if let block = self.receiveSetMessageRemindTypeBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x24:
                                            if let block = self.receiveSetBusinessCardBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x25:
                                            if let block = self.receiveSetTreatmentInfomationBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x26:
                                            if let block = self.receiveSetLocationPrimitiveTransmissionBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        default:
                                            break
                                        }
                                        currentIndex += 3
                                    }
                                }
                                
                                if val[1] == 0x07 {
                                    
                                    let resultArray = Array(val[4..<val.count-2])
                                    var currentIndex = 0
                                    while currentIndex < resultArray.count {
                                        let cmd_id = Int(resultArray[currentIndex])
                                        let result = resultArray[currentIndex+1]

                                        switch cmd_id {
                                        case 0:
                                            break
                                        case 4:
                                            
                                            break
                                            
                                        case 0x0e:
                                            if let block = self.receiveSetFactoryAndPowerOffBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x0f:
                                            if let block = self.receiveSetPowerConsumptionDataBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                            
                                        default:
                                            break
                                        }
                                        currentIndex += 2
                                    }
                                }
                                
                                if val[1] == 0x08 {

                                    let resultArray = Array(val[4..<val.count-2])
                                    var currentIndex = 0
                                    while currentIndex < resultArray.count {
                                        let cmd_id = Int(resultArray[currentIndex])
                                        let result = resultArray[currentIndex+1]

                                        switch cmd_id {
                                        case 0:
                                            break
                                        case 5:

                                            if let block = self.receiveReportEnterOrExitCameraBlock {
                                                self.parseReportEnterOrExitCameraData(val: [result], success: block)
                                            }

                                            break

                                        default:
                                            break
                                        }
                                        currentIndex += 2
                                    }
                                }
                                
                                if val[1] == 0x09 {

                                    var count:Int = Int(newVal[0])
                                    var valIndex:Int = 1

                                    while valIndex < newVal.count {
                                        let cmd_id:Int = (Int(newVal[valIndex]) | Int(newVal[valIndex+1]) << 8)
                                        let cmd_length:Int = (Int(newVal[valIndex+2]) | Int(newVal[valIndex+3]) << 8)
                                        let countLength:Int = 4
                                        if cmd_length > 0 {
                                            switch cmd_id {
                                            case 0x18:
                                                let startIndex = Int(valIndex+countLength)
                                                let endIndex = Int(valIndex+countLength+cmd_length)
                                                let doNotDisturbVal = Array(newVal[startIndex..<endIndex])
                                                if let block = self.receiveReportDoNotDisturb {
                                                    self.parseReportDoNotDisturb(val: doNotDisturbVal, success: block)
                                                }
                                                break
                                            case 0x1d:
                                                let startIndex = Int(valIndex+countLength)
                                                let endIndex = Int(valIndex+countLength+cmd_length)
                                                let worshipVal = Array(newVal[startIndex..<endIndex])
                                                if let block = self.receiveReportWorshipStartTime {
                                                    self.parseReportWorshipStartTime(val: worshipVal, success: block)
                                                }
                                                break
                                            case 0x05:
                                                let startIndex = Int(valIndex+countLength)
                                                let endIndex = Int(valIndex+countLength+cmd_length)
                                                let alarmVal = Array(newVal[startIndex..<endIndex])
                                                if let block = self.receiveReportAlarmArray {
                                                    self.parseReportAlarmArray(val: alarmVal, success: block)
                                                }
                                                break
                                            case 0x09:
                                                let startIndex = Int(valIndex+countLength)
                                                let endIndex = Int(valIndex+countLength+cmd_length)
                                                let languageVal = Array(newVal[startIndex..<endIndex])
                                                if let block = self.receiveReportLanguageType {
                                                    self.parseReportLanguageType(val: languageVal, success: block)
                                                }
                                                break
                                            default:
                                                break
                                            }
                                        }
                                        valIndex = (valIndex+countLength+Int(cmd_length))
                                    }
                                }
                                
                                if val[1] == 0x0a {
                                    //MARK:- 多包上报
                                    let resultArray = Array(val[4..<val.count-2])
                                    let cmd_id:Int = Int(newVal[0])
                                    switch cmd_id {
                                    case 0x07:
                                        let stateVal = Array(resultArray[1..<2])
                                        if let block = self.receiveReportAssistedPositioning {
                                            self.parseReportAssistedPositioning(val: stateVal, success: block)
                                        }
                                        break
                                    case 0x08:
                                        let startIndex = 1
                                        let endIndex = 24
                                        let powerVal = Array(resultArray[startIndex..<endIndex])
                                        
                                        //if let block = self.receiveReportPowerConsumptionData {
                                            self.parseReportPowerConsumptionData(val: powerVal/*, success: ((_ dataDic:[String:String],_ error:ZyError) -> Void)*/)
                                        //}
                                        break
                                    case 0x09:
                                        let stateVal = Array(resultArray[1..<2])
                                        if let block = self.receiveReportTreatmentStatus {
                                            self.parseReportTreatmentStatus(val: stateVal, success: block)
                                        }
                                        break
                                    case 0x0a:
                                        if let block = self.receiveReportLocationPrimitiveTransmission {
                                            self.parseReportLocationPrimitiveTransmission(val: newVal, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                }

                                if val[1] == 0x0b {
                                    var count:Int = Int(newVal[0])
                                    var valIndex:Int = 1
                                    
                                    let cmd_id:Int = Int(newVal[valIndex])
                                    switch cmd_id {
                                    case 0x01:
                                        if let block = self.receiveReportLocationInfo {
                                            self.parseReportLocationInfo(val: [], success: block)
                                        }
                                        break
                                    
                                    default:
                                        break
                                    }
                                }
                                
                                if val[1] == 0x0c {
                                    
                                    let resultArray = Array(val[4..<val.count-2])
                                    var currentIndex = 1
                                    while currentIndex < resultArray.count {
                                        let cmd_id = Int(resultArray[currentIndex])
                                        let result = resultArray[currentIndex+1]

                                        switch cmd_id {
                                        case 0x01:
                                            
                                            if let block = self.receiveGetAssistedPositioningStateBlock {
                                                self.parseGetAssistedPositioningState(val: result, success: block)
                                            }
                                            
                                            break
                                        default:
                                            break
                                        }
                                        currentIndex += 2
                                    }
                                }

                            }else{
                                if val[1] == 0x05 { //同步数据id 0x05
                                    if let block = self.receiveNewSetSyncHealthDataBlock {
                                        block(nil,.invalidLength)
                                    }
                                }
                                
                                if val[1] == 0x06 { //同步测量数据 0x06
                                    if let block = self.receiveSetSyncMeasurementDataBlock {
                                        block(nil,.invalidLength)
                                    }
                                }
                                
                                if val[1] == 0x04 {
                                    if let block = self.receiveNewGetAlarmArrayBlock {
                                        block([],.invalidLength)
                                    }
                                    if let block = self.receiveGetDoNotDisturbBlock {
                                        block(nil,.invalidLength)
                                    }
                                    if let block = self.receiveGetSleepGoalBlock {
                                        block(-1,.invalidLength)
                                    }
                                    if let block = self.receiveGetSosContactPersonBlock {
                                        block(nil,.invalidLength)
                                    }
                                    if let block = self.receiveGetCycleMeasurementParametersBlock {
                                        block(nil,.invalidLength)
                                    }
                                    if let block = self.receiveGetWorshipStartTimeBlock {
                                        block(nil,0,.invalidLength)
                                    }
                                    if let block = self.receiveGetLedSetupBlock {
                                        block([],.invalidLength)
                                    }
                                    if let block = self.receiveGetMotorShakeFunctionBlock {
                                        block([],.invalidLength)
                                    }
                                    if let block = self.receiveGetCustomSportsModeBlock {
                                        block(.runIndoor,.invalidLength)
                                    }
                                    if let block = self.receiveGetCustomBloodSugarScopeBlock {
                                        block([],.invalidLength)
                                    }
                                    if let block = self.receiveGetMessageRemindTypeBlock {
                                        block(-1,.invalidLength)
                                    }
                                    if let block = self.receiveGetBusinessCardBlock {
                                        block([],.invalidLength)
                                    }
                                    if let block = self.receiveGetTreatmentInfomationBlock {
                                        block(nil,.invalidLength)
                                    }
                                }
                                if val[1] == 0x03 {
                                    
                                    let resultArray = Array(val[4..<val.count-2])
                                    var currentIndex = 1
                                    while currentIndex < resultArray.count {
                                        let cmd_id = (Int(resultArray[currentIndex]) | Int(resultArray[currentIndex+1]) << 8)
                                        let result = resultArray[currentIndex+2]

                                        switch cmd_id {
                                        case 0:
                                            break
                                        case 4:
                                            if let block = self.receiveNewSetWeatherBlock {
                                                block(.invalidLength)
                                            }
                                            break
                                        case 5:
                                            if let block = self.receiveNewSetAlarmArrayBlock {
                                                block(.invalidLength)
                                            }
                                            break
                                        case 0x0f:
                                            if let block = self.receiveSetTimeZoneBlock {
                                                block(.invalidLength)
                                            }
                                            break
                                        case 0x18:
                                            if let block = self.receiveSetDoNotDisturbBlock {
                                                block(.invalidLength)
                                            }
                                            break
                                        case 0x19:
                                            if let block = self.receiveSetSleepGoalBlock {
                                                block(.invalidLength)
                                            }
                                            break
                                        case 0x1a:
                                            if let block = self.receiveSetSosContactPersonBlock {
                                                block(.invalidLength)
                                            }
                                            break
                                        case 0x1b:
                                            if let block = self.receiveCycleMeasurementParameters {
                                                block(.invalidLength)
                                            }
                                            break
                                        case 0x1e:
                                            if let block = self.receiveSetLedSetupBlock {
                                                block(.invalidLength)
                                            }
                                            break
                                        case 0x1f:
                                            if let block = self.receiveSetMotorShakeFunctionBlock {
                                                block(.invalidLength)
                                            }
                                            break
                                        case 0x21:
                                            if let block = self.receiveSetBleNameBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x22:
                                            if let block = self.receiveSetCustomBloodSugarScopeBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x23:
                                            if let block = self.receiveSetMessageRemindTypeBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x24:
                                            if let block = self.receiveSetBusinessCardBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x25:
                                            if let block = self.receiveSetTreatmentInfomationBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        case 0x26:
                                            if let block = self.receiveSetLocationPrimitiveTransmissionBlock {
                                                self.parseNewProtocolUniversalResponse(result: result, success: block)
                                            }
                                            break
                                        default:
                                            break
                                        }
                                        currentIndex += 3
                                    }
                                }
                                
                                if val[1] == 0x07 {
                                    
                                    let resultArray = Array(val[4..<val.count-2])
                                    var currentIndex = 0
                                    while currentIndex < resultArray.count {
                                        let cmd_id = Int(resultArray[currentIndex])
                                        let result = resultArray[currentIndex+1]

                                        switch cmd_id {
                                        case 0:
                                            break
                                        case 4:
                                            
                                            break
                                        case 0x0e:
                                            if let block = self.receiveSetFactoryAndPowerOffBlock {
                                                block(.invalidLength)
                                            }
                                            break
                                        case 0x0f:
                                            if let block = self.receiveSetPowerConsumptionDataBlock {
                                                block(.invalidLength)
                                            }
                                            break
                                        default:
                                            break
                                        }
                                        currentIndex += 2
                                    }
                                }
                                
                                if val[1] == 0x08 {

                                    let resultArray = Array(val[4..<val.count-2])
                                    var currentIndex = 0
                                    while currentIndex < resultArray.count {
                                        let cmd_id = Int(resultArray[currentIndex])
                                        let result = resultArray[currentIndex+1]

                                        switch cmd_id {
                                        case 0:
                                            break
                                        case 5:

                                            if let block = self.receiveReportEnterOrExitCameraBlock {
                                                block(-1,.invalidLength)
                                            }

                                            break

                                        default:
                                            break
                                        }
                                        currentIndex += 2
                                    }
                                }
                                
                                if val[1] == 0x09 {
                                    let newVal = Array(val[4..<val.count-2])
                                    var count:Int = Int(newVal[0])
                                    var valIndex = 1

                                    while valIndex < newVal.count {
                                        let cmd_id = (Int(newVal[valIndex]) | Int(newVal[valIndex+1]) << 8)
                                        var cmd_length:Int = (Int(newVal[valIndex+2]) | Int(newVal[valIndex+3]) << 8)
                                        let countLength = 4
                                        if cmd_length > 0 {
                                            switch cmd_id {
                                            case 0x18:
                                                if let block = self.receiveReportDoNotDisturb {
                                                    block(nil,.invalidLength)
                                                }
                                                break
                                            case 0x1d:
                                                if let block = self.receiveReportWorshipStartTime {
                                                    block(nil,0,.invalidLength)
                                                }
                                                break
                                            case 0x05:
                                                if let block = self.receiveReportAlarmArray {
                                                    block([],.invalidLength)
                                                }
                                                break
                                            case 0x09:
                                                if let block = self.receiveReportLanguageType {
                                                    block(-1,.invalidLength)
                                                }
                                                break
                                            default:
                                                break
                                            }
                                        }
                                        valIndex = (valIndex+countLength+Int(cmd_length))
                                    }
                                }
                                
                                if val[1] == 0x0c {
                                    
                                    let resultArray = Array(val[4..<val.count-2])
                                    var currentIndex = 1
                                    while currentIndex < resultArray.count {
                                        let cmd_id = Int(resultArray[currentIndex])
                                        let result = resultArray[currentIndex+1]

                                        switch cmd_id {
                                        case 0x01:
                                            
                                            if let block = self.receiveGetAssistedPositioningStateBlock {
                                                block(-1,.invalidLength)
                                            }

                                            break
                                        default:
                                            break
                                        }
                                        currentIndex += 2
                                    }
                                }

                                ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "新协议0xaa长度校验出错"))
                            }
                            self.newProtocalData = nil
                        }

                    }else{

                        let totalLength = (Int(val[2]) | Int(val[3]) << 8 )
                        if totalLength == val.count - 6 {
                            if val[1] == 0x05 { //同步数据id 0x05
                                if let block = self.receiveNewSetSyncHealthDataBlock {
                                    self.parseSetNewSyncHealthData(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                            }
                            
                            if val[1] == 0x06 { //同步测量数据 0x06
                                if let block = self.receiveSetSyncMeasurementDataBlock {
                                    self.parseSyncMeasurementData(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                            }
                            
                            if val[1] == 0x04 {
                                var currentIndex = 5
                                while currentIndex < val.count - 2 {
                                    let cmd_id = (Int(val[currentIndex]) | Int(val[currentIndex+1]) << 8)
                                    let cmd_length = (Int(val[currentIndex+2]) | Int(val[currentIndex+3]) << 8)
                                    
                                    switch cmd_id {
                                    case 5:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveNewGetAlarmArrayBlock {
                                            self.parseGetNewAlarmArray(val: newVal, success: block)
                                        }
                                        break
                                    case 0x18:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetDoNotDisturbBlock {
                                            self.parseGetDoNotDisturb(val: newVal, success: block)
                                        }
                                        break
                                    case 0x19:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetSleepGoalBlock {
                                            self.parseGetSleepGoal(val: newVal, success: block)
                                        }
                                        break
                                    case 0x1a:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetSosContactPersonBlock {
                                            self.parseGetSosContactPerson(val: newVal, success: block)
                                        }
                                        break
                                    case 0x1b:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetCycleMeasurementParametersBlock {
                                            self.parseGetCycleMeasurementParameters(val: newVal, success: block)
                                        }
                                        break
                                    case 0x1d:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetWorshipStartTimeBlock {
                                            self.parseGetWorshipStartTime(val: newVal, success: block)
                                        }
                                        break
                                    case 0x1e:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetLedSetupBlock {
                                            self.parseGetLedSetup(val: newVal, success: block)
                                        }
                                        break
                                    case 0x1f:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetMotorShakeFunctionBlock {
                                            self.parseGetMotorShakeFunction(val: newVal, success: block)
                                        }
                                        break
                                    case 0x20:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetCustomSportsModeBlock {
                                            self.parseGetCustomSportsMode(val: newVal, success: block)
                                        }
                                        break
                                    case 0x22:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetCustomBloodSugarScopeBlock {
                                            self.parseGetCustomBloodSugarScope(val: newVal, success: block)
                                        }
                                        break
                                    case 0x23:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetMessageRemindTypeBlock {
                                            self.parseGetMessageRemindType(val: newVal, success: block)
                                        }
                                        break
                                    case 0x24:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetBusinessCardBlock {
                                            self.parseGetBusinessCard(val: newVal, success: block)
                                        }
                                        break
                                    case 0x25:
                                        let newVal = Array(val[(currentIndex+4)..<(currentIndex+4+cmd_length)])
                                        if let block = self.receiveGetTreatmentInfomationBlock {
                                            self.parseGetTreatmentInfomation(val: newVal, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    
                                    currentIndex += (4+cmd_length)
                                }
                            }
                            
                            if val[1] == 0x03 {
                                
                                let resultArray = Array(val[4..<val.count-2])
                                var currentIndex = 1
                                while currentIndex < resultArray.count {
                                    let cmd_id = (Int(resultArray[currentIndex]) | Int(resultArray[currentIndex+1]) << 8)
                                    let result = resultArray[currentIndex+2]

                                    switch cmd_id {
                                    case 0:
                                        break
                                    case 4:
                                        if let block = self.receiveNewSetWeatherBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveNewSetAlarmArrayBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x0f:
                                        if let block = self.receiveSetTimeZoneBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x18:
                                        if let block = self.receiveSetDoNotDisturbBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x19:
                                        if let block = self.receiveSetSleepGoalBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x1a:
                                        if let block = self.receiveSetSosContactPersonBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x1b:
                                        if let block = self.receiveCycleMeasurementParameters {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x1e:
                                        if let block = self.receiveSetLedSetupBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x1f:
                                        if let block = self.receiveSetMotorShakeFunctionBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x21:
                                        if let block = self.receiveSetBleNameBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x22:
                                        if let block = self.receiveSetCustomBloodSugarScopeBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x23:
                                        if let block = self.receiveSetMessageRemindTypeBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x24:
                                        if let block = self.receiveSetBusinessCardBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x25:
                                        if let block = self.receiveSetTreatmentInfomationBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x26:
                                        if let block = self.receiveSetLocationPrimitiveTransmissionBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    currentIndex += 3
                                }
                            }
                            
                            if val[1] == 0x07 {
                                
                                let resultArray = Array(val[4..<val.count-2])
                                var currentIndex = 0
                                while currentIndex < resultArray.count {
                                    let cmd_id = Int(resultArray[currentIndex])
                                    let result = resultArray[currentIndex+1]

                                    switch cmd_id {
                                    case 0:
                                        break
                                    case 4:
                                        
                                        break
                                        
                                    case 0x0e:
                                        if let block = self.receiveSetFactoryAndPowerOffBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x0f:
                                        if let block = self.receiveSetPowerConsumptionDataBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    currentIndex += 2
                                }
                            }
                            
                            if val[1] == 0x08 {

                                let resultArray = Array(val[4..<val.count-2])
                                var currentIndex = 0
                                while currentIndex < resultArray.count {
                                    let cmd_id = Int(resultArray[currentIndex])
                                    let result = resultArray[currentIndex+1]

                                    switch cmd_id {
                                    case 0:
                                        break
                                    case 5:

                                        if let block = self.receiveReportEnterOrExitCameraBlock {
                                            self.parseReportEnterOrExitCameraData(val: [result], success: block)
                                        }

                                        break

                                    default:
                                        break
                                    }
                                    currentIndex += 2
                                }
                            }
                            
                            if val[1] == 0x09 {
                                let newVal = Array(val[4..<val.count-2])
                                var count:Int = Int(newVal[0])
                                var valIndex = 1

                                while valIndex < newVal.count {
                                    let cmd_id = (Int(newVal[valIndex]) | Int(newVal[valIndex+1]) << 8)
                                    var cmd_length:Int = (Int(newVal[valIndex+2]) | Int(newVal[valIndex+3]) << 8)
                                    let countLength = 4
                                    if cmd_length > 0 {
                                        switch cmd_id {
                                        case 0x18:
                                            let startIndex = Int(valIndex+countLength)
                                            let endIndex = Int(valIndex+countLength+cmd_length)
                                            let doNotDisturbVal = Array(newVal[startIndex..<endIndex])
                                            if let block = self.receiveReportDoNotDisturb {
                                                self.parseReportDoNotDisturb(val: doNotDisturbVal, success: block)
                                            }
                                            break
                                        case 0x1d:
                                            let startIndex = Int(valIndex+countLength)
                                            let endIndex = Int(valIndex+countLength+cmd_length)
                                            let worshipVal = Array(newVal[startIndex..<endIndex])
                                            if let block = self.receiveReportWorshipStartTime {
                                                self.parseReportWorshipStartTime(val: worshipVal, success: block)
                                            }
                                            break
                                        case 0x05:
                                            let startIndex = Int(valIndex+countLength)
                                            let endIndex = Int(valIndex+countLength+cmd_length)
                                            let alarmVal = Array(newVal[startIndex..<endIndex])
                                            if let block = self.receiveReportAlarmArray {
                                                self.parseReportAlarmArray(val: alarmVal, success: block)
                                            }
                                            break
                                        case 0x09:
                                            let startIndex = Int(valIndex+countLength)
                                            let endIndex = Int(valIndex+countLength+cmd_length)
                                            let languageVal = Array(newVal[startIndex..<endIndex])
                                            if let block = self.receiveReportLanguageType {
                                                self.parseReportLanguageType(val: languageVal, success: block)
                                            }
                                            break
                                        default:
                                            break
                                        }
                                    }
                                    valIndex = (valIndex+countLength+Int(cmd_length))
                                }
                            }

                            if val[1] == 0x0a {
                                let newVal = Array(val[4..<val.count-2])
                                let cmd_id:Int = Int(newVal[0])
                                switch cmd_id {
                                case 0x07:
                                    let stateVal = Array(newVal[1..<2])
                                    if let block = self.receiveReportAssistedPositioning {
                                        self.parseReportAssistedPositioning(val: stateVal, success: block)
                                    }
                                    break
                                case 0x08:
                                    let startIndex = 1
                                    let endIndex = 24
                                    let powerVal = Array(newVal[startIndex..<endIndex])
                                    //if let block = self.receiveReportPowerConsumptionData {
                                        self.parseReportPowerConsumptionData(val: powerVal/*, success: ((_ dataDic:[String:String],_ error:ZyError) -> Void)*/)
                                    //}
                                    break
                                case 0x09:
                                    let stateVal = Array(newVal[1..<2])
                                    if let block = self.receiveReportTreatmentStatus {
                                        self.parseReportTreatmentStatus(val: stateVal, success: block)
                                    }
                                    break
                                case 0x0a:
                                    let stateVal = Array(newVal[1..<2])
                                    if let block = self.receiveReportLocationPrimitiveTransmission {
                                        self.parseReportLocationPrimitiveTransmission(val: stateVal, success: block)
                                    }
                                    break
                                    
                                default:
                                    break
                                }
                            }
                            
                            if val[1] == 0x0b {
                                let newVal = Array(val[4..<val.count-2])
                                var count:Int = Int(newVal[0])
                                let valIndex = 1
                                if valIndex < newVal.count {
                                    let cmd_id:Int = Int(newVal[valIndex])
                                    switch cmd_id {
                                    case 0x01:
                                        if let block = self.receiveReportLocationInfo {
                                            self.parseReportLocationInfo(val: [], success: block)
                                        }
                                        break
                                    
                                    default:
                                        break
                                    }
                                }
                            }
                            
                            if val[1] == 0x0c {
                                
                                let resultArray = Array(val[4..<val.count-2])
                                var currentIndex = 1
                                while currentIndex < resultArray.count {
                                    let cmd_id = Int(resultArray[currentIndex])
                                    let result = resultArray[currentIndex+1]

                                    switch cmd_id {
                                    case 0x01:

                                        if let block = self.receiveGetAssistedPositioningStateBlock {
                                            self.parseGetAssistedPositioningState(val: result, success: block)
                                        }
                                        
                                        break
                                    default:
                                        break
                                    }
                                    currentIndex += 2
                                }
                            }
                            
                        }else{
                            if val[1] == 0x05 { //同步数据id 0x05
                                if let block = self.receiveNewSetSyncHealthDataBlock {
                                    block(nil,.invalidLength)
                                }
                            }
                            
                            if val[1] == 0x06 { //同步测量数据 0x06
                                if let block = self.receiveSetSyncMeasurementDataBlock {
                                    block(nil,.invalidLength)
                                }
                            }
                            
                            if val[1] == 0x04 {
                                if let block = self.receiveNewGetAlarmArrayBlock {
                                    block([],.invalidLength)
                                }
                                if let block = self.receiveGetDoNotDisturbBlock {
                                    block(nil,.invalidLength)
                                }
                                if let block = self.receiveGetSleepGoalBlock {
                                    block(-1,.invalidLength)
                                }
                                if let block = self.receiveGetSosContactPersonBlock {
                                    block(nil,.invalidLength)
                                }
                                if let block = self.receiveGetCycleMeasurementParametersBlock {
                                    block(nil,.invalidLength)
                                }
                                if let block = self.receiveGetWorshipStartTimeBlock {
                                    block(nil,0,.invalidLength)
                                }
                                if let block = self.receiveGetLedSetupBlock {
                                    block([],.invalidLength)
                                }
                                if let block = self.receiveGetMotorShakeFunctionBlock {
                                    block([],.invalidLength)
                                }
                                if let block = self.receiveGetCustomSportsModeBlock {
                                    block(.runIndoor,.invalidLength)
                                }
                                if let block = self.receiveGetCustomBloodSugarScopeBlock {
                                    block([],.invalidLength)
                                }
                                if let block = self.receiveGetMessageRemindTypeBlock {
                                    block(-1,.invalidLength)
                                }
                                if let block = self.receiveGetBusinessCardBlock {
                                    block([],.invalidLength)
                                }
                                if let block = self.receiveGetTreatmentInfomationBlock {
                                    block(nil,.invalidLength)
                                }
                            }
                            
                            if val[1] == 0x01 {
                                
                                let resultArray = Array(val[4..<val.count-2])
                                var currentIndex = 1
                                while currentIndex < resultArray.count {
                                    let cmd_id = (Int(resultArray[currentIndex]) | Int(resultArray[currentIndex+1]) << 8)
                                    let result = resultArray[currentIndex+2]

                                    switch cmd_id {
                                    case 0:
                                        break
                                    case 4:
                                        if let block = self.receiveNewSetWeatherBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveNewSetAlarmArrayBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 0x0f:
                                        if let block = self.receiveSetTimeZoneBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 0x18:
                                        if let block = self.receiveSetDoNotDisturbBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 0x19:
                                        if let block = self.receiveSetSleepGoalBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 0x1a:
                                        if let block = self.receiveSetSosContactPersonBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 0x1b:
                                        if let block = self.receiveCycleMeasurementParameters {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 0x1e:
                                        if let block = self.receiveSetLedSetupBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 0x1f:
                                        if let block = self.receiveSetMotorShakeFunctionBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 0x21:
                                        if let block = self.receiveSetBleNameBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 0x22:
                                        if let block = self.receiveSetCustomBloodSugarScopeBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x23:
                                        if let block = self.receiveSetMessageRemindTypeBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x24:
                                        if let block = self.receiveSetBusinessCardBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x25:
                                        if let block = self.receiveSetTreatmentInfomationBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 0x26:
                                        if let block = self.receiveSetLocationPrimitiveTransmissionBlock {
                                            self.parseNewProtocolUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    currentIndex += 3
                                }
                            }
                            
                            if val[1] == 0x07 {
                                
                                let resultArray = Array(val[4..<val.count-2])
                                var currentIndex = 0
                                while currentIndex < resultArray.count {
                                    let cmd_id = Int(resultArray[currentIndex])
                                    let result = resultArray[currentIndex+1]

                                    switch cmd_id {
                                    case 0:
                                        break
                                    case 4:
                                        
                                        break
                                    case 0x0e:
                                        if let block = self.receiveSetFactoryAndPowerOffBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    case 0x0f:
                                        if let block = self.receiveSetPowerConsumptionDataBlock {
                                            block(.invalidLength)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    currentIndex += 2
                                }
                            }
                            
                            if val[1] == 0x08 {
                                
                                let resultArray = Array(val[4..<val.count-2])
                                var currentIndex = 0
                                while currentIndex < resultArray.count {
                                    let cmd_id = Int(resultArray[currentIndex])
                                    let result = resultArray[currentIndex+1]

                                    switch cmd_id {
                                    case 0:
                                        break
                                    case 5:
                                        if let block = self.receiveReportEnterOrExitCameraBlock {
                                            block(-1,.invalidLength)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    currentIndex += 2
                                }
                            }
                            
                            if val[1] == 0x09 {
                                let newVal = Array(val[4..<val.count-2])
                                var count:Int = Int(newVal[0])
                                var valIndex = 1

                                while valIndex < newVal.count {
                                    let cmd_id = (Int(newVal[valIndex]) | Int(newVal[valIndex+1]) << 8)
                                    var cmd_length:Int = (Int(newVal[valIndex+2]) | Int(newVal[valIndex+3]) << 8)
                                    let countLength = 4
                                    if cmd_length > 0 {
                                        switch cmd_id {
                                        case 0x18:
                                            if let block = self.receiveReportDoNotDisturb {
                                                block(nil,.invalidLength)
                                            }
                                            break
                                        case 0x1d:
                                            if let block = self.receiveReportWorshipStartTime {
                                                block(nil,0,.invalidLength)
                                            }
                                            break
                                        case 0x05:
                                            if let block = self.receiveReportAlarmArray {
                                                block([],.invalidLength)
                                            }
                                            break
                                        case 0x09:
                                            if let block = self.receiveReportLanguageType {
                                                block(-1,.invalidLength)
                                            }
                                            break
                                        default:
                                            break
                                        }
                                    }
                                    valIndex = (valIndex+countLength+Int(cmd_length))
                                }
                            }
                            
                            if val[1] == 0x0c {
                                
                                let resultArray = Array(val[4..<val.count-2])
                                var currentIndex = 1
                                while currentIndex < resultArray.count {
                                    let cmd_id = Int(resultArray[currentIndex])
                                    let result = resultArray[currentIndex+1]

                                    switch cmd_id {
                                    case 0x01:
                                        
                                        if let block = self.receiveGetAssistedPositioningStateBlock {
                                            block(-1,.invalidLength)
                                        }
                                                                                
                                        break
                                    default:
                                        break
                                    }
                                    currentIndex += 2
                                }
                            }
                            
                            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "新协议0xaa长度校验出错"))
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
            print("writeDataAndBackError self.peripheral = \(self.peripheral)")
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
    
//    func writeDataAndBackError(data:Data) -> ZyError {
//
//        return self.writeDataAndBackErrorTest(data: data)
//
//        self.sendFailState = false
//        if self.peripheral?.state != .connected {
//
//            return .disconnected
//
//        }else{
//
//            if self.writeCharacteristic != nil && self.peripheral != nil {
//
//                DispatchQueue.global().async {
//
//                    printLog("send dataString -> wait 之前 sendData = \(self.convertDataToSpaceHexStr(data: data,isSend: true)) self.semaphoreCount = \(self.semaphoreCount) self.signalValue = \(self.signalValue)")
////                    if self.semaphoreCount != 1 && self.signalValue != 1 {
////                        //定时器计数重置
////                        self.commandDetectionCount = 0
////                        if self.commandDetectionTimer == nil {
////                            //检测命令发送之后是否有回复，在deviceReceivedData方法内有数据则把此定时器销毁。如果没有回复，那么5s之后把信号量回复默认值
////                            DispatchQueue.main.async {
////                                self.commandDetectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.commandDetectionTimerMethod), userInfo: nil, repeats: true)
////                            }
////                        }
////                    }
//                    self.semaphoreCount -= 1
////                    self.commandSemaphore.wait()
//                    let result = self.commandSemaphore.wait(wallTimeout: DispatchWallTime.now()+Double(5))//.wait(timeout: DispatchTime.now()+5)//
//                    if result == .timedOut {
//                        self.semaphoreCount += 1
//                    }
//                    printLog("result = \(result)")
//
//                    let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
//                    ZySDKLog.writeStringToSDKLog(string: "发送:"+dataString)
//
//                    DispatchQueue.main.async {
//
//                        printLog("send",dataString)
//                        printLog("发送命令 -> self.semaphoreCount =",self.semaphoreCount)
//                        if self.sendFailState {
//                            printLog("重置信号量状态true，取消此命令发送")
//                            ZySDKLog.writeStringToSDKLog(string: "重置信号量状态true，取消此命令发送 \n\(dataString)")
//                        }else{
//                            self.peripheral?.writeValue(data, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
//                        }
//                        //定时器计数重置
//                        self.commandDetectionCount = 0
//                        if self.commandDetectionTimer == nil {
//                            //检测命令发送之后是否有回复，在deviceReceivedData方法内有数据则把此定时器销毁。如果没有回复，那么5s之后把信号量回复默认值
//                            self.commandDetectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.commandDetectionTimerMethod), userInfo: nil, repeats: true)
//                        }
//                    }
//                }
//                return .none
//            }else{
//
//                ZySDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
//                printLog("写特征为空")
//
//                return .invalidCharacteristic
//            }
//        }
//    }
    
    func deviceDisconnectedFail() {
        
        if let block = self.receiveGetDeviceNameBlock {
            block(nil,.disconnected)
            self.receiveGetDeviceNameBlock = nil
        }
        
        if let block = self.receiveGetFirmwareVersionBlock {
            block(nil,.disconnected)
            self.receiveGetFirmwareVersionBlock = nil
        }
        
        if let block = self.receiveGetMacBlock {
            block(nil,.disconnected)
            self.receiveGetMacBlock = nil
        }
        
        if let block = self.receiveGetBatteryBlock {
            block(nil,.disconnected)
            self.receiveGetBatteryBlock = nil
        }
        
        if let block = self.receiveSetTimeBlock {
            block(.disconnected)
            self.receiveSetTimeBlock = nil
        }
        
        if let block = self.receiveGetDeviceSupportListBlock {
            block(nil,.disconnected)
            self.receiveGetDeviceSupportListBlock = nil
        }

        if let block = self.receiveGetDeviceSupportFunctionDetailBlock {
            block([:],.disconnected)
            self.receiveGetDeviceSupportFunctionDetailBlock = nil
        }
        
        if let block = self.receiveGetDeviceOtaVersionInfo {
            block([:],.disconnected)
            self.receiveGetDeviceOtaVersionInfo = nil
        }
        
        if let block = self.receiveGetSerialNumberBlock {
            block(nil,.disconnected)
            self.receiveGetSerialNumberBlock = nil
        }
        
        if let block = self.receiveGetPersonalInformationBlock {
            block(nil,.disconnected)
            self.receiveGetPersonalInformationBlock = nil
        }
        
        if let block = self.receiveSetPersonalInformationBlock {
            block(.disconnected)
            self.receiveSetPersonalInformationBlock = nil
        }
        
        if let block = self.receiveGetTimeFormatBlock {
            block(-1,.disconnected)
            self.receiveGetTimeFormatBlock = nil
        }
        
        if let block = self.receiveSetTimeFormatBlock {
            block(.disconnected)
            self.receiveSetTimeFormatBlock = nil
        }
        
        if let block = self.receiveGetMetricSystemBlock {
            block(-1,.disconnected)
            self.receiveGetMetricSystemBlock = nil
        }
        
        if let block = self.receiveSetMetricSystemBlock {
            block(.disconnected)
            self.receiveSetMetricSystemBlock = nil
        }
        
        if let block = self.receiveSetWeatherBlock {
            block(.disconnected)
            self.receiveSetWeatherBlock = nil
        }
        
        if let block = self.receiveSetEnterCameraBlock {
            block(.disconnected)
            self.receiveSetEnterCameraBlock = nil
        }
        
        if let block = self.receiveSetFindDeviceBlock {
            block(.disconnected)
            self.receiveSetFindDeviceBlock = nil
        }
        
        if let block = self.receiveGetLightScreenBlock {
            block(-1,.disconnected)
            self.receiveGetLightScreenBlock = nil
        }
        
        if let block = self.receiveSetLightScreenBlock {
            block(.disconnected)
            self.receiveSetLightScreenBlock = nil
        }
        
        if let block = self.receiveGetScreenLevelBlock {
            block(-1,.disconnected)
            self.receiveGetScreenLevelBlock = nil
        }
        
        if let block = self.receiveSetScreenLevelBlock {
            block(.disconnected)
            self.receiveSetScreenLevelBlock = nil
        }
        
        if let block = self.receiveGetScreenTimeLongBlock {
            block(-1,.disconnected)
            self.receiveGetScreenTimeLongBlock = nil
        }
        
        if let block = self.receiveSetScreenTimeLongBlock {
            block(.disconnected)
            self.receiveSetScreenTimeLongBlock = nil
        }
        
        if let block = self.receiveGetLocalDialBlock {
            block(-1,.disconnected)
            self.receiveGetLocalDialBlock = nil
        }
        
        if let block = self.receiveSetLocalDialBlock {
            block(.disconnected)
            self.receiveSetLocalDialBlock = nil
        }
        
        if let block = self.receiveGetAlarmBlock {
            block(nil,.disconnected)
        }
        
        if let block = self.receiveSetAlarmBlock {
            block(.disconnected)
            self.receiveSetAlarmBlock = nil
        }
        
        if let block = self.receiveGetDeviceLanguageBlock {
            block(-1,.disconnected)
            self.receiveGetDeviceLanguageBlock = nil
        }
        
        if let block = self.receiveSetDeviceLanguageBlock {
            block(.disconnected)
            self.receiveSetDeviceLanguageBlock = nil
        }
        
        if let block = self.receiveGetStepGoalBlock {
            block(-1,.disconnected)
            self.receiveGetStepGoalBlock = nil
        }
        
        if let block = self.receiveSetStepGoalBlock {
            block(.disconnected)
            self.receiveSetStepGoalBlock = nil
        }
        
        if let block = self.receiveGetDispalyModeBlock {
            block(-1,.disconnected)
            self.receiveGetDispalyModeBlock = nil
        }
        
        if let block = self.receiveSetDispalyModeBlock {
            block(.disconnected)
            self.receiveSetDispalyModeBlock = nil
        }
        
        if let block = self.receiveGetWearingWayBlock {
            block(-1,.disconnected)
            self.receiveGetWearingWayBlock = nil
        }
        
        if let block = self.receiveSetWearingWayBlock {
            block(.disconnected)
            self.receiveSetWearingWayBlock = nil
        }
        
        if let block = self.receiveSetSingleMeasurementBlock {
            block(.disconnected)
            self.receiveSetSingleMeasurementBlock = nil
        }
        
        if let block = self.receiveSetExerciseModeBlock {
            block(.disconnected)
            self.receiveSetExerciseModeBlock = nil
        }
        
        if let block = self.receiveGetExerciseModeBlock {
            block(.runOutside,.unknow,.disconnected)
            self.receiveGetExerciseModeBlock = nil
        }
        
        if let block = self.receiveSetDeviceModeBlock {
            block(.disconnected)
            self.receiveSetDeviceModeBlock = nil
        }
        
        if let block = self.receiveSetPhoneModeBlock {
            block(.disconnected)
            self.receiveSetPhoneModeBlock = nil
        }
        
        if let block = self.receiveGetWeatherUnitBlock {
            block(-1,.disconnected)
            self.receiveGetWeatherUnitBlock = nil
        }
        
        if let block = self.receiveSetWeatherUnitBlock {
            block(.disconnected)
            self.receiveSetWeatherUnitBlock = nil
        }
        
        if let block = self.receiveSetReportRealtimeDataBlock {
            block(.disconnected)
            self.receiveSetReportRealtimeDataBlock = nil
        }
        
        if let block = self.receiveGetCustomDialEditBlock {
            block(nil,.disconnected)
            self.receiveGetCustomDialEditBlock = nil
        }
        
        if let block = self.receiveSetCustomDialEditBlock {
            block(.disconnected)
            self.receiveSetCustomDialEditBlock = nil
        }
        
        if let block = self.receiveSetPhoneStateBlock {
            block(.disconnected)
            self.receiveSetPhoneStateBlock = nil
        }
        
        if let block = self.receiveGetCustonDialFrameSizeBlock {
            block(nil,.disconnected)
            self.receiveGetCustonDialFrameSizeBlock = nil
        }
        
        if let block = self.receiveGet24HrMonitorBlock {
            block(-1,.disconnected)
            self.receiveGet24HrMonitorBlock = nil
        }
        
        if let block = self.receiveSet24HrMonitorBlock {
            block(.disconnected)
            self.receiveSet24HrMonitorBlock = nil
        }
        
        if let block = self.receiveGetNotificationRemindBlock {
            block([],[],.disconnected)
            self.receiveGetNotificationRemindBlock = nil
        }
        
        if let block = self.receiveSetNotificationRemindBlock {
            block(.disconnected)
            self.receiveSetNotificationRemindBlock = nil
        }
        
        if let block = self.receiveGetSedentaryBlock {
            block(nil,.disconnected)
            self.receiveGetSedentaryBlock = nil
        }
        
        if let block = self.receiveSetSedentaryBlock {
            block(.disconnected)
            self.receiveSetSedentaryBlock = nil
        }
        
        if let block = self.receiveGetLostBlock {
            block(-1,.disconnected)
            self.receiveGetLostBlock = nil
        }
        
        if let block = self.receiveSetLostBlock {
            block(.disconnected)
            self.receiveSetLostBlock = nil
        }
        
        if let block = self.receiveGetDoNotDisturbBlock {
            block(nil,.disconnected)
            self.receiveGetDoNotDisturbBlock = nil
        }
        
        if let block = self.receiveSetDoNotDisturbBlock {
            block(.disconnected)
            self.receiveSetDoNotDisturbBlock = nil
        }
        
        if let block = self.receiveGetHrWaringBlock {
            block(nil,.disconnected)
            self.receiveGetHrWaringBlock = nil
        }
        
        if let block = self.receiveSetHrWaringBlock {
            block(.disconnected)
            self.receiveSetHrWaringBlock = nil
        }
        
        if let block = self.receiveGetMenstrualCycleBlock {
            block(nil,.disconnected)
            self.receiveGetMenstrualCycleBlock = nil
        }
        
        if let block = self.receiveSetMenstrualCycleBlock {
            block(.disconnected)
            self.receiveSetMenstrualCycleBlock = nil
        }
        
        if let block = self.receiveGetWashHandBlock {
            block([:],.disconnected)
            self.receiveGetWashHandBlock = nil
        }
        
        if let block = self.receiveSetWashHandBlock {
            block(.disconnected)
            self.receiveSetWashHandBlock = nil
        }
        
        if let block = self.receiveGetDrinkWaterBlock {
            block(nil,.disconnected)
            self.receiveGetDrinkWaterBlock = nil
        }
        
        if let block = self.receiveSetDrinkWaterBlock {
            block(.disconnected)
            self.receiveSetDrinkWaterBlock = nil
        }
        
        if let block = self.receiveSetSyncStepDataBlock {
            block.success(nil,.disconnected)
            self.receiveSetSyncStepDataBlock = nil
        }
        
        if let block = self.receiveSetSyncSleepDataBlock {
            block.success(nil,.disconnected)
            self.receiveSetSyncSleepDataBlock = nil
        }
        
        if let block = self.receiveSetSyncHeartrateDataBlock {
            block.success(nil,.disconnected)
            self.receiveSetSyncHeartrateDataBlock = nil
        }
        
        if let block = self.receiveSetSyncExerciseDataBlock {
            block(nil,.disconnected)
            self.receiveSetSyncExerciseDataBlock = nil
        }
        
        if let block = self.receiveSetPowerTurnOffBlock {
            block(.disconnected)
            self.receiveSetPowerTurnOffBlock = nil
        }
        
        if let block = self.receiveSetFactoryDataResetBlock {
            block(.disconnected)
            self.receiveSetFactoryDataResetBlock = nil
        }
        
        if let block = self.receiveSetMotorVibrationBlock {
            block(.disconnected)
            self.receiveSetMotorVibrationBlock = nil
        }
        
        if let block = self.receiveSetRestartBlock {
            block(.disconnected)
            self.receiveSetRestartBlock = nil
        }
    }
    
    // MARK: - 检测命令定时器方法
    @objc func commandDetectionTimerMethod() {
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
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetSyncHealthData长度校验出错"))
            if let block = self.receiveSetSyncStepDataBlock {
                self.isStepDetailData = false
                self.signalCommandSemaphore()
                //printLog("健康数据5s未接收到 ->receiveSetSyncStepDataBlock")
                block.success(nil,.invalidLength)
                self.receiveSetSyncStepDataBlock = nil
            }
            if let block = self.receiveSetSyncSleepDataBlock {
                self.isSleepDetailData = false
                self.signalCommandSemaphore()
                //printLog("健康数据5s未接收到 ->receiveSetSyncSleepDataBlock")
                block.success(nil,.invalidLength)
                self.receiveSetSyncSleepDataBlock = nil
            }
            if let block = self.receiveSetSyncHeartrateDataBlock {
                self.isHrDetailData = false
                self.signalCommandSemaphore()
                //printLog("健康数据5s未接收到 ->receiveSetSyncHeartrateDataBlock")
                block.success(nil,.invalidLength)
                self.receiveSetSyncHeartrateDataBlock = nil
            }
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
        self.serverVersionInfoDic.removeAll()
        self.macString = nil
        self.receiveGetDeviceOtaVersionInfo = nil
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
        self.isRequesting = false
        self.isCommandSendState = false
        self.lastSendData = nil
        self.commandListArray.removeAll()
    }
    
    // MARK: - 重置命令等待，待发命令全部移除不发送
    @objc public func resetWaitCommand() {
        self.sendFailState = true
        self.resetCommandSemaphore(showLog: true)
    }
    
    // MARK: - 设备信息 0x00
    // MARK: - 获取设备名称 0x00
    @objc public func getDeviceName(_ success:@escaping((String?,ZyError)->Void)) {
        
        var val:[UInt8] = [0x00,0x00,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDeviceNameBlock = success
        }else{
            
            success(nil,state)
        }
        
    }
    
    private func parseGetDeviceName(val:[UInt8],success:@escaping((String?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            let newVal = val[5...(val.count-1)]
            let newData = newVal.withUnsafeBufferPointer { (bytes) -> Data in
                return Data.init(buffer: bytes)
            }
            let string = String.init(data: newData, encoding: .utf8) ?? "nil"//String.init(format: "%@", newData as CVarArg)
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(string, .none)
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取固件版本号 0x02
    @objc public func getFirmwareVersion(_ success:@escaping((String?,ZyError)->Void)) {
        
        var val:[UInt8] = [0x00,0x02,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetFirmwareVersionBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetFirmwareVersion(val:[UInt8],success:@escaping((String?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let versionData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                let byte = bytes.baseAddress! + 5
                return Data.init(bytes: byte, count: val.count-5)
            })
            
            let string = String.init(data: versionData, encoding: .utf8)
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string ?? ""))
            success(string,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取序列号 0x04
    @objc public func getSerialNumber(_ success:@escaping((String?,ZyError)->Void)) {
        
        var val:[UInt8] = [0x00,0x04,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)

        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetSerialNumberBlock = success
        }else{
            
            success(nil,state)
        }
    }
    
    private func parseGetSerialNumber(val:[UInt8],success:@escaping((String?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let newVal = val[5...(val.count-1)]
            let newData = newVal.withUnsafeBufferPointer { (bytes) -> Data in
                return Data.init(buffer: bytes)
            }
            let string = String.init(data: newData, encoding: .utf8) ?? "nil"//String.init(format: "%@", newData as CVarArg)
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(string,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取mac地址 0x06
    @objc public func getMac(_ success:@escaping((String?,ZyError)->Void)) {
        
        var val:[UInt8] = [0x00,0x06,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetMacBlock = success
        }else{
            
            success(nil,state)
            
        }
        
    }
    
    private func privateGetMac(_ success:@escaping((String?,ZyError)->Void)) {
        printLog("privateGetMac")
        if let macString = self.macString {
            printLog("self.macString 有值")
            success(macString,.none)
        }else{
            print("self.macString = nil")
            if self.receiveGetMacBlock != nil {
                printLog("receiveGetMacBlock != nil")
                self.receivePrivateGetMacBlock = success
            }else{
                printLog("receiveGetMacBlock == nil")
                self.getMac(success)
            }
        }
    }
    
    private func parseGetMac(val:[UInt8],success:@escaping((String?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let string = String.init(format: "%02x:%02x:%02x:%02x:%02x:%02x",val[10],val[9],val[8],val[7],val[6],val[5])
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(string,.none)
            self.macString = string
            if let block = self.receivePrivateGetMacBlock {
                block(string,.none)
                self.receivePrivateGetMacBlock = nil
            }
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取电量 0x08
    @objc public func getBattery(_ success:@escaping((String?,ZyError)->Void)) {
        
        var val:[UInt8] = [0x00,0x08,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetBatteryBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetBattery(val:[UInt8],success:@escaping((String?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let string = String.init(format: "%d",val[5])
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(string,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置时间 0x09
    @objc public func setTime(time:Any? = nil,success:@escaping((ZyError) -> Void)) {
        
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
        
        var val:[UInt8] = [0x00,0x09,0x0b,0x00,UInt8(year/100),UInt8(year%100),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetTimeBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetTime(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取产品、固件、资源等版本信息 0x0E
    @objc public func getDeviceOtaVersionInfo(_ success:@escaping(([String:Any],ZyError)->Void)) {
        
        var val:[UInt8] = [0x00,0x0E,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDeviceOtaVersionInfo = success
        }else{
            success([:],state)
        }
    }
    
    private func privateGetOtaVersionInfo(_ success:@escaping(([String:Any],ZyError)->Void)) {
        printLog("privateGetOtaVersionInfo")
        if let otaInfo = self.otaVersionInfo {
            printLog("self.otaVersionInfo 有值")
            success(otaInfo,.none)
        }else{
            print("self.otaVersionInfo = nil")
            if self.receiveGetDeviceOtaVersionInfo != nil {
                printLog("receiveGetDeviceOtaVersionInfo != nil")
                self.receivePrivateGetDeviceOtaVersionInfo = success
            }else{
                printLog("receiveGetDeviceOtaVersionInfo == nil")
                self.getDeviceOtaVersionInfo(success)
            }
        }
    }
    
    private func parseGetDeviceOtaVersionInfo(val:[UInt8],success:@escaping(([String:Any],ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let product = (Int(val[5]) | Int(val[6]) << 8 )
            let project = (Int(val[7]) | Int(val[8]) << 8 )
            let boot = String.init(format: "%d.%d", val[9],val[10])
            let firmware = String.init(format: "%d.%d", val[11],val[12])
            let library = String.init(format: "%d.%d", val[13],val[14])
            let font = String.init(format: "%d.%d", val[15],val[16])
            
            let string = String.init(format: "\nproduct:%d\nproject:%d\nfirmware:%@\nlibrary:%@\nfont:%@", product,project,firmware,library,font)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(["product":"\(product)","project":"\(project)","boot":boot,"firmware":firmware,"library":library,"font":font],.none)
            self.otaVersionInfo = ["product":"\(product)","project":"\(project)","boot":boot,"firmware":firmware,"library":library,"font":font]
            if let block = self.receivePrivateGetDeviceOtaVersionInfo  {
                block(self.otaVersionInfo!,.none)
                self.receivePrivateGetDeviceOtaVersionInfo = nil
            }
            
        }else{
            success([:],.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设备设置 0x01
    // MARK: - 获取个人信息 0x00
    @objc public func getPersonalInformation(_ success:@escaping((ZyPersonalModel?,ZyError) -> Void)) {
        
        
        var val:[UInt8] = [0x01,0x00,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetPersonalInformationBlock = success
        }else{
            success(nil,state)
        }
        
    }
    
    private func parseGetPersonalInformation(val:[UInt8],success:@escaping((ZyPersonalModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let age = val[5]
            let gender = val[6]
            let height = (Int(val[7]) | Int(val[8]) << 8)
            let weight = (Int(val[9]) | Int(val[10]) << 8)
            
            let heightString = String.init(format: "%.1f", Float(height)/10.0)
            let weightString = String.init(format: "%.1f", Float(weight)/10.0)
            
            let string = String.init(format: "年龄:%d,性别:%@,身高:%@,体重:%@", age,gender == 0 ? "男":"女",heightString,weightString)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = ZyPersonalModel.init()
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
    @objc public func setPersonalInformation(model:ZyPersonalModel,success:@escaping((ZyError) -> Void)) {
        
        let heightFloat = Int(model.height * 10)
        let weightFloat = Int(model.weight * 10)
        let gender = model.gender == false ? 0 : 1
        
        var val:[UInt8] = [0x01,0x01,0x0a,0x00,UInt8(model.age),UInt8(gender),UInt8((heightFloat ) & 0xff), UInt8((heightFloat >> 8) & 0xff),UInt8((weightFloat ) & 0xff), UInt8((weightFloat >> 8) & 0xff)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetPersonalInformationBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetPersonalInformation(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取时间制式 0x02
    @objc public func getTimeFormat(_ success:@escaping((Int,ZyError) -> Void)) {
        
        
        var val:[UInt8] = [0x01,0x02,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetTimeFormatBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetTimeFormat(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let timeFormat = val[5]
            let string = String.init(format: "时间制:%@",timeFormat == 0 ? "24小时制":"12小时制")
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(timeFormat),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置时间制式 0x03
    @objc public func setTimeFormat(format:Int,success:@escaping((ZyError) -> Void)) {
        var format = format
        if format > UInt8.max || format < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            format = 0
        }
        var val:[UInt8] = [0x01,0x03,0x05,0x00,UInt8(format)]
        let data = Data.init(bytes: &val, count: val.count)
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetTimeFormatBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetTimeFormat(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let string = ""
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取公英制 0x04
    @objc public func getMetricSystem(_ success:@escaping((Int,ZyError) -> Void)) {
        
        
        var val:[UInt8] = [0x01,0x04,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetMetricSystemBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetMetricSystem(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            let metricSystem = val[5]
            let string = String.init(format: "公英制:%@",metricSystem == 0 ? "公制":"英制")
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(metricSystem),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置公英制 0x05
    @objc public func setMetricSystem(metric:Int,success:@escaping((ZyError) -> Void)) {
        
        var metric = metric
        if metric > UInt8.max || metric < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            metric = 0
        }
        var val:[UInt8] = [0x01,0x05,0x05,0x00,UInt8(metric)]
        let data = Data.init(bytes: &val, count: val.count)
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetMetricSystemBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetMetricSystem(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置天气 0x07
    @objc public func setWeather(model:ZyWeatherModel,updateTime:String? = nil,success:@escaping((ZyError) -> Void)) {
        
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
        if self.functionListModel?.functionList_weatherExtend == true {

            var date = Date.init()

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
//            let formatRegex = "(\\d{4})-(\\d{2})-(\\d{2}) (\\d{2}):(\\d{2}):(\\d{2})"
//            let pre = NSPredicate.init(format: "SELF MATCHES %@", formatRegex)
//            let result = pre.evaluate(with: time)
//            if !result {
//                let currentTime = Date().conversionDateToString(DateFormat: "yyyy-MM-dd HH:mm:ss")
//                self.logView.writeString(string: "\(time)格式显示输入错误,更改为当前时间:\(currentTime)")
//                print("\(time)格式显示输入错误,更改为当前时间:\(currentTime)")
//                time = currentTime
//            }
            
            if let time = updateTime {
                date = timeFormatter.date(from: time) ?? .init()
            }

            let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            let second = calendar.component(.second, from: date)

            let year_0 = ((year) & 0xff)
            let year_1 = ((year >> 8) & 0xff)
            print("year_0 = \(year_0),year_1 =\(year_1)",String.init(format: "%02x,%02x", year_0,year_1))
            
            let year_2:Int8 = Int8(bitPattern: UInt8(year_0))
            let year_3:Int8 = Int8(bitPattern: UInt8(year_1))
            print("year_2 = \(year_2),year_3 =\(year_3)",String.init(format: "%02x,%02x", year_2,year_3))
            
            val = [
                0x01,
                0x43,
                0x13,
                0x00,
                Int8(bitPattern: UInt8((year) & 0xff)),
                Int8(bitPattern: UInt8((year >> 8) & 0xff)),
                Int8(month),
                Int8(day),
                Int8(hour),
                Int8(minute),
                Int8(second),
                Int8(model.dayCount),
                Int8(model.type.rawValue),
                Int8(model.temp),
                Int8(model.airQuality),
                Int8(model.minTemp),
                Int8(model.maxTemp),
                Int8(model.tomorrowMinTemp),
                Int8(model.tomorrowMaxTemp),
            ]
        }
        
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetWeatherBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetWeather(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置进入拍照模式 0x09
    @objc public func setEnterCamera(success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x09,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetEnterCameraBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetEnterCamera(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 寻找手环 0x0b
    @objc public func setFindDevice(success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x0b,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetFindDeviceBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetFindDevice(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取抬腕亮屏 0x0c
    @objc public func getLightScreen(_ success:@escaping((Int,ZyError) -> Void)) {
        
        
        var val:[UInt8] = [0x01,0x0c,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLightScreenBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetLightScreen(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let string = String.init(format: "%@",isOpen == 0 ? NSLocalizedString("Shut down", comment: "关闭"):"开启")
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(isOpen),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置抬腕亮屏 0x0d
    @objc public func setLightScreen(isOpen:Int,success:@escaping((ZyError) -> Void)) {
        var isOpen = isOpen
        if isOpen > UInt8.max || isOpen < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            isOpen = 0
        }
        var val:[UInt8] = [
            0x01,
            0x0d,
            0x05,
            0x00,
            UInt8(isOpen)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLightScreenBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetLightScreen(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取屏幕亮度 0x0e
    @objc public func getScreenLevel(_ success:@escaping((Int,ZyError) -> Void)) {
        
        var val:[UInt8] = [0x01,0x0e,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetScreenLevelBlock = success
        }else{
            success(0,state)
        }
        
    }
    
    private func parseGetScreenLevel(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let level = val[5]
            let string = String.init(format: "亮度:%d",level)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(level),.none)
            
        }else{
            success(0,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置屏幕亮度 0x0f
    @objc public func setScreenLevel(value:Int,success:@escaping((ZyError) -> Void)) {
        var value = value
        if value > UInt8.max || value < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            value = 0
        }
        var val:[UInt8] = [
            0x01,
            0x0f,
            0x05,
            0x00,
            UInt8(value),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetScreenLevelBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetScreenLevel(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取屏幕时长 0x32
    @objc public func getScreenTimeLong(_ success:@escaping((Int,ZyError) -> Void)) {
        
        var val:[UInt8] = [0x01,0x32,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetScreenTimeLongBlock = success
        }else{
            success(0,state)
        }
        
    }
    
    private func parseGetScreenTimeLong(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let timeLong = val[5]
            let string = String.init(format: "时长:%d",timeLong)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(timeLong),.none)
            
        }else{
            success(0,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置屏幕时长 0x33
    @objc public func setScreenTimeLong(value:Int,success:@escaping((ZyError) -> Void)) {
        var value = value
        if value > UInt8.max || value < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            value = 0
        }
        var val:[UInt8] = [
            0x01,
            0x33,
            0x05,
            0x00,
            UInt8(value),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetScreenTimeLongBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetScreenTimeLong(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取本地表盘 0x10
    @objc public func getLocalDial(_ success:@escaping((Int,ZyError) -> Void)) {
        
        var val:[UInt8] = [0x01,0x10,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLocalDialBlock = success
        }else{
            success(-1,state)
        }
    }
    
    private func parseGetLocalDial(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let index = val[5]
            let string = String.init(format: "本地表盘:%d",index)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(index),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置本地表盘 0x11
    @objc public func setLocalDial(index:Int,success:@escaping((ZyError) -> Void)) {
        var index = index
        if index > UInt8.max || index < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            index = 0
        }
        var val:[UInt8] = [
            0x01,
            0x11,
            0x05,
            0x00,
            UInt8(index)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLocalDialBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetLocalDial(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取闹钟 0x12
    @objc public func getAlarm(index:Int,success:@escaping((ZyAlarmModel?,ZyError) -> Void)) {
        var index = index
        if index > UInt8.max || index < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            index = 0
        }
        var val:[UInt8] = [0x01,0x12,0x05,0x00,UInt8(index)]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetAlarmBlock = success
        }else{
            success(nil,state)
        }
        
    }
    
    private func parseGetAlarm(val:[UInt8],success:@escaping((ZyAlarmModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            //            let alarm = ZyAlarmModel.init()
            
            let index = val[5]
            let repeatCount = val[6]
            let hour = val[7]
            let minute = val[8]
            let string = String.init(format: "序号:%d,重复:%d,小时:%d,分钟:%d",index,repeatCount,hour,minute)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = ZyAlarmModel.init(dic: ["index":"\(index)","repeatCount":"\(repeatCount)","hour":String.init(format: "%02d", hour),"minute":String.init(format: "%02d", minute)])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置闹钟 0x13
    @objc public func setAlarm(index:String,repeatCount:String,hour:String,minute:String,success:@escaping((ZyError) -> Void)) {
        
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
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetAlarmBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetAlarm(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    @objc public func setAlarmModel(model:ZyAlarmModel,success:@escaping((ZyError) -> Void)) {
        
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
        
        var hour = model.alarmHour
        var minute = model.alarmMinute
        if !model.isValid {
            hour = 255
            minute = 255
        }
        
        var val:[UInt8] = [
            0x01,
            0x13,
            0x08,
            0x00,
            UInt8(index),
            UInt8(repeatCount),
            UInt8(hour),
            UInt8(minute)
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
    @objc public func getDeviceLanguage(_ success:@escaping((Int,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x14,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDeviceLanguageBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetDeviceLanguage(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let index = val[5]
            let string = String.init(format: "序号:%d",index)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(index),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置设备语言 0x15
    @objc public func setDeviceLanguage(index:Int,success:@escaping((ZyError) -> Void)) {
        var index = index
        if index > UInt8.max || index < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            index = 0
        }
        var val:[UInt8] = [
            0x01,
            0x15,
            0x05,
            0x00,
            UInt8(index)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDeviceLanguageBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetDeviceLanguage(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取目标步数 0x16
    @objc public func getStepGoal(_ success:@escaping((Int,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x16,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetStepGoalBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetStepGoal(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let goalCount = (Int(val[5]) | Int(val[6]) << 8 | Int(val[7]) << 16 | Int(val[8]) << 24 )
            let string = String.init(format: "%d",goalCount)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(goalCount),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置目标步数 0x17
    @objc public func setStepGoal(target:Int,success:@escaping((ZyError) -> Void)) {
        
        var goal:Int = target
        if goal > UInt32.max || goal < UInt32.min {
            print("输入参数超过范围,改为默认值0")
            goal = 0
        }
        
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
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetStepGoalBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetStepGoal(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取显示方式 0x18
    @objc public func getDispalyMode(_ success:@escaping((Int,ZyError) -> Void)) {
        //vertical竖   horizontal横
        var val:[UInt8] = [
            0x01,
            0x18,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDispalyModeBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetDispalyMode(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isV = val[5]
            let string = String.init(format: "%@",isV == 0 ? "0横屏":"1竖屏")
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,isV))
            success(Int(isV),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置显示方式 0x19
    @objc public func setDispalyMode(isVertical:Int,success:@escaping((ZyError) -> Void)) {
        var isVertical = isVertical
        if isVertical > UInt8.max || isVertical < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            isVertical = 0
        }
        var val:[UInt8] = [
            0x01,
            0x19,
            0x05,
            0x00,
            UInt8(isVertical)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDispalyModeBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetDispalyMode(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取佩戴方式 0x1a
    @objc public func getWearingWay(_ success:@escaping((Int,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x1a,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetWearingWayBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseGetWearingWay(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isLeft = val[5]
            let string = String.init(format: "%@",isLeft == 0 ? "0左手":"1右手")
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(isLeft),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置佩戴方式 0x1b
    @objc public func setWearingWay(isLeftHand:Int,success:@escaping((ZyError) -> Void)) {
        var isLeftHand = isLeftHand
        if isLeftHand > UInt8.max || isLeftHand < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            isLeftHand = 0
        }
        var val:[UInt8] = [
            0x01,
            0x1b,
            0x05,
            0x00,
            UInt8(isLeftHand)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetWearingWayBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetWearingWay(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置单次测量 0x1d
    @objc public func setSingleMeasurement(type:Int,isOpen:Int,success:@escaping((ZyError) -> Void)) {
        var type = type
        if type > UInt8.max || type < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            type = 0
        }
        var isOpen = isOpen
        if isOpen > UInt8.max || isOpen < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            isOpen = 0
        }
        var val:[UInt8] = [
            0x01,
            0x1d,
            0x06,
            0x00,
            UInt8(type),
            UInt8(isOpen)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSingleMeasurementBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetSingleMeasurement(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取锻炼模式 0x1e
    @objc public func getExerciseMode(_ success:@escaping((ZyExerciseType,ZyExerciseState,ZyError) -> Void)) {
        
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
            success(.runOutside,.unknow,state)
        }
        
    }
    
    private func parseGetExerciseMode(val:[UInt8],success:@escaping((ZyExerciseType,ZyExerciseState,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let type = val[5]
            let string = String.init(format: "%d",type)
            if val.count >= 7 {
                let exerciseString = String.init(format: "%d",val[6])
                ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@,锻炼状态:%@", state,string,exerciseString))
            }else{
                ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            }
            
            if let exerciseType = ZyExerciseType.init(rawValue: Int(type)) {
                if val.count >= 7 {
                    let exerciseState = ZyExerciseState.init(rawValue: Int(val[6])) ?? .unknow
                    success(exerciseType,exerciseState,.none)
                }else{
                    success(exerciseType,.unknow,.none)
                }
            }else{
                success(.runOutside,.unknow,.notSupport)
            }
        }else{
            success(.runOutside,.unknow,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置锻炼模式 0x1f
    @objc public func setExerciseMode(type:ZyExerciseType,isOpen:ZyExerciseState,timestamp:Int,success:@escaping((ZyError) -> Void)) {
        var type = type.rawValue
        if type > UInt8.max || type < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            type = 0
        }
        var isOpen = isOpen.rawValue
        if isOpen > UInt8.max || isOpen < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            isOpen = 0
        }
        var val:[UInt8] = [
            0x01,
            0x1f,
            0x06,
            0x00,
            UInt8(type),
            UInt8(isOpen)
        ]
        if self.functionListModel?.functionList_exerciseInteraction == true {
            let arr = [
                UInt8((timestamp ) & 0xff),
                UInt8((timestamp >> 8) & 0xff),
                UInt8((timestamp >> 16) & 0xff),
                UInt8((timestamp >> 24) & 0xff)
            ]
            val.append(contentsOf: arr)
            val[2] = UInt8(val.count)
        }
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetExerciseModeBlock = success
        }else{
            success(state)
        }
        
    }

    private func parseSetExerciseMode(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置设备模式 0x21
    @objc public func setDeviceMode(type:Int,isOpen:Int,success:@escaping((ZyError) -> Void)) {
        var type = type
        if type > UInt8.max || type < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            type = 0
        }
        var isOpen = isOpen
        if isOpen > UInt8.max || isOpen < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            isOpen = 0
        }
        var val:[UInt8] = [
            0x01,
            0x21,
            0x06,
            0x00,
            UInt8(type),
            UInt8(isOpen)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDeviceModeBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetDeviceMode(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置手机类型 0x25
    @objc public func setPhoneMode(type:Int,success:@escaping((ZyError) -> Void)) {
        var type = type
        if type > UInt8.max || type < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            type = 0
        }
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
    
    private func parseSetPhoneMode(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取天气单位 0x28
    @objc public func getWeatherUnit(_ success:@escaping((Int,ZyError) -> Void)) {
        
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
    
    private func parseGetWeatherUnit(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isC = val[5]
            let string = String.init(format: "%@",isC == 0 ? "0摄氏度":"1华氏度")
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(isC),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置天气单位 0x29
    @objc public func setWeatherUnit(type:Int,success:@escaping((ZyError) -> Void)) {
        var type = type
        if type > UInt8.max || type < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            type = 0
        }
        var val:[UInt8] = [
            0x01,
            0x29,
            0x05,
            0x00,
            UInt8(type),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetWeatherUnitBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetWeatherUnit(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
        
        if val[4] == 1 {
            
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置实时数据上报开关 0x2B
    @objc public func setReportRealtimeData(isOpen:Int,success:@escaping((ZyError) -> Void)) {
        var isOpen = isOpen
        if isOpen > UInt8.max || isOpen < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            isOpen = 0
        }
        var val:[UInt8] = [
            0x01,
            0x2B,
            0x05,
            0x00,
            UInt8(isOpen),
        ]
        let data = Data.init(bytes: &val, count: val.count)
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetReportRealtimeDataBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetReportRealtimeData(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取自定义表盘 0x2C
    @objc public func getCustomDialEdit(_ success:@escaping((ZyCustomDialModel?,ZyError) -> Void)) {
        
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
    
    private func parseGetCustomDialEdit(val:[UInt8],success:@escaping((ZyCustomDialModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let colorHex = String.init(format: "0x%06x", (Int(val[5]) | Int(val[6]) << 8 | Int(val[7]) << 16))
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
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = ZyCustomDialModel.init(dic: ["colorHex":colorHex,"color":color,"positionType":"\(position)","timeUpType":"\(timeUpType)","timeDownType":"\(timeDownType)"])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置自定义表盘 0x2D
    @objc public func setCustomDialEdit(color:UIColor,positionType:String,timeUpType:String,timeDownType:String,success:@escaping((ZyError) -> Void)) {
        
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
    
    private func parseSetCustomDialEdit(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
        
        if val[4] == 1 {
            
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    @objc public func setCustomDialEdit(model:ZyCustomDialModel,success:@escaping((ZyError) -> Void)) {
        
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
    @objc public func setCustomDialEdit(image:UIImage,progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)) {
        
        self.getCustonDialFrameSize { frameSuccess, error in
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
                    
                    var sendData:Data //= self.createSendDialOtaFile(image: image)
                    if let model = self.functionListModel?.functionDetail_platformType {
                        if model.platform == 1 {
                            sendData = self.createSendJLdeviceDialOtaFile(image: image)
                        }else{
                            sendData = self.createSendDialOtaFile(image: image)
                        }
                    }else{
                        sendData = self.createSendDialOtaFile(image: image)
                    }
                    
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
    
    @objc public func setCustomDialEdit(image:UIImage,progress:@escaping((Float) -> Void),isJL_Device:Bool,success:@escaping((ZyError) -> Void)) {
        
        self.getCustonDialFrameSize { frameSuccess, error in
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
                    
                    var sendData:Data = Data()
                    if isJL_Device {
                        sendData = self.createSendJLdeviceDialOtaFile(image: image)
                    }else{
                        sendData = self.createSendDialOtaFile(image: image)
                    }
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
    
    func createSendJLdeviceDialOtaFile(image:UIImage) -> Data {
        
        var smallImage = image.changeSize(size: .init(width: self.screenSmallWidth, height: self.screenSmallHeight))
        //smallImage = smallImage.addShadowLayer(shadowWidth: 10)
        var bigImage = image//.changeSize(size: .init(width: 240, height: 240))
        
        if let screenType = self.functionListModel?.functionDetail_screenType {
            if screenType.supportType == 1 {
                smallImage = smallImage.changeCircle(fillColor: .black)
                bigImage = bigImage.changeCircle(fillColor: .black)
            }
        }
        
        let data_80Val = smallImage.toByteArray(rgba: "bgra")
        let data_80_80:Data = Data.init(bytes: data_80Val, count: data_80Val.count)
        let data_240Val = bigImage.toByteArray(rgba: "bgra")
        let data_240_240:Data = Data.init(bytes: data_240Val, count: data_240Val.count)
        
        let bigBmpPath = NSTemporaryDirectory() + "test_big.bmp"
        let bigBinPath = NSTemporaryDirectory() + "test_bigBin"
        let smallBmpPath = NSTemporaryDirectory() + "test_small.bmp"
        let smallBinPath = NSTemporaryDirectory() + "test_smallBin"
        
        if FileManager.createFile(filePath: bigBmpPath).isSuccess {
            FileManager.default.createFile(atPath: bigBmpPath, contents: data_240_240, attributes: nil)
        }
        if FileManager.createFile(filePath: smallBmpPath).isSuccess {
            FileManager.default.createFile(atPath: smallBmpPath, contents: data_80_80, attributes: nil)
        }
        if FileManager.createFile(filePath: bigBinPath).isSuccess {
            var input: [CChar] = bigBmpPath.cString(using: .utf8)!
            var output : [CChar] = bigBinPath.cString(using: .utf8)!
            let result = br28_btm_to_res_path_with_alpha(&input, Int32(self.screenBigWidth), Int32(self.screenBigHeight), &output)
            print("result big = \(result)")
        }
        if FileManager.createFile(filePath: smallBinPath).isSuccess {
            var input: [CChar] = smallBmpPath.cString(using: .utf8)!
            var output : [CChar] = smallBinPath.cString(using: .utf8)!
            let result = br28_btm_to_res_path_with_alpha(&input, Int32(self.screenSmallWidth), Int32(self.screenSmallHeight), &output)
            print("result small = \(result)")
        }

        var imageFileData = Data()

        let bigUrl = URL.init(fileURLWithPath: bigBinPath)
        let smallUrl = URL.init(fileURLWithPath: smallBinPath)
        if let bigFileData = try? Data.init(contentsOf: bigUrl) {
            if let smallFileData = try? Data.init(contentsOf: smallUrl) {
                let bigFileLength = [UInt8((bigFileData.count ) & 0xff),UInt8((bigFileData.count >> 8) & 0xff),UInt8((bigFileData.count >> 16) & 0xff),UInt8((bigFileData.count >> 24) & 0xff)]
                imageFileData.append(Data.init(bytes: bigFileLength, count: 4))
                let smallFileLength = [UInt8((smallFileData.count ) & 0xff),UInt8((smallFileData.count >> 8) & 0xff),UInt8((smallFileData.count >> 16) & 0xff),UInt8((smallFileData.count >> 24) & 0xff)]
                imageFileData.append(Data.init(bytes: smallFileLength, count: 4))
                imageFileData.append(bigFileData)
                imageFileData.append(smallFileData)
            }
        }

        printLog("imageFileData.count =",imageFileData.count)

        let data = imageFileData
        
        let date = Date.init()
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        var otaFileHeadData:[UInt8] = Array.init()
        
        let oldCount = ZyCommandModule.shareInstance.CRC32(data: data)
        let newCount = ZyCommandModule.shareInstance.CRC32(data: data)
        
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
        
        let headCrc32 = ZyCommandModule.shareInstance.CRC32(val: otaFileHeadData)
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
    
    func createSendJLdeviceDialOtaFile(image:UIImage,bigSize:CGSize,smallSize:CGSize) -> Data {
        
        var smallImage = image.changeSize(size: smallSize)
        //smallImage = smallImage.addShadowLayer(shadowWidth: 10)
        var bigImage = image.changeSize(size: bigSize)
        
        let data_80Val = smallImage.toByteArray(rgba: "bgra")
        let data_80_80:Data = Data.init(bytes: data_80Val, count: data_80Val.count)
        let data_240Val = bigImage.toByteArray(rgba: "bgra")
        let data_240_240:Data = Data.init(bytes: data_240Val, count: data_240Val.count)
        
        let bigBmpPath = NSTemporaryDirectory() + "test_big.bmp"
        let bigBinPath = NSTemporaryDirectory() + "test_bigBin"
        let smallBmpPath = NSTemporaryDirectory() + "test_small.bmp"
        let smallBinPath = NSTemporaryDirectory() + "test_smallBin"
        
        if FileManager.createFile(filePath: bigBmpPath).isSuccess {
            FileManager.default.createFile(atPath: bigBmpPath, contents: data_240_240, attributes: nil)
        }
        if FileManager.createFile(filePath: smallBmpPath).isSuccess {
            FileManager.default.createFile(atPath: smallBmpPath, contents: data_80_80, attributes: nil)
        }
        if FileManager.createFile(filePath: bigBinPath).isSuccess {
            var input: [CChar] = bigBmpPath.cString(using: .utf8)!
            var output : [CChar] = bigBinPath.cString(using: .utf8)!
            let result = br28_btm_to_res_path_with_alpha(&input, Int32(bigSize.width), Int32(bigSize.height), &output)
            print("result big = \(result)")
        }
        if FileManager.createFile(filePath: smallBinPath).isSuccess {
            var input: [CChar] = smallBmpPath.cString(using: .utf8)!
            var output : [CChar] = smallBinPath.cString(using: .utf8)!
            let result = br28_btm_to_res_path_with_alpha(&input, Int32(smallSize.width), Int32(smallSize.height), &output)
            print("result small = \(result)")
        }

        var imageFileData = Data()

        let bigUrl = URL.init(fileURLWithPath: bigBinPath)
        let smallUrl = URL.init(fileURLWithPath: smallBinPath)
        if let bigFileData = try? Data.init(contentsOf: bigUrl) {
            if let smallFileData = try? Data.init(contentsOf: smallUrl) {
                let bigFileLength = [UInt8((bigFileData.count ) & 0xff),UInt8((bigFileData.count >> 8) & 0xff),UInt8((bigFileData.count >> 16) & 0xff),UInt8((bigFileData.count >> 24) & 0xff)]
                imageFileData.append(Data.init(bytes: bigFileLength, count: 4))
                let smallFileLength = [UInt8((smallFileData.count ) & 0xff),UInt8((smallFileData.count >> 8) & 0xff),UInt8((smallFileData.count >> 16) & 0xff),UInt8((smallFileData.count >> 24) & 0xff)]
                imageFileData.append(Data.init(bytes: smallFileLength, count: 4))
                imageFileData.append(bigFileData)
                imageFileData.append(smallFileData)
            }
        }

        printLog("imageFileData.count =",imageFileData.count)

        return imageFileData
    }

    func createSendDialOtaFile(image:UIImage) -> Data {
        
        let data = self.createSendImageFile(image: image)
        
        let date = Date.init()
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        var year = calendar.component(.year, from: date)
        if year < 2000 {
            year = 2022
        }
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        var otaFileHeadData:[UInt8] = Array.init()
        
        let oldCount = ZyCommandModule.shareInstance.CRC32(data: data)
        let newCount = ZyCommandModule.shareInstance.CRC32(data: data)
        
        //固定数据  0xAA,0x55,0x01,0x05
        let otaHead:[UInt8] = [0xAA,0x55,0x01,0x05]
        //日期/时间  6字节；格式YY-MM-DD HH:MM:SS(BCD码)
        let time:[UInt8] = [UInt8(year-2000),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)]
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
        
        let headCrc32 = ZyCommandModule.shareInstance.CRC32(val: otaFileHeadData)
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
                
//        let smallImagePath = NSHomeDirectory() + "/Documents/smallImage.png"
//        let smallImageShadowPath = NSHomeDirectory() + "/Documents/smallImageShadow.png"
//        let bigImagePath = NSHomeDirectory() + "/Documents/bigImage.png"
        
        var smallImage = image.changeSize(size: .init(width: self.screenSmallWidth, height: self.screenSmallHeight))
//        if FileManager.createFile(filePath: smallImagePath).isSuccess {
//            FileManager.default.createFile(atPath: smallImagePath, contents: smallImage.pngData(), attributes: nil)
//        }
//        smallImage = smallImage.addCornerRadius(radiusWidth: 20)
//        smallImage = smallImage.addShadowLayer(shadowWidth: 15)
//        if FileManager.createFile(filePath: smallImageShadowPath).isSuccess {
//            FileManager.default.createFile(atPath: smallImageShadowPath, contents: smallImage.pngData(), attributes: nil)
//        }
        var bigImage = image//.changeSize(size: .init(width: 240, height: 240))
//        if FileManager.createFile(filePath: bigImagePath).isSuccess {
//            FileManager.default.createFile(atPath: bigImagePath, contents: bigImage.pngData(), attributes: nil)
//        }
        if let screenType = self.functionListModel?.functionDetail_screenType {
            if screenType.supportType == 1 {
                smallImage = smallImage.changeCircle(fillColor: .black)
                bigImage = bigImage.changeCircle(fillColor: .black)
            }
        }
        
        let data_80_80:Data = self.createImageBin(image: smallImage)
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
    
    func createSendImageFile(image:UIImage,bigSize:CGSize,smallSize:CGSize) -> Data {
                
//        let smallImagePath = NSHomeDirectory() + "/Documents/smallImage.png"
//        let smallImageShadowPath = NSHomeDirectory() + "/Documents/smallImageShadow.png"
//        let bigImagePath = NSHomeDirectory() + "/Documents/bigImage.png"
        
        var smallImage = image.changeSize(size: smallSize)
//        if FileManager.createFile(filePath: smallImagePath).isSuccess {
//            FileManager.default.createFile(atPath: smallImagePath, contents: smallImage.pngData(), attributes: nil)
//        }
//        smallImage = smallImage.addCornerRadius(radiusWidth: 20)
//        smallImage = smallImage.addShadowLayer(shadowWidth: 15)
//        if FileManager.createFile(filePath: smallImageShadowPath).isSuccess {
//            FileManager.default.createFile(atPath: smallImageShadowPath, contents: smallImage.pngData(), attributes: nil)
//        }
        var bigImage = image.changeSize(size: bigSize)
//        if FileManager.createFile(filePath: bigImagePath).isSuccess {
//            FileManager.default.createFile(atPath: bigImagePath, contents: bigImage.pngData(), attributes: nil)
//        }
//        if let screenType = self.functionListModel?.functionDetail_screenType {
//            if screenType.supportType == 1 {
//                smallImage = smallImage.changeCircle(fillColor: .black)
//                bigImage = bigImage.changeCircle(fillColor: .black)
//            }
//        }
        
        let data_80_80:Data = self.createImageBin(image: smallImage)
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
    @objc public func setPhoneState(state:String,success:@escaping((ZyError) -> Void)) {
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
    
    private func parseSetPhoneState(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
        
        if val[4] == 1 {
            
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: -  获取自定义表盘尺寸 0x30
    @objc public func getCustonDialFrameSize(_ success:@escaping((ZyDialFrameSizeModel?,ZyError) -> Void)) {
        
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
    
    private func parseGetCustonDialFrameSize(val:[UInt8],success:@escaping((ZyDialFrameSizeModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let bigWidth = (Int(val[5]) | Int(val[6]) << 8)
            let bigheight = (Int(val[7]) | Int(val[8]) << 8)
            let smallWidth = (Int(val[9]) | Int(val[10]) << 8)
            let smallHeight = (Int(val[11]) | Int(val[12]) << 8)
            
            let string = String.init(format: "%dx%d,%dx%d",bigWidth,bigheight,smallWidth,smallHeight)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = ZyDialFrameSizeModel.init(dic: ["bigWidth":"\(bigWidth)","bigHeight":"\(bigheight)","smallWidth":"\(smallWidth)","smallHeight":"\(smallHeight)"])
            
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取24小时心率监测 0x34
    @objc public func get24HrMonitor(_ success:@escaping((Int,ZyError) -> Void)) {
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
    
    private func parseGet24HrMonitor(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = String.init(format: "%d",val[5])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,isOpen))
            success(Int(val[5]),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置24小时心率监测 0x35
    @objc public func set24HrMonitor(isOpen:Int,success:@escaping((ZyError) -> Void)) {
        var isOpen = isOpen
        if isOpen > UInt8.max || isOpen < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            isOpen = 0
        }
        var val:[UInt8] = [
            0x01,
            0x35,
            0x05,
            0x00,
            UInt8(isOpen)
            
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSet24HrMonitorBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSet24HrMonitor(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置设备进入或退出拍照模式 0x37
    @objc public func setEnterOrExitCamera(isOpen:Int,success:@escaping((ZyError) -> Void)) {
        var isOpen = isOpen
        if isOpen > UInt8.max || isOpen < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            isOpen = 0
        }
        var val:[UInt8] = [
            0x01,
            0x37,
            0x05,
            0x00,
            UInt8(isOpen)
            
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetEnterOrExitCameraBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetEnterOrExitCamera(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置设备UUID 0x39
    @objc public func setDeviceUUID(uuidString:String? = nil,success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x39,
            0x14,
            0x00,
        ]
        
        var uuidStr = ""
        if let mac = uuidString {
            uuidStr = mac
        }else{
            uuidStr = self.peripheral?.identifier.uuidString.replacingOccurrences(of: "-", with: "") ?? ""
        }
        for i in stride(from: 0, to: uuidStr.count/2, by: 1) {
            let indexCount = i*2
            let string = "" + uuidStr.dropFirst(indexCount).dropLast(uuidStr.count-indexCount-2)
            let value = self.hexStringToInt(from: string)
            val.append(UInt8(value))
        }
        val[2] = UInt8(val.count)
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDeviceUUIDBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetDeviceUUID(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - app同步数据至设备 0x3b
    @objc public func setExerciseDataToDevice(type:ZyExerciseType,timeLong:Int,calories:Int,distance:Int,success:@escaping((ZyError) -> Void)) {
        var type = type.rawValue
        if type > UInt8.max || type < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            type = 0
        }
        var timeLong = timeLong
        if timeLong > UInt32.max || timeLong < UInt32.min {
            print("输入参数超过范围,改为默认值0")
            timeLong = 0
        }
        var calories = calories
        if calories > UInt32.max || calories < UInt32.min {
            print("输入参数超过范围,改为默认值0")
            calories = 0
        }
        var distance = distance
        if distance > UInt32.max || distance < UInt32.min {
            print("输入参数超过范围,改为默认值0")
            distance = 0
        }
        var val:[UInt8] = [
            0x01,
            0x3b,
            0x11,
            0x00,
            UInt8(type),
            UInt8((timeLong ) & 0xff),
            UInt8((timeLong >> 8) & 0xff),
            UInt8((timeLong >> 16) & 0xff),
            UInt8((timeLong >> 24) & 0xff),
            UInt8((calories ) & 0xff),
            UInt8((calories >> 8) & 0xff),
            UInt8((calories >> 16) & 0xff),
            UInt8((calories >> 24) & 0xff),
            UInt8((distance ) & 0xff),
            UInt8((distance >> 8) & 0xff),
            UInt8((distance >> 16) & 0xff),
            UInt8((distance >> 24) & 0xff),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetExerciseDataToDeviceBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetExerciseDataToDevice(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置清除所有数据
    @objc public func setClearAllData(_ success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x3d,
            0x04,
            0x00,
        ]
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetClearAllDataBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetClearAllData(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 绑定
    @objc public func setBind(_ success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x3f,
            0x04,
            0x00,
        ]
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetBindBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetBind(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 解绑
    @objc public func setUnbind(_ success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x01,
            0x41,
            0x04,
            0x00,
        ]
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetUnbindBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetUnbind(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设备提醒 0x02
    // MARK: - 获取消息提醒 0x00
    @objc public func getNotificationRemind(_ success:@escaping(([Int],[Int],ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x00,//
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetNotificationRemindBlock = success
        }else{
            success([],[],state)
        }
        
    }
    
    private func parseGetNotificationRemind(val:[UInt8],success:@escaping(([Int],[Int],ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            if val.count >= 11 {
                let openSwitch = (Int(val[5]) | Int(val[6]) << 8)
                let extensionSwitch = (Int(val[7]) | Int(val[8]) << 8 | Int(val[9]) << 16 | Int(val[10]) << 24)
                let string = String.init(format: "默认推送:%d,拓展推送:%d",openSwitch,extensionSwitch)
                ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
                let arr = self.getNotificationTypeArrayWithIntString(countString: "\(openSwitch)")
                let extensionArray = self.getNotificationExtensionTypeArrayWithIntString(countString: "\(extensionSwitch)")
                success(arr,extensionArray,.none)
            }else{
                let openSwitch = (Int(val[5]) | Int(val[6]) << 8)
                let string = String.init(format: "%d",openSwitch)
                ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
                let arr = self.getNotificationTypeArrayWithIntString(countString: "\(openSwitch)")
                success(arr,[],.none)
            }

        }else{
            success([],[],.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置消息提醒 0x01
    @objc public func setNotificationRemind(isOpen:String,extensionOpen:String,success:@escaping((ZyError) -> Void)) {
        
        var switchCount = UInt16(isOpen) ?? 0
        if self.functionListModel?.functionDetail_notification?.isSupportExtensionNotification == true {
            if (switchCount >> 14 & 0x01) == 0 {
                switchCount = switchCount + (1 << 14)
            }
        }
        let extensionCount = UInt32(extensionOpen) ?? 0
        var val:[UInt8] = [
            0x02,
            0x01,
            0x06,
            0x00,
            UInt8(switchCount & 0xff),
            UInt8((switchCount >> 8) & 0xff)
        ]
        
        if self.functionListModel?.functionDetail_notification?.isSupportExtensionNotification == true {
        val = [
            0x02,
            0x01,
            0x06,
            0x00,
            UInt8(switchCount & 0xff),
            UInt8((switchCount >> 8) & 0xff),
            UInt8(extensionCount & 0xff),
            UInt8((extensionCount >> 8) & 0xff),
            UInt8((extensionCount >> 16) & 0xff),
            UInt8((extensionCount >> 24) & 0xff),
        ]
        }else{
            if self.functionListModel?.functionDetail_notification?.isSupportExtensionNotification == false {
                print("功能列表不支持拓展消息开关")
            }
        }
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetNotificationRemindBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetNotificationRemind(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    @objc public func setNotificationRemindArray(array:[Int],extensionArray:[Int],success:@escaping((ZyError) -> Void)) {
        
        var switchCount = 0
        for i in stride(from: 0, to: array.count, by: 1) {
            switchCount += 1 << (array[i])
        }
        if self.functionListModel?.functionDetail_notification?.isSupportExtensionNotification == true {
            if (switchCount >> 14 & 0x01) == 0 {
                switchCount = switchCount + (1 << 14)
            }
        }
        var extensionCount = 0
        for i in stride(from: 0, to: extensionArray.count, by: 1) {
            extensionCount += 1 << (extensionArray[i])
        }
        printLog("switchCount =",switchCount)
        printLog("extensionCount =",extensionCount)
        var val:[UInt8] = [
            0x02,
            0x01,
            0x06,
            0x00,
            UInt8(switchCount & 0xff),
            UInt8((switchCount >> 8) & 0xff)
        ]
        //2024.4.3何工P5X设备去掉 extensionCount > 0 && 的判断，因为后续拓展的开关关掉如果不发4byte的长度拓展设置无法更改。不确定此操作在之前的设备是否会闪退
        if self.functionListModel?.functionDetail_notification?.isSupportExtensionNotification == true {
        val = [
            0x02,
            0x01,
            0x06,
            0x00,
            UInt8(switchCount & 0xff),
            UInt8((switchCount >> 8) & 0xff),
            UInt8(extensionCount & 0xff),
            UInt8((extensionCount >> 8) & 0xff),
            UInt8((extensionCount >> 16) & 0xff),
            UInt8((extensionCount >> 24) & 0xff),
        ]
        }else{
            if self.functionListModel?.functionDetail_notification?.isSupportExtensionNotification == false {
                print("功能列表不支持拓展消息开关")
            }
        }
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetNotificationRemindBlock = success
        }else{
            success(state)
        }
    }
    
    // MARK: - 获取久坐提醒 0x02
    @objc public func getSedentary(_ success:@escaping((ZySedentaryModel?,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x02,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetSedentaryBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetSedentary(val:[UInt8],success:@escaping((ZySedentaryModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let timeLong = val[6]
            let count = val[7]
            
            var modelArray:[ZyStartEndTimeModel] = Array.init()
            
            for i in 0..<Int(count) {
                let model = ZyStartEndTimeModel.init()
                model.startHour = Int(val[8+i*4])
                model.startMinute = Int(val[9+i*4])
                model.endHour = Int(val[10+i*4])
                model.endMinute = Int(val[11+i*4])
                modelArray.append(model)
            }
            
            let string = String.init(format: "开关:%d,时长:%d,时段数量：%d,时段数组",isOpen,timeLong,count,modelArray)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = ZySedentaryModel.init(dic: ["isOpen":"\(isOpen)","timeLong":"\(timeLong)","timeArray":modelArray])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置久坐提醒 0x03
    @objc public func setSedentary(isOpen:String,timeLong:String,timeArray:[ZyStartEndTimeModel],success:@escaping((ZyError) -> Void)) {
        
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
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSedentaryBlock = success
        }else{
            success(state)
        }
    }
    
    @objc public func setSedentary(model:ZySedentaryModel,success:@escaping((ZyError) -> Void)) {
        
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
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSedentaryBlock = success
        }else{
            success(state)
        }
    }
    
    @objc public func setSedentary(isOpen:String,timeLong:String,startHour:String,startMinute:String,endHour:String,endMinute:String,success:@escaping((ZyError) -> Void)) {
        
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
                
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSedentaryBlock = success
        }else{
            success(state)
        }
    }
    
    
    private func parseSetSedentary(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取防丢提醒 0x04
    @objc public func getLost(_ success:@escaping((Int,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x04,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLostBlock = success
        }else{
            success(-1,state)
        }
    }
    
    private func parseGetLost(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let string = String.init(format: "开关:%d")
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(isOpen),.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置防丢提醒 0x05
    @objc public func setLost(isOpen:String,success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x05,
            0x05,
            0x00,
            (UInt8(isOpen) ?? 0),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLostBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetLost(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取勿扰 0x06
    @objc public func getDoNotDisturb(_ success:@escaping((ZyDoNotDisturbModel?,ZyError) -> Void)) {
        
//        if self.functionListModel?.functionList_newPortocol == true {
//            
//            let headVal:[UInt8] = [
//                0xaa,
//                0x84
//            ]
//            
//            //参数id
//            let cmd_id = 0x18
//            
//            let contentVal:[UInt8] = [
//                0x01,
//                UInt8((cmd_id ) & 0xff),
//                UInt8((cmd_id >> 8) & 0xff),
//            ]
//            
//            self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
//                if error == .none {
//                    self?.receiveGetDoNotDisturbBlock = success
//                }else{
//                    success(nil,error)
//                }
//            }
//            
//        }else{
            var val:[UInt8] = [
                0x02,
                0x06,
                0x04,
                0x00,
            ]
            let data = Data.init(bytes: &val, count: val.count)
            
            let state = self.writeDataAndBackError(data: data)
            if state == .none {
                self.receiveGetDoNotDisturbBlock = success
            }else{
                success(nil,state)
            }
//        }
    }
    
    private func parseGetDoNotDisturb(val:[UInt8],success:@escaping((ZyDoNotDisturbModel?,ZyError) -> Void)) {
        
//        if self.functionListModel?.functionList_newPortocol == true {
//
//            if val.count == 5 {
//
//                let isOpen = val[0]
//                let startHour = val[1]
//                let startMinute = val[2]
//                let endHour = val[3]
//                let endMinute = val[4]
//
//                let string = String.init(format: "开关:%d,开始时间：%d:%d,结束时间：%d:%d",isOpen,startHour,startMinute,endHour,endMinute)
//                ZySDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
//
//                let model = ZyDoNotDisturbModel.init(dic: ["isOpen":"\(isOpen)","startHour":String.init(format: "%02d", startHour),"startMinute":String.init(format: "%02d", startMinute),"endHour":String.init(format: "%02d", endHour),"endMinute":String.init(format: "%02d", endMinute)])
//
//                success(model,.none)
//
//            }else{
//                success(nil,.invalidLength)
//            }
//
//
//        }else{
            let state = String.init(format: "%02x", val[4])
            
            if val[4] == 1 {
                
                let isOpen = val[5]
                let startHour = val[6]
                let startMinute = val[7]
                let endHour = val[8]
                let endMinute = val[9]
                let string = String.init(format: "开关:%d,开始时间：%d:%d,结束时间：%d:%d",isOpen,startHour,startMinute,endHour,endMinute)
                ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
                
                let model = ZyDoNotDisturbModel.init(dic: ["isOpen":"\(isOpen)","startHour":String.init(format: "%02d", startHour),"startMinute":String.init(format: "%02d", startMinute),"endHour":String.init(format: "%02d", endHour),"endMinute":String.init(format: "%02d", endMinute)])
                
                success(model,.none)
                
            }else{
                success(nil,.invalidState)
            }
            //printLog("第\(#line)行" , "\(#function)")
//        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置勿扰 0x07
    @objc public func setDoNotDisturb(isOpen:String,startHour:String,startMinute:String,endHour:String,endMinute:String,success:@escaping((ZyError) -> Void)) {
        
//        if self.functionListModel?.functionList_newPortocol == true {
//
//            var headVal:[UInt8] = [
//                0xaa,
//                0x83
//            ]
//
//            //参数id
//            let cmd_id = 0x18
//            //参数长度
//            let modelCount = 5
//
//            var contentVal:[UInt8] = [
//                0x01,
//                UInt8((cmd_id ) & 0xff),
//                UInt8((cmd_id >> 8) & 0xff),
//                UInt8((modelCount ) & 0xff),
//                UInt8((modelCount >> 8) & 0xff),
//                (UInt8(isOpen) ?? 0),
//                (UInt8(startHour) ?? 0),
//                (UInt8(startMinute) ?? 0),
//                (UInt8(endHour) ?? 0),
//                (UInt8(endMinute) ?? 0),
//            ]
//
//            self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
//                if error == .none {
//                    self?.receiveSetDoNotDisturbBlock = success
//                }else{
//                    success(error)
//                }
//            }
//        }else{
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
            
            let state = self.writeDataAndBackError(data: data)
            if state == .none {
                self.receiveSetDoNotDisturbBlock = success
            }else{
                success(state)
            }
//        }
    }
    
    @objc public func setDoNotDisturb(model:ZyDoNotDisturbModel,success:@escaping((ZyError) -> Void)) {
        
//        if self.functionListModel?.functionList_newPortocol == true {
//            let isOpen = model.isOpen
//            var headVal:[UInt8] = [
//                0xaa,
//                0x83
//            ]
//
//            //参数id
//            let cmd_id = 0x18
//            //参数长度
//            let modelCount = 5
//
//            var contentVal:[UInt8] = [
//                0x01,
//                UInt8((cmd_id ) & 0xff),
//                UInt8((cmd_id >> 8) & 0xff),
//                UInt8((modelCount ) & 0xff),
//                UInt8((modelCount >> 8) & 0xff),
//                isOpen == false ? 0:1,
//                UInt8(model.timeModel.startHour),
//                UInt8(model.timeModel.startMinute),
//                UInt8(model.timeModel.endHour),
//                UInt8(model.timeModel.endMinute)
//            ]
//
//            self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
//                if error == .none {
//                    self?.receiveSetDoNotDisturbBlock = success
//                }else{
//                    success(error)
//                }
//            }
//        }else{
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
            
            let state = self.writeDataAndBackError(data: data)
            if state == .none {
                self.receiveSetDoNotDisturbBlock = success
            }else{
                success(state)
            }
//        }
    }
    
    private func parseSetDoNotDisturb(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取心率预警 0x08
    @objc public func getHrWaring(_ success:@escaping((ZyHrWaringModel?,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x08,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetHrWaringBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetHrWaring(val:[UInt8],success:@escaping((ZyHrWaringModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let maxValue = val[6]
            let minValue = val[7]
            let string = String.init(format: "开关:%d,最大值：%d,最小值:%d",isOpen,maxValue,minValue)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = ZyHrWaringModel.init(dic: ["isOpen":"\(isOpen)","maxHr":"\(maxValue)","minHr":"\(minValue)"])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置心率预警 0x09
    @objc public func setHrWaring(isOpen:String,maxHr:String,minHr:String,success:@escaping((ZyError) -> Void)) {
        
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
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetHrWaringBlock = success
        }else{
            success(state)
        }
        
    }
    
    @objc public func setHrWaring(model:ZyHrWaringModel,success:@escaping((ZyError) -> Void)) {
        
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
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetHrWaringBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetHrWaring(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取生理周期 0x0a
    @objc public func getMenstrualCycle(_ success:@escaping((ZyMenstrualModel?,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x0a,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetMenstrualCycleBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetMenstrualCycle(val:[UInt8],success:@escaping((ZyMenstrualModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val.count < 15 {
            success(nil,.invalidLength)
            self.signalCommandSemaphore()
            return
        }
        if val[4] == 1 {
            
            let isOpen = val[5]
            let cycleCount = val[6]
            let menstrualCount = val[7]
            let lastYear = (Int(val[8]) | Int(val[9]) << 8)
            let lastMonth = val[10]
            let lastDay = val[11]
            let startDay = val[12]
            let remindHour = val[13]
            let remindMinute = val[14]
            let string = String.init(format: "开关:%d,周期天数:%d,经期天数:%d,上次经期日期:%04d-%02d-%02d,提前%d天提醒,提醒时间：%d:%d",isOpen,cycleCount,menstrualCount,lastYear,lastMonth,lastDay,startDay,remindHour,remindMinute)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = ZyMenstrualModel.init(dic: ["isOpen":"\(isOpen)",
                                                     "cycleCount":"\(cycleCount)",
                                                     "menstrualCount":"\(menstrualCount)",
                                                     "year":"\(lastYear)",
                                                     "month":"\(lastMonth)",
                                                     "day":"\(lastDay)",
                                                     "advanceDay":"\(startDay)",
                                                     "remindHour":"\(remindHour)",
                                                     "remindMinute":"\(remindMinute)",
                                                     ])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置生理周期 0x0b
    @objc public func setMenstrualCycle(model:ZyMenstrualModel,success:@escaping((ZyError) -> Void)) {
        let isOpen = model.isOpen
        var val:[UInt8] = [
            0x02,
            0x0b,
            0x0e,
            0x00,
            isOpen == false ? 0:1,
            UInt8(model.cycleCount),
            UInt8(model.menstrualCount),
            UInt8((model.year) & 0xff),
            UInt8((model.year >> 8) & 0xff),
            UInt8(model.month),
            UInt8(model.day),
            UInt8(model.advanceDay),
            UInt8(model.remindHour),
            UInt8(model.remindMinute),
        ]
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetMenstrualCycleBlock = success
        }else{
            success(state)
        }
    }
     
    @objc public func setMenstrualCycle(isOpen:String,cycleCount:String,menstrualCount:String,year:String,month:String,day:String,advanceDay:String,remindHour:String,remindMinute:String,success:@escaping((ZyError) -> Void)) {
        let yearCount = Int(year) ?? 0
        var val:[UInt8] = [
            0x02,
            0x0b,
            0x0e,
            0x00,
            (UInt8(isOpen) ?? 0),
            (UInt8(cycleCount) ?? 0),
            (UInt8(menstrualCount) ?? 0),
            UInt8((yearCount ) & 0xff),
            UInt8((yearCount >> 8 ) & 0xff),
            (UInt8(month) ?? 0),
            (UInt8(day) ?? 0),
            (UInt8(advanceDay) ?? 0),
            (UInt8(remindHour) ?? 0),
            (UInt8(remindMinute) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetMenstrualCycleBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetMenstrualCycle(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取洗手提醒 0x0c
    @objc public func getWashHand(_ success:@escaping(([String:Any],ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x0c,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetWashHandBlock = success
        }else{
            success([:],state)
        }
    }
    
    private func parseGetWashHand(val:[UInt8],success:@escaping(([String:Any],ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let startHour = val[6]
            let startMinute = val[7]
            let targetCount = val[8]
            let remindInterval = val[9]
            let string = String.init(format: "开关:%d,开始小时:%d,开始分钟:%d,目标次数:%d,提醒间隔:%d",isOpen,startHour,startMinute,targetCount,remindInterval)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(["ttt":"\(string)"],.none)
            
        }else{
            success([:],.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置洗手提醒 0x0d
    @objc public func setWashHand(isOpen:String,startHour:String,startMinute:String,targetCount:String,remindInterval:String,success:@escaping((ZyError) -> Void)) {
        
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
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetWashHandBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetWashHand(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取喝水提醒 0x0e
    @objc public func getDrinkWater(_ success:@escaping((ZyDrinkWaterModel?,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x0e,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDrinkWaterBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetDrinkWater(val:[UInt8],success:@escaping((ZyDrinkWaterModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        if val.count <= 10 {
            success(nil,.invalidLength)
            self.signalCommandSemaphore()
            return
        }
        if val[4] == 1 {
            
            let isOpen = val[5]
            let startHour = val[6]
            let startMinute = val[7]
            let endHour = val[8]
            let endMinute = val[9]
            let remindInterval = val[10]
            let string = String.init(format: "开关:%d,开始时间：%d:%d,结束时间：%d:%d,提醒间隔:%d",isOpen,startHour,startMinute,endHour,endMinute,remindInterval)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = ZyDrinkWaterModel.init(dic: ["isOpen":"\(isOpen)","startHour":String.init(format: "%02d", startHour),"startMinute":String.init(format: "%02d", startMinute),"endHour":String.init(format: "%02d", endHour),"endMinute":String.init(format: "%02d", endMinute),"remindInterval":"\(remindInterval)"])
            
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置喝水提醒 0x0f
    @objc public func setDrinkWater(isOpen:String,startHour:String,startMinute:String,endHour:String,endMinute:String,remindInterval:String,success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x0f,
            0x0a,
            0x00,
            (UInt8(isOpen) ?? 0),
            (UInt8(startHour) ?? 0),
            (UInt8(startMinute) ?? 0),
            (UInt8(endHour) ?? 0),
            (UInt8(endMinute) ?? 0),
            (UInt8(remindInterval) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDrinkWaterBlock = success
        }else{
            success(state)
        }
    }
    
    @objc public func setDrinkWater(model:ZyDrinkWaterModel,success:@escaping((ZyError) -> Void)) {
        let isOpen = model.isOpen
        let remindInterval = model.remindInterval
        var val:[UInt8] = [
            0x02,
            0x07,
            0x09,
            0x00,
            isOpen == false ? 0:1,
            UInt8(model.timeModel.startHour),
            UInt8(model.timeModel.startMinute),
            UInt8(model.timeModel.endHour),
            UInt8(model.timeModel.endMinute),
            UInt8(remindInterval)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDrinkWaterBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetDrinkWater(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置常用联系人 0x13
    @objc public func setAddressBook(modelArray:[ZyAddressBookModel],success:@escaping((ZyError) -> Void)) {
        
        /*
         bit0           cmd_class
         bit1           cmd_id
         bit2~5         所有数据长度(所有联系人数据，不是整个命令的长度)
         bit6           状态(默认01)
         bit7           类型(默认0)
         bit8~9         序号
         bit10~11       crc16校验(所有联系人数据，不是整个命令的长度)
         bit12          最后一个包的数据长度(所有联系人数据的最后一包长度。不包括前面4byte的固定部分)
         bit13~Total_N  联系人数据
         
         数据格式(bit13~Total_N)
         bit0~1         数据总长度
         bit2~3         联系人数量
         bit4~Model_N   联系人数据格式
         
         单个联系人数据格式(bit4~Model_N)
         bit0~1         联系人序号
         bit2           姓名长度N
         bit3           号码长度M
         bit4~N         姓名utf8
         bitN+1~M       号码utf8
         ...()
         
         张三 13755660033
         李四 0755-6128998
         {length = 47 , bytes = 0x2f 00 02 00 00 00 06 0b e5 bc a0 e4 b8 89 31 33 37 35 35 36 36 30 30 33 33 01 00 06 0c e6 9d 8e e5 9b 9b 30 37 35 35 2d 36 31 32 38 39 39 38}
         {length = 47 , bytes = 0x2f00(数据总长度) 0200(联系人数量) 0000(联系人序号) 06(姓名长度) 0b(号码长度) e5bca0e4b889(张三) 3133373535363630303333(13755660033) 0100() 06() 0c() e69d8ee59b9b(李四) 303735352d36313238393938(0755-6128998)}
         
         */
        
        let cmdClass = 0x02
        let cmdId = 0x13
        let state = 0x01
        let type = 0x00
        
        //数据格式(bit13~Total_N) bit0~3数据总长度+联系人数量
        var modelDataArray:[UInt8] = [0,0,0,0]
        for i in 0..<modelArray.count {
            let model = modelArray[i]
            let nameData = model.name.data(using: .utf8) ?? .init()
            //要限制长度<=64字符
            if nameData.count >= 64 {
                let aData = nameData.subdata(in: 0..<64)
                let str = NSString.init(data: aData, encoding:4)
                print("str = \(str)")
                
                let strUtf8 = String.init(data: aData, encoding: .utf8)
                print("strUtf8 = \(strUtf8)")
                let test = String.init(data: nameData, encoding: .utf8)
                print("nameData = \(test)")
                print("\(model.name) 长度超过64，截取为:\(String.init(format: "%@", aData as CVarArg))")
            }
            let nameValArray = nameData.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: nameData.count >= 64 ? 64 : nameData.count))
            }
            let phoneData = model.phoneNumber.data(using: .utf8) ?? .init()
            if phoneData.count >= 32 {
                print("\(model.phoneNumber) 长度超过32，截取为:\(String.init(data: phoneData.subdata(in: 0..<32), encoding: .utf8))")
            }
            let phoneValArray = phoneData.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: phoneData.count >= 32 ? 32 : phoneData.count))
            }
            
            modelDataArray.append(contentsOf: [UInt8(i & 0xff),UInt8((i >> 8) & 0xff),UInt8(nameValArray.count),UInt8(phoneValArray.count)])
            modelDataArray.append(contentsOf: nameValArray)
            modelDataArray.append(contentsOf: phoneValArray)
        }
        
        let allModelLenght = modelDataArray.count
        let modelCount = modelArray.count
        modelDataArray[0] = UInt8((allModelLenght ) & 0xff)
        modelDataArray[1] = UInt8((allModelLenght >> 8) & 0xff)
        modelDataArray[2] = UInt8((modelCount ) & 0xff)
        modelDataArray[3] = UInt8((modelCount >> 8 ) & 0xff)
        
        let crc16 = self.CRC16(val: modelDataArray)

        let testData = modelDataArray.withUnsafeBufferPointer { (bytes) -> Data in
            return Data.init(buffer: bytes)
        }
        print("modelDataArray = \(self.convertDataToSpaceHexStr(data: testData,isSend: true))")
        
        let indexCount = 1 + (allModelLenght + 8) / 16//应该能接收的所有包序号
        let lastLength = (allModelLenght - 7) > 0 ? ((allModelLenght - 7) % 16) : allModelLenght
        
        if self.peripheral?.state != .connected {
            
            success(.disconnected)
            return
            
        }
        
        if self.writeCharacteristic == nil || self.peripheral == nil {
            
            success(.invalidCharacteristic)
            return
        }

        
        DispatchQueue.global().async {

            self.semaphoreCount -= 1
            let result = self.commandSemaphore.wait(wallTimeout: DispatchWallTime.now()+5)
            if result == .timedOut {
                self.semaphoreCount += 1
            }
            
            DispatchQueue.main.async {

                printLog("发送命令 -> self.semaphoreCount =",self.semaphoreCount)
                self.receiveSetAddressBookBlock = success
                
                var delayCount = 0
                for i in stride(from: 0, to: indexCount, by: 1) {
                    var valArray:[UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]//Array.init()//(arrayLiteral: 20)
                    valArray[0] = UInt8(cmdClass)
                    valArray[1] = UInt8(cmdId)
                    if i == 0 {
                        valArray[2] = UInt8((allModelLenght ) & 0xff)
                        valArray[3] = UInt8((allModelLenght >> 8) & 0xff)
                        valArray[4] = UInt8((allModelLenght >> 16) & 0xff)
                        valArray[5] = UInt8((allModelLenght >> 24) & 0xff)
                        valArray[6] = UInt8(state)
                        valArray[7] = UInt8(type)
                        valArray[8] = UInt8((i) & 0xff)
                        valArray[9] = UInt8((i >> 8) & 0xff)
                        valArray[10] = UInt8((crc16) & 0xff)
                        valArray[11] = UInt8((crc16 >> 8) & 0xff)
                        valArray[12] = UInt8(lastLength)

                        let arr:[UInt8] = modelDataArray.count == 4 ? Array.init(modelDataArray[0..<4]) : Array.init(modelDataArray[0..<7])
                        valArray.replaceSubrange(valArray.index(0, offsetBy: 13)..<valArray.endIndex, with: arr)
                        
                    }else{
                        
                        valArray[2] = UInt8(i & 0xff)
                        valArray[3] = UInt8((i >> 8) & 0xff)
                        
                        let startIndex = ((i-1)*16+7)
                        print("startIndex = \(startIndex)")
                        if allModelLenght - ((i-1)*16) - 7 >= 16 {
                            let arr:[UInt8] = Array.init(modelDataArray[startIndex..<(startIndex+16)])
                            valArray.replaceSubrange(valArray.index(0, offsetBy: 4)..<valArray.endIndex, with: arr)
                        }else{
                            print("(allModelLenght - startIndex-1) = \((allModelLenght - startIndex-1))")
                            let arr:[UInt8] = Array.init(modelDataArray[startIndex..<allModelLenght])
                            valArray.replaceSubrange(valArray.index(0, offsetBy: 4)..<valArray.endIndex, with: arr)
                        }
                    }
                    
                    let newData = valArray.withUnsafeBufferPointer { (bytes) -> Data in
                        return Data.init(buffer: bytes)
                    }
                    
                    let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: newData,isSend: true))
                    printLog("SetAddressBook send =",dataString)
                    self.writeData(data: newData)
                    if delayCount > 5 {
                        printLog("通讯录延时0.1s")
                        delayCount = 0
                        Thread.sleep(forTimeInterval: 0.1)
                    }else{
                        delayCount += 1
                    }
                }

                //定时器计数重置
//                self.commandDetectionCount = 0
//                if self.commandDetectionTimer == nil {
//                    //检测命令发送之后是否有回复，在deviceReceivedData方法内有数据则把此定时器销毁。如果没有回复，那么5s之后把信号量回复默认值
//                    self.commandDetectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.commandDetectionTimerMethod), userInfo: nil, repeats: true)
//                }
            }
        }
    }
    
    private func parseSetAddressBook(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取低电提醒
    @objc public func getLowBatteryRemind(_ success:@escaping((ZyLowBatteryModel?,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x14,
            0x04,
            0x00,
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLowBatteryRemindBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetLowBatteryRemind(val:[UInt8],success:@escaping((ZyLowBatteryModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let isOpen = val[5]
            let remindBattery = val[6]
            let remindCount = val[7]
            let remindInterval = val[8]
            let string = String.init(format: "开关:%d,提醒电量：%d,提醒次数：%d,提醒间隔:%d",isOpen,remindBattery,remindCount,remindInterval)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            
            let model = ZyLowBatteryModel.init(dic: ["isOpen":"\(isOpen)","remindBattery":"\(remindBattery)","remindCount":"\(remindCount)","remindInterval":"\(remindInterval)"])
            
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置低电提醒
    @objc public func setLowBatteryRemind(isOpen:String,remindBattery:String,remindCount:String,remindInterval:String,success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x15,
            0x08,
            0x00,
            (UInt8(isOpen) ?? 0),
            (UInt8(remindBattery) ?? 0),
            (UInt8(remindCount) ?? 0),
            (UInt8(remindInterval) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLowBatteryRemindBlock = success
        }else{
            success(state)
        }
    }
    
    @objc public func setLowBatteryRemind(model:ZyLowBatteryModel,success:@escaping((ZyError) -> Void)) {
        let isOpen = model.isOpen
        let remindBattery = model.remindBattery
        let remindCount = model.remindCount
        let remindInterval = model.remindInterval
        var val:[UInt8] = [
            0x02,
            0x15,
            0x08,
            0x00,
            isOpen == false ? 0:1,
            UInt8(remindBattery),
            UInt8(remindCount),
            UInt8(remindInterval)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLowBatteryRemindBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetLowBatteryRemind(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置朝拜闹钟
    @objc public func setWorshipTime(_ modelArray:[ZyWorshipTimeModel],progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)){
        
        var worshipArray:[UInt8] = Array.init()
        var headArray:[UInt8] = Array.init()
         
        let date = Date.init()
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        var year = calendar.component(.year, from: date)
        if year < 2000 {
            year = 2022
        }
        var month = calendar.component(.month, from: date)
        var day = calendar.component(.day, from: date)
        
        //固定为 0xAA,0x55
        let head:[UInt8] = [0xaa,0x55]
        //日期/时间  6字节；格式YY-MM-DD HH:MM:SS(BCD码)  默认给的是此刻的时间，实际应该是发第一个model里面的时间
        var time:[UInt8] = [UInt8(self.decimalToBcd(value: year-2000)),UInt8(self.decimalToBcd(value: month)),UInt8(self.decimalToBcd(value: day)),UInt8(0),UInt8(0),UInt8(0)]
        //天总数 数组个数
        let dayCount = [UInt8(modelArray.count & 0xff),UInt8((modelArray.count >> 8) & 0xff)]

        var fileArray:[UInt8] = .init()
        for i in 0..<modelArray.count {
            let item = modelArray[i]
            if i == 0 {
                let formatter = DateFormatter.init()
                formatter.dateFormat = "yyyy-MM-dd"
                let firstDate = formatter.date(from: item.timeString) ?? Date()
                year = calendar.component(.year, from: firstDate)
                month = calendar.component(.month, from: firstDate)
                day = calendar.component(.day, from: firstDate)
                time[0] = UInt8(self.decimalToBcd(value: year-2000))
                time[1] = UInt8(self.decimalToBcd(value: month))
                time[2] = UInt8(self.decimalToBcd(value: day))
            }
            fileArray.append(UInt8(self.decimalToBcd(value: item.fajr/60)))
            fileArray.append(UInt8(self.decimalToBcd(value: item.fajr%60)))
            fileArray.append(UInt8(self.decimalToBcd(value: item.dhuhr/60)))
            fileArray.append(UInt8(self.decimalToBcd(value: item.dhuhr%60)))
            fileArray.append(UInt8(self.decimalToBcd(value: item.asr/60)))
            fileArray.append(UInt8(self.decimalToBcd(value: item.asr%60)))
            fileArray.append(UInt8(self.decimalToBcd(value: item.maghrib/60)))
            fileArray.append(UInt8(self.decimalToBcd(value: item.maghrib%60)))
            fileArray.append(UInt8(self.decimalToBcd(value: item.isha/60)))
            fileArray.append(UInt8(self.decimalToBcd(value: item.isha%60)))
        }
        
        // 文件长度 仅数据部分，不包含文件头
        let fileLength = [UInt8(fileArray.count & 0xff),UInt8((fileArray.count >> 8) & 0xff),UInt8((fileArray.count >> 16) & 0xff),UInt8((fileArray.count >> 24) & 0xff)]
        // 文件校验 仅数据部分，不包含文件头，CRC32 校验
        let fileCrc32 = [UInt8(self.CRC32(val: fileArray) & 0xff),UInt8((self.CRC32(val: fileArray) >> 8) & 0xff),UInt8((self.CRC32(val: fileArray) >> 16) & 0xff),UInt8((self.CRC32(val: fileArray) >> 24) & 0xff)]
        //预留 9byte
        var arrLength_9:[UInt8] = Array.init()
        for _ in 0..<9 {
            arrLength_9.append(0)
        }
        //文件头校验 CRC32 校验
        headArray.append(contentsOf: head)
        headArray.append(0)//版本号，默认0 后续有需求再改此值
        headArray.append(contentsOf: time)
        headArray.append(contentsOf: dayCount)
        headArray.append(contentsOf: fileLength)
        headArray.append(contentsOf: fileCrc32)
        headArray.append(contentsOf: arrLength_9)
        
        print("self.CRC32(val: headArray) = \(String.init(format: "%04x", self.CRC32(val: headArray)))")
        print("headArray = \(headArray)")
        let headArrayCrc32 = [UInt8(self.CRC32(val: headArray) & 0xff),UInt8((self.CRC32(val: headArray) >> 8) & 0xff),UInt8((self.CRC32(val: headArray) >> 16) & 0xff),UInt8((self.CRC32(val: headArray) >> 24) & 0xff)]
        
        worshipArray.append(contentsOf: headArray)
        worshipArray.append(contentsOf: headArrayCrc32)
        worshipArray.append(contentsOf: fileArray)
        
        let worshipData = Data.init(bytes: &worshipArray, count: worshipArray.count)
        //print("worshipData = \(self.convertDataToHexStr(data: worshipData))")
        self.setOtaStartUpgrade(type: 6, localFile: self.createSendOtaHead(type:6,data: worshipData), isContinue: false, progress: progress, success: success)
    }
    
    // MARK: - 设置本地音乐文件
    @objc public func setLocalMusicFile(_ fileNmae:String, localFile:Any,progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)) {
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
        guard let fileData = fileData else {return}
        
//        let val = data.withUnsafeBytes { (byte) -> [UInt8] in
//            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
//            return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
//        }
        var headArray:[UInt8] = Array.init()
        
        //固定为 0xAA,0x55
        let head:[UInt8] = [0xaa,0x55]
        //文件名
        var fileNameData:Data = fileNmae.data(using: .utf8) ?? Data.init()
        let maxLength = 45
        if fileNameData.count > maxLength {
            let componentArray = fileNmae.components(separatedBy: ".")
            if let lastString = componentArray.last {
                let typeString = "."+lastString
                let typeData = typeString.data(using: .utf8) ?? Data.init()
                fileNameData = fileNameData.subdata(in: 0..<(maxLength-typeString.count))+typeData
            }
        }
        let fileNameArray:[UInt8] = fileNameData.withUnsafeBytes { (byte) -> [UInt8] in
            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
            return [UInt8](UnsafeBufferPointer.init(start: b, count: fileNameData.count))
        }
        print("fileNmae = \(fileNmae)")
        print("fileNameData = \(self.convertDataToHexStr(data: fileNameData))")
        //文件名长度
        let fileNameLength:[UInt8] = [UInt8(fileNameArray.count)]
        // 文件长度 仅数据部分，不包含文件头
        let fileLength = [UInt8(fileData.count & 0xff),UInt8((fileData.count >> 8) & 0xff),UInt8((fileData.count >> 16) & 0xff),UInt8((fileData.count >> 24) & 0xff)]
        // 文件校验 仅数据部分，不包含文件头，CRC32 校验
        let fileCrc32 = [UInt8(self.CRC32(data: fileData) & 0xff),UInt8((self.CRC32(data: fileData) >> 8) & 0xff),UInt8((self.CRC32(data: fileData) >> 16) & 0xff),UInt8((self.CRC32(data: fileData) >> 24) & 0xff)]

        //文件头校验 CRC32 校验
        headArray.append(contentsOf: head)
        headArray.append(0)//版本号，默认0 后续有需求再改此值
        headArray.append(contentsOf: fileNameLength)
        headArray.append(contentsOf: fileNameArray)
        headArray.append(contentsOf: fileLength)
        headArray.append(contentsOf: fileCrc32)
        
        let headArrayCrc32 = [UInt8(self.CRC32(val: headArray) & 0xff),UInt8((self.CRC32(val: headArray) >> 8) & 0xff),UInt8((self.CRC32(val: headArray) >> 16) & 0xff),UInt8((self.CRC32(val: headArray) >> 24) & 0xff)]
        
        let totalData = Data.init(bytes: &headArray, count: headArray.count) + Data.init(bytes: headArrayCrc32, count: headArrayCrc32.count) + fileData

        let musicPath = NSHomeDirectory() + "/Documents/test_musicData.bin"
        if FileManager.createFile(filePath: musicPath).isSuccess {
            
            FileManager.default.createFile(atPath: musicPath, contents: self.createSendOtaHead(type: 7 ,data: totalData), attributes: nil)
        }
        self.setOtaStartUpgrade(type: 7, localFile: self.createSendOtaHead(type: 7 ,data: totalData), isContinue: false, progress: progress, success: success)
    }
    
    // MARK: - 拼接ota文件头部data
    func createSendOtaHead(type:Int,data:Data) -> Data {
        
        let data = data
        
        let date = Date.init()
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        var year = calendar.component(.year, from: date)
        if year < 2000 {
            year = 2022
        }
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)

        var otaFileHeadData:[UInt8] = Array.init()
        
        let oldCount = ZyCommandModule.shareInstance.CRC32(data: data)
        let newCount = ZyCommandModule.shareInstance.CRC32(data: data)
        
        //固定数据  0xAA,0x55,0x01,0x05
        let otaHead:[UInt8] = [0xAA,0x55,0x01,UInt8(type)]
        //日期/时间  6字节；格式YY-MM-DD HH:MM:SS(BCD码)
        let time:[UInt8] = [UInt8(self.decimalToBcd(value: year-2000)),UInt8(self.decimalToBcd(value: month)),UInt8(self.decimalToBcd(value: day)),UInt8(self.decimalToBcd(value: hour)),UInt8(self.decimalToBcd(value: minute)),UInt8(self.decimalToBcd(value: second))]
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

        let headCrc32 = ZyCommandModule.shareInstance.CRC32(val: otaFileHeadData)
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
    
    // MARK: - 同步数据 0x03
    // MARK: - 同步健康数据 0x00
    @objc public func setSyncHealthData(type:String,dayCount:String,success:@escaping((Any?,ZyError) -> Void)) {
        
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
    
    private func parseSetSyncHealthData(val:[UInt8],type:String,day:String,success:@escaping((Any?,ZyError) -> Void)) {
        //        let state = String.init(format: "%02x", val[4])
        //        ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseSetSyncHealthData待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        
        var typeString = ""
        if type == "1" {
            
            typeString = "步数"
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "第%@天,类型:%@", day,typeString))
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
                ZySDKLog.writeStringToSDKLog(string: str)
                ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", stepArray))
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
            
            let model = ZyStepModel.init(dic: ["dayCount":day.count == 0 ? "0":day,"type":type,"totalStep":"\(totalStep)","detailArray":detailArray,"step":"\(step)","calorie":"\(calorie)","distance":"\(distance)"])
            success(model,.none)
            
        }else if type == "2" {
            
            typeString = "心率"
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "第%@天,类型:%@", day,typeString))
            
            var hrArray = [Int].init()
            for i in stride(from: 0, to: val.count, by: 1) {
                hrArray.append(Int(val[i]))
            }
            //printLog("hrArray =",hrArray)
            ZySDKLog.writeStringToSDKLog(string: "心率数据")
            ZySDKLog.writeStringToSDKLog(string: "\(hrArray)")
            
            let model = ZyHrModel.init(dic: ["dayCount":day.count == 0 ? "0":day,"type":type,"detailArray":hrArray])
            success(model,.none)
            
        }else if type == "3" {
            
            typeString = "睡眠"
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "第%@天,类型:%@", day,typeString))
            
            let sleepDic = self.dealSleepData(val: val)
            let totalDeep = sleepDic["deep"] as! Int
            let totalLight = sleepDic["light"] as! Int
            let totalAwake = sleepDic["awake"] as! Int
            let sleepArray = sleepDic["originalArray"]  as! [Int]
            let modelArray = sleepDic["detailArray"] as! [String:String]
            let modelArray_filter = sleepDic["detailArray_filter"]  as! [String:String]
            
            let model = ZySleepModel.init(dic: ["dayCount":day.count == 0 ? "0":day,"type":type,"deep":"\(totalDeep)","light":"\(totalLight)","awake":"\(totalAwake)","originalArray":sleepArray,"detailArray":modelArray,"detailArray_filter":modelArray_filter])
            success(model,.none)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 同步锻炼数据 0x02
    @objc public func setSyncExerciseData(indexCount:Int,success:@escaping((ZyExerciseModel?,ZyError) -> Void)) {
        var indexCount = indexCount
        if indexCount > UInt8.max || indexCount < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            indexCount = 0
        }
        let type = 4
        var val:[UInt8] = [
            0x03,
            0x02,
            0x06,
            0x00,
            UInt8(type),
            UInt8(indexCount)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetSyncExerciseDataBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseSetSyncExerciseData(val:[UInt8],success:@escaping((ZyExerciseModel?,ZyError) -> Void)) {
        //        let state = String.init(format: "%02x", val[4])
        //        ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
        //        success("\(state)")
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseSetSyncExerciseData待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        
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
        
        let model = ZyExerciseModel.init(dic: ["startTime":startTime,"type":"\(type)","hr":"\(hr)","validTimeLength":"\(validTimeLength)","step":"\(step)","endTime":"\(endTime)","calorie":"\(calorie)","distance":"\(distance)"])
        success(model,.none)
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取设备支持的功能列表 0x04
    @objc public func getDeviceSupportList(_ success:@escaping((ZyFunctionListModel?,ZyError)->Void)) {
        
        
        var val:[UInt8] = [0x03,0x04,0x05,0x00,0x06]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDeviceSupportListBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetDeviceSupportList(val:[UInt8],success:@escaping((ZyFunctionListModel?,ZyError)->Void)) {
        /*
         bit0 锻炼功能
         bit1 计步功能（24 小时详情）
         bit2 睡眠（24 小时详情）
         bit3 心率检测（24 小时详情）
         bit4 血压检测（24 小时详情）
         bit5 血氧检测（24 小时详情）
         Bit6 消息推送
         Bit7 公英制
         Bit8 闹钟提醒
         Bit9 久坐提醒
         Bit10 目标提醒
         Bit11 振动提醒
         Bit12 勿扰模式
         Bit13 防丢提醒
         Bit14 天气
         Bit15 多国语言
         Bit16 背光控制
         Bit17 通讯录
         Bit18 在线表盘
         Bit19 自定义表盘
         Bit20 本地表盘
         Bit21 心率预警
         Bit22 生理周期
         Bit23 喝水提醒
         Bit24 抬腕亮屏
         Bit25 全天心率
         Bit26 拍照控制
         Bit27 音乐控制
         Bit28 查找手环
         Bit29 关机控制
         Bit30 重启控制
         Bit31 恢复出厂控制
         Bit32 挂断电话
         Bit33 接听电话
         Bit34 时间格式
         Bit35 手环款式
         */
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseGetDeviceSupportList待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        
        let model = ZyFunctionListModel.init(val: val)

            success(model,.none)
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
    
    // MARK: - 测试命令 0x04
    // MARK: - 关机 0x01
    @objc public func setPowerTurnOff(success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x04,
            0x01,
            0x04,
            0x00
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetPowerTurnOffBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetPowerTurnOff(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        if val.count > 4 {
            if val[4] == 1 {
                let state = String.init(format: "%02x", val[4])
                ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
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
    @objc public func setFactoryDataReset(success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x04,
            0x03,
            0x04,
            0x00
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetFactoryDataResetBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetFactoryDataReset(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        
        if val[4] == 1 {
            
            let state = String.init(format: "%02x", val[4])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 马达震动 0x05
    @objc public func setMotorVibration(type:String,success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x04,
            0x05,
            0x05,
            0x00,
            (UInt8(type) ?? 0)
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetMotorVibrationBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetMotorVibration(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        
        if val.count > 4 {
            if val[4] == 1 {
                
                let state = String.init(format: "%02x", val[4])
                ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
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
    @objc public func setRestart(success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x04,
            0x07,
            0x04,
            0x00
        ]
        let data = Data.init(bytes: &val, count: val.count)

        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetRestartBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetRestart(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        
        if val[4] == 1 {
            
            let state = String.init(format: "%02x", val[4])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设备恢复出厂设置并关机
    @objc public func setFactoryAndPowerOff(success:@escaping((ZyError) -> Void)) {
        
        if self.functionListModel?.functionList_newPortocol == false {
            success(.notSupport)
            print("不支持此命令")
            return
        }
        
        var headVal:[UInt8] = [
            0xaa,
            0x87
        ]
        
        var contentVal:[UInt8] = [
            0x0e,
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetFactoryAndPowerOffBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 设备耗电数据上报
    @objc public func setPowerConsumptionData(isOpen:Bool,timeInterval:Int,success:@escaping((ZyError) -> Void)) {
        
        if self.functionListModel?.functionList_newPortocol == false {
            success(.notSupport)
            print("不支持此命令")
            return
        }
        
        let openCount = (isOpen ? 1 : 0 ) + timeInterval << 1
        print("openCount = \(openCount)")
        var headVal:[UInt8] = [
            0xaa,
            0x87
        ]
        
        var contentVal:[UInt8] = [
            0x0f,
            UInt8(openCount)
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetPowerConsumptionDataBlock = success
            }else{
                success(error)
            }
        }
    }
        
    // MARK: - 数据主动上报 0x80
    // MARK: - 实时步数
    @objc public func reportRealTimeStep(success:@escaping((ZyStepModel?,ZyError) -> Void)) {
        self.receiveReportRealTiemStepBlock = success
    }
    
    private func parseReportRealTimeStepData(val:[UInt8],success:@escaping((ZyStepModel?,ZyError) -> Void)) {
        
        if val[4] == 1 {
            
            let step = (Int(val[5]) | Int(val[6]) << 8 | Int(val[7]) << 16 | Int(val[8]) << 24)
            var distance = 0
            var calorie = 0
            
            if val.count >= 13 {
                calorie = (Int(val[11]) | Int(val[12]) << 8)//(Int(val[9]) | Int(val[10]) << 8 | Int(val[11]) << 16 | Int(val[12]) << 24)
                distance = (Int(val[9]) | Int(val[10]) << 8)//(Int(val[13]) | Int(val[14]) << 8 | Int(val[15]) << 16 | Int(val[16]) << 24)
            }
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "实时步数 步数:%d,距离:%d,卡路里:%d",step,distance,calorie))//
            
            let model = ZyStepModel.init(dic: ["step":"\(step)","distance":"\(distance)","calorie":"\(calorie)"])
            success(model,.none)//
            
        }else{
            success(nil,.invalidState)
        }
        
    }
    
    // MARK: - 实时心率
    @objc public func reportRealTimeHr(success:@escaping(([String:Any],ZyError) -> Void)) {
        self.receiveReportRealTiemHrBlock = success
    }
    
    private func parseReportRealTimeHrData(val:[UInt8],success:@escaping(([String:Any],ZyError) -> Void)) {
        
        if val[4] == 1 {
            
            let hr = val[5]
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "实时心率 心率:%d",hr))
            success(["hr":"\(hr)"],.none)
            
        }else{
            success([:],.invalidState)
        }
    }
    
    // MARK: - 单次测量结果
    @objc public func reportSingleMeasurementResult(success:@escaping(([String:Any],ZyError) -> Void)) {
        self.receiveReportSingleMeasurementResultBlock = success
    }
    
        private func parseReportSingleMeasurementResultData(val:[UInt8],success:@escaping(([String:Any],ZyError) -> Void)) {
        
        let type = val[5]
        let value1 = val[6]
        let value2 = val[7]
        
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "单次测量结果 类型:%d,测量值1:%d,测量值2:%d",type,value1,value2))
        
        if val[4] == 2 {
            if type == 6 {
                success(["type":"\(type)","value1":"\(0)","value2":"\((Int(value2) | Int(value1) << 8))"],.none)
            }else{
                success(["type":"\(type)","value1":"\(value1)","value2":"\(value2)"],.none)
            }
            
            
        }else if val[4] != 1{
            success(["type":"\(type)","value1":"\(value1)","value2":"\(value2)"],.fail)
        }
    }
    
    // MARK: - 上报锻炼状态
    @objc public func reportExerciseState(success:@escaping((ZyExerciseState,ZyError) -> Void)) {
        self.receiveReportExerciseStateBlock = success
    }
    
    private func parseReportExerciseStateData(val:[UInt8],success:@escaping((ZyExerciseState,ZyError) -> Void)) {
        
        if val[4] == 1 {
            
            if val.count >= 6 {
                let state = ZyExerciseState.init(rawValue: Int(val[5])) ?? .unknow
                success(state,.none)
                ZySDKLog.writeStringToSDKLog(string: String.init(format: "锻炼状态 类型:%d",val[5]))
            }else{
                success(.end,.none)
            }
        }else{
            success(.unknow,.invalidState)
        }
    }
    
    // MARK: - 找手机
    @objc public func reportFindPhone(success:@escaping((ZyError) -> Void)) {
        self.receiveReportFindPhoneBlock = success
    }
    
    private func parseReportFindPhoneData(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        
        success(.none)
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "找手机"))
        
    }
    
    // MARK: - 结束找手机
    @objc public func reportEndFindPhone(success:@escaping((ZyError) -> Void)) {
        self.receiveReportEndFindPhoneBlock = success
    }
    
    private func parseReportEndFindPhoneData(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        
        success(.none)
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "结束找手机"))
        
    }
    
    // MARK: - 拍照
    @objc public func reportTakePictures(success:@escaping((ZyError) -> Void)) {
        self.receiveReportTakePicturesBlock = success
    }
    
    private func parseReportTakePicturesData(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        
        success(.none)
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "拍照"))
    }
    
    // MARK: - 设备上报进入/退出拍照 0进1退
    @objc public func reportEnterOrExitCamera(success:@escaping((Int,ZyError) -> Void)) {
        self.receiveReportEnterOrExitCameraBlock = success
    }
    
    private func parseReportEnterOrExitCameraData(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {

        if let result = val.first {
            success(Int(result),.none)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "\(result == 0 ? "进入":"退出")拍照"))
        }
        
        
    }
    
    // MARK: - 音乐控制
    @objc public func reportMusicControl(success:@escaping((Int,ZyError) -> Void)) {
        self.receiveReportMusicControlBlock = success
    }
    
    private func parseReportMusicControlData(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        
        let type = val[5]
        
        success(Int(type),.none)
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "音乐控制 类型:%d",type))
        
    }
    
    // MARK: - 来电控制 0x8E
    @objc public func reportCallControl(success:@escaping((Int,ZyError) -> Void)) {
        self.receiveReportCallControlBlock = success
    }
    
    private func parseReportCallControlData(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        
        let type = val[5]
        
        success(Int(type),.none)
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "来电控制 类型:%d",type))
        
    }
    
    // MARK: - 上报屏幕亮度 0x90
    @objc public func reportScreenLevel(success:@escaping((Int,ZyError) -> Void)) {
        self.receiveReportScreenLevelBlock = success
    }
    
    private func parseReportScreenLevel(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        
        let level = val[5]
        
        success(Int(level),.none)
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "屏幕亮度 等级:%d",level))
        
    }
    
    // MARK: - 上报屏幕时长 0x92
    @objc public func reportScreenTimeLong(success:@escaping((Int,ZyError) -> Void)) {
        self.receiveReportScreenTimeLongBlock = success
    }
    
    private func parseReportScreenTimeLong(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        
        let timeLong = val[5]
        
        success(Int(timeLong),.none)
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "亮屏时长:%d",timeLong))
        
    }
    
    // MARK: - 上报抬腕亮屏开关
    @objc public func reportLightScreen(success:@escaping((Int,ZyError) -> Void)) {
        self.receiveReportLightScreenBlock = success
    }
    
    private func parseReportLightScreen(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        
        let isOpen = val[5]
        
        success(Int(isOpen),.none)
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "抬腕亮屏 开关:%d",isOpen == 0 ? "关":"开"))
        
    }
    
    // MARK: - 上报设备震动开关
    @objc public func reportDeviceVibration(success:@escaping((Int,ZyError) -> Void)) {
        self.receiveReportDeviceVibrationBlock = success
    }
    
    private func parseReportDeviceVibration(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        
        let isOpen = val[5]
        
        success(Int(isOpen),.none)
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "设备震动 开关:%d",isOpen == 0 ? "关":"开"))
        
    }
    
    // MARK: - 上报实时 数据 0x98
    @objc public func reportNewRealtimeData(success:@escaping((ZyStepModel?,Int,Int,Int,Int,ZyError) -> Void)) {
        self.receiveReportNewRealtimeDataBlock = success
//        let val:[UInt8] = [0x80,0x98,0x10,0x00,0x01,0x35,0x00,0x01,0x27,0x00,0x00,0x36,0x01,0x62,0x80,0x4e]//[0x80,0x98,0x13,0x00,0x01,0x3f,0x00,0x01,0x27,0x00,0x00,0x58,0x1b,0x36,0x01,0x41,0x62,0x80,0x4e]
//        self.parseReportNewRealtimeData(val: val, success: success)
    }
    
    private func parseReportNewRealtimeData(val:[UInt8],success:@escaping((ZyStepModel?,Int,Int,Int,Int,ZyError) -> Void)) {
        
        if val[4] == 1 {
            
            let typeCount = (Int(val[5]) | Int(val[6]) << 8)
            var startIndex = 7
            
            var step = 0
            var distance = 0
            var calorie = 0
            var hr = 0
            var bo = 0
            var dbp = 0
            var sbp = 0
            
            for i in 0..<16 {
                let state = (typeCount >> i) & 0x01
                //string += "\nbit\(i+index*64) = \(state)"
                
                switch i {
                case 0:
                    if state != 0 {
                        step = (Int(val[startIndex]) | Int(val[startIndex+1]) << 8 | Int(val[startIndex+2]) << 16 | Int(val[startIndex+3]) << 24)
                        startIndex += 4
                    }
                    break
                case 1:
                    if state != 0 {
                        distance = (Int(val[startIndex]) | Int(val[startIndex+1]) << 8)
                        startIndex += 2
                    }
                    break
                case 2:
                    if state != 0 {
                        calorie = (Int(val[startIndex]) | Int(val[startIndex+1]) << 8)
                        startIndex += 2
                    }
                    break
                case 3:
                    if state != 0 {
                        hr = (Int(val[startIndex]))
                        startIndex += 1
                    }
                    break
                case 4:
                    if state != 0 {
                        bo = (Int(val[startIndex]))
                        startIndex += 1
                    }
                    break
                case 5:
                    if state != 0 {
                        sbp = (Int(val[startIndex]))
                        dbp = (Int(val[startIndex+1]))
                        startIndex += 2
                    }
                    break
                default:
                    break
                }
            }
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "实时数据 步数:%d,距离:%d,卡路里:%d,心率:%d,血氧:%d,血压:%d/%d",step,distance,calorie,hr,bo,sbp,dbp))//
            
            let model = ZyStepModel.init(dic: ["step":"\(step)","distance":"\(distance)","calorie":"\(calorie)"])
            success(model,hr,bo,sbp,dbp,.none)//
            
        }else{
            success(nil,-1,-1,-1,-1,.invalidState)
        }
        
    }
    
    // MARK: - 运动数据交互上报 0x9c
    @objc public func reportExerciseInteractionData(success:@escaping((_ timestamp:Int,_ step:Int,_ hr:Int,ZyError) -> Void)) {
        self.receiveReportExerciseInteractionDataBlock = success

    }
    
    private func parseReportExerciseInteractionData(val:[UInt8],success:@escaping((Int,Int,Int,ZyError) -> Void)) {
        
        if val[4] == 1 {
            
            let timestamp = (Int(val[5]) | Int(val[6]) << 8 | Int(val[7]) << 16 | Int(val[8]) << 24)
            let step = (Int(val[9]) | Int(val[10]) << 8 | Int(val[11]) << 16 | Int(val[12]) << 24)
            let hr = Int(val[13])
                        
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "运动数据交互上报 时间戳:%d,步数:%d,心率:%d",timestamp,step,hr))//
            
            success(timestamp,step,hr,.none)//
            
        }else{
            success(-1,-1,-1,.invalidState)
        }
        
    }
    
    // MARK: - 勿扰提醒上报
    @objc public func reportDoNotDisturb(success:@escaping((ZyDoNotDisturbModel?,ZyError) -> Void)) {
        self.receiveReportDoNotDisturb = success
    }
    
    private func parseReportDoNotDisturb(val:[UInt8],success:@escaping((ZyDoNotDisturbModel?,ZyError) -> Void)) {
        
        if val.count >= 5 {
            let isOpen = val[0]
            let startHour = val[1]
            let startMinute = val[2]
            let endHour = val[3]
            let endMinute = val[4]
            let string = String.init(format: "开关:%d,开始时间：%d:%d,结束时间：%d:%d",isOpen,startHour,startMinute,endHour,endMinute)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
            
            let model = ZyDoNotDisturbModel.init(dic: ["isOpen":"\(isOpen)","startHour":String.init(format: "%02d", startHour),"startMinute":String.init(format: "%02d", startMinute),"endHour":String.init(format: "%02d", endHour),"endMinute":String.init(format: "%02d", endMinute)])
            
            success(model,.none)
        }else{
            success(nil,.invalidLength)
        }
    }
    
    // MARK: - 语言上报
    @objc public func reportLanguageType(success:@escaping((Int,ZyError) -> Void)) {
        self.receiveReportLanguageType = success
    }
    
    private func parseReportLanguageType(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        if val.count >= 1 {
            let languageType = val[0]
            let string = String.init(format: "语言类型:%d",languageType)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
            
            success(Int(languageType),.none)
        }else{
            success(-1,.invalidLength)
        }
    }
    
    // MARK: - 新协议部分0xaa
    // MARK: - 新协议通用发送数据部分
    func dealNewProtocolData(headVal:[UInt8],contentVal:[UInt8],backBlock:@escaping((ZyError)->())) {
        var headVal = headVal
        var dataArray:[Data] = []
        var firstBit:UInt8 = 0
        var maxMtuCount = 0
        if let model = self.functionListModel?.functionDetail_newPortocol {
            if contentVal.count > model.maxMtuCount {
                firstBit = 128
            }
            maxMtuCount = model.maxMtuCount
            headVal.append(UInt8((contentVal.count ) & 0xff))
            headVal.append(UInt8((contentVal.count >> 8) & 0xff)+firstBit)
        }
        //判断是否要分包，分包的要再加总包数跟报序号
        if firstBit > 0 {
            var contentIndex = 0
            var packetCount = 0
            while contentIndex < contentVal.count {
                //分包添加总包数跟包序号
                let maxCount =  contentVal.count / (maxMtuCount - 10) + (contentVal.count % (maxMtuCount - 10) > 0 ? 1 : 0)
                let packetVal:[UInt8] = [
                    UInt8((maxCount ) & 0xff),
                    UInt8((maxCount >> 8) & 0xff),
                    UInt8((packetCount+1 ) & 0xff),
                    UInt8(((packetCount+1) >> 8) & 0xff)
                ]
                
                //嵌入式何工把长度这部分修改为 多包也只发当前包的长度
                if packetCount < maxCount - 1 {
                    headVal[headVal.count-1] = UInt8(((maxMtuCount - 10) >> 8) & 0xff) + firstBit
                    headVal[headVal.count-2] = UInt8(((maxMtuCount - 10)) & 0xff)
                }else{
                    let countValue = contentVal.count - packetCount * (maxMtuCount - 10)
                    headVal[headVal.count-1] = UInt8((countValue >> 8) & 0xff) + firstBit
                    headVal[headVal.count-2] = UInt8((countValue) & 0xff)
                }
                let startIndex = packetCount*(maxMtuCount - 10)
                //print("(packetCount+1)*(maxMtuCount - 10) = \((packetCount+1)*(maxMtuCount - 10)),(startIndex + contentVal.count - packetCount*(maxMtuCount - 10)) = \((startIndex + contentVal.count - packetCount*(maxMtuCount - 10)))")
                let endIndex = (packetCount+1)*(maxMtuCount - 10) <= contentVal.count ? (packetCount+1)*(maxMtuCount - 10) : (startIndex + contentVal.count - packetCount*(maxMtuCount - 10))
                let subContentVal =  Array(contentVal[startIndex..<endIndex])
                                
                var val = headVal + packetVal + subContentVal
                
                let check = CRC16(val: val)
                let checkVal = [UInt8((check ) & 0xff),UInt8((check >> 8) & 0xff)]
                
                val += checkVal
                
                let data = Data.init(bytes: &val, count: val.count)
                dataArray.append(data)
                
                packetCount += 1
                contentIndex = endIndex
            }
//            {
//                //分包添加总包数跟包序号
//                let maxCount =  contentVal.count / (maxMtuCount - 10) + (contentVal.count % (maxMtuCount - 10) > 0 ? 1 : 0)
//                let packetVal:[UInt8] = [
//                    UInt8((maxCount ) & 0xff),
//                    UInt8((maxCount >> 8) & 0xff),
//                    UInt8((packetCount ) & 0xff),
//                    UInt8((packetCount >> 8) & 0xff)
//                ]
//                
//                let startIndex = packetCount*(maxMtuCount - 10)
//                //print("(packetCount+1)*(maxMtuCount - 10) = \((packetCount+1)*(maxMtuCount - 10)),(startIndex + contentVal.count - packetCount*(maxMtuCount - 10)) = \((startIndex + contentVal.count - packetCount*(maxMtuCount - 10)))")
//                let endIndex = (packetCount+1)*(maxMtuCount - 10) <= contentVal.count ? (packetCount+1)*(maxMtuCount - 10) : (startIndex + contentVal.count - packetCount*(maxMtuCount - 10))
//                let subContentVal =  Array(contentVal[startIndex..<endIndex])
//                                
//                var val = headVal + packetVal + subContentVal
//                
//                let check = CRC16(val: val)
//                let checkVal = [UInt8((check ) & 0xff),UInt8((check >> 8) & 0xff)]
//                
//                val += checkVal
//                
//                let data = Data.init(bytes: &val, count: val.count)
//                dataArray.append(data)
//                
//                packetCount += 1
//                contentIndex = endIndex
//            }
            
        }else{
            var val = headVal + contentVal
            let check = CRC16(val: val)
            let checkVal = [UInt8((check ) & 0xff),UInt8((check >> 8) & 0xff)]
            
            val += checkVal
            
            let data = Data.init(bytes: &val, count: val.count)
            dataArray.append(data)
        }
        
        if dataArray.count > 1 {
            
            if self.peripheral?.state != .connected {
                
                backBlock(.disconnected)
                return
            }
            
            if self.writeCharacteristic == nil || self.peripheral == nil {
                
                backBlock(.invalidCharacteristic)
                return
            }

            
            DispatchQueue.global().async {

                self.semaphoreCount -= 1
                let result = self.commandSemaphore.wait(wallTimeout: DispatchWallTime.now()+5)
                if result == .timedOut {
                    self.semaphoreCount += 1
                }
                
                DispatchQueue.main.async {

                    printLog("发送命令 -> self.semaphoreCount =",self.semaphoreCount)
                    backBlock(.none)
                    
                    var delayCount = 0
                    for item in dataArray {
                        let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: item,isSend: true))
                        printLog("setNewSyncHealthData send =",dataString)
                        self.writeData(data: item)
                        if delayCount > 5 {
                            printLog("通讯录延时0.1s")
                            delayCount = 0
                            Thread.sleep(forTimeInterval: 0.1)
                        }else{
                            delayCount += 1
                        }
                    }
                }
            }

        }else{
            if let data = dataArray.first {
                let state = self.writeDataAndBackError(data: data)
                backBlock(state)
            }
        }
    }
    
    // MARK: - 新协议通用回复
    func parseNewProtocolUniversalResponse(result:UInt8,success:@escaping((ZyError) -> Void)) {
        
        let state = String.init(format: "%02x",result)
        
        switch result {
        case 0:
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            break
        case 1:
            success(.fail)
            break
        case 3:
            success(.notSupport)
            break
        default:
            success(.invalidState)
            break
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
        
    // MARK: - 同步数据
    /// 同步数据
    /// - Parameters:
    ///   - type: 1：步数，2：心率，3：睡眠，4、锻炼数据 5锻炼数据基础信息
    ///   - indexArray: <#indexArray description#>
    ///   - success: <#success description#>
    @objc public func setNewSyncHealthData(type:Int,indexArray:[Int],success:@escaping((Any?,ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。请使用setSyncHealthData或setSyncExerciseData")
            return
        }
        
        if type < 1 || type > 5 {
            print("输入参数超过范围,返回失败")
            success(nil,.fail)
            return
        }
        var indexArray = indexArray
        if indexArray.count == 0 {
            indexArray = [0]
        }
        var headVal:[UInt8] = [
            0xaa,
            0x85
        ]
        var contentVal:[UInt8] = [
            UInt8(type),
            UInt8(indexArray.count)
        ]
        for item in indexArray {
            contentVal.append(UInt8(item))
        }
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none{
                self?.receiveNewSetSyncHealthDataBlock = success
            }else{
                success(nil,error)
            }
        }
    }
    
    private func parseSetNewSyncHealthData(val:[UInt8],success:@escaping((Any?,ZyError) -> Void)) {

//        var str = "03020068 01ffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff  ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aaaaaaaa aa016801 ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff  ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff fd555555 55555555 555aa955 55555556 95555556 55555555 5555556a a5555555 95555555 55555555 55ffffff ffffffff  ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff"
//        str = str.replacingOccurrences(of: " ", with: "")
//
//        var val = [UInt8]()
//        for i in 0..<str.count/2 {
//        let startIndex = str.index(str.startIndex,offsetBy: i*2)
//        let endIndex = str.index(str.startIndex,offsetBy: (i+1)*2)
//        let value = String.init(format: "%@", str.substring(with: (startIndex..<endIndex)))
//        let intValue = self.hexStringToInt(from: value)
//        val.append(UInt8(intValue))
//        }
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }
//        print("valArray = \(self.convertDataToHexStr(data: valData))")

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseSetNewSyncHealthData待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        var syncDic = [String:Any?]()
        
        let type = val[0]
        var count:Int = Int(val[1])
        var valIndex = 2
/*{length = 58 , bytes = 0xaa 05 34 00 05 0a 00 00 00 00 00 01 00 00 00 00 02 00 00 00 00 03 00 00 00 00 04 00 00 00 00 05 00 00 00 00 06 00 00 00 00 07 00 00 00 00 08 00 00 00 00 09 00 00 00 00 fe ae}*/
        while valIndex < val.count {
            let number = val[valIndex]
            var length:Int = 0
            var countLength = 2
            if type == 5 {
                countLength = 5
                let gpsLength = (Int(val[valIndex+1]) | Int(val[valIndex+2]) << 8 | Int(val[valIndex+3]) << 16 | Int(val[valIndex+4]) << 24)
                if gpsLength > 0 {
                    length = 4
                    countLength = 10
                    syncDic["\(number)"] = NSNull()
                    let modelVal:[UInt8] = Array(val[valIndex..<(valIndex+countLength+Int(length))])
                    syncDic["\(number)"] = self.getNewProtocalHealthModel(type: Int(type), day: Int(number), val: modelVal, isGpsLengthCheck: true)
                }
            }else{
                length = Int(val[valIndex+1])
                if type == 2 || type == 3 {
                    length = (Int(val[valIndex+1]) | Int(val[valIndex+2]) << 8)
                    countLength = 3
                }
                if type == 4 {
                    if Int(val[valIndex+1]) == 255 {
                        length = (Int(val[valIndex+2]) | Int(val[valIndex+3]) << 8 | Int(val[valIndex+4]) << 16 | Int(val[valIndex+5]) << 24)
                        countLength = 6
                    }
                }
                syncDic["\(number)"] = NSNull()
                if length > 0 {
                    let modelVal:[UInt8] = Array(val[valIndex+countLength..<(valIndex+countLength+Int(length))])
                    syncDic["\(number)"] = self.getNewProtocalHealthModel(type: Int(type), day: Int(number), val: modelVal, isGpsLengthCheck: true)
                }
            }
            valIndex = (valIndex+countLength+Int(length))
        }
        if syncDic.keys.count != count {
            ZySDKLog.writeStringToSDKLog(string: "数据获取条数不一致: 总数:\(count),实际接收:\(syncDic.keys.count)")
        }
        success(syncDic,.none)
        self.signalCommandSemaphore()
    }
    
    func getNewProtocalHealthModel(type:Int,day:Int,val:[UInt8],isGpsLengthCheck:Bool? = false) -> Any? {
        var typeString = ""
        if type == 1 {
            
            typeString = "步数"
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "第%d天,类型:%@", day,typeString))
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
                ZySDKLog.writeStringToSDKLog(string: str)
                ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@", stepArray))
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
            
            let model = ZyStepModel.init(dic: ["type":type,"totalStep":"\(totalStep)","detailArray":detailArray,"step":"\(step)","calorie":"\(calorie)","distance":"\(distance)"])
            return model
        }else if type == 2 {
            
            typeString = "心率"
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "第%d天,类型:%@", day,typeString))
            
            var hrArray = [Int].init()
            for i in stride(from: 0, to: val.count, by: 1) {
                hrArray.append(Int(val[i]))
            }
            //printLog("hrArray =",hrArray)
            ZySDKLog.writeStringToSDKLog(string: "心率数据")
            ZySDKLog.writeStringToSDKLog(string: "\(hrArray)")
            
            let model = ZyHrModel.init(dic: ["type":type,"detailArray":hrArray])
            return model
        }else if type == 3 {
            
            typeString = "睡眠"
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "第%d天,类型:%@", day,typeString))
            
            let sleepDic = self.dealSleepData(val: val)
            let totalDeep = sleepDic["deep"] as! Int
            let totalLight = sleepDic["light"] as! Int
            let totalAwake = sleepDic["awake"] as! Int
            let sleepArray = sleepDic["originalArray"]  as! [Int]
            let modelArray = sleepDic["detailArray"] as! [[String:String]]
            let modelArray_filter = sleepDic["detailArray_filter"]  as! [[String:String]]
            
            let model = ZySleepModel.init(dic: ["type":type,"deep":"\(totalDeep)","light":"\(totalLight)","awake":"\(totalAwake)","originalArray":sleepArray,"detailArray":modelArray,"detailArray_filter":modelArray_filter])
            return model
        }else if type == 4 {
            
            let startTime = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", (Int(val[0]) | (Int(val[1]) << 8)),val[2],val[3],val[5],val[6],val[7])
            let type = val[8]
            let hr = val[9]
            let validTimeLength = (Int(val[10]) | Int(val[11]) << 8)
            let step = (Int(val[12]) | Int(val[13]) << 8 | Int(val[14]) << 16 | Int(val[15]) << 24)
            let endTime = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", (Int(val[16]) | (Int(val[17]) << 8)),val[18],val[19],val[21],val[22],val[23])
            let calorie = (Int(val[24]) | Int(val[25]) << 8 | Int(val[26]) << 16 | Int(val[27]) << 24)
            let distance = (Int(val[28]) | Int(val[29]) << 8 | Int(val[30]) << 16 | Int(val[31]) << 24)
            
            let timeformat = DateFormatter.init()
            timeformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var gpsArray = [[CLLocation]]()
            if val.count >= 33 {
                let gpsStartIndex = 32
                let gpsLength = (Int(val[gpsStartIndex]) | Int(val[gpsStartIndex+1]) << 8)
                if 34+gpsLength == val.count {
                    let gpsInterval = Int(val[gpsStartIndex+2])
                    let gpsCount = (Int(val[gpsStartIndex+3]) | Int(val[gpsStartIndex+4]) << 8)
                    
                    var locationStartIndex = gpsStartIndex+5
                    let firstBasicBit = (0x01 << 31)
                    let firstBit = (0x01 << 15)
                    for i in 0..<gpsCount {
                        let timeOffsetInterval = (Int(val[locationStartIndex]) | Int(val[locationStartIndex+1]) << 8)
                        let timestamp = (timeformat.date(from: startTime)?.timeIntervalSince1970 ?? 0) + TimeInterval(timeOffsetInterval)
                        let timeDate = Date.init(timeIntervalSince1970:timestamp)
                        var basicLatitude = (Int(val[locationStartIndex+2]) | Int(val[locationStartIndex+3]) << 8 | Int(val[locationStartIndex+4]) << 16 | Int(val[locationStartIndex+5]) << 24)
                        if basicLatitude > firstBasicBit {
                            basicLatitude = -(basicLatitude - firstBasicBit)
                        }
                        var basicLongitude = (Int(val[locationStartIndex+6]) | Int(val[locationStartIndex+7]) << 8 | Int(val[locationStartIndex+8]) << 16 | Int(val[locationStartIndex+9]) << 24)
                        if basicLongitude > firstBasicBit {
                            basicLongitude = -(basicLongitude - firstBasicBit)
                        }
                        let locationCount = (Int(val[locationStartIndex+10]) | Int(val[locationStartIndex+11]) << 8)
                        print("第\(i)组gps数据,个数为\(locationCount)")
                        print("gps timeDate = \(timeDate.timeIntervalSince1970),timeString = \(timeDate.conversionDateToString(DateFormat: "yyyy-MM-dd HH:mm:ss"))")
                        print("timeOffsetInterval = \(timeOffsetInterval)")
                        print("basicLatitude = \(basicLatitude)")
                        print("basicLongitude = \(basicLongitude)")
                        var singleGpsArray = [CLLocation]()
                        for j in 0..<locationCount {
                            var latitudeOffset = (Int(val[locationStartIndex+12+j*4+0]) | Int(val[locationStartIndex+12+j*4+1]) << 8)
                            if latitudeOffset > firstBit {
                                latitudeOffset = -(latitudeOffset - firstBit)
                            }
                            var longitudeOffset = (Int(val[locationStartIndex+12+j*4+2]) | Int(val[locationStartIndex+12+j*4+3]) << 8)
                            if longitudeOffset > firstBit {
                                longitudeOffset = -(longitudeOffset - firstBit)
                            }
                            
                            var latitude = 0
                            var longitude = 0
                            if basicLatitude > 0 {
                                latitude = basicLatitude + latitudeOffset
                            }else{
                                latitude = -(abs(basicLatitude) + latitudeOffset)
                            }
                            if basicLongitude > 0 {
                                longitude = basicLongitude + longitudeOffset
                            }else{
                                longitude = -(abs(basicLongitude) + longitudeOffset)
                            }
                            let locationModel = CLLocation.init(coordinate: CLLocationCoordinate2D.init(latitude: Double(latitude)/1000000.0, longitude: Double(longitude)/1000000.0), altitude: 0, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: timeDate + TimeInterval(j*gpsInterval))
                            //print("locationModel = \(locationModel)")
//                            print("latitudeOffset = \(latitudeOffset)")
//                            print("longitudeOffset = \(longitudeOffset)")
                            print("latitude = \(latitude),longitude = \(longitude),timestamp = \((timeDate + TimeInterval(j*gpsInterval)).conversionDateToString(DateFormat: "yyyy-MM-dd HH:mm:ss"))")
//                            if let lastModel:CLLocation = singleGpsArray.last {
//                                if !(lastModel.coordinate.latitude == locationModel.coordinate.latitude && lastModel.coordinate.longitude == locationModel.coordinate.longitude) {
////                                    print("latitudeOffset = \(latitudeOffset)")
////                                    print("longitudeOffset = \(longitudeOffset)")
////                                    print("latitude = \(latitude),longitude = \(longitude)")
//                                    singleGpsArray.append(locationModel)
//                                }
//                            }else{
//                                print("latitudeOffset = \(latitudeOffset)")
//                                print("longitudeOffset = \(longitudeOffset)")
//                                print("latitude = \(latitude),longitude = \(longitude)")
                                singleGpsArray.append(locationModel)
//                            }
                        }
                        gpsArray.append(singleGpsArray)
                        locationStartIndex = locationStartIndex+12+locationCount*4
                    }
                    
                }else{
                    print("gps数据跟总长度异常，不做解析")
                    ZySDKLog.writeStringToSDKLog(string: String.init(format: "gps数据跟总长度异常，不做解析"))
                    return nil
                }
            }
            
            let model = ZyExerciseModel.init(dic: ["startTime":startTime,"type":"\(type)","hr":"\(hr)","validTimeLength":"\(validTimeLength)","step":"\(step)","endTime":"\(endTime)","calorie":"\(calorie)","distance":"\(distance)","gpsArray":gpsArray])
            return model
        }else if type == 5 {
            let index = Int(val[0])
            let gpsLength = (Int(val[1]) | Int(val[2]) << 8 | Int(val[3]) << 16 | Int(val[4]) << 24)
            let startTime = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", (Int(val[5]) | (Int(val[6]) << 8)),val[7],val[8],val[10],val[11],val[12])
            let type = Int(val[13])
            print("index = \(index),gpsLength = \(gpsLength),startTime = \(startTime),type = \(type)")
            let model = ZyExerciseBasicModel.init()
            model.index = index
            model.gpsLength = gpsLength
            model.startTime = startTime
            model.type = ZyExerciseType.init(rawValue: type) ?? .runOutside
            return model
        }
        return nil
        //printLog("第\(#line)行" , "\(#function)")
    }
    
    func dealSleepData(val:[UInt8]) -> [String:Any] {
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
        var modelArray_filter = [[String:String]].init()
        var startIndex = 0
        var isAwakeSameState = false
        var islightSameState = false
        var isDeepSameState = false
        var isInvalidSameState = false
        var totalDeep = 0
        var totalLight = 0
        var totalAwake = 0
        var totalInvalid = 0
        var timeOffset = 720
        if self.functionListModel?.functionList_sleepDataVersion == true {
            if let model = self.functionListModel?.functionDetail_sleepDataVersion {
                if model.versionType == 1 {
                    timeOffset = 1080
                }
            }
        }
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
                    if startIndex > timeOffset {
                        start = String.init(format: "%02d:%02d", (startIndex-timeOffset)/60,(startIndex-timeOffset)%60)
                    }else{
                        start = String.init(format: "%02d:%02d", (startIndex+timeOffset)/60,(startIndex+timeOffset)%60)
                    }
                    if i > timeOffset {
                        end = String.init(format: "%02d:%02d", (i-timeOffset)/60,(i-timeOffset)%60)
                    }else{
                        end = String.init(format: "%02d:%02d", (i+timeOffset)/60,(i+timeOffset)%60)
                    }
                    
                    let total = String.init(format: "%d", i - startIndex + 1)
                    let type = String.init(format: "%d", state)
                    
                    modelArray.append(["start":start,"end":end,"total":total,"type":type])
                    modelArray_filter.append(["start":start,"end":end,"total":total,"type":type])
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
                    if startIndex > timeOffset {
                        start = String.init(format: "%02d:%02d", (startIndex-timeOffset)/60,(startIndex-timeOffset)%60)
                    }else{
                        start = String.init(format: "%02d:%02d", (startIndex+timeOffset)/60,(startIndex+timeOffset)%60)
                    }
                    if i > timeOffset {
                        end = String.init(format: "%02d:%02d", (i-timeOffset)/60,(i-timeOffset)%60)
                    }else{
                        end = String.init(format: "%02d:%02d", (i+timeOffset)/60,(i+timeOffset)%60)
                    }
                    let total = String.init(format: "%d", i - startIndex + 1)
                    let type = String.init(format: "%d", state)
                    
                    modelArray.append(["start":start,"end":end,"total":total,"type":type])
                    modelArray_filter.append(["start":start,"end":end,"total":total,"type":type])
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
                    if startIndex > timeOffset {
                        start = String.init(format: "%02d:%02d", (startIndex-timeOffset)/60,(startIndex-timeOffset)%60)
                    }else{
                        start = String.init(format: "%02d:%02d", (startIndex+timeOffset)/60,(startIndex+timeOffset)%60)
                    }
                    if i > timeOffset {
                        end = String.init(format: "%02d:%02d", (i-timeOffset)/60,(i-timeOffset)%60)
                    }else{
                        end = String.init(format: "%02d:%02d", (i+timeOffset)/60,(i+timeOffset)%60)
                    }
                    let total = String.init(format: "%d", i - startIndex + 1)
                    let type = String.init(format: "%d", state)
                    
                    modelArray.append(["start":start,"end":end,"total":total,"type":type])
                    modelArray_filter.append(["start":start,"end":end,"total":total,"type":type])
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
                    if startIndex > timeOffset {
                        start = String.init(format: "%02d:%02d", (startIndex-timeOffset)/60,(startIndex-timeOffset)%60)
                    }else{
                        start = String.init(format: "%02d:%02d", (startIndex+timeOffset)/60,(startIndex+timeOffset)%60)
                    }
                    if i > timeOffset {
                        end = String.init(format: "%02d:%02d", (i-timeOffset)/60,(i-timeOffset)%60)
                    }else{
                        end = String.init(format: "%02d:%02d", (i+timeOffset)/60,(i+timeOffset)%60)
                    }
                    let total = String.init(format: "%d", i - startIndex + 1)
                    let type = String.init(format: "%d", state)
                    
                    if !modelArray.isEmpty {
                        modelArray.append(["start":start,"end":end,"total":total,"type":type])
                    }
                    //modelArray_filter.append(["start":start,"end":end,"total":total,"type":type])
                }
                totalInvalid += 1
            }
            
            //循环到最后一个数据
            if i == sleepArray.count-2 {
                //判断最后一个数据跟最后一个状态是否一致
                if state == nextState {
                    //一致把最后一个状态加入最后一组数据
                    isAwakeSameState = false
                    if startIndex > timeOffset {
                        start = String.init(format: "%02d:%02d", (startIndex-timeOffset)/60,(startIndex-timeOffset)%60)
                    }else{
                        start = String.init(format: "%02d:%02d", (startIndex+timeOffset)/60,(startIndex+timeOffset)%60)
                    }
                    if i > timeOffset {
                        end = String.init(format: "%02d:%02d", (i-timeOffset+1)/60,(i-timeOffset+1)%60)
                    }else{
                        end = String.init(format: "%02d:%02d", (i+timeOffset+1)/60,(i+timeOffset+1)%60)
                    }
                    let total = String.init(format: "%d", (i+1) - startIndex + 1)
                    let type = String.init(format: "%d", state)
                    if type != "3" {
                        modelArray.append(["start":start,"end":end,"total":total,"type":type])
                        modelArray_filter.append(["start":start,"end":end,"total":total,"type":type])
                    }
                }else{
                    //不一致的，最后一个状态为单独一组
                    let start = String.init(format: "%02d:%02d", i/60,i%60)
                    let end = String.init(format: "%02d:%02d", (i+1)/60,(i+1)%60)
                    let total = String.init(format: "%d", 1)
                    let type = String.init(format: "%d", nextState)
                    if type != "3" {
                        modelArray.append(["start":start,"end":end,"total":total,"type":type])
                        modelArray_filter.append(["start":start,"end":end,"total":total,"type":type])
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
        var newArray:[[String:String]] = []
        var changeDic:[String:String] = [:]
        var filterFirstInvalidDic = false
        for i in 0..<modelArray.count-1 {
            
            let currentDic:[String:String] = modelArray[i]
            let nextDic:[String:String] = modelArray[i+1]
            
            let currentType = currentDic["type"]
            let nextType = nextDic["type"]
            if filterFirstInvalidDic == false {
                if (currentType == "0" || currentType == "3") {
                    changeDic = [:]
                    //过滤掉要减去过滤的清醒时长
                    if currentType == "0" {
                        totalAwake -= Int(currentDic["total"] ?? "0") ?? 0
                    }
                    continue
                }else{
                    filterFirstInvalidDic = true
                }
            }
            
            if changeDic.isEmpty {
                changeDic = currentDic
                if changeDic["type"] == "3" {
                    changeDic["type"] = "0"
                    totalAwake += Int(changeDic["total"] ?? "0") ?? 0
                }
            }
            
            //nextType==0的数据在上面一个for里面已经添加过
            if (currentType == "0" || currentType == "3") && (nextType == "3") {
                
                changeDic["end"] = nextDic["end"]
                changeDic["type"] = "0"
                let currentTotal = Int(changeDic["total"] ?? "0") ?? 0
                let nextTotal = Int(nextDic["total"] ?? "0") ?? 0
                changeDic["total"] = "\(currentTotal + nextTotal)"
                totalAwake += currentTotal + nextTotal
            }else{
                newArray.append(changeDic)
                changeDic = [:]
            }
            
            if i == modelArray.count-2 {
                if changeDic.isEmpty {
                    newArray.append(nextDic)
                }else{
                    newArray.append(changeDic)
                }
            }
        }
        printLog("-------modelArray =",modelArray)
        if newArray.count > 0 {
            modelArray = newArray
        }

        //ZySDKLog.writeStringToSDKLog(string: "原始数据")
        //ZySDKLog.writeStringToSDKLog(string: "\(originalArray)")
        //ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@\n\n\n", originalArray))
        
        //ZySDKLog.writeStringToSDKLog(string: "1440未整合数据")
        //ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@\n\n\n", sleepArray))
        
        //ZySDKLog.writeStringToSDKLog(string: "睡眠整合数据")
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "%@\n\n\n", modelArray))
        
//            printLog("originalArray =",originalArray)
//            printLog("sleepArray =",sleepArray,sleepArray.count)
        printLog("modelArray =",modelArray)
        printLog("modelArray_filter =",modelArray_filter)
        return ["deep":totalDeep,"light":totalLight,"awake":totalAwake,"originalArray":sleepArray,"detailArray":modelArray,"detailArray_filter":modelArray_filter]
    }
    
    // MARK: - 同步测量数据
    /// 同步数据
    /// - Parameters:
    ///   - dataType: 1：心率，2：血氧，3：血压，4：血糖，5：压力，6.体温，7：心电，
    ///   - measureType: 1：全天测量 ，2：点击测量
    ///   - indexArray: <#indexArray description#>
    ///   - success: <#success description#>
    @objc public func setSyncMeasurementData(dataType:Int,measureType:Int,indexArray:[Int],success:@escaping((Any?,ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }
        
        if dataType < 1 || dataType > 7 {
            print("输入参数超过范围,返回失败")
            success(nil,.fail)
            return
        }
        var headVal:[UInt8] = [
            0xaa,
            0x86
        ]
        var contentVal:[UInt8] = [
            UInt8(dataType),
            UInt8(measureType),
            UInt8(indexArray.count)
        ]
        for item in indexArray {
            contentVal.append(UInt8(item))
        }
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none{
                self?.receiveSetSyncMeasurementDataBlock = success
            }else{
                success(nil,error)
            }
        }
    }
    
    private func parseSyncMeasurementData(val:[UInt8],success:@escaping((Any?,ZyError) -> Void)) {

        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseSyncMeasurementData待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        if val.count <= 2 {
            success([],.fail)
            self.signalCommandSemaphore()
            return
        }
        let type = val[0]
        let measureType = val[1]
        var count:Int = Int(val[2])
        var allDayInterval = val[3]
        var valIndex = 4
        let model = ZyMeasurementModel()
        model.type = ZyMeasurementType.init(rawValue: Int(type)) ?? .heartrate
        model.timeInterval = Int(allDayInterval)
        var valueModelArray:[ZyMeasurementValueModel] = .init()
        while valIndex < val.count {
            let number = val[valIndex]
            var length:Int = (Int(val[valIndex+1]) | Int(val[valIndex+2]) << 8)
            let countLength = 3
            
            if length > 0 {
                let modelVal:[UInt8] = Array(val[valIndex+countLength..<(valIndex+countLength+Int(length))])
                
                if type == 1 || type == 2 || type == 5 || type == 4 || type == 7 {
                    if measureType == 2 {
                        if modelVal.count % 3 == 0 {
                            for i in 0..<modelVal.count/3 {
                                let valueModel = ZyMeasurementValueModel()
                                valueModel.time = String.init(format: "%02d:%02d", val[valIndex+countLength+i*3],val[valIndex+countLength+i*3+1])
                                valueModel.value_2 = Int(val[valIndex+countLength+i*3+2])
                                valueModel.dayIndex = Int(number)
                                valueModelArray.append(valueModel)
                            }
                        }else{
                            success(nil,.fail)
                            self.signalCommandSemaphore()
                            return
                        }
                    }else if measureType == 1 {
                        for i in 0..<modelVal.count/3 {
                            let valueModel = ZyMeasurementValueModel()
                            //valueModel.time = String.init(format: "%02d:%02d", i * Int(allDayInterval) / 60 , i * Int(allDayInterval) % 60)
                            //valueModel.value_2 = Int(val[valIndex+countLength+i])
                            //改成成测量数据一致的格式
                            valueModel.time = String.init(format: "%02d:%02d", val[valIndex+countLength+i*3],val[valIndex+countLength+i*3+1])
                            valueModel.value_2 = Int(val[valIndex+countLength+i*3+2])
                            valueModel.dayIndex = Int(number)
                            valueModelArray.append(valueModel)
                        }
                    }
                    
                }else if type == 3 {
                    if measureType == 2 {
                        if modelVal.count % 4 == 0 {
                            for i in 0..<modelVal.count/4 {
                                let valueModel = ZyMeasurementValueModel()
                                valueModel.time = String.init(format: "%02d:%02d", val[valIndex+countLength+i*4],val[valIndex+countLength+i*4+1])
                                valueModel.value_1 = Int(val[valIndex+countLength+i*4+2])
                                valueModel.value_2 = Int(val[valIndex+countLength+i*4+3])
                                valueModel.dayIndex = Int(number)
                                valueModelArray.append(valueModel)
                            }
                        }else{
                            success(nil,.fail)
                            self.signalCommandSemaphore()
                            return
                        }
                    }else if measureType == 1 {
                        for i in 0..<modelVal.count/4 {
                            let valueModel = ZyMeasurementValueModel()
                            //valueModel.time = String.init(format: "%02d:%02d", i * Int(allDayInterval) / 60 , i * Int(allDayInterval) % 60)
                            //valueModel.value_1 = Int(val[valIndex+countLength+i])
                            //valueModel.value_2 = Int(val[valIndex+countLength+i+1])
                            //改成成测量数据一致的格式
                            valueModel.time = String.init(format: "%02d:%02d", val[valIndex+countLength+i*4],val[valIndex+countLength+i*4+1])
                            valueModel.value_1 = Int(val[valIndex+countLength+i*4+2])
                            valueModel.value_2 = Int(val[valIndex+countLength+i*4+3])
                            valueModel.dayIndex = Int(number)
                            valueModelArray.append(valueModel)
                        }
                    }
                    
                }else if type == 6 {
                    if measureType == 2 {
                        if modelVal.count % 6 == 0 {
                            for i in 0..<modelVal.count/6 {
                                let valueModel = ZyMeasurementValueModel()
                                valueModel.time = String.init(format: "%02d:%02d", val[valIndex+countLength+i*6],val[valIndex+countLength+i*6+1])
                                valueModel.value_1 = (Int(val[valIndex+countLength+i*6+2]) | Int(val[valIndex+countLength+i*6+3]) << 8)
                                valueModel.value_2 = (Int(val[valIndex+countLength+i*6+4]) | Int(val[valIndex+countLength+i*6+5]) << 8)
                                valueModel.dayIndex = Int(number)
                                valueModelArray.append(valueModel)
                            }
                        }else{
                            success(nil,.fail)
                            self.signalCommandSemaphore()
                            return
                        }
                    }else if measureType == 1 {
                        for i in 0..<modelVal.count/6 {
                            let valueModel = ZyMeasurementValueModel()
                            //valueModel.time = String.init(format: "%02d:%02d", i * Int(allDayInterval) / 60 , i * Int(allDayInterval) % 60)
                            //valueModel.value_2 = (Int(val[valIndex+countLength+i*2]) | Int(val[valIndex+countLength+i*2+1]) << 8)
                            //改成成测量数据一致的格式
                            valueModel.time = String.init(format: "%02d:%02d", val[valIndex+countLength+i*6],val[valIndex+countLength+i*6+1])
                            valueModel.value_1 = (Int(val[valIndex+countLength+i*6+2]) | Int(val[valIndex+countLength+i*6+3]) << 8)
                            valueModel.value_2 = (Int(val[valIndex+countLength+i*6+4]) | Int(val[valIndex+countLength+i*6+5]) << 8)
                            valueModel.dayIndex = Int(number)
                            valueModelArray.append(valueModel)
                        }
                    }
                }
                model.listArray = valueModelArray
            }
            valIndex = (valIndex+countLength+Int(length))
        }
        success(model,.none)
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置天气
    @objc public func setNewWeather(modelArray:[ZyWeatherModel],updateTime:String? = nil,success:@escaping((ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。请使用setWeather")
            return
        }
        if modelArray.count <= 0 {
            print("输入参数超过范围,返回失败")
            success(.fail)
            return
        }
        
        var date = Date.init()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let time = updateTime {
            date = timeFormatter.date(from: time) ?? .init()
        }

        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        var headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 4
        //参数长度
        let modelCount = modelArray.count * 9 + 8//时间戳+个数
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8((year ) & 0xff),
            UInt8((year >> 8) & 0xff),
            UInt8(month),
            UInt8(day),
            UInt8(hour),
            UInt8(minute),
            UInt8(second),
            UInt8(modelArray.count)
        ]
        for item in modelArray {
            contentVal.append(UInt8(bitPattern: Int8(0x08)))
            contentVal.append(UInt8(bitPattern: Int8(item.dayCount)))
            contentVal.append(UInt8(bitPattern: Int8(item.type.rawValue)))
            contentVal.append(UInt8(bitPattern: Int8(item.temp)))
            contentVal.append(UInt8(bitPattern: Int8(item.airQuality)))
            contentVal.append(UInt8(bitPattern: Int8(item.minTemp)))
            contentVal.append(UInt8(bitPattern: Int8(item.maxTemp)))
            contentVal.append(UInt8(bitPattern: Int8(item.tomorrowMinTemp)))
            contentVal.append(UInt8(bitPattern: Int8(item.tomorrowMaxTemp)))
        }
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveNewSetWeatherBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 设置闹钟
    @objc public func setNewAlarmArray(modelArray:[ZyAlarmModel],success:@escaping((ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。请使用setAlarm")
            return
        }
        var modelArray = modelArray
        if modelArray.count <= 0 {
            let zyModel = ZyAlarmModel.init()
            zyModel.isValid = false
            zyModel.alarmIndex = 0
            modelArray.append(zyModel)
        }
        let headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 5
        //参数长度
        let modelCount = modelArray.count * 5 + 1//闹钟个数
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8(modelArray.count)
        ]

        for model in modelArray {
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
            var hour = model.alarmHour
            var minute = model.alarmMinute
            if !model.isValid {
                hour = 255
                minute = 255
            }
            contentVal.append(UInt8(0x04))
            contentVal.append(UInt8(index))
            contentVal.append(UInt8(repeatCount))
            contentVal.append(UInt8(hour))
            contentVal.append(UInt8(minute))
        }
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveNewSetAlarmArrayBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取闹钟
    @objc public func getNewAlarmArray(success:@escaping(([ZyAlarmModel],ZyError) -> Void))  {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。请使用getAlarm")
            return
        }

        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 5
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveNewGetAlarmArrayBlock = success
            }else{
                success([],error)
            }
        }
    }
    
    func parseGetNewAlarmArray(val:[UInt8],success:@escaping(([ZyAlarmModel],ZyError) -> Void)) {
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseGetNewAlarmArray待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        var alarmArray = [ZyAlarmModel]()

        let alarmCount = val[0]
        var valIndex = 1
        while valIndex < val.count {
            let length = val[valIndex]
            if length >= 4 {
                let index = val[valIndex+1]
                let repeatCount = val[valIndex+2]
                let hour = val[valIndex+3]
                let minute = val[valIndex+4]
                let string = String.init(format: "序号:%d,重复:%d,小时:%d,分钟:%d",index,repeatCount,hour,minute)
                print("\(string)")
                ZySDKLog.writeStringToSDKLog(string: string)
                let model = ZyAlarmModel.init(dic: ["index":"\(index)","repeatCount":"\(repeatCount)","hour":String.init(format: "%02d", hour),"minute":String.init(format: "%02d", minute)])
                alarmArray.append(model)
                valIndex += Int(length+1)
            }
        }
        if alarmCount == alarmArray.count {
            success(alarmArray,.none)
        }else{
            print("获取闹钟个数不一致,返回失败")
            ZySDKLog.writeStringToSDKLog(string: "获取闹钟个数不一致,返回失败")
            success([],.fail)
        }
        
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置睡眠目标
    @objc public func setSleepGoal(target:Int,success:@escaping((ZyError) -> Void)) {

        if target <= 0 || target > 1440{
            print("输入参数超过范围,返回失败")
            success(.fail)
            return
        }

        var headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x19
        //参数长度
        let modelCount = 2
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8((target ) & 0xff),
            UInt8((target >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetSleepGoalBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取睡眠目标
    @objc public func getSleepGoal(_ success:@escaping((Int,ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }

        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 0x19
        
        let contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetSleepGoalBlock = success
            }else{
                success(-1,error)
            }
        }
    }
    
    private func parseGetSleepGoal(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        
        if val.count == 2 {
            
            let goalCount = (Int(val[0]) | Int(val[1]) << 8 )
            let string = String.init(format: "%d",goalCount)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
            success(Int(goalCount),.none)
            
        }else{
            success(-1,.invalidState)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置sos联系人
    @objc public func setSosContactPerson(model:ZyAddressBookModel,success:@escaping((ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }

        var headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x1a
        
        let nameData = model.name.data(using: .utf8) ?? .init()
        //要限制长度<=64字符
        if nameData.count >= 64 {
            let aData = nameData.subdata(in: 0..<64)
            let str = NSString.init(data: aData, encoding:4)
            print("str = \(str)")
            
            let strUtf8 = String.init(data: aData, encoding: .utf8)
            print("strUtf8 = \(strUtf8)")
            let test = String.init(data: nameData, encoding: .utf8)
            print("nameData = \(test)")
            print("\(model.name) 长度超过64，截取为:\(String.init(format: "%@", aData as CVarArg))")
        }
        let nameValArray = nameData.withUnsafeBytes { (byte) -> [UInt8] in
            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
            return [UInt8](UnsafeBufferPointer.init(start: b, count: nameData.count >= 64 ? 64 : nameData.count))
        }
        let phoneData = model.phoneNumber.data(using: .utf8) ?? .init()
        if phoneData.count >= 32 {
            print("\(model.phoneNumber) 长度超过32，截取为:\(String.init(data: phoneData.subdata(in: 0..<32), encoding: .utf8))")
        }
        let phoneValArray = phoneData.withUnsafeBytes { (byte) -> [UInt8] in
            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
            return [UInt8](UnsafeBufferPointer.init(start: b, count: phoneData.count >= 32 ? 32 : phoneData.count))
        }
        //参数长度
        let modelCount = 2 + nameValArray.count + phoneValArray.count
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
        ]
        contentVal.append(UInt8(nameValArray.count))
        contentVal.append(contentsOf: nameValArray)
        contentVal.append(UInt8(phoneValArray.count))
        contentVal.append(contentsOf: phoneValArray)
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetSosContactPersonBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取sos联系人
    @objc public func getSosContactPerson(_ success:@escaping((ZyAddressBookModel?,ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }

        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 0x1a
        
        let contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetSosContactPersonBlock = success
            }else{
                success(nil,error)
            }
        }
    }
    
    private func parseGetSosContactPerson(val:[UInt8],success:@escaping((ZyAddressBookModel?,ZyError) -> Void)) {
        
        if true {
            let currentIndex = 0
            let nameLength = val[currentIndex]
            let nameArray = Array(val[(currentIndex+1)..<(currentIndex+1+Int(nameLength))])
            let numberLength = val[currentIndex+1+Int(nameLength)]
            let numberArray = Array(val[(currentIndex+2+Int(nameLength))..<(currentIndex+2+Int(nameLength)+Int(numberLength))])

            let model = ZyAddressBookModel.init()
            let nameData = nameArray.withUnsafeBufferPointer { (bytes) -> Data in
                return Data.init(buffer: bytes)
            }
            if let str = String.init(data: nameData, encoding: .utf8) {
                model.name = str
            }

            let numberData = numberArray.withUnsafeBufferPointer({ (bytes) -> Data in
                return Data.init(buffer: bytes)
            })

            if let str = String.init(data: numberData, encoding: .utf8) {
                model.phoneNumber = str
            }

            ZySDKLog.writeStringToSDKLog(string: String.init(format: "联系人:\(model.name),号码:\(model.phoneNumber)"))
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置周期测量参数
    /// - Parameters:
    ///   - type: 1：心率，2：血氧，3：血压，4：血糖，5：压力，6.体温，7：心电，
    ///   - isOpen: 0：关 1：开
    ///   - timeInterval: 开关为开必须>0
    @objc public func setCycleMeasurementParameters(type:Int,isOpen:Int,timeInterval:Int,startHour:Int,startMinute:Int,endHour:Int,endMinute:Int,success:@escaping((ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }
        var type = type
        if type > UInt8.max || type < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            type = 0
        }
        var isOpen = isOpen
        if isOpen > UInt8.max || isOpen < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            isOpen = 0
        }
        var timeInterval = timeInterval
        if timeInterval > UInt16.max || timeInterval < UInt16.min {
            print("输入参数超过范围,改为默认值0")
            timeInterval = 0
        }
        var startHour = startHour
        if startHour > UInt8.max || startHour < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            startHour = 0
        }
        var startMinute = startMinute
        if startMinute > UInt8.max || startMinute < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            startMinute = 0
        }
        var endHour = endHour
        if endHour > UInt8.max || endHour < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            endHour = 0
        }
        var endMinute = endMinute
        if endMinute > UInt8.max || endMinute < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            endMinute = 0
        }
        var headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x1b
        //参数长度
        let modelCount = 8
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8((type ) & 0xff),
            UInt8((isOpen ) & 0xff),
            UInt8((timeInterval ) & 0xff),
            UInt8((timeInterval >> 8) & 0xff),
            UInt8(startHour),
            UInt8(startMinute),
            UInt8(endHour),
            UInt8(endMinute)
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveCycleMeasurementParameters = success
            }else{
                success(error)
            }
        }
    }
    
//    // MARK: - 获取周期测量参数
    @objc public func getCycleMeasurementParameters(_ success:@escaping(([ZyCycleMeasurementModel]?,ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }

        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 0x1b
        
        let contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetCycleMeasurementParametersBlock = success
            }else{
                success(nil,error)
            }
        }
    }
    
    private func parseGetCycleMeasurementParameters(val:[UInt8],success:@escaping(([ZyCycleMeasurementModel]?,ZyError) -> Void)) {
        
        var cycleArray:[ZyCycleMeasurementModel] = .init()
        for i in 0..<Int(val.count)/8 {
            if val.count > (i+1) * 8 {
                let model = ZyCycleMeasurementModel.init()
                model.type = ZyMeasurementType.init(rawValue: Int(val[i*8])) ?? .bloodOxygen
                model.isOpen = val[i*8+1] == 0 ? false : true
                model.timeInterval = (Int(val[i*8+2]) | Int(val[i*8+3]) << 8 )
                model.timeModel.startHour = Int(val[i*8+4])
                model.timeModel.startMinute = Int(val[i*8+5])
                model.timeModel.endHour = Int(val[i*8+6])
                model.timeModel.endMinute = Int(val[i*8+7])
                cycleArray.append(model)
            }
        }
        
        success(cycleArray,.none)
        
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
            
    // MARK: - 获取朝拜闹钟数据
    @objc public func getWorshipStartTime(_ success:@escaping((_ timeString:String?,_ dayCount:Int,_ error:ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }

        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]

        //参数id
        let cmd_id = 0x1d

        let contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]

        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetWorshipStartTimeBlock = success
            }else{
                success(nil,0,error)
            }
        }
    }

    private func parseGetWorshipStartTime(val:[UInt8],success:@escaping((String?,Int,ZyError) -> Void)) {

        if val.count >= 8 {
            let dayCount = (Int(val[0]) | Int(val[1]) << 8)
            var timeString:String?

            let year = val[2]
            let month = val[3]
            let day = val[4]
            let hour = val[5]
            let minute = val[6]
            let second = val[7]

            if year != 0xff && month != 0xff && day != 0xff && hour != 0xff && minute != 0xff && second != 0xff {
                timeString = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", year,month,day,hour,minute,second)
            }

            ZySDKLog.writeStringToSDKLog(string: String.init(format: "朝拜天数:\(dayCount),开始时间:\(timeString ?? "无效时间")"))
            success(timeString,dayCount,.none)

        }else{
            success(nil,0,.invalidState)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 朝拜闹钟开始时间上报
    @objc public func reportWorshipStartTime(success:@escaping((_ timeString:String?,_ dayCount:Int,_ error:ZyError) -> Void)) {
        self.receiveReportWorshipStartTime = success
    }

    private func parseReportWorshipStartTime(val:[UInt8],success:@escaping((String?,Int,ZyError) -> Void)) {

        if val.count >= 8 {
            let dayCount = (Int(val[0]) | Int(val[1]) << 8)
            var timeString:String?

            let year = val[2]
            let month = val[3]
            let day = val[4]
            let hour = val[5]
            let minute = val[6]
            let second = val[7]

            if year != 0xff && month != 0xff && day != 0xff && hour != 0xff && minute != 0xff && second != 0xff {
                timeString = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", year,month,day,hour,minute,second)
            }

            ZySDKLog.writeStringToSDKLog(string: String.init(format: "朝拜天数:\(dayCount),开始时间:\(timeString ?? "无效时间")"))
            success(timeString,dayCount,.none)

        }else{
            success(nil,0,.invalidState)
        }
    }
    
    // MARK: - 闹钟上报
    @objc public func reportAlarmArray(success:@escaping((_ alarmArray:[ZyAlarmModel],_ error:ZyError) -> Void)) {
        self.receiveReportAlarmArray = success
    }
    
    private func parseReportAlarmArray(val:[UInt8],success:@escaping((_ alarmArray:[ZyAlarmModel],_ error:ZyError) -> Void)) {
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseGetNewAlarmArray待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        var alarmArray = [ZyAlarmModel]()

        let alarmCount = val[0]
        var valIndex = 1
        while valIndex < val.count {
            let length = val[valIndex]
            if length >= 4 {
                let index = val[valIndex+1]
                let repeatCount = val[valIndex+2]
                let hour = val[valIndex+3]
                let minute = val[valIndex+4]
                let string = String.init(format: "序号:%d,重复:%d,小时:%d,分钟:%d",index,repeatCount,hour,minute)
                print("\(string)")
                ZySDKLog.writeStringToSDKLog(string: string)
                let model = ZyAlarmModel.init(dic: ["index":"\(index)","repeatCount":"\(repeatCount)","hour":String.init(format: "%02d", hour),"minute":String.init(format: "%02d", minute)])
                alarmArray.append(model)
                valIndex += Int(length+1)
            }
        }
        if alarmCount == alarmArray.count {
            success(alarmArray,.none)
        }else{
            print("获取闹钟个数不一致,返回失败")
            ZySDKLog.writeStringToSDKLog(string: "获取闹钟个数不一致,返回失败")
            success([],.fail)
        }
        
    }
    
    
    // MARK: - 设置时区
    /// - Parameters:
    ///   - timeZone: 0-12东区 13-24西区  （正数不变负数从13开始）
    @objc public func setTimeZone(timeZone:Int = 0,success:@escaping((ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }
        
        var timeZone = timeZone
        if timeZone < 0 || timeZone > 24{
            print("输入参数超过范围,默认系统时区")
            timeZone = 0
        }
        
        if timeZone == 0 {
            let systemZone = NSTimeZone.local.secondsFromGMT()
            var deviceZone = systemZone / 3600
            timeZone = deviceZone < 0 ? (-deviceZone + 12) : deviceZone
            print("NSTimeZone = \(NSTimeZone.default),systemZone = \(systemZone)")
            print("系统时区:\(deviceZone),参数时区:\(timeZone)")
        }
        
        var headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x0F
        //参数长度
        let modelCount = 1
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8(timeZone)
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetTimeZoneBlock = success
            }else{
                success(error)
            }
        }
        
    }
    
    // MARK: - 设备状态查询
    @objc public func getAssistedPositioningState(_ success:@escaping((Int,ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }

        let headVal:[UInt8] = [
            0xaa,
            0x8c
        ]
        //参数个数
        let idCount = 1
        //设备状态ID 辅助定位
        let stateId = 1
        
        let contentVal:[UInt8] = [
            UInt8(idCount),
            UInt8(stateId),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetAssistedPositioningStateBlock = success
            }else{
                success(-1,error)
            }
        }
    }
    
    // MARK: - 上报请求辅助定位文件
    @objc public func reportAssistedPositioning(success:@escaping((_ state:Int, _ error:ZyError) -> Void)) {
        self.receiveReportAssistedPositioning = success
    }
    
    private func parseReportAssistedPositioning(val:[UInt8],success:@escaping((_ state:Int, _ error:ZyError) -> Void)) {
     
        if val.count >= 1 {
            let state = Int(val[0])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "辅助定位状态上报:\(state) 0无效1有效"))
            success(state,.none)
        }else{
            success(0,.invalidState)
        }
        
    }
    
    // MARK: - 上报耗电数据
    @objc public func reportPowerConsumptionData(success:@escaping((_ dataDic:[String:String],_ error:ZyError) -> Void)) {
        self.receiveReportPowerConsumptionData = success
    }
    
    private func parseReportPowerConsumptionData(val:[UInt8]/*,success:@escaping((_ dataDic:[String:String],_ error:ZyError) -> Void)*/) {
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parsePowerConsumptionData待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))

        let lightScreenCount = (Int(val[0]) | Int(val[1]) << 8 | Int(val[2]) << 16 | Int(val[3]) << 24)
        let lightScreenTimeLength = (Int(val[4]) | Int(val[5]) << 8 | Int(val[6]) << 16 | Int(val[7]) << 24)
        let meassageCount = (Int(val[8]) | Int(val[9]) << 8 | Int(val[10]) << 16 | Int(val[11]) << 24)
        let battery = Int(val[12])
        let batteryVoltage = (Int(val[13]) | Int(val[14]) << 8)
        let callTimeLength = (Int(val[15]) | Int(val[16]) << 8 | Int(val[17]) << 16 | Int(val[18]) << 24)
        let motorviBrationTimeLength = (Int(val[19]) | Int(val[20]) << 8 | Int(val[21]) << 16 | Int(val[22]) << 24)
        let dic = ["lightScreenCount":"\(lightScreenCount)","lightScreenTimeLength":"\(lightScreenTimeLength)","meassageCount":"\(meassageCount)","battery":"\(battery)","batteryVoltage":"\(batteryVoltage)","callTimeLength":"\(callTimeLength)","motorviBrationTimeLength":"\(motorviBrationTimeLength)"]
        //success(dic,.none)
        let str = String.init(format: "%@", dic)
        printLog("str = \(str)")
        ZySDKLog.writePowerConsumptionStringToSDKLog(string: str)
    }
    
    // MARK: - 上报治疗状态
    @objc public func reportTreatmentStatus(success:@escaping((_ type:Int,_ error:ZyError) -> Void)) {
        self.receiveReportTreatmentStatus = success
    }
    
    private func parseReportTreatmentStatus(val:[UInt8],success:@escaping((_ type:Int, _ error:ZyError) -> Void)) {
        
        if val.count >= 1 {
            let state = Int(val[0])
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "治疗状态上报:\(state) 0开始1进行中2结束"))
            success(state,.none)
        }else{
            success(0,.invalidState)
        }
    }
    
    // MARK: - 上报原始定位数据
    @objc public func reportLocationPrimitiveTransmission(success:@escaping((_ data:Data,_ error:ZyError) -> Void)) {
        self.receiveReportLocationPrimitiveTransmission = success
    }
    
    private func parseReportLocationPrimitiveTransmission(val:[UInt8],success:@escaping((_ data:Data,_ error:ZyError) -> Void)) {
        let data = Data.init(bytes: val, count: val.count)
        success(data,.none)
        
    }
    
    // MARK: - 上报请求定位信息
    @objc public func reportLocationInfo(success:@escaping((_ error:ZyError) -> Void)) {
        self.receiveReportLocationInfo = success
    }
    
    private func parseReportLocationInfo(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        
        success(.none)
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "请求定位信息"))
        
    }
    
    // MARK: - 设置定位信息
    @objc public func setLocationInfo(localtion:CLLocation) {
        
        var headVal:[UInt8] = [
            0xaa,
            0x8B
        ]
        
        //参数id
        let cmd_id = 1
        //参数长度
        let modelCount = 20
        
        var latitude:Int = Int(localtion.coordinate.latitude * 1000000)
        var longitude:Int = Int(localtion.coordinate.longitude * 1000000)
        if latitude < 0 {
            latitude = abs(latitude) | 0x80000000
        }
        if longitude < 0 {
            longitude = abs(longitude) | 0x80000000
        }
        //print("latitude = \(latitude),longitude = \(longitude)")
        let direction:Int = Int(localtion.course) < 0 ? 0 : Int(localtion.course)
        let speed:Int = Int(localtion.speed * 100) < 0 ? 0 : Int(localtion.speed * 100)
        
        let date = Date()
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        let systemZone = NSTimeZone.local.secondsFromGMT()
        var deviceZone = systemZone / 3600
        let timeZone = deviceZone < 0 ? (-deviceZone + 12) : deviceZone
        print("NSTimeZone = \(NSTimeZone.default),systemZone = \(systemZone)")
        print("系统时区:\(deviceZone),参数时区:\(timeZone)")
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8(cmd_id),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8((latitude ) & 0xff),
            UInt8((latitude >> 8) & 0xff),
            UInt8((latitude >> 16) & 0xff),
            UInt8((latitude >> 24) & 0xff),
            UInt8((longitude ) & 0xff),
            UInt8((longitude >> 8) & 0xff),
            UInt8((longitude >> 16) & 0xff),
            UInt8((longitude >> 24) & 0xff),
            UInt8((direction ) & 0xff),
            UInt8((direction >> 8) & 0xff),
            UInt8(speed / 100),
            UInt8(speed % 100),
            UInt8((year ) & 0xff),
            UInt8((year >> 8) & 0xff),
            UInt8(month),
            UInt8(day),
            UInt8(hour),
            UInt8(minute),
            UInt8(second),
            UInt8(timeZone),
        ]

            var dataArray:[Data] = []
            var firstBit:UInt8 = 0
            var maxMtuCount = 0
            if let model = self.functionListModel?.functionDetail_newPortocol {
                if contentVal.count > model.maxMtuCount {
                    firstBit = 128
                }
                maxMtuCount = model.maxMtuCount
                headVal.append(UInt8((contentVal.count ) & 0xff))
                headVal.append(UInt8((contentVal.count >> 8) & 0xff)+firstBit)
            }
            //判断是否要分包，分包的要再加总包数跟报序号
            if firstBit > 0 {
                var contentIndex = 0
                var packetCount = 0
                while contentIndex < contentVal.count {
                    //分包添加总包数跟包序号
                    let maxCount =  contentVal.count / (maxMtuCount - 10)
                    let packetVal:[UInt8] = [
                        UInt8((maxCount ) & 0xff),
                        UInt8((maxCount >> 8) & 0xff),
                        UInt8((packetCount ) & 0xff),
                        UInt8((packetCount >> 8) & 0xff)
                    ]
                    
                    let startIndex = packetCount*(maxMtuCount - 10)
                    //print("(packetCount+1)*(maxMtuCount - 10) = \((packetCount+1)*(maxMtuCount - 10)),(startIndex + contentVal.count - packetCount*(maxMtuCount - 10)) = \((startIndex + contentVal.count - packetCount*(maxMtuCount - 10)))")
                    let endIndex = (packetCount+1)*(maxMtuCount - 10) <= contentVal.count ? (packetCount+1)*(maxMtuCount - 10) : (startIndex + contentVal.count - packetCount*(maxMtuCount - 10))
                    let subContentVal =  Array(contentVal[startIndex..<endIndex])
                                    
                    var val = headVal + packetVal + subContentVal
                    
                    let check = CRC16(val: val)
                    let checkVal = [UInt8((check ) & 0xff),UInt8((check >> 8) & 0xff)]
                    
                    val += checkVal
                    
                    let data = Data.init(bytes: &val, count: val.count)
                    dataArray.append(data)
                    
                    packetCount += 1
                    contentIndex = endIndex
                }
                
            }else{
                var val = headVal + contentVal
                let check = CRC16(val: val)
                let checkVal = [UInt8((check ) & 0xff),UInt8((check >> 8) & 0xff)]
                
                val += checkVal
                
                let data = Data.init(bytes: &val, count: val.count)
                dataArray.append(data)
            }
            
            
            if let data = dataArray.first {
                self.writeData(data: data)
            }

    }
    
    private func parseGetAssistedPositioningState(val:UInt8,success:@escaping((Int,ZyError) -> Void)) {
        
        let state = val

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "辅助定位:\(state == 0 ? "无效":"有效")"))
        success(Int(state),.none)

    }
    
    // MARK: - LED灯功能设置
    @objc public func setLedSetup(modelArray:[ZyLedFunctionModel],success:@escaping((ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }
        var headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x1E
        //参数长度
        let modelCount = modelArray.count * 4 + 1//功能项列表+总数
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8(modelArray.count)
        ]
        for item in modelArray {
            contentVal.append(UInt8(bitPattern: Int8(item.ledType.rawValue)))
            contentVal.append(UInt8(bitPattern: Int8(item.ledColor)))
            contentVal.append(UInt8(bitPattern: Int8(item.timeLength)))
            contentVal.append(UInt8(bitPattern: Int8(item.frequency)))
        }
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetLedSetupBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取led功能灯
    @objc public func getLedSetup(_ success:@escaping(([ZyLedFunctionModel],ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }
        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 0x1e
        
        let contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetLedSetupBlock = success
            }else{
                success([],error)
            }
        }
    }
    
    private func parseGetLedSetup(val:[UInt8],success:@escaping(([ZyLedFunctionModel],ZyError) -> Void)) {
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseGetLedSetup待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        var modelArray = [ZyLedFunctionModel]()

        let modelCount = val[0]
        var valIndex = 0
        while valIndex+1 < val.count {
            let ledType = val[valIndex+1]
            let ledColor = val[valIndex+2]
            let timeLength = val[valIndex+3]
            let frequency = val[valIndex+4]
            let string = String.init(format: "类型:%d,颜色:%d,持续时长:%d,闪烁频次:%d",ledType,ledColor,timeLength,frequency)
            print("\(string)")
            ZySDKLog.writeStringToSDKLog(string: string)
            let model = ZyLedFunctionModel.init(dic: ["ledType":Int(ledType),"ledColor":Int(ledColor),"timeLength":Int(timeLength),"frequency":Int(frequency)])
            modelArray.append(model)
            valIndex += 4
        }
        if modelCount == modelArray.count {
            success(modelArray,.none)
        }else{
            print("获取led灯功能个数不一致,返回失败")
            ZySDKLog.writeStringToSDKLog(string: "获取led灯功能个数不一致,返回失败")
            success([],.fail)
        }
        
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取单个LED灯功能
    @objc public func getLedSetup(type:ZyLedFunctionType,success:@escaping((ZyLedFunctionModel?,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x16,
            0x05,
            0x00,
            UInt8(type.rawValue)
        ]
        if type == .powerIndicator {
            val = [
                0x02,
                0x18,
                0x05,
                0x00,
                UInt8(type.rawValue)
            ]
        }
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLedSetupSingleBlock = success
        }else{
            success(nil,state)
        }
        
    }
    
    private func parseGetLedSetupSingle(val:[UInt8],success:@escaping((ZyLedFunctionModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])

        if val[1] == 0x98 && val.count < 10 {
            success(nil,.invalidLength)
            self.signalCommandSemaphore()
            return
        }
        
        if val[1] == 0x96 && val.count < 9 {
            success(nil,.invalidLength)
            self.signalCommandSemaphore()
            return
        }
        
        if val[4] == 1 {
            if val[1] == 0x98 {
                
                let ledType = 0
                let ledColor = 0
                let firstColor = val[5]
                let secondColor = val[6]
                let thirdColor = val[7]
                let timeLength = val[8]
                let frequency = val[9]
                let string = String.init(format: "类型:%d,颜色:%d,75-100电量颜色:%d,21-74电量颜色:%d,0-20电量颜色:%d,持续时长:%d,闪烁频次:%d",ledType,ledColor,firstColor,secondColor,thirdColor,timeLength,frequency)
                print("\(string)")
                ZySDKLog.writeStringToSDKLog(string: string)
                let model = ZyLedFunctionModel.init(dic: ["ledType":Int(ledType),"ledColor":Int(ledColor),"firstColor":Int(firstColor),"secondColor":Int(secondColor),"thirdColor":Int(thirdColor),"timeLength":Int(timeLength),"frequency":Int(frequency)])
                success(model,.none)
                
            }
            
            if val[1] == 0x96 {
                let ledType = val[5]
                let ledColor = val[6]
                let timeLength = val[7]
                let frequency = val[8]
                let string = String.init(format: "类型:%d,颜色:%d,持续时长:%d,闪烁频次:%d",ledType,ledColor,timeLength,frequency)
                print("\(string)")
                ZySDKLog.writeStringToSDKLog(string: string)
                let model = ZyLedFunctionModel.init(dic: ["ledType":Int(ledType),"ledColor":Int(ledColor),"timeLength":Int(timeLength),"frequency":Int(frequency)])
                success(model,.none)
            }
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置单个LED灯功能
    @objc public func setLedSetup(model:ZyLedFunctionModel,success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = []
        if model.ledType == .powerIndicator {
            val = [
                0x02,
                0x19,
                0x09,
                0x00,
                UInt8(model.firstColor),
                UInt8(model.secondColor),
                UInt8(model.thirdColor),
                UInt8(model.timeLength),
                UInt8(model.frequency),
            ]
            
        }else{
            val = [
                0x02,
                0x17,
                0x08,
                0x00,
                (UInt8(model.ledType.rawValue) ?? 0),
                UInt8(model.ledColor),
                UInt8(model.timeLength),
                UInt8(model.frequency),
            ]
        }
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLedSetupSingleBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetLedSetupSingle(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取单个马达震动功能
    @objc public func getMotorShakeFunction(type:ZyLedFunctionType,success:@escaping((ZyMotorFunctionModel?,ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x1A,
            0x05,
            0x00,
            UInt8(type.rawValue)
        ]
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetMotorShakeFunctionSingleBlock = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetMotorShakeFunctionSingle(val:[UInt8],success:@escaping((ZyMotorFunctionModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])

        if val.count < 9 {
            success(nil,.invalidLength)
            self.signalCommandSemaphore()
            return
        }
        
        if val[4] == 1 {
            let ledType = val[5]
            let timeLength = val[6]
            let frequency = val[7]
            let level = val[8]
            let string = String.init(format: "类型:%d,震动时长:%d,震动频次:%d,震动强度:%d",ledType,timeLength,frequency,level)
            print("\(string)")
            ZySDKLog.writeStringToSDKLog(string: string)
            let model = ZyMotorFunctionModel.init(dic: ["ledType":Int(ledType),"timeLength":Int(timeLength),"frequency":Int(frequency),"level":Int(level)])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置单个马达震动功能
    @objc public func setMotorShakeFunction(model:ZyMotorFunctionModel,success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x1B,
            0x08,
            0x00,
            UInt8(model.ledType.rawValue),
            UInt8(model.timeLength),
            UInt8(model.frequency),
            UInt8(model.level),
        ]
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetMotorShakeFunctionSingleBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetMotorShakeFunctionSingle(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 马达震动功能设置
    @objc public func setMotorShakeFunction(modelArray:[ZyMotorFunctionModel],success:@escaping((ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }
        var headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x1F
        //参数长度
        let modelCount = modelArray.count * 4 + 1//功能项列表+总数
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8(modelArray.count)
        ]
        for item in modelArray {
            contentVal.append(UInt8(bitPattern: Int8(item.ledType.rawValue)))
            contentVal.append(UInt8(bitPattern: Int8(item.timeLength)))
            contentVal.append(UInt8(bitPattern: Int8(item.frequency)))
            contentVal.append(UInt8(bitPattern: Int8(item.level)))
        }
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetMotorShakeFunctionBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取马达功能
    @objc public func getMotorShakeFunction(_ success:@escaping(([ZyMotorFunctionModel],ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }
        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 0x1f
        
        let contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetMotorShakeFunctionBlock = success
            }else{
                success([],error)
            }
        }
    }
    private func parseGetMotorShakeFunction(val:[UInt8],success:@escaping(([ZyMotorFunctionModel],ZyError) -> Void)) {
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseGetLedSetup待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        var modelArray = [ZyMotorFunctionModel]()

        let modelCount = val[0]
        var valIndex = 0
        while valIndex+1 < val.count {
            let ledType = val[valIndex+1]
            let timeLength = val[valIndex+2]
            let frequency = val[valIndex+3]
            let level = val[valIndex+4]
            let string = String.init(format: "类型:%d,震动时长:%d,震动频次:%d,震动强度:%d",ledType,timeLength,frequency,level)
            print("\(string)")
            ZySDKLog.writeStringToSDKLog(string: string)
            let model = ZyMotorFunctionModel.init(dic: ["ledType":Int(ledType),"timeLength":Int(timeLength),"frequency":Int(frequency),"level":Int(level)])
            modelArray.append(model)
            valIndex += 4
        }
        if modelCount == modelArray.count {
            success(modelArray,.none)
        }else{
            print("获取马达震动功能个数不一致,返回失败")
            ZySDKLog.writeStringToSDKLog(string: "获取马达震动功能个数不一致,返回失败")
            success([],.fail)
        }
        
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取LED自定义设置
    @objc public func getLedCustomSetup(success:@escaping((ZyLedFunctionModel?,ZyError) -> Void)){
        
        var val:[UInt8] = [
            0x02,
            0x1c,
            0x04,
            0x00,
        ]

        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetLedCustomSetupBlock = success
        }else{
            success(nil,state)
        }
        
    }
    
    private func parseGetLedCustomSetup(val:[UInt8],success:@escaping((ZyLedFunctionModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])

        if val[2] == 9 {
            let ledColor = val[5]
            let timeLength = val[6]
            let frequency = val[7]
            let ledOpenCount = val[8]
            let string = String.init(format: "颜色:%d,持续时长:%d,闪烁频次:%d,LED开关",ledColor,timeLength,frequency,ledOpenCount)
            print("\(string)")
            ZySDKLog.writeStringToSDKLog(string: string)
            let model = ZyLedFunctionModel.init(dic: ["ledType":Int(ZyLedFunctionType.customSetup.rawValue),"ledColor":Int(ledColor),"timeLength":Int(timeLength),"frequency":Int(frequency),"ledOpenCount":Int(ledOpenCount)])
            success(model,.none)
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置LED自定义设置
    @objc public func setLedCustomSetup(model:ZyLedFunctionModel,success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x1d,
            0x07,
            0x00,
            UInt8(model.ledColor),
            UInt8(model.timeLength),
            UInt8(model.frequency),
            UInt8(model.ledOpenCount),
        ]
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetLedCustomSetupBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetLedCustomSetup(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取自定义震动设置
    @objc public func getMotorShakeCustom(success:@escaping((ZyMotorFunctionModel?,ZyError) -> Void)){
        
        var val:[UInt8] = [
            0x02,
            0x1e,
            0x04,
            0x00,
        ]

        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetMotorShakeCustomBlock = success
        }else{
            success(nil,state)
        }
        
    }
    
    private func parseGetMotorShakeCustom(val:[UInt8],success:@escaping((ZyMotorFunctionModel?,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[2] == 8 {
            let timeLength = val[5]
            let frequency = val[6]
            let level = val[7]
            let string = String.init(format: "震动时长:%d,震动频次:%d,震动强度:%d",timeLength,frequency,level)
            print("\(string)")
            ZySDKLog.writeStringToSDKLog(string: string)
            let model = ZyMotorFunctionModel.init(dic: ["ledType":Int(ZyLedFunctionType.customSetup.rawValue),"timeLength":Int(timeLength),"frequency":Int(frequency),"level":Int(level)])
            success(model,.none)
            
        }else{
            success(nil,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置自定义震动
    @objc public func setMotorShakeCustom(model:ZyMotorFunctionModel,success:@escaping((ZyError) -> Void)) {
        
        var val:[UInt8] = [
            0x02,
            0x1f,
            0x07,
            0x00,
            UInt8(model.timeLength),
            UInt8(model.frequency),
            UInt8(model.level),
        ]
        
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetMotorShakeCustomBlock = success
        }else{
            success(state)
        }
    }
    
    private func parseSetMotorShakeCustom(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取自定义运动类型
    @objc public func getCustomSportsMode(_ success:@escaping((ZyExerciseType,ZyError) -> Void)) {
        
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }
        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 0x20
        
        let contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetCustomSportsModeBlock = success
            }else{
                success(.runIndoor,error)
            }
        }
    }
    
    private func parseGetCustomSportsMode(val:[UInt8],success:@escaping((ZyExerciseType,ZyError) -> Void)) {
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseGetCustomSportsMode待解析数据:\n length = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))

        let modelCount = val[0]
        let sportsType = val[1]

        success(ZyExerciseType.init(rawValue: Int(sportsType)) ?? .runOutside,.none)
        
        self.signalCommandSemaphore()
    }
    
    // MARK: - 蓝牙改名字
    @objc public func setBleName(name:String,success:@escaping((ZyError) -> Void)) {
        if self.functionListModel?.functionList_newPortocol == false {
            print("当前设备不支持此命令。")
            return
        }
        var headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x21

        var nameVal:[UInt8] = .init()
        if let data:Data = name.data(using: .utf8) {
            if let model = self.functionListModel?.functionDetail_bleNameSetup {
                if data.count < model.nameMaxLength {
                    
                    nameVal = data.withUnsafeBytes { (byte) -> [UInt8] in
                        let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                        return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
                    }
                    
                }else{
                    let newData = data.subdata(in: 0..<model.nameMaxLength)
                    
                    nameVal = newData.withUnsafeBytes { (byte) -> [UInt8] in
                        let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                        return [UInt8](UnsafeBufferPointer.init(start: b, count: newData.count))
                    }
                }
            }
        }
        //参数长度
        let modelCount = nameVal.count
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
        ]
        contentVal.append(contentsOf: nameVal)
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetBleNameBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 设置自定义血糖
    @objc public func setCustomBloodSugarScope(modelArray:[ZyCustomBloodSugar],success:@escaping((ZyError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x22
        //参数长度
        let modelCount = modelArray.count * 8 + 1//闹钟个数
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8(modelArray.count)
        ]

        for model in modelArray {
            let index = model.indexId

            let isOpen = model.isOpen
            let startHour = model.startHour
            let startMinute = model.startMinute
            let endHour = model.endHour
            let endMinute = model.endMinute
            let maxValue = model.maxValue
            let minValue = model.minValue

            contentVal.append(UInt8(0x08))
            contentVal.append(UInt8(index))
            contentVal.append(UInt8(isOpen ? 0x01 : 0x00))
            contentVal.append(UInt8(startHour))
            contentVal.append(UInt8(startMinute))
            contentVal.append(UInt8(endHour))
            contentVal.append(UInt8(endMinute))
            contentVal.append(UInt8(maxValue))
            contentVal.append(UInt8(minValue))
        }
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetCustomBloodSugarScopeBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取自定义血糖
    @objc public func getCustomBloodSugarScope(success:@escaping(([ZyCustomBloodSugar],ZyError) -> Void))  {

        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 0x22
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetCustomBloodSugarScopeBlock = success
            }else{
                success([],error)
            }
        }
    }
    
    func parseGetCustomBloodSugarScope(val:[UInt8],success:@escaping(([ZyCustomBloodSugar],ZyError) -> Void)) {
        
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }

        ZySDKLog.writeStringToSDKLog(string: String.init(format: "parseGetCustomBloodSugarScope待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        var bloodSugarArray = [ZyCustomBloodSugar]()

        let bsCount = val[0]
        var valIndex = 1
        while valIndex < val.count {
            let length = val[valIndex]
            if length >= 8 {
                let indexId = val[valIndex+1]
                let isOpen = val[valIndex+2]
                let startHour = val[valIndex+3]
                let startMinute = val[valIndex+4]
                let endHour = val[valIndex+5]
                let endMinute = val[valIndex+6]
                let maxValue = val[valIndex+7]
                let minValue = val[valIndex+8]
                let string = String.init(format: "序号:%d,开关:%d,开始时间:%02d:%02d,结束时间:%02d:%02d,最大值:%.1f,最小值:%.1f",indexId,isOpen,startHour,startMinute,endHour,endMinute,Float(maxValue)/10.0,Float(minValue)/10.0)
                print("\(string)")
                ZySDKLog.writeStringToSDKLog(string: string)
                let model = ZyCustomBloodSugar.init(dic: ["indexId":"\(indexId)","isOpen":"\(isOpen)","startHour":String.init(format: "%02d", startHour),"startMinute":String.init(format: "%02d", startMinute),"endHour":String.init(format: "%02d", endHour),"endMinute":String.init(format: "%02d", endMinute),"maxValue":"\(maxValue)","minValue":"\(minValue)"])
                bloodSugarArray.append(model)
                valIndex += Int(length+1)
            }
        }
        if bsCount == bloodSugarArray.count {
            success(bloodSugarArray,.none)
        }else{
            print("获取自定义血糖个数不一致,返回失败")
            ZySDKLog.writeStringToSDKLog(string: "获取自定义血糖个数不一致,返回失败")
            success([],.fail)
        }
        
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置消息提醒方式
    @objc public func setMessageRemindType(index:Int,success:@escaping((ZyError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x23
        //参数长度
        let modelCount = 1
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8(index),
        ]

        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetMessageRemindTypeBlock = success
            }else{
                success(error)
            }
        }
    }

    // MARK: - 获取消息提醒方式
    @objc public func getMessageRemindType(success:@escaping((Int,ZyError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 0x23
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetMessageRemindTypeBlock = success
            }else{
                success(-1,error)
            }
        }
    }
    
    func parseGetMessageRemindType(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        
        if val.count == 1 {
            let type = Int(val[0])
            let string = String.init(format: "%d",type)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
            success(Int(type),.none)
        }else{
            success(-1,.invalidState)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置治疗信息
    @objc public func setTreatmentInfomation(model:ZyTreatmentModel,success:@escaping((ZyError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x25
        var contentVal:[UInt8] = [0x01,
                                  UInt8((cmd_id ) & 0xff),
                                  UInt8((cmd_id >> 8) & 0xff),
                                  0x00,
                                  0x00]
        contentVal.append(UInt8(model.type))
        contentVal.append(model.isOpen ? 0x01 : 0x00)
        contentVal.append(UInt8(model.timeDic.count))
        for (key,value) in model.timeDic {
            let timeArray = key.components(separatedBy: ":")
            if let hour = timeArray.first{
                contentVal.append(UInt8(hour) ?? 0)
            }
            if let minute = timeArray.last {
                contentVal.append(UInt8(minute) ?? 0)
            }
            contentVal.append(UInt8((Int(value) ?? 0) & 0xff))
            contentVal.append(UInt8(((Int(value) ?? 0) >> 8) & 0xff) ?? 0)
        }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        contentVal.append(UInt8(model.dateDic.count))
        
        for (key,value) in model.dateDic {
            if let date = timeFormatter.date(from: key) {
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                
                contentVal.append(UInt8((year ) & 0xff))
                contentVal.append(UInt8((year >> 8) & 0xff))
                contentVal.append(UInt8(month))
                contentVal.append(UInt8(day))
                contentVal.append(UInt8(value) ?? 0)
            }
        }
        //参数长度
        let modelCount = (contentVal.count - 5)
        contentVal[3] = UInt8((modelCount) & 0xFF)
        contentVal[4] = UInt8((modelCount >> 8) & 0xFF)

        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetTreatmentInfomationBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取治疗信息
    @objc public func getTreatmentInfomation(success:@escaping((ZyTreatmentModel?,ZyError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 0x25
        
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetTreatmentInfomationBlock = success
            }else{
                success(nil,error)
            }
        }
    }
    
    func parseGetTreatmentInfomation(val:[UInt8],success:@escaping((ZyTreatmentModel?,ZyError) -> Void)) {
        
        if val.count > 2 {
            
            let type = Int(val[0])
            let isOpen = Int(val[1])
            let timeCount = Int(val[2])
            var dateCount = 0
            var timeDic:[String:String] = .init()
            var dateDic:[String:String] = .init()
            if timeCount * 4 + 2 < val.count {
                let timeVal = Array(val[3..<(timeCount * 4 + 3)])
                for i in 0..<timeCount {
                    let hour = timeVal[i*4]
                    let minute = timeVal[i*4 + 1]
                    let timeLength = (Int(timeVal[i*4 + 2]) | Int(timeVal[i*4 + 3]) << 8)
                    let key = String.init(format: "%02d:%02d", hour,minute)
                    let value = String.init(format: "%d", timeLength)
                    timeDic[key] = value
                }
                dateCount = Int(val[timeCount * 4 + 3])
            }
            if dateCount * 5 + 4 < val.count {
                let dateVal = Array(val[(timeCount * 4 + 4)..<(timeCount * 4 + 4 + dateCount * 5)])
                for i in 0..<dateCount {
                    let year = (Int(dateVal[i*5]) | Int(dateVal[i*5 + 1]) << 8)
                    let month = dateVal[i*5 + 2]
                    let day = dateVal[i*5 + 3]
                    let count = dateVal[i*5 + 4]
                    let key = String.init(format: "%04d-%02d-%02d", year,month,day)
                    let value = String.init(format: "%d", count)
                    dateDic[key] = value
                }
            }
            let treatmentModel = ZyTreatmentModel()
            treatmentModel.type = type
            treatmentModel.isOpen = isOpen == 0 ? false:true
            treatmentModel.timeDic = timeDic
            treatmentModel.dateDic = dateDic
            var string = ""
            string += String.init(format: "\n类型:%d",type)
            string += String.init(format: "\n开关:%d",isOpen)
            for (key,value) in timeDic {
                string += String.init(format: "\n%@:%@",key,value)
            }
            for (key,value) in dateDic {
                string += String.init(format: "\n%@:%@",key,value)
            }
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
            success(treatmentModel,.none)
        }else{
            success(nil,.invalidState)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 定位原始数据透传开关
    @objc public func setLocationPrimitiveTransmission(isOpen:Int,success:@escaping((ZyError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x26
        //参数长度
        let modelCount = 1
        var contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((modelCount ) & 0xff),
            UInt8((modelCount >> 8) & 0xff),
            UInt8(isOpen),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetLocationPrimitiveTransmissionBlock = success
                if isOpen != 0 {
                    let date:Date = Date()
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss SS"
                    let strNowTime = timeFormatter.string(from: date)
                    //let onceUrl:String = String.init(format: "\n保存时间:%@\n\n\n\n\n",strNowTime)
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
                    let filePath = String.init(format: "%@/%@_locationLog",savePath,Date.init().conversionDateToString(DateFormat: "yyyy-MM-dd HH:mm:ss"))
                    if !fileManager.fileExists(atPath: filePath) {
                        fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
                    }
                    self?.reportLocationPrimitiveTransmission(success: { data, error in
                        
                        do {
                            //let url = URL(fileURLWithPath: filePath)
                            let fileHandle = try FileHandle(forWritingAtPath: filePath)                                // 移动到文件末尾
                            fileHandle?.seekToEndOfFile()
                            // 写入新内容
                            fileHandle?.write(data)
                        }catch {
                            print("写入失败: \(error)")
                        }
                    })
                }else{
                    self?.receiveReportLocationPrimitiveTransmission = nil
                }
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 设置名片
    @objc public func setBusinessCard(modelArray:[ZyBusinessCardModel],success:@escaping((ZyError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xaa,
            0x83
        ]
        
        //参数id
        let cmd_id = 0x24
        var contentVal:[UInt8] = [0x01,
                                  UInt8((cmd_id ) & 0xff),
                                  UInt8((cmd_id >> 8) & 0xff),
                                  0x00,
                                  0x00]
        contentVal.append(UInt8(modelArray.count))
        for i in 0..<modelArray.count {
            let cardModel = modelArray[i]
            if let detailModel = self.functionListModel?.functionDetail_businessCard {
                var titleData = cardModel.titleString.data(using: .utf8) ?? .init()
                if titleData.count >= detailModel.titleLength {
                    titleData = titleData.subdata(in: 0..<detailModel.titleLength)
                }
                let titleValArray = titleData.withUnsafeBytes { (byte) -> [UInt8] in
                    let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: titleData.count))
                }
                var qrData = cardModel.qrString.data(using: .utf8) ?? .init()
                if qrData.count >= detailModel.qrLength {
                    qrData = qrData.subdata(in: 0..<detailModel.qrLength)
                }
                let qrValArray = qrData.withUnsafeBytes { (byte) -> [UInt8] in
                    let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: qrData.count))
                }
                contentVal.append(UInt8(cardModel.index))
                contentVal.append(UInt8(titleData.count))
                contentVal.append(contentsOf: titleValArray)
                contentVal.append(UInt8(qrData.count & 0xFF))
                contentVal.append(UInt8((qrData.count >> 8) & 0xFF))
                contentVal.append(contentsOf: qrValArray)
            }
        }
        //参数长度
        let modelCount = (contentVal.count - 5)//modelArray.count > 0 ? (contentVal.count - 5) : 0
        contentVal[3] = UInt8((modelCount) & 0xFF)
        contentVal[4] = UInt8((modelCount >> 8) & 0xFF)

        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetBusinessCardBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取名片
    @objc public func getBusinessCard(success:@escaping(([ZyBusinessCardModel],ZyError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xaa,
            0x84
        ]
        
        //参数id
        let cmd_id = 0x24
        var maxCount = 0
        if let model = self.functionListModel?.functionDetail_businessCard {
            maxCount = model.maxCount
        }
        
        let contentVal:[UInt8] = [
            0x01,
            UInt8((cmd_id ) & 0xff),
            UInt8((cmd_id >> 8) & 0xff),
            UInt8((maxCount ) & 0xff),
            UInt8((maxCount >> 8) & 0xff),
        ]
        
        self.dealNewProtocolData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetBusinessCardBlock = success
            }else{
                success([],error)
            }
        }
    }
    
    func parseGetBusinessCard(val:[UInt8],success:@escaping(([ZyBusinessCardModel],ZyError) -> Void)) {
        
        if val.count > 1 {
            let arrayCount = Int(val[0])
            
            var modelArray:[ZyBusinessCardModel] = .init()
            var startIndex = 1
            while startIndex < val.count {
                let modelIndex = val[startIndex]
                if startIndex+1 >= val.count {
                    print("index+1 >= val.count 长度异常 不解析")
                    startIndex = val.count
                    continue
                }
                let titleLength = (val[startIndex+1])
                startIndex += 1
                print("titleLength = \(titleLength),startIndex = \(startIndex)")
                if startIndex+Int(titleLength) > val.count {
                    print("startIndex+2+functionLength 长度异常 不解析")
                    startIndex = val.count
                    continue
                }
                let titleVal = Array.init(val[(startIndex+1)..<(startIndex+1+Int(titleLength))])
                startIndex += (Int(titleLength))
                if titleVal.count <= 0 {
                    print("数据异常不解析")
                    //success(model,.fail)
                    startIndex = val.count
                    continue
                }
                
                let qrLength = (Int(val[startIndex+1]) | Int(val[startIndex+2]) << 8)
                startIndex += 2
                print("qrLength = \(qrLength),startIndex = \(startIndex)")
                if startIndex+Int(qrLength) > val.count {
                    print("startIndex+2+qrLength 长度异常 不解析")
                    startIndex = val.count
                    continue
                }
                let qrVal = Array.init(val[(startIndex+1)..<(startIndex+1+Int(qrLength))])
                startIndex += (Int(qrLength))
                if qrVal.count <= 0 {
                    print("数据异常不解析")
                    //success(model,.fail)
                    startIndex = val.count
                    continue
                }
                let cardModel = ZyBusinessCardModel.init()
                cardModel.index = Int(modelIndex)
                let titleData = titleVal.withUnsafeBufferPointer { (bytes) -> Data in
                    return Data.init(buffer: bytes)
                }
                if let str = String.init(data: titleData, encoding: .utf8) {
                    cardModel.titleString = str
                }

                let qrData = qrVal.withUnsafeBufferPointer({ (bytes) -> Data in
                    return Data.init(buffer: bytes)
                })

                if let str = String.init(data: qrData, encoding: .utf8) {
                    cardModel.qrString = str
                }
                modelArray.append(cardModel)
                startIndex += 1
            }
            
            var string = ""
            for item in modelArray {
                string += String.init(format: "\n序号:%d",item.index)
                string += String.init(format: "\n标题:%@",item.titleString)
                string += String.init(format: "\n二维码:%@",item.qrString)
                string += "\n"
            }
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
            success(modelArray,.none)
        }else{
            success([],.invalidState)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 潜水深度设置
    @objc public func setDiveDeep(count:Int,timeLong:Int,success:@escaping((ZyError) -> Void)) {
        var val:[UInt8] = [
            0x01,
            0x44,
            0x0a,
            0x00,
            UInt8((count ) & 0xff),
            UInt8((count >> 8) & 0xff),
            UInt8((timeLong ) & 0xff),
            UInt8((timeLong >> 8) & 0xff),
            UInt8((timeLong >> 16) & 0xff),
            UInt8((timeLong >> 24) & 0xff),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDiveDeepBlock = success
        }else{
            success(state)
        }
        
    }
    
    private func parseSetDiveDeep(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 潜水深度获取
    @objc public func getDiveDeep(success:@escaping((Int,Int,ZyError) -> Void)) {
        
        var val:[UInt8] = [0x01,0x45,0x04,0x00]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetDiveDeepBlock = success
        }else{
            success(-1,-1,state)
        }
        
    }
    
    func parseGetDiveDeep(val:[UInt8],success:@escaping((Int,Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            let deep = (Int(val[5]) | Int(val[6]) << 8)
            let timeLong = (Int(val[7]) | Int(val[8]) << 8 | Int(val[9]) << 16 | Int(val[10]) << 24)
            
            let string = String.init(format: "深度:%d,时长:%d",deep,timeLong)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,解析:%@", state,string))
            success(Int(deep),Int(timeLong),.none)
            
        }else{
            success(-1,-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 潜水气压转换
    @objc public func setDivePressure(count:Int,success:@escaping((Int,ZyError) -> Void)) {
        var val:[UInt8] = [
            0x01,
            0x46,
            0x08,
            0x00,
            UInt8((count ) & 0xff),
            UInt8((count >> 8) & 0xff),
            UInt8((count >> 16) & 0xff),
            UInt8((count >> 24) & 0xff),
        ]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveSetDivePressureBlock = success
        }else{
            success(-1,state)
        }
        
    }
    
    private func parseSetDivePressure(val:[UInt8],success:@escaping((Int,ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val.count > 8 {
            let count = (Int(val[5]) | Int(val[6]) << 8 | Int(val[7]) << 16 | Int(val[8]) << 24)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@,转换后深度:%d", state,count))
            success(-1,.none)
            
        }else{
            success(-1,.invalidState)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置自定义运动图片
    @objc public func setCustomSportsModeWithImage(_ sportsType:Int,image:UIImage,progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)) {
        
        let imageBin = self.createSendJLdeviceDialOtaFile(image: image, bigSize: .init(width: self.functionListModel?.functionDetail_customSports?.bigWidth ?? 46, height: self.functionListModel?.functionDetail_customSports?.bigHeight ?? 46), smallSize: .init(width: self.functionListModel?.functionDetail_customSports?.smallWidth ?? 30, height: self.functionListModel?.functionDetail_customSports?.smallHeight ?? 30))
        
        self.setCustomSportsMode(sportsType, localFile: imageBin, progress: progress, success: success)
        
    }
    
    // MARK: - 设置自定义运动文件
    @objc public func setCustomSportsMode(_ sportsType:Int,localFile:Any,progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)){
        
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
        guard let fileData = fileData else {return}
        
        var sendDataArray:[UInt8] = Array.init()
        var headArray:[UInt8] = Array.init()
         
        let date = Date.init()
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        var year = calendar.component(.year, from: date)
        if year < 2000 {
            year = 2022
        }
        var month = calendar.component(.month, from: date)
        var day = calendar.component(.day, from: date)
        var hour = calendar.component(.hour, from: date)
        var minute = calendar.component(.minute, from: date)
        var second = calendar.component(.second, from: date)
        
        //固定为 0xAA,0x55
        let head:[UInt8] = [0xaa,0x55]
        //日期/时间  6字节；格式YY-MM-DD HH:MM:SS(BCD码)  默认给的是此刻的时间，实际应该是发第一个model里面的时间
        var time:[UInt8] = [UInt8(self.decimalToBcd(value: year-2000)),UInt8(self.decimalToBcd(value: month)),UInt8(self.decimalToBcd(value: day)),UInt8(self.decimalToBcd(value: hour)),UInt8(self.decimalToBcd(value: minute)),UInt8(self.decimalToBcd(value: second))]
        //运动类型
        let sportsType = [UInt8(sportsType < 26 ? 26 : sportsType)]
        // 文件长度 仅数据部分，不包含文件头
        let fileLength = [UInt8(fileData.count & 0xff),UInt8((fileData.count >> 8) & 0xff),UInt8((fileData.count >> 16) & 0xff),UInt8((fileData.count >> 24) & 0xff)]
        // 文件校验 仅数据部分，不包含文件头，CRC32 校验
        let fileCrc32 = [UInt8(self.CRC32(data: fileData) & 0xff),UInt8((self.CRC32(data: fileData) >> 8) & 0xff),UInt8((self.CRC32(data: fileData) >> 16) & 0xff),UInt8((self.CRC32(data: fileData) >> 24) & 0xff)]
        //预留 9byte
        var arrLength_9:[UInt8] = Array.init()
        for _ in 0..<9 {
            arrLength_9.append(0)
        }
        //文件头校验 CRC32 校验
        headArray.append(contentsOf: head)
        headArray.append(0)//版本号，默认0 后续有需求再改此值
        headArray.append(contentsOf: time)
        headArray.append(contentsOf: sportsType)
        headArray.append(contentsOf: fileLength)
        headArray.append(contentsOf: fileCrc32)
        headArray.append(contentsOf: arrLength_9)
        
        print("self.CRC32(val: headArray) = \(String.init(format: "%04x", self.CRC32(val: headArray)))")
        print("headArray = \(headArray)")
        let headArrayCrc32 = [UInt8(self.CRC32(val: headArray) & 0xff),UInt8((self.CRC32(val: headArray) >> 8) & 0xff),UInt8((self.CRC32(val: headArray) >> 16) & 0xff),UInt8((self.CRC32(val: headArray) >> 24) & 0xff)]
        
        sendDataArray.append(contentsOf: headArray)
        sendDataArray.append(contentsOf: headArrayCrc32)
        
        let sendData = Data.init(bytes: &sendDataArray, count: sendDataArray.count) + fileData
        //print("sendDataArray = \(self.convertDataToHexStr(data: sendDataArray))")
//        let sportsPath = NSHomeDirectory() + "/Documents/test_sportsData.bin"
//        if FileManager.createFile(filePath: sportsPath).isSuccess {
//            
//            FileManager.default.createFile(atPath: sportsPath, contents: self.createSendOtaHead(type: 9 ,data: sendData), attributes: nil)
//        }
        self.setOtaStartUpgrade(type: 9, localFile: self.createSendOtaHead(type:9,data: sendData), isContinue: false, progress: progress, success: success)
    }
    
    // MARK: - 设置辅助定位文件
    @objc public func setAssistedPositioning(_ localFile:Any,progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)){
        
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
        guard let fileData = fileData else {return}
        
        var sendDataArray:[UInt8] = Array.init()
        var headArray:[UInt8] = Array.init()
         
        let date = Date.init()
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        var year = calendar.component(.year, from: date)
        if year < 2000 {
            year = 2022
        }
        var month = calendar.component(.month, from: date)
        var day = calendar.component(.day, from: date)
        var hour = calendar.component(.hour, from: date)
        var minute = calendar.component(.minute, from: date)
        var second = calendar.component(.second, from: date)
        
        //固定为 0xAA,0x55
        let head:[UInt8] = [0xaa,0x55]
        //日期/时间  6字节；格式YY-MM-DD HH:MM:SS(BCD码)  默认给的是此刻的时间，实际应该是发第一个model里面的时间
        var time:[UInt8] = [UInt8(self.decimalToBcd(value: year-2000)),UInt8(self.decimalToBcd(value: month)),UInt8(self.decimalToBcd(value: day)),UInt8(self.decimalToBcd(value: hour)),UInt8(self.decimalToBcd(value: minute)),UInt8(self.decimalToBcd(value: second))]
        // 文件长度 仅数据部分，不包含文件头
        let fileLength = [UInt8(fileData.count & 0xff),UInt8((fileData.count >> 8) & 0xff),UInt8((fileData.count >> 16) & 0xff),UInt8((fileData.count >> 24) & 0xff)]
        // 文件校验 仅数据部分，不包含文件头，CRC32 校验
        let fileCrc32 = [UInt8(self.CRC32(data: fileData) & 0xff),UInt8((self.CRC32(data: fileData) >> 8) & 0xff),UInt8((self.CRC32(data: fileData) >> 16) & 0xff),UInt8((self.CRC32(data: fileData) >> 24) & 0xff)]
        //预留 9byte
        var arrLength_11:[UInt8] = Array.init()
        for _ in 0..<11 {
            arrLength_11.append(0)
        }
        //文件头校验 CRC32 校验
        headArray.append(contentsOf: head)
        headArray.append(0)//版本号，默认0 后续有需求再改此值
        headArray.append(contentsOf: time)
        headArray.append(contentsOf: fileLength)
        headArray.append(contentsOf: fileCrc32)
        headArray.append(contentsOf: arrLength_11)
        
        print("self.CRC32(val: headArray) = \(String.init(format: "%04x", self.CRC32(val: headArray)))")
        print("headArray = \(headArray)")
        let headArrayCrc32 = [UInt8(self.CRC32(val: headArray) & 0xff),UInt8((self.CRC32(val: headArray) >> 8) & 0xff),UInt8((self.CRC32(val: headArray) >> 16) & 0xff),UInt8((self.CRC32(val: headArray) >> 24) & 0xff)]
        
        sendDataArray.append(contentsOf: headArray)
        sendDataArray.append(contentsOf: headArrayCrc32)
        
        let sendData = Data.init(bytes: &sendDataArray, count: sendDataArray.count) + fileData
        //print("sendDataArray = \(self.convertDataToHexStr(data: sendDataArray))")
        self.setOtaStartUpgrade(type: 8, localFile: self.createSendOtaHead(type:8,data: sendData), isContinue: false, progress: progress, success: success)
    }
    
    // MARK: - ota升级
    @objc public func setOtaStartUpgrade(type:Int,localFile:Any,isContinue:Bool,progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)) {
        var type = type
        if type > UInt8.max || type < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            type = 0
        }
        //所有ota相关的命令不用信号量等待机制   直接用writeData方法发送
        if isContinue {
            self.setStartUpgrade(type: type, localFile: localFile, maxCount: 20,isContinue: true, progress: progress, success: success)
        }else{
            self.otaStartIndex = 0
            
            self.setStopUpgrade { error in
                if error == .none {
                    self.setSubpackageInformationInteraction(maxSend: 1024, maxReceive: 1024) { subpackageInfo, error in
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
    @objc public func setSubpackageInformationInteraction(maxSend:Int,maxReceive:Int,success:@escaping(([String:Any],ZyError) -> Void)) {
        var maxSend = maxSend
        if maxSend > UInt16.max || maxSend < UInt16.min {
            print("输入参数超过范围,改为默认值0")
            maxSend = 0
        }
        var maxReceive = maxReceive
        if maxReceive > UInt16.max || maxReceive < UInt16.min {
            print("输入参数超过范围,改为默认值0")
            maxReceive = 0
        }
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
    
    private func parseSetSubpackageInformationInteractionData(val:[UInt8],success:@escaping(([String:Any],ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 0 {
            
            let maxSend = (Int(val[5]) | Int(val[6]) << 8)
            let maxReceive = (Int(val[7]) | Int(val[8]) << 8)
            printLog("最大发送长度 =",maxSend)
            printLog("最大接收长度 =",maxReceive)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(["maxSend":"\(maxSend)","maxReceive":"\(maxReceive)"],.none)
            
        }else{
            success([:],.invalidState)
        }
    }
    
    // MARK: - 分包信息交互(APP) 0x01
    @objc public func replySubpackageInformationInteraction(state:Int,maxSend:Int,maxReceive:Int,success:@escaping((ZyError) -> Void)) {
        var state = state
        if state > UInt8.max || state < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            state = 0
        }
        var maxSend = maxSend
        if maxSend > UInt16.max || maxSend < UInt16.min {
            print("输入参数超过范围,改为默认值0")
            maxSend = 0
        }
        var maxReceive = maxReceive
        if maxReceive > UInt16.max || maxReceive < UInt16.min {
            print("输入参数超过范围,改为默认值0")
            maxReceive = 0
        }
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
    
    private func parseReplySubpackageInformationInteractionData(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 1 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            success(.none)
            
        }else{
            success(.invalidState)
        }
    }
    
    // MARK: - 开始升级
    @objc public func setStartUpgrade(type:Int,localFile:Any,maxCount:Int,isContinue:Bool,progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)) {
        var type = type
        if type > UInt8.max || type < UInt8.min {
            print("输入参数超过范围,改为默认值0")
            type = 0
        }
        var maxCount = maxCount
        if maxCount > UInt16.max || maxCount < UInt16.min {
            print("输入参数超过范围,改为默认值0")
            maxCount = 0
        }
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
            printLog("正常进入升级")
        }
        
    }
    
    private func parseSetStartUpgradeData(val:[UInt8],progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 0 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            
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
                //只要是有过升级，就需要重新获取固件的升级版本信息。此处把之前获取的清除掉
                self.otaVersionInfo = nil
                self.receiveGetDeviceOtaVersionInfo = nil
                self.serverVersionInfoDic.removeAll()
                self.dealUpgradeData(maxSingleCount: maxSingleCount, packageCount: packageCount, packageIndex: 0, val: otaVal,progress: progress, success: success)
            }
            
        }else{
            success(.invalidState)
        }
    }
    
    private func dealUpgradeData(maxSingleCount:Int,packageCount:Int,packageIndex:Int,val:[UInt8],progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)) {
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
        ZySDKLog.writeStringToSDKLog(string: String.init(format: "当前数据组结束序号 ->:%d", totalLength))
    }
    
    // MARK: - 重发包号数据
    private func resendUpgradeData(maxSingleCount:Int,packageCount:Int,resendVal:[UInt8],val:[UInt8],progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)) {
        
        //重传总包数
        let resendTotalCount = (Int(resendVal[6]) | Int(resendVal[7]) << 8 | Int(resendVal[8]) << 16 | Int(resendVal[9]) << 24 )
        
        //单包长度
        let count = maxSingleCount + 4 + 4 + 2
        
        for i in stride(from: 0, to: resendTotalCount, by: 1) {
            
            //重传包序号
            let resendIndex = (Int(resendVal[10+i*4]) | Int(resendVal[11+i*4]) << 8 | Int(resendVal[12+i*4]) << 16 | Int(resendVal[13+i*4]) << 24 )
            printLog("重传包序号 =",resendIndex)
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "重传包序号 ->:%d", resendIndex))
            
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
    @objc public func setStopUpgrade(success:@escaping((ZyError) -> Void)) {
        
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
    
    private func parseSetStopUpgradeData(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 0 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            
            let result = val[5]
            printLog("result =",result)
            
            success(.none)
            
        }else{
            success(.invalidState)
        }
    }
    
    // MARK: - 升级结果
    private func parseGetUpgradeResultData(val:[UInt8],success:@escaping((ZyError) -> Void)) {
        let state = String.init(format: "%02x", val[4])
        
        if val[4] == 0 {
            
            ZySDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
            
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
    
    @objc public func checkUpgradeState(success:@escaping(([String:Any],ZyError) -> Void)) {
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
    var isRequesting = false
    @objc public func getServerOtaDeviceInfo(success:@escaping(([String:Any],ZyError) -> Void)) {
        
        if self.isRequesting {
            printLog("正在获取,请勿重复点击")
            return
        }
        
        printLog("getServerOtaDeviceInfo 调用成功")
        
        self.privateGetOtaVersionInfo { versionSuccess, error in
            if error == .none {
                printLog("GetDeviceOtaVersionInfo ->\(versionSuccess)")
                
                let product = versionSuccess["product"] as! String
                let project = versionSuccess["project"] as! String
                let firmware = versionSuccess["firmware"] as! String
                let library = versionSuccess["library"] as! String
                let font = versionSuccess["font"] as! String

                self.privateGetMac { macSuccess, error in
                    if error == .none {
                        if let string = macSuccess {
                            printLog("macSuccess =\(string)")
                            if self.serverVersionInfoDic.keys.count > 0 {
                                success(self.serverVersionInfoDic,.none)
                            }else{
                                self.isRequesting = true
                                //此处如果在等待的时候把设备断开连接或者是解绑，命令不会再进入回调，而isRequesting是true下次请求永远都不会往下调用。断开连接之后把isRequesting置位false
                                let url = ZyNetworkManager.shareInstance.basicUrl+"/api/ota/getNewVersionByAddress?"+String.init(format: "productId=%@&projectId=%@&firmwareId=%@&imageId=%@&fontId=%@&address=%@",product,project,firmware,library,font,string)
                                ZyNetworkManager.shareInstance.get(url: url, isNeedToken: false) { info in
                                    self.isRequesting = false
                                    printLog("getNewVersionByAddress info =",info)
                                    self.serverVersionInfoDic = info
                                    success(info,.none)
                                } fail: { error in
                                    self.isRequesting = false
                                    printLog("error =",error)
                                    success([:],.fail)
                                }
                            }
                        }
                    }else{
                        self.isRequesting = false
                        success([:],.fail)
                    }
                }
            }else{
                self.isRequesting = false
                success([:],.fail)
            }
        }
        
        
        
        
        /*
        var product = ""
        var project = ""
        var firmware = ""
        var library = ""
        var font = ""
        var mac = ""
        
        let group = DispatchGroup()
        group.enter()
        self.privateGetOtaVersionInfo { versionSuccess, error in
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
            
            //let url = ZyNetworkManager.shareInstance.basicUrl+"/api/ota/get?"+String.init(format: "productId=%@&projectId=%@&firmwareId=%@&firmwareIdSecond=%@&imageId=%@&imageIdSecond=%@&fontId=%@&fontIdSecond=%@",product,project,firmwareFirst,firmwareLast,libraryFirst,libraryLast,fontFirst,fontLast)
            
            //http://www.antjuyi.com/api/ota/getNewVersionByAddress?productId=0&projectId=0&firmwareId=0.0&imageId=0.0&fontId=0.0&address=xx:xx:xx:xx:xx:xx
            let url = ZyNetworkManager.shareInstance.basicUrl+"/api/ota/getNewVersionByAddress?"+String.init(format: "productId=%@&projectId=%@&firmwareId=%@&imageId=%@&fontId=%@&address=%@",product,project,firmware,library,font,mac)
            ZyNetworkManager.shareInstance.get(url: url, isNeedToken: false) { info in
                self.isRequesting = false
                printLog("info =",info)
                success(info,.none)
            } fail: { error in
                self.isRequesting = false
                printLog("error =",error)
                success([:],.fail)
            }
        }
         */
    }
    
    // MARK: - 自动获取OTA版本信息及下载升级
    var currentSyncOtaIndex = 0
    var lastCompleteOtaIndex = -1
    @objc public func setAutoServerOtaDeviceInfo(url:String? = nil,progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)) {
        self.currentSyncOtaIndex = 0
        
        if url != nil {
            if self.isRequesting {
                printLog("正在获取,请勿重复点击")
                return
            }
            self.isRequesting = true
            ZyNetworkManager.shareInstance.get(url: url!, isNeedToken: false) { info in
                self.isRequesting = false
                printLog("setAutoServerOtaDeviceInfo info =",info)
                self.dealServerFile(With: info, progress: progress, success: success)
            } fail: { error in
                self.isRequesting = false
                printLog("error =",error)
                success(.fail)
            }
        }else{
            self.getServerOtaDeviceInfo { dic, error in
                //printLog("dic =",dic,"error =",dic)
                if error == .none {
                    self.dealServerFile(With: dic, progress: progress, success: success)
                }else{
                    printLog("getServerOtaDeviceInfo error")
                    success(.fail)
                }
            }
        }
    }
    
    func dealServerFile(With dic:[String:Any],progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)){
        //["data": Optional([["version": Optional(0.2), "urlx080": Optional(http://oss.antjuyi.com/ota/firmware/P22pro_v0.2.bin), "type": Optional(1)], ["type": Optional(2), "url": Optional(http://oss.antjuyi.com/ota/image/P22pro_v0.2.bin), "version": Optional(0.2)], ["version": Optional(0.2), "url": Optional(http://oss.antjuyi.com/ota/font/P22pro_v0.2.bin), "type": Optional(3)]]), "message": Optional(当前有新版本), "code": Optional(200)]
        
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
                        self.privateGetOtaVersionInfo { versionSuccess, error in
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
                                            ZyBleManager.shareInstance.disconnect(peripheral: peripheral)
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
                                            ZyBleManager.shareInstance.disconnect(peripheral: peripheral)
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
                                            ZyBleManager.shareInstance.disconnect(peripheral: peripheral)
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
    }
    
    func serverOtaMethod(indexCount:Int,dataArray:Array<Dictionary<String,Any>>,progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void))
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
                                                    ZyBleManager.shareInstance.disconnect(peripheral: peripheral)
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
                ZyBleManager.shareInstance.disconnect(peripheral: peripheral)
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
    
    // MARK: - 获取服务器本地表盘文件
    @objc public func getLocalDialImageServerInfo(success:@escaping(([Dictionary<String,Any>]?,ZyError)->Void)) {
        self.privateGetOtaVersionInfo { versionSuccess, error in
            if error == .none {
                printLog("GetDeviceOtaVersionInfo ->\(versionSuccess)")
                
                let product = versionSuccess["product"] as! String
                let project = versionSuccess["project"] as! String

                let url = ZyNetworkManager.shareInstance.basicUrl+String.init(format: "/api/online/getCover?productId=%@&projectId=%@", product,project)
                /*
                 {
                     "code": 200,
                     "message": "获取本地表盘信息成功",
                     "data": [
                         {
                             "url": "http://oss.antjuyi.com/online/local/240x240/p0xp0/1.png",
                             "width": 240,
                             "height": 240,
                             "type": 0
                         },
                         {
                             "url": "http://oss.antjuyi.com/online/local/240x240/p0xp0/2.png",
                             "width": 240,
                             "height": 240,
                             "type": 0
                         },
                         {
                             "url": "http://oss.antjuyi.com/online/local/240x240/p0xp0/3.png",
                             "width": 240,
                             "height": 240,
                             "type": 0
                         }
                     ]
                 }
                 */
                
                ZyNetworkManager.shareInstance.get(url: url, isNeedToken: false) { info in
                                
                    let dic = info
                    if let code = dic["code"] as? Int {
                        if code == 200 {
                            
                            if let dataDic:[Dictionary<String,Any>] = dic["data"] as? [Dictionary<String,Any>] {
                                success(dataDic,.none)
                            }else{
                                printLog("data错误 ->",dic["data"] as Any)
                                success(nil,.fail)
                            }
                            
                        }else{
                            printLog("code != 200",dic["code"] as Any)
                            success(nil,.fail)
                        }
                    }else{
                        printLog("code错误 ->",dic["code"] as Any)
                        success(nil,.fail)
                    }

                } fail: { error in
                    printLog("error =",error as Any)
                    success(nil,.fail)
                }
                
            }else{
                
                success(nil,.fail)
            }
        }
    }
    
    // MARK: - 获取服务器自定义表盘图片
    @objc public func getCustomDialImageServerInfo(success:@escaping(([String:Any]?,ZyError)->Void)) {
        self.privateGetOtaVersionInfo { versionSuccess, error in
            if error == .none {
                printLog("GetDeviceOtaVersionInfo ->\(versionSuccess)")
                
                let product = versionSuccess["product"] as! String
                let project = versionSuccess["project"] as! String

                let url = ZyNetworkManager.shareInstance.basicUrl+String.init(format: "/api/online/getCustom?productId=%@&projectId=%@", product,project)
                /*
                 {
                     "code": 200,
                     "message": "获取数据成功",
                     "data": {
                         "custom": {
                             "backGroundImage": "http://oss.antjuyi.com/online/custom/240x240/P22_Pro_en/background.png",
                             "timeImage": "http://oss.antjuyi.com/online/custom/240x240/P22_Pro_en/time.png",
                             "dateImage": "http://oss.antjuyi.com/online/custom/240x240/P22_Pro_en/date.png",
                             "stepImage": "http://oss.antjuyi.com/online/custom/240x240/P22_Pro_en/step.png",
                             "sleepImage": "http://oss.antjuyi.com/online/custom/240x240/P22_Pro_en/sleep.png",
                             "hrImage": "http://oss.antjuyi.com/online/custom/240x240/P22_Pro_en/hr.png"
                         }
                     }
                 }
                 */
                
                ZyNetworkManager.shareInstance.get(url: url, isNeedToken: false) { info in
                                
                    let dic = info
                    if let code = dic["code"] as? Int {
                        if code == 200 {
                            
                            if let dataDic:[String:Any] = dic["data"] as? [String:Any] {
                                success(dataDic,.none)
                            }else{
                                print("\(type(of: dic["data"])),\(dic["data"] is [String:Any])")
                                print("\(dic["data"])")
                                printLog("data错误 ->",dic["data"] as Any)
                                success(nil,.fail)
                            }
                            
                        }else{
                            printLog("code != 200",dic["code"] as Any)
                            success(nil,.fail)
                        }
                    }else{
                        printLog("code错误 ->",dic["code"] as Any)
                        success(nil,.fail)
                    }

                } fail: { error in
                    printLog("error =",error as Any)
                    success(nil,.fail)
                }
                
            }else{
                
                success(nil,.fail)
            }
        }
    }
    
    // MARK: - 获取在线表盘  旧接口，获取全部
    @objc public func getOnlineDialList(success:@escaping(([ZyOnlineDialModel],ZyError) -> Void)) {
        self.privateGetOtaVersionInfo { versionSuccess, error in
            if error == .none {
                printLog("GetDeviceOtaVersionInfo ->\(versionSuccess)")
                
                let product = versionSuccess["product"] as! String
                let project = versionSuccess["project"] as! String

                let url = ZyNetworkManager.shareInstance.basicUrl+"/api/online/get?"+String.init(format: "productId=%@&projectId=%@",product,project)
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
                
                ZyNetworkManager.shareInstance.get(url: url, isNeedToken: false) { info in
                                
                    let dic = info
                    if let code = dic["code"] as? Int {
                        if code == 200 {
                            
                            if let dataDic = dic["data"] as? Dictionary<String,Any> {
                                
                                var dialArray:[ZyOnlineDialModel] = Array.init()
                                
                                if let listArray = dataDic["list"] as? Array<Dictionary<String,Any>> {
                                    for item in listArray {
                                        let dialModel = ZyOnlineDialModel.init()
                                        if let id = item["id"] as? Int {
                                            dialModel.dialId = id
                                        }
                                        if let imageUrl = item["imageUrl"] as? String {
                                            dialModel.dialImageUrl = imageUrl
                                        }
                                        if let imageUrl = item["previewUrl"] as? String {
                                            dialModel.dialPreviewUrl = imageUrl
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
                
            }else{
                
                success([],.fail)
            }
        }
    }
    // MARK: - 获取在线表盘 新接口，分页获取
    @objc public func getOnlineDialList(pageIndex:Int,pageSize:Int,success:@escaping(([ZyOnlineDialModel],ZyError) -> Void)) {
        
        self.privateGetOtaVersionInfo { versionSuccess, error in
            if error == .none {
                printLog("GetDeviceOtaVersionInfo ->\(versionSuccess)")
                
                let product = versionSuccess["product"] as! String
                let project = versionSuccess["project"] as! String
                
                //http://www.antjuyi.com/api/online/getNew?productId=0&projectId=0&pageIndex=1&pageSize=5
                let url = ZyNetworkManager.shareInstance.basicUrl+"/api/online/getNew?"+String.init(format: "productId=%@&projectId=%@&pageIndex=%d&pageSize=%d",product,project,pageIndex,pageSize)

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
                ZyNetworkManager.shareInstance.get(url: url, isNeedToken: false) { info in
                                
                    let dic = info
                    if let code = dic["code"] as? Int {
                        if code == 200 {
                            
                            if let dataDic = dic["data"] as? Dictionary<String,Any> {
                                
                                var dialArray:[ZyOnlineDialModel] = Array.init()
                                
                                if let listArray = dataDic["list"] as? Array<Dictionary<String,Any>> {
                                    for item in listArray {
                                        let dialModel = ZyOnlineDialModel.init()
                                        if let id = item["id"] as? Int {
                                            dialModel.dialId = id
                                        }
                                        if let imageUrl = item["imageUrl"] as? String {
                                            dialModel.dialImageUrl = imageUrl
                                        }
                                        if let imageUrl = item["previewUrl"] as? String {
                                            dialModel.dialPreviewUrl = imageUrl
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
            }else{
                success([],.fail)
            }
        }
        
        
    }
    
    // MARK: - 同步在线表盘
    @objc public func setOnlienDialFile(model:Any,progress:@escaping((Float) -> Void),success:@escaping((ZyError) -> Void)) {
        
        let fileDownPath = NSHomeDirectory() + "/Documents/onlineDialFile/"
        
        if let model = model as? ZyOnlineDialModel {
            
            if let url = model.dialFileUrl {
                self.downloadBinFile(url: url, filePath: fileDownPath) { fileString, error in
                    if error == .none {
                        
                        //拼接处完整的路径
                        let fileURL = URL.init(fileURLWithPath: fileString)
                        if let fileData = try? Data.init(contentsOf: fileURL) {
                            printLog("fileData.count = \(fileData.count)")
                            //小于5k的文件直接报失败
                            if fileData.count <= 5*1024 {
                                ZySDKLog.writeStringToSDKLog(string: "下载的文件大小 \(fileData.count) bytes <= 5kb 默认异常处理")
                                printLog("下载的文件大小 \(fileData.count) bytes <= 5kb 默认异常处理")
                                success(.fail)
                                return
                            }
                            self.setOtaStartUpgrade(type: 4, localFile: fileString, isContinue: false, progress: progress, success: success)
                        }
                    }
                }
            }else{
                printLog("参数model -> ZyOnlineDialModel -> dialFileUrl错误")
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
            
            printLog("参数model -> 仅支持 ZyOnlineDialModel 、String 、 URL 、Data 类型")
            success(.fail)
            
        }
        
    }
    
    // MARK: - 获取辅助定位数据
    public func getServerAssistedPositioningData(success:@escaping((String?,Data?,ZyError) -> Void)) {

        let urlStringArray = [
            "https://zywlian.oss-cn-hongkong.aliyuncs.com/custom/praylocation/ELPO_BDS_3.DAT",
            "https://zywlian.oss-cn-hongkong.aliyuncs.com/custom/praylocation/ELPO_GAL_3.DAT",
            "https://zywlian.oss-cn-hongkong.aliyuncs.com/custom/praylocation/ELPO_GLO_3.DAT",
            "https://zywlian.oss-cn-hongkong.aliyuncs.com/custom/praylocation/ELPO_GPS_3.DAT",
        ]
        
        let group = DispatchGroup()
        let filePath = NSHomeDirectory() + "/Documents/AssistedPositioning/"
        for item in urlStringArray {
            group.enter()
            self.downloadBinFile(url: item, filePath: filePath, zipType: "DAT") { path, errror in
                group.leave()
                if errror == .none {
                    print("path = \(path)")
                }
            }
        }
        group.notify(queue: .main) {
            print("所有文件下载完毕")
            let fileDic = FileManager.getFileListInFolderWithPath(path: filePath)
            print("fileDic.content = \(fileDic.content)")
            var headData:Data = .init()
            var fileData:Data = .init()
            if let fileNameList = fileDic.content as? [String] {
                let gpsName = "ELPO_GPS_3.DAT"
                let gloName = "ELPO_GLO_3.DAT"
                let galName = "ELPO_GAL_3.DAT"
                let bdsName = "ELPO_BDS_3.DAT"
                if fileNameList.contains(gpsName) && fileNameList.contains(gloName) && fileNameList.contains(galName) && fileNameList.contains(bdsName) {
                    let gpsFile = filePath + gpsName
                    let gloFile = filePath + gloName
                    let galFile = filePath + galName
                    let bdsFile = filePath + bdsName
                    
                    if let gpsData = try? Data.init(contentsOf: URL.init(fileURLWithPath: gpsFile)) {
                        let val = [
                            UInt8((gpsData.count ) & 0xff),
                            UInt8((gpsData.count >> 8) & 0xff),
                            UInt8((gpsData.count >> 16) & 0xff),
                            UInt8((gpsData.count >> 24) & 0xff),
                        ]
                        headData.append(val, count: val.count)
                        fileData.append(gpsData)
                    }
                    
                    if let gloData = try? Data.init(contentsOf: URL.init(fileURLWithPath: gloFile)) {
                        let val = [
                            UInt8((gloData.count ) & 0xff),
                            UInt8((gloData.count >> 8) & 0xff),
                            UInt8((gloData.count >> 16) & 0xff),
                            UInt8((gloData.count >> 24) & 0xff),
                        ]
                        headData.append(val, count: val.count)
                        fileData.append(gloData)
                    }
                    
                    if let galData = try? Data.init(contentsOf: URL.init(fileURLWithPath: galFile)) {
                        let val = [
                            UInt8((galData.count ) & 0xff),
                            UInt8((galData.count >> 8) & 0xff),
                            UInt8((galData.count >> 16) & 0xff),
                            UInt8((galData.count >> 24) & 0xff),
                        ]
                        headData.append(val, count: val.count)
                        fileData.append(galData)
                    }
                    
                    if let bdsData = try? Data.init(contentsOf: URL.init(fileURLWithPath: bdsFile)) {
                        let val = [
                            UInt8((bdsData.count ) & 0xff),
                            UInt8((bdsData.count >> 8) & 0xff),
                            UInt8((bdsData.count >> 16) & 0xff),
                            UInt8((bdsData.count >> 24) & 0xff),
                        ]
                        headData.append(val, count: val.count)
                        fileData.append(bdsData)
                    }
                    
                    let finalFilePath = filePath + "finalFile.DAT"
                    let finalData = headData+fileData
                    if FileManager.createFile(filePath: filePath).isSuccess {
                        FileManager.default.createFile(atPath: finalFilePath, contents: finalData, attributes: nil)
                    }
                    success(finalFilePath,finalData,.none)
                }else{
                    success(nil,nil,.fail)
                }
            }else{
                success(nil,nil,.fail)
            }
            
        }
    }
    
    func downloadBinFile(url:String,filePath:String,zipType:String? = nil,success:@escaping((String,ZyError) -> Void)) {
        var fileString = ""
        let destination:Alamofire.DownloadRequest.DownloadFileDestination/*Destination*/ = { (_, _) in
            let binFileArray = url.components(separatedBy: "/")
            
            var zipDefaultString = "default."
            if let typeString = zipType {
                zipDefaultString += typeString
            }else{
                zipDefaultString += "bin"
            }
            
            fileString = filePath + (binFileArray.last ?? zipDefaultString)
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
            ZySDKLog.writeStringToSDKLog(string: "发送:"+dataString)
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
                ZySDKLog.writeStringToSDKLog(string: "发送:"+dataString)
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
            ZySDKLog.writeStringToSDKLog(string: "发送:"+dataString)
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
            ZySDKLog.writeStringToSDKLog(string: "发送:"+dataString)
            printLog("send",dataString)
            //                printLog("((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0)",((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? "withoutResponse" : "withResponse")
            self.peripheral?.writeValue(newData, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
}
