//
//  HeadphoneScanVC.swift
//  ZyTools
//
//  Created by 猜猜我是谁 on 2024/4/25.
//

import UIKit
//import ZywlSDK
import CoreBluetooth

class HeadphoneScanVC: UIViewController {
    
    var tableView:UITableView!
    var dataSourceArray = [Any].init()
    var filterString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Scan", comment: "扫描")

        ZywlCommandModule.shareInstance.matchingUUIDArray = [CBUUID.init(string: "53527AA4-29F7-AE11-4E74-997334782568"),CBUUID.init(string: "EC00D102-11E1-9B23-0002-5B00C0C1A8A8"),CBUUID.init(string: "000001FF-3C17-D293-8E48-14FE2E4DA212")]

        ZywlCommandModule.shareInstance.getSystemListPeripheral { modelArray in
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
        
    }

    @objc func scanButtonClick(sender:UIButton) {
        self.dataSourceArray.removeAll()
        self.tableView.reloadData()
        
        ZywlCommandModule.shareInstance.scanDevice { (model) in

        } modelArray: { [weak self](modelArray) in
            if (self?.filterString.count ?? 0) > 0 {
                for item in modelArray {
                    if (item.name ?? "").lowercased().contains((self?.filterString ?? "").lowercased()) {
                        if !(self?.dataSourceArray.contains(where: { model in
                            return model as! ZywlScanModel == item
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

extension HeadphoneScanVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "scanCell") ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "scanCell")

        let model:ZywlScanModel = self.dataSourceArray[indexPath.row] as! ZywlScanModel

        cell.textLabel?.text = String.init(format: "%@       %d", model.name ?? "null",model.rssi )
        cell.detailTextLabel?.text = model.macString ?? model.uuidString

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let model:ZywlScanModel = self.dataSourceArray[indexPath.row] as! ZywlScanModel
        let peripheral = model.peripheral

        ZywlCommandModule.shareInstance.connectHeadphoneDevice(peripheral: model as Any) { (result) in
            if result {
                print("连接成功",peripheral?.name,peripheral?.identifier)

                let vc = HeadphoneCommandVC.init()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
