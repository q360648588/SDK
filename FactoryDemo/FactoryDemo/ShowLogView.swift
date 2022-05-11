//
//  ShowLogView.swift
//  AntSdkDemo
//
//  Created by 猜猜我是谁 on 2021/8/31.
//

import UIKit

class ShowLogView: UIView {

    var textView:UITextView!
    var isFollow = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView() {
        self.textView = UITextView.init(frame: .init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        self.textView.isEditable = false
        self.textView.backgroundColor = .green
        self.addSubview(self.textView)
        
        let clearButton = UIButton.init(type: .custom)
        clearButton.backgroundColor = .red.withAlphaComponent(0.3)
        clearButton.frame = CGRect.init(x: screenWidth-100, y: 0, width: 100, height: 40)
        clearButton.setTitle("关闭", for: .normal)
        clearButton.addTarget(self, action: #selector(clearBtnClick), for: .touchUpInside)
        self.addSubview(clearButton)
         
        let followButton = UIButton.init(type: .custom)
        followButton.backgroundColor = .red.withAlphaComponent(0.3)
        followButton.frame = CGRect.init(x: screenWidth-100, y: 50, width: 100, height: 40)
        followButton.setTitle("自动跟随", for: .normal)
        followButton.setTitle("取消跟随", for: .selected)
        followButton.isSelected = false
        followButton.addTarget(self, action: #selector(followBtnClick(sender:)), for: .touchUpInside)
        self.addSubview(followButton)
        
    }
    
    @objc func clearBtnClick() {
        self.clearString()
        self.isHidden = true
    }
    
    @objc func followBtnClick(sender:UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.isFollow = true
        }else{
            self.isFollow = false
        }
        
        
    }
    
    func writeString(string:String) {
        self.isHidden = false
        let formatter = DateFormatter.init()
        formatter.dateFormat = "HH:mm:ss.SSS"
        self.textView.text.append(String.init(format: "%@  %@\n", formatter.string(from: Date.init()),string))
        if self.isFollow {
            self.textView.layoutManager.allowsNonContiguousLayout = false
            self.textView.scrollRangeToVisible(NSRange.init(location: self.textView.text.count, length: 1))
        }
        
    }
    
    func clearString() {
        self.textView.text = ""
    }
    
}
