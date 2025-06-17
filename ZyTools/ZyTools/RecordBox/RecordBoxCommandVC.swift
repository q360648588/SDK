//
//  RecordBoxCommandVC.swift
//  ZyTools
//
//  Created by c h on 2025/3/12.
//

import UIKit
import CoreBluetooth

class RecordBoxCommandVC: UIViewController {
    
    var currentBleState:CBPeripheralState! {
        didSet {
            if self.currentBleState == .disconnected {
                self.title = "disconnected"
            }else if self.currentBleState == .connecting {
                self.title = "connecting"
            }else if self.currentBleState == .connected {
                self.title = "connected"
            }else if self.currentBleState == .disconnecting {
                self.title = "disconnecting"
            }
        }
    }
    var tableView:UITableView!
    var dataSourceArray = [[String]].init()
    var titleArray = [String].init()
    var logView:ShowLogView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentBleState = ZyCommandModule.shareInstance.peripheral?.state ?? .disconnected
        
        ZyCommandModule.shareInstance.peripheralStateChange { [weak self] state in
            self?.currentBleState = state
        }
        
        let rightItem = UIBarButtonItem.init(title: "→", style: .done, target: self, action: #selector(pushNextVC))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.tableView = UITableView.init(frame: .init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.logView = ShowLogView.init(frame: .init(x: 0, y: 84, width: screenWidth, height: screenHeight-84))
        //self.logView.center = self.view.center
        self.logView.isHidden = true
        self.view.addSubview(self.logView)
        
        self.titleArray = ["录音文件上传"]
        
        self.dataSourceArray = [
            [
            "4.3.1 录音文件列表查询",
            "启动录音文件上传，自动添加流水号",
//            "4.3.2 启动录音文件上传",
            "4.3.3 请求录音文件数据上传",
            "4.3.5 录音文件数据上传",
            "4.3.6 录音文件列表刷新",
            "4.3.7 录音文件删除",
            "4.3.8 录音文件批量删除",
            "4.3.9 录音文件上传暂停",
        ]
        ]
        
    }
    @objc func pushNextVC() {
        let vc = LogViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func logButtonClick(sender:UIButton) {
        let vc = LogViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    deinit {
        print("deinit ZyVC")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RecordBoxCommandVC:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionArray = self.dataSourceArray[section]
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UILabel.init(frame: .init(x: 0, y: 0, width: screenWidth, height: 50))
        view.backgroundColor = .gray//ViewBgColor
        view.isUserInteractionEnabled = true
        
        let label = UILabel.init(frame: .init(x: 20, y: 0, width: screenWidth-40, height: 50))
        label.text = self.titleArray[section]
        view.addSubview(label)

        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "commandCell") ?? UITableViewCell.init(style: .default, reuseIdentifier: "commandCell")
        
        let sectionArray = self.dataSourceArray[indexPath.section]
        cell.textLabel?.text = sectionArray[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionArray = self.dataSourceArray[indexPath.section]
        let rowString = sectionArray[indexPath.row]
        let vc = LogViewController.init()
        
        print("didSelectRowAt -> date =",Date.init())
        
        switch rowString {
        case "4.3.1 录音文件列表查询":
            let array = [
                "起始序号",
                "录音文件个数"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("录音文件列表查询", comment: ""))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("录音文件列表查询", comment: ""), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let index = textArray[0]
                let fileCount = textArray[1]
                self.logView.writeString(string: "序号:\(index),个数:\(fileCount)")

                ZyCommandModule.shareInstance.setCheckFileList(index: Int(index) ?? 0, fileCount: Int(fileCount) ?? 0) { listArray, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    
                    if error == .none {
                        print("success ->",listArray)
                        
                        for item in listArray {
                            self.logView.writeString(string: "\n\(item)")
                            print("\n\(item)")
                        }
                    }
                }
            }
            break
        case "启动录音文件上传，自动添加流水号":
            
            let array = [
                "文件名",
                "开始包序号",
                "上传包号",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("启动录音文件上传", comment: ""))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("启动录音文件上传", comment: ""), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let name = textArray[0]
                let index = textArray[1]
                let packageCount = textArray[2]

                self.logView.writeString(string: "文件名:\(name)")
                self.logView.writeString(string: "包序号:\(index)")
                self.logView.writeString(string: "上传包号:\(packageCount)")
                ZyCommandModule.shareInstance.setStartFileUpload(name: name) { model, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none , let model = model {
                        let numberIndex = model.numberIndex
                        self.logView.writeString(string: "流水号:\(numberIndex)")
                        ZyCommandModule.shareInstance.setStartFileDataUpload(index: Int(index) ?? 0, packageCount: Int(packageCount) ?? 0, numberIndex: numberIndex)
                    }
                }
            }
            
            break
        case "4.3.2 启动录音文件上传":
            let array = [
                "文件名",
                "开始包序号",
                "上传包号",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("启动录音文件上传", comment: ""))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("启动录音文件上传", comment: ""), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let name = textArray[0]
                self.logView.writeString(string: "文件名:\(name)")
                ZyCommandModule.shareInstance.setStartFileUpload(name: name) { model, error in
                    self.logView.writeString(string: self.getErrorCodeString(error: error))
                    if error == .none {
                        
                    }
                }
            }
            break
        case "4.3.3 请求录音文件数据上传":
            let array = [
                "开始包序号",
                "上传包号",
                "录音文件流水号"
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("请求录音文件数据上传", comment: ""))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("请求录音文件数据上传", comment: ""), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let index = textArray[0]
                let packageCount = textArray[1]
                let numberIndex = textArray[2]
                self.logView.writeString(string: "包序号:\(index),包号:\(packageCount),流水号:\(numberIndex)")
                ZyCommandModule.shareInstance.setStartFileDataUpload(index: Int(index) ?? 0, packageCount: Int(packageCount) ?? 0, numberIndex: Int(numberIndex) ?? 0)
            }
            break
        case "4.3.5 录音文件数据上传":
            let array = [
                "录音文件流水号",
                "补传包列表，“英文逗号隔开”",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("录音文件数据上传", comment: ""))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("录音文件数据上传", comment: ""), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let numberIndex = textArray[0]
                let listString = textArray[1]
                
                // 1. 按逗号分隔字符串
                let stringArray = listString.components(separatedBy: ",")
                // 2. 转换为 [Int] 数组
                let packageList = stringArray.compactMap { str in
                    // 去除空格（如果有）
                    let trimmedStr = str.trimmingCharacters(in: .whitespacesAndNewlines)
                    // 尝试将字符串转换为 Int
                    return Int(trimmedStr)
                }
                
                self.logView.writeString(string: "流水号:\(numberIndex),\n补传包列表 = \(listString)")
                ZyCommandModule.shareInstance.setFileDataReplenishmentSend(numberIndex: Int(numberIndex) ?? 0, packageList: packageList)
            }
            break
        case "4.3.6 录音文件列表刷新":
            ZyCommandModule.shareInstance.setFileListRefresh()
            break
        case "4.3.7 录音文件删除":
            let array = [
                "文件名",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("录音文件删除", comment: ""))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("录音文件删除", comment: ""), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let name = textArray[0]

                self.logView.writeString(string: "文件名:\(name)")
                ZyCommandModule.shareInstance.setSingleDeleteFile(name: name)
            }
            break
        case "4.3.8 录音文件批量删除":
            let array = [
                "文件名列表，英文逗号隔开",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("录音文件批量删除", comment: ""))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("录音文件批量删除", comment: ""), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let name = textArray[0]

                // 1. 按逗号分隔字符串
                let stringArray = name.components(separatedBy: ",")
                
                self.logView.writeString(string: "文件名:\(name)")
                ZyCommandModule.shareInstance.setBatchDeleteFile(nameList: stringArray)
            }
            break
        case "4.3.9 录音文件上传暂停":
            let array = [
                "文件名",
            ]
            
            self.logView.clearString()
            self.logView.writeString(string: NSLocalizedString("录音文件上传暂停", comment: ""))
            
            self.presentTextFieldAlertVC(title: NSLocalizedString("Prompt (default 0 for invalid data)", comment: "提示(无效数据默认0)"), message: NSLocalizedString("录音文件上传暂停", comment: ""), holderStringArray: array, cancel: nil, cancelAction: {
                
            }, ok: nil) { (textArray) in
                let name = textArray[0]

                self.logView.writeString(string: "文件名:\(name)")
                ZyCommandModule.shareInstance.setPuaseFileUpload(name: name)
            }
            break
            
        default:
            break
        }
    }
    
    func getErrorCodeString(error:ZyError) -> String {
        if error == .none {
            return "成功 none"
        }else if error == .disconnected {
            return "设备未连接 disconnected"
        }else if error == .invalidCharacteristic {
            return "无效特征值 invalidCharacteristic"
        }else if error == .invalidLength {
            return "无效数据长度 invalidLength"
        }else if error == .invalidState {
            return "无效状态 invalidState"
        }else if error == .notSupport {
            return "不支持此功能"
        }
        return "未知error"
    }
}
