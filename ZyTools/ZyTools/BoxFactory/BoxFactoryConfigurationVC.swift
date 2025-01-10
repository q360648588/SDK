//
//  BoxFactoryConfigurationVC.swift
//  ZyTools
//
//  Created by 猜猜我是谁 on 2024/5/20.
//

import UIKit

let zycxScanNameKey = "hc_zycx_scanNameKey"
let zycxNewBleNameKey = "hc_zycx_newBleNameKey"
let zycxAppVersionKey = "hc_zycx_appVersionKey"
let zycxImageVersionKey = "hc_zycx_imageVersionKey"
let zycxFontVersionKey = "hc_zycx_fontVersionKey"
let zycxProductIdKey = "hc_zycx_ProductKey"
let zycxProjectIdKey = "hc_zycx_ProjectKey"
let zycxPowerOffKey = "hc_zycx_powerOffKey"
let zycxApplicationKey = "1_zycx_ApplicationFiles"
let zycxLibraryKey = "2_zycx_LibraryFiles"
let zycxFontKey = "3_zycx_FontFiles"
let zycxDialKey = "4_zycx_DialFiles"
let zycxOtaSortKey = "hc_zycx_otaSortKey"

class BoxFactoryConfigurationVC: UIViewController {
    
    var myTableView:UITableView!
    
    var filterArray:[String] = Array.init()
    var dataSourceArray:[String] = Array.init()
    
    var scanNameString = ""
    var appVersion = ""
    var productId = ""
    var projectId = ""
    var imageVersion = ""
    var fontVersion = ""
    var powerOffString = ""
    var applicationString = ""
    var libraryString = ""
    var fontString = ""
    var dialString = ""
    var newBleNameString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "仅记录升级相关顺序"
        
        let rightItem = UIBarButtonItem.init(title: "排序", style: .done, target: self, action: #selector(otaSorting))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.loadData()
        self.createTableView()

        
        
    }
    
    @objc func otaSorting() {
        self.myTableView.isEditing = !self.myTableView.isEditing
    }
    
    func loadData() {
        let userDefault = UserDefaults.standard
        let scanArray = userDefault.array(forKey: zycxScanNameKey)
        
        var scanNameString = ""
        if let arr = scanArray {
            for i in 0..<arr.count {
                let item = arr[i] as! String
                scanNameString = scanNameString + item
                if i < arr.count - 1 {
                    scanNameString = scanNameString + ","
                }
            }
        }else{
            scanNameString = "设置扫描设备名"
        }
        self.scanNameString = scanNameString
        
        if let newName = userDefault.string(forKey: zycxNewBleNameKey) {
            self.newBleNameString = "修改蓝牙名为:"+newName
        }else{
            self.newBleNameString = "修改蓝牙名为:(不修改)"
        }
        
        if let product = userDefault.string(forKey: zycxProductIdKey) {
            self.productId = "升级指定产品版本:"+product
        }else{
            self.productId = "升级指定产品版本:无"
        }
        
        if let project = userDefault.string(forKey: zycxProjectIdKey) {
            self.projectId = "升级指定项目版本:"+project
        }else{
            self.projectId = "升级指定项目版本:无"
        }
        
        if let appVersion = userDefault.string(forKey: zycxAppVersionKey) {
            self.appVersion = "过滤固件版本:"+appVersion
        }else{
            self.appVersion = "过滤固件版本:无"
        }
        
        if let imageVersion = userDefault.string(forKey: zycxImageVersionKey) {
            self.imageVersion = "过滤图库版本:"+imageVersion
        }else{
            self.imageVersion = "过滤图库版本:无"
        }
        
        if let fontVersion = userDefault.string(forKey: zycxFontVersionKey) {
            self.fontVersion = "过滤字体版本:"+fontVersion
        }else{
            self.fontVersion = "过滤字体版本:无"
        }
        
        self.powerOffString = "恢复出厂并关机(不支持则只关机)"+(userDefault.bool(forKey: zycxPowerOffKey) == true ? ":开" : ":关")
        
        var applicationString = ""
        let applicationPath = userDefault.string(forKey: zycxApplicationKey)
        if let path = applicationPath {
            applicationString = "1应用文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
        }else{
            applicationString = "1应用文件:未选择"
        }
        self.applicationString = applicationString
        
        var libraryString = ""
        let libraryPath = userDefault.string(forKey: zycxLibraryKey)
        if let path = libraryPath {
            libraryString = "2图库文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
        }else{
            libraryString = "2图库文件:未选择"
        }
        self.libraryString = libraryString
        
        var fontString = ""
        let fontPath = userDefault.string(forKey: zycxFontKey)
        if let path = fontPath {
            fontString = "3字库文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
        }else{
            fontString = "3字库文件:未选择"
        }
        self.fontString = fontString
        
        var dialString = ""
        let dialPath = userDefault.string(forKey: zycxDialKey)
        if let path = dialPath {
            dialString = "4表盘文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
        }else{
            dialString = "4表盘文件:未选择"
        }
        self.dialString = dialString
        
        self.dataSourceArray = [scanNameString,self.newBleNameString,self.productId,self.projectId,self.applicationString,self.libraryString,self.fontString,self.dialString,self.powerOffString]
        
        let sortArray = userDefault.array(forKey: zycxOtaSortKey)
        
        if let sortArray:[Int] = sortArray as? [Int] {
            self.dataSourceArray = [scanNameString,self.newBleNameString,self.productId,self.projectId,self.appVersion,self.imageVersion,self.fontVersion,self.powerOffString]
            for item in sortArray {
                if item == 1 {
                    self.dataSourceArray.insert(self.applicationString, at: self.dataSourceArray.count-1)
                }
                if item == 2 {
                    self.dataSourceArray.insert(self.libraryString, at: self.dataSourceArray.count-1)
                }
                if item == 3 {
                    self.dataSourceArray.insert(self.fontString, at: self.dataSourceArray.count-1)
                }
                if item == 4 {
                    self.dataSourceArray.insert(self.dialString, at: self.dataSourceArray.count-1)
                }
            }
        }
        if userDefault.array(forKey: zycxOtaSortKey) == nil {
            self.getSortOrder()
        }
    }
    
    func createTableView() {
        let myTableView = UITableView.init(frame: .init(x: 0, y: 10, width: screenWidth, height: screenHeight))
        myTableView.delegate = self
        myTableView.dataSource = self
        self.view.addSubview(myTableView)
        self.myTableView = myTableView
    }

    func getSortOrder() {
        var newArray:[Int] = Array.init()
        for i in 0..<self.dataSourceArray.count {
            let string = self.dataSourceArray[i]
            if string.contains("应用文件") {
                newArray.append(1)
            }
            if string.contains("图库文件") {
                newArray.append(2)
            }
            if string.contains("字库文件") {
                newArray.append(3)
            }
            if string.contains("表盘文件") {
                newArray.append(4)
            }
        }
        let userDefault = UserDefaults.standard
        userDefault.set(newArray, forKey: zycxOtaSortKey)
        userDefault.synchronize()
    }
}

extension BoxFactoryConfigurationVC:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "scanCell") ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "scanCell")
        
        let model = self.dataSourceArray[indexPath.row]
        
        cell.textLabel?.text = model
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userDefault = UserDefaults.standard
        
        
        let selectString = self.dataSourceArray[indexPath.row]
        
        if self.scanNameString == selectString {
            let array = [
                "不用区分大小写"
            ]
            self.presentTextFieldAlertVC(title: "设置需要扫描设备的名称", message: "多个设备以英文逗号分开,以扫描到的设备名包含输入的设备名过滤", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { textArray in
                let filterString = textArray[0]
                self.filterArray = filterString.components(separatedBy: ",")
                if filterString.count > 0 {
                    userDefault.set(self.filterArray, forKey: zycxScanNameKey)
                }else{
                    userDefault.removeObject(forKey: zycxScanNameKey)
                }
                
                userDefault.synchronize()
                self.loadData()
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
        
        if self.newBleNameString == selectString {
            let array = [
                "需要区分大小写"
            ]
            
            self.presentTextFieldAlertVC(title: "设置蓝牙设备的新名称", message: "区分大小写", holderStringArray: array) {
                
            } okAction: { textArray in
                let newBleNameString = textArray[0]
                if newBleNameString.count > 0 {
                    userDefault.set(newBleNameString, forKey: zycxNewBleNameKey)
                }else{
                    userDefault.removeObject(forKey: zycxNewBleNameKey)
                }
                
                userDefault.synchronize()
                self.loadData()
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }

            
        }
        
        if self.productId == selectString {
            let array = [
                "不输入则无指定产品ID"
            ]
            self.presentTextFieldAlertVC(title: "设置需要升级的产品ID", message: "版本号为整数,如 1", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { textArray in
                let appString = textArray[0]
                if appString.count > 0 {
                    userDefault.set(appString, forKey: zycxProductIdKey)
                }else{
                    userDefault.removeObject(forKey: zycxProductIdKey)
                }
                
                userDefault.synchronize()
                self.loadData()
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
        
        if self.projectId == selectString {
            let array = [
                "不输入则无指定项目ID"
            ]
            self.presentTextFieldAlertVC(title: "设置需要升级的项目ID", message: "版本号为整数,如 1", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { textArray in
                let appString = textArray[0]
                if appString.count > 0 {
                    userDefault.set(appString, forKey: zycxProjectIdKey)
                }else{
                    userDefault.removeObject(forKey: zycxProjectIdKey)
                }
                
                userDefault.synchronize()
                self.loadData()
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
        
        if self.appVersion == selectString {
            let array = [
                "不输入则不过滤"
            ]
            self.presentTextFieldAlertVC(title: "设置需要过滤的应用版本号", message: "版本号小数点之后需要两位(不可以输入其他字符及空格),如1.00", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { textArray in
                let appString = textArray[0]
                if appString.count > 0 {
                    userDefault.set(appString, forKey: zycxAppVersionKey)
                }else{
                    userDefault.removeObject(forKey: zycxAppVersionKey)
                }
                
                userDefault.synchronize()
                self.loadData()
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
        
        if self.imageVersion == selectString {
            let array = [
                "不输入则不过滤"
            ]
            self.presentTextFieldAlertVC(title: "设置需要过滤的图库版本号", message: "版本号小数点之后需要两位(不可以输入其他字符及空格),如1.00", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { textArray in
                let imageString = textArray[0]
                if imageString.count > 0 {
                    userDefault.set(imageString, forKey: zycxImageVersionKey)
                }else{
                    userDefault.removeObject(forKey: zycxImageVersionKey)
                }
                
                userDefault.synchronize()
                self.loadData()
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
        
        if self.fontVersion == selectString {
            let array = [
                "不输入则不过滤"
            ]
            self.presentTextFieldAlertVC(title: "设置需要过滤的字库版本号", message: "版本号小数点之后需要两位(不可以输入其他字符及空格),如1.00", holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { textArray in
                let fontString = textArray[0]
                if fontString.count > 0 {
                    userDefault.set(fontString, forKey: zycxFontVersionKey)
                }else{
                    userDefault.removeObject(forKey: zycxFontVersionKey)
                }
                
                userDefault.synchronize()
                self.loadData()
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
        
        if selectString.contains("恢复出厂并关机(不支持则只关机)") {
            let result = userDefault.bool(forKey: zycxPowerOffKey)
            userDefault.set(!result, forKey: zycxPowerOffKey)
            userDefault.synchronize()
            self.loadData()
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
        
        if self.applicationString == selectString {
            
            var messageString = ""
            let applicationPath = userDefault.string(forKey: zycxApplicationKey)
            if let path = applicationPath {
                messageString = "\(path)"
            }else{
                messageString = "未选择"
            }
            
            self.presentSystemAlertVC(title: "当前应用文件路径", message: messageString, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"

                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    vc.navigationController?.popToViewController(self, animated: true)
                    
                    if pathString.count > 0 {
                        userDefault.set(pathString, forKey: zycxApplicationKey)
                    }else{
                        userDefault.removeObject(forKey: zycxApplicationKey)
                    }
                    userDefault.synchronize()
                    self.loadData()
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
                
            }, ok: "确定") {
                
            }
        }
        
        if self.libraryString == selectString {
            
            var messageString = ""
            let libraryPath = userDefault.string(forKey: zycxLibraryKey)
            if let path = libraryPath {
                messageString = "\(path)"
            }else{
                messageString = "未选择"
            }
            
            self.presentSystemAlertVC(title: "当前图库文件路径", message: messageString, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"

                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    vc.navigationController?.popToViewController(self, animated: true)
                    
                    if pathString.count > 0 {
                        userDefault.set(pathString, forKey: zycxLibraryKey)
                    }else{
                        userDefault.removeObject(forKey: zycxLibraryKey)
                    }
                    userDefault.synchronize()
                    self.loadData()
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
                
            }, ok: "确定") {
                
            }
        }
        
        if self.fontString == selectString {
            
            var messageString = ""
            let fontPath = userDefault.string(forKey: zycxFontKey)
            if let path = fontPath {
                messageString = "\(path)"
            }else{
                messageString = "未选择"
            }
            
            self.presentSystemAlertVC(title: "当前字库文件路径", message: messageString, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"

                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    vc.navigationController?.popToViewController(self, animated: true)
                    
                    if pathString.count > 0 {
                        userDefault.set(pathString, forKey: zycxFontKey)
                    }else{
                        userDefault.removeObject(forKey: zycxFontKey)
                    }
                    userDefault.synchronize()
                    self.loadData()
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
                
            }, ok: "确定") {
                
            }
        }
        
        if self.dialString == selectString {
            
            var messageString = ""
            let dialPath = userDefault.string(forKey: zycxDialKey)
            if let path = dialPath {
                messageString = "\(path)"
            }else{
                messageString = "未选择"
            }
            
            self.presentSystemAlertVC(title: "当前表盘文件路径", message: messageString, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"

                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    vc.navigationController?.popToViewController(self, animated: true)
                    
                    if pathString.count > 0 {
                        userDefault.set(pathString, forKey: zycxDialKey)
                    }else{
                        userDefault.removeObject(forKey: zycxDialKey)
                    }
                    userDefault.synchronize()
                    self.loadData()
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
                
            }, ok: "确定") {
                
            }
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row > 0 && indexPath.row < self.dataSourceArray.count - 1 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let content=self.dataSourceArray[sourceIndexPath.row]
        self.dataSourceArray.remove(at: sourceIndexPath.row)
        self.dataSourceArray.insert(content, at: destinationIndexPath.row)
        self.getSortOrder()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
}
