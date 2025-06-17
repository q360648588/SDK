//
//  ZyBaseModule.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2021/4/16.
//

import UIKit
import CoreBluetooth
import zlib

@objc public class ZyboxBaseModule: NSObject {
    
    /// 已配对设备的UUID数组，用来获取被手机系统配对的设备。默认不获取已被手机配对的设备
    @objc public var matchingUUIDArray:[CBUUID]? = nil
    
    /// 过滤设备的UUID数组。默认扫描所有设备
    @objc public var serviceUUIDArray:[CBUUID]? = nil
    
    /// 扫描时间
    @objc dynamic public var scanInterval:Int

    @objc dynamic public internal(set) var peripheral:CBPeripheral? {
        willSet {
            //printLog("旧值 ->",self.peripheral as Any)
            if self.peripheral != nil {
                self.peripheral!.removeObserver(self, forKeyPath: "state")
            }
        }
        didSet {
            //printLog("新值 ->",self.peripheral as Any)
            if self.peripheral != nil {
                self.peripheral!.addObserver(self, forKeyPath: "state", options: [.new,.old], context: nil)
            }
        }
    }
    
    @objc dynamic public var blePowerState:CBManagerState {
        return ZyboxBleManager.shareInstance.getBlePowerState()
    }
    
    var writeCharacteristic:CBCharacteristic?//6E400002-B5A3-F393-E0A9-E50E24DCCA9E
    var receiveCharacteristic:CBCharacteristic?//6E400003-B5A3-F393-E0A9-E50E24DCCA9E
    
    var ant_ReconnectTimer:Timer?
    
    var connectCompleteBlock:((Bool)->())?
    var reconnectComplete:(()->())?
    @objc dynamic public internal(set) var isSyncOtaData = false
    var syncOtaReconnectComplete:(()->())?
    var peripheralStateChange:((CBPeripheralState)->())?
    var isReadSendDataBlock:(()->())?
    @objc public var isHaveWechatSportsServer:Bool = false
    var testMaxMtuCount = 20//专门给录音盒测试用的
    
    override init() {
        self.scanInterval = 30
        super.init()
        let antManager = ZyboxBleManager.shareInstance
        self.ant_ReconnectTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(reconnectMethod), userInfo: nil, repeats: true)
        RunLoop.current.add(self.ant_ReconnectTimer!, forMode: RunLoop.Mode.default)
        
        antManager.DeviceNeedReconnectMothed {
            let userDefault = UserDefaults.standard
            let isNeedReconnect = userDefault.bool(forKey: "Zybox_ReconnectKey")
            
            if isNeedReconnect {
                self.ant_ReconnectTimer?.fireDate = .distantPast
                ZyboxCommandModule.shareInstance.resetCommandSemaphore()
            }
        }
    }
    // MARK: - 外设连接状态变化回调
    /// 外设连接状态变化回调
    /// - Parameter state: <#state description#>
    @objc public func peripheralStateChange(state:@escaping((CBPeripheralState)->())) {
        self.peripheralStateChange = state
    }
    
    @objc public func peripheralIsReadSendData(state:@escaping(()->())) {
        self.isReadSendDataBlock = state
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        printLog("keyPath = \(String(describing: keyPath)),object = \(String(describing: object)),change.new = \(change?[NSKeyValueChangeKey(rawValue: "new")]),change.old = \(change?[NSKeyValueChangeKey(rawValue: "old")]),context = \(String(describing: context))")//
        if keyPath == "state" {
            let state:CBPeripheralState = CBPeripheralState.init(rawValue: change?[NSKeyValueChangeKey(rawValue: "new")] as! Int) ?? .disconnected

            if let block = self.peripheralStateChange {
                block(state)
            }
            
            if state == .disconnected {
                //断开不能调用此方法  会导致升级异常error以及其他bug的出现
                //ZyCommandModule.shareInstance.deviceDisconnectedFail()
            }
        }
    }
    
    // MARK: - 蓝牙状态变化回调
    /// 蓝牙状态变化回调
    /// - Parameter state: <#state description#>
    @objc public func bluetoothPowerStateChange(state:@escaping((CBManagerState)->())) {
        ZyboxBleManager.shareInstance.getBlePowerDidUpdateState { bleState in
            state(bleState)
            if bleState == .poweredOn {
                ZyboxSDKLog.writeStringToSDKLog(string: "系统蓝牙状态:poweredOn")
                self.ant_ReconnectTimer?.fireDate = .distantPast
            }else if bleState == .poweredOff {
                ZyboxSDKLog.writeStringToSDKLog(string: "系统蓝牙状态:poweredOff")
                //命令信号量重置
                ZyboxCommandModule.shareInstance.resetCommandSemaphore()

            }else if bleState == .unknown {
                ZyboxSDKLog.writeStringToSDKLog(string: "系统蓝牙状态:unknown")
            }else if bleState == .resetting {
                ZyboxSDKLog.writeStringToSDKLog(string: "系统蓝牙状态:resetting")
            }else if bleState == .unsupported {
                ZyboxSDKLog.writeStringToSDKLog(string: "系统蓝牙状态:unsupported")
            }else if bleState == .unauthorized {
                ZyboxSDKLog.writeStringToSDKLog(string: "系统蓝牙状态:unauthorized")
            }
        }
    }
    
    // MARK: - ancs共享通知变化回调
    /// ancs共享通知变化回调
    /// - Parameter state: iOS13及以上才会正常返回
    @objc public func bluetoothAncsStateChange(state:@escaping((Bool)->())) {
        ZyboxBleManager.shareInstance.getAncsDidUpdateState(value: state)
    }
    
    @objc func reconnectMethod() {
        printLog("定时器方法")
        let userDefault = UserDefaults.standard
        let isNeedReconnect = userDefault.bool(forKey: "Zybox_ReconnectKey")
        let reconeectString = userDefault.string(forKey: "Zybox_ReconnectIdentifierKey") ?? ""
        printLog("isNeedReconnect = ",isNeedReconnect,"reconeectString =",reconeectString,"state =",ZyboxBleManager.shareInstance.getBlePowerState().rawValue)
        
        var blePower = ""
        let bleState = ZyboxBleManager.shareInstance.getBlePowerState()
        if bleState == .poweredOn {
            blePower = "系统蓝牙状态:poweredOn"
        }else if bleState == .poweredOff {
            blePower = "系统蓝牙状态:poweredOff"
        }else if bleState == .unknown {
            blePower = "系统蓝牙状态:unknown"
        }else if bleState == .resetting {
            blePower = "系统蓝牙状态:resetting"
        }else if bleState == .unsupported {
            blePower = "系统蓝牙状态:unsupported"
        }else if bleState == .unauthorized {
            blePower = "系统蓝牙状态:unauthorized"
        }
        ZyboxSDKLog.writeStringToSDKLog(string: "重连 blePower = \(blePower)")
        ZyboxSDKLog.writeStringToSDKLog(string: "重连 reconeectString = \(reconeectString)")
        ZyboxSDKLog.writeStringToSDKLog(string: "重连 isNeedReconnect = \(isNeedReconnect)")
        
        if ZyboxBleManager.shareInstance.getBlePowerState() == .poweredOn && isNeedReconnect && reconeectString.count > 0 {
            if self.peripheral?.state == .connected {
                printLog("已连接、重连定时器关闭")
                ZyboxSDKLog.writeStringToSDKLog(string: "重连 已连接关闭重连定时器")
                self.ant_ReconnectTimer?.fireDate = .distantFuture
            }else{
                self.connectDevice(peripheral: reconeectString) { result in
                    if result {
                        if !self.isSyncOtaData {
                            if let block = self.reconnectComplete {
                                ZyboxSDKLog.writeStringToSDKLog(string: "重连 reconnectComplete")
                                block()
                            }
                        }else {
                            //在ZyCommandModule类调用服务器升级接口之后会通过此回调重连继续升级
                            if let block = self.syncOtaReconnectComplete {
                                ZyboxSDKLog.writeStringToSDKLog(string: "重连 syncOtaReconnectComplete")
                                block()
                            }
                        }
                    }
                }
            }
        }else{
            printLog("重连标识相关状态不对、重连定时器关闭")
            self.ant_ReconnectTimer?.fireDate = .distantFuture
        }
    }
    // MARK: - 设置是否需要重连
    /// 设置是否需要重连
    /// - Parameter state: true:重连 false:不重连
    @objc public func setIsNeedReconnect(state:Bool) {
        printLog("setIsNeedReconnect =",state)
        let userDefault = UserDefaults.standard
        userDefault.setValue(state, forKey: "Zybox_ReconnectKey")
        userDefault.synchronize()
    }
    // MARK: - 重连成功回调
    /// 重连成功回调
    /// - Parameter complete: <#complete description#>
    @objc public func reconnectDevice(complete:@escaping(()->())) {
        self.reconnectComplete = complete
    }
    @objc public func setTestEnvironment(state:Bool) {
        printLog("setTestEnvironment =",state)
        let userDefault = UserDefaults.standard
        userDefault.setValue(state, forKey: "Zy_TestEnvironment")
        userDefault.synchronize()
    }
    func syncOtaReconnectDevice(complete:@escaping(()->())) {
        self.syncOtaReconnectComplete = complete
    }
    
    func setReconnectIdentifier(identifier:String) {
        let userDefault = UserDefaults.standard
        userDefault.setValue(identifier, forKey: "Zybox_ReconnectIdentifierKey")
        userDefault.synchronize()
    }
    
    // MARK: - 获取重连标识
    /// 获取重连标识
    /// - Returns: 外设唯一标识
    @objc public func getReconnectIdentifier() -> String {
        let userDefault = UserDefaults.standard
        let idString:String = userDefault.string(forKey: "Zybox_ReconnectIdentifierKey") ?? ""
        
        return idString
    }
    // MARK: - 获取系统蓝牙列表的设备
    /// 获取系统列表的设备
    /// - Parameter modelArray: <#modelArray description#>
    @objc open func getSystemListPeripheral(modelArray:@escaping(([ZyboxScanModel])->(Void))) {
        var peripheralArray = [ZyboxScanModel].init()
        
        let connectedArray = ZyboxBleManager.shareInstance.getListConnectPeripheras(serviceArray: self.matchingUUIDArray ?? [])
        if connectedArray.count > 0 {
            for item in connectedArray {
                let model:ZyboxScanModel = ZyboxScanModel.init()
                model.name = item.name
                model.rssi = 0
                model.peripheral = item
                model.uuidString = item.identifier.uuidString
                peripheralArray.append(model)
            }
        }
        modelArray(peripheralArray)
    }
    
    /// 扫描设备，每新增一个设备都会有回调
    /// - Parameters:
    ///   - scanModel: 扫描到的设备
    ///   - modelArray: 所有扫描到的设备数组，包括系统蓝牙列表已连接的
    /// - Returns:
    @objc open func scanDevice(scanModel:@escaping((ZyboxScanModel)->(Void)),modelArray:@escaping(([ZyboxScanModel])->(Void))) {
        var peripheralArray = [ZyboxScanModel].init()
        
        self.stopScan()
        
        let connectedArray = ZyboxBleManager.shareInstance.getListConnectPeripheras(serviceArray: self.matchingUUIDArray ?? [])
        if connectedArray.count > 0 {
            for item in connectedArray {
                let model:ZyboxScanModel = ZyboxScanModel.init()
                model.name = item.name
                model.rssi = 0
                model.peripheral = item
                model.uuidString = item.identifier.uuidString
                print("name = \(item.name)")
                print("identifier.uuidString = \(item.identifier.uuidString)")
                print("identifier.uuid = \(item.identifier.uuid)")
                print("identifier.description = \(item.identifier.description)")
                print("identifier.debugDescription = \(item.identifier.debugDescription)")
                print("services = \(item.services)")
                for server in item.services ?? [] {
                    print("server = \(server)")
                }
                //print("listConnect-> model.uuidString = \(model.uuidString),model.name = \(model.name),item = \(item)")
                peripheralArray.append(model)
            }
            modelArray(peripheralArray)
        }
        
        ZyboxBleManager.shareInstance.scanPeripheralWithServices()
        ZyboxBleManager.shareInstance.CentralDiscoverPeripheral { (manager, peripheral, advertisementData, rssi) in
            let model:ZyboxScanModel = ZyboxScanModel.init()
            model.name = peripheral.name
            model.rssi = Int(truncating: rssi)
            model.peripheral = peripheral
            model.uuidString = peripheral.identifier.uuidString
            var macString:String?
            if let macData:Data = advertisementData["kCBAdvDataManufacturerData"] as? Data {
                var mac:String = ""
                if macData.count > 6 + 6 + 1 {
                    if macData[13] == 0x80 {
                        let newData = macData.subdata(in: 7..<13)
                        //print("--->>> newData = \(self.convertDataToHexStr(data: newData))")
                        mac = self.convertDataToHexStr(data: newData)
                        mac = mac.replacingOccurrences(of: " ", with: "")
                        var index = mac.count
                        while ((index - 2) > 0) {
                            index -= 2
                            mac.insert(":", at: mac.index(mac.startIndex, offsetBy: index))
                        }
                        macString = mac
                    }
                }else if macData.count >= 2 + 6 {
                    var newData = macData.subdata(in: 2..<8)
                    //print("--->>> newData = \(self.convertDataToHexStr(data: newData))")
                    macString = newData.withUnsafeBytes { (bytes) -> String in
                        var dataString = ""
                        for i in stride(from: bytes.count-1, through: 0, by: -1) {
                            let count = UInt8(bytes[i])
                            
                            dataString = dataString + String.init(format: "%02x", count)
                            if i > 0 {
                                dataString += ":"
                            }
                        }
                        return dataString
                    }
                }
                
            }
            model.macString = macString
            if !peripheralArray.contains(where: { item in
                if item.uuidString == model.uuidString {
                    if item.macString?.count ?? 0 == 0 && model.macString?.count ?? 0 > 0 {
                        print("scan-> item.macString = \(item.macString),item.name = \(item.name) model.macString = \(model.macString),model.name = \(model.name)")
                        item.macString = model.macString
                        scanModel(model)
                    }
                    return true
                }
                return false
            }) {
                //print("scan-> model.uuidString = \(model.uuidString),model.name = \(model.name)")
                scanModel(model)
                peripheralArray.append(model)
            }
            peripheralArray.sort { (scanModel1, scanModel2) -> Bool in
                return scanModel1.rssi > scanModel2.rssi
            }
            modelArray(peripheralArray)
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(stopScan), object: nil)
        self.perform(#selector(stopScan), with: nil, afterDelay: TimeInterval(scanInterval))
        
    }
    
    /// 停止扫描
    @objc public func stopScan() {
        ZyboxBleManager.shareInstance.stopScanPeripheral()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(stopScan), object: nil)
    }
    
    /// 连接设备
    /// - Parameters:
    ///   - peripheral: 支持String跟CBPeripheral两种
    ///   - connectState: 连接状态
    /// - Returns:
    @objc public func connectDevice(peripheral:Any,connectState:@escaping((Bool)->())) {
        if self.peripheral != nil && self.peripheral?.state != .disconnected{
            let userDefault = UserDefaults.standard
            let isNeedReconnect = userDefault.bool(forKey: "Zybox_ReconnectKey")
            if !isNeedReconnect {
                printLog("当前有正在连接或正在断开的设备。同时操作多个设备会有异常，此处开发者需要自行处理，保证在连接过程中只有唯一连接")
            }
        }
        self.stopScan()
        if peripheral is String {
            let p = ZyboxBleManager.shareInstance.getPeripheral(string: peripheral as! String)
            if p != nil {
                if self.peripheral != p! {
                    self.peripheral = p!
                }
                if #available(iOS 13.0, *) {
                    ZyboxBleManager.shareInstance.connect(peripheral: p!, options: [CBConnectPeripheralOptionRequiresANCS:true,
                                                                      CBConnectPeripheralOptionNotifyOnDisconnectionKey:true,
                                                                    CBConnectPeripheralOptionEnableTransportBridgingKey:true,
                                                                                 ])
                } else {
                    ZyboxBleManager.shareInstance.connect(peripheral: p!, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
                }
            }else{
                connectState(false)
            }
        }else if peripheral is CBPeripheral {
            if self.peripheral != peripheral as? CBPeripheral {
                self.peripheral = peripheral as? CBPeripheral
            }
            if #available(iOS 13.0, *) {
                ZyboxBleManager.shareInstance.connect(peripheral: peripheral as! CBPeripheral, options: [CBConnectPeripheralOptionRequiresANCS:true,CBConnectPeripheralOptionNotifyOnDisconnectionKey:true,CBConnectPeripheralOptionEnableTransportBridgingKey:true])
            } else {
                ZyboxBleManager.shareInstance.connect(peripheral: peripheral as! CBPeripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
            }
        }else if peripheral is ZyboxScanModel {
            if let zyModel = peripheral as? ZyboxScanModel {
                if let peripheral = (peripheral as! ZyboxScanModel).peripheral {
                    if self.peripheral != peripheral {
                        self.peripheral = peripheral
                    }
                    if #available(iOS 13.0, *) {
                        ZyboxBleManager.shareInstance.connect(peripheral: peripheral, options: [CBConnectPeripheralOptionRequiresANCS:true,
                                                                                                                 CBConnectPeripheralOptionNotifyOnDisconnectionKey:true,
                                                                                                               CBConnectPeripheralOptionEnableTransportBridgingKey:true,
                                                                                                                            ])
                    } else {
                        ZyboxBleManager.shareInstance.connect(peripheral: peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
                    }
                }else{
                    if let uuidString = zyModel.uuidString {
                        if let peripheral = ZyboxBleManager.shareInstance.getPeripheral(string: uuidString) {
                            if self.peripheral != peripheral {
                                self.peripheral = peripheral
                            }
                            if #available(iOS 13.0, *) {
                                ZyboxBleManager.shareInstance.connect(peripheral: peripheral, options: [CBConnectPeripheralOptionRequiresANCS:true,
                                                                                                                         CBConnectPeripheralOptionNotifyOnDisconnectionKey:true,
                                                                                                                       CBConnectPeripheralOptionEnableTransportBridgingKey:true,
                                                                                                                                    ])
                            } else {
                                ZyboxBleManager.shareInstance.connect(peripheral: peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
                            }
                        }
                    }
                }
            }

        }else{
            connectState(false)
        }
        
        ZyboxBleManager.shareInstance.CentralConnectPeripheralState { (result, central, peripheral, error) in
            if result {
                printLog("CentralConnectPeripheralState")
                ZyboxSDKLog.clear()
                self.discoverServices(peripheral: peripheral)
                self.connectCompleteBlock = connectState
                
            }else{
                
                connectState(false)
            
            }
        }
    }
    
    @objc public func otaDisconnect() {
        //断开连接并打开正常的重连方法
        if let peripheral = self.peripheral {
            ZyboxBleManager.shareInstance.disconnect(peripheral: peripheral)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.ant_ReconnectTimer?.fireDate = .distantPast
        }
    }
    
    /// 断开连接
    @objc public func disconnect(complete:(()->Void)? = nil) {
       
        //此方法只能让外部调用，此方法会删除重连标识，如果SDK内部调用会影响重连，重连只调用一次就自动取消。内部调用断开连接用if的判断
        if self.peripheral != nil && self.peripheral?.state != .disconnected{
            ZyboxBleManager.shareInstance.disconnect(peripheral: self.peripheral!)
        }
        
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: "Zybox_ReconnectIdentifierKey")
        userDefault.synchronize()
        
        ZyboxBleManager.shareInstance.CentralDisonnectPeripheral { (central, peripheral, error) in
            printLog("----------设备已断开----------")
            if error == nil {
                //蓝牙列表忽略设备，error是nil  该重连的还是要继续
                if let identifierString = UserDefaults.standard.string(forKey: "Zybox_ReconnectIdentifierKey") {
                    if identifierString.count > 0 {
                        printLog("----------蓝牙列表忽略设备---------- ")
                        ZyboxSDKLog.writeStringToSDKLog(string: "----------蓝牙列表忽略设备----------")
                    }else{
                        printLog("----------设备已主动断开----------")
                        ZyboxSDKLog.writeStringToSDKLog(string: "----------设备已主动断开----------")
                    }
                }else{
                    printLog("----------设备已主动断开----------")
                    ZyboxSDKLog.writeStringToSDKLog(string: "----------设备已主动断开----------")
                }
            }
            self.peripheral = nil
            //命令信号量重置
            ZyboxCommandModule.shareInstance.resetCommandSemaphore()

            if let complete = complete {
                complete()
            }
        }

    }
    
    /// 发现服务
    /// - Parameter peripheral: peripheral
    func discoverServices(peripheral:CBPeripheral) {
        printLog("发现服务")
        peripheral.delegate = ZyboxBleManager.shareInstance
        peripheral.discoverServices(nil)
        self.isHaveWechatSportsServer = false
        ZyboxBleManager.shareInstance.PeripheralDiscoverService { (peripheral, error) in
            if error == nil {
                for service in peripheral.services ?? [] {
                    printLog("Service found with UUID:",service.uuid)
                    if String.init(format: "%@", service.uuid) == "FEE7" {
                        self.isHaveWechatSportsServer = true
                    }
                }
                self.discoverCharcristic(peripheral: peripheral)
            }
        }
    }
    
    func discoverCharcristic(peripheral:CBPeripheral) {
        printLog("发现特征")
        let serviceCount = peripheral.services?.count
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        var currentIndex = 0
        
        ZyboxBleManager.shareInstance.PeripheralDiscoverCharacteristic { (peripheral, service, error) in
            currentIndex += 1
            ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "service:%@",service.uuid))
            for characteristic in service.characteristics ?? [] {
                ZyboxSDKLog.writeStringToSDKLog(string: String.init(format: "characteristic:%@",characteristic.uuid))
                printLog("characteristic:",characteristic)
                print("characteristic.properties = \(characteristic.properties)")
                if String.init(format: "%@", characteristic.uuid) == "6E400002-B5A3-F393-E0A9-E50E24DCCA9E" || String.init(format: "%@", characteristic.uuid) == "FF02" || String.init(format: "%@", characteristic.uuid) == "00000901-3C17-D293-8E48-14FE2E4DA212"{
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                    self.writeCharacteristic = characteristic
                }
                if String.init(format: "%@", characteristic.uuid) == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" || String.init(format: "%@", characteristic.uuid) == "FF03" || String.init(format: "%@", characteristic.uuid) == "00000902-3C17-D293-8E48-14FE2E4DA212" {
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                    self.receiveCharacteristic = characteristic
                }
            }
            
            if currentIndex == serviceCount {
                
                ZyboxSDKLog.writeStringToSDKLog(string: "----------连接成功:\(peripheral.name ?? "")----------")

                self.deviceReceivedData()
                
                let userDefault = UserDefaults.standard
                userDefault.setValue(peripheral.identifier.uuidString, forKey: "Zybox_ReconnectIdentifierKey")
                userDefault.synchronize()
                
                if let block = self.connectCompleteBlock {
                    
                    if let peripheral = self.peripheral ,let characteristic = self.writeCharacteristic {
                        let mtu = peripheral.maximumWriteValueLength(for: ((characteristic.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
                        
                        var val:[UInt8] = [
                            0xbb,
                            0x01,
                            0x00,
                            0x02,
                            UInt8((mtu >> 8) & 0xff),
                            UInt8((mtu) & 0xff),
                        ]
                        let check = self.CRC16(val: val)
                        let checkVal = [UInt8((check) & 0xff),UInt8((check >> 8) & 0xff)]
                        val += checkVal
                        let data = Data.init(bytes: &val, count: val.count)
                        let dataString = String.init(format: "%@", self.convertDataToSpaceHexStr(data: data,isSend: true))
                        ZyboxSDKLog.writeStringToSDKLog(string: "发送:"+dataString)
                        printLog("send",dataString)
                        peripheral.writeValue(data, for: characteristic, type: ((characteristic.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0) ? .withoutResponse : .withResponse)
                    }
                    ZyboxCommandModule.shareInstance.setTime { _ in
                        
                    }
                    block(true)
                    return
                }
            }
        }
    }
    
    @objc func functionListCommandNoSupport() {
        printLog("functionListCommandNoSupport,self.peripheral = \(self.peripheral)")
        if let block = self.connectCompleteBlock {
            block(self.peripheral?.state == .connected ? true:false)
        }
    }
    
    func deviceReceivedData() {
        ZyboxBleManager.shareInstance.PeripheralUpdateValue { (peripheral, characteristic, error) in
//            printLog(("characteristic.value =",String.init(format: "%@", characteristic.value! as CVarArg)))
        }
    }
    
    func convertDataToHexStr(data:Data) ->String {
        
        if data.count <= 0 {
            return ""
        }

        var dataString = ""
        let str = data.withUnsafeBytes { (bytes) -> String in
            for i in stride(from: 0, to: bytes.count, by: 1) {
                let count = UInt8(bytes[i])
                
                if i % 4 == 0 && dataString.count > 0 {
                    dataString = dataString + " "
                }
                dataString = dataString + String.init(format: "%02x", count)
                
            }
            return dataString
        }
        return str
    }
    
    func convertHexStringToData(string:String) -> Data? {
        var data = Data.init(capacity: 4)

        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: string, range: NSMakeRange(0, string.utf16.count)) { match, flags, stop in
            let byteString = (string as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }

        guard data.count > 0 else { return nil }

        return data
    }
    
    func convertDataToSpaceHexStr(data:Data,isSend:Bool) ->String {
        
        if data.count <= 0 {
            return ""
        }

        var dataString = ""
        let str = data.withUnsafeBytes { (bytes) -> String in
            for i in stride(from: 0, to: bytes.count, by: 1) {
                let count = UInt8(bytes[i])
                
                if dataString.count > 0 {
                    
                    dataString = dataString + " "

                }
                dataString = dataString + String.init(format: "%02x", count)
                
                if i == 4 && !isSend {
                    //dataString = dataString + " :"
                }
                
                if i == 3 && isSend {//((i == 3) || (data.count <= 3 && i == data.count-1))
                    //dataString = dataString + " :"
                }
                
            }
            return String.init(format: "{length = %d , bytes = 0x%@}", data.count,dataString)
        }
        return str
    }
    
    // MARK: - 十六进制字符串转十进制数字
    func hexStringToInt(from: String ) -> Int  {
         let  str = from.uppercased()
         var  sum = 0
         for  i in  str.utf8 {
             sum = sum * 16 + Int (i) - 48 // 0-9 从48开始
             if  i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                 sum -= 7
             }
         }
         return  sum
    }
    
    // MARK: - 十进制转BDC码
    func decimalToBcd(value:Int) -> Int {
        return ((((value) / 10) << 4) + ((value) % 10))
    }
    
    // MARK: - BCD码转十进制
    func bcdToDecimal(value:Int) -> Int {
        return ((((value) & 0xf0) >> 4) * 10 + ((value) & 0x0f))
    }
    
    public func CRC16(data:Data) -> UInt16 {
        
        let val = data.withUnsafeBytes { (byte) -> [UInt8] in
            let b = byte.baseAddress?.bindMemory(to: UInt8.self, capacity: 4)
            return [UInt8](UnsafeBufferPointer.init(start: b, count: data.count))
        }
        
        return CRC16(val: val)
    }
    
    //CRC16校验
    public func CRC16(val: [UInt8])-> UInt16 {
        var crc:UInt16 = 0xFFFF
        
        for i in 0 ..< val.count {
            crc  = UInt16((UInt8)(crc >> 8)) | (crc << 8)
            crc ^= UInt16(val[i])
            crc ^= UInt16((UInt8)(crc & 0xFF) >> 4)
            crc ^= (crc << 8) << 4
            crc ^= ((crc & 0xFF) << 4) << 1
        }
        
        return crc
    }
    
    public func CRC32(val:[UInt8]) -> uLong {
        
        let valData = val.withUnsafeBufferPointer { (bytes) -> Data in
            return Data.init(buffer: bytes)
        }
        
        return CRC32(data: valData)
    }
    
    public func CRC32(data:Data) -> uLong {
        
        let crc = crc32(0, data.withUnsafeBytes({ (bytes) -> UnsafePointer<Bytef> in
            let b = bytes.baseAddress!.bindMemory(to: UInt8.self, capacity: 4)
            return b
        }), uInt(data.count))
        
        return crc
    }
//    //CRC16校验
//    func validate(crcL:UInt16,crcH:UInt16,crc:UInt16)->Bool {
//        if ((crc & 0xff) == crcL && ((crc >> 8) & 0xff) == crcH)
//        {
//            return true
//        }
//        return false
//    }
    
    func colorRgb565(color:UIColor) -> [UInt8] {
        
        let uint8Max = CGFloat(UInt8.max)
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var alpha:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &alpha)
        
        printLog("color.ciColor.red =",r,"g =",g,"b =",b)
        
        let intR = Int(r * uint8Max)
        let intG = Int(g * uint8Max)
        let intB = Int(b * uint8Max)
        
        let a = ((intB >> 3) & 0x1f)
        let newColor = UInt16((intR & 0xf8) << 8 | (intG & 0xfc) << 3 | a)
        
        return [UInt8((newColor >> 8) & 0xff),UInt8(newColor & 0xff)]
    }
    
    func colorRgb565(red:Int,green:Int,blue:Int) -> [UInt8] {
        let a = ((blue >> 3) & 0x1f)
        let newColor = UInt16((red & 0xf8) << 8 | (green & 0xfc) << 3 | a)
        
        return [UInt8((newColor >> 8) & 0xff),UInt8(newColor & 0xff)]
    }
        
}

extension Date {
    // MARK: - 返回dayCount天日期，+为之后，-为之前
    func afterDay(dayCount:Int) -> Date {
        return self.addingTimeInterval(TimeInterval(dayCount * 86400))
    }
    
    func conversionDateToString(DateFormat dateFormatter:String) -> String {
        let formatter = DateFormatter.init()
        //formatter.dateStyle = .medium
        formatter.dateFormat = dateFormatter
        return formatter.string(from:self)
    }
}

extension UIImage{
    
    /**
    获取图片中的像素颜色值
    
    - parameter pos: 图片中的位置
    
    - returns: 颜色值
    */
    func getPixelColor(pos:CGPoint)->(alpha: UInt8, red: UInt8, green: UInt8,blue:UInt8){
        
        if let cgImage = self.cgImage {
            let pixelData=cgImage.dataProvider?.data//CGImageGetDataProvider(cgImage).data
            let data:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            let pixelInfo: Int = ((Int(cgImage.width) * Int(pos.x)) + Int(pos.y)) * 4
            
            let r = UInt8(data[pixelInfo])
            let g = UInt8(data[pixelInfo+1])
            let b = UInt8(data[pixelInfo+2])
            let a = UInt8(data[pixelInfo+3])

            return (a,r,g,b)
        }
        
        return (0,0,0,0)
    }
    
    /**
     Converts the image into an array of RGBA bytes.
     */
    func toByteArray(rgba:String? = "rgba") -> [UInt8] {
        let width = Int(size.width)
        let height = Int(size.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        
        bytes.withUnsafeMutableBytes { ptr in
            if let context = CGContext(
                data: ptr.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) {
                
                if let image = self.cgImage {
                    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    context.draw(image, in: rect)
                }
            }
        }
        
        if rgba == "rgba" {
            return bytes
        }else if rgba == "bgra" {
            for i in stride(from: 0, to: bytes.count/4, by: 1) {
                bytes.swapAt(i*4, i*4+3)
                bytes.swapAt(i*4+1, i*4+2)
            }
            return bytes
        }
        
        return bytes
    }
    
    /**
     Creates a new UIImage from an array of RGBA bytes.
     */
    @nonobjc class func fromByteArray(_ bytes: UnsafeMutableRawPointer,
                                             width: Int,
                                             height: Int) -> UIImage {
        
        if let context = CGContext(data: bytes, width: width, height: height,
                                   bitsPerComponent: 8, bytesPerRow: width * 4,
                                   space: CGColorSpaceCreateDeviceRGB(),
                                   bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue),
           let cgImage = context.makeImage() {
            return UIImage(cgImage: cgImage, scale: 0, orientation: .up)
        } else {
            return UIImage()
        }
    }
    
    func changeSize(size:CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        self.draw(in: .init(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage.init()
        
    }
    
    func changeCircle(fillColor:UIColor) -> UIImage{

        if let cgImage = self.cgImage {
            let rect = CGRect.init(origin: .zero, size: CGSize.init(width: cgImage.width, height: cgImage.height))
            
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 1.0)
            fillColor.setFill()
            UIRectFill(rect)
            
            let path = UIBezierPath.init(ovalIn: rect)
            path.addClip()
            
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? UIImage.init()
        }
        return UIImage.init()
    }
    
    func addCornerRadius(radiusWidth:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1.0)
        
        let context : CGContext? = UIGraphicsGetCurrentContext()

        let area:CGRect = .init(origin: .zero, size: .init(width: self.size.width, height: self.size.height))

        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -area.height)
        context?.setBlendMode(.multiply)
        
        context?.setFillColor(UIColor.clear.cgColor)
        //context?.setStrokeColor(UIColor.white.cgColor)
        context?.setShouldAntialias(true)
        let rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(rect)
        let path = UIBezierPath.init(roundedRect: rect, cornerRadius: radiusWidth)//.init(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: .init(width: shadowWidth, height: shadowWidth))
        path.close()
        path.addClip()
        
        if let cgImg = self.cgImage {
            context?.draw(cgImg, in: rect)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? .init()
        UIGraphicsEndImageContext()
        
        print("self.size = \(self.size)")
        print("newImage = \(newImage)")
        
        return newImage
    }
    
    func addShadowLayer(shadowWidth:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1.0)
        
        let context : CGContext? = UIGraphicsGetCurrentContext()

        let area:CGRect = .init(origin: .zero, size: .init(width: self.size.width-shadowWidth, height: self.size.height-shadowWidth))

        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -area.height)
        context?.setBlendMode(.multiply)
        context?.setShadow(offset: .init(width: 0, height: 0), blur: shadowWidth, color: UIColor.white.cgColor)
        
        if let cgImg = self.cgImage {
            context?.draw(cgImg, in: .init(x: shadowWidth/2.0, y: -shadowWidth/2.0, width: self.size.width-shadowWidth, height: self.size.height-shadowWidth))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? .init()
        UIGraphicsEndImageContext()
        
        print("self.size = \(self.size)")
        print("newImage = \(newImage)")
        
        return newImage
    }
    
}

extension FileManager {
    
    // 文件管理器
    static var fileManager: FileManager {
        return FileManager.default
    }
    
    // MARK: 2.1、创建文件夹(蓝色的，文件夹和文件是不一样的)
    /// 创建文件夹(蓝色的，文件夹和文件是不一样的)
    /// - Parameter folderName: 文件夹的名字
    /// - Returns: 返回创建的 创建文件夹路径
    @discardableResult
    static func createFolder(folderPath: String) -> (isSuccess: Bool, error: String) {
        if !judgeFileOrFolderExists(filePath: folderPath) {
            // 不存在的路径才会创建
            do {
                // withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
                try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                printLog("创建文件夹成功")
                return (true, "")
            } catch _ {
                return (false, "创建失败")
            }
        }
        return (true, "")
    }
    
    // MARK: 2.2、删除文件夹
    /// 删除文件夹
    /// - Parameter folderPath: 文件的路径
    @discardableResult
    static func removefolder(folderPath: String) -> (isSuccess: Bool, error: String) {
        let filePath = "\(folderPath)"
        guard judgeFileOrFolderExists(filePath: filePath) else {
            // 不存在就不做什么操作了
            printLog("removefolder 文件路径为空")
            return (true, "")
        }
        // 文件存在进行删除
        do {
            try fileManager.removeItem(atPath: filePath)
            printLog("删除文件夹成功")
            return (true, "")
            
        } catch _ {
            return (false, "删除失败")
        }
    }
    
    // MARK: 2.3、创建文件
    /// 创建文件
    /// - Parameter filePath: 文件路径
    /// - Returns: 返回创建的结果 和 路径
    @discardableResult
    static func createFile(filePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: filePath) else {
            // 不存在的文件路径才会创建
            // withIntermediateDirectories 为 ture 表示路径中间如果有不存在的文件夹都会创建
            let createSuccess = fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
            
            return (createSuccess, "")
        }
        return (true, "")
    }
    
    // MARK: 2.4、删除文件
    /// 删除文件
    /// - Parameter filePath: 文件路径
    @discardableResult
    static func removefile(filePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: filePath) else {
            // 不存在的文件路径就不需要要移除
            return (true, "")
        }
        // 移除文件
        do {
            try fileManager.removeItem(atPath: filePath)
            printLog("删除文件成功")
            return (true, "")
        } catch _ {
            return (false, "移除文件失败")
        }
    }
    
    // MARK: 文件写入
    @discardableResult
    static func writeDicToFile(content: [String:Any], writePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: writePath) else {
            // 不存在的文件路径
            printLog("writeDicToFile 文件路径为空")
            return (false, "不存在的文件路径")
        }
        
        let result = (content as NSDictionary).write(toFile: writePath, atomically: true)
        if result {
            printLog("文件写入成功")
            return (true, "")
        } else {
            return (false, "写入失败")
        }
    }
    
    //文件读取
    @discardableResult
    static func readDicFromFile(readPath: String) -> (isSuccess: Bool, content: Any?, error: String) {
        guard judgeFileOrFolderExists(filePath: readPath),  let readHandler =  FileHandle(forReadingAtPath: readPath) else {
            // 不存在的文件路径
            printLog("readDicFromFile 文件路径为空")
            return (false, nil, "不存在的文件路径")
        }

        let dic = NSDictionary.init(contentsOfFile: readPath)
        
        return (true, dic, "")
    }
    
    // MARK: 图片写入
    @discardableResult
    static func writeImageToFile(content: UIImage, writePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: writePath) else {
            // 不存在的文件路径
            printLog("writeImageToFile 文件路径为空")
            return (false, "不存在的文件路径")
        }

        let imageData:Data = content.pngData() ?? Data.init()
        let result: ()? = try? imageData.write(to: URL.init(fileURLWithPath: writePath))
        
        if (result != nil) {
            printLog("文件写入成功")
            return (true, "")
        }else{
            return (false, "写入失败")
        }
        
    }
    
    //图片读取
    @discardableResult
    static func readImageFromFile(readPath: String) -> (isSuccess: Bool, content: Any?, error: String) {
        guard judgeFileOrFolderExists(filePath: readPath) else {
            // 不存在的文件路径
            printLog("readImageFromFile 文件路径为空")
            return (false, nil, "不存在的文件路径")
        }

        let image = UIImage.init(contentsOfFile: readPath)
        return (true, image, "")

    }
    
    //获取文件夹下文件列表
    @discardableResult
    static func getFileListInFolderWithPath(path:String) -> (isSuccess: Bool, content: [Any]?, error: String) {
        guard judgeFileOrFolderExists(filePath: path) else {
            // 不存在的文件路径
            printLog("getFileListInFolderWithPath 文件路径为空")
            return (false , nil , "不存在的文件路径")
        }
        
        do {
            // withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
            let fileList = try self.fileManager.contentsOfDirectory(atPath: path)
//            printLog("获取文件夹下文件列表成功")
            return (true , fileList , "获取成功")
        } catch _ {
            return (false , nil , "获取失败")
        }

        
    }

    
    // MARK: 2.10、判断 (文件夹/文件) 是否存在
     /** 判断文件或文件夹是否存在*/
     static func judgeFileOrFolderExists(filePath: String) -> Bool {
         let exist = fileManager.fileExists(atPath: filePath)
         // 查看文件夹是否存在，如果存在就直接读取，不存在就直接反空
         guard exist else {
             return false
         }
         return true
     }
}
