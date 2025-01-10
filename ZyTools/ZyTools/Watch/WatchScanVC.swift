//
//  WatchScanVC.swift
//  ZyTools
//
//  Created by 猜猜我是谁 on 2024/5/20.
//

import UIKit

class WatchScanVC: UIViewController {
    
    var tableView:UITableView!
    var dataSourceArray = [Any].init()
    var filterString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ZyCommandModule.shareInstance.matchingUUIDArray = [CBUUID.init(string: "53527AA4-29F7-AE11-4E74-997334782568"),CBUUID.init(string: "EC00D102-11E1-9B23-0002-5B00C0C1A8A8"),CBUUID.init(string: "AE00"),CBUUID.init(string: "00000800-3C17-D293-8E48-14FE2E4DA212"),CBUUID.init(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"),CBUUID.init(string: "000001FF-3C17-D293-8E48-14FE2E4DA212")]//6E400001-B5A3-F393-E0A9-E50E24DCCA9E
        
        ZyCommandModule.shareInstance.getSystemListPeripheral { modelArray in
            print("modelArray =",modelArray)
            for item in modelArray {
                print("item ->",item.name as Any,item.rssi,item.uuidString,item.peripheral as Any)
            }
        }
        
        self.tableView = UITableView.init(frame: .init(x: 0, y: 0, width: screenWidth, height: screenHeight-100))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        let scanButton = UIButton.init(frame: .init(x: screenWidth/2.0-75, y: screenHeight-80, width: 150, height: 50))
        scanButton.backgroundColor = .red
        scanButton.setTitle(NSLocalizedString("Scan", comment: "扫描"), for: .normal)
        scanButton.addTarget(self, action: #selector(self.scanButtonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(scanButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //ZyCommandModule.shareInstance.disconnect()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func scanButtonClick(sender:UIButton) {
        self.dataSourceArray.removeAll()
        self.tableView.reloadData()
        
//        ZyCommandModule.shareInstance.getSystemListPeripheral { [weak self]modelArray in
//            self?.dataSourceArray = modelArray
//            self?.tableView.reloadData()
//        }
        
        ZyCommandModule.shareInstance.scanDevice { (model) in
            //单个扫描到的model
//            if (self.filterString.count) > 0 {
//                if (model.name ?? "").lowercased().contains((self.filterString).lowercased()) {
//                    self.dataSourceArray.append(model)
//                    self.tableView.reloadData()
//                }
//            }else{
//                self.dataSourceArray.append(model)
//                self.tableView.reloadData()
//            }
            
        } modelArray: { [weak self](modelArray) in
            if (self?.filterString.count ?? 0) > 0 {
                for item in modelArray {
                    if (item.name ?? "").lowercased().contains((self?.filterString ?? "").lowercased()) {
                        if !(self?.dataSourceArray.contains(where: { model in
                            return model as! ZyScanModel == item
                        }) ?? false) {
                            self?.dataSourceArray.append(item)
                        }

                    }
                }
            }else{
                self?.dataSourceArray = modelArray
            }

            self?.tableView.reloadData()
        }
    }
}

extension WatchScanVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "scanCell") ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "scanCell")
        
        let model:ZyScanModel = self.dataSourceArray[indexPath.row] as! ZyScanModel
        
        cell.textLabel?.text = String.init(format: "%@       %d", model.name ?? "null",model.rssi )//(model.name ?? "null") + "\(model.peripheral?.identifier ?? "null")"  + "           \(model.rssi ?? 0)"
        cell.detailTextLabel?.text = model.macString ?? model.uuidString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model:ZyScanModel = self.dataSourceArray[indexPath.row] as! ZyScanModel
        let peripheral = model.peripheral
        
        ZyCommandModule.shareInstance.connectDevice(peripheral: peripheral as Any) { (result) in
            if result {
                print("连接成功",peripheral?.name,peripheral?.identifier)
                
                let vc = WatchCommandVC.init()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
}
