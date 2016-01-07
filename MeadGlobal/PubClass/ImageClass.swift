//
// 圖片影像 Class
//

import Foundation
import UIKit

/**
 * 圖片影像 Class
 */
class ImageClass {
    /**
    * init
    */
    init() {

    }
    
    /**
    * UIImage 轉換為 Base64 encode, 一律為 jpg 格式
    * @return String (Base64encode)
    */
    func ImgToBase64(mImage: UIImage) -> String {
        //let imageData = UIImagePNGRepresentation(mImage)
        let imageData = UIImageJPEGRepresentation(mImage, 0.6)
        
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
        return ResizeImage(SquareImage(image), targetSize: size)
    }
    
    /**
    * 回傳正方形影像
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
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        // 壓縮比, 壓縮圖片
        let fltZipRate: CGFloat = 1.0
        
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
        UIImageJPEGRepresentation(newImage, fltZipRate)
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}