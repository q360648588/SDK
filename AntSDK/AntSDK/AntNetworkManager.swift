//
//  NetworkManager.swift
//  HeroFit
//
//  Created by 猜猜我是谁 on 2020/11/23.
//  Copyright © 2020 猜猜我是谁. All rights reserved.
//

import UIKit
import Alamofire

class AntNetworkManager: NSObject {
    
    let basicUrl = "http://www.antjuyi.com"
//    let basicUrl = "http://192.168.1.21:8080"
    
    public static let shareInstance = AntNetworkManager()
    
    private override init() {
        super.init()
        
        let net = NetworkReachabilityManager()
        net?.listener = { status in
            if net?.isReachable ?? false {
                switch status{
                case .notReachable:
                    printLog("the noework is not reachable")
                case .unknown:
                    printLog("It is unknown whether the network is reachable")
                case .reachable(.ethernetOrWiFi):
                    printLog("通过WiFi链接")
                case .reachable(.wwan):
                    printLog("通过移动网络链接")
                }
            }else {
                printLog("网络不可用")
            }
        }
    }

    func post(url:String,parameter:Dictionary<String,Any>?,isNeedToken:Bool?,complete:@escaping(Dictionary<String,Any>) -> Void,fail:@escaping(Error?)-> Void) {
        
        //printLog("url:",url)
        //printLog("parameter:",parameter as Any)
        
        /*Session.default*/Alamofire.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            
            switch response.result {
            case .success(_):
//                printLog("response.value = ",response.value as Any)
                //let dic = response.value as! Dictionary<String, Any>
                let dic = self.clearNullDic(dic: response.value as! Dictionary<String, Any?>)
                
                //self.showCodeMessage(code: dic["code"])
                
//                if Int(dic["code"] as! Int) == 200 || Int(dic["code"] as! Int) < 1 {
                    complete(dic)
//                }else{
//                    fail(NSError.init(domain: "\(dic["code"] ?? 0)", code: 0, userInfo: nil))
//                }
                
                
                break
            case .failure(_):
                fail(response.error)
                //printLog("response.error = ",response.error!)
                //printLog("response.error.errorDescription = ",response.error?.errorDescription)
                break
            }
        }
    }
    
    func get(url:String,isNeedToken:Bool?,complete:@escaping(Dictionary<String,Any>) -> Void,fail:@escaping(Error?)-> Void) {
        
        printLog("url:",url)
        
        /*Session.default*/Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            
            switch response.result {
            case .success(_):
                //printLog("response.value = ",response.value as Any)
                //let dic = response.value as! Dictionary<String, Any>
                let dic = self.clearNullDic(dic: response.value as! Dictionary<String, Any?>)
                
                //self.showCodeMessage(code: dic["code"])
                
//                if Int(dic["code"] as! Int) == 200 || Int(dic["code"] as! Int) < 1 {
                    complete(dic)
//                }else{
//                    fail(NSError.init(domain: "\(dic["code"] ?? 0)", code: 0, userInfo: nil))
//                }
                
                break
            case .failure(_):
                fail(response.error)
                //printLog("response.error = ",response.error!)
                //printLog("response.error.errorDescription = ",response.error?.errorDescription)
                break
            }
        }
    }
    
    func clearNullDic(dic : Dictionary<String,Any?>) -> Dictionary<String,Any> {
        var tempDic : Dictionary<String,Any?> = dic
        
        for item in tempDic.keys {
            if(tempDic[item]?.map({_ in}) == nil || (tempDic[item] as? NSNull) != nil ){
                tempDic[item] = " "
            }
            
            if((tempDic[item] as? Dictionary<String,Any?>) != nil ){
                let getDic = clearNullDic(dic: tempDic[item] as! Dictionary<String,Any?>)
                tempDic[item] = getDic
            }
            
            if((tempDic[item] as? [Dictionary<String,Any?>]) != nil ){
                
                let tempArr : [Dictionary<String,Any?>] = (tempDic[item] as! [Dictionary<String,Any?>])
                
                var tempNArr : [Dictionary<String,Any?>]? = []
                tempNArr?.removeAll()
                
                for i in tempArr{
                    let iDic = clearNullDic(dic: i as Dictionary<String,Any?>)
                    tempNArr?.append(iDic)
                }
                
                tempDic[item] = tempNArr
                
            }
            
        }
        
        return tempDic
    }
}



struct LsqDecoder {
    
    //TODO:转换模型(单个)
    
    public static func decode<T>(_ type:T.Type, param: [String:Any]) -> T? where T:Decodable{
        
        guard let jsonData = self.getJsonData(with: param)else{
            
            return nil
            
        }
        
        guard let model = try? JSONDecoder().decode(type, from: jsonData)else{
            
            return nil
            
        }
        
        return model
        
    }
    
    //多个
    
    public static func decode<T>(_ type:T.Type, array: [[String:Any]]) -> [T]? where T:Decodable{
        
        if let data = self.getJsonData(with: array){
            
            if let models = try?JSONDecoder().decode([T].self, from: data){
                
                return models
            }
            
        }else{
            
            printLog("模型转换->转换data失败")
            
        }
        
        return nil
        
    }
    
    private static func getJsonData(with param:Any)->Data?{
        
        if !JSONSerialization.isValidJSONObject(param) {
            
            return nil
            
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: param, options: []) else {
            
            return nil
            
        }
        
        return data
        
    }
    
}

//模型转字典，或转json字符串

struct LsqEncoder {
    
    public static func encoder<T>(toString model:T) ->String? where T:Encodable{
                
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(model) else {
            
            return nil
            
        }
        
        guard let jsonStr = String(data: data, encoding: .utf8) else {
            
            return nil
            
        }
        
        return jsonStr
        
    }
    
    public static func encoder<T>(toDictionary model:T) ->[String:Any]? where T:Encodable{
        
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(model) else {
            
            return nil
            
        }
        
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any]else{
            
            return nil
            
        }
        
        
        
        return dict
        
    }
    
}
