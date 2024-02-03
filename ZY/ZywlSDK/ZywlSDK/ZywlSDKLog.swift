//
//  ZySDKLog.swift
//  ZySDK
//
//  Created by 猜猜我是谁 on 2021/4/17.
//

import UIKit

public class ZywlSDKLog: NSObject {
    
    static let shareInstance = ZywlSDKLog()
    
    var logString = ""
    var allString = ""
    var powerConsumptionString = ""
    
    private override init() {
        super.init()
    }
    
    @objc public class func writeStringToSDKLog(string:String) {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "HH:mm:ss.SSS"
        DispatchQueue.main.async {
            self.shareInstance.logString.append(String.init(format: "%@  %@\n\n", formatter.string(from: Date.init()),string))
            self.shareInstance.allString.append(String.init(format: "%@  %@\n\n", formatter.string(from: Date.init()),string))
        }
    }
    
    @objc public class func writePowerConsumptionStringToSDKLog(string:String) {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "HH:mm:ss.SSS"
        DispatchQueue.main.async {
            self.shareInstance.powerConsumptionString.append(String.init(format: "%@  %@\n\n", formatter.string(from: Date.init()),string))
        }
    }
    
    @objc public class func powerConsumptionLog() -> String {
        return self.shareInstance.powerConsumptionString
    }
    
    @objc public class func showLog() -> String {
        return self.shareInstance.logString
    }
    
    @objc public class func showAllLog() -> String {
        return self.shareInstance.allString
    }
    
    @objc public class func clear() {
        self.shareInstance.logString = ""
    }
}
