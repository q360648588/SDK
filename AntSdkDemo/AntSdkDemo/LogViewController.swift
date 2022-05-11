//
//  LogViewController.swift
//  AntSdkDemo
//
//  Created by 猜猜我是谁 on 2021/4/17.
//

import UIKit
import AntSDK

class LogViewController: UIViewController {

    var textView:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .trash, target: self, action: #selector(self.clearLog))
        self.createView()
    }
    
    func createView() {
        self.textView = UITextView.init(frame: self.view.bounds)
        self.textView.text = AntSDKLog.showLog()
        self.textView.isEditable = false
        self.view.addSubview(self.textView)
    }
    
    @objc func clearLog() {
        self.textView.text = nil
        AntSDKLog.clear()
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
