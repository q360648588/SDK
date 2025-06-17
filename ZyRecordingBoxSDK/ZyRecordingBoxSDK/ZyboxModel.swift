//
//  ZyModel.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2022/5/7.
//

import Foundation
import CoreBluetooth
import UIKit
import CoreLocation

//public struct ZyScanModel {
//    public var name:String?
//    public var rssi:Int?
//    public var peripheral:CBPeripheral?
//    fileprivate init() {
//
//    }
//}

@objc public class ZyboxScanModel: NSObject {
    @objc public var name:String?
    @objc public var rssi:Int = 0
    @objc public var peripheral:CBPeripheral?
    @objc public var uuidString:String?
    @objc public var macString:String?
}

@objc public class ZyboxRecordFileModel:NSObject,Codable {
    @objc public var fileName = ""
    @objc public var fileCreateTime = 0
    @objc public var fileTimeLength = 0
}

@objc public class ZyboxRecordStateModel:NSObject,Codable {
    @objc public var battery = 0 //电量
    @objc public var recordingState = 0 //录音状态
    @objc public var broadcastTimeout = 0 //广播超时
    @objc public var versionString = ""
    @objc public var tCardTotalSize = 0
    @objc public var tCardRemainderSize = 0
}


@objc public class ZyboxRecordFileDataModel:NSObject {
    @objc public var fileSize = 0
    @objc public var maxLength = 0
    @objc public var numberIndex = 0
    @objc public var fileName = ""
}
