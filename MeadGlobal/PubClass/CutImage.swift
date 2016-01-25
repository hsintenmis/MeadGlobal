//
// Class, 裁切圖片，指定方形/圓形，指定固定長寬
//

import UIKit
import Foundation
import CoreGraphics

/**
* protocol (Abstract)
*/
protocol ClipViewControllerDelegate {
    func ClipViewController(clipViewController: CutImage, FinishClipImage editImage: UIImage)
}

/**
 * Class, 裁切圖片，指定方形/圓形，指定固定長寬
 */
class CutImage: UIViewController, UIGestureRecognizerDelegate {
    var delegate: ClipViewControllerDelegate?
    
    /** 顯示'裁剪' 字串 */
    var D_CUTTRANLANG = "OK"
    
    // 圖片相關參數設定, 裁剪框的frame
    var scaleRation: CGFloat = 3.0  // 图片缩放的最大倍数
    var radius: CGFloat = 120.0  //圆形裁剪框的半径
    var circularFrame: CGRect?
    var OriginalFrame: CGRect?
    var currentFrame: CGRect?
    var clipType: Int = 0;  //裁剪的形状, 0=圓, 1=方
    
    // 設定圖片
    var _imageView: UIImageView = UIImageView()
    var _image: UIImage!
    var _overView: UIView = UIView()
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.CreatUI()
        //self.addAllGesture()
    }
    
    // View DidAppear
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        //self.CreatUI()
        //self.addAllGesture()
    }
    
    /**
    * 取得並設定 從圖庫選擇的圖片
    */
    func initWithImage(img: UIImage) {
        self._image = self.fixOrientation(img)
        
        self.CreatUI()
        self.addAllGesture()
    }
    
    /**
    * 建立 ViewControler UI
    */
    private func CreatUI() {
        self.view.backgroundColor = UIColor.whiteColor()
        
        // 验证 裁剪半径是否有效
        self.radius = (self.radius > self.view.frame.size.width/2)
            ? self.view.frame.size.width/2 : self.radius
        
        let width: CGFloat = self.view.frame.size.width
        let height: CGFloat = (_image.size.height / _image.size.width) * self.view.frame.size.width
        
        // 設定 ImageView
        _imageView = UIImageView(frame: CGRectMake(0, 0, width, height))
        _imageView.image = _image
        _imageView.contentMode = UIViewContentMode.ScaleAspectFill
        _imageView.center = self.view.center

        self.OriginalFrame = _imageView.frame;
        self.view.addSubview(_imageView)

        //覆盖层
        _overView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        _overView.backgroundColor = UIColor.clearColor()
        _overView.opaque = false
        
        self.view.addSubview(_overView)

        // 設定 Button
        let clipBtn = UIButton(type: UIButtonType.RoundedRect)
        
        clipBtn.frame = CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)
        clipBtn.backgroundColor = UIColor.blueColor()
        
        // Button .Selected
        let mySelectedAttributedTitle = NSAttributedString(string: D_CUTTRANLANG,
            attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        clipBtn.setAttributedTitle(mySelectedAttributedTitle, forState: .Selected)
        
        // Button .Normal
        let myNormalAttributedTitle = NSAttributedString(string: D_CUTTRANLANG,
            attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        clipBtn.setAttributedTitle(myNormalAttributedTitle, forState: .Normal)
        
        // Button add click event
        clipBtn.addTarget(self, action: "clipBtnSelected", forControlEvents: UIControlEvents.TouchUpInside)

        self.view.addSubview(clipBtn)

        // 绘制裁剪框
        self.drawClipPath(self.clipType)
        self.MakeImageViewFrameAdaptClipFrame()
    }
    
    /**
    * Button '裁剪' 點取, 取得裁剪的圖片，本 VC 結束
    */
    func clipBtnSelected() {
        delegate?.ClipViewController(self, FinishClipImage: self.getSmallImage())
    }
    
    /**
    * 方形裁剪
    */
    private func getSmallImage() ->UIImage {
        let width: CGFloat = _imageView.frame.size.width
        let rationScale: CGFloat = (width / _image.size.width)
        
        let origX: CGFloat = (self.circularFrame!.origin.x - _imageView.frame.origin.x) / rationScale
        let origY: CGFloat = (self.circularFrame!.origin.y - _imageView.frame.origin.y) / rationScale
        
        let oriWidth: CGFloat = self.circularFrame!.size.width / rationScale
        let oriHeight: CGFloat = self.circularFrame!.size.height / rationScale
        
        let myRect: CGRect = CGRectMake(origX, origY, oriWidth, oriHeight)
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(_image.CGImage, myRect)!

        UIGraphicsBeginImageContext(myRect.size)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextDrawImage(context, myRect, imageRef)
        
        let clipImage: UIImage = UIImage(CGImage: imageRef)
        UIGraphicsEndImageContext();
        
        // 圓形
        if (self.clipType == 0) {
            return self.CircularClipImage(clipImage)
        }
        
        return clipImage;
    }
    
    /**
    * 圆形图片
    */
    private func CircularClipImage(image: UIImage) -> UIImage {
        let arcCenterX: CGFloat = image.size.width / 2
        let arcCenterY: CGFloat = image.size.height / 2
        
        UIGraphicsBeginImageContext(image.size)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextBeginPath(context)
        CGContextAddArc(context, arcCenterX , arcCenterY, image.size.width / 2 , 0.0, CGFloat(M_PI) * 2, 0)
        CGContextClip(context);
        
        let myRect: CGRect = CGRectMake(0 , 0, image.size.width ,  image.size.height)
        image.drawInRect(myRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return  newImage;
    }
    
    /**
     * 绘制裁剪框
     * @param clipType: 0=圓, 1=方型
     */
    private func drawClipPath(clipType: Int) {
        // 取得螢幕長與寬
        let bounds = UIScreen.mainScreen().bounds
        let ScreenWidth: CGFloat = bounds.size.width
        let ScreenHeight: CGFloat = bounds.size.height
        let ScreenCenter: CGPoint = self.view.center
        
        self.circularFrame = CGRectMake(ScreenCenter.x - self.radius, ScreenCenter.y - self.radius, self.radius * 2, self.radius * 2)
        let mPath: UIBezierPath = UIBezierPath(rect: CGRectMake(0.0, 64.0, ScreenWidth, ScreenHeight))
        
        let layer: CAShapeLayer = CAShapeLayer()
        
        // 绘制圆形裁剪区域
        if (clipType == 0) {
            let pathCirl = UIBezierPath(arcCenter: ScreenCenter, radius: self.radius, startAngle: 0.0, endAngle: CGFloat(M_PI)*2.0, clockwise: false)
            mPath.appendPath(pathCirl)
        }
        else {
            let pathCirl = UIBezierPath(rect: CGRectMake(ScreenCenter.x - self.radius, ScreenCenter.y - self.radius, self.radius * 2, self.radius * 2))
            mPath.appendPath(pathCirl)
        }
        
        mPath.usesEvenOddFillRule = true
        layer.path = mPath.CGPath
        layer.fillRule = kCAFillRuleEvenOdd;
        layer.fillColor = UIColor.blackColor().CGColor
        layer.opacity = 0.5; // 透明度
        
        _overView.layer.addSublayer(layer)
    }
    
    /**
     * 让图片自己适应裁剪框的大小
     */
    private func MakeImageViewFrameAdaptClipFrame() {
        var width: CGFloat = _imageView.frame.size.width
        var height: CGFloat = _imageView.frame.size.height

        if (height < self.circularFrame!.size.height) {
            width = (width / height) * self.circularFrame!.size.height
            height = self.circularFrame!.size.height
            
            let mFrame: CGRect = CGRectMake(0, 0, width, height)
            _imageView.frame = mFrame
            _imageView.center = self.view.center
        }
    }
    
    /**
    * ViewControler 加入手勢設定
    */
    func addAllGesture() {
        // 捏合手势
        //let pinGesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinGesture")
        let pinGesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("handlePinGesture:"))

        pinGesture.delegate = self
        self.view.addGestureRecognizer(pinGesture)

        // 拖动手势
        //let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture")
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"))
        
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
    }
    
    /**
    * 手勢設定: 捏合手势
    */
    func handlePinGesture(pinGesture: UIPinchGestureRecognizer) {
        let mView: UIView = _imageView
        
        if (pinGesture.state ==  UIGestureRecognizerState.Began || pinGesture.state == UIGestureRecognizerState.Changed) {
            mView.transform = CGAffineTransformScale(mView.transform, pinGesture.scale, pinGesture.scale);
        }
        else if (pinGesture.state == UIGestureRecognizerState.Ended) {
            let ration: CGFloat = mView.frame.size.width / self.OriginalFrame!.size.width
            
            if (ration > self.scaleRation) {
                let newFrame: CGRect = CGRectMake(0, 0, self.OriginalFrame!.size.width * self.scaleRation, self.OriginalFrame!.size.height * self.scaleRation)
                mView.frame = newFrame
            }
            else if (mView.frame.size.width < self.circularFrame!.size.width && self.OriginalFrame!.size.width <= self.OriginalFrame!.size.height) {
                
                let rat: CGFloat = self.OriginalFrame!.size.height / self.OriginalFrame!.size.width
                let newFrame: CGRect = CGRectMake(0, 0, self.circularFrame!.size.width , self.circularFrame!.size.height * rat)
                mView.frame = newFrame
            }
            else if (mView.frame.size.height < self.circularFrame!.size.height && self.OriginalFrame!.size.height <= self.OriginalFrame!.size.width) {
                
                let rat: CGFloat = self.OriginalFrame!.size.width / self.OriginalFrame!.size.height
                let newFrame: CGRect = CGRectMake(0, 0, self.circularFrame!.size.width * rat, self.circularFrame!.size.height)
                mView.frame = newFrame
            }
            
            mView.center = self.view.center
            self.currentFrame = mView.frame;
        }
    }
    
    /**
     * 手勢設定: 拖动手势
     */
    func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        let mView: UIView = self._imageView
        
        if (panGesture.state == UIGestureRecognizerState.Began || panGesture.state == UIGestureRecognizerState.Changed) {
            
            let translation: CGPoint = panGesture.translationInView(mView.superview)
            mView.center = CGPointMake(mView.center.x + translation.x, mView.center.y + translation.y)
            panGesture.setTranslation(CGPointZero, inView: mView.superview)
        }
        else if (panGesture.state == UIGestureRecognizerState.Ended) {
            var currentFrame: CGRect = mView.frame
            
            // 向右滑动 并且超出裁剪范围后
            if (currentFrame.origin.x >= self.circularFrame!.origin.x) {
                currentFrame.origin.x = self.circularFrame!.origin.x;
            }
            // 向下滑动 并且超出裁剪范围后
            if (currentFrame.origin.y >= self.circularFrame!.origin.y) {
                currentFrame.origin.y = self.circularFrame!.origin.y;
            }
            // 向左滑动 并且超出裁剪范围后
            if (currentFrame.size.width + currentFrame.origin.x < self.circularFrame!.origin.x + self.circularFrame!.size.width) {
                
                let movedLeftX: CGFloat = fabs(currentFrame.size.width + currentFrame.origin.x - (self.circularFrame!.origin.x + self.circularFrame!.size.width))
                currentFrame.origin.x += movedLeftX;
            }
            // 向上滑动 并且超出裁剪范围后
            if (currentFrame.size.height + currentFrame.origin.y < self.circularFrame!.origin.y + self.circularFrame!.size.height) {
                
                let moveUpY: CGFloat = fabs(currentFrame.size.height + currentFrame.origin.y - (self.circularFrame!.origin.y + self.circularFrame!.size.height))
                currentFrame.origin.y += moveUpY;
            }
            
            UIView.animateWithDuration(0.05, animations: {mView.frame = currentFrame})
            //[UIView animateWithDuration:0.05 animations:^{[view setFrame:currentFrame];}];
        }
    }

    /**
    * 修正圖片方向
    */
    private func fixOrientation(image: UIImage!) -> UIImage {
        //return image.imageWithRenderingMode(.AlwaysOriginal)
        
        if (image.imageOrientation == UIImageOrientation.Up) {
            return image
        }
        
        //var transform: CGAffineTransform = CGAffineTransformIdentity
        let transform = self._getTransform(image)

        //let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), CGImageGetBitsPerComponent(image.CGImage), 0, CGImageGetColorSpace(image.CGImage), UInt32(CGImageGetBitmapInfo(image.CGImage).rawValue))!

        let size = image.size
        let cgImage = image.CGImage
        let width = CGImageGetWidth(cgImage)
        let height = CGImageGetHeight(cgImage)
        let bitsPerComponent = CGImageGetBitsPerComponent(cgImage)
        let bytesPerRow = CGImageGetBytesPerRow(cgImage)
        let colorSpace = CGImageGetColorSpace(cgImage)
        let bitmapInfo = CGImageGetBitmapInfo(cgImage)
        
        //UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        //image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let ctx = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        CGContextConcatCTM(ctx, transform)
        
        // 判別是否需要調換 長/寬
        var mRect: CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        
        switch (image.imageOrientation) {
        case UIImageOrientation.Left: break
        case UIImageOrientation.LeftMirrored: break
        case UIImageOrientation.Right: break
        case UIImageOrientation.RightMirrored:
            mRect = CGRectMake(0,0, image.size.height, image.size.width)
            break
        default:
            break
        }
        
        // 重新繪製 image
        let cgNewImage = CGBitmapContextCreateImage(ctx)
        CGContextDrawImage(ctx, mRect, cgNewImage)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //let cgimg: CGImageRef = CGBitmapContextCreateImage(ctx)!
        //let img: UIImage = UIImage(CGImage: cgimg)
        
        return img
    }
    
    /**
    * 修正圖片方向，回傳 'CGAffineTransform'
    */
    private func _getTransform(image: UIImage!)->CGAffineTransform {
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        switch (image.imageOrientation) {
        case UIImageOrientation.Down: break
        case UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
            
        case UIImageOrientation.Left: break
        case UIImageOrientation.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
            
        case UIImageOrientation.Right: break
        case UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            break
            
        default:
            break
        }
        
        switch (image.imageOrientation) {
        case UIImageOrientation.UpMirrored: break
        case UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
            
        case UIImageOrientation.LeftMirrored: break
        case UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break;
            
        default:
            break
        }
        
        return transform
    }

}
