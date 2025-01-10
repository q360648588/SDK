//
//  AndXuCommandModule.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2021/7/5.
//

import UIKit
import CoreBluetooth
import JL_BLEKit

@objc public enum ZywlError : Int {
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

@objc public class ZywlCommandModule: ZywlBaseModule {
    
    @objc public static let shareInstance = ZywlCommandModule()
    
    private var semaphoreCount = 1
    private var signalValue = 1
    private var commandSemaphore = DispatchSemaphore(value: 1)
    private var commandListArray:Array<Data> = .init()
    private var isCommandSendState = false
    private var lastSendData:Data?
    private var commandDetectionTimer:Timer?//检测发送的是否有命令回复的定时器
    private var commandDetectionCount = 0
    
    private var semaphoreChargingBoxCount = 1
    private var chargingBoxSemaphore = DispatchSemaphore(value: 1)
    private var chargingBoxListArray:Array<Data> = .init()
    private var isChargingBoxSendState = false
    private var chargingBoxDetectionTimer:Timer?//检测充电仓发送的是否有命令回复的定时器
    private var chargingBoxDetectionCount = 0
    
    private var receiveGetHeadphoneBattery:((Int,Int,ZywlError) -> Void)?
    private var receiveGetBoxBattery:((Int,ZywlError) -> Void)?
    private var receiveSetFindHeadphoneDevice:((ZywlError) -> Void)?
    private var receiveGetMac:((String?,String?,ZywlError) -> Void)?
    private var receiveGetFirmwareVersion:((String?,String?,ZywlError) -> Void)?
    private var receiveGetCustomButton:((Int,Int,Int,ZywlError) -> Void)?
    private var receiveSetCustomButton:((ZywlError) -> Void)?
    private var receiveGetLowLatencyMode:((Int,ZywlError) -> Void)?
    private var receiveSetLowLatencyMode:((ZywlError) -> Void)?
    private var receiveGetInEarDetection:((Int,ZywlError) -> Void)?
    private var receiveSetInEarDetection:((ZywlError) -> Void)?
    private var receiveGetEqMode:((Int,ZywlError) -> Void)?
    private var receiveSetEqMode:((ZywlError) -> Void)?
    private var receiveGetAmbientSound:((Int,ZywlError) -> Void)?
    private var receiveSetAmbientSound:((ZywlError) -> Void)?
    private var receiveGetHeadsetWearingStatus:((Int,ZywlError) -> Void)?
    private var receiveSetResetFactory:((ZywlError) -> Void)?
    private var receiveGetDesktopMode:((Int,ZywlError) -> Void)?
    private var receiveSetDesktopMode:((ZywlError) -> Void)?
    private var receiveGetPanoramicSound:((Int,ZywlError) -> Void)?
    private var receiveSetPanoramicSound:((ZywlError) -> Void)?
    private var receiveGetLhdcMode:((Int,ZywlError) -> Void)?
    private var receiveGetSpeedMode:((Int,ZywlError) -> Void)?
    private var receiveSetSpeedMode:((ZywlError) -> Void)?
    private var receiveGetResistanceWindNoise:((Int,ZywlError) -> Void)?
    private var receiveSetResistanceWindNoise:((ZywlError) -> Void)?
    private var receiveGetBassToneEnhancement:((Int,ZywlError) -> Void)?
    private var receiveSetBassToneEnhancement:((ZywlError) -> Void)?
    private var receiveGetLowFrequencyEnhancement:((Int,ZywlError) -> Void)?
    private var receiveSetLowFrequencyEnhancement:((ZywlError) -> Void)?
    private var receiveGetCoupletPattern:((Int,ZywlError) -> Void)?
    private var receiveSetCoupletPattern:((ZywlError) -> Void)?
    
    //OWS
    private var receiveGetOwsDeviceAllInformation:((ZywlOwsL04DeviceInformationModel?,ZywlError) -> Void)?
    private var receiveGetOwsBoxScreenSize:((Int,Int,ZywlError) -> Void)?
    private var receiveGetOwsBleName:((String?,ZywlError) -> Void)?
    private var receiveGetOwsMediaVoiceVolume:((Int,ZywlError) -> Void)?
    private var receiveGetOwsScreenOutTimeLength:((Int,ZywlError) -> Void)?
    private var receiveGetOwsLocalDialIndex:((Int,Int,ZywlError) -> Void)?
    private var receiveGetOwsMessageRemind:((Bool,Bool,Bool,ZywlError) -> Void)?
    private var receiveGetOwsGameMode:((Bool,ZywlError) -> Void)?
    private var receiveGetOwsNoiseControlMode:((Int,ZywlError) -> Void)?
    private var receiveGetOwsNoiseReductionMode:((Int,ZywlError) -> Void)?
    private var receiveGetOwsShakeSongMode:((Bool,ZywlError) -> Void)?
    private var receiveGetOwsSupportFunction:((Int,Int,ZywlError) -> Void)?
    private var receiveGetOwsDeviceOriginalName:((String?,ZywlError) -> Void)?
    private var receiveGetOwsAlarmArray:((_ modelArray:[ZywlOwsAlarmModel],_ error:ZywlError)->Void)?
    private var receiveSetOwsClearPairingRecord:((ZywlError) -> Void)?
    private var receiveSetOwsResetFactory:((ZywlError) -> Void)?
    private var receiveSetOwsTouchButtonFunction:((ZywlError) -> Void)?
    private var receiveSetOwsAllTouchButtonReset:((ZywlError) -> Void)?
    private var receiveSetOwsFindHeadphones:((ZywlError) -> Void)?
    private var receiveSetOwsBleName:((ZywlError) -> Void)?
    private var receiveSetOwsMediaVoiceVolume:((ZywlError) -> Void)?
    private var receiveSetOwsScreenOutTimeLength:((ZywlError) -> Void)?
    private var receiveSetOwsLocalDialIndex:((ZywlError) -> Void)?
    private var receiveSetOwsMessageRemind:((ZywlError) -> Void)?
    private var receiveSetOwsGameMode:((ZywlError) -> Void)?
    private var receiveSetOwsNoiseControlMode:((ZywlError) -> Void)?
    private var receiveSetOwsNoiseReductionMode:((ZywlError) -> Void)?
    private var receiveSetOwsShakeSong:((ZywlError) -> Void)?
    private var receiveSetOwsShakeSongMode:((ZywlError) -> Void)?
    private var receiveSetOwsTime:((ZywlError) -> Void)?
    private var receiveSetOwsLanguage:((ZywlError) -> Void)?
    private var receiveSetOwsAlarmArray:((ZywlError) -> Void)?
    private var receiveSetOwsOperationSong:((ZywlError) -> Void)?
    private var receiveSetOwsWeather:((ZywlError) -> Void)?
    private var receiveReportOwsMediaVoiceVolume:((Int,ZywlError) -> Void)?
    private var receiveReportOwsBattery:((Int,Int,Int,ZywlError) -> Void)?
    private var receiveGetOwsEqMode:((Bool,Int,ZywlError) -> Void)?
    private var receiveSetOwsEqMode:((ZywlError) -> Void)?
    private var receiveGetOwsCustomEq:((Int,[Int],ZywlError) -> Void)?
    private var receiveSetOwsCustomEq:((ZywlError) -> Void)?
    private var reportOwsModel:((ZywlOwsL04DeviceInformationModel?) -> Void)?
    
    //ZYCX
    private var receiveGetZycxSubcontractingInfomation:((Int,ZywlError)->Void)?
    private var receiveReportZycxSubcontractingInfomation:((Int,ZywlError)->Void)?
    private var receiveGetZycxFunctionList:((ZycxFunctionListModel?,ZywlError)->Void)?
    private var receiveGetZycxHeadphoneFunctionList:((ZycxHeadphoneFunctionListModel?,ZywlError)->Void)?
    private var receiveGetZycxDeviceInfomation:((_ model:ZycxDeviceInfomationModel?,_ error:ZywlError)->Void)?
    private var receiveGetZycxHeadphoneDeviceInfomation:((_ model:ZycxHeadphoneDeviceInfomationModel?,_ error:ZywlError)->Void)?
    private var receiveGetZycxDeviceParameters:((_ model:ZycxDeviceParametersModel?,_ error:ZywlError)->Void)?
    private var receiveGetZycxHeadphoneDeviceParameters:((_ model:ZycxHeadphoneDeviceParametersModel?,_ error:ZywlError)->Void)?
    private var receiveSetZycxDeviceParameters:((_ error:ZywlError)->Void)?
    private var receiveSetZycxTimezone:((_ error:ZywlError)->Void)?
    private var receiveSetZycxTime:((_ error:ZywlError)->Void)?
    private var receiveSetZycxTimeFormat:((_ error:ZywlError)->Void)?
    private var receiveSetZycxWeatherUnit:((_ error:ZywlError)->Void)?
    private var receiveSetZycxScreenLightLevel:((_ error:ZywlError)->Void)?
    private var receiveSetZycxScreenLightTimeLong:((_ error:ZywlError)->Void)?
    private var receiveSetZycxDialIndex:((_ error:ZywlError)->Void)?
    private var receiveSetZycxLanguageIndex:((_ error:ZywlError)->Void)?
    private var receiveSetZycxMessagePush:((_ error:ZywlError)->Void)?
    private var receiveSetZycxAlarmArray:((_ error:ZywlError)->Void)?
    private var receiveSetZycxCustomDialInfomation:((_ error:ZywlError)->Void)?
    private var receiveSetZycxWeather:((_ error:ZywlError)->Void)?
    private var receiveSetZycxSosContact:((_ error:ZywlError)->Void)?
    private var receiveSetZycxAddressContact:((_ error:ZywlError)->Void)?
    private var receiveSetZycxDeviceUuidString:((_ error:ZywlError)->Void)?
    private var receiveSetZycxDeviceVibration:((_ error:ZywlError)->Void)?
    private var receiveSetZycxSedentary:((_ error:ZywlError)->Void)?
    private var receiveSetZycxDrinkWater:((_ error:ZywlError)->Void)?
    private var receiveSetZycxDisturb:((_ error:ZywlError)->Void)?
    private var receiveSetZycxLostRemind:((_ error:ZywlError)->Void)?
    private var receiveSetZycxPhysiologicalCycle:((_ error:ZywlError)->Void)?
    private var receiveSetZycxBleName:((_ error:ZywlError)->Void)?
    private var receiveSetZycxPowerOff:((_ error:ZywlError)->Void)?
    private var receiveSetZycxRestart:((_ error:ZywlError)->Void)?
    private var receiveSetZycxResetFactory:((_ error:ZywlError)->Void)?
    private var receiveSetZycxResetFactoryAndPowerOff:((_ error:ZywlError)->Void)?
    private var receiveSetZycxShipMode:((_ error:ZywlError)->Void)?
    private var receiveSetZycxVibrationMotor:((_ error:ZywlError)->Void)?
    private var receiveSetZycxFindChargingBox:((_ error:ZywlError)->Void)?
    private var receiveSetZycxClearBtInfomation:((_ error:ZywlError)->Void)?
    private var receiveSetZycxBtRadioEnable:((_ error:ZywlError)->Void)?
    private var receiveSetZycxBindState:((_ error:ZywlError)->Void)?
    private var receiveSetZycxClearData:((_ error:ZywlError)->Void)?
    
    private var receiveGetZycxBattery:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveGetZycxHeadphoneConnectState:((_ value:Bool,_ error:ZywlError)->Void)?
    private var receiveGetZycxBoxCoverState:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveGetZycxBoxBtConnectStatus:((_ value:Int,_ error:ZywlError)->Void)?
    
    private var receiveReportZycxBattery:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxWeatherUnit:((_ value:Bool,_ error:ZywlError)->Void)?
    private var receiveReportZycxScreenLightLevel:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxScreenLightTimeLong:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxLocalDialIndex:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxLanguageIndex:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxShakeSong:((_ value:Bool,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneConnectState:((_ value:Bool,_ error:ZywlError)->Void)?
    private var receiveReportZycxBoxCoverState:((_ value:Bool,_ error:ZywlError)->Void)?
    private var receiveReportZycxEnterOrExitCameraMode:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxCallControl:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxMusicControl:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxFindChargingBox:((_ value:Bool,_ error:ZywlError)->Void)?
    private var receiveReportZycxTakePhoto:((_ value:Int,_ error:ZywlError)->Void)?
    
    private var receiveReportZycxMusicState:((_ state:Int,_ vioceVoolume:Int,_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneCustomButtonList:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneEqMode:((_ error:ZywlError)->Void)?
    
    private var receiveGetZycxHeadphoneSubcontractingInfomation:((Int,ZywlError)->Void)?
    private var receiveReportZycxHeadphoneSubcontractingInfomation:((Int,ZywlError)->Void)?
    
    private var receiveSetZycxHeadphoneAmbientSoundEffect:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneSpaceSoundEffect:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneInEarPerception:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneExtremeSpeedMode:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneWindNoiseResistantMode:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneBassToneEnhancement:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneLowFrequencyEnhancement:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneCoupletPattern:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneDesktopMode:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneShakeSong:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneVoiceVolume:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneSoundEffectMode:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphonePatternMode:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneBattery:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphonePowerOff:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneRestart:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneResetFactory:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneResetFactoryAndPowerOff:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneTiktokControl:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneMusicControl:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneCallControl_AndswerHandUp:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneCallControl_DtmfDialing:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneCallControl_VolumeVoice:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneFind:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneTakePhoto:((_ error:ZywlError)->Void)?
    private var receiveSetZycxHeadphoneCustomButtonResetDefault:((_ error:ZywlError)->Void)?
    
    private var receiveGetZycxHeadphoneStateBattery:((_ leftBattery:Int,_ rightBattery:Int,_ error:ZywlError)->Void)?
    private var receiveGetZycxHeadphoneMusicState:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveGetZycxHeadphoneCurrentTime:((_ timeString:String,_ error:ZywlError)->Void)?
    private var receiveGetZycxHeadphoneBtConncetState:((_ state:Int,_ error:ZywlError)->Void)?
    private var receiveGetZycxHeadphoneTwsIsPair:((_ state:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneBattery:((_ leftBattery:Int,_ rightBattery:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneFind:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneCallControl:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneMusicState:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneAmbientSoundEffect:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneSpaceSoundEffect:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneInEarPerception:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneExtremeSpeedMode:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneWindNoiseResistantMode:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneBassToneEnhancement:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneLowFrequencyEnhancement:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneCoupletPattern:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneDesktopMode:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneShakeSong:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneVoiceVolume:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneEqMode:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneCustomButton:((_ value:[ZycxHeadphoneDeviceParametersModel_customButton],_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneClassicBluetoothConnect:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneCurrentTime:((_ timeString:String,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphoneSoundEffectMode:((_ value:Int,_ error:ZywlError)->Void)?
    private var receiveReportZycxHeadphonePatternMode:((_ value:Int,_ error:ZywlError)->Void)?
    
    var receiveSetZycxStartUpgradeBlock:((ZywlError) -> Void)?
    var receiveSetZycxStartUpgradeProgressBlock:((Float) -> Void)?
    var receiveSetZycxStopUpgradeBlock:((ZywlError) -> Void)?
    var receiveCheckUpgradeStateBlock:(([String:Any],ZywlError) -> Void)?
    
    var otaData:Data?
    var otaStartIndex = 0
    var otaMaxSingleCount = 0
    var otaPackageCount = 0
    var otaCheckFailResendData:Data?
    var otaContinueDataLength = 0
    var failCheckCount = 0
    
    var newProtocalData:Data?
    var totalLength = 0
    var isNewProtocalData = false
    var newProtocalMaxIndex = 0
    var newProtocalLength = 0
    var newProtocalCRC16 = 0
    
    var currentReceiveCommandEndOver = false //当前接收命令状态是否结束   5s没有接收到回复数据默认结束，赋值true
    var sendFailState = false  //命令发送失败状态，true时在信号量需要发命令的地方return待发送的命令
    var owsModel:ZywlOwsL04DeviceInformationModel? = nil //设备信息模型
    public var zycxDeviceInfoModel:ZycxDeviceInfomationModel? = nil
    public var zycxHeadphoneDeviceInfoModel:ZycxHeadphoneDeviceInfomationModel? = nil
    
    var isHeadphoneForwardingData = false
    
    private override init() {
        super.init()
        
        ZywlCrashHandler.setup { (stackTrace, completion) in
            
            printLog("CrashHandler",stackTrace);
            
            let date:NSDate = NSDate()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "YYYY/MM/dd hh:mm:ss SS"
            let strNowTime = timeFormatter.string(from: date as Date) as String
            let url:String = String.init(format: "========异常错误报告========\ntime:%@\n%@\n\n\n\n\n蓝牙相关:%@",strNowTime,stackTrace,ZywlSDKLog.showLog())
            
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
        self.headphoneWriteCharacteristic = super.headphoneWriteCharacteristic
        self.headphoneReceiveCharacteristic = super.headphoneReceiveCharacteristic
        self.headphonePeripheral = super.headphonePeripheral
        
        self.chargingBoxWriteCharacteristic = super.chargingBoxWriteCharacteristic
        self.chargingBoxReceiveCharacteristic = super.chargingBoxReceiveCharacteristic
        self.chargingBoxPeripheral = super.chargingBoxPeripheral
                        
        ZywlBleManager.shareInstance.PeripheralUpdateValue { (peripheral, characteristic, error) in
            
            let data = characteristic.value ?? Data.init()
            
            let val = data.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
            }
            
            if val.count <= 0 {
                printLog("characteristic数据为空")
                return
            }
            
            if characteristic == self.headphoneReceiveCharacteristic {
                printLog("characteristic =",characteristic)
                //if characteristic.value?.count ?? 0 > 20 {
                    let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: characteristic.value ?? Data.init(),isSend: true))
                    printLog("characteristic.value =",dataString)
                    ZywlSDKLog.writeStringToSDKLog(string: dataString)
                //}
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsDeviceAllInformation长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsBoxScreenSize长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsBleName长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsMediaVoiceVolume长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsScreenOutTimeLength长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsLocalDialIndex长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "OwsMessageRemind长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "OwsGameMode长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsNoiseControlMode长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsNoiseReductionMode长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsShakeSongMode长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsSupportFunction长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsDeviceOriginalName长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsAlarmArray长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsClearPairingRecord长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsResetFactory长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsTouchButtonFunction长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsAllTouchButtonReset长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsFindHeadphones长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsBleName长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsMediaVoiceVolume长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsScreenOutTimeLength长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsLocalDialIndex长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsMessageRemind长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsGameMode长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsNoiseControlMode长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsNoiseReductionMode长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsShakeSong长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsShakeSong长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsTime长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsLanguage长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsAlarmArray长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsOperationSong长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsWeather长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "ReportOwsMediaVoiceVolume长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "ReportOwsMediaVoiceVolume长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsEqMode长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsEqMode长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "GetOwsCustomEq长度校验出错"))
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
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "SetOwsCustomEq长度校验出错"))
                        }
                    }
                }
                
                // MARK: - ZYCX 0xAB，仓对耳机；0xC0，手机对耳机；
                if val[0] == 0xab || val[0] == 0xc0 {
                    
                    let firstBit = Int(val[2])
                    let maxMtuCount = self.maxMtuCount

                    let crc16 = (Int(val[val.count-2]) << 8 | Int(val[val.count-1]))
                    
                    if firstBit > 0 {

                        let totalCount = (Int(val[4]) << 8 | Int(val[5]))
                        let currentCount = (Int(val[6]) << 8 | Int(val[7]) )

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
                            let errorString = String.init(format: "第%d包crc16校验出错,app计算的:%02x,设备返回的:%02x", currentCount,self.CRC16(val: testArray),crc16)
                            print("errorString = \(errorString)")
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: errorString))
                        }

                        if totalCount == currentCount + 0 {
                            let totalLength = (Int(val[2]) << 8 | (firstBit-128))
                            guard self.newProtocalData != nil else {
                                print("self.newProtocalData 数据错误")
                                return
                            }
                            if self.newProtocalData!.count == totalLength {

                                let newVal = self.newProtocalData!.withUnsafeBytes({ (bytes) -> [UInt8] in
                                    let b = (bytes.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                                    return [UInt8](UnsafeBufferPointer.init(start: b, count: (self.newProtocalData?.count ?? 0)))
                                })
                                
                                if val[1] == 0x80 { //主动获取分包信息
                                    
                                    if let block = self.receiveGetZycxHeadphoneSubcontractingInfomation {
                                        self.parseGetZycxHeadphoneSubcontractingInfomation(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x81 { //设备上报分包信息
                                    
                                    if let block = self.receiveReportZycxHeadphoneSubcontractingInfomation {
                                        self.parseReportZycxHeadphoneSubcontractingInfomation(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                
                                if val[1] == 0x82 { //功能列表返回
                                    
                                    if let block = self.receiveGetZycxHeadphoneFunctionList {
                                        self.parseGetZycxHeadphoneFunctionList(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x83 { //设备信息
                                    
                                    if let block = self.receiveGetZycxHeadphoneDeviceInfomation {
                                        self.parseGetZycxHeadphoneDeviceInfomation(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x84 { //设备参数获取
                                    
                                    if let block = self.receiveGetZycxHeadphoneDeviceParameters {
                                        self.parseGetZycxHeadphoneDeviceParameters(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x85 { //设备参数设置
                                    let cmd_id = val[4]
                                    let result = val[5]
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveSetZycxHeadphoneCustomButtonList {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveSetZycxHeadphoneEqMode {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 2:
//                                        if let block = self.receiveSetZycxTimeFormat {
//                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
//                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveSetZycxHeadphoneAmbientSoundEffect {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 4:
                                        if let block = self.receiveSetZycxHeadphoneSpaceSoundEffect {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveSetZycxHeadphoneInEarPerception {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 6:
                                        if let block = self.receiveSetZycxHeadphoneExtremeSpeedMode {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 7:
                                        if let block = self.receiveSetZycxHeadphoneWindNoiseResistantMode {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 8:
                                        if let block = self.receiveSetZycxHeadphoneBassToneEnhancement {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 9:
                                        if let block = self.receiveSetZycxHeadphoneLowFrequencyEnhancement {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 10:
                                        if let block = self.receiveSetZycxHeadphoneCoupletPattern {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 11:
                                        if let block = self.receiveSetZycxHeadphoneDesktopMode {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 12:
                                        if let block = self.receiveSetZycxHeadphoneShakeSong {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 13:
                                        if let block = self.receiveSetZycxHeadphoneVoiceVolume {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 14:
                                        if let block = self.receiveSetZycxHeadphoneBattery {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 15:
                                        if let block = self.receiveSetZycxHeadphoneSoundEffectMode {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 16:
                                        if let block = self.receiveSetZycxHeadphonePatternMode {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    if let block = self.receiveSetZycxDeviceParameters {
                                        self.parseSetZycxDeviceParameters(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x86 { //设备控制
                                    let cmd_id = val[4]
                                    let result = val[5]
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveSetZycxHeadphonePowerOff {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        if let block = self.receiveSetZycxHeadphoneRestart {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        if let block = self.receiveSetZycxHeadphoneResetFactory {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        if let block = self.receiveSetZycxHeadphoneResetFactoryAndPowerOff {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveSetZycxHeadphoneTiktokControl {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveSetZycxHeadphoneMusicControl {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveSetZycxHeadphoneCallControl_AndswerHandUp {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                            self.receiveSetZycxHeadphoneCallControl_AndswerHandUp = nil
                                        }
                                        if let block = self.receiveSetZycxHeadphoneCallControl_DtmfDialing {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                            self.receiveSetZycxHeadphoneCallControl_DtmfDialing = nil
                                        }
                                        if let block = self.receiveSetZycxHeadphoneCallControl_VolumeVoice {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                            self.receiveSetZycxHeadphoneCallControl_VolumeVoice = nil
                                        }
                                        
                                        break
                                    case 4:
                                        if let block = self.receiveSetZycxHeadphoneFind {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveSetZycxHeadphoneTakePhoto {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 6:
                                        if let block = self.receiveSetZycxHeadphoneCustomButtonResetDefault {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                        
                                        
                                    default:
                                        break
                                    }
                                }
                            }else{

                                print("命令长度错误")
                                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "新协议0xac长度校验出错"))
                            }
                            self.newProtocalData = nil
                            self.totalLength = 0
                        }

                    }else{

                        let totalLength = (Int(val[2]) << 8 | Int(val[3]) )
                        if totalLength == val.count - 6 {
                            
                            if val[1] == 0x80 { //主动获取分包信息
                                
                                if let block = self.receiveGetZycxHeadphoneSubcontractingInfomation {
                                    self.parseGetZycxHeadphoneSubcontractingInfomation(val: Array(val[4..<(val.count-2)]), success: block)
                                }
//
                            }
                            
                            if val[1] == 0x81 { //设备上报分包信息
                                
                                if let block = self.receiveReportZycxHeadphoneSubcontractingInfomation {
                                    self.parseGetZycxHeadphoneSubcontractingInfomation(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x82 { //功能列表返回
                                if let block = self.receiveGetZycxHeadphoneFunctionList {
                                    self.parseGetZycxHeadphoneFunctionList(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                            }
                            
                            if val[1] == 0x83 { //设备信息
                                
                                if let block = self.receiveGetZycxHeadphoneDeviceInfomation {
                                    self.parseGetZycxHeadphoneDeviceInfomation(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x84 { //设备参数
                                
                                if let block = self.receiveGetZycxHeadphoneDeviceParameters {
                                    self.parseGetZycxHeadphoneDeviceParameters(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x85 { //设备参数设置
                                let cmd_id = val[5]
                                let result = val[6]
                                
                                switch cmd_id {
                                case 0:
                                    if let block = self.receiveSetZycxHeadphoneCustomButtonList {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 1:
                                    if let block = self.receiveSetZycxHeadphoneEqMode {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 2:
//                                    if let block = self.receiveSetZycxTimeFormat {
//                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
//                                    }
                                    break
                                case 3:
                                    if let block = self.receiveSetZycxHeadphoneAmbientSoundEffect {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 4:
                                    if let block = self.receiveSetZycxHeadphoneSpaceSoundEffect {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 5:
                                    if let block = self.receiveSetZycxHeadphoneInEarPerception {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 6:
                                    if let block = self.receiveSetZycxHeadphoneExtremeSpeedMode {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 7:
                                    if let block = self.receiveSetZycxHeadphoneWindNoiseResistantMode {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 8:
                                    if let block = self.receiveSetZycxHeadphoneBassToneEnhancement {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 9:
                                    if let block = self.receiveSetZycxHeadphoneLowFrequencyEnhancement {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 10:
                                    if let block = self.receiveSetZycxHeadphoneCoupletPattern {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 11:
                                    if let block = self.receiveSetZycxHeadphoneDesktopMode {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 12:
                                    if let block = self.receiveSetZycxHeadphoneShakeSong {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 13:
                                    if let block = self.receiveSetZycxHeadphoneVoiceVolume {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 14:
                                    if let block = self.receiveSetZycxHeadphoneBattery {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 15:
                                    if let block = self.receiveSetZycxHeadphoneSoundEffectMode {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 16:
                                    if let block = self.receiveSetZycxHeadphonePatternMode {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                default:
                                    break
                                }
                                if let block = self.receiveSetZycxDeviceParameters {
                                    self.parseSetZycxDeviceParameters(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x86 { //设备控制
                                let cmd_id = val[4]
                                let result = val[5]
                                
                                switch cmd_id {
                                case 0:
                                    if let block = self.receiveSetZycxHeadphonePowerOff {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    if let block = self.receiveSetZycxHeadphoneRestart {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    if let block = self.receiveSetZycxHeadphoneResetFactory {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    if let block = self.receiveSetZycxHeadphoneResetFactoryAndPowerOff {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    
                                    break
                                case 1:
                                    if let block = self.receiveSetZycxHeadphoneTiktokControl {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 2:
                                    if let block = self.receiveSetZycxHeadphoneMusicControl {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 3:
                                    if let block = self.receiveSetZycxHeadphoneCallControl_AndswerHandUp {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        self.receiveSetZycxHeadphoneCallControl_AndswerHandUp = nil
                                    }
                                    if let block = self.receiveSetZycxHeadphoneCallControl_DtmfDialing {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        self.receiveSetZycxHeadphoneCallControl_DtmfDialing = nil
                                    }
                                    if let block = self.receiveSetZycxHeadphoneCallControl_VolumeVoice {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        self.receiveSetZycxHeadphoneCallControl_DtmfDialing = nil
                                    }
                                    break
                                case 4:
                                    if let block = self.receiveSetZycxHeadphoneFind {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 5:
                                    if let block = self.receiveSetZycxHeadphoneTakePhoto {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 6:
                                    if let block = self.receiveSetZycxHeadphoneCustomButtonResetDefault {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                default:
                                    break
                                }
                            }
                            
                            if val[1] == 0x87 { //状态查询
                                let stateVal = Array(val[4..<(val.count-2)])
                                var currentIndex = 0
                                while currentIndex < stateVal.count {
                                    let cmd_id = stateVal[currentIndex]
                                    let cmd_length = stateVal[currentIndex+1]
                                    var cmd_result:[UInt8] = []
                                    if currentIndex+1+Int(cmd_length) < stateVal.count{
                                        cmd_result = Array(stateVal[(currentIndex+2)..<(currentIndex+2+Int(cmd_length))])
                                    }
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveGetZycxHeadphoneStateBattery {
                                            self.parseGetZycxHeadphoneStateBattery(val: cmd_result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveGetZycxHeadphoneMusicState {
                                            self.parseGetZycxHeadphoneMusicState(val: cmd_result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveGetZycxHeadphoneCurrentTime {
                                            self.parseGetZycxHeadphoneCurrentTime(val: cmd_result, success: block)
                                        }
                                        break
                                    case 4:
                                        if let block = self.receiveGetZycxHeadphoneBtConncetState {
                                            self.parseGetZycxHeadphoneBtConncetState(val: cmd_result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveGetZycxHeadphoneTwsIsPair {
                                            self.parseGetZycxHeadphoneTwsIsPair(val: cmd_result, success: block)
                                        }
                                        break
                                        
                                    default:
                                        break
                                    }
                                    currentIndex = currentIndex + 2 + Int(cmd_length)
                                }
                            }
                            
                            if val[1] == 0x88 { //状态上报
                                let stateVal = Array(val[4..<(val.count-2)])
                                var currentIndex = 1
                                while currentIndex < stateVal.count {
                                    let cmd_id = stateVal[currentIndex]
                                    let cmd_length = stateVal[currentIndex+1]
                                    var cmd_result:[UInt8] = []
                                    if currentIndex+1+Int(cmd_length) < stateVal.count{
                                        cmd_result = Array(stateVal[(currentIndex+2)..<(currentIndex+2+Int(cmd_length))])
                                    }
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveReportZycxHeadphoneBattery {
                                            self.parseReportZycxHeadphoneBattery(val: cmd_result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveReportZycxHeadphoneFind {
                                            self.parseReportZycxHeadphoneFind(val: cmd_result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveReportZycxHeadphoneCallControl {
                                            self.parseReportZycxHeadphoneCallControl(val: cmd_result, success: block)
                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveReportZycxHeadphoneMusicState {
                                            self.parseReportZycxHeadphoneMusicState(val: cmd_result, success: block)
                                        }
                                        break
                                    case 4:
                                        if let block = self.receiveReportZycxHeadphoneAmbientSoundEffect {
                                            self.parseReportZycxHeadphoneAmbientSoundEffect(val: cmd_result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveReportZycxHeadphoneSpaceSoundEffect {
                                            self.parseReportZycxHeadphoneSpaceSoundEffect(val: cmd_result, success: block)
                                        }
                                        break
                                    case 6:
                                        if let block = self.receiveReportZycxHeadphoneInEarPerception {
                                            self.parseReportZycxHeadphoneInEarPerception(val: cmd_result, success: block)
                                        }
                                        break
                                        
                                    case 7:
                                        if let block = self.receiveReportZycxHeadphoneExtremeSpeedMode {
                                            self.parseReportZycxHeadphoneExtremeSpeedMode(val: cmd_result, success: block)
                                        }
                                        break
                                    case 8:
                                        if let block = self.receiveReportZycxHeadphoneWindNoiseResistantMode {
                                            self.parseReportZycxHeadphoneWindNoiseResistantMode(val: cmd_result, success: block)
                                        }
                                        break
                                    case 9:
                                        if let block = self.receiveReportZycxHeadphoneBassToneEnhancement {
                                            self.parseReportZycxHeadphoneBassToneEnhancement(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xa:
                                        if let block = self.receiveReportZycxHeadphoneLowFrequencyEnhancement {
                                            self.parseReportZycxHeadphoneLowFrequencyEnhancement(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xb:
                                        if let block = self.receiveReportZycxHeadphoneCoupletPattern {
                                            self.parseReportZycxHeadphoneCoupletPattern(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xc:
                                        if let block = self.receiveReportZycxHeadphoneDesktopMode {
                                            self.parseReportZycxHeadphoneDesktopMode(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xd:
                                        if let block = self.receiveReportZycxHeadphoneShakeSong {
                                            self.parseReportZycxHeadphoneShakeSong(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xe:
                                        if let block = self.receiveReportZycxHeadphoneEqMode {
                                            self.parseReportZycxHeadphoneEqMode(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xf:
                                        if let block = self.receiveReportZycxHeadphoneVoiceVolume {
                                            self.parseReportZycxHeadphoneVoiceVolume(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0x10:
                                        if let block = self.receiveReportZycxHeadphoneCustomButton {
                                            self.parseReportZycxHeadphoneCustomButton(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0x11:
                                        if let block = self.receiveReportZycxHeadphoneClassicBluetoothConnect {
                                            self.parseReportZycxHeadphoneClassicBluetoothConnect(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0x12:
                                        if let block = self.receiveReportZycxHeadphoneCurrentTime {
                                            self.parseReportZycxHeadphoneCurrentTime(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0x13:
                                        if let block = self.receiveReportZycxHeadphoneSoundEffectMode {
                                            self.parseReportZycxHeadphoneSoundEffectMode(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0x14:
                                        if let block = self.receiveReportZycxHeadphonePatternMode {
                                            self.parseReportZycxHeadphonePatternMode(val: cmd_result, success: block)
                                        }
                                        break
                                        
                                    default:
                                        break
                                    }
                                    currentIndex = currentIndex + 2 + Int(cmd_length)
                                }
                            }
                            
                        }else{
                            print("命令长度错误")
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "新协议0xac长度校验出错"))
                        }
                    }
                }
            }
            
            if characteristic == self.chargingBoxReceiveCharacteristic {
                printLog("characteristic =",characteristic)
                //if characteristic.value?.count ?? 0 > 20 {
                    let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: characteristic.value ?? Data.init(),isSend: true))
                    printLog("characteristic.value =",dataString)
                    ZywlSDKLog.writeStringToSDKLog(string: dataString)
                //}
                
                // MARK: - ZYCX val[0] = 0xac
                if val[0] == 0xac {
                    
                    let firstBit = Int(val[2])
                    let maxMtuCount = self.maxMtuCount

                    let crc16 = (Int(val[val.count-2]) << 8 | Int(val[val.count-1]))
                    
                    if firstBit >= 128 {

                        let totalCount = (Int(val[4]) << 8 | Int(val[5]))
                        let currentCount = (Int(val[6]) << 8 | Int(val[7]) )

                        let newData = val.withUnsafeBufferPointer({ (bytes) -> Data in
                            let byte = bytes.baseAddress! + 8
                            return Data.init(bytes: byte, count: val.count-10)
                        })
                        
                        let testArray = Array(val[0..<val.count-2])
                        if self.CRC16(val: testArray) == crc16 {
                            if self.newProtocalData == nil {
                                self.newProtocalData = Data()
                                self.totalLength = (Int(val[3]) | (firstBit-128) << 8 )
                                print("self.totalLength = \(self.totalLength)")
                            }
                            self.newProtocalData?.append(newData)
                        }else{
                            print("testArray = \(testArray),count = \(testArray.count),crc16 = \(self.CRC16(val: testArray)),\(String.init(format: "%04x", self.CRC16(val: testArray)))")
                            let errorString = String.init(format: "第%d包crc16校验出错,app计算的:%02x,设备返回的:%02x", currentCount,self.CRC16(val: testArray),crc16)
                            print("errorString = \(errorString)")
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: errorString))
                        }

                        if totalCount == currentCount + 1 {
                            
                            guard self.newProtocalData != nil else {
                                print("self.newProtocalData 数据错误")
                                return
                            }
                            print("self.newProtocalData!.count = \(self.newProtocalData!.count)")
                            print("self.totalLength = \(self.totalLength)")
                            if /*self.newProtocalData!.count == self.totalLength*/true {

                                let newVal = self.newProtocalData!.withUnsafeBytes({ (bytes) -> [UInt8] in
                                    let b = (bytes.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                                    return [UInt8](UnsafeBufferPointer.init(start: b, count: (self.newProtocalData?.count ?? 0)))
                                })
                                
                                if val[1] == 0x80 { //主动获取分包信息
                                    
                                    if let block = self.receiveGetZycxSubcontractingInfomation {
                                        self.parseGetZycxSubcontractingInfomation(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x81 { //设备上报分包信息
                                    
                                    if let block = self.receiveReportZycxSubcontractingInfomation {
                                        self.parseReportZycxSubcontractingInfomation(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                
                                if val[1] == 0x82 { //功能列表返回
                                    
                                    if let block = self.receiveGetZycxFunctionList {
                                        self.parseGetZycxFunctionList(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x83 { //设备信息
                                    
                                    if let block = self.receiveGetZycxDeviceInfomation {
                                        self.parseGetZycxDeviceInfomation(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x84 { //设备参数获取
                                    
                                    if let block = self.receiveGetZycxDeviceParameters {
                                        self.parseGetZycxDeviceParameters(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x85 { //设备参数设置
                                    let cmd_id = val[4]
                                    let result = val[5]
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveSetZycxTimezone {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveSetZycxTime {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveSetZycxTimeFormat {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveSetZycxWeatherUnit {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 4:
                                        if let block = self.receiveSetZycxScreenLightLevel {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveSetZycxScreenLightTimeLong {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 6:
                                        if let block = self.receiveSetZycxDialIndex {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 7:
                                        if let block = self.receiveSetZycxLanguageIndex {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 8:
                                        if let block = self.receiveSetZycxMessagePush {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 9:
                                        if let block = self.receiveSetZycxAlarmArray {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 10:
                                        if let block = self.receiveSetZycxCustomDialInfomation {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 11:
                                        if let block = self.receiveSetZycxWeather {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 12:
                                        if let block = self.receiveSetZycxSosContact {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 13:
                                        if let block = self.receiveSetZycxAddressContact {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 14:
                                        if let block = self.receiveSetZycxDeviceUuidString {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 15:
                                        if let block = self.receiveSetZycxDeviceVibration {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 16:
                                        if let block = self.receiveSetZycxSedentary {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 17:
                                        if let block = self.receiveSetZycxDrinkWater {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 18:
                                        if let block = self.receiveSetZycxDisturb {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 19:
                                        if let block = self.receiveSetZycxLostRemind {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 20:
                                        if let block = self.receiveSetZycxPhysiologicalCycle {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 21:
                                        if let block = self.receiveSetZycxBleName {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                        
                                    default:
                                        break
                                    }
                                    if let block = self.receiveSetZycxDeviceParameters {
                                        self.parseSetZycxDeviceParameters(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x86 { //设备控制
                                    let cmd_id = val[4]
                                    let result = val[5]
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveSetZycxPowerOff {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        if let block = self.receiveSetZycxRestart {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        if let block = self.receiveSetZycxResetFactory {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        if let block = self.receiveSetZycxResetFactoryAndPowerOff {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        if let block = self.receiveSetZycxShipMode {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveSetZycxVibrationMotor {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveSetZycxFindChargingBox {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveSetZycxClearBtInfomation {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 4:
                                        if let block = self.receiveSetZycxBtRadioEnable {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveSetZycxBindState {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 6:
                                        if let block = self.receiveSetZycxClearData {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                        
                                    default:
                                        break
                                    }
                                }
                            }else{

                                print("命令长度错误")
                                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "新协议0xac长度校验出错"))
                            }
                            self.newProtocalData = nil
                            self.totalLength = 0
                        }

                    }else{

                        let totalLength = (Int(val[2]) << 8 | Int(val[3]) )
                        if totalLength == val.count - 6 {
                            
                            if val[1] == 0x80 { //主动获取分包信息
                                
                                if let block = self.receiveGetZycxSubcontractingInfomation {
                                    self.parseGetZycxSubcontractingInfomation(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x81 { //设备上报分包信息
                                
                                if let block = self.receiveReportZycxSubcontractingInfomation {
                                    self.parseGetZycxSubcontractingInfomation(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x82 { //功能列表返回
                                if let block = self.receiveGetZycxFunctionList {
                                    self.parseGetZycxFunctionList(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                            }
                            
                            if val[1] == 0x83 { //设备信息
                                
                                if let block = self.receiveGetZycxDeviceInfomation {
                                    self.parseGetZycxDeviceInfomation(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x84 { //设备参数
                                
                                if let block = self.receiveGetZycxDeviceParameters {
                                    self.parseGetZycxDeviceParameters(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x85 { //设备参数设置
                                let cmd_id = val[5]
                                let result = val[6]
                                
                                switch cmd_id {
                                case 0:
                                    if let block = self.receiveSetZycxTimezone {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 1:
                                    if let block = self.receiveSetZycxTime {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 2:
                                    if let block = self.receiveSetZycxTimeFormat {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 3:
                                    if let block = self.receiveSetZycxWeatherUnit {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 4:
                                    if let block = self.receiveSetZycxScreenLightLevel {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 5:
                                    if let block = self.receiveSetZycxScreenLightTimeLong {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 6:
                                    if let block = self.receiveSetZycxDialIndex {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 7:
                                    if let block = self.receiveSetZycxLanguageIndex {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 8:
                                    if let block = self.receiveSetZycxMessagePush {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 9:
                                    if let block = self.receiveSetZycxAlarmArray {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 10:
                                    if let block = self.receiveSetZycxCustomDialInfomation {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 11:
                                    if let block = self.receiveSetZycxWeather {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 12:
                                    if let block = self.receiveSetZycxSosContact {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 13:
                                    if let block = self.receiveSetZycxAddressContact {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 14:
                                    if let block = self.receiveSetZycxDeviceUuidString {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 15:
                                    if let block = self.receiveSetZycxDeviceVibration {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 16:
                                    if let block = self.receiveSetZycxSedentary {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 17:
                                    if let block = self.receiveSetZycxDrinkWater {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 18:
                                    if let block = self.receiveSetZycxDisturb {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 19:
                                    if let block = self.receiveSetZycxLostRemind {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 20:
                                    if let block = self.receiveSetZycxPhysiologicalCycle {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 21:
                                    if let block = self.receiveSetZycxBleName {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                default:
                                    break
                                }
                                if let block = self.receiveSetZycxDeviceParameters {
                                    self.parseSetZycxDeviceParameters(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x86 { //设备控制
                                let cmd_id = val[5]
                                let result = val[6]
                                
                                switch cmd_id {
                                case 0:
                                    if let block = self.receiveSetZycxPowerOff {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    if let block = self.receiveSetZycxRestart {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    if let block = self.receiveSetZycxResetFactory {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    if let block = self.receiveSetZycxResetFactoryAndPowerOff {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    if let block = self.receiveSetZycxShipMode {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 1:
                                    if let block = self.receiveSetZycxVibrationMotor {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 2:
                                    if let block = self.receiveSetZycxFindChargingBox {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 3:
                                    if let block = self.receiveSetZycxClearBtInfomation {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 4:
                                    if let block = self.receiveSetZycxBtRadioEnable {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 5:
                                    if let block = self.receiveSetZycxBindState {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 6:
                                    if let block = self.receiveSetZycxClearData {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                default:
                                    break
                                }
                            }
                            
                            if val[1] == 0x87 { //状态查询
                                let stateVal = Array(val[4..<(val.count-2)])
                                var currentIndex = 0
                                while currentIndex < stateVal.count {
                                    let cmd_id = stateVal[currentIndex]
                                    let cmd_length = stateVal[currentIndex+1]
                                    var cmd_result:[UInt8] = []
                                    if currentIndex+1+Int(cmd_length) < stateVal.count{
                                        cmd_result = Array(stateVal[(currentIndex+2)..<(currentIndex+2+Int(cmd_length))])
                                    }
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveGetZycxBattery {
                                            self.parseGetZycxBattery(val: cmd_result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveGetZycxHeadphoneConnectState {
                                            self.parseGetZycxHeadphoneConnectState(val: cmd_result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveGetZycxBoxCoverState {
                                            self.parseGetZycxBoxCoverState(val: cmd_result, success: block)
                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveGetZycxBoxBtConnectStatus {
                                            self.parseGetZycxBoxBtConnectStatus(val: cmd_result, success: block)
                                        }
                                        break
                                        
                                    default:
                                        break
                                    }
                                    currentIndex = currentIndex + 2 + Int(cmd_length)
                                }
                            }
                            
                            if val[1] == 0x88 { //状态上报
                                let stateVal = Array(val[4..<(val.count-2)])
                                var currentIndex = 0
                                while currentIndex < stateVal.count {
                                    let cmd_id = stateVal[currentIndex]
                                    let cmd_length = stateVal[currentIndex+1]
                                    var cmd_result:[UInt8] = []
                                    if currentIndex+1+Int(cmd_length) < stateVal.count{
                                        cmd_result = Array(stateVal[(currentIndex+2)..<(currentIndex+2+Int(cmd_length))])
                                    }
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveReportZycxBattery {
                                            self.parseReportZycxBattery(val: cmd_result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveReportZycxWeatherUnit {
                                            self.parseReportZycxWeatherUnit(val: cmd_result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveReportZycxScreenLightLevel {
                                            self.parseReportZycxScreenLightLevel(val: cmd_result, success: block)
                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveReportZycxScreenLightTimeLong {
                                            self.parseReportZycxScreenLightTimeLong(val: cmd_result, success: block)
                                        }
                                        break
                                    case 4:
                                        if let block = self.receiveReportZycxLocalDialIndex {
                                            self.parseReportZycxLocalDialIndex(val: cmd_result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveReportZycxLanguageIndex {
                                            self.parseReportZycxLanguageIndex(val: cmd_result, success: block)
                                        }
                                        break
                                    case 6:
                                        if let block = self.receiveReportZycxShakeSong {
                                            self.parseReportZycxShakeSong(val: cmd_result, success: block)
                                        }
                                        break
                                    case 7:
                                        if let block = self.receiveReportZycxHeadphoneConnectState {
                                            self.parseReportZycxHeadphoneConnectState(val: cmd_result, success: block)
                                        }
                                        break
                                    case 8:
                                        if let block = self.receiveReportZycxBoxCoverState {
                                            self.parseReportZycxBoxCoverState(val: cmd_result, success: block)
                                        }
                                        break
                                    case 9:
                                        if let block = self.receiveReportZycxEnterOrExitCameraMode {
                                            self.parseReportZycxEnterOrExitCameraMode(val: cmd_result, success: block)
                                        }
                                        break
                                        
                                    default:
                                        break
                                    }
                                    currentIndex = currentIndex + 2 + Int(cmd_length)
                                }
                            }
                            
                            if val[1] == 0x89 { //设备控制上报
                                let stateVal = Array(val[4..<(val.count-2)])
                                var currentIndex = 0
                                while currentIndex < stateVal.count {
                                    let cmd_id = stateVal[currentIndex]
                                    let cmd_length = stateVal[currentIndex+1]
                                    var cmd_result:[UInt8] = []
                                    if currentIndex+1+Int(cmd_length) < stateVal.count{
                                        cmd_result = Array(stateVal[(currentIndex+2)..<(currentIndex+2+Int(cmd_length))])
                                    }
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveReportZycxCallControl {
                                            self.parseReportZycxCallControl(val: cmd_result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveReportZycxMusicControl {
                                            self.parseReportZycxMusicControl(val: cmd_result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveReportZycxFindChargingBox {
                                            self.parseReportZycxFindChargingBox(val: cmd_result, success: block)
                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveReportZycxTakePhoto {
                                            self.parseReportZycxTakePhoto(val: cmd_result, success: block)
                                        }
                                        break
                                                                                
                                    default:
                                        break
                                    }
                                    currentIndex = currentIndex + 2 + Int(cmd_length)
                                }
                            }
                                 
                            if val[1] == 0x8A { //设备控制上报
                                let stateVal = Array(val[4..<(val.count-2)])
                                var currentIndex = 1
                                while currentIndex < stateVal.count {
                                    let cmd_id = stateVal[currentIndex]
                                    let cmd_length = stateVal[currentIndex+1]
                                    var cmd_result:[UInt8] = []
                                    if currentIndex+1+Int(cmd_length) < stateVal.count{
                                        cmd_result = Array(stateVal[(currentIndex+2)..<(currentIndex+2+Int(cmd_length))])
                                    }
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveReportZycxMusicState {
                                            self.parseReportZycxMusicState(val: cmd_result, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    currentIndex = currentIndex + 2 + Int(cmd_length)
                                }
                            }
                            
                            if val[1] == 0xff { //升级
                                let stateVal = Array(val[4..<(val.count-2)])
                                let cmd_id = stateVal[0]
                                let cmd_result = Array(stateVal[1..<(stateVal.count)])
                                
                                switch cmd_id {
                                case 0x80:
                                    if let block = self.receiveSetZycxStartUpgradeBlock ,let progress = self.receiveSetZycxStartUpgradeProgressBlock {
                                        self.parseSetStartUpgradeData(val: cmd_result, progress: progress, success: block)
                                    }
                                    break
                                case 0x81:
                                    if let block = self.receiveSetZycxStopUpgradeBlock {
                                        self.parseSetStopUpgradeData(val: cmd_result, success: block)
                                    }
                                    break
                                case 0x83:
                                    
                                    let otaVal = self.otaData?.withUnsafeBytes{ (byte) -> [UInt8] in
                                        let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                                        return [UInt8](UnsafeBufferPointer.init(start: b, count: self.otaData?.count ?? 0))
                                    } ?? []
                                    
                                    if cmd_result[0] == 0x00 {  //校验成功  发送下一组
                                        self.otaStartIndex += 1
                                        self.dealUpgradeData(maxSingleCount: self.otaMaxSingleCount, packageCount:  self.otaPackageCount, packageIndex: self.otaStartIndex, val: otaVal, progress: self.receiveSetZycxStartUpgradeProgressBlock!, success: self.receiveSetZycxStartUpgradeBlock!)
                                        
                                        self.otaCheckFailResendData = nil
                                        self.failCheckCount = 0
                                    }else if cmd_result[0] == 0x01 {
                                        //所有数据接收完成
                                        self.otaCheckFailResendData = nil
                                        self.failCheckCount = 0
                                        self.otaStartIndex = 0
                                        self.otaData = nil
                                        printLog("self.otaData = nil")
                                    }else if val[5] == 5 {
                                        //存在重传数据
                                        if self.otaCheckFailResendData == data {//重传数据已发送过一次直接失败
                                            
                                            if let block = self.receiveSetZycxStartUpgradeBlock {
                                                block(.fail)
                                                self.otaCheckFailResendData = nil
                                                self.otaData = nil
                                                printLog("self.otaData = nil")
                                                self.failCheckCount = 0
                                            }
                                            
                                        }else{
                                            
                                            self.resendUpgradeData(maxSingleCount: self.otaMaxSingleCount, packageCount: self.otaPackageCount, resendVal: cmd_result, val: otaVal, progress: self.receiveSetZycxStartUpgradeProgressBlock!, success: self.receiveSetZycxStartUpgradeBlock!)
                                            if self.failCheckCount >= 2 {
                                                self.otaCheckFailResendData = data
                                                self.failCheckCount = 0
                                            }
                                            self.failCheckCount += 1
                                            
                                        }
                                        
                                    }else {
                                        self.otaStartIndex = 0
                                        if let block = self.receiveSetZycxStartUpgradeBlock {
                                            block(.fail)
                                            self.otaCheckFailResendData = nil
                                            self.failCheckCount = 0
                                            self.otaData = nil
                                            printLog("self.otaData = nil")
                                        }
                                    }
                                    break
                                case 0x84:
                                    if let block = self.receiveSetZycxStartUpgradeBlock {
                                        self.parseGetUpgradeResultData(val: cmd_result, success: block)
                                    }
                                    break
                                case 0x85:
                                    if cmd_result[0] == 0x00 {
                                        if let block = self.receiveSetZycxStartUpgradeBlock {
                                            self.parseGetUpgradeResultData(val: cmd_result, success: block)
                                        }
                                    }else if cmd_result[0] == 0x01 {
                                        
                                        let fileType = cmd_result[1]
                                        
                                        self.otaMaxSingleCount = (Int(val[6]) << 8 | Int(val[7]))
                                        self.otaPackageCount = (Int(val[8]) << 8 | Int(val[9]))
                                        //给的包号是otaMaxSingleCount为1包，转换为otaStartIndex需要 包号/每组包数
                                        let packageIndex = (Int(val[12]) << 24 | Int(val[13]) << 16 | Int(val[14]) << 8 | Int(val[15]))
                                        self.otaStartIndex = packageIndex / self.otaPackageCount
                                        self.otaContinueDataLength = (Int(cmd_result[2]) << 24 | Int(cmd_result[3]) << 16 | Int(cmd_result[4]) << 8 | Int(cmd_result[5]))
                                        
                                        printLog("继续升级信息 文件类型:",fileType,"单包最大字节数:",self.otaMaxSingleCount,"每组包数:",self.otaPackageCount,"包号:",packageIndex,"文件长度:",self.otaContinueDataLength)
                                        
                                        if self.otaData != nil {
                                            
                                            let otaVal = self.otaData!.withUnsafeBytes{ (byte) -> [UInt8] in
                                                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                                                return [UInt8](UnsafeBufferPointer.init(start: b, count: self.otaData!.count))
                                            }
                                            if self.otaContinueDataLength != self.otaData!.count {
                                                printLog("otaContinueDataLength =",self.otaContinueDataLength,"otaData.count =",self.otaData!.count,"数据不一致")
                                            }else{
                                                self.dealUpgradeData(maxSingleCount: self.otaMaxSingleCount, packageCount:  self.otaPackageCount, packageIndex: self.otaStartIndex, val: otaVal, progress: self.receiveSetZycxStartUpgradeProgressBlock!, success: self.receiveSetZycxStartUpgradeBlock!)
                                            }
                                            
                                        }else{
                                            
                                            if let block = self.receiveCheckUpgradeStateBlock {
                                                block(["type":"\(val[6])"],.none)
                                            }
                                            
                                        }
                                    }
                                    break
                                default:
                                    break
                                }
                            }
                            
                        }else{
                            print("命令长度错误")
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "新协议0xac长度校验出错"))
                        }
                    }
                }
                // MARK: - ZYCX 0xAB，仓对耳机；0xC0，手机对耳机；
                if val[0] == 0xab || val[0] == 0xc0 {
                    
                    let firstBit = Int(val[2])
                    let maxMtuCount = self.maxMtuCount

                    let crc16 = (Int(val[val.count-2]) << 8 | Int(val[val.count-1]))
                    
                    if firstBit > 0 {

                        let totalCount = (Int(val[4]) << 8 | Int(val[5]))
                        let currentCount = (Int(val[6]) << 8 | Int(val[7]) )

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
                            let errorString = String.init(format: "第%d包crc16校验出错,app计算的:%02x,设备返回的:%02x", currentCount,self.CRC16(val: testArray),crc16)
                            print("errorString = \(errorString)")
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: errorString))
                        }

                        if totalCount == currentCount + 0 {
                            let totalLength = (Int(val[2]) << 8 | (firstBit-128))
                            guard self.newProtocalData != nil else {
                                print("self.newProtocalData 数据错误")
                                return
                            }
                            if self.newProtocalData!.count == totalLength {

                                let newVal = self.newProtocalData!.withUnsafeBytes({ (bytes) -> [UInt8] in
                                    let b = (bytes.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                                    return [UInt8](UnsafeBufferPointer.init(start: b, count: (self.newProtocalData?.count ?? 0)))
                                })
                                
                                if val[1] == 0x80 { //主动获取分包信息
                                    
                                    if let block = self.receiveGetZycxHeadphoneSubcontractingInfomation {
                                        self.parseGetZycxHeadphoneSubcontractingInfomation(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x81 { //设备上报分包信息
                                    
                                    if let block = self.receiveReportZycxHeadphoneSubcontractingInfomation {
                                        self.parseReportZycxHeadphoneSubcontractingInfomation(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                
                                if val[1] == 0x82 { //功能列表返回
                                    
                                    if let block = self.receiveGetZycxHeadphoneFunctionList {
                                        self.parseGetZycxHeadphoneFunctionList(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x83 { //设备信息
                                    
                                    if let block = self.receiveGetZycxHeadphoneDeviceInfomation {
                                        self.parseGetZycxHeadphoneDeviceInfomation(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x84 { //设备参数获取
                                    
                                    if let block = self.receiveGetZycxHeadphoneDeviceParameters {
                                        self.parseGetZycxHeadphoneDeviceParameters(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x85 { //设备参数设置
                                    let cmd_id = val[4]
                                    let result = val[5]
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveSetZycxHeadphoneCustomButtonList {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveSetZycxHeadphoneEqMode {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 2:
//                                        if let block = self.receiveSetZycxTimeFormat {
//                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
//                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveSetZycxHeadphoneAmbientSoundEffect {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 4:
                                        if let block = self.receiveSetZycxHeadphoneSpaceSoundEffect {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveSetZycxHeadphoneInEarPerception {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 6:
                                        if let block = self.receiveSetZycxHeadphoneExtremeSpeedMode {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 7:
                                        if let block = self.receiveSetZycxHeadphoneWindNoiseResistantMode {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 8:
                                        if let block = self.receiveSetZycxHeadphoneBassToneEnhancement {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 9:
                                        if let block = self.receiveSetZycxHeadphoneLowFrequencyEnhancement {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 10:
                                        if let block = self.receiveSetZycxHeadphoneCoupletPattern {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 11:
                                        if let block = self.receiveSetZycxHeadphoneDesktopMode {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 12:
                                        if let block = self.receiveSetZycxHeadphoneShakeSong {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 13:
                                        if let block = self.receiveSetZycxHeadphoneVoiceVolume {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 14:
                                        if let block = self.receiveSetZycxHeadphoneBattery {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 15:
                                        if let block = self.receiveSetZycxHeadphoneSoundEffectMode {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 16:
                                        if let block = self.receiveSetZycxHeadphonePatternMode {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    if let block = self.receiveSetZycxDeviceParameters {
                                        self.parseSetZycxDeviceParameters(val: newVal, success: block)
                                    }
                                    
                                }
                                
                                if val[1] == 0x86 { //设备控制
                                    let cmd_id = val[4]
                                    let result = val[5]
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveSetZycxHeadphonePowerOff {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        if let block = self.receiveSetZycxHeadphoneRestart {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        if let block = self.receiveSetZycxHeadphoneResetFactory {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        if let block = self.receiveSetZycxHeadphoneResetFactoryAndPowerOff {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveSetZycxHeadphoneTiktokControl {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveSetZycxHeadphoneMusicControl {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveSetZycxHeadphoneCallControl_AndswerHandUp {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                            self.receiveSetZycxHeadphoneCallControl_AndswerHandUp = nil
                                        }
                                        if let block = self.receiveSetZycxHeadphoneCallControl_DtmfDialing {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                            self.receiveSetZycxHeadphoneCallControl_DtmfDialing = nil
                                        }
                                        if let block = self.receiveSetZycxHeadphoneCallControl_VolumeVoice {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                            self.receiveSetZycxHeadphoneCallControl_VolumeVoice = nil
                                        }
                                        
                                        break
                                    case 4:
                                        if let block = self.receiveSetZycxHeadphoneFind {
                                            self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveSetZycxHeadphoneTakePhoto {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    case 6:
                                        if let block = self.receiveSetZycxHeadphoneCustomButtonResetDefault {
                                            self.parseHeadphoneUniversalResponse(result: result, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                }
                            }else{

                                print("命令长度错误")
                                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "新协议0xac长度校验出错"))
                            }
                            self.newProtocalData = nil
                            self.totalLength = 0
                        }

                    }else{

                        let totalLength = (Int(val[2]) << 8 | Int(val[3]) )
                        if totalLength == val.count - 6 {
                            
                            if val[1] == 0x80 { //主动获取分包信息
                                
                                if let block = self.receiveGetZycxHeadphoneSubcontractingInfomation {
                                    self.parseGetZycxHeadphoneSubcontractingInfomation(val: Array(val[4..<(val.count-2)]), success: block)
                                }
//                                
                            }
                            
                            if val[1] == 0x81 { //设备上报分包信息
                                
                                if let block = self.receiveReportZycxHeadphoneSubcontractingInfomation {
                                    self.parseGetZycxHeadphoneSubcontractingInfomation(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x82 { //功能列表返回
                                if let block = self.receiveGetZycxHeadphoneFunctionList {
                                    self.parseGetZycxHeadphoneFunctionList(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                            }
                            
                            if val[1] == 0x83 { //设备信息
                                
                                if let block = self.receiveGetZycxHeadphoneDeviceInfomation {
                                    self.parseGetZycxHeadphoneDeviceInfomation(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x84 { //设备参数
                                
                                if let block = self.receiveGetZycxHeadphoneDeviceParameters {
                                    self.parseGetZycxHeadphoneDeviceParameters(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x85 { //设备参数设置
                                let cmd_id = val[5]
                                let result = val[6]
                                
                                switch cmd_id {
                                case 0:
                                    if let block = self.receiveSetZycxHeadphoneCustomButtonList {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 1:
                                    if let block = self.receiveSetZycxHeadphoneEqMode {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 2:
//                                    if let block = self.receiveSetZycxTimeFormat {
//                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
//                                    }
                                    break
                                case 3:
                                    if let block = self.receiveSetZycxHeadphoneAmbientSoundEffect {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 4:
                                    if let block = self.receiveSetZycxHeadphoneSpaceSoundEffect {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 5:
                                    if let block = self.receiveSetZycxHeadphoneInEarPerception {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 6:
                                    if let block = self.receiveSetZycxHeadphoneExtremeSpeedMode {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 7:
                                    if let block = self.receiveSetZycxHeadphoneWindNoiseResistantMode {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 8:
                                    if let block = self.receiveSetZycxHeadphoneBassToneEnhancement {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 9:
                                    if let block = self.receiveSetZycxHeadphoneLowFrequencyEnhancement {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 10:
                                    if let block = self.receiveSetZycxHeadphoneCoupletPattern {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 11:
                                    if let block = self.receiveSetZycxHeadphoneDesktopMode {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 12:
                                    if let block = self.receiveSetZycxHeadphoneShakeSong {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 13:
                                    if let block = self.receiveSetZycxHeadphoneVoiceVolume {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 14:
                                    if let block = self.receiveSetZycxHeadphoneBattery {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 15:
                                    if let block = self.receiveSetZycxHeadphoneSoundEffectMode {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 16:
                                    if let block = self.receiveSetZycxHeadphonePatternMode {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                default:
                                    break
                                }
                                if let block = self.receiveSetZycxDeviceParameters {
                                    self.parseSetZycxDeviceParameters(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                                
                            }
                            
                            if val[1] == 0x86 { //设备控制
                                let cmd_id = val[4]
                                let result = val[5]
                                
                                switch cmd_id {
                                case 0:
                                    if let block = self.receiveSetZycxHeadphonePowerOff {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    if let block = self.receiveSetZycxHeadphoneRestart {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    if let block = self.receiveSetZycxHeadphoneResetFactory {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    if let block = self.receiveSetZycxHeadphoneResetFactoryAndPowerOff {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    
                                    break
                                case 1:
                                    if let block = self.receiveSetZycxHeadphoneTiktokControl {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 2:
                                    if let block = self.receiveSetZycxHeadphoneMusicControl {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 3:
                                    if let block = self.receiveSetZycxHeadphoneCallControl_AndswerHandUp {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        self.receiveSetZycxHeadphoneCallControl_AndswerHandUp = nil
                                    }
                                    if let block = self.receiveSetZycxHeadphoneCallControl_DtmfDialing {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        self.receiveSetZycxHeadphoneCallControl_DtmfDialing = nil
                                    }
                                    if let block = self.receiveSetZycxHeadphoneCallControl_VolumeVoice {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                        self.receiveSetZycxHeadphoneCallControl_DtmfDialing = nil
                                    }
                                    break
                                case 4:
                                    if let block = self.receiveSetZycxHeadphoneFind {
                                        self.parseChargingBoxUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 5:
                                    if let block = self.receiveSetZycxHeadphoneTakePhoto {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                case 6:
                                    if let block = self.receiveSetZycxHeadphoneCustomButtonResetDefault {
                                        self.parseHeadphoneUniversalResponse(result: result, success: block)
                                    }
                                    break
                                default:
                                    break
                                }
                            }
                            
                            if val[1] == 0x87 { //状态查询
                                let stateVal = Array(val[4..<(val.count-2)])
                                var currentIndex = 0
                                while currentIndex < stateVal.count {
                                    let cmd_id = stateVal[currentIndex]
                                    let cmd_length = stateVal[currentIndex+1]
                                    var cmd_result:[UInt8] = []
                                    if currentIndex+1+Int(cmd_length) < stateVal.count{
                                        cmd_result = Array(stateVal[(currentIndex+2)..<(currentIndex+2+Int(cmd_length))])
                                    }
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveGetZycxHeadphoneStateBattery {
                                            self.parseGetZycxHeadphoneStateBattery(val: cmd_result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveGetZycxHeadphoneMusicState {
                                            self.parseGetZycxHeadphoneMusicState(val: cmd_result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveGetZycxHeadphoneCurrentTime {
                                            self.parseGetZycxHeadphoneCurrentTime(val: cmd_result, success: block)
                                        }
                                        break
                                    case 4:
                                        if let block = self.receiveGetZycxHeadphoneBtConncetState {
                                            self.parseGetZycxHeadphoneBtConncetState(val: cmd_result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveGetZycxHeadphoneTwsIsPair {
                                            self.parseGetZycxHeadphoneTwsIsPair(val: cmd_result, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    currentIndex = currentIndex + 2 + Int(cmd_length)
                                }
                            }
                            
                            if val[1] == 0x88 { //状态上报
                                let stateVal = Array(val[4..<(val.count-2)])
                                var currentIndex = 1
                                while currentIndex < stateVal.count {
                                    if currentIndex >= stateVal.count {
                                        currentIndex = stateVal.count
                                        break
                                    }
                                    let cmd_id = stateVal[currentIndex]
                                    if currentIndex+1 >= stateVal.count {
                                        currentIndex = stateVal.count
                                        break
                                    }
                                    let cmd_length = stateVal[currentIndex+1]
                                    var cmd_result:[UInt8] = []
                                    if currentIndex+1+Int(cmd_length) < stateVal.count{
                                        cmd_result = Array(stateVal[(currentIndex+2)..<(currentIndex+2+Int(cmd_length))])
                                    }
                                    
                                    switch cmd_id {
                                    case 0:
                                        if let block = self.receiveReportZycxHeadphoneBattery {
                                            self.parseReportZycxHeadphoneBattery(val: cmd_result, success: block)
                                        }
                                        break
                                    case 1:
                                        if let block = self.receiveReportZycxHeadphoneFind {
                                            self.parseReportZycxHeadphoneFind(val: cmd_result, success: block)
                                        }
                                        break
                                    case 2:
                                        if let block = self.receiveReportZycxHeadphoneCallControl {
                                            self.parseReportZycxHeadphoneCallControl(val: cmd_result, success: block)
                                        }
                                        break
                                    case 3:
                                        if let block = self.receiveReportZycxHeadphoneMusicState {
                                            self.parseReportZycxHeadphoneMusicState(val: cmd_result, success: block)
                                        }
                                        break
                                    case 4:
                                        if let block = self.receiveReportZycxHeadphoneAmbientSoundEffect {
                                            self.parseReportZycxHeadphoneAmbientSoundEffect(val: cmd_result, success: block)
                                        }
                                        break
                                    case 5:
                                        if let block = self.receiveReportZycxHeadphoneSpaceSoundEffect {
                                            self.parseReportZycxHeadphoneSpaceSoundEffect(val: cmd_result, success: block)
                                        }
                                        break
                                    case 6:
                                        if let block = self.receiveReportZycxHeadphoneInEarPerception {
                                            self.parseReportZycxHeadphoneInEarPerception(val: cmd_result, success: block)
                                        }
                                        break
                                        
                                    case 7:
                                        if let block = self.receiveReportZycxHeadphoneExtremeSpeedMode {
                                            self.parseReportZycxHeadphoneExtremeSpeedMode(val: cmd_result, success: block)
                                        }
                                        break
                                    case 8:
                                        if let block = self.receiveReportZycxHeadphoneWindNoiseResistantMode {
                                            self.parseReportZycxHeadphoneWindNoiseResistantMode(val: cmd_result, success: block)
                                        }
                                        break
                                    case 9:
                                        if let block = self.receiveReportZycxHeadphoneBassToneEnhancement {
                                            self.parseReportZycxHeadphoneBassToneEnhancement(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xa:
                                        if let block = self.receiveReportZycxHeadphoneLowFrequencyEnhancement {
                                            self.parseReportZycxHeadphoneLowFrequencyEnhancement(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xb:
                                        if let block = self.receiveReportZycxHeadphoneCoupletPattern {
                                            self.parseReportZycxHeadphoneCoupletPattern(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xc:
                                        if let block = self.receiveReportZycxHeadphoneDesktopMode {
                                            self.parseReportZycxHeadphoneDesktopMode(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xd:
                                        if let block = self.receiveReportZycxHeadphoneShakeSong {
                                            self.parseReportZycxHeadphoneShakeSong(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xe:
                                        if let block = self.receiveReportZycxHeadphoneEqMode {
                                            self.parseReportZycxHeadphoneEqMode(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0xf:
                                        if let block = self.receiveReportZycxHeadphoneVoiceVolume {
                                            self.parseReportZycxHeadphoneVoiceVolume(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0x10:
                                        if let block = self.receiveReportZycxHeadphoneCustomButton {
                                            self.parseReportZycxHeadphoneCustomButton(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0x11:
                                        if let block = self.receiveReportZycxHeadphoneClassicBluetoothConnect {
                                            self.parseReportZycxHeadphoneClassicBluetoothConnect(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0x12:
                                        if let block = self.receiveReportZycxHeadphoneCurrentTime {
                                            self.parseReportZycxHeadphoneCurrentTime(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0x13:
                                        if let block = self.receiveReportZycxHeadphoneSoundEffectMode {
                                            self.parseReportZycxHeadphoneSoundEffectMode(val: cmd_result, success: block)
                                        }
                                        break
                                    case 0x14:
                                        if let block = self.receiveReportZycxHeadphonePatternMode {
                                            self.parseReportZycxHeadphonePatternMode(val: cmd_result, success: block)
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    currentIndex = currentIndex + 2 + Int(cmd_length)
                                }
                            }
                            
                        }else{
                            print("命令长度错误")
                            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "新协议0xac长度校验出错"))
                        }
                    }
                }
            }
        }
    }
    
    func checkLength(val:[UInt8]) -> Bool {
        var result = false
        //printLog("长度校验 = ",(Int(val[2]) | Int(val[3]) << 8 ))
        if (Int(val[2]) << 8 | Int(val[3]) ) == val.count {
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
        if self.headphoneWriteCharacteristic != nil {
            
            let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
            ZywlSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
            printLog("send",dataString)
            self.headphonePeripheral?.writeValue(data, for: self.headphoneWriteCharacteristic!, type: ((self.headphoneWriteCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
        }else{
            
            ZywlSDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
            printLog("写特征为空")
            
        }
    }

    
    func writeChargingBoxData(data:Data) {
        //此方法目前是升级在用 不做信号量等待
        if self.chargingBoxWriteCharacteristic != nil {
            
            let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
            ZywlSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
            printLog("send",dataString)
            self.chargingBoxPeripheral?.writeValue(data, for: self.chargingBoxWriteCharacteristic!, type: ((self.chargingBoxWriteCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
        }else{
            
            ZywlSDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
            printLog("写特征为空")
            
        }
    }
    
    @objc public func checkCurrentCommamdIsNeedWait() -> Bool {
        printLog("self.commandListArray.count =",self.commandListArray.count)
        return self.commandListArray.count <= 0 ? false : true
    }
    
    func writeDataAndBackError(data:Data) -> ZywlError {
        if self.headphonePeripheral?.state != .connected {
            
            return .disconnected
            
        }else{
            
            if self.headphoneWriteCharacteristic != nil && self.headphonePeripheral != nil {

                self.commandListArray.append(data)
                if !self.isCommandSendState {
                    self.isCommandSendState = true
                    self.sendListArrayData()
                }
                
                return .none
            }else{
                
                ZywlSDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
                printLog("写特征为空")
                
                return .invalidCharacteristic
            }
        }
    }
    
    func writeChargingBoxDataAndBackError(data:Data) -> ZywlError {
        if self.chargingBoxPeripheral?.state != .connected {
            
            return .disconnected
            
        }else{
            
            if self.chargingBoxWriteCharacteristic != nil && self.chargingBoxPeripheral != nil {

                self.chargingBoxListArray.append(data)
                if !self.isChargingBoxSendState {
                    self.isChargingBoxSendState = true
                    self.sendChargingBoxListArrayData()
                }
                
                return .none
            }else{
                
                ZywlSDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
                printLog("写特征为空")
                
                return .invalidCharacteristic
            }
        }
    }
    
    func sendListArrayData() {
        
        if self.commandListArray.count > 0 {
            //取出数组第一条data
            if let data = self.commandListArray.first {
                if self.headphonePeripheral?.state == .connected && self.headphoneWriteCharacteristic != nil && self.headphonePeripheral != nil {
                    DispatchQueue.global().async {

                        self.semaphoreCount -= 1
                        let result = self.commandSemaphore.wait(timeout: DispatchTime.now()+5)
                        if result == .timedOut {
                            self.semaphoreCount += 1
                            let lastString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: self.lastSendData ?? .init(),isSend: true))
                            printLog("result = \(result) , self.lastSendData = \(lastString)")
                            ZywlSDKLog.writeStringToSDKLog(string: "发送超时的命令:"+lastString)
                            printLog("timedOut -> self.semaphoreCount =",self.semaphoreCount)
                        }
                        
                        let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
                        ZywlSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
                                            
                        DispatchQueue.main.async {

                            printLog("send",dataString)
                            printLog("发送命令 -> self.semaphoreCount =",self.semaphoreCount)
                            self.headphonePeripheral?.writeValue(data, for: self.headphoneWriteCharacteristic!, type: ((self.headphoneWriteCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
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
    
    func sendChargingBoxListArrayData() {
        
        if self.chargingBoxListArray.count > 0 {
            //取出数组第一条data
            if let data = self.chargingBoxListArray.first {
                if self.headphonePeripheral?.state == .connected && self.headphoneWriteCharacteristic != nil && self.headphonePeripheral != nil {
                    DispatchQueue.global().async {

                        self.semaphoreChargingBoxCount -= 1
                        let result = self.commandSemaphore.wait(timeout: DispatchTime.now()+5)
                        if result == .timedOut {
                            self.semaphoreChargingBoxCount += 1
                            let lastString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: self.lastSendData ?? .init(),isSend: true))
                            printLog("result = \(result) , self.lastSendData = \(lastString)")
                            ZywlSDKLog.writeStringToSDKLog(string: "发送超时的命令:"+lastString)
                            printLog("timedOut -> self.semaphoreChargingBoxCount =",self.semaphoreChargingBoxCount)
                        }
                        
                        let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
                        ZywlSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
                                            
                        DispatchQueue.main.async {

                            printLog("send",dataString)
                            printLog("发送命令 -> self.semaphoreChargingBoxCount =",self.semaphoreChargingBoxCount)
                            self.headphonePeripheral?.writeValue(data, for: self.headphoneWriteCharacteristic!, type: ((self.headphoneWriteCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
                            self.lastSendData = data
                            
                            //定时器计数重置
                            self.commandDetectionCount = 0
                            if self.commandDetectionTimer == nil {
                                //检测命令发送之后是否有回复，在deviceReceivedData方法内有数据则把此定时器销毁。如果没有回复，那么5s之后把信号量回复默认值
                                self.commandDetectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.chargingBoxDetectionTimerMethod), userInfo: nil, repeats: true)
                            }
                            
                            //移除发送的第一条data
                            if self.chargingBoxListArray.count > 0 {
                                self.chargingBoxListArray.remove(at: 0)
                                self.sendChargingBoxListArrayData()
                            }
                        }
                    }
                }
            }
        }else{
            self.isChargingBoxSendState = false
        }
    }
        
    // MARK: - 检测命令定时器方法
    @objc public func commandDetectionTimerMethod() {
        if self.commandDetectionCount >= 50 {
            //用信号量+1，只放一条命令过。如果用重置信号量会导致后续的命令全部怼出去，如果还有丢的命令也无法发现
            self.signalCommandSemaphore()
            //取消定时器
            self.commandDetectionTimerInvalid()
            //此次接收回复命令结束
        }
        self.commandDetectionCount += 1
    }
    
    // MARK: - 充电仓检测命令定时器方法
    @objc public func chargingBoxDetectionTimerMethod() {
        if self.chargingBoxDetectionCount >= 50 {
            //用信号量+1，只放一条命令过。如果用重置信号量会导致后续的命令全部怼出去，如果还有丢的命令也无法发现
            self.signalCommandSemaphore()
            //取消定时器
            self.chargingBoxDetectionTimerInvalid()
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
    
    // MARK: - 充电仓检测命令定时器销毁
    func chargingBoxDetectionTimerInvalid() {
        if self.chargingBoxDetectionTimer != nil {
            self.chargingBoxDetectionTimer?.invalidate()
            self.chargingBoxDetectionTimer = nil
        }
    }
    
    // MARK: - 检测信号量+1
    func signalCommandSemaphore() {
        if self.semaphoreCount < 1 {
            self.signalValue = self.commandSemaphore.signal()
            self.semaphoreCount += 1
        }
        printLog("signalCommandSemaphore -> self.semaphoreCount =",self.semaphoreCount)
    }
    
    // MARK: - 充电仓检测信号量+1
    func signalChargingBoxSemaphore() {
        if self.semaphoreChargingBoxCount < 1 {
            _ = self.chargingBoxSemaphore.signal()
            self.semaphoreChargingBoxCount += 1
        }
        printLog("signalChargingBoxSemaphore -> self.semaphoreChargingBoxCount =",self.semaphoreChargingBoxCount)
    }
    
    // MARK: - 检测命令信号量重置
    func resetCommandSemaphore(showLog:Bool? = false) {
        //目前SDK内部重置会在重连、断开连接、关闭蓝牙三个地方调用
        let resetCount = 1-self.semaphoreCount
        if showLog == true {
            ZywlSDKLog.writeStringToSDKLog(string: "同步异常处理，取消后续命令发送")
        }else{
            ZywlSDKLog.writeStringToSDKLog(string: "重连、断开连接、关闭蓝牙，取消后续命令发送")
        }
        
        printLog("resetCommandSemaphore resetCount->",resetCount)
        for _ in 0..<resetCount {
            self.signalCommandSemaphore()
        }
        
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
    
    // MARK: - 检测命令信号量重置
    func resetChargingBoxSemaphore(showLog:Bool? = false) {
        //目前SDK内部重置会在重连、断开连接、关闭蓝牙三个地方调用
        let resetCount = 1-self.semaphoreChargingBoxCount
        if showLog == true {
            ZywlSDKLog.writeStringToSDKLog(string: "同步异常处理，取消后续命令发送")
        }else{
            ZywlSDKLog.writeStringToSDKLog(string: "重连、断开连接、关闭蓝牙，取消后续命令发送")
        }
        
        printLog("resetCommandSemaphore resetCount->",resetCount)
        for _ in 0..<resetCount {
            self.signalChargingBoxSemaphore()
        }
        
        if self.semaphoreChargingBoxCount < 1 {
            for _ in 0..<1-self.semaphoreChargingBoxCount {
                self.signalChargingBoxSemaphore()
            }
        }
        //重置之后网络请求的isRequesting置为false
        self.isChargingBoxSendState = false
        self.commandListArray.removeAll()
    }
    
    // MARK: - 重置命令等待，待发命令全部移除不发送
    @objc public func resetWaitCommand() {
        self.sendFailState = true
        self.resetCommandSemaphore(showLog: true)
    }
    
    // MARK: - 获取耳机电量
    @objc public func getHeadphoneBattery(_ success:@escaping((_ leftHeadphone:Int,_ rightHeadphone:Int,ZywlError)->Void)) {
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
    
    private func parseGetHeadphoneBattery(val:[UInt8],success:@escaping((_ leftHeadphone:Int,_ rightHeadphone:Int,ZywlError)->Void)) {

        if val.count >= 6 {
            let leftBattery = Int(val[2])
            let rightBattery = Int(val[4])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "leftBattery:%d,rightBattery:%d", leftBattery,rightBattery))
            success(leftBattery,rightBattery,.none)
        }else{
            success(0,0,.invalidLength)
        }
                
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取充电仓电量
    @objc public func getBoxBattery(_ success:@escaping((_ boxBattery:Int,ZywlError)->Void)) {
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
    
    private func parseGetBoxBattery(val:[UInt8],success:@escaping((_ value:Int,ZywlError)->Void)) {

        if val.count >= 6 {
            let batteryValue = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "batteryValue:%d", batteryValue))
            success(batteryValue,.none)
        }else{
            success(0,.invalidLength)
        }
                
        self.signalCommandSemaphore()
    }
    
    // MARK: - 查找设备
    @objc public func setFindHeadphoneDevice(type:Int,isOpen:Bool,success:@escaping((ZywlError)->Void)) {
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
    
    private func parseSetFindHeadphoneDevice(val:[UInt8],success:@escaping((ZywlError)->Void)) {

        if val.count >= 3 {
            let state = Int(val[2])
            if state == 1 {
                success(.none)
            }else{
                success(.fail)
            }
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d", state))
        }else{
            success(.invalidLength)
        }
                
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取mac
    @objc public func getMac(_ success:@escaping((_ leftMac:String?,_ rightMac:String?,ZywlError)->Void)) {
        
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
    
    private func privateGetMac(val:[UInt8],success:@escaping((_ leftMac:String?,_ rightMac:String?,ZywlError)->Void)) {
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
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "leftString:%@,rightString:%@", leftString,rightString))
            success(leftString,rightString,.none)
            
        }else{
            success(nil,nil,.invalidLength)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取固件版本号
    @objc public func getFirmwareVersion(_ success:@escaping((_ leftVersion:String?,_ rightVersion:String?,ZywlError)->Void)) {
        
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
    
    private func parseGetFirmwareVersion(val:[UInt8],success:@escaping((_ leftVersion:String?,_ rightVersion:String?,ZywlError)->Void)) {

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
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "leftVersion:%@,rightVersion:%@", leftVersion,rightVersion))
            success(leftVersion == "0.0.0" ? nil : leftVersion,rightVersion == "0.0.0" ? nil : rightVersion,.none)
            
        }else{
            success(nil,nil,.invalidLength)
        }
        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 获取自定义按键
    @objc public func getCustomButton(handGestureId:Int,success:@escaping((_ handGestureId:Int,_ leftFuncId:Int,_ rightFuncId:Int,ZywlError)->Void)) {
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
    
    private func parseGetCustomButton(val:[UInt8],success:@escaping((_ handGestureId:Int,_ leftFuncId:Int,_ rightFuncId:Int,ZywlError)->Void)) {
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
    @objc public func setCustomButton(handGestureId:Int,leftFuncId:Int,rightFuncId:Int,success:@escaping((ZywlError)->Void)) {
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
    
    private func parseSetCustomButton(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = val[2]
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getLowLatencyMode(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    
    private func parseGetLowLatencyMode(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            success(state,.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 低延迟模式设置
    @objc public func setLowLatencyMode(type:Int,success:@escaping((ZywlError)->Void)) {
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
    
    private func parseSetLowLatencyMode(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getInEarDetection(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    private func parseGetInEarDetection(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            success(state,.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 入耳检测设置
    @objc public func setInEarDetection(type:Int,success:@escaping((ZywlError)->Void)) {
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
    
    private func parseSetInEarDetection(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getEqMode(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    private func parseGetEqMode(val:[UInt8],success:@escaping((Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            success(state,.none)
            
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 设置EQ类型
    @objc public func setEqMode(type:Int,customEqValue:[Float],success:@escaping((ZywlError)->Void)) {
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
    
    private func parseSetEqMode(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getAmbientSound(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    
    private func parseGetAmbientSound(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            success(state,.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 环境音设置
    @objc public func setAmbientSound(type:Int ,success:@escaping((ZywlError)->Void)) {
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
    
    private func parseSetAmbientSound(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getHeadsetWearingStatus(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    
    private func parseGetHeadsetWearingStatus(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func setResetFactory(_ success:@escaping((ZywlError)->Void)) {
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
    
    private func parseSetResetFactory(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getDesktopMode(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    
    private func parseGetDesktopMode(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func setDesktopMode(type:Int ,success:@escaping((ZywlError)->Void)) {
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
    private func parseSetDesktopMode(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getPanoramicSound(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    
    private func parseGetPanoramicSound(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
            success(state,.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalCommandSemaphore()
    }
    
    // MARK: - 全景声设置
    @objc public func setPanoramicSound(type:Int ,success:@escaping((ZywlError)->Void)) {
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
    private func parseSetPanoramicSound(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getLhdcMode(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    
    private func parseGetLhdcMode(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getSpeedMode(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    
    private func parseGetSpeedMode(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func setSpeedMode(type:Int ,success:@escaping((ZywlError)->Void)) {
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
    private func parseSetSpeedMode(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getResistanceWindNoise(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    
    private func parseGetResistanceWindNoise(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func setResistanceWindNoise(type:Int ,success:@escaping((ZywlError)->Void)) {
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
    private func parseSetResistanceWindNoise(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getBassToneEnhancement(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    
    private func parseGetBassToneEnhancement(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func setBassToneEnhancement(type:Int ,success:@escaping((ZywlError)->Void)) {
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
    private func parseSetBassToneEnhancement(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getLowFrequencyEnhancement(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
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
    
    private func parseGetLowFrequencyEnhancement(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func setLowFrequencyEnhancement(type:Int ,success:@escaping((ZywlError)->Void)) {
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
    private func parseSetLowFrequencyEnhancement(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getCoupletPattern(_ success:@escaping((_ type:Int,ZywlError)->Void)) {
        var val:[UInt8] = [0xBA,0x57]
        let data = Data.init(bytes: &val, count: val.count)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetCoupletPattern = success
        }else{
            success(0,state)
        }
    }
    
    private func parseGetCoupletPattern(val:[UInt8],success:@escaping((_ type:Int,ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func setCoupletPattern(type:Int ,success:@escaping((ZywlError)->Void)) {
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
    private func parseSetCoupletPattern(val:[UInt8],success:@escaping((ZywlError)->Void)) {
        if val.count >= 3 {
            let state = Int(val[2])
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "state:%d",state))
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
    @objc public func getOwsDeviceAllInformation(_ success:@escaping((_ model:ZywlOwsL04DeviceInformationModel?,ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x01,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsDeviceAllInformation = success
        }else{
            success(nil,state)
        }
    }
    
    private func parseGetOwsDeviceAllInformation(val:[UInt8],success:@escaping((ZywlOwsL04DeviceInformationModel?,ZywlError)->Void)) {
        
        if val.count >= 44 {
            let model = ZywlOwsL04DeviceInformationModel()
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
    @objc public func getOwsBoxScreenSize(_ success:@escaping((_ width:Int,_ height:Int,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x02,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsBoxScreenSize = success
        }else{
            success(0,0,state)
        }
    }
    
    func parseGetOwsBoxScreenSize(val:[UInt8],success:@escaping((_ width:Int,_ height:Int,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsBleName(_ success:@escaping((_ name:String?,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x03,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsBleName = success
        }else{
            success(nil,state)
        }
    }
    
    func parseGetOwsBleName(val:[UInt8],success:@escaping((_ name:String?,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsMediaVoiceVolume(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x04,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsMediaVoiceVolume = success
        }else{
            success(0,state)
        }
    }
    
    func parseGetOwsMediaVoiceVolume(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsScreenOutTimeLength(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x05,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsScreenOutTimeLength = success
        }else{
            success(0,state)
        }
    }
    
    func parseGetOwsScreenOutTimeLength(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsLocalDialIndex(_ success:@escaping((_ index:Int,_ totalCount:Int,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x06,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsLocalDialIndex = success
        }else{
            success(0,0,state)
        }
    }
    
    func parseGetOwsLocalDialIndex(val:[UInt8],success:@escaping((_ index:Int,_ totalCount:Int,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsMessageRemind(_ success:@escaping((_ isOpencall:Bool,_ isOpenSms:Bool,_ isOpenOther:Bool,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x07,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsMessageRemind = success
        }else{
            success(false,false,false,state)
        }
    }
    
    func parseGetOwsMessageRemind(val:[UInt8],success:@escaping((_ isOpencall:Bool,_ isOpenSms:Bool,_ isOpenOther:Bool,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsGameMode(_ success:@escaping((_ isOpen:Bool,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x08,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsGameMode = success
        }else{
            success(false,state)
        }
    }
    
    func parseGetOwsGameMode(val:[UInt8],success:@escaping((_ isOpen:Bool,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsNoiseControlMode(_ success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x09,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsNoiseControlMode = success
        }else{
            success(0,state)
        }
    }
    
    func parseGetOwsNoiseControlMode(val:[UInt8],success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsNoiseReductionMode(_ success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x0a,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsNoiseReductionMode = success
        }else{
            success(0,state)
        }
    }
    
    func parseGetOwsNoiseReductionMode(val:[UInt8],success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsShakeSongMode(_ success:@escaping((_ isOpen:Bool,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x0b,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsShakeSongMode = success
        }else{
            success(false,state)
        }
    }
    
    func parseGetOwsShakeSongMode(val:[UInt8],success:@escaping((_ isOpen:Bool,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsSupportFunction(_ success:@escaping((_ functionCount1:Int,_ functionCount2:Int,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x0c,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsSupportFunction = success
        }else{
            success(0,0,state)
        }
    }
    
    func parseGetOwsSupportFunction(val:[UInt8],success:@escaping((_ functionCount1:Int,_ functionCount2:Int,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsDeviceOriginalName(_ success:@escaping((_ name:String?,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x0d,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsDeviceOriginalName = success
        }else{
            success(nil,state)
        }
    }
    
    func parseGetOwsDeviceOriginalName(val:[UInt8],success:@escaping((_ name:String?,_ error:ZywlError)->Void)) {
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
    @objc public func getOwsAlarmArray(_ success:@escaping((_ modelArray:[ZywlOwsAlarmModel],_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x01,0x0d,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsAlarmArray = success
        }else{
            success([],state)
        }
    }
    
    func parseGetOwsAlarmArray(val:[UInt8],success:@escaping((_ modelArray:[ZywlOwsAlarmModel],_ error:ZywlError)->Void)) {
        
        var alarmArray = [ZywlOwsAlarmModel]()
        let alarmCount = Int(val[0])
        if val.count == alarmCount * 5 + 1 {
            for i in 0..<alarmCount {
                let model = ZywlOwsAlarmModel.init()
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
    @objc public func setOwsClearPairingRecord(_ success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsResetFactory(_ success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsTouchButtonFunction(handId:Int,touchId:Int,functionId:Int,_ success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsAllTouchButtonReset(_ success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsFindHeadphones(isOpen:Bool,_ success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsBleName(name:String,_ success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsMediaVoiceVolume(value:Int,_ success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsScreenOutTimeLength(value:Int,_ success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsLocalDialIndex(_ value:Int,_ success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsMessageRemind(isOpencall:Bool,isOpenSms:Bool,isOpenOther:Bool,success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsGameMode(isOpen:Bool,success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsNoiseControlMode(type:Int, success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func getOwsNoiseReductionMode(type:Int, success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsShakeSong(_ success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsShakeSongMode(isOpen:Bool, success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func setOwsTime(time:Any? = nil,success:@escaping((ZywlError) -> Void)) {
        
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
    @objc public func setOwsLanguage(type:Int,success:@escaping((ZywlError) -> Void)) {
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
    @objc public func setOwsAlarmArray(modelArray:[ZywlOwsAlarmModel],success:@escaping((ZywlError) -> Void)) {
        
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
    @objc public func setOwsOperationSong(type:Int,success:@escaping((ZywlError) -> Void)) {
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
    @objc public func setOwsWeather(city:String? = nil,modelArray:[ZywlOwsWeatherModel],success:@escaping((ZywlError) -> Void)) {
        
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
    func parseSetGeneralSettingsReply(val:[UInt8],success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func reportOwsMediaVoiceVolume(success:@escaping((_ volume:Int,_ error:ZywlError) -> Void)) {
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
    @objc public func reportOwsBattery(success:@escaping((_ leftBattery:Int,_ rightBattery:Int,_ boxBattery:Int,_ error:ZywlError) -> Void)) {
        self.receiveReportOwsBattery = success
    }
    
    func parseReportOwsBattery(val:[UInt8],success:@escaping((_ leftBattery:Int,_ rightBattery:Int,_ boxBattery:Int,_ error:ZywlError) -> Void)) {
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
    
    @objc public func reportOwsModel(success:@escaping((_ owsModel:ZywlOwsL04DeviceInformationModel?) -> Void)) {
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
    @objc public func getOwsEqMode(_ success:@escaping((_ isOpen:Bool,_ type:Int,_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x04,0x01,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsEqMode = success
        }else{
            success(false,0,state)
        }
    }
    
    func parseGetOwsEqMode(val:[UInt8],success:@escaping((_ isOpen:Bool,_ type:Int,_ error:ZywlError)->Void)) {
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
    @objc public func setOwsEqMode(isOpen:Bool,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
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
    @objc public func getOwsCustomEq(_ success:@escaping((_ type:Int,_ valueArray:[Int],_ error:ZywlError)->Void)) {
        var val:[UInt8] = [0xA8,0x03,0x00,0x06,0x04,0x03,0x00,0x01,0x00]
        let data = self.owsCrc8Data(val: val)
        
        let state = self.writeDataAndBackError(data: data)
        if state == .none {
            self.receiveGetOwsCustomEq = success
        }else{
            success(0,[],state)
        }
    }
    
    func parseGetOwsCustomEq(val:[UInt8],success:@escaping((_ type:Int,_ valueArray:[Int],_ error:ZywlError)->Void)) {
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
    @objc public func setOwsCustomEq(valueArray:[Float],success:@escaping((_ error:ZywlError)->Void)) {
        
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
    
    
    // MARK: - ZYCX耳机协议
    // MARK: - ZYCX通用发送数据部分
    func dealChargingBoxData(headVal:[UInt8],contentVal:[UInt8],backBlock:@escaping((ZywlError)->())) {
        var headVal = headVal
        var dataArray:[Data] = []
        var firstBit:UInt8 = 0
        let maxMtuCount = self.maxMtuCount
            if contentVal.count > maxMtuCount {
                firstBit = 128
            }
        headVal.append(UInt8((contentVal.count >> 8) & 0xff)+firstBit)
        headVal.append(UInt8((contentVal.count ) & 0xff))
        //判断是否要分包，分包的要再加总包数跟报序号
        if firstBit > 0 {
            var contentIndex = 0
            var packetCount = 0
            while contentIndex < contentVal.count {
                //分包添加总包数跟包序号
                let maxCount =  contentVal.count / (maxMtuCount - 10) + (contentVal.count % (maxMtuCount - 10) > 0 ? 1 : 0)
                let packetVal:[UInt8] = [
                    UInt8((maxCount >> 8) & 0xff),
                    UInt8((maxCount ) & 0xff),
                    UInt8((packetCount >> 8) & 0xff),
                    UInt8((packetCount ) & 0xff),
                ]
                //嵌入式何工把长度这部分修改为 多包也只发当前包的长度
                if packetCount < maxCount - 1 {
                    headVal[headVal.count-2] = UInt8(((maxMtuCount - 10) >> 8) & 0xff) + firstBit
                    headVal[headVal.count-1] = UInt8(((maxMtuCount - 10)) & 0xff)
                }else{
                    let countValue = contentVal.count - packetCount * (maxMtuCount - 10)
                    headVal[headVal.count-2] = UInt8((countValue >> 8) & 0xff) + firstBit
                    headVal[headVal.count-1] = UInt8((countValue) & 0xff)
                }
                
                let startIndex = packetCount*(maxMtuCount - 10)
                //print("(packetCount+1)*(maxMtuCount - 10) = \((packetCount+1)*(maxMtuCount - 10)),(startIndex + contentVal.count - packetCount*(maxMtuCount - 10)) = \((startIndex + contentVal.count - packetCount*(maxMtuCount - 10)))")
                let endIndex = (packetCount+1)*(maxMtuCount - 10) <= contentVal.count ? (packetCount+1)*(maxMtuCount - 10) : (startIndex + contentVal.count - packetCount*(maxMtuCount - 10))
                let subContentVal =  Array(contentVal[startIndex..<endIndex])
                                
                var val = headVal + packetVal + subContentVal
                
                let check = CRC16(val: val)
                let checkVal = [UInt8((check >> 8) & 0xff),UInt8((check ) & 0xff)]
                
                val += checkVal
                
                let data = Data.init(bytes: &val, count: val.count)
                dataArray.append(data)
                
                packetCount += 1
                contentIndex = endIndex
            }
            
        }else{
            var val = headVal + contentVal
            let check = CRC16(val: val)
            let checkVal = [UInt8((check >> 8) & 0xff),UInt8((check ) & 0xff)]
            
            val += checkVal
            
            let data = Data.init(bytes: &val, count: val.count)
            dataArray.append(data)
        }
        
        if dataArray.count > 0 {
            print("self.chargingBoxPeripheral?.state = \(self.chargingBoxPeripheral?.state.rawValue)")
            if self.chargingBoxPeripheral?.state != .connected {
                
                backBlock(.disconnected)
                return
            }
            
            if self.chargingBoxWriteCharacteristic == nil || self.chargingBoxPeripheral == nil {
                
                backBlock(.invalidCharacteristic)
                return
            }

            
            DispatchQueue.global().async {

                self.semaphoreChargingBoxCount -= 1
                let result = self.chargingBoxSemaphore.wait(wallTimeout: DispatchWallTime.now()+5)
                if result == .timedOut {
                    self.semaphoreChargingBoxCount += 1
                }
                
                DispatchQueue.main.async {

                    printLog("发送命令 -> self.semaphoreChargingBoxCount =",self.semaphoreChargingBoxCount)
                    backBlock(.none)
                    
                    var delayCount = 0
                    for item in dataArray {
                        let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: item,isSend: true))
                        printLog("send =",dataString)
                        self.writeChargingBoxData(data: item)
                        if delayCount > 5 {
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
                let state = self.writeChargingBoxDataAndBackError(data: data)
                backBlock(state)
            }
        }
    }
    
    func dealHeadphoneData(headVal:[UInt8],contentVal:[UInt8],backBlock:@escaping((ZywlError)->())) {
        var headVal = headVal
        var dataArray:[Data] = []
        var firstBit:UInt8 = 0
        let maxMtuCount = self.maxHeadphoneMtuCount
            if contentVal.count > maxMtuCount {
                firstBit = 128
            }
        headVal.append(UInt8((contentVal.count >> 8) & 0xff)+firstBit)
        headVal.append(UInt8((contentVal.count ) & 0xff))
        //判断是否要分包，分包的要再加总包数跟报序号
        if firstBit > 0 {
            var contentIndex = 0
            var packetCount = 0
            while contentIndex < contentVal.count {
                //分包添加总包数跟包序号
                let maxCount =  contentVal.count / (maxMtuCount - 10) + (contentVal.count % (maxMtuCount - 10) > 0 ? 1 : 0)
                let packetVal:[UInt8] = [
                    UInt8((maxCount >> 8) & 0xff),
                    UInt8((maxCount ) & 0xff),
                    UInt8((packetCount >> 8) & 0xff),
                    UInt8((packetCount ) & 0xff),
                ]
                //嵌入式何工把长度这部分修改为 多包也只发当前包的长度
                if packetCount < maxCount - 1 {
                    headVal[headVal.count-2] = UInt8(((maxMtuCount - 10) >> 8) & 0xff) + firstBit
                    headVal[headVal.count-1] = UInt8(((maxMtuCount - 10)) & 0xff)
                }else{
                    let countValue = contentVal.count - packetCount * (maxMtuCount - 10)
                    headVal[headVal.count-2] = UInt8((countValue >> 8) & 0xff) + firstBit
                    headVal[headVal.count-1] = UInt8((countValue) & 0xff)
                }
                
                let startIndex = packetCount*(maxMtuCount - 10)
                //print("(packetCount+1)*(maxMtuCount - 10) = \((packetCount+1)*(maxMtuCount - 10)),(startIndex + contentVal.count - packetCount*(maxMtuCount - 10)) = \((startIndex + contentVal.count - packetCount*(maxMtuCount - 10)))")
                let endIndex = (packetCount+1)*(maxMtuCount - 10) <= contentVal.count ? (packetCount+1)*(maxMtuCount - 10) : (startIndex + contentVal.count - packetCount*(maxMtuCount - 10))
                let subContentVal =  Array(contentVal[startIndex..<endIndex])
                                
                var val = headVal + packetVal + subContentVal
                
                let check = CRC16(val: val)
                let checkVal = [UInt8((check >> 8) & 0xff),UInt8((check ) & 0xff)]
                
                val += checkVal
                
                let data = Data.init(bytes: &val, count: val.count)
                dataArray.append(data)
                
                packetCount += 1
                contentIndex = endIndex
            }
            
        }else{
            var val = headVal + contentVal
            let check = CRC16(val: val)
            let checkVal = [UInt8((check >> 8) & 0xff),UInt8((check ) & 0xff)]
            
            val += checkVal
            
            let data = Data.init(bytes: &val, count: val.count)
            dataArray.append(data)
        }
        
        if dataArray.count > 0 {
            print("self.headphonePeripheral?.state = \(self.headphonePeripheral?.state.rawValue)")
            if self.headphonePeripheral?.state != .connected {
                
                backBlock(.disconnected)
                return
            }
            
            if self.headphoneWriteCharacteristic == nil || self.headphonePeripheral == nil {
                
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
                        printLog("send =",dataString)
                        self.writeData(data: item)
                        if delayCount > 5 {
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
    
    // MARK: - ZYCX通用回复
    func parseChargingBoxUniversalResponse(result:UInt8,success:@escaping((ZywlError) -> Void)) {
        
        let state = String.init(format: "%02x",result)
        
        switch result {
        case 0:
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
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
        self.signalChargingBoxSemaphore()
    }
    
    func parseHeadphoneUniversalResponse(result:UInt8,success:@escaping((ZywlError) -> Void)) {
        
        let state = String.init(format: "%02x",result)
        
        switch result {
        case 0:
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
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
        if self.isHeadphoneForwardingData {
            self.signalChargingBoxSemaphore()
        }else{
            self.isHeadphoneForwardingData = false
            self.signalCommandSemaphore()
        }
    }
    // MARK: - 同步分包信息交互(主动)
    /*
     4.1.同步分包信息交互(设备主动)
     消息ID：0x00(发送)
     起始字节           字段              数据类型            描述及要求
     0                单包最大发送长度     WORD             注：需要先确定单包最大发送长度后再进行其他操作
                                                            使用最小长度做发送分包

     消息ID：0x80(应答)
     起始字节           字段              数据类型            描述及要求
     0                单包最大发送长度     BYTE
     
     */
    @objc public func getPhoneMaxMtu() -> Int {
        var maxLength = 20
        if let chargingBoxWriteCharacteristic = self.chargingBoxWriteCharacteristic {
            maxLength = self.chargingBoxPeripheral?.maximumWriteValueLength(for: (((chargingBoxWriteCharacteristic.properties.rawValue) & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse) ?? 20
        }
        ZywlSDKLog.writeStringToSDKLog(string: "maxWriteValueLength:\(maxLength)")
        return maxLength
    }
    @objc public func getZycxSubcontractingInfomation(maxValue:Int = 0,_ success:@escaping((_ count:Int, _ error:ZywlError)->Void)) {
        
        let headVal:[UInt8] = [
            0xac,
            0x00
        ]
        var mtu = 1024
        if let chargingBoxWriteCharacteristic = self.chargingBoxWriteCharacteristic {
            mtu = self.chargingBoxPeripheral?.maximumWriteValueLength(for: (((chargingBoxWriteCharacteristic.properties.rawValue) & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse) ?? 1024
        }
        let maxLength = maxValue > 0 ? maxValue : mtu
        
        print("最大写入长度 maxLength = \(maxLength)")
        let contentVal:[UInt8] = [UInt8(((maxLength) >> 8) & 0xff),UInt8((maxLength) & 0xff)]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxSubcontractingInfomation = success
            }else{
                success(0,error)
            }
        }
    }
    
    func parseGetZycxSubcontractingInfomation(val:[UInt8],success:@escaping((_ count:Int, _ error:ZywlError)->Void)) {
        
        if val.count == 2 {
            
            let count = (Int(val[0]) << 8 | Int(val[1]))
            self.maxMtuCount = count
            let string = String.init(format: "%d",count)
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "解析 最大写入长度:%@",string))
            success(Int(count),.none)
            
        }else{
            success(0,.invalidState)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalChargingBoxSemaphore()
    }
    
    /*
     
     4.2.同步分包信息交互(耳机主动)
     消息ID：0x81(发送)
     起始字节    字段    数据类型    描述及要求
     0    单包最大发送长度    WORD    使用最小长度做发送分包

     消息ID：0x01(应答)
     起始字节    字段    数据类型    描述及要求
     0    单包最大发送长度    BYTE
     
     */
    @objc public func reportZycxSubcontractingInfomation(_ success:@escaping((_ count:Int ,_ error:ZywlError)->Void)) {
        
        self.receiveReportZycxSubcontractingInfomation = success
        
    }
    
    func parseReportZycxSubcontractingInfomation(val:[UInt8],success:@escaping((_ count:Int, _ error:ZywlError)->Void)) {
        
        if val.count == 2 {
            
            let count = (Int(val[0]) << 8 | Int(val[1]) )
            self.maxMtuCount = count
            let string = String.init(format: "%d",count)
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
            success(Int(count),.none)
            
        }else{
            success(0,.invalidState)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalChargingBoxSemaphore()
    }
    
    // MARK: - 查询设备功能列表
    /*
     4.3.查询设备功能列表

     消息ID：0x02(发送)
     消息体为空；

     消息ID：0x82(应答)
     起始字节    字段    数据类型    描述及要求
     0    功能列表数据长度    BYTE    该长度仅代表“功能列表数据”的长度；
     1    功能列表数据    BYTE[n]     详见“功能列表数据”
                                    每个功能采用1个BIT代表；
                                    例如：1-支持消息推送，则BYTE[0]的BIT0为1；
                                    2-支持拍照控制，则BYTE[1]的BIT7为1；
                                     注：
                                     为了节约空间设计；部分位支持包含详细数据，详见“功能列表数据说明”
     1+n    功能列表详细数据项总数    BYTE    可选项；某些功能列表数据存在更详细的数据，则存在该项，否则不此项及以下项；
     2+n    功能列表详细数据列表    BYTE[n]

     功能列表详细数据列表说明
     起始字节    字段    数据类型    描述及要求
     0    功能列表详细数据ID    BYTE    详见“功能列表详细数据说明”
     1    功能列表详细数据长度    BYTE
     2    功能列表详细数据内容    BYTE[n]

     功能列表数据说明
     序号    功能列表数据
     0      消息推送
            该位支持则包含详细数据，详见“功能列表详细数据ID：0x00”
     1    语言
            该位支持则包含详细数据，详见“功能列表详细数据ID：0x01”
     2    闹钟
            该位支持则包含详细数据，详见“功能列表详细数据ID：0x02”
     3    久坐
     4    振动
     5    勿扰模式
     6    防丢
     7    天气
     8    背光控制
            该位支持则包含详细数据，详见“功能列表详细数据ID：0x03”
     9    通讯录
            该位支持则包含详细数据，详见“功能列表详细数据ID：0x04”
     10    在线表盘
     11    自定义表盘
            该位支持则包含详细数据，详见“功能列表详细数据ID：0x05”
     12    本地表盘
            该位支持则包含详细数据，详见“功能列表详细数据ID：0x06”
     13    生理周期
     14    喝水
     15    拍照控制
     16    音乐控制
     17    查找设备
     18    关机控制
     19    重启控制
     20    恢复出厂控制
     21    挂断电话
     22    接听电话
     23    时间格式
     24    屏的款式 (方、圆)
            该位支持则包含详细数据，详见“功能列表详细数据ID：0x07”
     25    是否支持经典蓝牙
     26    绑定 app 时，进行数据擦除
     27    绑定、解绑
     28    设备平台类型
            该位支持则包含详细数据，详见“功能列表详细数据ID：0x08”
     29    自定义表盘字体颜色设置
     30    SOS 紧急联系人
     31    支持本地播
            该位支持则包含详细数据，详见“功能列表详细数据ID：0x09”

     功能列表详细数据说明
     功能列表详细数据ID    功能列表详细数据长度    功能列表详细数据内容
     0x00    BYTE[8]    消息推送内容
                        详见“消息类型列表说明”
                         采用BIT方式标识是否支持该类型，0-支持，1不支持
                         例如：1-支持QQ，则BYTE[0]的BIT4为1
                         2-支持Zalo，则BYTE[3]的BIT7为1
     0x01    BYTE[8]    语言
                         详见“语言类型列表说明”
                         采用BIT方式标识是否支持该类型，0-支持，1不支持
                         例如：1-支持法语，则BYTE[0]的BIT5为1
                         2-支持高棉语，则BYTE[4]的BIT7为1
     0x02    BYTE[2]    闹钟内容
                         BYTE[0]：最大支持多少个闹钟
                         BYTE[1]：是否支持添加或者删除功能 (0: 不支持, 1: 支持)
     0x03    BYTE[4]    背光控制内容
                         BYTE0：亮度等级
                         BYTE1：亮屏时长最大值
                         BYTE2：亮屏时长最小值
                         BYTE3：亮屏时长调整间隔（当无该字段时APP默认调整间隔为1s
     0x04    WORD    通讯录最大支持条数
     0x05    BYTE[9]    自定义表盘
                         BYTE0：自定义表盘颜色设置，0：不支持，1：支持
                         BYTE1~BYTE2：屏宽度
                         BYTE3~BYTE4：屏高度
                         BYTE5~BYTE6：缩图宽度
                         BYTE7~BYTE8：缩图高度
     0x06    BYTE    内置表盘个数
     0x07    BYTE    屏款式
                        BYTE0：0方宽，1纯圆款，2圆角款
     0x08    BYTE    设备平台类型
                        BYTE0：0瑞昱，1杰里，2 Nordic
     0x09    BYTE    BYTE0：本地播支持的音乐文件格式
                     BIT0：mp3
                     BIT1：wav
                     BIT2~BIT7：预留，默认0
     
     消息类型列表说明
     序号    消息类型
     0    Call(电话)
     1    SMS(信息)
     2    Instagram(照片墙)
     3    Wechat(中国微信)
     4    QQ
     5    Line(韩国社交软件)
     6    LinkedIn(领英)
     7    WhatsApp(美国社交软件)
     8    Twitter(推特)
     9    Facebook(脸书)
     10    Messenger(Facebook 社交软件)
     11    Skype(微软的一个即时通讯软件)
     12    Snapchat(“阅后即焚”照片分享应用)
     13    支付宝
     14    淘宝
     15    抖音
     16    钉钉
     17    京东
     18    Gmail
     19    Viber
     20    YouTube
     21    KakaoTalk
     22    Telegram
     23    Hangouts
     24    Vkontakte
     25    Flickr
     26    Tumblr
     27    Pinterest
     28    Truecaller
     29    Paytm
     30    Zalo
     31    MicrosoftTeams

     语言类型列表说明
     序号    语言类型
     0    英文
     1    简体中文
     2    日语
     3    韩语
     4    德语
     5    法语
     6    西班牙语
     7    阿拉伯语
     8    俄语
     9    繁体中文
     10    意大利语
     11    葡萄牙语
     12    乌克兰
     13    印度语
     14    波兰语
     15    希腊语
     16    越南语
     17    印度尼西亚语
     18    泰语
     19    荷兰语
     20    土耳其语
     21    罗马尼亚语
     22    丹麦语
     23    瑞典语
     24    孟加拉语
     25    捷克语
     26    波斯语
     27    希伯来语
     28    马来语
     29    斯洛伐克语
     30    科萨语
     31    斯洛文尼亚语
     32    匈牙利语
     33    立陶宛语
     34    乌尔都语
     35    保加利亚语
     36    克罗地亚语
     37    拉脱维亚语
     38    爱沙尼亚语
     39    高棉语
     
     */
    
    @objc public func getZycxFunctionList(_ success:@escaping((ZycxFunctionListModel?,ZywlError)->Void)) {
        
        let headVal:[UInt8] = [
            0xac,
            0x02
        ]
        
        let contentVal:[UInt8] = []
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxFunctionList = success
            }else{
                success(nil,error)
            }
        }
    }
    
    func parseGetZycxFunctionList(val:[UInt8],success:@escaping((ZycxFunctionListModel?,ZywlError)->Void)) {
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }
        
        ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "parseGetZycxFunctionList待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        
        let model = ZycxFunctionListModel.init(val: val)
        
        success(model,.none)
        //printLog("第\(#line)行" , "\(#function)")
        self.signalChargingBoxSemaphore()
    }
    
    /*
     
     4.4.设备信息查询
     消息ID：0x03(发送)
     消息体为空；

     消息ID：0x83(应答)
     起始字节    字段    数据类型    描述及要求
     0    设备信息ID项总数    BYTE
     1    设备信息数据项列表    BYTE[n]    详见”设备信息数据项列表说明”

     设备信息数据项列表说明
     起始字节    字段    数据类型    描述及要求
     0    设备信息ID    BYTE    详见”设备信息数据定义说明表”
     1    设备信息数据长度    BYTE
     2    设备信息数据内容    BYTE[n]

     参数ID    参数内容长度    参数说明
     0x00    BYTE[16]    设备名称（ASCII编码字符串）
     0x01    BYTE[8]    固件版本号（ASCII编码字符串）
     0x02    BYTE[4]    图库版本号（ASCII编码字符串）
     0x03    BYTE[4]    字库版本号（ASCII编码字符串）
     0x04    BYTE    产品ID
     0x05    BYTE    项目ID
     0x06    BYTE[6]    设备MAC地址
     0x07    BYTE[14]    序列号,AAA_AAA_AAAAAA
     0x08    BYTE[8]    硬件版本号,ASCII编码字符串跟设备显示保持一致
     0x09    BYTE[8]    自定义表盘尺寸，自定义表盘尺寸信息数据格式
     
     */
    // MARK: - 设备信息查询
    @objc public func getZycxDeviceInfomation(_ success:@escaping((_ model:ZycxDeviceInfomationModel?,_ error:ZywlError)->Void)) {
        
        let headVal:[UInt8] = [
            0xac,
            0x03
        ]
        
        var contentVal:[UInt8] = [
            0x00,
            0x01,
            0x02,
            0x03,
            0x04,
            0x05,
            0x06,
            0x07,
            0x08,
            0x09
        ]
        contentVal.insert(UInt8(contentVal.count), at: 0)
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxDeviceInfomation = success
            }else{
                success(nil,error)
            }
        }
    }
    
    func parseGetZycxDeviceInfomation(val:[UInt8],success:@escaping((_ model:ZycxDeviceInfomationModel?,_ error:ZywlError)->Void)) {
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }
        
        ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "parseGetZycxDeviceInfomation待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))

        var modelDic:[String:Any] = [:]
        let count:Int = Int(val[0])
        var index = 1
        for i in 0..<count {
            let functionId = val[index]
            let functionLength = val[index+1]
            let functionVal = Array.init(val[(index+2)..<(index+2+Int(functionLength))])
            
            let functionData = functionVal.withUnsafeBufferPointer({ (bytes) -> Data in
                let byte = bytes.baseAddress!
                return Data.init(bytes: byte, count: functionVal.count)
            })
            
            switch functionId {
            case 0:
                
                if let nameString = String.init(data: functionData, encoding: .utf8) {
                    modelDic["name"] = nameString
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "name = %@",nameString))
                }
                break
            case 1:
                let firmwareString = String.init(format: "%d.%d", functionVal[0],functionVal[1])
                modelDic["firmwareVersion"] = firmwareString
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "firmwareVersion = %@",firmwareString))
                
                break
            case 2:
                
                let imageString = String.init(format: "%d.%d", functionVal[0],functionVal[1])
                modelDic["imageVersion"] = imageString
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "imageVersion = %@",imageString))
                
                break
                
            case 3:
                let fontString = String.init(format: "%d.%d", functionVal[0],functionVal[1])
                modelDic["fontVersion"] = fontString
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "fontVersion = %@",fontString))
                
                break
            case 4:
                let productString = String.init(format: "%d", (Int(functionVal[0]) << 8 | Int(functionVal[1])))
                modelDic["productId"] = productString
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "productId = %@",productString))
                break
            case 5:
                let projectString = String.init(format: "%d", (Int(functionVal[0]) << 8 | Int(functionVal[1])))
                modelDic["projectId"] = projectString
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "projectId = %@",projectString))
                break
            case 6:
                let macString = String.init(format: "%02x:%02x:%02x:%02x:%02x:%02x",functionVal[0],functionVal[1],functionVal[2],functionVal[3],functionVal[4],functionVal[5])
                modelDic["mac"] = macString
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "mac = %@",macString))
                break
            case 7:
                if let serverString = String.init(data: functionData, encoding: .utf8) {
                    modelDic["serialNumber"] = serverString
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "serialNumber = %@",serverString))
                }
                break
            case 8:
                if let hardwareString = String.init(data: functionData, encoding: .utf8) {
                    modelDic["hardwareVersion"] = hardwareString
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "hardwareVersion = %@",hardwareString))
                }
                break
            case 9:
                
                let bigWidth = (Int(functionVal[0]) << 8 | Int(functionVal[1]))
                let bigHeight = (Int(functionVal[2]) << 8 | Int(functionVal[3]))
                let smallWidth = (Int(functionVal[4]) << 8 | Int(functionVal[5]))
                let smallHeight = (Int(functionVal[6]) << 8 | Int(functionVal[7]))
                let dialSize = ZycxDialFrameSizeModel.init(dic: ["bigWidth":"\(bigWidth)","bigHeight":"\(bigHeight)","smallWidth":"\(smallWidth)","smallHeight":"\(smallHeight)"])
                modelDic["dialSize"] = dialSize
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "bigWidth = %d",dialSize.bigWidth))
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "bigHeight = %d",dialSize.bigHeight))
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "smallWidth = %d",dialSize.smallWidth))
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "smallHeight = %d",dialSize.smallHeight))
                
                break
            default:
                break
            }
            index = (index+2+Int(functionLength))
        }
        let model = ZycxDeviceInfomationModel.init(dic: modelDic)
        self.zycxDeviceInfoModel = model
        success(model,.none)
        
        //printLog("第\(#line)行" , "\(#function)")
        self.signalChargingBoxSemaphore()
    }

    // MARK: - 设备参数查询
    /*
     消息ID：0x04(发送)
     起始字节    字段    数据类型    描述及要求
     0    参数ID项总数    BYTE
     1    参数 ID 列表    BYTE[n]    参数顺序排列，如“参数 ID1 参数 ID2......参数IDn”。

     消息ID：0x84(应答)
     起始字节    字段    数据类型    描述及要求
     0    参数项总数    BYTE
     1    参数列表    BYTE[n]    详见”参数列表说明”

     参数列表说明
     起始字节    字段    数据类型    描述及要求
     0    参数ID    BYTE    详见”参数ID说明”
     1    参数长度    BYTE
     2    参数内容    BYTE[n]

     参数ID说明
     参数ID    参数长度    参数内容
     0x00    BYTE    时区
     东区1-12 ，西区 13-24
     0x01    BYTE[7]    时间，例：2023/03/01 17:20:22
     BYTE[0] = 0xE7;
     BYTE[1] = 0x07;
     BYTE[2] = 0x03;
     BYTE[3] = 0x01;
     BYTE[4] = 0x11;
     BYTE[5] = 0x14;
     BYTE[6] = 0x16;
     0x02    BYTE    时间制式，0：24小时制，1：12小时制
     0x03    BYTE    天气单位  0x00：摄氏度0x01：华氏度
     0x04    BYTE    屏幕亮度，范围：0~100%
     0x05    BYTE    亮屏时间，范围：1~60秒
     0x06    BYTE    当前本地表盘序号，范围：0~255
     0x07    BYTE    当前语言，详见“语言类型列表说明”
     0x08    BYTE[8]    消息提醒开关，详见“消息类型列表说明”
     0x09    BYTE[n]    闹钟信息，详见“闹钟信息说明”
     0x0A    BYTE[n]    自定义表盘，详见“自定义表盘说明”
     0x0B    BYTE[n]    天气信息，详见“天气信息说明”
     0x0C    BYTE[n]    SOS紧急报警联系人，详见“SOS紧急报警联系人说明”
     0x0D    BYTE[n]    常用联系人，详见“常用联系人说明”
     0x0E    BYTE[16]    UUID，用于BT回连
     0x0F    BYTE       震动，0-关闭 1-开启
     0x10    BYTE[n]    久坐
     0x11    BYTE[6]    喝水
     0x12    BYTE[5]    勿扰
     0x13    BYTE       防丢，0-关闭 1-开启
     0x14    BYTE[10]   生理周期，详见“生理周期说明”
     0x15    BYTE[n]    蓝牙名，最大 29 字节
     
     天气信息说明
     起始字节    字段    数据类型    描述及要求
     0    时间    BYTE[7]    例：2023/03/01 17:20:22
     BYTE[0] = 0xE7;// 年
     BYTE[1] = 0x07;// 年
     BYTE[2] = 0x03;// 月
     BYTE[3] = 0x01;// 日
     BYTE[4] = 0x11;// 时
     BYTE[5] = 0x14;// 分
     BYTE[6] = 0x16;// 秒
     7    天气信息总数    BYTE    范围1~7
     8    天气信息内容    BYTE[n]    详见“天气信息内容说明”

     天气信息内容说明
     起始字节    字段    数据类型    描述及要求
     1    未来天数    BYTE    范围0~6；0-今天，1-明天
     2    天气代码    BYTE    0-多云，1-雾霾，2-晴，3-阴天，4-雪，5-⾬
     3    平均气温    BYTE    偏移值：127，范围：-127~128，单位：℃
     4    空气质量    BYTE    预留
     5    最低温度    BYTE    偏移值：127，范围：-127~128，单位：℃
     6    最高温度    BYTE    偏移值：127，范围：-127~128，单位：℃

     闹钟信息说明
     起始字节    字段    数据类型    描述及要求
     0    闹钟总数    BYTE    最小为1个
     1    闹钟详情列表    BYTE[n]    详见“闹钟详情列表说明”

     闹钟详情列表说明
     起始字节    字段    数据类型    描述及要求
     0    序号（id）    BYTE    从0开始
     1    重复    BYTE    bit7 表示循环开关，1 开 0 关
     bit0-6 表示星期天到星期六闹钟开关
     2    小时    BYTE    0~23
     3    分钟    BYTE    0~59

     自定义表盘说明
     起始字节    字段    数据类型    描述及要求
     0    字体颜色    BYTE[3]    RGB 888
     3    显示位置
     类型    BYTE    0 左上 1 左中 2 左下
     3 右上 4 右中 5 右下
     6 中上 7 居中 8 中下

     4    时间上方
     显示类型    BYTE    0关闭
     1 日期
     2 睡眠
     3 心率
     4 计步
     5    时间下方
     显示类型    BYTE    同时间上方显示类型

     SOS紧急联系人说明
     起始字节    字段    数据类型    描述及要求
     0    联系人姓名长度    BYTE
     1    联系人姓名    BYTE[m]    utf-8编码
     1+m    联系电话长度    BYTE
     2+m    联系电话    BYTE[n]    utf-8编码

     常用联系人说明
     起始字节    字段    数据类型    描述及要求
     0    常用联系人总数    BYTE    最小为1
     1    常用联系人列表    BYTE[n]

     起始字节    字段    数据类型    描述及要求
     0    序号    BYTE    从0开始
     1    联系人姓名长度    BYTE
     2    联系人姓名    STRING
     2+m    联系电话长度    BYTE
     3+m    联系电话    STRING

     久坐说明
     起始字节   字段  数据类型    描述及要求
     0        开关   BYTE     0，关闭 1，开启
     1      间隔时长  BYTE      单位：分钟
     2      时段数据数量  BYTE    数量最大为 2
     3      时段数据列表  BYTE[4] 详见“时段数据说明”
     
     时段数据说明
     0      时段1开始小时     BYTE    范围 0~23；单位：小时
     1      时段1开始分钟     BYTE    范围 0~59；单位：分钟
     2      时段2结束小时     BYTE
     3      时段2结束分钟     BYTE
     
     喝水说明
     起始字节 字段 数据类型 描述及要求
     0 开关 BYTE 0，关闭 1，开启
     1 开始小时 BYTE 范围 0~23；单位：小时
     2 开始分钟 BYTE 范围 0~59；单位：分钟
     3 结束小时 BYTE
     4 结束分钟 BYTE
     5 提醒间隔 BYTE 单位：分钟
     
     勿扰说明
     起始字节 字段 数据类型 描述及要求
     0 开关 BYTE 0，关闭 1，开启
     1 开始小时 BYTE 范围 0~23；单位：小时
     2 开始分钟 BYTE 范围 0~59；单位：分钟
     3 结束小时 BYTE
     4 结束分钟 BYTE
     
     生理周期说明
     起始字节 字段 数据类型 描述及要求
     0  开关       BYTE    0，关闭 1，开启
        周期天数    BYTE 0~255
        经期天数    BYTE 0~255
        上次经期的年  WORD >2000
        上次经期的月  BYTE 1~12
        上次经期的日  BYTE 1~31
        经期开始提醒  BYTE 月经期到来的倒计通知天数，0 表示不提醒
        提醒小时     BYTE 0~23
        提醒分钟     BYTE 0~59
     */
    @objc public func getZycxDeviceParameters(listArray:[Int]? = nil , success:@escaping((_ model:ZycxDeviceParametersModel?,_ error:ZywlError)->Void)) {
        
        var headVal:[UInt8] = [
            0xac,
            0x04
        ]
        
        var listArray:[Int] = listArray ?? []
        if listArray.count <= 0 {
            for i in stride(from: 0, to: 21, by: 1) {
                listArray.append(i)
            }
        }
        
        var contentVal:[UInt8] = []
        contentVal.append(UInt8(listArray.count))
        for item in listArray {
            contentVal.append(UInt8(item))
        }
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxDeviceParameters = success
            }else{
                success(nil,error)
            }
        }
    }
    
    func parseGetZycxDeviceParameters(val:[UInt8],success:@escaping((_ model:ZycxDeviceParametersModel?,_ error:ZywlError)->Void)) {
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }
        
        ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "parseGetZycxDeviceParameters待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))

        let model = ZycxDeviceParametersModel()
        let count:Int = Int(val[0])
        var index = 1
        for _ in 0..<count {
            let functionId = val[index]
            let functionLength = (val[index+1] << 8 | val[index+2])
            let functionVal = Array.init(val[(index+3)..<(index+3+Int(functionLength))])
            
            let functionData = functionVal.withUnsafeBufferPointer({ (bytes) -> Data in
                let byte = bytes.baseAddress!
                return Data.init(bytes: byte, count: functionVal.count)
            })
            
            switch functionId {
            case 0:
                let timezone = Int(functionVal[0])
                model.timezone = timezone
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "timezone = %d",timezone))
                break
            case 1:
                let timeString = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", (Int(functionVal[0]) << 8 | Int(functionVal[1])),functionVal[2],functionVal[3],functionVal[4],functionVal[5],functionVal[6])
                model.timeString = timeString
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "timeString = %@",timeString))
                
                break
            case 2:
                let timeFormat_is12 = functionVal[0] == 0 ? false : true
                model.timeFormat_is12 = timeFormat_is12
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "timeFormat_is24 = %d",!timeFormat_is12))
                
                break
                
            case 3:
                let weatherUnit_isH = functionVal[0] == 0 ? false : true
                model.weatherUnit_isH = weatherUnit_isH
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "weatherUnit_isC = %d",!weatherUnit_isH))
                
                break
            case 4:
                let screenLightLevel = Int(functionVal[0])
                model.screenLightLevel = screenLightLevel
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "screenLightLevel = %d",screenLightLevel))
                break
            case 5:
                let screenLightTimeLong = Int(functionVal[0])
                model.screenLightTimeLong = screenLightTimeLong
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "screenLightTimeLong = %d",screenLightTimeLong))
                break
            case 6:
                let localDialIndex = Int(functionVal[0])
                model.localDialIndex = localDialIndex
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "localDialIndex = %d",localDialIndex))
                break
            case 7:
                let languageIndex = Int(functionVal[0])
                model.languageIndex = languageIndex
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "languageIndex = %d",languageIndex))
                break
            case 8:
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
                let messagePushModel = ZycxDeviceParametersModel_messagePush(result: Double(functionCount))
                model.messagePushModel = messagePushModel
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "messagePushModelCount = %.0f",messagePushModel.openCount))
                var messagePushString = ""
                if model.messagePushModel?.isOpenCall == true {
                    messagePushString += "\n isOpenCall"
                }
                if model.messagePushModel?.isOpenSMS == true {
                    messagePushString += "\n isOpenSMS"
                }
                if model.messagePushModel?.isOpenWechat == true {
                    messagePushString += "\n isOpenWechat"
                }
                if model.messagePushModel?.isOpenQQ == true {
                    messagePushString += "\n isOpenQQ"
                }
                if model.messagePushModel?.isOpenFacebook == true {
                    messagePushString += "\n isOpenFacebook"
                }
                if model.messagePushModel?.isOpenTwitter == true {
                    messagePushString += "\n isOpenTwitter"
                }
                if model.messagePushModel?.isOpenWhatsApp == true {
                    messagePushString += "\n isOpenWhatsApp"
                }
                if model.messagePushModel?.isOpenInstagram == true {
                    messagePushString += "\n isOpenInstagram"
                }
                if model.messagePushModel?.isOpenSkype == true {
                    messagePushString += "\n isOpenSkype"
                }
                if model.messagePushModel?.isOpenKakaoTalk == true {
                    messagePushString += "\n isOpenKakaoTalk"
                }
                if model.messagePushModel?.isOpenLine == true {
                    messagePushString += "\n isOpenLine"
                }
                if model.messagePushModel?.isOpenLinkedIn == true {
                    messagePushString += "\n isOpenLinkedIn"
                }
                if model.messagePushModel?.isOpenMessenger == true {
                    messagePushString += "\n isOpenMessenger"
                }
                if model.messagePushModel?.isOpenSnapchat == true {
                    messagePushString += "\n isOpenSnapchat"
                }
                if model.messagePushModel?.isOpenAlipay == true {
                    messagePushString += "\n isOpenAlipay"
                }
                if model.messagePushModel?.isOpenTaoBao == true {
                    messagePushString += "\n isOpenTaoBao"
                }
                if model.messagePushModel?.isOpenDouYin == true {
                    messagePushString += "\n isOpenDouYin"
                }
                if model.messagePushModel?.isOpenDingDing == true {
                    messagePushString += "\n isOpenDingDing"
                }
                if model.messagePushModel?.isOpenJingDong == true {
                    messagePushString += "\n isOpenJingDong"
                }
                if model.messagePushModel?.isOpenGmail == true {
                    messagePushString += "\n isOpenGmail"
                }
                if model.messagePushModel?.isOpenViber == true {
                    messagePushString += "\n isOpenViber"
                }
                if model.messagePushModel?.isOpenYouTube == true {
                    messagePushString += "\n isOpenYouTube"
                }
                if model.messagePushModel?.isOpenTelegram == true {
                    messagePushString += "\n isOpenTelegram"
                }
                if model.messagePushModel?.isOpenHangouts == true {
                    messagePushString += "\n isOpenHangouts"
                }
                if model.messagePushModel?.isOpenVkontakte == true {
                    messagePushString += "\n isOpenVkontakte"
                }
                if model.messagePushModel?.isOpenFlickr == true {
                    messagePushString += "\n isOpenFlickr"
                }
                if model.messagePushModel?.isOpenTumblr == true {
                    messagePushString += "\n isOpenTumblr"
                }
                if model.messagePushModel?.isOpenPinterest == true {
                    messagePushString += "\n isOpenPinterest"
                }
                if model.messagePushModel?.isOpenTruecaller == true {
                    messagePushString += "\n isOpenTruecaller"
                }
                if model.messagePushModel?.isOpenPaytm == true {
                    messagePushString += "\n isOpenPaytm"
                }
                if model.messagePushModel?.isOpenZalo == true {
                    messagePushString += "\n isOpenZalo"
                }
                if model.messagePushModel?.isOpenMicrosoftTeams == true {
                    messagePushString += "\n isOpenMicrosoftTeams"
                }
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: " messagePushOpen = %@",messagePushString))
                break
            case 9:
                
                var alarmArray = [ZycxDeviceParametersModel_alarm]()
                let alarmCount = functionVal[0]
                var valIndex = 1
                while valIndex < functionVal.count {
                    let index = functionVal[valIndex+0]
                    let repeatCount = functionVal[valIndex+1]
                    let hour = functionVal[valIndex+2]
                    let minute = functionVal[valIndex+3]
                    let string = String.init(format: "序号:%d,重复:%d,小时:%d,分钟:%d",index,repeatCount,hour,minute)
                    ZywlSDKLog.writeStringToSDKLog(string: string)
                    let model = ZycxDeviceParametersModel_alarm.init(dic: ["index":"\(index)","repeatCount":"\(repeatCount)","hour":String.init(format: "%02d", hour),"minute":String.init(format: "%02d", minute)])
                    alarmArray.append(model)
                    valIndex += 4
                }
                model.alarmListModel = alarmArray
                
                break
                
            case 10:
                
                let colorHex = String.init(format: "0x%06x", (Int(functionVal[0]) << 16 | Int(functionVal[1]) << 8 | Int(functionVal[2])))
                let position = functionVal[3]
                let timeUpType = functionVal[4]
                let timeDownType = functionVal[5]

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
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "%@",string))
                
                let customDialModel = ZycxDeviceParametersModel_customDial.init(dic: ["colorHex":colorHex,"color":color,"positionType":"\(position)","timeUpType":"\(timeUpType)","timeDownType":"\(timeDownType)"])
                model.customDialModel = customDialModel
                
                break
                
            case 11:
                
                let timeString = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", (Int(functionVal[0] << 8) | Int(functionVal[1])),functionVal[2],functionVal[3],functionVal[4],functionVal[5],functionVal[6])
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "天气timeString:%@",timeString))
                model.weatherModel = .init()
                let arrayCount = Int(functionVal[7])
                var weatherArray = [ZycxDeviceParametersModel_weather].init()
                let weatherVal = Array.init(functionVal[(8)..<(functionVal.count)])
                for i in 0..<arrayCount {
                    let weatherModel = ZycxDeviceParametersModel_weather.init()
                    weatherModel.dayCount = Int(weatherVal[i*5])
                    weatherModel.type = ZycxWeatherType.init(rawValue: Int(weatherVal[i*5+1])) ?? .sunny
                    weatherModel.temp = Int(weatherVal[i*5+2])
                    weatherModel.airQuality = Int(weatherVal[i*5+3])
                    weatherModel.minTemp = Int(weatherVal[i*5+4])
                    weatherModel.maxTemp = Int(weatherVal[i*5+5])
                    weatherArray.append(weatherModel)
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "dayCount:\(weatherModel.dayCount),type:\(weatherModel.type.rawValue),temp:\(weatherModel.temp),airQuality:\(weatherModel.airQuality),minTemp:\(weatherModel.minTemp),weatherModel.maxTemp:\(weatherModel.maxTemp)"))
                }
                model.weatherModel?.timeString = timeString
                model.weatherModel?.weatherArray = weatherArray
                
                break
            case 12:
                
                let currentIndex = 0
                let nameLength = functionVal[currentIndex]
                let nameArray = Array(functionVal[(currentIndex+1)..<(currentIndex+1+Int(nameLength))])
                let numberLength = functionVal[currentIndex+1+Int(nameLength)]
                let numberArray = Array(functionVal[(currentIndex+2+Int(nameLength))..<(currentIndex+2+Int(nameLength)+Int(numberLength))])

                let contactModel = ZycxDeviceParametersModel_contactPerson.init()
                let nameData = nameArray.withUnsafeBufferPointer { (bytes) -> Data in
                    return Data.init(buffer: bytes)
                }
                if let str = String.init(data: nameData, encoding: .utf8) {
                    contactModel.name = str
                }

                let numberData = numberArray.withUnsafeBufferPointer({ (bytes) -> Data in
                    return Data.init(buffer: bytes)
                })

                if let str = String.init(data: numberData, encoding: .utf8) {
                    contactModel.phoneNumber = str
                }

                model.sosContactModel = contactModel
                
                break
            case 13:
                
                break
            case 14:
                var uuidString = ""
                for i in functionVal {
                    uuidString += String.init(format: "%02x", i)
                }
                model.uuidString = uuidString
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "uuidString:%@",uuidString))
                break
            case 0x0f:
                let vibration = functionVal[0] == 0 ? false : true
                model.vibration = vibration
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "vibration = %d",vibration))
                break
            case 0x10:
                
                let isOpen = functionVal[0] == 0 ? false : true
                let timeLong = functionVal[1]
                let count = functionVal[2]
                
                var modelArray:[ZycxDeviceParametersModel_timeModel] = Array.init()
                
                for i in 0..<Int(count) {
                    let model = ZycxDeviceParametersModel_timeModel.init()
                    model.startHour = Int(val[3+i*4])
                    model.startMinute = Int(val[4+i*4])
                    model.endHour = Int(val[5+i*4])
                    model.endMinute = Int(val[6+i*4])
                    modelArray.append(model)
                }
                
                let string = String.init(format: "开关:%d,时长:%d,时段数量：%d,时段数组",isOpen,timeLong,count,modelArray)
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "久坐:%@",string))
                let sedentaryModel = ZycxDeviceParametersModel_sedentaryModel.init(dic: ["isOpen":"\(isOpen)","timeLong":"\(timeLong)","timeArray":modelArray])
                model.sedentaryModel = sedentaryModel
                
                break
            case 0x11:
                
                let isOpen = functionVal[0]
                let startHour = functionVal[1]
                let startMinute = functionVal[2]
                let endHour = functionVal[3]
                let endMinute = functionVal[4]
                let remindInterval = functionVal[5]
                let string = String.init(format: "开关:%d,开始时间：%d:%d,结束时间：%d:%d,提醒间隔:%d",isOpen,startHour,startMinute,endHour,endMinute,remindInterval)
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "喝水:%@",string))
                
                let drinkWaterModel = ZycxDeviceParametersModel_drinkWaterModel.init(dic: ["isOpen":"\(isOpen)","startHour":String.init(format: "%02d", startHour),"startMinute":String.init(format: "%02d", startMinute),"endHour":String.init(format: "%02d", endHour),"endMinute":String.init(format: "%02d", endMinute),"remindInterval":"\(remindInterval)"])
                model.drinkWaterModel = drinkWaterModel
                break
            case 0x12:
                
                let isOpen = functionVal[0]
                let startHour = functionVal[1]
                let startMinute = functionVal[2]
                let endHour = functionVal[3]
                let endMinute = functionVal[4]
                let string = String.init(format: "开关:%d,开始时间：%d:%d,结束时间：%d:%d",isOpen,startHour,startMinute,endHour,endMinute)
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
                
                let disturbModel = ZycxDeviceParametersModel_disturbModel.init(dic: ["isOpen":"\(isOpen)","startHour":String.init(format: "%02d", startHour),"startMinute":String.init(format: "%02d", startMinute),"endHour":String.init(format: "%02d", endHour),"endMinute":String.init(format: "%02d", endMinute)])
                model.disturbModel = disturbModel
                break
            case 0x13:
                let lostRemind = functionVal[0] == 0 ? false : true
                model.lostRemind = lostRemind
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "lostRemind = %d",lostRemind))
                break
            case 0x14:
                let isOpen = functionVal[0]
                let cycleCount = functionVal[1]
                let menstrualCount = functionVal[2]
                let lastYear = (Int(functionVal[3]) << 8 | Int(functionVal[4]) )
                let lastMonth = functionVal[5]
                let lastDay = functionVal[6]
                let startDay = functionVal[7]
                let remindHour = functionVal[8]
                let remindMinute = functionVal[9]
                let string = String.init(format: "开关:%d,周期天数:%d,经期天数:%d,上次经期日期:%04d-%02d-%02d,提前%d天提醒,提醒时间：%d:%d",isOpen,cycleCount,menstrualCount,lastYear,lastMonth,lastDay,startDay,remindHour,remindMinute)
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "生理周期:%@",string))
                
                let physiologicalModel = ZycxDeviceParametersModel_physiologicalModel.init(dic: ["isOpen":"\(isOpen)",
                                                         "cycleCount":"\(cycleCount)",
                                                         "menstrualCount":"\(menstrualCount)",
                                                         "year":"\(lastYear)",
                                                         "month":"\(lastMonth)",
                                                         "day":"\(lastDay)",
                                                         "advanceDay":"\(startDay)",
                                                         "remindHour":"\(remindHour)",
                                                         "remindMinute":"\(remindMinute)",
                                                         ])
                model.physiologicalModel = physiologicalModel
                break
            case 0x15:
                if let bleName = String.init(data: functionData, encoding: .utf8) {
                    model.bleName = bleName
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "bleName = %@",bleName))
                }
                break
            default:
                break
            }
            index = (index+3+Int(functionLength))
        }
        success(model,.none)
        
        //printLog("第\(#line)行" , "\(#function)")
        self.signalChargingBoxSemaphore()
    }
    
    // MARK: - 参数设置
    /*
     消息ID：0x05(发送)
     起始字节    字段    数据类型    描述及要求
     0    参数项总数    BYTE
     1    参数列表    BYTE[n]    详见“参数列表说明(设置)”

     参数列表说明(设置)
     起始字节    字段    数据类型    描述及要求
     0    参数ID    BYTE    详见”参数ID说明”
     1    参数长度    BYTE
     2    参数内容    BYTE[n]

     消息ID：0x85(应答)
     起始字节    字段    数据类型    描述及要求
     0    参数项总数    BYTE
     1    参数列表    BYTE[n]    该列表为设置的所有项

     参数数据项列表说明(应答)
     起始字节    字段    数据类型    描述及要求
     0    参数ID    BYTE    详见”参数ID说明”
     2    操作结果    BYTE    0：成功，1：失败
     
     */
    @objc public func setZycxDeviceParameters(model:ZycxDeviceParametersModel) {
        
        var headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        let id0 = [0x00,0x00,0x01,UInt8(model.timezone)]
        
        let format = DateFormatter.init()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date:Date = format.date(from: model.timeString) ?? Date()
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let id1 = [0x01,0x00,0x07,UInt8((year >> 8) & 0xFF) ,UInt8(year & 0xFF),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)]
        
        let id2 = [0x02,0x00,0x01,UInt8(model.timeFormat_is12 ? 0x01:0x00)]
        
        let id3 = [0x03,0x00,0x01,UInt8(model.weatherUnit_isH ? 0x01:0x00)]
        
        let id4 = [0x04,0x00,0x01,UInt8(model.screenLightLevel)]
        
        let id5 = [0x05,0x00,0x01,UInt8(model.screenLightTimeLong)]
        
        let id6 = [0x06,0x00,0x01,UInt8(model.localDialIndex)]
        
        let id7 = [0x07,0x00,0x01,UInt8(model.languageIndex)]
        
        let openCount = model.messagePushModel?.openCount ?? 0
        //
        let id8:[UInt8] = [0x08,0x00,0x08,UInt8((Int(openCount)) & 0xFF),UInt8((Int(openCount) >> 8) & 0xFF),UInt8((Int(openCount) >> 16) & 0xFF),UInt8((Int(openCount) >> 24) & 0xFF),UInt8((Int(openCount) >> 32) & 0xFF),UInt8((Int(openCount) >> 40) & 0xFF),UInt8((Int(openCount) >> 48) & 0xFF),UInt8((Int(openCount) >> 56) & 0xFF)]
        
        var id9:[UInt8] = [0x09,0x00,0x00]
        if model.alarmListModel.count > 0 {
            id9.append(UInt8(model.alarmListModel.count))
            let alarmArray = model.alarmListModel.sorted { alarm1, alarm2 in
                return alarm1.alarmIndex < alarm2.alarmIndex
            }
            for i in 0..<alarmArray.count {
                let alarm = alarmArray[i]
                id9.append(UInt8(i))
                id9.append(UInt8(alarm.alarmRepeatCount))
                id9.append(UInt8(alarm.alarmHour))
                id9.append(UInt8(alarm.alarmMinute))
            }
            id9[2] = UInt8(alarmArray.count*4 + 1)
        }
        
        var ida:[UInt8] = [0x0a,0x00,0x06]
        if let customDialModel = model.customDialModel {
            let uint8Max = CGFloat(UInt8.max)
            var r:CGFloat = 0
            var g:CGFloat = 0
            var b:CGFloat = 0
            var alpha:CGFloat = 0
            customDialModel.color.getRed(&r, green: &g, blue: &b, alpha: &alpha)
            
            let intR:UInt8 = UInt8(r * uint8Max)
            let intG:UInt8 = UInt8(g * uint8Max)
            let intB:UInt8 = UInt8(b * uint8Max)
            ida.append(contentsOf: [UInt8(intR),UInt8(intG),UInt8(intB)])
            ida.append(UInt8(customDialModel.positionType.rawValue))
            ida.append(UInt8(customDialModel.timeUpType.rawValue))
            ida.append(UInt8(customDialModel.timeDownType.rawValue))
        }
        
        var idb:[UInt8] = [0x0b,0x00,0x00]
        if let weatherModel = model.weatherModel {
            if weatherModel.weatherArray.count > 0 {
                let weatherDate:Date = format.date(from:weatherModel.timeString) ?? Date()
                let year = calendar.component(.year, from: weatherDate)
                let month = calendar.component(.month, from: weatherDate)
                let day = calendar.component(.day, from: weatherDate)
                let hour = calendar.component(.hour, from: weatherDate)
                let minute = calendar.component(.minute, from: weatherDate)
                let second = calendar.component(.second, from: weatherDate)
                idb.append(contentsOf: [UInt8((year >> 8) & 0xFF) ,UInt8(year & 0xFF),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)])
                idb.append(UInt8(weatherModel.weatherArray.count))
                
                for item in weatherModel.weatherArray {
                    idb.append(UInt8(item.dayCount))
                    idb.append(UInt8(item.type.rawValue))
                    idb.append(UInt8.init(bitPattern: Int8(item.temp)))
                    idb.append(UInt8(item.airQuality))
                    idb.append(UInt8.init(bitPattern: Int8(item.minTemp)))
                    idb.append(UInt8.init(bitPattern: Int8(item.maxTemp)))
                }
                idb[2] = UInt8(weatherModel.weatherArray.count * 6 + 8)
            }
        }
        
        var idc:[UInt8] = [0x0c,0x00,0x00]
        if let sosModel = model.sosContactModel {
            var nameData = sosModel.name.data(using: .utf8) ?? .init()
            if nameData.count >= 64 {
                nameData = nameData.subdata(in: 0..<64)
            }
            let nameValArray = nameData.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: nameData.count))
            }
            var phoneData = sosModel.phoneNumber.data(using: .utf8) ?? .init()
            if phoneData.count >= 32 {
                phoneData = phoneData.subdata(in: 0..<32)
            }
            let phoneValArray = phoneData.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: phoneData.count))
            }
            idc.append(UInt8(nameData.count))
            idc.append(contentsOf: nameValArray)
            idc.append(UInt8(phoneData.count))
            idc.append(contentsOf: phoneValArray)
            //参数长度
            let modelCount = 2 + nameValArray.count + phoneValArray.count
            idc[1] = UInt8((modelCount >> 8) & 0xFF)
            idc[2] = UInt8((modelCount) & 0xFF)
        }
        
        var idd:[UInt8] = [0x0d,0x00,0x00]
        if model.addressBookContactListModel.count > 0 {
            idd.append(UInt8(model.addressBookContactListModel.count))
            for i in 0..<model.addressBookContactListModel.count {
                idd.append(UInt8(i))
                let addressModel = model.addressBookContactListModel[i]
                var nameData = addressModel.name.data(using: .utf8) ?? .init()
                if nameData.count >= 64 {
                    nameData = nameData.subdata(in: 0..<64)
                }
                let nameValArray = nameData.withUnsafeBytes { (byte) -> [UInt8] in
                    let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: nameData.count))
                }
                var phoneData = addressModel.phoneNumber.data(using: .utf8) ?? .init()
                if phoneData.count >= 32 {
                    phoneData = phoneData.subdata(in: 0..<32)
                }
                let phoneValArray = phoneData.withUnsafeBytes { (byte) -> [UInt8] in
                    let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: phoneData.count))
                }
                idd.append(UInt8(nameData.count))
                idd.append(contentsOf: nameValArray)
                idd.append(UInt8(phoneData.count))
                idd.append(contentsOf: phoneValArray)
            }
            //参数长度
            let modelCount = idd.count - 3
            idd[1] = UInt8((modelCount >> 8) & 0xFF)
            idd[2] = UInt8((modelCount) & 0xFF)
        }
        
        
        var ide:[UInt8] = [0x0e,0x00,0x10]
        var uuidStr = ""
        if model.uuidString.count > 0 {
            uuidStr = model.uuidString.replacingOccurrences(of: "-", with: "")
        }else{
            uuidStr = self.chargingBoxPeripheral?.identifier.uuidString.replacingOccurrences(of: "-", with: "") ?? ""
        }
        for i in stride(from: 0, to: uuidStr.count/2, by: 1) {
            let indexCount = i*2
            let string = "" + uuidStr.dropFirst(indexCount).dropLast(uuidStr.count-indexCount-2)
            let value = self.hexStringToInt(from: string)
            ide.append(UInt8(value))
        }
        
        let idf = [0x0f,0x00,0x01,UInt8(model.vibration ? 0x01:0x00)]
        
        var id10:[UInt8] = [0x10,0x00,0x00]
        if let sedentaryModel = model.sedentaryModel {
            id10.append(contentsOf: [sedentaryModel.isOpen ? 0x01:0x00,UInt8(sedentaryModel.timeLong),UInt8(sedentaryModel.timeArray.count)])
            var timeVal:[UInt8] = Array.init()
            for i in 0..<sedentaryModel.timeArray.count {
                let timeModel = sedentaryModel.timeArray[i]
                let startHour = UInt8(timeModel.startHour)
                let startMinute = UInt8(timeModel.startMinute)
                let endHour = UInt8(timeModel.endHour)
                let endMinute = UInt8(timeModel.endMinute)
                timeVal.append(startHour)
                timeVal.append(startMinute)
                timeVal.append(endHour)
                timeVal.append(endMinute)
            }
            id10.append(contentsOf: timeVal)
            id10[2] = UInt8(id10.count)
        }
        
        var id11:[UInt8] = [0x11,0x00,0x06]
        if let drinkWaterModel = model.drinkWaterModel {
            id11.append(drinkWaterModel.isOpen ? 0x01 : 0x00)
            id11.append(UInt8(drinkWaterModel.timeModel.startHour))
            id11.append(UInt8(drinkWaterModel.timeModel.startMinute))
            id11.append(UInt8(drinkWaterModel.timeModel.endHour))
            id11.append(UInt8(drinkWaterModel.timeModel.endMinute))
            id11.append(UInt8(drinkWaterModel.remindInterval))
        }
        
        var id12:[UInt8] = [0x12,0x00,0x00]
        if let disturbModel = model.disturbModel {
            id12.append(disturbModel.isOpen ? 0x01 : 0x00)
            id12.append(UInt8(disturbModel.timeModel.startHour))
            id12.append(UInt8(disturbModel.timeModel.startMinute))
            id12.append(UInt8(disturbModel.timeModel.endHour))
            id12.append(UInt8(disturbModel.timeModel.endMinute))
            id12[2] = UInt8(id12.count)
        }

        let id13 = [0x13,0x00,0x01,UInt8(model.vibration ? 0x01:0x00)]
        
        var id14:[UInt8] = [0x14,0x00,0x00]
        if let physiologicalModel = model.physiologicalModel {
            id14.append(physiologicalModel.isOpen ? 0x01 : 0x00)
            id14.append(UInt8(physiologicalModel.cycleCount))
            id14.append(UInt8(physiologicalModel.menstrualCount))
            id14.append(UInt8((year >> 8) & 0xFF))
            id14.append(UInt8(year))
            id14.append(UInt8(physiologicalModel.month))
            id14.append(UInt8(physiologicalModel.day))
            id14.append(UInt8(physiologicalModel.advanceDay))
            id14.append(UInt8(physiologicalModel.remindHour))
            id14.append(UInt8(physiologicalModel.remindMinute))
            id14[2] = UInt8(id14.count)
        }
        
        var id15:[UInt8] = [0x15,0x00,0x00]
        let nameData = model.bleName.data(using: .utf8) ?? .init()
        //要限制长度<=64字符
        if nameData.count >= 29 {
            let aData = nameData.subdata(in: 0..<29)
            let str = NSString.init(data: aData, encoding:4)
            print("str = \(str)")
            
            let strUtf8 = String.init(data: aData, encoding: .utf8)
            print("strUtf8 = \(strUtf8)")
            let test = String.init(data: nameData, encoding: .utf8)
            print("nameData = \(test)")
            print("\(model.bleName) 长度超过29，截取为:\(String.init(format: "%@", aData as CVarArg))")
        }
        let nameValArray = nameData.withUnsafeBytes { (byte) -> [UInt8] in
            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
            return [UInt8](UnsafeBufferPointer.init(start: b, count: nameData.count >= 29 ? 29 : nameData.count))
        }
        id15.append(contentsOf: nameValArray)
        id15[2] = UInt8(id15.count)
        
        var contentVal:[UInt8] = [0x21]
        contentVal.append(contentsOf: id0)
        contentVal.append(contentsOf: id1)
        contentVal.append(contentsOf: id2)
        contentVal.append(contentsOf: id3)
        contentVal.append(contentsOf: id4)
        contentVal.append(contentsOf: id5)
        contentVal.append(contentsOf: id6)
        contentVal.append(contentsOf: id7)
        contentVal.append(contentsOf: id8)
        contentVal.append(contentsOf: id9)
        contentVal.append(contentsOf: ida)
        contentVal.append(contentsOf: idb)
        contentVal.append(contentsOf: idc)
        contentVal.append(contentsOf: idd)
        contentVal.append(contentsOf: ide)
        contentVal.append(contentsOf: id10)
        contentVal.append(contentsOf: id11)
        contentVal.append(contentsOf: id12)
        contentVal.append(contentsOf: id13)
        contentVal.append(contentsOf: id14)
        contentVal.append(contentsOf: id15)
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.signalChargingBoxSemaphore()
            }else{

            }
        }
    }
    
    func parseSetZycxDeviceParameters(val:[UInt8],success:@escaping((_ error:ZywlError)->Void)) {
        
        //printLog("第\(#line)行" , "\(#function)")
        
    }
    
    // MARK: - 获取时区
    @objc public func getZycxTimezone(_ success:@escaping((_ timezone:Int,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [0]) { model, error in
            success(model?.timezone ?? 0,error)
        }
    }
    
    // MARK: - 设置时区
    @objc public func setZycxTimezone(timezone:Int,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        let id0 = [0x00,0x00,0x01,UInt8(timezone)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id0)
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxTimezone = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取时间
    @objc public func getZycxTime(_ success:@escaping((_ timeString:String,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [1]) { model, error in
            success(model?.timeString ?? "",error)
        }
    }
    
    // MARK: - 设置时间
    @objc public func setZycxTime(timeString:String? = nil,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        let format = DateFormatter.init()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var date:Date = Date()
        if let timeString = timeString {
            date = format.date(from: timeString) ?? Date()
        }
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let id1 = [0x01,0x00,0x07,UInt8((year >> 8) & 0xFF) ,UInt8(year & 0xFF),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)]
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id1)
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxTime = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取时间制
    @objc public func getZycxTimeformat(_ success:@escaping((_ timeformat:Bool,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [2]) { model, error in
            success(model?.timeFormat_is12 ?? false,error)
        }
    }
    
    // MARK: - 设置时间制
    @objc public func setZycxTimeFormat(is12:Bool,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        let id2 = [0x02,0x00,0x01,UInt8(is12 ? 0x01:0x00)]
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id2)
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxTimeFormat = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取天气单位
    @objc public func getZycxWeatherUnit(_ success:@escaping((_ weatherUnit:Bool,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [3]) { model, error in
            success(model?.weatherUnit_isH ?? false,error)
        }
    }
    
    // MARK: - 设置天气单位
    @objc public func setZycxWeatherUnit(isH:Bool,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        let id3 = [0x03,0x00,0x01,UInt8(isH ? 0x01:0x00)]

        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id3)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxWeatherUnit = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取屏幕亮度
    @objc public func getZycxScreenLightLevel(_ success:@escaping((_ level:Int,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [4]) { model, error in
            success(model?.screenLightLevel ?? 1,error)
        }
    }
    
    // MARK: - 设置屏幕亮度
    @objc public func setZycxScreenLightLevel(level:Int,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        let id4 = [0x04,0x00,0x01,UInt8(level)]

        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id4)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxScreenLightLevel = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取亮屏时间
    @objc public func getZycxScreenLightTimeLong(_ success:@escaping((_ timelong:Int,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [5]) { model, error in
            success(model?.screenLightTimeLong ?? 1,error)
        }
    }
    
    // MARK: - 设置亮屏时间
    @objc public func setZycxScreenLightTimeLong(timeLong:Int,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        let id5 = [0x05,0x00,0x01,UInt8(timeLong)]

        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id5)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxScreenLightTimeLong = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取本地表盘序号
    @objc public func getZycxDialIndex(_ success:@escaping((_ index:Int,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [6]) { model, error in
            success(model?.localDialIndex ?? 1,error)
        }
    }
    
    // MARK: - 设置本地表盘序号
    @objc public func setZycxDialIndex(index:Int,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        let id6 = [0x06,0x00,0x01,UInt8(index)]
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id6)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxDialIndex = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取当前语言
    @objc public func getZycxLanguageIndex(_ success:@escaping((_ index:Int,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [7]) { model, error in
            success(model?.languageIndex ?? 1,error)
        }
    }
    
    // MARK: - 设置当前语言
    @objc public func setZycxLanguageIndex(index:Int,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        let id7 = [0x07,0x00,0x01,UInt8(index)]
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id7)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxLanguageIndex = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取消息提醒开关
    @objc public func getZycxMessagePush(_ success:@escaping((_ model:ZycxDeviceParametersModel_messagePush?,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [8]) { model, error in
            success(model?.messagePushModel ?? nil,error)
        }
    }
    
    // MARK: - 设置消息提醒开关
    @objc public func setZycxMessagePush(model:ZycxDeviceParametersModel_messagePush,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        let openCount = model.getCurrentOpenCount()
        //
        let id8:[UInt8] = [0x08,0x00,0x08,UInt8((Int(openCount)) & 0xFF),UInt8((Int(openCount) >> 8) & 0xFF),UInt8((Int(openCount) >> 16) & 0xFF),UInt8((Int(openCount) >> 24) & 0xFF),UInt8((Int(openCount) >> 32) & 0xFF),UInt8((Int(openCount) >> 40) & 0xFF),UInt8((Int(openCount) >> 48) & 0xFF),UInt8((Int(openCount) >> 56) & 0xFF)]
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id8)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxMessagePush = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取闹钟
    @objc public func getZycxAlarmArray(_ success:@escaping((_ alarmArray:[ZycxDeviceParametersModel_alarm],_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [9]) { model, error in
            success(model?.alarmListModel ?? [],error)
        }
    }
    
    // MARK: - 设置闹钟
    @objc public func setZycxAlarmArray(alarmArray:[ZycxDeviceParametersModel_alarm],_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        var alarmArray = alarmArray
        if alarmArray.count <= 0 {
            let zyModel = ZycxDeviceParametersModel_alarm.init()
            zyModel.alarmIndex = 0
            zyModel.alarmHour = 255
            zyModel.alarmMinute = 255
            alarmArray.append(zyModel)
        }
        var id9:[UInt8] = [0x09,0x00,0x00]
        if alarmArray.count > 0 {
            id9.append(UInt8(alarmArray.count))
            let alarmArray = alarmArray.sorted { alarm1, alarm2 in
                return alarm1.alarmIndex < alarm2.alarmIndex
            }
            for i in 0..<alarmArray.count {
                let alarm = alarmArray[i]
                id9.append(UInt8(i))
                id9.append(UInt8(alarm.alarmRepeatCount))
                id9.append(UInt8(alarm.alarmHour))
                id9.append(UInt8(alarm.alarmMinute))
            }
            id9[2] = UInt8(alarmArray.count*4 + 1)
        }
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id9)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxAlarmArray = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取自定义表盘信息
    @objc public func getZycxCustomDialInfomation(_ success:@escaping((_ model:ZycxDeviceParametersModel_customDial?,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [10]) { model, error in
            success(model?.customDialModel ?? nil,error)
        }
    }
    
    // MARK: - 设置自定义表盘信息
    @objc public func setZycxCustomDialInfomation(model:ZycxDeviceParametersModel_customDial,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        var ida:[UInt8] = [0x0a,0x00,0x06]
        let uint8Max = CGFloat(UInt8.max)
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var alpha:CGFloat = 0
        model.color.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        let intR:UInt8 = UInt8(r * uint8Max)
        let intG:UInt8 = UInt8(g * uint8Max)
        let intB:UInt8 = UInt8(b * uint8Max)
        ida.append(contentsOf: [UInt8(intR),UInt8(intG),UInt8(intB)])
        ida.append(UInt8(model.positionType.rawValue))
        ida.append(UInt8(model.timeUpType.rawValue))
        ida.append(UInt8(model.timeDownType.rawValue))
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: ida)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxCustomDialInfomation = success
            }else{
                success(error)
            }
        }
    }

    // MARK: - 获取天气信息
    @objc public func getZycxWeather(_ success:@escaping((_ model:ZycxDeviceParametersModel_weatherListModel?,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [11]) { model, error in
            success(model?.weatherModel ?? nil,error)
        }
    }
    
    // MARK: - 设置天气信息
    @objc public func setZycxWeather(model:ZycxDeviceParametersModel_weatherListModel,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        var idb:[UInt8] = [0x0b,0x00,0x00]
        if model.weatherArray.count > 0 {
            let format = DateFormatter.init()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
            let weatherDate:Date = format.date(from:model.timeString) ?? Date()
            let year = calendar.component(.year, from: weatherDate)
            let month = calendar.component(.month, from: weatherDate)
            let day = calendar.component(.day, from: weatherDate)
            let hour = calendar.component(.hour, from: weatherDate)
            let minute = calendar.component(.minute, from: weatherDate)
            let second = calendar.component(.second, from: weatherDate)
            idb.append(contentsOf: [UInt8((year >> 8) & 0xFF) ,UInt8(year & 0xFF),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)])
            idb.append(UInt8(model.weatherArray.count))
            
            for item in model.weatherArray {
                idb.append(UInt8(item.dayCount))
                idb.append(UInt8(item.type.rawValue))
                idb.append(UInt8.init(bitPattern: Int8(item.temp)))
                idb.append(UInt8(item.airQuality))
                idb.append(UInt8.init(bitPattern: Int8(item.minTemp)))
                idb.append(UInt8.init(bitPattern: Int8(item.maxTemp)))
            }
            idb[2] = UInt8(model.weatherArray.count * 6 + 8)
        }
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: idb)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxWeather = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取SOS联系人
    @objc public func getZycxSosContact(_ success:@escaping((_ model:ZycxDeviceParametersModel_contactPerson?,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [12]) { model, error in
            success(model?.sosContactModel ?? nil,error)
        }
    }
    
    // MARK: - 设置SOS联系人
    @objc public func setZycxSosContact(model:ZycxDeviceParametersModel_contactPerson,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        var idc:[UInt8] = [0x0c,0x00,0x00]
        var nameData = model.name.data(using: .utf8) ?? .init()
        if nameData.count >= 64 {
            nameData = nameData.subdata(in: 0..<64)
        }
        let nameValArray = nameData.withUnsafeBytes { (byte) -> [UInt8] in
            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
            return [UInt8](UnsafeBufferPointer.init(start: b, count: nameData.count))
        }
        var phoneData = model.phoneNumber.data(using: .utf8) ?? .init()
        if phoneData.count >= 32 {
            phoneData = phoneData.subdata(in: 0..<32)
        }
        let phoneValArray = phoneData.withUnsafeBytes { (byte) -> [UInt8] in
            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
            return [UInt8](UnsafeBufferPointer.init(start: b, count: phoneData.count))
        }
        idc.append(UInt8(nameData.count))
        idc.append(contentsOf: nameValArray)
        idc.append(UInt8(phoneData.count))
        idc.append(contentsOf: phoneValArray)
        //参数长度
        let modelCount = 2 + nameValArray.count + phoneValArray.count
        idc[1] = UInt8((modelCount >> 8) & 0xFF)
        idc[2] = UInt8((modelCount) & 0xFF)
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: idc)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxSosContact = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取常用联系人
    @objc public func getZycxAddressContact(_ success:@escaping((_ model:[ZycxDeviceParametersModel_contactPerson],_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [13]) { model, error in
            success(model?.addressBookContactListModel ?? [],error)
        }
    }
    
    // MARK: - 设置常用联系人
    @objc public func setZycxAddressContact(listModel:[ZycxDeviceParametersModel_contactPerson],_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        var idd:[UInt8] = [0x0d,0x00,0x00]
        idd.append(UInt8(listModel.count))
        for i in 0..<listModel.count {
            idd.append(UInt8(i))
            let addressModel = listModel[i]
            var nameData = addressModel.name.data(using: .utf8) ?? .init()
            if nameData.count >= 64 {
                nameData = nameData.subdata(in: 0..<64)
            }
            let nameValArray = nameData.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: nameData.count))
            }
            var phoneData = addressModel.phoneNumber.data(using: .utf8) ?? .init()
            if phoneData.count >= 32 {
                phoneData = phoneData.subdata(in: 0..<32)
            }
            let phoneValArray = phoneData.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: phoneData.count))
            }
            idd.append(UInt8(nameData.count))
            idd.append(contentsOf: nameValArray)
            idd.append(UInt8(phoneData.count))
            idd.append(contentsOf: phoneValArray)
        }
        //参数长度
        let modelCount = idd.count - 3
        idd[1] = UInt8((modelCount >> 8) & 0xFF)
        idd[2] = UInt8((modelCount) & 0xFF)

        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: idd)
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxAddressContact = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取uuid
    @objc public func getZycxDeviceUuidString(_ success:@escaping((_ uuidString:String,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [14]) { model, error in
            success(model?.uuidString ?? "",error)
        }
    }
    
    // MARK: - 设置uuid
    @objc public func setZycxDeviceUuidString(uuid:String? = nil,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        var ide:[UInt8] = [0x0e,0x00,0x10]
        
        var uuidStr = ""
        if let mac = uuid {
            uuidStr = mac.replacingOccurrences(of: "-", with: "")
        }else{
            uuidStr = self.chargingBoxPeripheral?.identifier.uuidString.replacingOccurrences(of: "-", with: "") ?? ""
        }
        for i in stride(from: 0, to: uuidStr.count/2, by: 1) {
            let indexCount = i*2
            let string = "" + uuidStr.dropFirst(indexCount).dropLast(uuidStr.count-indexCount-2)
            let value = self.hexStringToInt(from: string)
            ide.append(UInt8(value))
        }
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: ide)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxDeviceUuidString = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取震动
    @objc public func getZycxDeviceVibration(_ success:@escaping((_ isOpen:Bool,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [15]) { model, error in
            success(model?.vibration ?? false,error)
        }
    }
    // MARK: - 设置震动
    @objc public func setZycxDeviceVibration(isOpen:Bool,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        var idf:[UInt8] = [0x0f,0x00,0x01,isOpen ? 0x01:0x00]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: idf)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxDeviceVibration = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取久坐
    @objc public func getZycxSedentary(_ success:@escaping((_ model:ZycxDeviceParametersModel_sedentaryModel?,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [16]) { model, error in
            success(model?.sedentaryModel,error)
        }
    }
    
    // MARK: - 设置久坐
    @objc public func setZycxSedentary(model:ZycxDeviceParametersModel_sedentaryModel,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]

        var id10:[UInt8] = [0x10,0x00,0x00,model.isOpen ? 0x01:0x00,UInt8(model.timeLong),UInt8(model.timeArray.count)]
        
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
        id10.append(contentsOf: timeVal)
        id10[2] = UInt8(id10.count-3)
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id10)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxSedentary = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取喝水
    @objc public func getZycxDrinkWater(_ success:@escaping((_ model:ZycxDeviceParametersModel_drinkWaterModel?,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [17]) { model, error in
            success(model?.drinkWaterModel,error)
        }
    }
    // MARK: - 设置喝水
    @objc public func setZycxDrinkWater(model:ZycxDeviceParametersModel_drinkWaterModel,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        var id11:[UInt8] = [0x11,0x00,0x06]
        id11.append(model.isOpen ? 0x01 : 0x00)
        id11.append(UInt8(model.timeModel.startHour))
        id11.append(UInt8(model.timeModel.startMinute))
        id11.append(UInt8(model.timeModel.endHour))
        id11.append(UInt8(model.timeModel.endMinute))
        id11.append(UInt8(model.remindInterval))
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id11)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxDrinkWater = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取勿扰
    @objc public func getZycxDisturb(_ success:@escaping((_ model:ZycxDeviceParametersModel_disturbModel?,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [18]) { model, error in
            success(model?.disturbModel,error)
        }
    }
    
    // MARK: - 设置勿扰
    @objc public func setZycxDisturb(model:ZycxDeviceParametersModel_disturbModel,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]

        var id12:[UInt8] = [0x12,0x00,0x00]
        id12.append(model.isOpen ? 0x01 : 0x00)
        id12.append(UInt8(model.timeModel.startHour))
        id12.append(UInt8(model.timeModel.startMinute))
        id12.append(UInt8(model.timeModel.endHour))
        id12.append(UInt8(model.timeModel.endMinute))
        id12[2] = UInt8(id12.count-3)
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id12)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxDisturb = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取防丢
    @objc public func getZycxLostRemind(_ success:@escaping((_ isOpen:Bool,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [19]) { model, error in
            success(model?.lostRemind ?? false,error)
        }
    }
    
    // MARK: - 设置防丢
    @objc public func setZycxLostRemind(isOpen:Bool,_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]

        let id13 = [0x13,0x00,0x01,UInt8(isOpen ? 0x01:0x00)]
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id13)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxLostRemind = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取生理周期
    @objc public func getZycxPhysiologicalCycle(_ success:@escaping((_ model:ZycxDeviceParametersModel_physiologicalModel?,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [20]) { model, error in
            success(model?.physiologicalModel,error)
        }
    }
    
    // MARK: - 设置生理周期
    @objc public func setZycxPhysiologicalCycle(model:ZycxDeviceParametersModel_physiologicalModel , _ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        var id14:[UInt8] = [0x14,0x00,0x00]
        id14.append(model.isOpen ? 0x01 : 0x00)
        id14.append(UInt8(model.cycleCount))
        id14.append(UInt8(model.menstrualCount))
        id14.append(UInt8((model.year >> 8) & 0xFF))
        id14.append(UInt8(model.year))
        id14.append(UInt8(model.month))
        id14.append(UInt8(model.day))
        id14.append(UInt8(model.advanceDay))
        id14.append(UInt8(model.remindHour))
        id14.append(UInt8(model.remindMinute))
        id14[2] = UInt8(id14.count-3)
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id14)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxPhysiologicalCycle = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取蓝牙名
    @objc public func getZycxBleName(_ success:@escaping((_ name:String,_ error:ZywlError)->Void)) {
        self.getZycxDeviceParameters(listArray: [21]) { model, error in
            success(model?.bleName ?? "",error)
        }
    }
    
    // MARK: - 设置蓝牙名
    @objc public func setZycxBleName(bleName:String , _ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x05
        ]
        
        var id15:[UInt8] = [0x15,0x00,0x00]
        let nameData = bleName.data(using: .utf8) ?? .init()
        //要限制长度<=64字符
        if nameData.count >= 29 {
            let aData = nameData.subdata(in: 0..<29)
            let str = NSString.init(data: aData, encoding:4)
            print("str = \(str)")
            
            let strUtf8 = String.init(data: aData, encoding: .utf8)
            print("strUtf8 = \(strUtf8)")
            let test = String.init(data: nameData, encoding: .utf8)
            print("nameData = \(test)")
            print("\(bleName) 长度超过29，截取为:\(String.init(format: "%@", aData as CVarArg))")
        }
        let nameValArray = nameData.withUnsafeBytes { (byte) -> [UInt8] in
            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
            return [UInt8](UnsafeBufferPointer.init(start: b, count: nameData.count >= 29 ? 29 : nameData.count))
        }
        id15.append(contentsOf: nameValArray)
        id15[2] = UInt8(id15.count-3)
        
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id15)

        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxBleName = success
            }else{
                success(error)
            }
        }
    }

    // MARK: - 设备控制
    /*
     消息ID：0x06(发送)
     起始字节    字段    数据类型    描述及要求
     0    设备控制ID    BYTE    详见“设备控制ID说明(连接仓的设备主动)”
     1    设备控制长度    BYTE[n]
     1+n    设备控制内容    BYTE[n]

     设备控制ID说明(连接仓的设备主动)
     设备控制ID    设备控制长度    设备控制内容
     0x00    BYTE       0：设备关机 1.设备重启 2.设备恢复出厂设置 3.设备恢复出厂设置后关机
     0x01    BYTE       马达震动
                        0：关闭，1：开启
     0x02    BYTE       查找仓
                        0：关闭，1：开启
     0x03    BYTE[0]    清除设备BT配对信息
     0x04    BYTE       仓BT广播使能，0：关闭，1：开启
     0x05    BYTE       APP绑定，0:APP绑定，1:APP取消绑定
     0x06    BYTE       设备数据清除（设备无需重启）

     消息ID：0x86(应答)
     字段    数据类型    描述及要求
     控制ID    BYTE
     操作结果    BYTE    0x00 :成功 0x01 :失败
     */
    // MARK: - 设备关机
    @objc public func setZycxPowerOff(_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x00,0x01,0x00]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxPowerOff = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 设备重启
    @objc public func setZycxRestart(_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x00,0x01,0x01]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxRestart = success
            }else{
                success(error)
            }
        }
    }

    // MARK: - 设备恢复出厂
    @objc public func setZycxResetFactory(_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x00,0x01,0x02]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxResetFactory = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 设备恢复出厂并关机
    @objc public func setZycxResetFactoryAndPowerOff(_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x00,0x01,0x03]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxResetFactoryAndPowerOff = success
            }else{
                success(error)
            }
        }
    }

    // MARK: - 船运模式
    @objc public func setZycxShipMode(_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x00,0x01,0x04]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxShipMode = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 马达震动
    @objc public func setZycxVibrationMotor(isOpen:Bool,success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x01,0x01,isOpen ? 0x01:0x00]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxVibrationMotor = success
            }else{
                success(error)
            }
        }
    }

    // MARK: - 查找充电仓
    @objc public func setZycxFindChargingBox(isOpen:Bool,success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x02,0x01,isOpen ? 0x01:0x00]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxFindChargingBox = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 清除设备BT配对信息
    @objc public func setZycxClearBtInfomation(_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x03]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxClearBtInfomation = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 仓BT广播使能
    @objc public func setZycxBtRadioEnable(isOpen:Bool,success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x04,0x01,isOpen ? 0x01:0x00]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxBtRadioEnable = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - APP绑定
    @objc public func setZycxBindState(isBind:Bool,success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x05,0x01,isBind ? 0x01:0x00]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxBindState = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 设备数据清除(设备不重启)
    @objc public func setZycxClearData(_ success:@escaping((_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x06]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxClearData = success
            }else{
                success(error)
            }
        }
    }

    // MARK: - 4.8.状态查询(连接仓的设备主动)
    /*
     
     4.8.状态查询(连接仓的设备主动)
     消息ID：0x07(发送)
     起始字节    字段    数据类型    描述及要求
     0    状态查询ID    BYTE    详见”状态查询说明(连接仓的设备主动)”

     状态查询说明(连接仓的设备主动)
     状态查询ID    状态主动上报长度    状态主动上报内容
     0x00    BYTE    电量范围:(0%~100%)，0代表0%；
     0x01    BYTE    耳机连接状态 0：断开 1：打开
     0x02    BYTE    仓盖状态 0：关闭 1：打开
     0x03    BYTE    仓BT可连接状态，0：不可连接，1：可连接
     
     消息ID：0x87(发送)
     起始字节    字段    数据类型    描述及要求
     0    状态ID    BYTE    详见”状态查询说明(连接仓的设备主动)”
     1    状态长度    BYTE[n]
     1+n    状态内容    BYTE[n]
     
     */
    // MARK: - 电量获取
    @objc public func getZycxBattery(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x07
        ]
        
        let contentVal:[UInt8] = [0x00]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxBattery = success
            }else{
                success(0,error)
            }
        }
    }
    
    func parseGetZycxBattery(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let battery = val[0]
            success(Int(battery),.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalChargingBoxSemaphore()
    }
    
    // MARK: - 耳机连接状态
    @objc public func getZycxHeadphoneConnectState(_ success:@escaping((_ value:Bool,_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x07
        ]
        
        let contentVal:[UInt8] = [0x01]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxHeadphoneConnectState = success
            }else{
                success(false,error)
            }
        }
    }
    
    func parseGetZycxHeadphoneConnectState(val:[UInt8],success:@escaping((_ value:Bool,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let state = val[0] == 0 ? false:true
            success(state,.none)
        }else{
            success(false,.invalidLength)
        }
        self.signalChargingBoxSemaphore()
    }
    
    // MARK: - 仓盖状态
    @objc public func getZycxBoxCoverState(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x07
        ]
        
        let contentVal:[UInt8] = [0x02]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxBoxCoverState = success
            }else{
                success(0,error)
            }
        }
    }
    
    func parseGetZycxBoxCoverState(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let state = val[0]
            success(Int(state),.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalChargingBoxSemaphore()
    }
    
    // MARK: - 仓BT可连接状态
    @objc public func getZycxBoxBtConnectStatus(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xac,
            0x07
        ]
        
        let contentVal:[UInt8] = [0x03]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxBoxBtConnectStatus = success
            }else{
                success(0,error)
            }
        }
    }
    func parseGetZycxBoxBtConnectStatus(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let state = val[0]
            success(Int(state),.none)
        }else{
            success(0,.invalidLength)
        }
        self.signalChargingBoxSemaphore()
    }
    
    // MARK: - 电量上报
    @objc public func reportZycxBattery(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxBattery = success
    }
    
    func parseReportZycxBattery(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let battery = val[0]
            success(Int(battery),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 天气单位上报
    @objc public func reportZycxWeatherUnit(_ success:@escaping((_ value:Bool,_ error:ZywlError)->Void)){
        self.receiveReportZycxWeatherUnit = success
    }
    
    func parseReportZycxWeatherUnit(val:[UInt8],success:@escaping((_ value:Bool,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let result = val[0] == 0 ? false:true
            success(result,.none)
        }else{
            success(false,.invalidLength)
        }
    }
    
    // MARK: - 屏幕亮度上报
    @objc public func reportZycxScreenLightLevel(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxScreenLightLevel = success
    }
    
    func parseReportZycxScreenLightLevel(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let level = val[0]
            success(Int(level),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 亮屏时间上报
    @objc public func reportZycxScreenLightTimeLong(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxScreenLightTimeLong = success
    }
    
    func parseReportZycxScreenLightTimeLong(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let timeLong = val[0]
            success(Int(timeLong),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 本地表盘上报
    @objc public func reportZycxLocalDialIndex(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxLocalDialIndex = success
    }
    
    func parseReportZycxLocalDialIndex(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let index = val[0]
            success(Int(index),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 语言类型上报
    @objc public func reportZycxLanguageIndex(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxLanguageIndex = success
    }
    
    func parseReportZycxLanguageIndex(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let index = val[0]
            success(Int(index),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 摇一摇切歌模式上报
    @objc public func reportZycxShakeSong(_ success:@escaping((_ value:Bool,_ error:ZywlError)->Void)){
        self.receiveReportZycxShakeSong = success
    }
    
    func parseReportZycxShakeSong(val:[UInt8],success:@escaping((_ value:Bool,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let result = val[0] == 0 ? false:true
            success(result,.none)
        }else{
            success(false,.invalidLength)
        }
    }
    
    // MARK: - 耳机连接状态上报
    @objc public func reportZycxHeadphoneConnectState(_ success:@escaping((_ value:Bool,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneConnectState = success
    }
    
    func parseReportZycxHeadphoneConnectState(val:[UInt8],success:@escaping((_ value:Bool,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let result = val[0] == 0 ? false:true
            success(result,.none)
        }else{
            success(false,.invalidLength)
        }
    }
    // MARK: - 仓盖装给他上报
    @objc public func reportZycxBoxCoverState(_ success:@escaping((_ value:Bool,_ error:ZywlError)->Void)){
        self.receiveReportZycxBoxCoverState = success
    }
    
    func parseReportZycxBoxCoverState(val:[UInt8],success:@escaping((_ value:Bool,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let result = val[0] == 0 ? false:true
            success(result,.none)
        }else{
            success(false,.invalidLength)
        }
    }
    
    // MARK: - 拍照模式上报
    @objc public func reportZycxEnterOrExitCameraMode(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxEnterOrExitCameraMode = success
    }
    
    func parseReportZycxEnterOrExitCameraMode(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let result = Int(val[0])
            success(result,.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 设备控制
    /*
     消息ID：0x89(发送)
     起始字节    字段    数据类型    描述及要求
     0    设备控制ID    BYTE    详见“设备控制ID说明(仓主动)”
     1    设备控制长度    BYTE[n]
     1+n    设备控制内容    BYTE[n]

     设备控制ID说明(仓主动)
     设备控制ID    设备控制长度    设备控制内容
     0x00    BYTE    来电控制，0: 挂断、1：接听
     0x01    BYTE[2]    音乐控制，参数值如下：
     0 :开始    byte[0]:0、byte[1]:0(预留)
     1 :暂停    byte[0]:1、byte[1]:0(预留)
     2 :下一首  byte[0]:2、byte[1]:0(预留)
     3 :上一首  byte[0]:3、byte[1]:0(预留)
     4 :音量    byte[0]:4、byte[1]:(范围:0%~100%)，0代表0%
     0x02    BYTE    查找仓的设备
     0：关闭，1：开启
     */
    // MARK: - 来电控制，0: 挂断、1：接听
    @objc public func reportZycxCallControl(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxCallControl = success
    }
    
    func parseReportZycxCallControl(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let result = val[0]
            success(Int(result),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 音乐控制 0 :开始 1 :暂停 2 :下一首 3 :上一首 4 :音量
    @objc public func reportZycxMusicControl(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxMusicControl = success
    }
    
    func parseReportZycxMusicControl(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let result = val[0]
            success(Int(result),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 查找仓的设备 0：关闭 1：开启
    @objc public func reportZycxFindChargingBox(_ success:@escaping((_ value:Bool,_ error:ZywlError)->Void)){
        self.receiveReportZycxFindChargingBox = success
    }
    
    func parseReportZycxFindChargingBox(val:[UInt8],success:@escaping((_ value:Bool,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let result = val[0] == 0 ? false:true
            success(result,.none)
        }else{
            success(false,.invalidLength)
        }
    }
    
    // MARK: - 拍照
    @objc public func reportZycxTakePhoto(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxTakePhoto = success
    }
    
    func parseReportZycxTakePhoto(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        success(0,.none)
//        if val.count > 0 {
//            let result = Int(val[0])
//            success(result,.none)
//        }else{
//            success(0,.invalidLength)
//        }
    }
    
    // MARK: - 状态查询(仓主动)
    /*
     消息ID：0x0A(发送)
     起始字节    字段    数据类型    描述及要求
     0    状态查询ID    BYTE    详见”状态查询说明(仓主动)”

     状态查询说明(仓主动)
     状态查询ID    状态主动上报长度    状态主动上报内容
     0x00       BYTE[2]     音乐状态
                            BYTE[0]，播放状态：0 :开始、1 :暂停
                            BYTE[1]，音量：0~100%

     消息ID：0x8A(发送)
     起始字节    字段    数据类型    描述及要求
     0    状态ID    BYTE    详见”状态查询说明表”
     1    状态长度    BYTE[n]
     1+n    状态内容    BYTE[n]
     */
    // MARK: - 上报音乐状态
    @objc public func reportZycxMusicState(_ success:@escaping((_ state:Int,_ vioceVoolume:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxMusicState = success
    }
    
    func parseReportZycxMusicState(val:[UInt8],success:@escaping((_ state:Int,_ vioceVoolume:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let state = val[0]
            let vioceVoolume = val[1]
            success(Int(state),Int(vioceVoolume),.none)
        }else{
            success(0,0,.invalidLength)
        }
    }
    
    // MARK: - 设置音乐状态
    @objc public func setZycxMusicState(_ state:Int,vioceVoolume:Int) {
        let headVal:[UInt8] = [
            0xac,
            0x0b
        ]
        
        let contentVal:[UInt8] = [0x00,0x02,UInt8(state),UInt8(vioceVoolume)]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.signalChargingBoxSemaphore()
            }
        }
    }
    
    // MARK: - 设置通话状态
    @objc public func setZycxCallState(_ state:Int) {
        let headVal:[UInt8] = [
            0xac,
            0x0b
        ]
        
        let contentVal:[UInt8] = [0x01,0x01,UInt8(state)]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.signalChargingBoxSemaphore()
            }
        }
    }
    
    // MARK: - 设置进入或退出拍照模式
    @objc public func setZycxEnterOrExitCameraMode(_ state:Int) {
        let headVal:[UInt8] = [
            0xac,
            0x0b
        ]
        
        let contentVal:[UInt8] = [0x02,0x01,UInt8(state)]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.signalChargingBoxSemaphore()
            }
        }
    }
    
    // MARK: - 设置手机类型   不管设备回复
    @objc public func setZycxPhoneType() {
        let headVal:[UInt8] = [
            0xac,
            0x0b
        ]
        
        let contentVal:[UInt8] = [0x03,0x01,0x01]
        
        self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.signalChargingBoxSemaphore()
            }
        }
    }
    
    /*
     4.15.升级

     消息ID：0x7F(发送)
     起始字节    字段    数据类型    描述及要求
     0    子消息ID    BYTE
     1    数据    BYTE[n]

     子消息ID：0x00(启动升级)(发送)
     起始字节    字段    数据类型    描述及要求
     0      文件类型    BYTE      0-引导文件
                                1-应用文件
                                2-图库文件
                                3-字库文件
                                4-云端表盘文件
                                5-壁纸表盘文件
     1      文件长度    DWORD
     5      单包最大字节数    WORD

     子消息ID：0x01(停止升级)(发送)
     起始字节    字段    数据类型    描述及要求
     0          /       /       无数据内容

     子消息ID：0x02(升级数据)(发送)
     起始字节    字段    数据类型    描述及要求
     0    包号    DWORD       包号从0x00开始；
                            单包最大长度仅指数据部分长度，不包含包号；
                            设备回复
                            设备无需对此指令进行应答；
     4    数据    BYTE[n]

     子消息ID：0x03(组校验)(发送)
     起始字节    字段    数据类型    描述及要求
     0          /       /       无数据内容

     子消息ID：0x04(升级结果通知)(发送)
     起始字节    字段    数据类型    描述及要求
     0          /       /       无数据内容

     子消息ID：0x05(升级状态)(发送)
     起始字节    字段    数据类型    描述及要求
     0          /       /        无数据内容

     消息ID：0xF9(应答)
     起始字节    字段    数据类型    描述及要求
     0          子消息ID    BYTE
     n          数据      BYTE[n]

     子消息ID：0x80(启动升级)(应答)
     起始字节    字段    数据类型    描述及要求
     0         操作结果    BYTE    0x00:成功；0x01-文件类型不支持；0x02-文件大小过大；0x03-其他
                                操作结果不为0x00，代表升级异常；
                                操作结果不为0x00则不包含“单包最大字节数+每组包数+组校验应答超时时间”；
                                最终单包字节数：取APP与设备单包最大字节数二者的最小值；
                                每组包数：代表APP每次发送“升级数据”的包的数量；APP在发送“升级数据”包达到每组包数后发送“组校验”命令，APP根据设备应答的“组校验”数据判断是否是否需要重传，只有设备应答的“组校验”数据提示完成接收后才允许发送下一组数据；文件末尾最后一组包数可能达不到每组包数，此时按实际有几包则发送几包，在发完之后发送“组校验”命令；
                                例如：“每组包数”为10包，则发送10包“升级数据”后发送“组校验”命令；只有设备应答接收完成后才允许下发新的一组，否则根据设备应答的“组校验”完成数据重发；
                                组校验应答超时时间：单位(s)；用于超时判断，如果设备超过此时间未应答则代表升级异常；
     1      单包最大字节数    WORD    注:操作结果仅为0x00则包含此字段，否则不包含；
     3      每组包数    WORD    注:操作结果仅为0x00则包含此字段，否则不包含；
     5      组校验应答超时时间    WORD    注:操作结果仅为0x00则包含此字段，否则不包含；

     子消息ID：0x81(停止升级)(应答)
     起始字节    字段    数据类型    描述及要求
     0          操作结果    BYTE    0x00:成功；0x01-无升级过程；

     子消息ID：0x82(升级数据)(应答)
     注：为了加快传输速度，不进行应答，也就是不发次指令；
     起始字节    字段    数据类型    描述及要求
     0          /       /       无数据内容

     子消息ID：0x83(组校验)(发送)
     起始字节    字段    数据类型    描述及要求
     0          操作结果    BYTE    操作结果：(0x00:成功；0x01-升级完成 0x02-超过最大次数；0x03-无升级过程；0x04-其他；0x05-存在重传数据；）；
                                    操作结果为0x00~0x04则不包含”重传包总数+重传包列表”；
                                    操作结果为0x00代表该组数据已接收完成，可以继续下发下一组数据；
                                    操作结果为0x01~0x04代表该数据存在异常，已无法继续升级；APP收到该状态则认为此次升级异常；
                                    操作结果为0x05代表还存在重传的数据，如果重传信息大于数据最大长度，设备将按数据最大长度逐步发送重传信息；
                                    重传包总数为多少则代表重传包列表就多少项；例如：重传包总数为3，则之后就包含3个重传包，例如：重传包0、重传包5、重传包8；
     1          重传包总数    DWORD    注:操作结果仅为0x05则包含此字段，否则不包含；
     5          重传包列表    BYTE[n]    注:操作结果仅为0x05则包含此字段，否则不包含；

     子消息ID：0x84(升级结果通知)(发送)
     起始字节    字段    数据类型    描述及要求
     0    操作结果    BYTE    0x00:成功，0x01：失败
     1    文件类型    BYTE
     2    文件长度    DWORD

     子消息ID：0x85(升级状态)(发送)
     起始字节    字段    数据类型    描述及要求
     0      升级状态    BYTE    （0x00-无升级过程； 0x01-升级中；）当为0x00时则设备采用“设备回复（0）”格式进行回复；否则设备采用“设备回复（1）”格式进行回复；
                                包号：该包之前数据已完成下载，从该包号开始发送数据；文件偏移 = 单包最大字节数 * 包号；
     1    文件类型    BYTE      注:升级状态仅为0x01则包含此字段，否则不包含；
                                具体内容如上；
     2    文件长度    DWORD     注:升级状态仅为0x01则包含此字段，否则不包含；
     6    单包最大字节数    WORD    注:升级状态仅为0x01则包含此字段，否则不包含；
     8    每组包数    WORD    注:升级状态仅为0x01则包含此字段，否则不包含；
     10    组校验应答超时时间    WORD    注:升级状态仅为0x01则包含此字段，否则不包含；
     12    包号    DWORD    注:升级状态仅为0x01则包含此字段，否则不包含；
    */
    // MARK: - ota升级
    @objc public func setOtaStartUpgrade(type:Int,localFile:Any,isContinue:Bool,progress:@escaping((Float) -> Void),success:@escaping((ZywlError) -> Void)) {
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
                    self.getZycxSubcontractingInfomation { maxCount, error in
                        if error == .none {
                            if maxCount > 20 {
                                self.maxMtuCount = maxCount
                                self.setStartUpgrade(type: type, localFile: localFile, maxCount: maxCount,isContinue: false, progress: progress, success: success)
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
    }
    
    // MARK: - 开始升级
    @objc public func setStartUpgrade(type:Int,localFile:Any,maxCount:Int,isContinue:Bool,progress:@escaping((Float) -> Void),success:@escaping((ZywlError) -> Void)) {
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
            self.receiveSetZycxStartUpgradeBlock = success
            self.receiveSetZycxStartUpgradeProgressBlock = progress
            
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
            
            var headVal:[UInt8] = [
                0xac,
                0x7f,
            ]
            
            let contentVal:[UInt8] = [0x00,
                                      UInt8(type),
                                      UInt8((fileLength >> 24) & 0xff),
                                      UInt8((fileLength >> 16) & 0xff),
                                      UInt8((fileLength >> 8) & 0xff),
                                      UInt8((fileLength ) & 0xff),
                                      UInt8((self.maxMtuCount >> 8) & 0xff),
                                      UInt8((self.maxMtuCount ) & 0xff),
                                      ]
            headVal.append(UInt8((contentVal.count >> 8) & 0xff))
            headVal.append(UInt8((contentVal.count ) & 0xff))

            var val = headVal + contentVal
            let check = CRC16(val: val)
            let checkVal = [UInt8((check >> 8) & 0xff),UInt8((check ) & 0xff)]
            val += checkVal
            
            let data = Data.init(bytes: &val, count: val.count)
            self.writeChargingBoxData(data: data)
            self.receiveSetZycxStartUpgradeBlock = success
            self.receiveSetZycxStartUpgradeProgressBlock = progress
            self.otaData = fileData!
            printLog("正常进入升级")
        }
        
    }
    
    private func parseSetStartUpgradeData(val:[UInt8],progress:@escaping((Float) -> Void),success:@escaping((ZywlError) -> Void)) {
        
        if val.count > 0 {
            
            let result = val[0]
            printLog("result =",result)
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%d", result))

            if result == 0 {
                let maxSingleCount = (Int(val[1]) << 8 | Int(val[2]) )
                let packageCount = (Int(val[3]) << 8 | Int(val[4]) )
                
                self.otaMaxSingleCount = maxSingleCount
                self.otaPackageCount = packageCount
                
                let otaVal = self.otaData!.withUnsafeBytes{ (byte) -> [UInt8] in
                    let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: self.otaData!.count))
                }
                //只要是有过升级，就需要重新获取固件的升级版本信息。此处把之前获取的清除掉
//                self.otaVersionInfo = nil
//                self.receiveGetDeviceOtaVersionInfo = nil
                self.dealUpgradeData(maxSingleCount: maxSingleCount, packageCount: packageCount, packageIndex: 0, val: otaVal,progress: progress, success: success)
            }else{
                success(.fail)
            }
            
        }else{
            success(.invalidState)
        }
    }
    
    private func dealUpgradeData(maxSingleCount:Int,packageCount:Int,packageIndex:Int,val:[UInt8],progress:@escaping((Float) -> Void),success:@escaping((ZywlError) -> Void)) {
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
            
            var headData:[UInt8] = [
                0xac,
                0x7f,
            ]
            
            let contentData:[UInt8] = [0x02,
                                      UInt8((sendPackageIndex >> 24) & 0xff),
                                      UInt8((sendPackageIndex >> 16) & 0xff),
                                      UInt8((sendPackageIndex >> 8) & 0xff),
                                      UInt8(sendPackageIndex & 0xff)] + Array.init(sendVal[index..<(endIndex)])
            headData.append(UInt8((contentData.count >> 8) & 0xff))
            headData.append(UInt8((contentData.count ) & 0xff))
            var send = headData + contentData
            let check = CRC16(val: send)
            send.append(UInt8((check ) & 0xff))
            send.append(UInt8((check >> 8) & 0xff))
            
            let data = Data.init(bytes: &send, count: send.count)
            self.writeChargingBoxData(data: data)
        }
        
        //组校验
        var checkVal:[UInt8] = [
            0xac,
            0x7f,
        ]
        
        checkVal.append(UInt8((1 >> 8) & 0xff))
        checkVal.append(UInt8((1 ) & 0xff))
        checkVal.append(0x03)
        
        let check = CRC16(val: checkVal)
        checkVal.append(UInt8((check ) & 0xff))
        checkVal.append(UInt8((check >> 8) & 0xff))
        
        let data = Data.init(bytes: &checkVal, count: checkVal.count)
        self.writeChargingBoxData(data: data)
        
        progress(Float(totalLength)/Float(val.count) * 100.0)
        printLog("当前数据组结束序号 ->",totalLength)
        ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "当前数据组结束序号 ->:%d", totalLength))
    }
    
    // MARK: - 重发包号数据
    private func resendUpgradeData(maxSingleCount:Int,packageCount:Int,resendVal:[UInt8],val:[UInt8],progress:@escaping((Float) -> Void),success:@escaping((ZywlError) -> Void)) {
        
        //重传总包数
        let resendTotalCount = (Int(resendVal[1]) << 24 | Int(resendVal[2]) << 16 | Int(resendVal[3]) << 8 | Int(resendVal[4]))
                
        for i in stride(from: 0, to: resendTotalCount, by: 1) {
            
            //重传包序号
            let resendIndex = (Int(resendVal[5+i*4]) << 24 | Int(resendVal[6+i*4]) << 16 | Int(resendVal[7+i*4]) << 8 | Int(resendVal[8+i*4]) )
            printLog("重传包序号 =",resendIndex)
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "重传包序号 ->:%d", resendIndex))
            
            //取开始跟结束的index
            let startIndex = resendIndex*maxSingleCount
            let endIndex = ((resendIndex+1)*maxSingleCount) > val.count ? (val.count-((resendIndex)*maxSingleCount)+resendIndex*maxSingleCount) : ((resendIndex+1)*maxSingleCount)
            printLog("startIndex =",startIndex,"endIndex =",endIndex)
            
            var headData:[UInt8] = [
                0xac,
                0x7f,
            ]
            
            let contentData:[UInt8] = [0x02,
                                      UInt8((resendIndex >> 24) & 0xff),
                                      UInt8((resendIndex >> 16) & 0xff),
                                      UInt8((resendIndex >> 8) & 0xff),
                                      UInt8(resendIndex & 0xff)] + Array.init(val[startIndex..<(endIndex)])
            headData.append(UInt8((contentData.count >> 8) & 0xff))
            headData.append(UInt8((contentData.count ) & 0xff))
            var send = headData + contentData
            let check = CRC16(val: send)
            send.append(UInt8((check ) & 0xff))
            send.append(UInt8((check >> 8) & 0xff))
            
            let data = Data.init(bytes: &send, count: send.count)
            self.writeChargingBoxData(data: data)
        }
        
        //组校验
        var checkVal:[UInt8] = [
            0xac,
            0x7f,
        ]
        
        let contentVal:[UInt8] = [0x03]
        checkVal.append(UInt8((contentVal.count >> 8) & 0xff))
        checkVal.append(UInt8((contentVal.count ) & 0xff))
        checkVal.append(contentsOf: contentVal)
        
        let check = CRC16(val: checkVal)
        checkVal.append(UInt8((check ) & 0xff))
        checkVal.append(UInt8((check >> 8) & 0xff))
        
        let data = Data.init(bytes: &checkVal, count: checkVal.count)
        self.writeChargingBoxData(data: data)
            
    }
    
    // MARK: - 停止升级
    @objc public func setStopUpgrade(success:@escaping((ZywlError) -> Void)) {
        
        var headVal:[UInt8] = [
            0xac,
            0x7f,
        ]
        
        let contentVal:[UInt8] = [0x01]
        headVal.append(UInt8((contentVal.count >> 8) & 0xff))
        headVal.append(UInt8((contentVal.count ) & 0xff))
        
        var val = headVal + contentVal
        let check = CRC16(val: val)
        let checkVal = [UInt8((check >> 8) & 0xff),UInt8((check ) & 0xff)]
        val += checkVal
        
        let data = Data.init(bytes: &val, count: val.count)
        self.writeChargingBoxData(data: data)
        self.receiveSetZycxStopUpgradeBlock = success
        printLog("停止升级")
    }
    
    private func parseSetStopUpgradeData(val:[UInt8],success:@escaping((ZywlError) -> Void)) {
        
        if val.count > 0 {
                        
            let result = val[0]
            printLog("result =",result)
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%d", result))
            
            success(.none)
            
        }else{
            success(.invalidState)
        }
    }
    
    // MARK: - 升级结果
    private func parseGetUpgradeResultData(val:[UInt8],success:@escaping((ZywlError) -> Void)) {
        
        if val.count > 0 {

            let result = val[0]
            printLog("result =",result)
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%d", result))
            let type = val[1]
            let fileLength = (Int(val[2]) << 24 | Int(val[3]) << 16 | Int(val[4]) << 8 | Int(val[5]))
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
    
    @objc public func checkUpgradeState(success:@escaping(([String:Any],ZywlError) -> Void)) {
        var val:[UInt8] = [
            0xac,
            0x7f,
        ]
        
        let contentVal:[UInt8] = [0x05]
        val.append(UInt8((contentVal.count >> 8) & 0xff))
        val.append(UInt8((contentVal.count ) & 0xff))
        val += contentVal
        let check = CRC16(val: val)
        val.append(UInt8((check >> 8) & 0xff))
        val.append(UInt8((check) & 0xff))
        
        let data = Data.init(bytes: &val, count: val.count)
        self.writeChargingBoxData(data: data)
        self.receiveCheckUpgradeStateBlock = success
        
    }
    
    // MARK: - 设置自定义表盘图片
    @objc public func setZycxCustomDial(image:UIImage,progress:@escaping((Float) -> Void),success:@escaping((ZywlError) -> Void)) {
        
        if let customDialModel = self.chargingBoxFunctionListModel?.functionDetail_customDial?.dialSize {
            let bigWidth = customDialModel.bigWidth
            let bigheight = customDialModel.bigHeight
            let smallWidth = customDialModel.smallWidth
            let smallHeight = customDialModel.smallHeight
            
            if CGFloat(bigWidth) == image.size.width && CGFloat(bigheight) == image.size.height {
                
                var sendData:Data = self.createSendDialOtaFile(image: image)
                if let model = self.chargingBoxFunctionListModel?.functionDetail_platformType {
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
            }

        }else{
            if let customDialModel = self.zycxDeviceInfoModel {
                let bigWidth = customDialModel.dialSize.bigWidth
                let bigheight = customDialModel.dialSize.bigHeight
                let smallWidth = customDialModel.dialSize.smallWidth
                let smallHeight = customDialModel.dialSize.smallHeight
                
                if CGFloat(bigWidth) == image.size.width && CGFloat(bigheight) == image.size.height {
                    
                    var sendData:Data = self.createSendDialOtaFile(image: image)
                    if let model = self.chargingBoxFunctionListModel?.functionDetail_platformType {
                        if model.platform == 1 {
                            sendData = self.createSendJLdeviceDialOtaFile(image: image)
                        }else{
                            sendData = self.createSendDialOtaFile(image: image)
                        }
                    }else{
                        sendData = self.createSendDialOtaFile(image: image)
                    }
                    
                    printLog("sendData.count =",sendData.count)
                    self.setOtaStartUpgrade(type: 5, localFile: sendData, isContinue: false, progress: progress, success: success)
                }
            }else{
                printLog("图片尺寸跟设备尺寸不一致。请检查图片是否正确 image.size =",image.size)
                success(.fail)
            }
        }
    }
    
    // MARK: - 设置本地音乐文件
    @objc public func setZycxLocalMusicFile(_ fileNmae:String, localFile:Any,progress:@escaping((Float) -> Void),success:@escaping((ZywlError) -> Void)) {
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
        let fileLength = [UInt8(fileData.count & 0xff),UInt8((fileData.count >> 8) & 0xff),UInt8((fileData.count >> 16) & 0xff),UInt8((fileData.count  >> 24) & 0xff)]
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
        print("totalData = \(self.convertDataToHexStr(data: Data.init(bytes: &headArray, count: headArray.count)))")
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
        
        let oldCount = ZywlCommandModule.shareInstance.CRC32(data: data)
        let newCount = ZywlCommandModule.shareInstance.CRC32(data: data)
        
        //固定数据  0xAA,0x55,0x01,0x05
        let otaHead:[UInt8] = [0xAA,0x55,0x01,UInt8(type)]
        //日期/时间  6字节；格式YY-MM-DD HH:MM:SS(BCD码)
        let time:[UInt8] = [UInt8(self.decimalToBcd(value: year-2000)),UInt8(self.decimalToBcd(value: month)),UInt8(self.decimalToBcd(value: day)),UInt8(self.decimalToBcd(value: hour)),UInt8(self.decimalToBcd(value: minute)),UInt8(self.decimalToBcd(value: second))]
        //压缩方式  1字节；0-无压缩 1-fastlz
        let type:UInt8 = 0
        //文件长度    4字节；未经过处理的原始文件长度
        let fileLength_old = [UInt8((data.count) & 0xff),UInt8((data.count >> 8) & 0xff),UInt8((data.count >> 16) & 0xff),UInt8((data.count  >> 24) & 0xff)]
        //文件完整性校验    4字节；对整个原始文件进行校验；CRC-32 多项式：0x104C11DB7、初始值：0xFFFFFFFF、结果异或值：0xFFFFFFFF、输入反转：true、输出反转：true
        let fileCrc32_old = [UInt8((oldCount) & 0xff),UInt8((oldCount >> 8) & 0xff),UInt8((oldCount >> 16) & 0xff),UInt8((oldCount >> 24) & 0xff)]
        //文件长度    4字节；处理完之后的文件长度
        let fileLength_new = [UInt8((data.count) & 0xff),UInt8((data.count >> 8) & 0xff),UInt8((data.count >> 16) & 0xff),UInt8((data.count >> 24) & 0xff)]
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

        let headCrc32 = ZywlCommandModule.shareInstance.CRC32(val: otaFileHeadData)
        let fileCrc32 = [UInt8((headCrc32) & 0xff),UInt8((headCrc32 >> 8) & 0xff),UInt8((headCrc32 >> 16) & 0xff),UInt8((headCrc32 >> 24) & 0xff)]
        
        otaFileHeadData.append(contentsOf: fileCrc32)
        
        var finalData = Data.init(bytes: &otaFileHeadData, count: otaFileHeadData.count)
        print("otaFileHeadData = \(self.convertDataToHexStr(data: Data.init(bytes: &otaFileHeadData, count: otaFileHeadData.count)))")
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
        
        let oldCount = ZywlCommandModule.shareInstance.CRC32(data: data)
        let newCount = ZywlCommandModule.shareInstance.CRC32(data: data)
        
        //固定数据  0xAA,0x55,0x01,0x05
        let otaHead:[UInt8] = [0xAA,0x55,0x01,0x05]
        //日期/时间  6字节；格式YY-MM-DD HH:MM:SS(BCD码)
        let time:[UInt8] = [UInt8(year-2000),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)]
        //压缩方式  1字节；0-无压缩 1-fastlz
        let type:UInt8 = 0
        //文件长度    4字节；未经过处理的原始文件长度
        let fileLength_old = [UInt8((data.count) & 0xff),UInt8((data.count >> 8) & 0xff),UInt8((data.count >> 16) & 0xff),UInt8((data.count  >> 24) & 0xff)]
        //文件完整性校验    4字节；对整个原始文件进行校验；CRC-32 多项式：0x104C11DB7、初始值：0xFFFFFFFF、结果异或值：0xFFFFFFFF、输入反转：true、输出反转：true
        let fileCrc32_old = [UInt8((oldCount) & 0xff),UInt8((oldCount >> 8) & 0xff),UInt8((oldCount >> 16) & 0xff),UInt8((oldCount  >> 24) & 0xff)]
        //文件长度    4字节；处理完之后的文件长度
        let fileLength_new = [UInt8((data.count) & 0xff),UInt8((data.count >> 8) & 0xff),UInt8((data.count >> 16) & 0xff),UInt8((data.count >> 24) & 0xff)]
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
        
        let headCrc32 = ZywlCommandModule.shareInstance.CRC32(val: otaFileHeadData)
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
        
    func createSendJLdeviceDialOtaFile(image:UIImage) -> Data {
        
        var smallImage = image
        var bigImage = image
        if let customDialModel = self.chargingBoxFunctionListModel?.functionDetail_customDial?.dialSize {
            let smallWidth = customDialModel.smallWidth
            let smallHeight = customDialModel.smallHeight
            let bigWidth = customDialModel.bigWidth
            let bigHeight = customDialModel.bigHeight
            smallImage = image.changeSize(size: .init(width: smallWidth, height: smallHeight))
            bigImage = image.changeSize(size: .init(width: bigWidth, height: bigHeight))
        }else{
            if let customDialModel = self.zycxDeviceInfoModel {
                let smallWidth = customDialModel.dialSize.smallWidth
                let smallHeight = customDialModel.dialSize.smallHeight
                let bigWidth = customDialModel.dialSize.bigWidth
                let bigHeight = customDialModel.dialSize.bigHeight
                smallImage = image.changeSize(size: .init(width: smallWidth, height: smallHeight))
                bigImage = image.changeSize(size: .init(width: bigWidth, height: bigHeight))
            }
        }
        
        if let screenType = self.chargingBoxFunctionListModel?.functionDetail_screenType {
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
            if let customDialModel = self.chargingBoxFunctionListModel?.functionDetail_customDial?.dialSize {
                let bigWidth = customDialModel.bigWidth
                let bigheight = customDialModel.bigHeight
                let smallWidth = customDialModel.smallWidth
                let smallHeight = customDialModel.smallHeight
                let result = br28_btm_to_res_path_with_alpha(&input, Int32(bigWidth), Int32(bigheight),&output)
                print("result big = \(result)")
            }else{
                if let customDialModel = self.zycxDeviceInfoModel {
                    let smallWidth = customDialModel.dialSize.smallWidth
                    let smallHeight = customDialModel.dialSize.smallHeight
                    let bigWidth = customDialModel.dialSize.bigWidth
                    let bigHeight = customDialModel.dialSize.bigHeight
                    let result = br28_btm_to_res_path_with_alpha(&input, Int32(bigWidth), Int32(bigHeight),&output)
                    print("result big = \(result)")
                }
            }
        }
        if FileManager.createFile(filePath: smallBinPath).isSuccess {
            var input: [CChar] = smallBmpPath.cString(using: .utf8)!
            var output : [CChar] = smallBinPath.cString(using: .utf8)!
            if let customDialModel = self.chargingBoxFunctionListModel?.functionDetail_customDial?.dialSize {
                let bigWidth = customDialModel.bigWidth
                let bigheight = customDialModel.bigHeight
                let smallWidth = customDialModel.smallWidth
                let smallHeight = customDialModel.smallHeight
                let result = br28_btm_to_res_path_with_alpha(&input, Int32(smallWidth), Int32(smallHeight),&output)
                print("result small = \(result)")
            }else{
                if let customDialModel = self.zycxDeviceInfoModel {
                    let smallWidth = customDialModel.dialSize.smallWidth
                    let smallHeight = customDialModel.dialSize.smallHeight
                    let bigWidth = customDialModel.dialSize.bigWidth
                    let bigHeight = customDialModel.dialSize.bigHeight
                    let result = br28_btm_to_res_path_with_alpha(&input, Int32(smallWidth), Int32(smallHeight),&output)
                    print("result small = \(result)")
                }
            }
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
        
        let oldCount = ZywlCommandModule.shareInstance.CRC32(data: data)
        let newCount = ZywlCommandModule.shareInstance.CRC32(data: data)
        
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
        
        let headCrc32 = ZywlCommandModule.shareInstance.CRC32(val: otaFileHeadData)
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
        
        var smallImage = image
        var bigImage = image
        if let customDialModel = self.chargingBoxFunctionListModel?.functionDetail_customDial?.dialSize {
            let smallWidth = customDialModel.smallWidth
            let smallHeight = customDialModel.smallHeight
            let bigWidth = customDialModel.bigWidth
            let bigHeight = customDialModel.bigHeight
            smallImage = image.changeSize(size: .init(width: smallWidth, height: smallHeight))
            bigImage = image.changeSize(size: .init(width: bigWidth, height: bigHeight))
        }else{
            if let customDialModel = self.zycxDeviceInfoModel {
                let smallWidth = customDialModel.dialSize.smallWidth
                let smallHeight = customDialModel.dialSize.smallHeight
                let bigWidth = customDialModel.dialSize.bigWidth
                let bigHeight = customDialModel.dialSize.bigHeight
                smallImage = image.changeSize(size: .init(width: smallWidth, height: smallHeight))
                bigImage = image.changeSize(size: .init(width: bigWidth, height: bigHeight))
            }
        }
//        if FileManager.createFile(filePath: smallImagePath).isSuccess {
//            FileManager.default.createFile(atPath: smallImagePath, contents: smallImage.pngData(), attributes: nil)
//        }
//        smallImage = smallImage.addCornerRadius(radiusWidth: 20)
//        smallImage = smallImage.addShadowLayer(shadowWidth: 15)
//        if FileManager.createFile(filePath: smallImageShadowPath).isSuccess {
//            FileManager.default.createFile(atPath: smallImageShadowPath, contents: smallImage.pngData(), attributes: nil)
//        }
//        if FileManager.createFile(filePath: bigImagePath).isSuccess {
//            FileManager.default.createFile(atPath: bigImagePath, contents: bigImage.pngData(), attributes: nil)
//        }
        if let screenType = self.chargingBoxFunctionListModel?.functionDetail_screenType {
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
        var width:[UInt8] = [UInt8((285) & 0xff),UInt8((285 >> 8) & 0xff)]
        //图片高度    2字节，小端
        var height:[UInt8] = [UInt8((240) & 0xff),UInt8((240 >> 8) & 0xff)]
        if let customDialModel = self.chargingBoxFunctionListModel?.functionDetail_customDial?.dialSize {
            let bigWidth = customDialModel.bigWidth
            let bigheight = customDialModel.bigHeight
            width = [UInt8((bigWidth) & 0xff),UInt8((bigWidth >> 8) & 0xff)]
            height = [UInt8((bigheight) & 0xff),UInt8((bigheight >> 8) & 0xff)]
        }
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
    
    // MARK: - 耳机功能
    // MARK: - 同步分包信息交互(主动)
    /*
     4.1.同步分包信息交互(设备主动)
     消息ID：0x00(发送)
     起始字节           字段              数据类型            描述及要求
     0                单包最大发送长度     WORD             注：需要先确定单包最大发送长度后再进行其他操作
                                                            使用最小长度做发送分包

     消息ID：0x80(应答)
     起始字节           字段              数据类型            描述及要求
     0                单包最大发送长度     BYTE
     
     */
    @objc public func getHeadphonePhoneMaxMtu() -> Int {
        let maxLength = self.headphonePeripheral?.maximumWriteValueLength(for: ((self.headphoneWriteCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse) ?? 20
        ZywlSDKLog.writeStringToSDKLog(string: "maxWriteValueLength:\(maxLength)")
        return maxLength
    }
    @objc public func getZycxHeadphoneSubcontractingInfomation(maxValue:Int = 0,_ success:@escaping((_ count:Int, _ error:ZywlError)->Void)) {
        
        let headVal:[UInt8] = [
            0xc0,
            0x00
        ]
        let mtu = self.headphonePeripheral?.maximumWriteValueLength(for: ((self.headphoneWriteCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse) ?? 1024
        let maxLength = maxValue > 0 ? maxValue : mtu
        
        print("最大写入长度 maxLength = \(maxLength)")
        let contentVal:[UInt8] = [UInt8(((maxLength) >> 8) & 0xff),UInt8((maxLength) & 0xff)]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxHeadphoneSubcontractingInfomation = success
            }else{
                success(0,error)
            }
        }
    }
    
    func parseGetZycxHeadphoneSubcontractingInfomation(val:[UInt8],success:@escaping((_ count:Int, _ error:ZywlError)->Void)) {
        
        if val.count == 2 {
            
            let count = (Int(val[0]) << 8 | Int(val[1]))
            self.maxHeadphoneMtuCount = count
            let string = String.init(format: "%d",count)
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "解析 最大写入长度:%@",string))
            success(Int(count),.none)
            
        }else{
            success(0,.invalidState)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    /*
     
     4.2.同步分包信息交互(耳机主动)
     消息ID：0x81(发送)
     起始字节    字段    数据类型    描述及要求
     0    单包最大发送长度    WORD    使用最小长度做发送分包

     消息ID：0x01(应答)
     起始字节    字段    数据类型    描述及要求
     0    单包最大发送长度    BYTE
     
     */
    @objc public func reportZycxHeadphoneSubcontractingInfomation(_ success:@escaping((_ count:Int ,_ error:ZywlError)->Void)) {
        
        self.receiveReportZycxHeadphoneSubcontractingInfomation = success
        
    }
    
    func parseReportZycxHeadphoneSubcontractingInfomation(val:[UInt8],success:@escaping((_ count:Int, _ error:ZywlError)->Void)) {
        
        if val.count == 2 {
            
            let count = (Int(val[0]) << 8 | Int(val[1]) )
            self.maxHeadphoneMtuCount = count
            let string = String.init(format: "%d",count)
            ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
            success(Int(count),.none)
            
        }else{
            success(0,.invalidState)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 查询设备功能列表
    /*
     消息 ID：0x02(发送)
     消息体为空；
     
     消息 ID：0x82(应答)
     起始字节 字段 数据类型 描述及要求
     0 功能列表数据长度 BYTE 该长度仅代表“功能列表数据”的长度；
     1 功能列表数据 BYTE[n] 每个功能采用 1 个 BIT 代表；BIT0 代表第一字节第0位；BIT15，代表第二节第 7 位；
     1+n 功能列表详细数据总数 BYTE 可选项；某些功能列表数据存在更详细的数据，则存在该项，否则不包含此项及以下项；总数多少则包含多少个功能列表详细数据，例如：2，则有 2 个功能列表详细数据；
     2+n 功能列表详细数据列表 BYTE[n] 详见“功能列表详细数据说明”
     
     功能列表详细数据说明
     起始字节 字段 数据类型 描述及要求
     0 功能列表详细数据ID BYTE
     2 功能列表详细数据长度 BYTE
     3 功能列表详细数据内容 BYTE[n]
     
     功能列表数据：
     Bit0 拍照控制
     Bit1 音乐控制
     Bit2 查找设备
     Bit3 关机控制
     Bit4 重启控制
     Bit5 恢复出厂控制
     Bit6 挂断电话
     Bit7 接听电话
     Bit8 支持 EQ 模式
     Bit9 支持自定义 EQ 音效
     Bit10 环境音设置
     Bit11 空间音效设置
     Bit12 入耳感知播放
     Bit13 极速模式
     Bit14 抗风噪模式
     Bit15 低音增强模式
     Bit16 低频增强模式
     Bit17 对联模式
     Bit18 桌面模式
     Bit19 摇一摇切歌模式
     Bit20 设备类型
     Bit21 自定义按键
     */
    @objc public func getZycxHeadphoneFunctionList(isForwardingData:Bool = false, success:@escaping((ZycxHeadphoneFunctionListModel?,ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x02
            ]
            
            let contentVal:[UInt8] = []
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneFunctionList = success
                }else{
                    success(nil,error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x02
        ]
        
        let contentVal:[UInt8] = []
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxHeadphoneFunctionList = success
            }else{
                success(nil,error)
            }
        }
        
    }
    
    func parseGetZycxHeadphoneFunctionList(val:[UInt8],success:@escaping((ZycxHeadphoneFunctionListModel?,ZywlError)->Void)) {
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }
        
        ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "parseGetZycxFunctionList待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))
        
        if val.count > 0 {
            //let val:[UInt8] = [0x03,0xc6,0x0B,0x30,0x04,0x00,0x04,0x00,0x00,0x86,0xB1,0x01,0x04,0x00,0x00,0x05,0xfe,0x03,0x01,0x05,0x07,0x18,0x0c,0x00,0x01,0x0a,0x00,0x1E,0x00,0x3e,0x00,0x7d,0x00,0xfa,0x01,0xf4,0x03,0xe8,0x07,0xd0,0x0f,0xa0,0x1f,0x40,0x3e,0x80]
            let model = ZycxHeadphoneFunctionListModel.init(val: val)
            self.headphonesFunctionListModel = model
            success(model,.none)
        }else{
            success(nil,.invalidLength)
        }
        
        //printLog("第\(#line)行" , "\(#function)")
        //self.signalCommandSemaphore()
        if self.isHeadphoneForwardingData {
            self.signalChargingBoxSemaphore()
        }else{
            self.isHeadphoneForwardingData = false
            self.signalCommandSemaphore()
        }
    }
    
    /*
     消息 ID：0x03(发送)
     起始字节 字段 数据类型 描述及要求
     0 设备信息 ID项总数   BYTE
     1 设备信息ID列表     BYTE[n] 设备信息ID顺序排列，如“设备信息ID1 设备信息ID2......设备信息 IDn”。
     
     消息 ID：0x83(应答)
     起始字节 字段 数据类型 描述及要求
     0 设备信息总数   BYTE 总数多少则包含多少个设备信息，例如：2，则有2 个设备信息；
     1 设备信息列表   BYTE[n] 详见”设备信息说明”
     
     设备信息说明
     起始字节 字段 数据类型 描述及要求
     0 设备信息ID BYTE 详见”设备信息 ID 说明”
     1 设备信息长度   BYTE
     2 设备信息内容   BYTE[n]
     
     设备信息 ID 说明
     设备信息ID 设备信息长度  设备信息内容
     0x00 STRING 设备名称
     0x01 BYTE[6] MAC 地址（BLE）
     0x02 STRING 序列号,AAA_AAA_AAAAAA
     0x03 STRING 硬件版本号
     0x04 STRING 软件版本号
     0x05 STRING 蓝牙名（BLE）
     0x06 BYTE[6] MAC 地址（BR/EDR）
     0x07 STRING 蓝牙名（BR/EDR）
     */
    // MARK: - 设备信息查询
    @objc public func getZycxHeadphoneDeviceInfomation(isForwardingData:Bool = false, success:@escaping((_ model:ZycxHeadphoneDeviceInfomationModel?,_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x03
            ]
            
            var contentVal:[UInt8] = [
                0x00,
                0x01,
                0x02,
                0x03,
                0x04,
                0x05,
                0x06,
                0x07,
            ]
            contentVal.insert(UInt8(contentVal.count), at: 0)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneDeviceInfomation = success
                }else{
                    success(nil,error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x03
        ]
        
        var contentVal:[UInt8] = [
            0x00,
            0x01,
            0x02,
            0x03,
            0x04,
            0x05,
            0x06,
            0x07,
        ]
        contentVal.insert(UInt8(contentVal.count), at: 0)
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxHeadphoneDeviceInfomation = success
            }else{
                success(nil,error)
            }
        }
    }
    
    func parseGetZycxHeadphoneDeviceInfomation(val:[UInt8],success:@escaping((_ model:ZycxHeadphoneDeviceInfomationModel?,_ error:ZywlError)->Void)) {
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }
        
        ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "parseGetZycxDeviceInfomation待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))

        var modelDic:[String:Any] = [:]
        let count:Int = Int(val[0])
        var index = 1
        for i in 0..<count {
            let functionId = val[index]
            let functionLength = val[index+1]
            let functionVal = Array.init(val[(index+2)..<(index+2+Int(functionLength))])
            
            if functionVal.count <= 0 {
                continue
            }
            let functionData = functionVal.withUnsafeBufferPointer({ (bytes) -> Data in
                let byte = bytes.baseAddress!
                return Data.init(bytes: byte, count: functionVal.count)
            })
            
            switch functionId {
            case 0:
                
                if let nameString = String.init(data: functionData, encoding: .utf8) {
                    modelDic["deviceName"] = nameString
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "deviceName = %@",nameString))
                }
                break
            case 1:
                let macString = String.init(format: "%02x:%02x:%02x:%02x:%02x:%02x",functionVal[5],functionVal[4],functionVal[3],functionVal[2],functionVal[1],functionVal[0])
                modelDic["mac_ble"] = macString
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "mac_ble = %@",macString))
                break
            case 2:
                if let serverString = String.init(data: functionData, encoding: .utf8) {
                    modelDic["serialNumber"] = serverString
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "serialNumber = %@",serverString))
                }
                break
                
            case 3:
                if let nameString = String.init(data: functionData, encoding: .utf8) {
                    modelDic["hardwareVersion"] = nameString
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "hardwareVersion = %@",nameString))
                }
                
                break
            case 4:
                if let nameString = String.init(data: functionData, encoding: .utf8) {
                    modelDic["softwareVersion"] = nameString
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "softwareVersion = %@",nameString))
                }
                break
            case 5:
                if let nameString = String.init(data: functionData, encoding: .utf8) {
                    modelDic["bleName"] = nameString
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "bleName = %@",nameString))
                }
                break
            case 6:
                let macString = String.init(format: "%02x:%02x:%02x:%02x:%02x:%02x",functionVal[5],functionVal[4],functionVal[3],functionVal[2],functionVal[1],functionVal[0])
                modelDic["mac_br"] = macString
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "mac_br = %@",macString))
                break
            case 7:
                if let nameString = String.init(data: functionData, encoding: .utf8) {
                    modelDic["bleName_br"] = nameString
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "bleName_br = %@",nameString))
                }
                break
            default:
                break
            }
            index = (index+2+Int(functionLength))
        }
        let model = ZycxHeadphoneDeviceInfomationModel.init(dic: modelDic)
        self.zycxHeadphoneDeviceInfoModel = model
        success(model,.none)
        
        //printLog("第\(#line)行" , "\(#function)")
        //self.signalCommandSemaphore()
        if self.isHeadphoneForwardingData {
            self.signalChargingBoxSemaphore()
        }else{
            self.isHeadphoneForwardingData = false
            self.signalCommandSemaphore()
        }
    }
    
    /*
     消息 ID：0x04(发送)
     起始字节 字段 数据类型 描述及要求
     0 参数 ID 总数 BYTE
     1 参数 ID列表  BYTE[n] 参数 ID 顺序排列，如“参数 ID1 参数 ID2...... 参数 IDn”。
     
     消息 ID：0x84(应答)
     起始字节 字段 数据类型 描述及要求
     0 参数总数 BYTE 总数多少则包含多少个参数，例如：2，则有2个参数；
     1 参数列表 BYTE[n] 详见”参数说明”
     
     参数说明
     起始字节 字段 数据类型 描述及要求
     0 参数ID BYTE 详见”参数 ID 说明”
     1 参数长度 BYTE
     2 参数内容 BYTE[n]
     
     参数 ID 说明
     参数ID 参数长度 参数内容
     0x00 BYTE[n] 自定义按键，详见自定义按键说明
     0x01 BYTE  EQ 模式，参数如下：0：默认、1：重低音、2：影院音效、3：
                DJ、4：流行、5：爵士、6：古典、7：摇滚、8：原声、9：怀
                旧、10：律动、11：舞曲、12：电子、13：丽音、14：纯净人
                声、15：自定义
     0x02 BYTE[n] 自定义 EQ 音效，详见自定义 EQ 音效说明
     0x03 BYTE 环境音，0：关闭/默认、1：通透、2：降噪
     0x04 BYTE 空间音效，0：关闭/默认、1：音乐、2：影院、3：游戏
     0x05 BYTE 入耳感知播放，0：关闭/默认 1：开
     0x06 BYTE 极速模式，0：关闭/默认、1：开
     0x07 BYTE 抗风噪模式，0：关闭/默认、1：开
     0x08 BYTE 低音增强模式，0：关闭/默认、1：开
     0x09 BYTE 低频增强模式，0：关闭/默认、1：开
     0x0A BYTE 对联模式，0：关闭/默认、1：开
     0x0B BYTE 桌面模式，0：关闭/默认、1：开
     0x0C BYTE 摇一摇切歌模式 0：关闭/默认 1：开
     0x0D BYTE 耳机音量 0x0 到 0x16
     0x0E WORD 耳机电量，byte[0]左耳,byte[1]右耳
     
     自定义按键说明
     起始字节 字段 数据类型 描述及要求
     0 自定义按键项总数 BYTE
     1 自定义按键列表  BYTE[n]
     
     自定义按键列表
     起始字节 字段 数据类型 描述及要求
     0 耳机类型 BYTE 0：左耳，1：右耳
     1 按键类型 BYTE 0 单击，1 双击，2 三击，3 长按
     2 按键功能 ID BYTE 按键功能ID 描述
                            0 无功能
                            1 播放/暂停
                            2 上一曲
                            3 下一曲
                            4 音量+
                            5 音量-
                            6 来电接听
                            7 来电拒绝
                            8 挂断电话
                            9 环境音切换
                            10 唤醒语音助手
                            11 回拨电话
     
     自定义EQ音效说明
     起始字节 字段 数据类型 描述及要求
     0 总增益 BYTE 范围-12dB~12dB；分辨率 0.1；0 代表-12dB、120 代表 0dB、240 代表 12dB；
     0 自定义EQ音效项总数   BYTE 最大不超过20组；
     1 自定义EQ音效列表    BYTE[n]
     
     自定义 EQ 音效列表
     起始字节 字段 数据类型 描述及要求
     0 频率 WORD 1代表1HZ
     2 增益 BYTE 范围-12dB~12dB；分辨率 0.1；0 代表-12dB、120 代表 0dB、240 代表 12dB；
     3 Q值 WORD 分辨率0.1；0代表0，100代表 10；
     5 类型 BYTE 0：直通、1：低架、2：高架 3：低通 4：高通
     */
    // MARK: - 参数查询
    @objc public func getZycxHeadphoneDeviceParameters(isForwardingData:Bool = false,listArray:[Int]? = nil , success:@escaping((_ model:ZycxHeadphoneDeviceParametersModel?,_ error:ZywlError)->Void)) {
        
        var headVal:[UInt8] = [
            0xc0,
            0x04
        ]
        
        var listArray:[Int] = listArray ?? []
        if listArray.count <= 0 {
            if let functionModel = self.headphonesFunctionListModel {
                if functionModel.functionList_customButton {
                    listArray.append(0)
                }
                if functionModel.functionList_eqMode {
                    listArray.append(1)
                }
//                if functionModel.functionList_customEq {
//                    listArray.append(2)
//                }
                if functionModel.functionList_ambientSoundEffect {
                    listArray.append(3)
                }
                if functionModel.functionList_spaceSoundEffect {
                    listArray.append(4)
                }
                if functionModel.functionList_inEarPerception {
                    listArray.append(5)
                }
                if functionModel.functionList_extremeSpeedMode {
                    listArray.append(6)
                }
                if functionModel.functionList_windNoiseResistantMode {
                    listArray.append(7)
                }
                if functionModel.functionList_bassToneEnhancement {
                    listArray.append(8)
                }
                if functionModel.functionList_lowFrequencyEnhancement {
                    listArray.append(9)
                }
                if functionModel.functionList_coupletPattern {
                    listArray.append(10)
                }
                if functionModel.functionList_desktopMode {
                    listArray.append(11)
                }
                if functionModel.functionList_shakeSong {
                    listArray.append(12)
                }
                
                listArray.append(13)
                listArray.append(14)
                
                if functionModel.functionList_soundEffectMode {
                    listArray.append(15)
                }
                if functionModel.functionList_patternMode {
                    listArray.append(16)
                }
                    
            }else{
                for i in stride(from: 0, to: 17, by: 1) {
                    listArray.append(i)
                }
            }
        }
        
        var contentVal:[UInt8] = []
        contentVal.append(UInt8(listArray.count))
        for item in listArray {
            contentVal.append(UInt8(item))
        }
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneDeviceParameters = success
                }else{
                    success(nil,error)
                }
            }
            return
        }
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxHeadphoneDeviceParameters = success
            }else{
                success(nil,error)
            }
        }
    }
    
    func parseGetZycxHeadphoneDeviceParameters(val:[UInt8],success:@escaping((_ model:ZycxHeadphoneDeviceParametersModel?,_ error:ZywlError)->Void)) {
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }
        
        ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "parseGetZycxHeadphoneDeviceParameters待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))

        let model = ZycxHeadphoneDeviceParametersModel()
        let count:Int = Int(val[0])
        var index = 1
        //for _ in 0..<count {
        while index < val.count {
            let functionId = val[index]
            if index+1 >= val.count {
                print("index+1 >= val.count 长度异常 不解析")
                index = val.count
                continue
            }
            let functionLength = (val[index+1])
            if index+2+Int(functionLength) > val.count {
                print("index+2+functionLength 长度异常 不解析")
                index = val.count
                continue
            }
            let functionVal = Array.init(val[(index+2)..<(index+2+Int(functionLength))])
            
            if functionVal.count <= 0 {
                print("数据异常不解析")
                //success(model,.fail)
                index = (index+2+Int(functionLength))
                continue
            }
            
            switch functionId {
            case 0:
                
                var listArray:[ZycxHeadphoneDeviceParametersModel_customButton] = .init()
                let customCount = functionVal[0]
                var valIndex = 1
                while valIndex < functionVal.count {
                    let model = ZycxHeadphoneDeviceParametersModel_customButton()
                    let headphoneType = Int(functionVal[valIndex+0])
                    if valIndex+1 >= functionVal.count || valIndex+2 >= functionVal.count {
                        print("长度异常 本次不解析")
                        valIndex = functionVal.count
                        continue
                    }
                    let clickType = Int(functionVal[valIndex+1])
                    let commandType = Int(functionVal[valIndex+2])
                    let string = String.init(format: "耳机类型:%d,按键类型:%d,功能类型:%d",headphoneType,clickType,commandType)
                    ZywlSDKLog.writeStringToSDKLog(string: string)
                    model.headphoneType = headphoneType
                    model.touchType = clickType
                    model.commandType = commandType
                    listArray.append(model)
                    valIndex += 3
                }
                model.customButtonList = listArray
                break
            case 1:
                let eqModel = Int(functionVal[0])
                model.eqMode = eqModel
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "eqModel = %d",eqModel))
                
                break
            case 2:
                printLog("functionVal = \(functionVal)")
                let totalBuff = Int(functionVal[0])
                let count = Int(functionVal[1])
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "自定义eq音效 ZycxHeadphoneDeviceParametersModel_customEqModel = %d",totalBuff))
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "自定义eq音效 count = %d",count))
                var listArray = [ZycxHeadphoneDeviceParametersModel_customEqItem]()
                var valIndex = 2
                while valIndex < functionVal.count {
                    let eqItem = ZycxHeadphoneDeviceParametersModel_customEqItem()
                    eqItem.frequency = Int((functionVal[valIndex+0] << 8 | functionVal[valIndex+1]))
                    eqItem.buff = Int(functionVal[valIndex+2])
                    eqItem.Qvalue = Int((functionVal[valIndex+3] << 8 | functionVal[valIndex+4]))
                    eqItem.type = Int(functionVal[valIndex+5])
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "自定义eq音效 eqItem.frequency = %d",eqItem.frequency))
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "自定义eq音效 eqItem.buff = %d",eqItem.buff))
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "自定义eq音效 eqItem.Qvalue = %d",eqItem.Qvalue))
                    ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "自定义eq音效 eqItem.type = %d",eqItem.type))
                    listArray.append(eqItem)
                    valIndex += 6
                }
                let customEqModel = ZycxHeadphoneDeviceParametersModel_customEqModel()
                customEqModel.totalBuff = totalBuff
                customEqModel.eqListArray = listArray
                model.customEqModel = customEqModel
                
                break
                
            case 3:
                let ambientSoundEffect = Int(functionVal[0])
                model.ambientSoundEffect = ambientSoundEffect
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "环境音ambientSoundEffect = %d",ambientSoundEffect))
                
                break
            case 4:
                let spaceSoundEffect = Int(functionVal[0])
                model.spaceSoundEffect = spaceSoundEffect
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "空间音效spaceSoundEffect = %d",spaceSoundEffect))
                break
            case 5:
                let inEarPerception = Int(functionVal[0])
                model.inEarPerception = inEarPerception
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "入耳感知inEarPerception = %d",inEarPerception))
                break
            case 6:
                let extremeSpeedMode = Int(functionVal[0])
                model.extremeSpeedMode = extremeSpeedMode
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "极速模式extremeSpeedMode = %d",extremeSpeedMode))
                break
            case 7:
                let windNoiseResistantMode = Int(functionVal[0])
                model.windNoiseResistantMode = windNoiseResistantMode
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "抗风噪模式windNoiseResistantMode = %d",windNoiseResistantMode))
                break
            case 8:
                let bassToneEnhancement = Int(functionVal[0])
                model.bassToneEnhancement = bassToneEnhancement
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "低音增强模式bassToneEnhancement = %d",bassToneEnhancement))
                break
            case 9:
                
                let lowFrequencyEnhancement = Int(functionVal[0])
                model.lowFrequencyEnhancement = lowFrequencyEnhancement
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "低频增强模式lowFrequencyEnhancement = %d",lowFrequencyEnhancement))
                
                break
            case 0x0a:
                
                let coupletPattern = Int(functionVal[0])
                model.coupletPattern = coupletPattern
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "对联模式coupletPattern = %d",coupletPattern))

                break
                
            case 0x0B:
                
                let desktopMode = Int(functionVal[0])
                model.desktopMode = desktopMode
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "桌面模式desktopMode = %d",desktopMode))
                break
                
            case 0x0C:
                
                let shakeSong = Int(functionVal[0])
                model.shakeSong = shakeSong
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "摇一摇切歌模式shakeSong = %d",shakeSong))
                
                break
            case 0x0d:
                let voiceVolume = Int(functionVal[0])
                model.voiceVolume = voiceVolume
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "耳机音量voiceVolume = %d",voiceVolume))
                break
            case 0x0e:
                let leftBattery = Int(functionVal[0])
                model.leftBattery = leftBattery
                let rightBattery = Int(functionVal[1])
                model.rightBattery = rightBattery
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "左耳耳机电量leftBattery = %d,右耳耳机电量rightBattery = %d",leftBattery,rightBattery))
                break
            case 0x0f:
                let soundEffectMode = Int(functionVal[0])
                model.soundEffectMode = soundEffectMode
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "音效模式soundEffectMode = %d",soundEffectMode))
                break
            case 0x10:
                let patternMode = Int(functionVal[0])
                model.patternMode = patternMode
                ZywlSDKLog.writeStringToSDKLog(string: String.init(format: "信号模式patternMode = %d",patternMode))
                break
            default:
                break
            }
            index = (index+2+Int(functionLength))
        }
        success(model,.none)
        
        //printLog("第\(#line)行" , "\(#function)")
        if self.isHeadphoneForwardingData {
            self.signalChargingBoxSemaphore()
        }else{
            self.isHeadphoneForwardingData = false
            self.signalCommandSemaphore()
        }
    }

    /*
     消息 ID：0x05(发送)
     起始字节 字段 数据类型 描述及要求
     0 参数总数 BYTE 总数多少则包含多少个参数，例如：2，则有2个参数；
     1 参数列表 BYTE[n] 详见“参数说明(设置)”
     
     参数说明(设置)
     起始字节 字段 数据类型 描述及要求
     0 参数 ID BYTE 详见”参数 ID 说明”
     1 参数长度 BYTE
     2 参数内容 BYTE[n]
     
     消息 ID：0x85(应答)
     起始字节 字段 数据类型 描述及要求
     0 参数总数 BYTE
     1 参数列表 BYTE[n] 该列表为设置的所有项
     详见“参数说明(应答)”
     
     参数说明(应答)
     起始字节 字段 数据类型 描述及要求
     0 参数 ID BYTE 详见”参数 ID 说明”
     2 操作结果 BYTE 0：成功，1：失败
     */
    // MARK: - 参数设置
    @objc public func setZycxHeadphoneDeviceParameters(isForwardingData:Bool = false,model:ZycxHeadphoneDeviceParametersModel) {
        
        var headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        var touchArray:[UInt8] = .init()
        
        for item in model.customButtonList {
            touchArray.append(UInt8(item.headphoneType))
            touchArray.append(UInt8(item.touchType))
            touchArray.append(UInt8(item.commandType))
        }
        
        let id0 = [0x00,UInt8(touchArray.count+1),UInt8(model.customButtonList.count)] + touchArray
        
        let id1 = [0x01,0x01,UInt8(model.eqMode)]
        
        let id2:[UInt8] = [0x02,0x01,0x00]
        
        let id3 = [0x03,0x01,UInt8(model.ambientSoundEffect)]
        
        let id4 = [0x04,0x01,UInt8(model.spaceSoundEffect)]
        
        let id5 = [0x05,0x01,UInt8(model.inEarPerception)]
        
        let id6 = [0x06,0x01,UInt8(model.extremeSpeedMode)]
        
        let id7 = [0x07,0x01,UInt8(model.windNoiseResistantMode)]
        
        let id8:[UInt8] = [0x08,0x01,UInt8(model.bassToneEnhancement)]
        
        let id9:[UInt8] = [0x09,0x01,UInt8(model.lowFrequencyEnhancement)]

        let ida:[UInt8] = [0x0a,0x01,UInt8(model.coupletPattern)]

        let idb:[UInt8] = [0x0b,0x01,UInt8(model.desktopMode)]
        
        let idc:[UInt8] = [0x0c,0x01,UInt8(model.shakeSong)]

        var idd:[UInt8] = [0x0d,0x01,UInt8(model.voiceVolume)]
        
        var idf:[UInt8] = [0x0f,0x01,UInt8(model.soundEffectMode)]
        
        var id10:[UInt8] = [0x10,0x01,UInt8(model.patternMode)]
        
        var contentVal:[UInt8] = [0x0e]
        contentVal.append(contentsOf: id0)
        contentVal.append(contentsOf: id1)
        contentVal.append(contentsOf: id2)
        contentVal.append(contentsOf: id3)
        contentVal.append(contentsOf: id4)
        contentVal.append(contentsOf: id5)
        contentVal.append(contentsOf: id6)
        contentVal.append(contentsOf: id7)
        contentVal.append(contentsOf: id8)
        contentVal.append(contentsOf: id9)
        contentVal.append(contentsOf: ida)
        contentVal.append(contentsOf: idb)
        contentVal.append(contentsOf: idc)
        contentVal.append(contentsOf: idd)
        contentVal.append(contentsOf: idf)
        contentVal.append(contentsOf: id10)
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.signalChargingBoxSemaphore()
                }else{

                }
            }
        }else{
            self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.signalCommandSemaphore()
                }else{

                }
            }
        }
    }
    
    // MARK: - 获取自定义按键
    @objc public func getZycxHeadphoneCustomButtonList(isForwardingData:Bool = false,success:@escaping((_ listArray:[ZycxHeadphoneDeviceParametersModel_customButton],_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [0]) { model, error in
            success(model?.customButtonList ?? [],error)
        }
    }
    
    // MARK: - 设置自定义按键
    @objc public func setZycxHeadphoneCustomButtonList(isForwardingData:Bool = false,listArray:[ZycxHeadphoneDeviceParametersModel_customButton],_ success:@escaping((_ error:ZywlError)->Void)) {
        
        var listVal:[UInt8] = .init()
        for item in listArray {
            listVal.append(UInt8(item.headphoneType))
            listVal.append(UInt8(item.touchType))
            listVal.append(UInt8(item.commandType))
        }
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let id0 = [0x00,UInt8(listVal.count+1),UInt8(listArray.count)]+listVal
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: id0)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneCustomButtonList = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let id0 = [0x00,UInt8(listVal.count+1),UInt8(listArray.count)]+listVal
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id0)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneCustomButtonList = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取EQ模式
    @objc public func getZycxHeadphoneEqMode(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [1]) { model, error in
            success(model?.eqMode ?? 0,error)
        }
    }
    
    // MARK: - 设置EQ模式
    @objc public func setZycxHeadphoneEqMode(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {

        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let id1 = [0x01,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: id1)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneEqMode = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let id1 = [0x01,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id1)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneEqMode = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取自定义eq音效
    @objc public func getZycxHeadphoneCustomEq(isForwardingData:Bool = false,success:@escaping((_ customModel:ZycxHeadphoneDeviceParametersModel_customEqModel?,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [2]) { model, error in
            success(model?.customEqModel,error)
        }
    }
    
    // MARK: - 设置自定义eq音效
    @objc public func setZycxHeadphoneCustomEq(isForwardingData:Bool = false,customModel:ZycxHeadphoneDeviceParametersModel_customEqModel,success:@escaping((_ error:ZywlError)->Void)) {
        
        let totalBuff = customModel.totalBuff
        
        
        var listVal:[UInt8] = .init()
        for item in customModel.eqListArray {
            listVal.append(UInt8(item.frequency & 0xff))
            listVal.append(UInt8((item.frequency >> 8) & 0xff))
            listVal.append(UInt8(item.buff))
            listVal.append(UInt8((item.Qvalue) & 0xff))
            listVal.append(UInt8((item.Qvalue >> 8) & 0xff))
            listVal.append(UInt8(item.type))
        }
        
        let id2 = [0x02,UInt8(listVal.count+2),UInt8(totalBuff),UInt8(customModel.eqListArray.count)]+listVal
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id2)
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneCustomButtonList = success
                    
                }else{
                    success(error)
                }
            }
            return
        }

        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneCustomButtonList = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取环境音效
    @objc public func getZycxHeadphoneAmbientSoundEffect(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [3]) { model, error in
            success(model?.ambientSoundEffect ?? 0,error)
        }
    }
    
    // MARK: - 设置环境音效
    @objc public func setZycxHeadphoneAmbientSoundEffect(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let id3 = [0x03,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: id3)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneAmbientSoundEffect = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let id3 = [0x03,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id3)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneAmbientSoundEffect = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取空间音效
    @objc public func getZycxHeadphoneSpaceSoundEffect(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [4]) { model, error in
            success(model?.spaceSoundEffect ?? 0,error)
        }
    }
    
    // MARK: - 设置空间音效
    @objc public func setZycxHeadphoneSpaceSoundEffect(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let id4 = [0x04,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: id4)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneSpaceSoundEffect = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let id4 = [0x04,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id4)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneSpaceSoundEffect = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取入耳感知播放
    @objc public func getZycxHeadphoneInEarPerception(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [5]) { model, error in
            success(model?.inEarPerception ?? 0,error)
        }
    }
    
    // MARK: - 设置入耳感知播放
    @objc public func setZycxHeadphoneInEarPerception(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let id5 = [0x05,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: id5)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneInEarPerception = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let id5 = [0x05,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id5)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneInEarPerception = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取极速模式
    @objc public func getZycxHeadphoneExtremeSpeedMode(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [6]) { model, error in
            success(model?.extremeSpeedMode ?? 0,error)
        }
    }
    
    // MARK: - 设置极速模式
    @objc public func setZycxHeadphoneExtremeSpeedMode(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let id6 = [0x06,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: id6)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneExtremeSpeedMode = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let id6 = [0x06,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id6)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneExtremeSpeedMode = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取抗风噪模式
    @objc public func getZycxHeadphoneWindNoiseResistantMode(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [7]) { model, error in
            success(model?.windNoiseResistantMode ?? 0,error)
        }
    }
    
    // MARK: - 设置抗风噪模式
    @objc public func setZycxHeadphoneWindNoiseResistantMode(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let id7 = [0x07,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: id7)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneWindNoiseResistantMode = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let id7 = [0x07,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id7)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneWindNoiseResistantMode = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取低音增强模式
    @objc public func getZycxHeadphoneBassToneEnhancement(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [8]) { model, error in
            success(model?.bassToneEnhancement ?? 0,error)
        }
    }
    
    // MARK: - 设置低音增强模式
    @objc public func setZycxHeadphoneBassToneEnhancement(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let id8 = [0x08,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: id8)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneBassToneEnhancement = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let id8 = [0x08,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id8)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneBassToneEnhancement = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取低频增强模式
    @objc public func getZycxHeadphoneLowFrequencyEnhancement(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [9]) { model, error in
            success(model?.lowFrequencyEnhancement ?? 0,error)
        }
    }
    
    // MARK: - 设置低频增强模式
    @objc public func setZycxHeadphoneLowFrequencyEnhancement(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let id9 = [0x09,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: id9)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneLowFrequencyEnhancement = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let id9 = [0x09,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id9)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneLowFrequencyEnhancement = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取对联模式
    @objc public func getZycxHeadphoneCoupletPattern(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [10]) { model, error in
            success(model?.coupletPattern ?? 0,error)
        }
    }
    
    // MARK: - 设置对联模式
    @objc public func setZycxHeadphoneCoupletPattern(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let ida = [0x0a,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: ida)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneCoupletPattern = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let ida = [0x0a,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: ida)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneCoupletPattern = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取桌面模式
    @objc public func getZycxHeadphoneDesktopMode(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [11]) { model, error in
            success(model?.desktopMode ?? 0,error)
        }
    }
    
    // MARK: - 设置桌面模式
    @objc public func setZycxHeadphoneDesktopMode(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let idb = [0x0b,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: idb)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneDesktopMode = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let idb = [0x0b,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: idb)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneDesktopMode = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取摇一摇切歌模式
    @objc public func getZycxHeadphoneShakeSong(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [12]) { model, error in
            success(model?.shakeSong ?? 0,error)
        }
    }
    
    // MARK: - 设置摇一摇切歌模式
    @objc public func setZycxHeadphoneShakeSong(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let idc = [0x0c,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: idc)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneShakeSong = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let idc = [0x0c,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: idc)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneShakeSong = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取耳机音量
    @objc public func getZycxHeadphoneVoiceVolume(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [13]) { model, error in
            success(model?.voiceVolume ?? 0,error)
        }
    }
    
    // MARK: - 设置耳机音量
    @objc public func setZycxHeadphoneVoiceVolume(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let idd = [0x0d,0x01,UInt8(type)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: idd)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneVoiceVolume = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let idd = [0x0d,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: idd)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneVoiceVolume = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取耳机电量
    @objc public func getZycxHeadphoneBattery(isForwardingData:Bool = false,success:@escaping((_ leftBattery:Int,_ rightBattery:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [14]) { model, error in
            success(model?.leftBattery ?? 0,model?.rightBattery ?? 0,error)
        }
    }
    
    // MARK: - 设置耳机电量
    @objc public func setZycxHeadphoneBattery(isForwardingData:Bool = false,leftBattery:Int,rightBattery:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x05
            ]
            
            let ide = [0x0e,0x02,UInt8(leftBattery),UInt8(rightBattery)]
            var contentVal:[UInt8] = [0x01]
            contentVal.append(contentsOf: ide)
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneBattery = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let ide = [0x0e,0x02,UInt8(leftBattery),UInt8(rightBattery)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: ide)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneVoiceVolume = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取音效模式
    @objc public func getZycxHeadphoneSoundEffectMode(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [15]) { model, error in
            success(model?.soundEffectMode ?? 0,error)
        }
    }
    
    // MARK: - 设置音效模式
    @objc public func setZycxHeadphoneSoundEffectMode(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let idf = [0x0f,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: idf)
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneSoundEffectMode = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneSoundEffectMode = success
                
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取信号模式
    @objc public func getZycxHeadphonePatternMode(isForwardingData:Bool = false,success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        self.getZycxHeadphoneDeviceParameters(isForwardingData: isForwardingData, listArray: [16]) { model, error in
            success(model?.patternMode ?? 0,error)
        }
    }
    
    // MARK: - 设置信号模式
    @objc public func setZycxHeadphonePatternMode(isForwardingData:Bool = false,type:Int,success:@escaping((_ error:ZywlError)->Void)) {
        
        let headVal:[UInt8] = [
            0xc0,
            0x05
        ]
        
        let id10 = [0x10,0x01,UInt8(type)]
        var contentVal:[UInt8] = [0x01]
        contentVal.append(contentsOf: id10)
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphonePatternMode = success
                }else{
                    success(error)
                }
            }
            return
        }
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphonePatternMode = success
                
            }else{
                success(error)
            }
        }
    }
    
    /*
     消息 ID：0x06(发送)
     起始字节 字段 数据类型 描述及要求
     0 设备控制ID   BYTE 详见“设备控制 ID 说明”
     1 设备控制长度   BYTE[n]
     1+n 设备控制内容 BYTE[n]
     
     设备控制 ID 说明
     设备控制ID 设备控制长度  设备控制内容
     0x00 BYTE  0：设备关机、1：设备重启、2：设备恢复出厂设置、3：设备恢复出厂设置后关机
     0x01 WORD  抖音控制，参数值如下：
                0 :开始 byte[0]:0、byte[1]:0(预留)
                1 :暂停 byte[0]:1、byte[1]:0(预留)
                2 :下一首 byte[0]:2、byte[1]:0(预留)
                3 :上一首 byte[0]:3、byte[1]:0(预留)
                4 :点赞 byte[0]:4、byte[1]:0(预留)
                5 :音量 byte[0]:5、byte[1]:(0～16)
     0x02 WORD  音乐控制，参数值如下：
                0 :开始 byte[0]:0、byte[1]:0(预留)
                1 :暂停 byte[0]:1、byte[1]:0(预留)
                2 :下一首 byte[0]:2、byte[1]:0(预留)
                3 :上一首 byte[0]:3、byte[1]:0(预留)
                4 :音量 byte[0]:4、byte[1]:(0～16)
     0x03 BYTE 来电控制，0: 挂断、1：接听
     0x04 WORD  寻找耳机，参数值如下：
                 byte[0]，0：左耳机、1：右耳机
                 byte[1]，0：开始、1：结束
     
     消息 ID：0x86(应答)
     起始字节 字段 数据类型 描述及要求
     0 设备控制ID   BYTE
     1 操作结果 BYTE 0 :成功 1 :失败
     */
    
    // MARK: - 设备控制
    // MARK: - 设备关机
    @objc public func setZycxHeadphonePowerOff(isForwardingData:Bool = false, success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x00,0x01,0x00]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphonePowerOff = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x00,0x01,0x00]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphonePowerOff = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 设备重启
    @objc public func setZycxHeadphoneRestart(isForwardingData:Bool = false, success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x00,0x01,0x01]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneRestart = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x00,0x01,0x01]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneRestart = success
            }else{
                success(error)
            }
        }
    }

    // MARK: - 设备恢复出厂
    @objc public func setZycxHeadphoneResetFactory(isForwardingData:Bool = false, success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x00,0x01,0x02]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneResetFactory = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x00,0x01,0x02]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneResetFactory = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 设备恢复出厂并关机
    @objc public func setZycxHeadphoneResetFactoryAndPowerOff(isForwardingData:Bool = false, success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x00,0x01,0x03]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneResetFactoryAndPowerOff = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x00,0x01,0x03]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneResetFactoryAndPowerOff = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 抖音控制
    @objc public func setZycxHeadphoneTiktokControl(isForwardingData:Bool = false,type:Int ,value:Int = 0 ,success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x01,0x02,UInt8(type),UInt8(value)]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneTiktokControl = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x01,0x02,UInt8(type),UInt8(value)]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneTiktokControl = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 音乐控制
    @objc public func setZycxHeadphoneMusicControl(isForwardingData:Bool = false,type:Int ,value:Int = 0 ,success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x02,0x02,UInt8(type),UInt8(value)]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneMusicControl = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x02,0x02,UInt8(type),UInt8(value)]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneMusicControl = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 来电控制
    @objc public func setZycxHeadphoneCallControl_AndswerHandUp(isForwardingData:Bool = false,type:Int ,success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x03,0x02,UInt8(type),0x0]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneCallControl_AndswerHandUp = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x03,0x02,UInt8(type),0x0]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneCallControl_AndswerHandUp = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 来电控制
    @objc public func setZycxHeadphoneCallControl_DtmfDialing(isForwardingData:Bool = false,type:Int,number:String,success:@escaping((_ error:ZywlError)->Void)) {
        let numberData = number.data(using: .utf8) ?? .init()
        let numberVal = numberData.withUnsafeBytes { (byte) -> [UInt8] in
            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
            return [UInt8](UnsafeBufferPointer.init(start: b, count: numberData.count))
        }
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            var contentVal:[UInt8] = [0x03,UInt8(2+numberVal.count)]
            contentVal.append(contentsOf: numberVal)
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneCallControl_DtmfDialing = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        var contentVal:[UInt8] = [0x03,UInt8(2+numberVal.count)]
        contentVal.append(contentsOf: numberVal)
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneCallControl_DtmfDialing = success
            }else{
                success(error)
            }
        }
    }
    
    @objc public func setZycxHeadphoneCallControl_VolumeVoice(isForwardingData:Bool = false,value:Int ,success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x03,0x02,0x04,UInt8(value)]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneCallControl_VolumeVoice = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x03,0x02,0x04,UInt8(value)]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneCallControl_VolumeVoice = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 寻找耳机
    @objc public func setZycxHeadphoneFind(isForwardingData:Bool = false,headphoneType:Int,isStart:Int,success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x04,0x02,UInt8(headphoneType),UInt8(isStart)]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneFind = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x04,0x02,UInt8(headphoneType),UInt8(isStart)]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneFind = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 拍照控制
    @objc public func setZycxHeadphoneTakePhoto(isForwardingData:Bool = false,success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x05]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneTakePhoto = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x05]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneTakePhoto = success
            }else{
                success(error)
            }
        }
    }
    // MARK: - 双耳自定义按键功能恢复默认
    @objc public func setZycxHeadphoneCustomButtonResetDefault(isForwardingData:Bool = false,success:@escaping((_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x06
            ]
            
            let contentVal:[UInt8] = [0x06]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveSetZycxHeadphoneCustomButtonResetDefault = success
                }else{
                    success(error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x06
        ]
        
        let contentVal:[UInt8] = [0x06]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetZycxHeadphoneCustomButtonResetDefault = success
            }else{
                success(error)
            }
        }
    }
    
    /*
     消息 ID：0x07(发送)
     起始字节 字段 数据类型 描述及要求
     0 状态查询ID   BYTE 详见”状态查询 ID 说明”
     
     状态查询 ID 说明
     状态查询ID 状态主动上报长度    状态主动上报内容
     0x00 WORD 耳机电量，byte[0]左耳、byte[1]右耳
     0x01 BYTE 音乐状态，0 :开始、1 :暂停
     
     消息 ID：0x87(发送)
     起始字节 字段 数据类型 描述及要求
     0 状态 ID BYTE 详见”状态查询说明表”
     1 状态长度 BYTE[n]
     1+n 状态内容 BYTE[n]
     */
    // MARK: - 状态查询
    // MARK: - 电量获取
    @objc public func getZycxHeadphoneStateBattery(isForwardingData:Bool = false, success:@escaping((_ leftBattery:Int,_ rightBattery:Int,_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x07
            ]
            
            let contentVal:[UInt8] = [0x00]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneStateBattery = success
                }else{
                    success(0,0,error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x07
        ]
        
        let contentVal:[UInt8] = [0x00]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxHeadphoneStateBattery = success
            }else{
                success(0,0,error)
            }
        }
    }
    
    func parseGetZycxHeadphoneStateBattery(val:[UInt8],success:@escaping((_ leftBattery:Int,_ rightBattery:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let leftBattery = val[0]
            let rightBattery = val[1]
            success(Int(leftBattery),Int(rightBattery),.none)
        }else{
            success(0,0,.invalidLength)
        }
        if self.isHeadphoneForwardingData {
            self.signalChargingBoxSemaphore()
        }else{
            self.isHeadphoneForwardingData = false
            self.signalCommandSemaphore()
        }
    }
    
    // MARK: - 音乐状态
    @objc public func getZycxHeadphoneMusicState(isForwardingData:Bool = false, success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            let headVal:[UInt8] = [
                0xc0,
                0x07
            ]
            
            let contentVal:[UInt8] = [0x01]
            
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneMusicState = success
                }else{
                    success(0,error)
                }
            }
            return
        }

        let headVal:[UInt8] = [
            0xc0,
            0x07
        ]
        
        let contentVal:[UInt8] = [0x01]
        
        self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetZycxHeadphoneMusicState = success
            }else{
                success(0,error)
            }
        }
    }
    
    func parseGetZycxHeadphoneMusicState(val:[UInt8],success:@escaping((_ type:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let state = val[0]
            success(Int(state),.none)
        }else{
            success(0,.invalidLength)
        }
        if self.isHeadphoneForwardingData {
            self.signalChargingBoxSemaphore()
        }else{
            self.isHeadphoneForwardingData = false
            self.signalCommandSemaphore()
        }
    }

    // MARK: - 当前时间
    @objc public func getZycxHeadphoneCurrentTime(isForwardingData:Bool = false, time:Any? = nil, success:@escaping((_ timeString:String,_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xc0,
            0x07
        ]
        
        var contentVal:[UInt8] = [0x02]
        
//        var date = Date.init()
//        
//        if time is Date {
//            
//            date = time as! Date
//            
//        }else if time is String {
//            
//            let format = DateFormatter.init()
//            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            
//            let timeArray = (time as! String).components(separatedBy: " ")
//            if timeArray.count == 2 {
//                
//                date = format.date(from: time as! String) ?? .init()
//                
//            }else if timeArray.count == 3 {
//                
//                let newTime:String = timeArray[0] + timeArray[1]
//                date = format.date(from: newTime) ?? .init()
//                
//            }
//        }
//        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
//        let year = calendar.component(.year, from: date)
//        let month = calendar.component(.month, from: date)
//        let day = calendar.component(.day, from: date)
//        let hour = calendar.component(.hour, from: date)
//        let minute = calendar.component(.minute, from: date)
//        let second = calendar.component(.second, from: date)
//            
//        contentVal.append(contentsOf: [UInt8(year-2000),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)])

        if isForwardingData {
            self.isHeadphoneForwardingData = true
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneCurrentTime = success
                }else{
                    success("",error)
                }
            }
        }else{
            self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneCurrentTime = success
                }else{
                    success("",error)
                }
            }
        }
    }
    
    func parseGetZycxHeadphoneCurrentTime(val:[UInt8],success:@escaping((_ timeString:String,_ error:ZywlError)->Void)) {
        if val.count >= 6 {
            let timeString = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", 2000+Int(val[0]),val[1],val[2],val[3],val[4],val[5])
            success(timeString,.none)
        }else{
            success("",.invalidLength)
        }
        if self.isHeadphoneForwardingData {
            self.signalChargingBoxSemaphore()
        }else{
            self.isHeadphoneForwardingData = false
            self.signalCommandSemaphore()
        }
    }
    
    // MARK: - 获取经典蓝牙连接状态
    @objc public func getZycxHeadphoneBtConncetState(isForwardingData:Bool = false, success:@escaping((_ state:Int,_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xc0,
            0x07
        ]
        var contentVal:[UInt8] = [0x04]
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneBtConncetState = success
                }else{
                    success(-1,error)
                }
            }
        }else{
            self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneBtConncetState = success
                }else{
                    success(-1,error)
                }
            }
        }
    }
    
    func parseGetZycxHeadphoneBtConncetState(val:[UInt8],success:@escaping((_ state:Int,_ error:ZywlError)->Void)) {
        if val.count >= 1 {
            let state = Int(val[0])
            success(state,.none)
        }else{
            success(-1,.invalidLength)
        }
        if self.isHeadphoneForwardingData {
            self.signalChargingBoxSemaphore()
        }else{
            self.isHeadphoneForwardingData = false
            self.signalCommandSemaphore()
        }
    }
    
    // MARK: - 获取TWS是否配对
    @objc public func getZycxHeadphoneTwsIsPair(isForwardingData:Bool = false, success:@escaping((_ state:Int,_ error:ZywlError)->Void)) {
        let headVal:[UInt8] = [
            0xc0,
            0x07
        ]
        var contentVal:[UInt8] = [0x05]
        
        if isForwardingData {
            self.isHeadphoneForwardingData = true
            self.dealChargingBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneTwsIsPair = success
                }else{
                    success(-1,error)
                }
            }
        }else{
            self.dealHeadphoneData(headVal: headVal, contentVal: contentVal) { [weak self] error in
                if error == .none {
                    self?.receiveGetZycxHeadphoneTwsIsPair = success
                }else{
                    success(-1,error)
                }
            }
        }
    }
    
    func parseGetZycxHeadphoneTwsIsPair(val:[UInt8],success:@escaping((_ state:Int,_ error:ZywlError)->Void)) {
        if val.count >= 1 {
            let state = Int(val[0])
            success(state,.none)
        }else{
            success(-1,.invalidLength)
        }
        if self.isHeadphoneForwardingData {
            self.signalChargingBoxSemaphore()
        }else{
            self.isHeadphoneForwardingData = false
            self.signalCommandSemaphore()
        }
    }
    
    /*
     消息 ID：0x88(发送)
     起始字节 字段 数据类型 描述及要求
     0 状态主动上报总数 BYTE 总数多少则包含多少个状态主动上报，例如：2，则有 2 个状态主动上报；
     1 状态主动上报列表 BYTE[n] 详见“状态主动上报说明”
     
     状态主动上报说明
     起始字节 字段 数据类型 描述及要求
     0 状态主动上报ID BYTE 详见”状态主动上报 ID 说明”
     1 状态主动上报长度 BYTE[n]
     1+n 状态主动上报内容   BYTE[n]
     
     状态主动上报 ID 说明
     状态主动上报ID   状态主动上报长度    状态主动上报内容
     0x00 WORD 耳机电量，byte[0]左耳、byte[1]右耳
     0x01 BYTE 查找设备
     0x02 BYTE 来电控制，0: 挂断、1：接听
     0x03 BYTE 音乐状态，0 :开始、1 :暂停
     0x04 BYTE 环境音，0：关闭/默认、1：通透、2：降噪
     0x05 BYTE 空间音效，0：关闭/默认 1：音乐、2：影院、3：游戏
     0x06 BYTE 入耳感知播放，0：关闭/默认、1：开
     0x07 BYTE 极速模式，0：关闭/默认、1：开
     0x08 BYTE 抗风噪模式，0：关闭/默认、1：开
     0x09 BYTE 低音增强模式，0：关闭/默认、1：开
     0x0A BYTE 低频增强模式，0：关闭/默认、1：开
     0x0B BYTE 对联模式，0：关闭/默认、1：开
     0x0C BYTE 桌面模式，0：关闭/默认、1：开
     0x0D BYTE 摇一摇切歌模式，0：关闭/默认、1：开
     0x0E BYTE EQ 模式，参数如下：0：默认、1：重低音、2：影院音效、3：
                DJ、4：流行、5：爵士、6：古典、7：摇滚、8：原声、9：怀
                旧、10：律动、11：舞曲、12：电子、13：丽音、14：纯净人
                声
     0x0F BYTE 耳机电量(0～16)
     0x10 BYTE[n] 参考自定义按键说明
     0x11 BYTE (经典)蓝牙连接状态，0 :未连接、1 :已连接
     
     消息 ID：0x08(应答)
     消息体为空；
     */
    // MARK: - 状态主动上报
    // MARK: - 电量上报
    @objc public func reportZycxHeadphoneBattery(_ success:@escaping((_ leftBattery:Int,_ rightBattery:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneBattery = success
    }
    
    func parseReportZycxHeadphoneBattery(val:[UInt8],success:@escaping((_ leftBattery:Int,_ rightBattery:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let leftBattery = val[0]
            let rightBattery = val[1]
            success(Int(leftBattery),Int(rightBattery),.none)
        }else{
            success(0,0,.invalidLength)
        }
    }
    // MARK: - 查找设备
    @objc public func reportZycxHeadphoneFind(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneFind = success
    }
    
    func parseReportZycxHeadphoneFind(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 来电控制
    @objc public func reportZycxHeadphoneCallControl(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneCallControl = success
    }
    
    func parseReportZycxHeadphoneCallControl(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 音乐状态
    @objc public func reportZycxHeadphoneMusicState(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneMusicState = success
    }
    
    func parseReportZycxHeadphoneMusicState(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 环境音
    @objc public func reportZycxHeadphoneAmbientSoundEffect(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneAmbientSoundEffect = success
    }
    
    func parseReportZycxHeadphoneAmbientSoundEffect(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 空间音效
    @objc public func reportZycxHeadphoneSpaceSoundEffect(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneSpaceSoundEffect = success
    }
    
    func parseReportZycxHeadphoneSpaceSoundEffect(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 入耳感知
    @objc public func reportZycxHeadphoneInEarPerception(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneInEarPerception = success
    }
    
    func parseReportZycxHeadphoneInEarPerception(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 极速模式
    @objc public func reportZycxHeadphoneExtremeSpeedMode(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneExtremeSpeedMode = success
    }
    
    func parseReportZycxHeadphoneExtremeSpeedMode(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 抗风噪模式
    @objc public func reportZycxHeadphoneWindNoiseResistantMode(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneWindNoiseResistantMode = success
    }
    
    func parseReportZycxHeadphoneWindNoiseResistantMode(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 低音增强模式
    @objc public func reportZycxHeadphoneBassToneEnhancement(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneBassToneEnhancement = success
    }
    
    func parseReportZycxHeadphoneBassToneEnhancement(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 低频增强模式
    @objc public func reportZycxHeadphoneLowFrequencyEnhancement(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneLowFrequencyEnhancement = success
    }
    
    func parseReportZycxHeadphoneLowFrequencyEnhancement(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 对联模式
    @objc public func reportZycxHeadphoneCoupletPattern(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneCoupletPattern = success
    }
    
    func parseReportZycxHeadphoneCoupletPattern(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 桌面模式
    @objc public func reportZycxHeadphoneDesktopMode(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneDesktopMode = success
    }
    
    func parseReportZycxHeadphoneDesktopMode(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 摇一摇切歌模式
    @objc public func reportZycxHeadphoneShakeSong(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneShakeSong = success
    }
    
    func parseReportZycxHeadphoneShakeSong(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - eq模式
    @objc public func reportZycxHeadphoneEqMode(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneEqMode = success
    }
    
    func parseReportZycxHeadphoneEqMode(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 耳机音量
    @objc public func reportZycxHeadphoneVoiceVolume(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneVoiceVolume = success
    }
    
    func parseReportZycxHeadphoneVoiceVolume(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    // MARK: - 自定义按键
    @objc public func reportZycxHeadphoneCustomButton(_ success:@escaping((_ value:[ZycxHeadphoneDeviceParametersModel_customButton],_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneCustomButton = success
    }
    
    func parseReportZycxHeadphoneCustomButton(val:[UInt8],success:@escaping((_ value:[ZycxHeadphoneDeviceParametersModel_customButton],_ error:ZywlError)->Void)) {
        var listArray:[ZycxHeadphoneDeviceParametersModel_customButton] = .init()
        if val.count > 0 {
            let functionVal = val
            let customCount = functionVal[0]
            var valIndex = 1
            while valIndex < functionVal.count {
                let model = ZycxHeadphoneDeviceParametersModel_customButton()
                let headphoneType = Int(functionVal[valIndex+0])
                let clickType = Int(functionVal[valIndex+1])
                let commandType = Int(functionVal[valIndex+2])
                let string = String.init(format: "耳机类型:%d,按键类型:%d,功能类型:%d",headphoneType,clickType,commandType)
                ZywlSDKLog.writeStringToSDKLog(string: string)
                model.headphoneType = headphoneType
                model.touchType = clickType
                model.commandType = commandType
                listArray.append(model)
                valIndex += 3
            }
            
            success(listArray,.none)
        }else{
            success([],.invalidLength)
        }
    }
    // MARK: - 经典蓝牙连接状态
    @objc public func reportZycxHeadphoneClassicBluetoothConnect(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneClassicBluetoothConnect = success
    }
    
    func parseReportZycxHeadphoneClassicBluetoothConnect(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            self.forwardingOfHeadphoneIsConnected = value == 0 ? false:true
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 当前时间
    @objc public func reportZycxHeadphoneCurrentTime(_ success:@escaping((_ timeString:String,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneCurrentTime = success
    }
    
    func parseReportZycxHeadphoneCurrentTime(val:[UInt8],success:@escaping((_ timeString:String,_ error:ZywlError)->Void)) {
        if val.count >= 6 {
            let timeString = String.init(format: "%04d-%02d-%02d %02d:%02d:%02d", 2000+Int(val[0]),val[1],val[2],val[3],val[4],val[5])
            success(timeString,.none)
        }else{
            success("",.invalidLength)
        }
    }
    
    // MARK: - 音效模式
    @objc public func reportZycxHeadphoneSoundEffectMode(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphoneSoundEffectMode = success
    }
    
    func parseReportZycxHeadphoneSoundEffectMode(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
    
    // MARK: - 信号模式
    @objc public func reportZycxHeadphonePatternMode(_ success:@escaping((_ value:Int,_ error:ZywlError)->Void)){
        self.receiveReportZycxHeadphonePatternMode = success
    }
    
    func parseReportZycxHeadphonePatternMode(val:[UInt8],success:@escaping((_ value:Int,_ error:ZywlError)->Void)) {
        if val.count > 0 {
            let value = val[0]
            success(Int(value),.none)
        }else{
            success(0,.invalidLength)
        }
    }
}
