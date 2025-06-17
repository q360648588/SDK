//
//  AndXuCommandModule.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2021/7/5.
//

import UIKit
import CoreBluetooth
import JLAudioUnitKit

@objc public enum ZyboxError : Int {
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

let defaultSdkFilePath = NSHomeDirectory() + "/Documents/zyboxFile/"
@objc public class ZyboxCommandModule: ZyboxBaseModule, JLOpusDecoderDelegate {
    public func opusDecoder(_ decoder: JLOpusDecoder, data: Data?, error: (any Error)?) {
        //print("opusDecoder error = \(error?.localizedDescription)")
        if let data = data {
            //print("data = \(data.count)")
        }
    }
    
    
    @objc public static let shareInstance = ZyboxCommandModule()
    
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
    
    var receiveSetCheckFileListBlock:(([ZyboxRecordFileModel],ZyboxError) -> Void)?
    var receiveSetStartFileUploadBlock:((ZyboxRecordFileDataModel?,ZyboxError)->Void)?
    
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
    var fileNumber = 0 //文件流水号
    var fileSize = 0 //文件大小
    var fileTotalPackageCount = 0 //总包数
    var defaultRequestPackageCount = 200 //默认请求包数200。补发个数测试超过256个就会不响应，就默认200
    var fileDataDic:[String:Data] = .init()
    var currentFileName:String?
    var recordingFilePath:String = ""
    var deleteFileName:String?
    var deleteFileNameList:[String]?
    
    private var recordingFileReciveTimeout = 20 //0.1s检查一次，10为1s
    private var recordingFileReciveDetectionTimer:Timer?//检测是否还在传输录音文件数据
    private var recordingFileReciveDetectionCount = 0
    
    var receiveSetFileListRefreshBlock:((Int,ZyboxError) -> Void)?
    var receiveFileProgressBlock:((Float) -> Void)?
    var receiveDownloadFileDataBlock:((Data,String,ZyboxError) -> Void)?
    var receiveSetTimeBlock:((ZyboxError) -> Void)?
    var receiveGetDeviceStateBlock:((ZyboxRecordStateModel?,ZyboxError) -> Void)?
    var receiveSetSingleDeleteFileBlock:((ZyboxError) -> Void)?
    var receiveSetBatchDeleteFileBlock:((ZyboxError) -> Void)?
    var receiveSetPauseFileUploadBlock:((ZyboxError) -> Void)?
    var reciveSetDownloadFileDataBlock:(()->())?
    
    var currentPackageSendComplete:(()->Void)?
    
    private override init() {
        super.init()
        
        ZyboxCrashHandler.setup { (stackTrace, completion) in
            
            printLog("CrashHandler",stackTrace);
            
            let date:NSDate = NSDate()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "YYYY/MM/dd hh:mm:ss SS"
            let strNowTime = timeFormatter.string(from: date as Date) as String
            let url:String = String.init(format: "========异常错误报告========\ntime:%@\n%@\n\n\n\n\n%@",strNowTime,stackTrace,ZyboxSDKLog.showLog())
            
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
        
        ZyboxBleManager.shareInstance.PeripheralUpdateValue { (peripheral, characteristic, error) in
                        
            let data = characteristic.value ?? Data.init()
            
            var val = data.withUnsafeBytes { (byte) -> [UInt8] in
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
            
            if !(val[0] == 0xbb && val[1] == 0x85) {
                let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: characteristic.value ?? Data.init(),isSend: true))
                printLog("characteristic.value =",dataString)
            }
            
//            if characteristic.value?.count ?? 0 > 20 {
//                let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: characteristic.value ?? Data.init(),isSend: true))
//                printLog("characteristic.value =",dataString)
//            }
            
            if characteristic == self.receiveCharacteristic {
                if val[0] == 0xbb {
                    
                    let firstBit = Int(val[2])
                    var maxMtuCount = self.testMaxMtuCount

                    if val[1] == 0x81 {
                        self.testMaxMtuCount = (Int(val[4] << 8) | Int(val[5]))
                        maxMtuCount = self.testMaxMtuCount
                        print("MaxMtuCount = \(self.testMaxMtuCount)")
                        ZyboxSDKLog.writeStringToSDKLog(string: "MaxMtuCount = \(self.testMaxMtuCount)")
                    }
                    
                    let crc16 = (Int(val[val.count-2]) << 8 | Int(val[val.count-1]))
                    
                    if firstBit > 0 {

                        let totalCount = (Int(val[4]) << 8 | Int(val[5]) )
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
                            ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: errorString))
                        }

                        if totalCount == currentCount + 1 {
                            
                            guard self.newProtocalData != nil else {
                                print("self.newProtocalData 数据错误")
                                return
                            }
                            
                            let newVal = self.newProtocalData!.withUnsafeBytes({ (bytes) -> [UInt8] in
                                let b = (bytes.baseAddress?.bindMemory(to: UInt8.self, capacity: 4))!
                                return [UInt8](UnsafeBufferPointer.init(start: b, count: (self.newProtocalData?.count ?? 0)))
                            })
                            
                            if val[1] == 0x82 {
                                if let block = self.receiveSetCheckFileListBlock {
                                    let data123 = Data.init(bytes: newVal, count: newVal.count)
                                    let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data123,isSend: true))
                                    //print("dataString = \(dataString)")
                                    self.parseSetCheckFileList(val: newVal, success: block)
                                }
                            }
                            if val[1] == 0x83 {
                                self.fileSize = (Int(newVal[0]) << 24 | Int(newVal[1]) << 16 | Int(newVal[2]) << 8 | Int(newVal[3]))
                                let maxCount = (Int(newVal[4]) << 8 | Int(newVal[5]))
                                self.fileNumber = (Int(newVal[6]) << 8 | Int(newVal[7]))
                                let fileNameLength = (Int(newVal[8]) << 8 | Int(newVal[9]))
                                let fileNameVal = Array.init(newVal[(10)..<(10+fileNameLength)])
                                let fileNameData = fileNameVal.withUnsafeBufferPointer { (bytes) -> Data in
                                    return Data.init(buffer: bytes)
                                }
                                
                                let packageCount = self.fileSize/maxCount + (self.fileSize % maxCount > 0 ? 1 : 0)
                                self.fileTotalPackageCount = packageCount
                                
                                if let block = self.reciveSetDownloadFileDataBlock {
                                    block()
                                    self.reciveSetDownloadFileDataBlock = nil
                                }
                                                                
                                if let block = self.receiveSetStartFileUploadBlock {
                                    self.parseSetStartFileUpload(val: newVal, success: block)
                                }
                                
                                
                                
                            }
                                                        
                            if val[1] == 0x85 {
                                if self.recordingFileReciveDetectionTimer == nil {
                                    self.recordingFileReciveDetectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.recordingFileReciveDetectionTimerMethod), userInfo: nil, repeats: true)
                                }
                                //有收到数据就把这里的计时器清空
                                self.recordingFileReciveDetectionCount = 0
                                let number = (Int(newVal[0]) << 8 | Int(newVal[1]))
                                let result = Array(newVal[2..<newVal.count])
                                
                                if number == self.fileNumber,let block = self.receiveFileProgressBlock , self.fileTotalPackageCount > 0 {
                                                                        
                                    let packageIndex = (Int(result[0]) << 24 | Int(result[1]) << 16 | Int(result[2]) << 8 | Int(result[3]))
                                    var dicData = Array(result[4..<result.count])
                                    self.fileDataDic["\(packageIndex)"] = Data.init(bytes: dicData, count: dicData.count)
                                    block(Float(self.fileDataDic.keys.count)/Float(self.fileTotalPackageCount))
                                    print("序号packageIndex = \(packageIndex)")
             
                                    if self.fileDataDic.keys.count == self.fileTotalPackageCount {
                                        let allData = self.mergeDictionaryData(dic: self.fileDataDic)
                                        self.fileTotalPackageCount = 0//结束之后把总包改为默认值
                                        self.fileDataDic.removeAll()
                                        self.recordingFileReciveDetectionTimerInvalid()
                                        
                                        if let name = self.currentFileName {
                                            let filePath = defaultSdkFilePath + name
                                            FileManager.removefile(filePath: filePath)
                                        }
                                        
                                        if FileManager.createFile(filePath: self.recordingFilePath).isSuccess {
                                            FileManager.default.createFile(atPath: self.recordingFilePath, contents: allData, attributes: nil)
                                            
                                            let format = JLOpusFormat.defaultFormats()
                                            format.hasDataHeader = false
                                            let decoder = JLOpusDecoder(decoder: format, delegate: self)
                                            let outPath = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".pcm")
                                            decoder.opusDecodeFile(self.recordingFilePath, outPut: outPath) { filePath, error in
                                                if let path = filePath {
                                                    print("转换wav")
                                                    let pathUrl = URL.init(fileURLWithPath: path)
                                                    if let fileData = try? Data.init(contentsOf: pathUrl) {
                                                        let wavFile = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".wav")
                                                        if FileManager.createFile(filePath: wavFile).isSuccess {
                                                            if let _ = try? JLPcmToWav.convertPCMData(fileData, toWAVFile: wavFile, sampleRate: 16000, numChannels: 1, bitsPerSample: 16) {
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        if let block = self.receiveDownloadFileDataBlock {
                                            let finalPath = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".wav")
                                            block(allData,finalPath,.none)
                                        }
                                    }else{
                                        
                                        //判断fileTotalPackageCount的整数倍
                                        if self.fileDataDic.keys.count % self.defaultRequestPackageCount == 0 {
                                            // 高效获取最大键
                                            let maxKey = self.fileDataDic.keys.max {
                                                guard let a = Int($0), let b = Int($1) else { return false }
                                                return a < b
                                            }
                                            let maxInt = Int(maxKey ?? "0") ?? 0
                                            let upCount = maxInt % self.defaultRequestPackageCount == 0 ? maxInt : ((maxInt / self.defaultRequestPackageCount) + 1)*self.defaultRequestPackageCount
                                            let sendArray = self.findMissingKeys(in: self.fileDataDic, upTo: upCount)
                                            if sendArray.count > 0 {
                                                print("有补传序号:\(sendArray),-1-1-1-1 self.fileDataDic.keys.count = \(self.fileDataDic.keys.count)")
                                                self.setFileDataReplenishmentSend(numberIndex: self.fileNumber, packageList: sendArray)
                                                self.currentPackageSendComplete = {
                                                    self.dealFileDownload(index: self.fileDataDic.keys.count, totalPackageCount: self.fileTotalPackageCount, numberIndex: self.fileNumber)
                                                }
                                            }else{
                                                if let name = self.currentFileName {
                                                    let filePath = defaultSdkFilePath + name

                                                    print("val[1] == 0x85 -->>> 写入name:\(name),dic.keys.count = \(self.fileDataDic.keys.count)")
                                                    FileManager.writeDicToFile(content: self.fileDataDic, writePath: filePath)
                                                }
                                                self.dealFileDownload(index: self.fileDataDic.keys.count, totalPackageCount: self.fileTotalPackageCount, numberIndex: self.fileNumber)
                                            }
                                            
                                        }
                                    }
                                }
                            }
                            
                            if val[1] == 0x86 {
                                let number = (Int(newVal[0]) << 8 | Int(newVal[1]))
                                let result = Array(newVal[2..<newVal.count])
                                
                                if let block = self.receiveFileProgressBlock , self.fileTotalPackageCount > 0 {
                                    let packageIndex = (Int(result[0]) << 24 | Int(result[1]) << 16 | Int(result[2]) << 8 | Int(result[3]))
                                    var dicData = Array(result[4..<result.count])
                                    self.fileDataDic["\(packageIndex)"] = Data.init(bytes: dicData, count: dicData.count)
                                    block(Float(self.fileDataDic.keys.count)/Float(self.fileTotalPackageCount))
                                }
                                
                                if self.fileDataDic.keys.count == self.fileTotalPackageCount {
                                    let allData = self.mergeDictionaryData(dic: self.fileDataDic)
                                    self.fileTotalPackageCount = 0//结束之后把总包改为默认值
                                    self.fileDataDic.removeAll()
                                    self.recordingFileReciveDetectionTimerInvalid()
                                    
                                    if let name = self.currentFileName {
                                        let filePath = defaultSdkFilePath + name
                                        FileManager.removefile(filePath: filePath)
                                    }
                                    
                                    if FileManager.createFile(filePath: self.recordingFilePath).isSuccess {
                                        FileManager.default.createFile(atPath: self.recordingFilePath, contents: allData, attributes: nil)
                                        
                                        let format = JLOpusFormat.defaultFormats()
                                        format.hasDataHeader = false
                                        let decoder = JLOpusDecoder(decoder: format, delegate: self)

                                        let outPath = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".pcm")
                                        decoder.opusDecodeFile(self.recordingFilePath, outPut: outPath) { filePath, error in
                                            if let path = filePath {
                                                print("转换wav")
                                                let pathUrl = URL.init(fileURLWithPath: path)
                                                if let fileData = try? Data.init(contentsOf: pathUrl) {
                                                    let wavFile = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".wav")
                                                    if FileManager.createFile(filePath: wavFile).isSuccess {
                                                        if let _ = try? JLPcmToWav.convertPCMData(fileData, toWAVFile: wavFile, sampleRate: 16000, numChannels: 1, bitsPerSample: 16) {
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                   
                                    if let block = self.receiveDownloadFileDataBlock {
                                        let finalPath = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".wav")
                                        block(allData,finalPath,.none)
                                    }
                                                                        
                                }else{
                                    if self.fileDataDic.keys.count % self.defaultRequestPackageCount == 0 {
                                        if let block = self.currentPackageSendComplete {
                                            block()
                                            self.currentPackageSendComplete = nil
                                        }
                                    }
                                }
                            }
                            
                            if val[1] == 0x88 {
                                if let name = self.deleteFileName {
                                    let filePath = defaultSdkFilePath + name
                                    FileManager.removefile(filePath: filePath)
                                }
                                if let block = self.receiveSetSingleDeleteFileBlock {
                                    self.parseUniversalResponse(result: 0x00, success: block)
                                }
                            }
                            
                            if val[1] == 0x89 {
                                if let nameList = self.deleteFileNameList {
                                    for name in nameList {
                                        let filePath = defaultSdkFilePath + name
                                        FileManager.removefile(filePath: filePath)
                                    }
                                }
                                if let block = self.receiveSetBatchDeleteFileBlock {
                                    self.parseUniversalResponse(result: 0x00, success: block)
                                }
                            }
                            
                            if val[1] == 0x8a {
                                if let block = self.receiveSetPauseFileUploadBlock {
                                    self.parseUniversalResponse(result: 0x00, success: block)
                                }
                            }
                            
                            if val[1] == 0x90 {
                                if let block = self.receiveSetTimeBlock {
                                    self.parseUniversalResponse(result: 0x00, success: block)
                                }
                            }
                            
                            if val[1] == 0x91 {
                                
                                if let block = self.receiveGetDeviceStateBlock {
                                    self.parseGetDeviceState(val: newVal, success: block)
                                }
                            }
                            
                            self.newProtocalData = nil
                             
                        }

                    }else{

                        let totalLength = (Int(val[2]) << 8 | Int(val[3]))
                        if totalLength == val.count - 6 {
                            if val[1] == 0x82 {
                                if let block = self.receiveSetCheckFileListBlock {
                                    self.parseSetCheckFileList(val: Array(val[4..<(val.count-2)]), success: block)
                                }
                            }
                            if val[1] == 0x87 {
                                if let block = self.receiveSetFileListRefreshBlock {
                                    let resultArray = Array(val[4..<(val.count-2)])
                                    let fileCount = (Int(resultArray[0]) << 8 | Int(resultArray[1]))
                                    block(fileCount,.none)
                                }
                            }
                            
                            if val[1] == 0x83 {
                                let resultArray = Array(val[4..<(val.count-2)])
                                
                                self.fileSize = (Int(resultArray[0]) << 24 | Int(resultArray[1]) << 16 | Int(resultArray[2]) << 8 | Int(resultArray[3]))
                                let maxCount = (Int(resultArray[4]) << 8 | Int(resultArray[5]))
                                self.fileNumber = (Int(resultArray[6]) << 8 | Int(resultArray[7]))
                                let fileNameLength = (Int(resultArray[8]) << 8 | Int(resultArray[9]))
                                let fileNameVal = Array.init(resultArray[(10)..<(10+fileNameLength)])
                                let fileNameData = fileNameVal.withUnsafeBufferPointer { (bytes) -> Data in
                                    return Data.init(buffer: bytes)
                                }
                                var fileName = ""
                                if let str = String.init(data: fileNameData, encoding: .utf8) {
                                    fileName = str
                                }
                                
                                print("fileSize=\(self.fileSize),maxCount=\(maxCount),fileNumber=\(self.fileNumber),fileName=\(fileName)")
                                ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "fileSize=\(self.fileSize),maxCount=\(maxCount),fileNumber=\(self.fileNumber),fileName=\(fileName)"))
                                
                                
                                let packageCount = self.fileSize/maxCount + (self.fileSize % maxCount > 0 ? 1 : 0)
                                self.fileTotalPackageCount = packageCount
                                                                
                                if let block = self.receiveSetStartFileUploadBlock {
                                    self.parseSetStartFileUpload(val: resultArray, success: block)
                                }
                                
                                if let block = self.reciveSetDownloadFileDataBlock {
                                    block()
                                    self.reciveSetDownloadFileDataBlock = nil
                                }
                            }
                            
                            if val[1] == 0x85 {
                                if self.recordingFileReciveDetectionTimer == nil {
                                    self.recordingFileReciveDetectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.recordingFileReciveDetectionTimerMethod), userInfo: nil, repeats: true)
                                }
                                //有收到数据就把这里的计时器清空
                                self.recordingFileReciveDetectionCount = 0
                                let resultArray = Array(val[4..<(val.count-2)])
                                let number = (Int(resultArray[0]) << 8 | Int(resultArray[1]))
                                let result = Array(resultArray[2..<resultArray.count])
                                
                                print("receiveFileProgressBlock = \(self.receiveFileProgressBlock),self.fileTotalPackageCount = \(self.fileTotalPackageCount)")
                                if number == self.fileNumber,let block = self.receiveFileProgressBlock , self.fileTotalPackageCount > 0 {
                                                                        
                                    let packageIndex = (Int(result[0]) << 24 | Int(result[1]) << 16 | Int(result[2]) << 8 | Int(result[3]))
                                    var dicData = Array(result[4..<result.count])
                                    self.fileDataDic["\(packageIndex)"] = Data.init(bytes: dicData, count: dicData.count)
                                    block(Float(self.fileDataDic.keys.count)/Float(self.fileTotalPackageCount))
                                    print("序号packageIndex = \(packageIndex)")
                                                                        
                                    if self.fileDataDic.keys.count == self.fileTotalPackageCount {
                                        let allData = self.mergeDictionaryData(dic: self.fileDataDic)
                                        self.fileTotalPackageCount = 0//结束之后把总包改为默认值
                                        self.fileDataDic.removeAll()
                                        self.recordingFileReciveDetectionTimerInvalid()
                                        
                                        if let name = self.currentFileName {
                                            let filePath = defaultSdkFilePath + name
                                            FileManager.removefile(filePath: filePath)
                                        }
                                        
                                        if FileManager.createFile(filePath: self.recordingFilePath).isSuccess {
                                            FileManager.default.createFile(atPath: self.recordingFilePath, contents: allData, attributes: nil)
                                            
                                            let format = JLOpusFormat.defaultFormats()
                                            format.hasDataHeader = false
                                            let decoder = JLOpusDecoder(decoder: format, delegate: self)

                                            let outPath = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".pcm")
                                            decoder.opusDecodeFile(self.recordingFilePath, outPut: outPath){ filePath, error in
                                                if let path = filePath {
                                                    print("转换wav")
                                                    let pathUrl = URL.init(fileURLWithPath: path)
                                                    if let fileData = try? Data.init(contentsOf: pathUrl) {
                                                        let wavFile = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".wav")
                                                        if FileManager.createFile(filePath: wavFile).isSuccess {
                                                            if let _ = try? JLPcmToWav.convertPCMData(fileData, toWAVFile: wavFile, sampleRate: 16000, numChannels: 1, bitsPerSample: 16) {
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if let block = self.receiveDownloadFileDataBlock {
                                            let finalPath = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".wav")
                                            block(allData,finalPath,.none)
                                        }
                                        
                                    }else{
                                        //判断fileTotalPackageCount的整数倍
                                        //print("(packageIndex+1) % self.defaultRequestPackageCount = \((packageIndex+1) % self.defaultRequestPackageCount)")
                                        if (self.fileDataDic.keys.count) % self.defaultRequestPackageCount == 0 {
                                            // 高效获取最大键
                                            let maxKey = self.fileDataDic.keys.max {
                                                guard let a = Int($0), let b = Int($1) else { return false }
                                                return a < b
                                            }
                                            let maxInt = Int(maxKey ?? "0") ?? 0
                                            let upCount = maxInt % self.defaultRequestPackageCount == 0 ? maxInt : ((maxInt / self.defaultRequestPackageCount) + 1)*self.defaultRequestPackageCount
                                            let sendArray = self.findMissingKeys(in: self.fileDataDic, upTo: upCount)
                                            if sendArray.count > 0 {
                                                print("有补传序号:\(sendArray),-2-2-2-2 self.fileDataDic.keys.count = \(self.fileDataDic.keys.count)")
                                                self.setFileDataReplenishmentSend(numberIndex: self.fileNumber, packageList: sendArray)
                                                self.currentPackageSendComplete = {
                                                    self.dealFileDownload(index: self.fileDataDic.keys.count, totalPackageCount: self.fileTotalPackageCount, numberIndex: self.fileNumber)
                                                }
                                            }else{
                                                if let name = self.currentFileName {
                                                    let filePath = defaultSdkFilePath + name
                                                    print("val[1] == 0x85 -->>> 写入name:\(name),dic.keys.count = \(self.fileDataDic.keys.count)")
                                                    FileManager.writeDicToFile(content: self.fileDataDic, writePath: filePath)
                                                }
                                                self.dealFileDownload(index: self.fileDataDic.keys.count, totalPackageCount: self.fileTotalPackageCount, numberIndex: self.fileNumber)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if val[1] == 0x86 {
                                let resultArray = Array(val[4..<(val.count-2)])
                                let number = (Int(resultArray[0]) << 8 | Int(resultArray[1]))
                                let result = Array(resultArray[2..<resultArray.count])
                                                                
                                if let block = self.receiveFileProgressBlock , self.fileTotalPackageCount > 0 {
                                    let packageIndex = (Int(result[0]) << 24 | Int(result[1]) << 16 | Int(result[2]) << 8 | Int(result[3]))
                                    let dicData = Array(result[4..<result.count])
                                    self.fileDataDic["\(packageIndex)"] = Data.init(bytes: dicData, count: dicData.count)
                                    block(Float(self.fileDataDic.keys.count)/Float(self.fileTotalPackageCount))
                                }
                                
                                if self.fileDataDic.keys.count == self.fileTotalPackageCount {
                                    let allData = self.mergeDictionaryData(dic: self.fileDataDic)
                                    self.fileTotalPackageCount = 0//结束之后把总包改为默认值
                                    self.fileDataDic.removeAll()
                                    self.recordingFileReciveDetectionTimerInvalid()
                                    
                                    if let name = self.currentFileName {
                                        let filePath = defaultSdkFilePath + name
                                        FileManager.removefile(filePath: filePath)
                                    }
                                    
                                    if FileManager.createFile(filePath: self.recordingFilePath).isSuccess {
                                        FileManager.default.createFile(atPath: self.recordingFilePath, contents: allData, attributes: nil)
                                        
                                        let format = JLOpusFormat.defaultFormats()
                                        format.hasDataHeader = false
                                        let decoder = JLOpusDecoder(decoder: format, delegate: self)

                                        let outPath = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".pcm")
                                        decoder.opusDecodeFile(self.recordingFilePath, outPut: outPath) { filePath, error in
                                            if let path = filePath {
                                                print("转换wav")
                                                let pathUrl = URL.init(fileURLWithPath: path)
                                                if let fileData = try? Data.init(contentsOf: pathUrl) {
                                                    let wavFile = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".wav")
                                                    if FileManager.createFile(filePath: wavFile).isSuccess {
                                                        if let _ = try? JLPcmToWav.convertPCMData(fileData, toWAVFile: wavFile, sampleRate: 16000, numChannels: 1, bitsPerSample: 16) {
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                   
                                    if let block = self.receiveDownloadFileDataBlock {
                                        let finalPath = self.recordingFilePath.replacingOccurrences(of: ".opus", with: ".wav")
                                        block(allData,finalPath,.none)
                                    }
                                                                        
                                }else{
                                    if self.fileDataDic.keys.count % self.defaultRequestPackageCount == 0 {
                                        if let block = self.currentPackageSendComplete {
                                            block()
                                            self.currentPackageSendComplete = nil
                                        }
                                    }
                                }
                            }
                            
                            if val[1] == 0x88 {
                                if let name = self.deleteFileName {
                                    let filePath = defaultSdkFilePath + name
                                    FileManager.removefile(filePath: filePath)
                                }
                                if let block = self.receiveSetSingleDeleteFileBlock {
                                    self.parseUniversalResponse(result: 0x00, success: block)
                                }
                            }
                            
                            if val[1] == 0x89 {
                                if let nameList = self.deleteFileNameList {
                                    for name in nameList {
                                        let filePath = defaultSdkFilePath + name
                                        FileManager.removefile(filePath: filePath)
                                    }
                                }
                                if let block = self.receiveSetBatchDeleteFileBlock {
                                    self.parseUniversalResponse(result: 0x00, success: block)
                                }
                            }
                            
                            if val[1] == 0x8a {
                                if let block = self.receiveSetPauseFileUploadBlock {
                                    self.parseUniversalResponse(result: 0x00, success: block)
                                }
                            }
                            
                            if val[1] == 0x90 {
                                if let block = self.receiveSetTimeBlock {
                                    self.parseUniversalResponse(result: 0x00, success: block)
                                }
                            }
                            if val[1] == 0x91 {
                                let resultArray = Array(val[4..<(val.count-2)])
                                
                                if let block = self.receiveGetDeviceStateBlock {
                                    self.parseGetDeviceState(val: resultArray, success: block)
                                }
                            }
                            
                        }else{
                            ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "%@", "协议长度校验出错"))
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
            ZyboxSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
            printLog("send",dataString)
            self.peripheral?.writeValue(data, for: self.writeCharacteristic!, type: ((self.writeCharacteristic!.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
        }else{
            
            ZyboxSDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
            printLog("写特征为空")
            
        }
    }
    
    @objc public func checkCurrentCommamdIsNeedWait() -> Bool {
        printLog("self.semaphoreCount =",self.semaphoreCount)
        printLog("self.commandListArray.count =",self.commandListArray.count)
        return self.commandListArray.count <= 0 ? false : true
    }
    
    func writeDataAndBackError(data:Data) -> ZyboxError {
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
                
                ZyboxSDKLog.writeStringToSDKLog(string: "发送失败:写特征为空")
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
                            ZyboxSDKLog.writeStringToSDKLog(string: "发送超时的命令:"+lastString)
                            printLog("timedOut -> self.semaphoreCount =",self.semaphoreCount)
                        }
                        
                        let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
                        ZyboxSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
                                            
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
    
    // MARK: - 监测录音文件上传定时器
    @objc func recordingFileReciveDetectionTimerMethod() {
        if self.recordingFileReciveDetectionCount >= self.recordingFileReciveTimeout {
            if self.fileTotalPackageCount > 0 {
                print("定时器 recordingFileReciveDetectionTimerMethod")
                self.dealFileDownload(index: 0, totalPackageCount: self.fileTotalPackageCount, numberIndex: self.fileNumber)
            }
        }
    }

    // MARK: - 销毁监测录音文件上传定时器
    func recordingFileReciveDetectionTimerInvalid() {
        if self.recordingFileReciveDetectionTimer != nil {
            self.recordingFileReciveDetectionTimer?.invalidate()
            self.recordingFileReciveDetectionTimer = nil
            print("recordingFileReciveDetectionTimer 定时器销毁 \(self.recordingFileReciveDetectionTimer)")
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
        //目前SDK内部重置会在重连、断开连接、关闭蓝牙三个地方调用
        let resetCount = 1-self.semaphoreCount
        if showLog == true {
            ZyboxSDKLog.writeStringToSDKLog(string: "同步异常处理，取消后续命令发送")
        }else{
            ZyboxSDKLog.writeStringToSDKLog(string: "重连、断开连接、关闭蓝牙，取消后续命令发送")
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
    
    // MARK: - 录音文件列表查询
    public func setCheckFileList(index:Int,fileCount:Int,success:@escaping(([ZyboxRecordFileModel],ZyboxError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xbb,
            0x02
        ]
        
        let contentVal:[UInt8] = [
            UInt8((index >> 8) & 0xff),
            UInt8((index ) & 0xff),
            UInt8((fileCount >> 8) & 0xff),
            UInt8((fileCount) & 0xff),
        ]
        
        self.dealRecordBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetCheckFileListBlock = success
            }else{
                
            }
            self?.signalCommandSemaphore()
        }
    }
    
    private func parseSetCheckFileList(val:[UInt8],success:@escaping(([ZyboxRecordFileModel],ZyboxError) -> Void)) {
        
        if val.count > 4 {
            let originIndex = (Int(val[0]) << 8 | Int(val[1]))
            let fileCount = (Int(val[2]) << 8 | Int(val[3]))
            var stringArray:[[String]] = .init()
            var modelArray:[ZyboxRecordFileModel] = .init()
            var startIndex = 4
            let format = DateFormatter()
            format.dateFormat = "yyMMdd_HHmmss"
            while startIndex < val.count {
                var array = [String]()
                let index = (Int(val[startIndex+0]) << 8 | Int(val[startIndex+1]))
                let fileLength = Int(val[startIndex+2])
                let fileNameVal = Array.init(val[(startIndex+3)..<(startIndex+3+fileLength)])
                let fileTimeLength = (Int(val[startIndex+3+fileLength]) << 24 | Int(val[startIndex+4+fileLength]) << 16 | Int(val[startIndex+5+fileLength]) << 8 | Int(val[startIndex+6+fileLength]))
                let fileNameData = fileNameVal.withUnsafeBufferPointer { (bytes) -> Data in
                    return Data.init(buffer: bytes)
                }
                print("convertDataToSpaceHexStr =\(self.convertDataToSpaceHexStr(data: fileNameData, isSend: true))")
                print("startIndex = \(startIndex),index = \(index),fileLength = \(fileLength),fileTimeLength = \(fileTimeLength)")
                if let str = String.init(data: fileNameData, encoding: .utf8) {
                    print("str = \(str)")
                    array.append("\(index)")
                    array.append("\(str)")
                    array.append("\(fileTimeLength)")
                    let model = ZyboxRecordFileModel()
                    model.fileName = str
                    model.fileTimeLength = fileTimeLength
                    if let nameArrayFirtst = str.components(separatedBy: ".").first?.replacingOccurrences(of: "MIC", with: "") {
                        if let date = format.date(from: nameArrayFirtst) {
                            let timestamp = Int(date.timeIntervalSince1970)
                            if timestamp > 0 {
                                model.fileCreateTime = timestamp
                            }
                        }
                    }
                    modelArray.append(model)
                    stringArray.append(array)
                }
                startIndex += 7+fileLength
            }
            
            var string = ""
            for item in stringArray {
                string += String.init(format: "\n%@",item)
            }
            ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "解析:%@",string))
            success(modelArray,.none)
        }else{
            success([],.fail)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }
    
    // MARK: - 下载完整文件数据
    public func setDownloadFileData(name:String,folderPath:String? = nil,progress:@escaping((Float)->Void),success:@escaping((Data,String,ZyboxError) -> Void)) {
        
        var filePath = ""
        if let path = folderPath {
            filePath = path+name
        }else{
            filePath = FileManager.default.temporaryDirectory.appendingPathComponent(filePath).path+name
        }
        print("self.recordingFilePath = \(self.recordingFilePath)")
        self.recordingFilePath = filePath
        
        let headVal:[UInt8] = [
            0xbb,
            0x03
        ]
        
        var nameVal:[UInt8] = .init()
        if let data:Data = name.data(using: .utf8) {
            nameVal = data.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
            }
        }
        self.recordingFileReciveDetectionTimerInvalid()
        self.dealRecordBoxData(headVal: headVal, contentVal: nameVal) { [weak self] error in
            if error == .none {
                if let self = self {
                    self.reciveSetDownloadFileDataBlock = {
                        let filePath = defaultSdkFilePath + name
                        if FileManager.createFolder(folderPath: defaultSdkFilePath).isSuccess {
                            print("\(defaultSdkFilePath)文件夹创建成功")
                        }
                        if FileManager.createFile(filePath: filePath).isSuccess {
                            print("\(filePath)文件创建成功")
                        }
                        self.currentFileName = name
                        self.parseSetDownloadFileData(progress: progress, success: success)
                    }
                }
                
            }else{
                success(.init(),.init(),.fail)
            }
        }
    }
    
    func parseSetDownloadFileData(progress:@escaping((Float)->Void),success:@escaping((Data,String,ZyboxError) -> Void)) {
        self.fileDataDic.removeAll()
        if let name = self.currentFileName {
            let filePath = defaultSdkFilePath + name
            if let dic = FileManager.readDicFromFile(readPath: filePath).content as? [String:Data] {
                print("读取name = \(name),dic.count = \(dic.count)")
                self.fileDataDic = dic
            }
            self.receiveDownloadFileDataBlock = success
            self.receiveFileProgressBlock = progress
            self.dealFileDownload(index: 0, totalPackageCount: self.fileTotalPackageCount, numberIndex: self.fileNumber)
        }
        
    }
    
    // MARK: - 处理文件下载
    /// <#Description#>
    /// - Parameters:
    ///   - index: 当前请求序号
    ///   - totalPackageCount: 总包数
    ///   - numberIndex: 流水号
    func dealFileDownload(index:Int,totalPackageCount:Int, numberIndex:Int) {
        
        if index == 0 {
            let maxCount = (self.fileDataDic.keys.count / self.defaultRequestPackageCount) * self.defaultRequestPackageCount
            let dicCount = maxCount + (self.fileDataDic.keys.count % self.defaultRequestPackageCount > 0 ? self.defaultRequestPackageCount : 0)
            
            if dicCount == 0 {
                self.setStartFileDataUpload(index: 0, packageCount: self.defaultRequestPackageCount, numberIndex: numberIndex)
            }else{
                let startIndex = self.fileDataDic.keys.count - (self.fileDataDic.keys.count % self.defaultRequestPackageCount)
                // 高效获取最大键
                let maxKey = self.fileDataDic.keys.max {
                    guard let a = Int($0), let b = Int($1) else { return false }
                    return a < b
                }
                let maxInt = Int(maxKey ?? "0") ?? 0
                let upCount = maxInt % self.defaultRequestPackageCount == 0 ? maxInt : ((maxInt / self.defaultRequestPackageCount) + 1)*self.defaultRequestPackageCount
                let sendArray = self.findMissingKeys(in: self.fileDataDic, upTo: upCount)
                if sendArray.count > 0 {
                    print("有补传序号:\(sendArray),-3-3-3-3 self.fileDataDic.keys.count = \(self.fileDataDic.keys.count)")
                    self.setFileDataReplenishmentSend(numberIndex: self.fileNumber, packageList: sendArray)
                }else{
                    self.setStartFileDataUpload(index: startIndex, packageCount: self.defaultRequestPackageCount, numberIndex: numberIndex)
                }
                print("maxInt = \(maxInt),upCount = \(upCount),self.fileDataDic.keys.count = \(self.fileDataDic.keys.count)")
            }
        }else{
            
            self.setStartFileDataUpload(index: index, packageCount: self.defaultRequestPackageCount, numberIndex: numberIndex)
        }

    }

    
    // MARK: - 启动录音文件上传
    public func setStartFileUpload(name:String,success:@escaping((ZyboxRecordFileDataModel?,ZyboxError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xbb,
            0x03
        ]
        
        var nameVal:[UInt8] = .init()
        if let data:Data = name.data(using: .utf8) {
            nameVal = data.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
            }
        }
        
        self.dealRecordBoxData(headVal: headVal, contentVal: nameVal) { [weak self] error in
            if error == .none {
                self?.receiveSetStartFileUploadBlock = success
            }else{
                success(nil,.fail)
            }
        }
    }
    
    private func parseSetStartFileUpload(val:[UInt8],success:@escaping((ZyboxRecordFileDataModel?,ZyboxError) -> Void)) {
        
        if val.count > 10 {
            let fileSize = (Int(val[0]) << 24 | Int(val[1]) << 16 | Int(val[2]) << 8 | Int(val[3]))
            let maxCount = (Int(val[4]) << 8 | Int(val[5]))
            let numberIndex = (Int(val[6]) << 8 | Int(val[7]))
            let fileNameLength = (Int(val[8]) << 8 | Int(val[9]))
            let fileNameVal = Array.init(val[(10)..<(10+fileNameLength)])
            let fileNameData = fileNameVal.withUnsafeBufferPointer { (bytes) -> Data in
                return Data.init(buffer: bytes)
            }
            
            let model = ZyboxRecordFileDataModel()
            model.fileSize = fileSize
            model.maxLength = maxCount
            model.numberIndex = numberIndex
            
            if let str = String.init(data: fileNameData, encoding: .utf8) {
                model.fileName = str
            }
            
            print("model.fileSize=\(model.fileSize),model.maxLength=\(model.maxLength),model.numberIndex=\(model.numberIndex),model.fileName=\(model.fileName)")
            ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "model.fileSize=\(model.fileSize),model.maxLength=\(model.maxLength),model.numberIndex=\(model.numberIndex),model.fileName=\(model.fileName)"))
            success(model,.none)
        }else{
            success(nil,.fail)
        }

        //printLog("第\(#line)行" , "\(#function)")
        self.signalCommandSemaphore()
    }

    // MARK: - 请求录音文件数据上传
    public func setStartFileDataUpload(index:Int,packageCount:Int,numberIndex:Int) {
        print("当前序号:\(index),包数:\(packageCount),流水号:\(numberIndex)")
        let headVal:[UInt8] = [
            0xbb,
            0x04
        ]
        
        let contentVal:[UInt8] = [
            UInt8((index >> 32) & 0xff),
            UInt8((index >> 16) & 0xff),
            UInt8((index >> 8) & 0xff),
            UInt8((index) & 0xff),
            UInt8((packageCount >> 8) & 0xff),
            UInt8((packageCount) & 0xff),
            UInt8((numberIndex >> 8) & 0xff),
            UInt8((numberIndex ) & 0xff),
        ]
        self.dealRecordBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            self?.signalCommandSemaphore()
            //根据当前文件名保存数据，下次续传用
        }
    }
    
    // MARK: - 录音文件数据补传
    public func setFileDataReplenishmentSend(numberIndex:Int,packageList:[Int]) {
        
        print("录音文件数据补传 流水号:\(numberIndex),packageList.count = \(packageList.count)")
        let headVal:[UInt8] = [
            0xbb,
            0x06
        ]
        
        var contentVal:[UInt8] = [
            UInt8((numberIndex >> 8) & 0xff),
            UInt8((numberIndex ) & 0xff),
            UInt8((packageList.count >> 8) & 0xff),
            UInt8((packageList.count ) & 0xff),
        ]
        
        for index in packageList {
            let itemVal:[UInt8] = [
                UInt8((index >> 32) & 0xff),
                UInt8((index >> 16) & 0xff),
                UInt8((index >> 8) & 0xff),
                UInt8((index ) & 0xff),
            ]
            contentVal.append(contentsOf: itemVal)
        }
        
        self.dealRecordBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            self?.signalCommandSemaphore()
        }
    }


    // MARK: - 录音文件列表刷新
    public func setFileListRefresh(success:@escaping((Int,ZyboxError) -> Void)) {
        let headVal:[UInt8] = [
            0xbb,
            0x07
        ]
                
        self.dealRecordBoxData(headVal: headVal, contentVal: []) { [weak self] error in
            if error == .none {
                self?.receiveSetFileListRefreshBlock = success
            }else{
                success(0,.fail)
            }
        }
    }

    // MARK: - 录音文件删除
    public func setSingleDeleteFile(name:String,success:@escaping((ZyboxError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xbb,
            0x08
        ]
        
        var nameVal:[UInt8] = .init()
        if let data:Data = name.data(using: .utf8) {
            nameVal = data.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
            }
        }
        
        self.dealRecordBoxData(headVal: headVal, contentVal: nameVal) { [weak self] error in
            if error == .none {
                self?.deleteFileName = name
                self?.receiveSetSingleDeleteFileBlock = success
            }else{
                success(error)
            }
        }
    }

    // MARK: 录音文件批量删除
    public func setBatchDeleteFile(nameList:[String],success:@escaping((ZyboxError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xbb,
            0x09
        ]
        
        var contentVal:[UInt8] = [
            UInt8((nameList.count >> 8) & 0xff),
            UInt8((nameList.count ) & 0xff),
        ]
        
        for item in nameList {
            var nameVal:[UInt8] = .init()
            if let data:Data = item.data(using: .utf8) {
                nameVal = data.withUnsafeBytes { (byte) -> [UInt8] in
                    let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                    return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
                }
            }
            contentVal.append(UInt8((nameVal.count >> 8) & 0xff))
            contentVal.append(UInt8((nameVal.count ) & 0xff))
            contentVal.append(contentsOf: nameVal)
        }
        
        self.dealRecordBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            
            if error == .none {
                self?.deleteFileNameList = nameList
                self?.receiveSetBatchDeleteFileBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 录音文件上传暂停
    public func setPauseFileUpload(name:String,success:@escaping((ZyboxError) -> Void)) {
        
        let headVal:[UInt8] = [
            0xbb,
            0x0a
        ]
        
        var nameVal:[UInt8] = .init()
        if let data:Data = name.data(using: .utf8) {
            nameVal = data.withUnsafeBytes { (byte) -> [UInt8] in
                let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
                return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
            }
        }
        
        //上传暂停
        if let fileName = self.currentFileName {
            let filePath = defaultSdkFilePath + fileName

            print("写入name:\(fileName),self.fileDataDic.key.count = \(self.fileDataDic.keys.count)")
            FileManager.writeDicToFile(content: self.fileDataDic, writePath: filePath)
            self.currentFileName = nil
        }
        //暂停了不能再同步进度
        self.receiveFileProgressBlock = nil
        self.fileTotalPackageCount = 0
        self.fileDataDic.removeAll()
        self.recordingFileReciveDetectionTimerInvalid()
        
        print("暂停文件名:\(name),headVal = \(self.convertDataToHexStr(data: Data.init(bytes: headVal, count: headVal.count)))")
        self.dealRecordBoxData(headVal: headVal, contentVal: nameVal) { [weak self] error in
            if error == .none {
                self?.receiveSetPauseFileUploadBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 同步时间
    public func setTime(time:Any? = nil,success:@escaping((ZyboxError) -> Void)) {
        
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
        
        let headVal:[UInt8] = [
            0xbb,
            0x10
        ]
         
        let contentVal = [UInt8(year%2000),UInt8(month),UInt8(day),UInt8(hour),UInt8(minute),UInt8(second)]
        
        self.dealRecordBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveSetTimeBlock = success
            }else{
                success(error)
            }
        }
    }
    
    // MARK: - 获取设备状态
    public func getDeviceState(success:@escaping((_ model:ZyboxRecordStateModel?,_ error:ZyboxError)->Void)) {
        let headVal:[UInt8] = [
            0xbb,
            0x11
        ]
        let listArray = [0,1,2,3,4]
        var contentVal:[UInt8] = []
        contentVal.append(UInt8(listArray.count))
        for item in listArray {
            contentVal.append(UInt8(item))
        }
        
        self.dealRecordBoxData(headVal: headVal, contentVal: contentVal) { [weak self] error in
            if error == .none {
                self?.receiveGetDeviceStateBlock = success
            }else{
                success(nil,error)
            }
        }
    }
    
    private func parseGetDeviceState(val:[UInt8],success:@escaping((ZyboxRecordStateModel?,ZyboxError) -> Void)) {
        let valData = val.withUnsafeBufferPointer { (v) -> Data in
            return Data.init(buffer: v)
        }
        
        ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "parseGetDeviceState待解析数据:\nlength = %d, bytes = %@",valData.count, self.convertDataToHexStr(data: valData)))

        let model = ZyboxRecordStateModel()
        let count:Int = Int(val[0])
        var index = 1
        for _ in 0..<count {
            let functionId = val[index]
            let functionLength = val[index+1]
            let functionVal = Array.init(val[(index+2)..<(index+2+Int(functionLength))])
            
            let functionData = functionVal.withUnsafeBufferPointer({ (bytes) -> Data in
                let byte = bytes.baseAddress!
                return Data.init(bytes: byte, count: functionVal.count)
            })
            
            switch functionId {
            case 0:
                let battery = Int(functionVal[0])
                model.battery = battery
                ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "battery = %d",battery))
                break
            case 1:
                let state = Int(functionVal[0])
                model.recordingState = state
                ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "recordingState = %d",state))
                
                break
            case 2:
                let timeout = (Int(functionVal[0]) << 8 | Int(functionVal[1]))
                model.broadcastTimeout = timeout
                ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "broadcastTimeout = %d",timeout))
                
                break
                
            case 3:
                
                let versionData = functionVal.withUnsafeBufferPointer { (bytes) -> Data in
                    return Data.init(buffer: bytes)
                }
                
                if let versionString = String.init(data: versionData, encoding: .utf8) {
                    model.versionString = versionString
                    
                    ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "versionString = %@",versionString))
                }
                
                break
            case 4:
                let value1 = (Int(functionVal[0]) << 24 | Int(functionVal[1]) << 16 | Int(functionVal[2]) << 8 | Int(functionVal[3]))
                let value2 = (Int(functionVal[4]) << 24 | Int(functionVal[5]) << 16 | Int(functionVal[6]) << 8 | Int(functionVal[7]))
                
                model.tCardTotalSize = value1
                model.tCardRemainderSize = value2
                ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "tCardTotalSize = %d,tCardRemainderSize = %d",value1,value2))
                break
            
            default:
                break
            }
            index = (index+2+Int(functionLength))
        }
        success(model,.none)
        
        self.signalCommandSemaphore()
    }

    // MARK: - 恢复出厂设置
    
    // MARK: - 录音控制 0关1开

    
    func dealRecordBoxData(headVal:[UInt8],contentVal:[UInt8],backBlock:@escaping((ZyboxError)->())) {
        var headVal = headVal
        var dataArray:[Data] = []
        var firstBit:UInt8 = 0
        var maxMtuCount = 0
        if contentVal.count > self.testMaxMtuCount {
            firstBit = 128
        }
        maxMtuCount = self.testMaxMtuCount
        headVal.append(UInt8((contentVal.count >> 8) & 0xff)+firstBit)
        headVal.append(UInt8((contentVal.count) & 0xff))
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
                    UInt8(((packetCount) >> 8) & 0xff),
                    UInt8(((packetCount) ) & 0xff)
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
                        print("----------->>>多包 send =",dataString)
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
    
    // MARK: - 通用回复
    func parseUniversalResponse(result:UInt8,success:@escaping((ZyboxError) -> Void)) {
        
        let state = String.init(format: "%02x",result)
        
        switch result {
        case 0:
            ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "状态:%@", state))
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
    
    func mergeDictionaryData(dic: [String: Data]) -> Data {
        let sortedData = dic.keys
            .compactMap { key -> (Int, Data)? in
                guard let intKey = Int(key), let data = dic[key] else { return nil }
                return (intKey, data)
            }
            .sorted(by: { $0.0 < $1.0 })

        let totalSize = sortedData.reduce(0) { $0 + $1.1.count }
        return sortedData.reduce(into: Data(capacity: totalSize)) {
            $0.append($1.1)
        }
    }
    
    func findMissingKeys(in dictionary: [String: Any], upTo maxKey: Int) -> [Int] {
        // 提取并过滤有效数字键
        let validNumbers = dictionary.keys.compactMap { key -> Int? in
            guard let num = Int(key), num >= 0 else {
                print("发现无效键：\(key)")
                return nil
            }
            return num
        }
        
        // 处理空字典的特殊情况
        guard !validNumbers.isEmpty else {
            return Array(0..<maxKey)
        }
        
        // 计算缺失键
        let existingNumbers = Set(validNumbers)
        return (0..<maxKey)
            .filter { !existingNumbers.contains($0) }
            //.map { String($0) }
    }
}
