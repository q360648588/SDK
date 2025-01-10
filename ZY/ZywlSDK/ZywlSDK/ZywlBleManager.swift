//
//  ZyBleManager.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2021/4/16.
//

import UIKit
import CoreBluetooth

class ZywlBleManager: NSObject {

    public static let shareInstance = ZywlBleManager()
    
    /// 蓝牙开关状态
//    fileprivate(set) var blePowerState:CBManagerState = .unknown
    private var bleManager:CBCentralManager!
    private var blePowerBlock:((CBCentralManagerState)->())?
    private var ancsStateBlock:((Bool)->())?
    
    private var bleCentralDiscoverBlock:((CBCentralManager,CBPeripheral,[String : Any],NSNumber)->())?
    private var bleCentralConnectPeripheralBlock:((_ state: Bool,_ central: CBCentralManager, _ peripheral: CBPeripheral, _ error: Error?)->())?
    private var bleCentralDisconnectBlock:((_ central: CBCentralManager, _ peripheral: CBPeripheral, _ error: Error?)->())? 
    
    private var blePeripheralDiscoverServiceBlock:((_ peripheral: CBPeripheral,_ error: Error?)->())?
    private var blePeripheralDiscoverCharacteristicBlock:((_ peripheral: CBPeripheral,_ service: CBService, _ error: Error?)->())?
    private var blePeripheralUpdateValueBlock:((_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?)->())?
    
    private var bleReconnectBlock:(()->())?
    
    private override init() {
        super.init()
        self.bleManager = CBCentralManager.init(delegate: self, queue: nil)
        self.bleManager.delegate = self
        
    }
    
    /// 获取蓝牙开关更新状态
    /// - Parameter value: true：开，false：关
    /// - Returns:
    func getBlePowerDidUpdateState(value:@escaping((CBCentralManagerState)->())) {
        self.blePowerBlock = value
    }
    
    func getBlePowerState() -> CBCentralManagerState {
        return CBCentralManagerState.init(rawValue: self.bleManager.state.rawValue)!
    }
    
    func getAncsDidUpdateState(value:@escaping((Bool)->())) {
        self.ancsStateBlock = value
    }
    
    func scanPeripheralWithServices(array:[CBUUID]? = nil) {
        self.bleManager.scanForPeripherals(withServices: array, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
    }
    
    func getListConnectPeripheras(serviceArray:[CBUUID] = []) -> [CBPeripheral] {
        return self.bleManager.retrieveConnectedPeripherals(withServices: serviceArray)
    }
    
    func stopScanPeripheral() {
        self.bleManager.stopScan()
    }
    
    func connect(peripheral: CBPeripheral, options: [String : Any]?) {
        
        self.bleManager.connect(peripheral, options: options)
    }
    
    func disconnect(peripheral: CBPeripheral) {
        self.bleManager.cancelPeripheralConnection(peripheral)
    }
    
    func CentralDiscoverPeripheral(value:@escaping((_ central: CBCentralManager, _ peripheral: CBPeripheral, _ advertisementData: [String : Any], _ RSSI: NSNumber)->())) {
        self.bleCentralDiscoverBlock = value
    }
    
    func CentralConnectPeripheralState(value:@escaping((_ state: Bool,_ central: CBCentralManager, _ peripheral: CBPeripheral, _ error: Error?)->())) {
        self.bleCentralConnectPeripheralBlock = value
    }
    
    func CentralDisonnectPeripheral(value:@escaping((_ central: CBCentralManager, _ peripheral: CBPeripheral, _ error: Error?)->())) {
        self.bleCentralDisconnectBlock = value
    }
    
    func PeripheralDiscoverService(value:@escaping((_ peripheral: CBPeripheral,_ error: Error?)->())) {
        self.blePeripheralDiscoverServiceBlock = value
    }
    
    func PeripheralDiscoverCharacteristic(value:@escaping((_ peripheral: CBPeripheral,_ service: CBService, _ error: Error?)->())) {
        self.blePeripheralDiscoverCharacteristicBlock = value
    }
    
    func PeripheralUpdateValue(value:@escaping((_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?)->())){
        self.blePeripheralUpdateValueBlock = value
    }
    
    func DeviceNeedReconnectMothed(value:@escaping(()->())) {
        self.bleReconnectBlock = value
    }
    
    func getPeripheral(string:String) -> CBPeripheral? {
        if string.count > 0 {
            let uuid = UUID.init(uuidString: string)
            if uuid != nil {
                let p = self.bleManager.retrievePeripherals(withIdentifiers: [uuid!])
                if p.count > 0 {
                    return p.first
                }
                return nil
            }
            return nil
        }
        return nil
    }
    
}

extension ZywlBleManager:CBCentralManagerDelegate {
    // MARK: - 蓝牙开关状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if let block = self.blePowerBlock {
            block(CBCentralManagerState.init(rawValue: central.state.rawValue)!)
        }
    }
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("peripheralDidUpdateName \(peripheral.name)")
    }
    func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        if #available(iOS 13.0, *) {
            printLog("didUpdateANCSAuthorizationFor = \(peripheral.ancsAuthorized)")
            if let block = self.ancsStateBlock {
                block(peripheral.ancsAuthorized)
            }
        } else {
            printLog("didUpdateANCSAuthorizationFor ")
        }
    }
    
    // MARK: - 扫描到蓝牙设备
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        printLog("\n--------------------------------------------------------------------------\n")
//        printLog("peripheral ->",peripheral,"\nadvertisementData ->",advertisementData)
//        printLog("\n--------------------------------------------------------------------------\n")
        if let block = self.bleCentralDiscoverBlock {
            block(central,peripheral,advertisementData,RSSI)
        }
    }
    
    // MARK: - 连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let block = self.bleCentralConnectPeripheralBlock {
            block(true,central,peripheral,nil)
        }
    }
    
    // MARK: - 连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let block = self.bleCentralConnectPeripheralBlock {
            block(false,central,peripheral,error)
        }
    }
    
    // MARK: - 断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        printLog("peripheral =",peripheral,"error =",error)

        if error != nil {
            printLog("----------设备非正常断开---------- ")
            if let block = self.bleReconnectBlock {
                block()
            }
        }else{
            //蓝牙列表忽略设备，error是nil  该重连的还是要继续
            if let identifierString = UserDefaults.standard.string(forKey: "Zycx_BoxReconnectKey") {
                if identifierString.count > 0 {
                    printLog("----------蓝牙列表忽略设备---------- ")
                    if let block = self.bleReconnectBlock {
                        block()
                    }
                }
            }
            if let identifierString = UserDefaults.standard.string(forKey: "Zycx_ReconnectKey") {
                if identifierString.count > 0 {
                    printLog("----------蓝牙列表忽略设备---------- ")
                    if let block = self.bleReconnectBlock {
                        block()
                    }
                }
            }
        }
        
        if let block = self.bleCentralDisconnectBlock {
            block(central,peripheral,error)
        }
    }
    
    
}

extension ZywlBleManager:CBPeripheralDelegate{
    // MARK: - 发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let block = self.blePeripheralDiscoverServiceBlock {
            block(peripheral,error)
        }
    }
    
    // MARK: - 发现特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let block = self.blePeripheralDiscoverCharacteristicBlock {
            block(peripheral,service,error)
        }
    }
    
    // MARK: - 数据交互
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let block = self.blePeripheralUpdateValueBlock {
            block(peripheral,characteristic,error)
        }
    }
    // MARK: - 写入数据
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //printLog("写入数据  didWriteValueFor CBCharacteristic = \(characteristic) error = \(error)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        //printLog("写入数据  didWriteValueFor CBDescriptor ")
    }
    
//    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
//        printLog("toSendWriteWithoutResponse")
//    }
}
