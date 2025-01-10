//
//  ExtensionFile.swift
//  ZyTools
//
//  Created by 猜猜我是谁 on 2024/4/26.
//

import Foundation
import UIKit

extension UIViewController {
    class func getAnyVC<T>(vc:T) -> T? {
        
        var anyVC:T? = nil
        let HcWindow = UIApplication.shared.delegate as! AppDelegate
        let nc = HcWindow.window?.rootViewController
        //print("nc = \(nc)")
        if nc is UITabBarController {
            let nc:UITabBarController = nc as! UITabBarController
            for vc in nc.viewControllers! {
                if vc is UINavigationController {
                    let vc:UINavigationController = vc as! UINavigationController
                    for item in vc.viewControllers {
                        if item is T {
                            anyVC = item as? T
                        }
                        //print("item = \(item)")
                    }
                }
            }
        }else if nc is UINavigationController {
            let nc:UINavigationController = nc as! UINavigationController
            for vc in nc.viewControllers {
                if vc is UINavigationController {
                    let vc:UINavigationController = vc as! UINavigationController
                    for item in vc.viewControllers {
                        if item is T {
                            anyVC = item as? T
                        }
                        //print("item = \(item)")
                    }
                }
                if vc is UIViewController {
                    if vc is T {
                        anyVC = vc as? T
                    }
                }
            }
        }
        return anyVC
    }
    
    func presentTextFieldAlertVC(title:String?,message:String?,holderStringArray:[String]? = [],cancel:String? = NSLocalizedString("Cancel", comment: "取消") ,cancelAction:(()->())?,ok:String? = NSLocalizedString("Sure", comment: "确定") ,okAction:(([String])->())?){

        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)

        var cancel = cancel
        if cancel == nil {
            cancel = NSLocalizedString("Cancel", comment: "取消")
        }
        
        var ok = ok
        if ok == nil {
            ok = NSLocalizedString("Sure", comment: "确定")
        }
        
        for item in holderStringArray ?? [] {
            alertVC.addTextField { (textField) in
                textField.keyboardType = .numbersAndPunctuation
                textField.placeholder = item
            }
        }
        
        let cancelAC = UIAlertAction.init(title: cancel, style: .default) { (action) in
            if let cancelAction = cancelAction{
                cancelAction()
            }
        }

        let okAC = UIAlertAction.init(title: ok, style: .default) { (action) in
            var array = [String].init()
            for i in stride(from: 0, to: holderStringArray?.count ?? 0, by: 1) {
                let textField = alertVC.textFields?[i]
                array.append(textField?.text ?? "")
            }
            
            if let okAction = okAction{
                okAction(array)
            }
        }

        alertVC.addAction(cancelAC)
        alertVC.addAction(okAC)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            alertVC.popoverPresentationController?.sourceView = self.view //要展示在哪里
            
            alertVC.popoverPresentationController?.sourceRect = self.view.frame //箭头指向哪里
            
        }
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func presentSystemAlertVC(title:String?,message:String?,cancel:String? = NSLocalizedString("Cancel", comment: "取消"),cancelAction:(()->())?,ok:String? = NSLocalizedString("Sure", comment: "确定"),okAction:(()->())?) {
        
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)

        var cancel = cancel
        if cancel == nil {
            cancel = NSLocalizedString("Cancel", comment: "取消")
        }
        
        var ok = ok
        if ok == nil {
            ok = NSLocalizedString("Sure", comment: "确定")
        }
        
        if let cancelAction = cancelAction{
            let cancelAC = UIAlertAction.init(title: cancel, style: .default) { (action) in
                cancelAction()
            }
            alertVC.addAction(cancelAC)
        }
        
        //cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        if let okAction = okAction{
            let okAC = UIAlertAction.init(title: ok, style: .default) { (action) in
                okAction()
            }
            alertVC.addAction(okAC)
        }

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            alertVC.popoverPresentationController?.sourceView = self.view //要展示在哪里
            
            alertVC.popoverPresentationController?.sourceRect = self.view.frame //箭头指向哪里
            
        }
        
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension UIColor {
     
    // Hex String -> UIColor
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
         
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
         
        var color: UInt32 = 0xFFFFFF
        scanner.scanHexInt32(&color)
         
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
         
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
         
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
     
    // UIColor -> Hex String
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(UInt8.max)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
         
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
}

extension UIImage{
    
    /**
    获取图片中的像素颜色值
    
    - parameter pos: 图片中的位置
    
    - returns: 颜色值
    */
    func getPixelColor(pos:CGPoint)->(alpha: UInt8, red: UInt8, green: UInt8,blue:UInt8){
//        pixelsWide
        if let cgImage = self.cgImage {
            let pixelData=cgImage.dataProvider?.data//CGImageGetDataProvider(cgImage).data
            
            let data:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            let pixelInfo: Int = ((Int(cgImage.width) * Int(pos.x)) + Int(pos.y)) * 4
            
            //("pixelData =",CFDataGetLength(pixelData))
            //print("cgImage.bytesPerRow =",cgImage.bytesPerRow)
            //print("cgImage.width =",cgImage.width)
            //print("cgImage.height =",cgImage.height)
            
            var a:UInt8 = 0
            var r:UInt8 = 0
            var g:UInt8 = 0
            var b:UInt8 = 0
            
            if cgImage.alphaInfo == .premultipliedFirst || cgImage.alphaInfo == .noneSkipFirst || cgImage.alphaInfo == .first {
                //ARGB
                a = UInt8(data[pixelInfo])
                r = UInt8(data[pixelInfo+1])
                g = UInt8(data[pixelInfo+2])
                b = UInt8(data[pixelInfo+3])
                
            }else if cgImage.alphaInfo == .premultipliedLast || cgImage.alphaInfo == .noneSkipLast || cgImage.alphaInfo == .last {
                //RGBA
                r = UInt8(data[pixelInfo])
                g = UInt8(data[pixelInfo+1])
                b = UInt8(data[pixelInfo+2])
                a = UInt8(data[pixelInfo+3])
                
            }
            
            return (a,r,g,b)
        }
        
        return (0,0,0,0)
    }
    
    public func pickColor(at position: CGPoint) -> (alpha: UInt8, red: UInt8, green: UInt8,blue:UInt8) {
        
        // 用来存放目标像素值
//        var pixel = [UInt8](repeatElement(0, count: 4))
//        // 颜色空间为 RGB，这决定了输出颜色的编码是 RGB 还是其他（比如 YUV）
//        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!//CGColorSpaceCreateDeviceRGB()
//        // 设置位图颜色分布为 RGBA
//        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
//        guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
//            return (0,0,0,0)
//        }
//        // 设置 context 原点偏移为目标位置所有坐标
//        context.translateBy(x: -position.x, y: -position.y)
//        // 将图像渲染到 context 中
//        if let cgImage = self.cgImage {
//            context.draw(cgImage, in: .init(origin: .init(x: 0, y: 0), size: self.size))
//        }
//        let r:UInt8 = UInt8(pixel[0])
//        let g:UInt8 = UInt8(pixel[1])
//        let b:UInt8 = UInt8(pixel[2])
//        let a:UInt8 = UInt8(pixel[3])
//
//        return (a,r,g,b)
//
        

            let pointX = trunc(position.x);
            let pointY = trunc(position.y);

            let width = self.size.width;
            let height = self.size.height;
            let colorSpace = CGColorSpaceCreateDeviceRGB();
            var pixelData: [UInt8] = [0, 0, 0, 0]

            pixelData.withUnsafeMutableBytes { pointer in
                if let context = CGContext(data: pointer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), let cgImage = self.cgImage {
                    context.setBlendMode(.copy)
                    context.translateBy(x: -pointX, y: pointY - height)
                    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
                }
            }
        
        let r:UInt8 = UInt8(pixelData[0])
        let g:UInt8 = UInt8(pixelData[1])
        let b:UInt8 = UInt8(pixelData[2])
        let a:UInt8 = UInt8(pixelData[3])

        return (a,r,g,b)

            

    }
    
    func img_changeSize(size:CGSize) -> UIImage {


        if let cgImage = self.cgImage {

            UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
            self.draw(in: .init(x: 0, y: 0, width: size.width, height: size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage ?? UIImage.init()

        }
        return UIImage.init()

    }
    
    func img_changeCircle(fillColor:UIColor) -> UIImage{

        if let cgImage = self.cgImage {
            let rect = CGRect.init(origin: .zero, size: CGSize.init(width: cgImage.width, height: cgImage.height))
            
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 1.0)
            fillColor.setFill()
            UIRectFill(rect)
            
            let path = UIBezierPath.init(ovalIn: rect)
            path.addClip()
            
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? UIImage.init()
        }
        return UIImage.init()
    }
    
    /**
     Converts the image into an array of RGBA bytes.
     */
    @nonobjc public func toByteArray() -> [UInt8] {
        let width = Int(size.width)
        let height = Int(size.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        
        bytes.withUnsafeMutableBytes { ptr in
            if let context = CGContext(
                data: ptr.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) {
                
                if let image = self.cgImage {
                    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    context.draw(image, in: rect)
                }
            }
        }
        return bytes
    }
    
    /**
     Creates a new UIImage from an array of RGBA bytes.
     */
    @nonobjc public class func fromByteArray(_ bytes: UnsafeMutableRawPointer,
                                             width: Int,
                                             height: Int) -> UIImage {
        
        if let context = CGContext(data: bytes, width: width, height: height,
                                   bitsPerComponent: 8, bytesPerRow: width * 4,
                                   space: CGColorSpaceCreateDeviceRGB(),
                                   bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue),
           let cgImage = context.makeImage() {
            return UIImage(cgImage: cgImage, scale: 0, orientation: .up)
        } else {
            return UIImage()
        }
    }
    
}

extension Date {
    // MARK: - 返回dayCount天日期，+为之后，-为之前
    func afterDay(dayCount:Int) -> Date {
        return self.addingTimeInterval(TimeInterval(dayCount * 86400))
    }
    
    func conversionDateToString(DateFormat dateFormatter:String) -> String {
        let formatter = DateFormatter.init()
        //formatter.dateStyle = .medium
        formatter.dateFormat = dateFormatter
        return formatter.string(from:self)
    }
    
    var Year: Int {
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let year = calendar.component(.year, from: self)
        return year
    }

    var Month: Int {
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let month = calendar.component(.month, from: self)
        return month
    }
    
    var Day: Int {
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let day = calendar.component(.day, from: self)
        return day
    }
    
    var Hour: Int {
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let hour = calendar.component(.hour, from: self)
        return hour
    }
    
    var Minute: Int {
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let minute = calendar.component(.minute, from: self)
        return minute
    }
    
    var Second: Int {
        let calendar = Calendar.init(identifier: Foundation.Calendar.Identifier.gregorian)
        let second = calendar.component(.second, from: self)
        return second
    }
}

extension FileManager {
    
    // 文件管理器
    static var fileManager: FileManager {
        return FileManager.default
    }
    
    // MARK: 2.1、创建文件夹(蓝色的，文件夹和文件是不一样的)
    /// 创建文件夹(蓝色的，文件夹和文件是不一样的)
    /// - Parameter folderName: 文件夹的名字
    /// - Returns: 返回创建的 创建文件夹路径
    @discardableResult
    static func createFolder(folderPath: String) -> (isSuccess: Bool, error: String) {
        if !judgeFileOrFolderExists(filePath: folderPath) {
            // 不存在的路径才会创建
            do {
                // withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
                try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                print("创建文件夹成功")
                return (true, "")
            } catch _ {
                return (false, "创建失败")
            }
        }
        return (true, "")
    }
    
    // MARK: 2.2、删除文件夹
    /// 删除文件夹
    /// - Parameter folderPath: 文件的路径
    @discardableResult
    static func removefolder(folderPath: String) -> (isSuccess: Bool, error: String) {
        let filePath = "\(folderPath)"
        guard judgeFileOrFolderExists(filePath: filePath) else {
            // 不存在就不做什么操作了
            print("removefolder 文件路径为空")
            return (true, "")
        }
        // 文件存在进行删除
        do {
            try fileManager.removeItem(atPath: filePath)
            print("删除文件夹成功")
            return (true, "")
            
        } catch _ {
            return (false, "删除失败")
        }
    }
    
    // MARK: 2.3、创建文件
    /// 创建文件
    /// - Parameter filePath: 文件路径
    /// - Returns: 返回创建的结果 和 路径
    @discardableResult
    static func createFile(filePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: filePath) else {
            // 不存在的文件路径才会创建
            // withIntermediateDirectories 为 ture 表示路径中间如果有不存在的文件夹都会创建
            let createSuccess = fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
            
            return (createSuccess, "")
        }
        return (true, "")
    }
    
    // MARK: 2.4、删除文件
    /// 删除文件
    /// - Parameter filePath: 文件路径
    @discardableResult
    static func removefile(filePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: filePath) else {
            // 不存在的文件路径就不需要要移除
            return (true, "")
        }
        // 移除文件
        do {
            try fileManager.removeItem(atPath: filePath)
            print("删除文件成功")
            return (true, "")
        } catch _ {
            return (false, "移除文件失败")
        }
    }
    
    // MARK: 文件写入
    @discardableResult
    static func writeDicToFile(content: [String:Any], writePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: writePath) else {
            // 不存在的文件路径
            print("writeDicToFile 文件路径为空")
            return (false, "不存在的文件路径")
        }
        
        let result = (content as NSDictionary).write(toFile: writePath, atomically: true)
        if result {
            print("文件写入成功")
            return (true, "")
        } else {
            return (false, "写入失败")
        }
    }
    
    //文件读取
    @discardableResult
    static func readDicFromFile(readPath: String) -> (isSuccess: Bool, content: Any?, error: String) {
        guard judgeFileOrFolderExists(filePath: readPath),  let readHandler =  FileHandle(forReadingAtPath: readPath) else {
            // 不存在的文件路径
            print("readDicFromFile 文件路径为空")
            return (false, nil, "不存在的文件路径")
        }

        let dic = NSDictionary.init(contentsOfFile: readPath)
        
        return (true, dic, "")
    }
    
    // MARK: 图片写入
    @discardableResult
    static func writeImageToFile(content: UIImage, writePath: String) -> (isSuccess: Bool, error: String) {
        guard judgeFileOrFolderExists(filePath: writePath) else {
            // 不存在的文件路径
            print("writeImageToFile 文件路径为空")
            return (false, "不存在的文件路径")
        }

        let imageData:Data = content.pngData() ?? Data.init()
        let result: ()? = try? imageData.write(to: URL.init(fileURLWithPath: writePath))
        
        if (result != nil) {
            print("文件写入成功")
            return (true, "")
        }else{
            return (false, "写入失败")
        }
        
    }
    
    //图片读取
    @discardableResult
    static func readImageFromFile(readPath: String) -> (isSuccess: Bool, content: Any?, error: String) {
        guard judgeFileOrFolderExists(filePath: readPath) else {
            // 不存在的文件路径
            print("readImageFromFile 文件路径为空")
            return (false, nil, "不存在的文件路径")
        }

        let image = UIImage.init(contentsOfFile: readPath)
        return (true, image, "")

    }
    
    //获取文件夹下文件列表
    @discardableResult
    static func getFileListInFolderWithPath(path:String) -> (isSuccess: Bool, content: [Any]?, error: String) {
        guard judgeFileOrFolderExists(filePath: path) else {
            // 不存在的文件路径
            print("getFileListInFolderWithPath 文件路径为空")
            return (false , nil , "不存在的文件路径")
        }
        
        do {
            // withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
            let fileList = try self.fileManager.contentsOfDirectory(atPath: path)
//            print("获取文件夹下文件列表成功")
            return (true , fileList , "获取成功")
        } catch _ {
            return (false , nil , "获取失败")
        }

        
    }

    
    // MARK: 2.10、判断 (文件夹/文件) 是否存在
     /** 判断文件或文件夹是否存在*/
     static func judgeFileOrFolderExists(filePath: String) -> Bool {
         let exist = fileManager.fileExists(atPath: filePath)
         // 查看文件夹是否存在，如果存在就直接读取，不存在就直接反空
         guard exist else {
             return false
         }
         return true
     }
}
