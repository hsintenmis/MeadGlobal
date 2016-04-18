//
// 圖片影像 Class
//

import Foundation
import UIKit

/**
 * 圖片影像 Class
 */
class ImageClass {
    // common property
    private var pubClass = PubClass()
    
    /**
     * init
     */
    init() {
        
    }
    
    /**
     * UIImage 轉換為 Base64 encode, 一律為 jpg 格式
     * @return String (Base64encode)
     */
    func ImgToBase64(mImage: UIImage, compRate: CGFloat!) -> String {
        //let imageData = UIImagePNGRepresentation(mImage)
        let imageData = UIImageJPEGRepresentation(mImage, compRate)
        
        let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        //let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        return base64String
    }
    
    /**
     * Base64 encode 轉換為 UIImage
     * @return UIImage
     */
    func Base64ToImg(base64String: String) -> UIImage {
        let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions(rawValue: 0))
        let decodedimage = UIImage(data: decodedData!)
        
        return decodedimage!
    }
    
    /**
     * 指定 SIZE, 回傳正方形影像
     */
    func SquareImageTo(image: UIImage, size: CGSize) -> UIImage {
        return ResizeImage(SquareImage(image), targetSize: size, compRate: 1.0)
    }
    
    /**
     * 回傳圓形影像
     */
    func SquareImage(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        let cropSquare = CGRectMake((originalHeight - originalWidth)/2, 0.0, originalWidth, originalWidth)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    
    /**
     * 指定 SIZE, 回傳影像
     */
    func ResizeImage(image: UIImage, targetSize: CGSize, compRate: CGFloat!) -> UIImage {        
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        
        image.drawInRect(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //UIImagePNGRepresentation(newImage)
        UIImageJPEGRepresentation(newImage, compRate)
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
     * 讀取指定 URL 圖片, HTTP 連線, 開啟 'PopLoading' AlertView
     */
    func HTTPConn(mVC: UIViewController, strURL: String!, callBack: (NewImage: UIImage?)->Void) {
        let vcPopLoading = pubClass.getPopLoading(nil)
        mVC.presentViewController(vcPopLoading, animated: true, completion:{
            self.taskHTTPConn(strURL, AlertVC: vcPopLoading, callBack: callBack)
        })
    }
    
    /**
     * 讀取指定 URL 圖片, HTTP 連線, 產生 'task' 使用閉包, 回傳 UIImage 於 CallBack()使用
     */
    private func taskHTTPConn(strURL: String!, AlertVC vcPopLoading: UIAlertController, callBack: (NewImage: UIImage?)->Void) {
        
        // 產生 'task' 使用閉包
        let task = NSURLSession.sharedSession().dataTaskWithURL( NSURL(string: strURL)!, completionHandler:{ (mNSData, mRespon, mNSErr) -> Void in
            
            // http 回傳代碼, 200=OK
            if let httpResponse = mRespon as? NSHTTPURLResponse {
                if (Int(httpResponse.statusCode) == 200) {
                    
                    // 若取得 'stream' data, 設定到 imageView
                    if let imgTmp = UIImage(data: mNSData!) {
                        // 關閉 'vcPopLoading'
                        dispatch_async(dispatch_get_main_queue(), {
                            vcPopLoading.dismissViewControllerAnimated(true, completion: {
                                callBack(NewImage: imgTmp)
                            })
                        })
                    }
                }
            }
            
            // 關閉 'vcPopLoading'
            dispatch_async(dispatch_get_main_queue(), {
                vcPopLoading.dismissViewControllerAnimated(true, completion: {
                    callBack(NewImage: nil)
                })
            })
        })
        
        task.resume()
    }
    
}