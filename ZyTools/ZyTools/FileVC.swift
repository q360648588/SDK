//
//  fileVC.swift
//  ZySdkDemo
//
//  Created by 猜猜我是谁 on 2021/9/18.
//

import UIKit

class FileVC: UIViewController {

    var tableView:UITableView!
    var dataSourceArray = [Any].init()
    var filePath:String
    var saveClickBlock:((String) -> Void)?
    var saveUrl:String?
    
    init(filePath:String) {
        self.filePath = filePath+"/"
        
        super.init(nibName: nil, bundle: nil)
        do {
            let fileList = try FileManager.default.contentsOfDirectory(atPath: filePath)
            self.dataSourceArray = fileList
            print("fileList =",fileList)
        } catch _ {
            print("文件列表获取失败")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView = UITableView.init(frame: .init(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.title = NSLocalizedString("Select Save, select empty to clear", comment: "选中保存，选空清除")
        
        let rightItem = UIBarButtonItem.init(title: NSLocalizedString("Save/Clear", comment: "保存/清除"), style: .done, target: self, action: #selector(saveClick))
        self.navigationItem.rightBarButtonItem = rightItem
        
    }
    
    @objc func saveClick() {
        
        if self.saveUrl?.count ?? 0 <= 0 {
            
            self.presentSystemAlertVC(title: NSLocalizedString("Warning", comment: "警告"), message: NSLocalizedString("No file is currently selected, the selected type file will be cleared by default", comment: "当前未选择文件，默认会清除该选中类型文件")) {
                
            } okAction: {
                
                if let block = self.saveClickBlock {
                    block("")
                }
                
                for vc in self.navigationController!.viewControllers {
                    if vc is ChargingBoxCommandVC {
                        self.navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                    if vc is WatchCommandVC {
                        self.navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
                
            }
            
        }else{
            
            if let block = self.saveClickBlock {
                block(self.saveUrl ?? "")
            }
            
            for vc in self.navigationController!.viewControllers {
                if vc is ChargingBoxCommandVC {
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
                if vc is WatchCommandVC {
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
            
        }

    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

extension FileVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "fileCell") ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "fileCell")
        
        let fileString = self.dataSourceArray[indexPath.row] as! String
        
        let path = self.filePath+fileString
        
        cell.textLabel?.text = String.init(format: "%@",fileString)
        
        let attributes = try? FileManager.default.attributesOfItem(atPath: path) //结果为Dictionary类型
        let creatDate:Date = attributes![FileAttributeKey.creationDate]! as! Date
        let format = DateFormatter.init()
        format.dateFormat = "yyyy-MM-dd"
        print("创建时间：\(format.string(from: creatDate))")
        
        cell.detailTextLabel?.text = "1234"
        let dateLabel = UILabel.init(frame: .init(x: 0, y: 0, width: 80, height: cell.frame.height))
        dateLabel.textAlignment = .right
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.text = format.string(from: creatDate)
        dateLabel.sizeToFit()
        cell.accessoryView = dateLabel
        
        if self.isDirectory(filePath: path) {
            if #available(iOS 13.0, *) {
                cell.imageView?.image = UIImage.init(systemName: "folder")
            } else {
                
            }
            
            do {
                let nextListArray = try FileManager.default.contentsOfDirectory(atPath: path)
                cell.detailTextLabel?.text = "\(nextListArray.count) items"
                print("nextListArray =",nextListArray)
            } catch _ {
                print("文件列表获取失败")
            }
            
            
        }else{
            if #available(iOS 13.0, *) {
                cell.imageView?.image = UIImage.init(systemName: "doc.circle.fill")
            } else {
                
            }
            
            let fileSize:Int64 = (attributes![FileAttributeKey.size]! as? NSNumber)?.int64Value ?? 0
            print("文件大小：\(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .binary))")
            cell.detailTextLabel?.text = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .binary)
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileString = self.dataSourceArray[indexPath.row] as! String
        
        let path = self.filePath+fileString
        
        if self.isDirectory(filePath: path) {
            let vc = FileVC.init(filePath: path)
            if let block = self.saveClickBlock {
                vc.saveClickBlock = block
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            self.saveUrl = path
        }
        
    }
    
    func isDirectory(filePath:String) ->Bool {
        print("filePath =",filePath)
        
        var isDirectory : ObjCBool = false
        
        let exist:Bool = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
//        let exist:Bool = FileManager.default.fileExists(atPath: filePath)

        print("isDirectory.boolValue =",isDirectory.boolValue,"exist =",exist)
        
        return isDirectory.boolValue
    }
}
