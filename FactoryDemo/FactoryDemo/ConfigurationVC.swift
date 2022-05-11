//
//  ConfigurationVC.swift
//  FactoryDemo
//
//  Created by 猜猜我是谁 on 2022/1/8.
//

import UIKit
import AntSDK

class ConfigurationVC: UIViewController {

    var myTableView:UITableView!
    
    var filterArray:[String] = Array.init()
    var dataSourceArray:[String] = Array.init()
    
    var scanNameString = ""
    var bootString = ""
    var applicationString = ""
    var libraryString = ""
    var fontString = ""
    var dialString = ""
    
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
        let scanArray = userDefault.array(forKey: ScanNameKey)
        
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
        
        var bootString = ""
        let bootPath = userDefault.string(forKey: BootKey)
        if let path = bootPath {
            bootString = "0引导文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
        }else{
            bootString = "0引导文件:未选择"
        }
        self.bootString = bootString
        
        var applicationString = ""
        let applicationPath = userDefault.string(forKey: ApplicationKey)
        if let path = applicationPath {
            applicationString = "1应用文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
        }else{
            applicationString = "1应用文件:未选择"
        }
        self.applicationString = applicationString
        
        var libraryString = ""
        let libraryPath = userDefault.string(forKey: LibraryKey)
        if let path = libraryPath {
            libraryString = "2图库文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
        }else{
            libraryString = "2图库文件:未选择"
        }
        self.libraryString = libraryString
        
        var fontString = ""
        let fontPath = userDefault.string(forKey: FontKey)
        if let path = fontPath {
            fontString = "3字库文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
        }else{
            fontString = "3字库文件:未选择"
        }
        self.fontString = fontString
        
        var dialString = ""
        let dialPath = userDefault.string(forKey: DialKey)
        if let path = dialPath {
            dialString = "4表盘文件:\(path.replacingOccurrences(of: "/Documents/", with: ""))"
        }else{
            dialString = "4表盘文件:未选择"
        }
        self.dialString = dialString
        
        self.dataSourceArray = [scanNameString,self.bootString,self.applicationString,self.libraryString,self.fontString,self.dialString,"关机"]
        
        let sortArray = userDefault.array(forKey: OtaSortKey)
        
        if let sortArray:[Int] = sortArray as? [Int] {
            self.dataSourceArray = [scanNameString,"关机"]
            for item in sortArray {
                if item == 0 {
                    self.dataSourceArray.insert(self.bootString, at: self.dataSourceArray.count-1)
                }
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
        if userDefault.array(forKey: OtaSortKey) == nil {
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
            if string.contains("引导文件") {
                newArray.append(0)
            }
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
        userDefault.set(newArray, forKey: OtaSortKey)
        userDefault.synchronize()
    }
}

extension ConfigurationVC:UITableViewDataSource,UITableViewDelegate {
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
                    userDefault.set(self.filterArray, forKey: ScanNameKey)
                }else{
                    userDefault.removeObject(forKey: ScanNameKey)
                }
                
                userDefault.synchronize()
                self.loadData()
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
        
        if self.bootString == selectString {
            
            var messageString = ""
            let bootPath = userDefault.string(forKey: BootKey)
            if let path = bootPath {
                messageString = "\(path)"
            }else{
                messageString = "未选择"
            }
            
            self.presentSystemAlertVC(title: "当前引导文件路径", message: messageString, cancel: "修改路径", cancelAction: {
                
                let path = NSHomeDirectory() + "/Documents"

                let vc = FileVC.init(filePath: path)
                self.navigationController?.pushViewController(vc, animated: true)
                
                vc.saveClickBlock = { (pathString) in
                    let homePath = NSHomeDirectory()
                    let pathString = pathString.replacingOccurrences(of: homePath, with: "")
                    print("选中的文件连接 pathString =",pathString)
                    vc.navigationController?.popToViewController(self, animated: true)
                    
                    if pathString.count > 0 {
                        userDefault.set(pathString, forKey: BootKey)
                    }else{
                        userDefault.removeObject(forKey: BootKey)
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
        
        if self.applicationString == selectString {
            
            var messageString = ""
            let applicationPath = userDefault.string(forKey: ApplicationKey)
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
                        userDefault.set(pathString, forKey: ApplicationKey)
                    }else{
                        userDefault.removeObject(forKey: ApplicationKey)
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
            let libraryPath = userDefault.string(forKey: LibraryKey)
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
                        userDefault.set(pathString, forKey: LibraryKey)
                    }else{
                        userDefault.removeObject(forKey: LibraryKey)
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
            let fontPath = userDefault.string(forKey: FontKey)
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
                        userDefault.set(pathString, forKey: FontKey)
                    }else{
                        userDefault.removeObject(forKey: FontKey)
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
            let dialPath = userDefault.string(forKey: DialKey)
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
                        userDefault.set(pathString, forKey: DialKey)
                    }else{
                        userDefault.removeObject(forKey: DialKey)
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
