//
//  LogViewController.swift
//  ZySdkDemo
//
//  Created by 猜猜我是谁 on 2021/4/17.
//

import UIKit
import ZywlSDK

class LogViewController: UIViewController {

    var textView:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .trash, target: self, action: #selector(self.clearLog))
        self.createView()
    }
    
    func createView() {
        self.textView = UITextView.init(frame: self.view.bounds)
        //self.textView.text = ZywlSDKLog.showLog()
        if let localType = UserDefaults.standard.string(forKey: "HC_LocalSelectType") {
            if localType == "103" {
                self.textView.text = ZywlSDKLog.showLog()
            }
            if localType == "102" {
                self.textView.text = ZywlSDKLog.showLog()
            }
            if localType == "101" {
                self.textView.text = ZySDKLog.showLog()
            }
        }
        self.textView.isEditable = false
        self.view.addSubview(self.textView)
    }
    
    @objc func clearLog() {
        self.textView.text = nil
        if let localType = UserDefaults.standard.string(forKey: "HC_LocalSelectType") {
            if localType == "103" {
                ZywlSDKLog.clear()
            }
            if localType == "102" {
                ZywlSDKLog.clear()
            }
            if localType == "101" {
                ZySDKLog.clear()
            }
        }
        
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
