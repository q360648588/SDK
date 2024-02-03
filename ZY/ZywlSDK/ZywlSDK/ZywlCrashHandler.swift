//
//  CrashHandler.swift
//  CrashHandlerTest
//
//  Created by WangJensen on 6/30/17.
//  Copyright © 2017 WangJensen. All rights reserved.
//

import Foundation
import MachO

 typealias Completion = ()->Void;
 typealias CrashCallback = (String,Completion)->Void;

 var crashCallBack:CrashCallback?

func slideAddress() -> Int {
    
    var slier:Int = 0
    
    for i in stride(from: UInt32(0), to: _dyld_image_count(), by: UInt32.Stride(1)) {
        if _dyld_get_image_header(i).pointee.filetype == MH_EXECUTE {
            slier = _dyld_get_image_vmaddr_slide(i)
        }
    }
    
    return slier
}

func signalHandler(signal:Int32) -> Void {
    var stackTrace = String();
    //增加偏移量地址
    stackTrace = stackTrace.appendingFormat("slideAdress:0x%0x\r\n", slideAddress())
    stackTrace = stackTrace.appendingFormat(String.init(format: "slideAdress:0x1%08x\r\n", slideAddress()))

    for symbol in Thread.callStackSymbols {
        stackTrace = stackTrace.appendingFormat("%@\r\n", symbol);
    }
    
    if crashCallBack != nil {
        crashCallBack!(stackTrace,{
            unregisterSignalHandler();
            exit(signal);
        });
    }
}

func registerSignalHanlder()
{
    signal(SIGINT, signalHandler);
    signal(SIGSEGV, signalHandler);
    signal(SIGTRAP, signalHandler);
    signal(SIGABRT, signalHandler);
    signal(SIGILL, signalHandler);
}

func unregisterSignalHandler()
{
    signal(SIGINT, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGTRAP, SIG_DFL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
}

func registerUncaughtExceptionHandler() {
    NSSetUncaughtExceptionHandler { (exception) in
        let arr:NSArray = exception.callStackSymbols as NSArray
        let reason:String = exception.reason ?? "nil"
        let name:String = exception.name.rawValue
        
        var crash = String()
        crash = crash.appendingFormat("slideAdress:0x%0x\r\n", slideAddress())
        crash += "\r\n\r\n name:\(name) \r\n reason:\(String(describing: reason)) \r\n \(arr.componentsJoined(by: "\n")) \r\n\r\n"
        
        if crashCallBack != nil {
            crashCallBack!(crash,{
                unregisterSignalHandler();
            });
        }
    }
}

func printLog(_ items: Any..., separator: String = " ",terminator: String = "\n",funcName:String = #function,lineNum:Int = #line){
        
    #if DEBUG
    let dateString = Date().conversionDateToString(DateFormat: "yyyy-MM-dd HH:mm:ss.SSS")
    print("\(dateString) 方法名:\(funcName),第\(lineNum)行" , items)
    #endif
}

 class ZywlCrashHandler
{
     static func setup(callBack:@escaping CrashCallback){
        crashCallBack = callBack;
        registerSignalHanlder();
        registerUncaughtExceptionHandler()
    }
}
