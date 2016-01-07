//
// 網路存取設定
// info.plist 設定 NSAppTransportSecurity => dict: NSAllowsArbitraryLoads = YES
//

import Foundation
import UIKit

/**
* 本專案所有的設定檔與公用 method
*/
class PubClass {
    // public
    /** 伺服器/網站 URL: http://pub.mysoqi.com/store_cn/001/ */
    let D_WEBURL = "http://pub.mysoqi.com/store_cn/001/"
    
    /** 會員資料檔 JSON string, 檔名: member.txt */
    let D_FILE_MEMBER = "member.txt"
    
    /** 會員資料，唯一識別碼前置字串，ex. 'MEAD' + '000001' */
    let D_STR_IDHEAD = "MEAD"
    
    // AppDelegate
    var AppDelg: AppDelegate!
    
    // 本專案語系相關
    var aryLangCode = ["Base", "zh-Hans", "zh-Hant", "es"]
    
    // private property
    private let mVCtrl: UIViewController!
    
    // pop Window 相關
    var isPopWindowShow = false; // 頁面是否有 popWindow 顯示中
    var mPopLoading: UIAlertController? // 目前產生 pop Loading 視窗的 'ViewControler'
    
    /**
    * init
    */
    init(viewControl: UIViewController) {
        mVCtrl = viewControl;
        AppDelg = UIApplication.sharedApplication().delegate! as! AppDelegate
    }
    
    /**
     * 設定 AppDelegate 全域變數的 value
     */
    func setAppDelgVal(strKey: String, withVal mVal: AnyObject) {
        AppDelg.setValue(mVal, forKey: strKey)
    }
    
    /**
    * 取得 prefer data, NSUserDefaults<br>
    * ex. key: acc, psd, save(登入頁面儲存 switch), lang
    */
    func getPrefData(strKey: String)->AnyObject? {
        let mPref = self.getPrefData()
        return mPref[strKey]
    }
    
    /**
     * 回傳 pref data, Dictionary 格式<BR>
     * ex. key: acc, psd, save(登入頁面儲存 switch), lang
     */
    func getPrefData()->Dictionary<String, AnyObject> {
        let mPref = NSUserDefaults(suiteName: "standardUserDefaults")!
        var dictPref = Dictionary<String, AnyObject>()
        
        dictPref["acc"] = ""
        dictPref["psd"] = ""
        dictPref["issave"] = true
        dictPref["lang"] = aryLangCode[0]
        
        // 取得 pref data
        if let strAcc: String = mPref.objectForKey("acc") as? String {
            dictPref["acc"] = strAcc
        }
        
        if let strPsd: String = mPref.objectForKey("psd") as? String {
            dictPref["psd"] = strPsd
        }
        
        if let bolSave: Bool = mPref.objectForKey("issave") as? Bool {
            dictPref["issave"] = bolSave
        }
        
        if let strLang: String = mPref.objectForKey("lang") as? String {
            dictPref["lang"] = strLang
        }
        
        return dictPref
    }
    
    /**
    * 輸入字串轉換為指定語系文字, 點取 'Localizable' 語系檔查看'?'
    */
    func getLang(strCode: String!)->String {
        let strLang = AppDelg.V_LANGCODE + ".lproj/Localizable"
        
        return NSLocalizedString(strCode, tableName: strLang, bundle:NSBundle.mainBundle(), value: "", comment: "")
    }
    
    /**
    * SubString
    */
    func subStr(mStr: String, strFrom: Int, strEnd: Int)->String {
        return mStr.substringWithRange(Range<String.Index>(start: mStr.startIndex.advancedBy(strFrom), end: mStr.startIndex.advancedBy(strEnd)))
    }
    
    /**
    * 取得 prefer 的 user data, ex. acc, psd ...
    */
    func getUserData()->[String : String] {
        var aryUser = Dictionary<String, String>()
        aryUser["acc"] = "kevin"
        aryUser["psd"] = "12345"
        
        return aryUser
    }
    
    /**
     * [我知道了] 彈出視窗
     */
    func popIsee(var Title strTitle: String? = nil, Msg strMsg: String!) {
        if strTitle == nil {
            strTitle = getLang("sysprompt")
        }
        
        let mAlert = UIAlertController(title: strTitle, message: strMsg, preferredStyle:UIAlertControllerStyle.Alert)
        
        mAlert.addAction(UIAlertAction(title:getLang("i_see"), style: UIAlertActionStyle.Default, handler:nil))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mVCtrl.presentViewController(mAlert, animated: true, completion: nil)
        })
    }
    
    /**
     * [我知道了] 彈出視窗, with 'handler'
     */
    func popIsee(var Title strTitle: String? = nil, Msg strMsg: String!, withHandler mHandler:()->Void) {
        if strTitle == nil {
            strTitle = getLang("sysprompt")
        }
        
        let mAlert = UIAlertController(title: strTitle, message: strMsg, preferredStyle:UIAlertControllerStyle.Alert)
        
        mAlert.addAction(UIAlertAction(title:getLang("i_see"), style: UIAlertActionStyle.Default, handler:
            {(action: UIAlertAction!) in mHandler()}
        ))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mVCtrl.presentViewController(mAlert, animated: true, completion: nil)
        })
    }
    
    /**
    * 產生 UIAlertController (popWindow 資料傳送中)
    */
    func getPopLoading(msg: String?) -> UIAlertController {
        var mPopLoading: UIAlertController
        let strMsg = (msg == nil) ? self.getLang("datatranplzwait") : msg
        
        mPopLoading = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        mPopLoading.restorationIdentifier = "popLoading"
        mPopLoading.message = strMsg
        
        return mPopLoading
    }
    
    /**
    * HTTP 連線, 使用 post 方式, 'callBack' 需要實作<BR>
    * callBack 參數為 JSON data
    */
    func startHTTPConn(dictParm: Dictionary<String, String>!, callBack: (Dictionary<String, AnyObject>)->Void ) {
        
        // 將 dict 參數轉為 string
        var strConnParm: String = "";
        var loopi = 0
        
        for (strKey, strVal) in dictParm {
            strConnParm += "\(strKey)=\(strVal)"
            loopi++
            
            if loopi != dictParm.count {
                strConnParm += "&"
            }
        }
        
        // 產生 popWindow
        let mPop = self.getPopLoading(nil)
        
        self.mVCtrl.presentViewController(mPop, animated: false, completion:{
            // 產生 http Request
            let mRequest = NSMutableURLRequest(URL: NSURL(string: self.D_WEBURL)!)
            mRequest.HTTPBody = strConnParm.dataUsingEncoding(NSUTF8StringEncoding)
            mRequest.HTTPMethod = "POST"
            mRequest.timeoutInterval = 60
            mRequest.HTTPShouldHandleCookies = false
            
            // 產生 'task' 使用閉包
            let task = NSURLSession.sharedSession().dataTaskWithRequest(mRequest) {
                data, response, error in
                
                var dictRS = Dictionary<String, AnyObject>();
                
                if error != nil {
                    dictRS = self.getHTTPJSONData(nil)
                } else {
                    dictRS = self.getHTTPJSONData(data!)
                }
                
                // 關閉 popWindow
                mPop.dismissViewControllerAnimated(false, completion:nil)
                
                callBack(dictRS)
            }
            
            task.resume()
        })
    }
    
    /**
    * HTTP 連線, 連線取得 NSData 解析並回傳 JSON data<BR>
    * 回傳資料如: 'result' => bool, 'msg' => 錯誤訊息 or nil, 'data' => Dictionary
    */
    private func getHTTPJSONData(mData: NSData?)->Dictionary<String, AnyObject> {
        var dictRS = Dictionary<String, AnyObject>()
        dictRS["result"] = false
        dictRS["msg"] = self.getLang("err_data")
        dictRS["data"] = nil
        
        // 檢查回傳的 'NSData'
        if mData == nil {
            return dictRS
        }
        
        // 解析回傳的 NSData 為 JSON
        do {
            let jobjRoot = try NSJSONSerialization.JSONObjectWithData(mData!, options:NSJSONReadingOptions(rawValue: 0))
            
            guard let dictRespon = jobjRoot as? Dictionary<String, AnyObject> else {
                dictRS["msg"] = "資料解析錯誤 (JSON data error)！"
                return dictRS
            }
            
            if ( dictRespon["result"] as! Bool != true) {
                dictRS["msg"] = "回傳結果失敗！"
                return dictRS
            }
            
            // 解析正確的 jobj data
            dictRS["result"] = true
            dictRS["msg"] = nil
            dictRS["data"] = dictRespon
            
            return dictRS
        }
        catch let errJson as NSError {
            dictRS["msg"] = "資料解析錯誤!\n\(errJson)"
            return dictRS
        }
    }
    
    /**
    * Color 使用 HEX code, ex. #FFFFFF, 回傳 UIColor
    */
    func ColorHEX (hex:String!) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    /**
    * 顏色數值輸入'#FFFFFF', 回傳 CGColor
    */
    func ColorCGColor(hex: String!)->CGColor {
        let mColor = self.ColorHEX(hex)
        return mColor.CGColor
    }
    
    /**
     * 字串格式化可閱讀的日期文字, ex. '20150131235959' = 2015年01月31日 23:59<BR>
     * @param type: 8 or 14 (Int)
     */
    func formatDateWithStr(strDate: String!, type: Int?)->String {
        if ( strDate.characters.count < 8) {
            return strDate
        }
        
        var strYY: String, strMM: String, strDD: String

        strYY = strDate.substringWithRange(Range<String.Index>(start: strDate.startIndex.advancedBy(0), end: strDate.startIndex.advancedBy(4)))
        strMM = strDate.substringWithRange(Range<String.Index>(start: strDate.startIndex.advancedBy(4), end: strDate.startIndex.advancedBy(6)))
        strDD = strDate.substringWithRange(Range<String.Index>(start: strDate.startIndex.advancedBy(6), end: strDate.startIndex.advancedBy(8)))
        
        if (type == 8) {
            return "\(strYY)年\(Int(strMM)!)月\(Int(strDD)!)日"
        }
        
        if (type > 8) {
            var strHH: String, strMin: String
            
            strHH = strDate.substringWithRange(Range<String.Index>(start: strDate.startIndex.advancedBy(8), end: strDate.startIndex.advancedBy(10)))
            strMin = strDate.substringWithRange(Range<String.Index>(start: strDate.startIndex.advancedBy(10), end: strDate.startIndex.advancedBy(12)))
            
            return "\(strYY)年\(strMM)月\(strDD)日 \(strHH):\(strMin)"
        }
        
        return strDate
    }
    
    /**
     * 字串格式化可閱讀的日期文字, 簡短顯示 ex. '20150131235959' = 2015/01/31 23:59<BR>
     * @param type: 8s or 14s (String)
     */
    func formatDateWithStr(strDate: String!, type: String?)->String {
        if ( strDate.characters.count < 8) {
            return strDate
        }
        
        var strYY: String, strMM: String, strDD: String
        
        strYY = strDate.substringWithRange(Range<String.Index>(start: strDate.startIndex.advancedBy(0), end: strDate.startIndex.advancedBy(4)))
        strMM = strDate.substringWithRange(Range<String.Index>(start: strDate.startIndex.advancedBy(4), end: strDate.startIndex.advancedBy(6)))
        strDD = strDate.substringWithRange(Range<String.Index>(start: strDate.startIndex.advancedBy(6), end: strDate.startIndex.advancedBy(8)))
        
        if (type == "8s") {
            return "\(strYY)/\(strMM)/\(strDD)"
        }
        
        if (type == "14s") {
            var strHH: String, strMin: String
            
            strHH = strDate.substringWithRange(Range<String.Index>(start: strDate.startIndex.advancedBy(8), end: strDate.startIndex.advancedBy(10)))
            strMin = strDate.substringWithRange(Range<String.Index>(start: strDate.startIndex.advancedBy(10), end: strDate.startIndex.advancedBy(12)))
            
            return "\(strYY)/\(strMM)/\(strDD) \(strHH):\(strMin)"
        }
        
        return strDate
    }
    
    /**
    * 計算動態 View 的 CGFloat 長,寬
    * @return dict: ex. dict["h"], dict["w"]
    */
    func getUIViewSize(mView: UIView)->Dictionary<String, CGFloat> {
        let mSize = mView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        var dictData = Dictionary<String, CGFloat>()
        dictData["h"] = mSize.height
        dictData["w"] = mSize.width
        
        return dictData
    }
    
    /**
     * 根據輸入的 width 重新調整 Imgae 尺寸
     */
    func resizeImageWithWidth(sourceImage: UIImage, imgWidth: CGFloat)->UIImage {
        // 若 width <= 輸入的 width, 直接回傳原 image
        let oldWidth: CGFloat = sourceImage.size.width
        if (imgWidth >= oldWidth) {
            return sourceImage
        }
        
        // 重新計算長寬
        let scaleFactor: CGFloat = imgWidth / oldWidth
        let newHeight: CGFloat = sourceImage.size.height * scaleFactor
        let newWidth: CGFloat = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        sourceImage.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    /**
    * 回傳裝置的 '今天' 日期 14 碼
    */
    func getDevToday()-> String {
        let calendar = NSCalendar.currentCalendar()
        let date = NSDate()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
        
        var strRS = String(components.year)
        strRS += String(format: "%02d", components.month)
        strRS += String(format: "%02d", components.day)
        strRS += String(format: "%02d", components.hour)
        strRS += String(format: "%02d", components.minute)
        
        return strRS
    }

    /**
     * Keyboard 相關, 使用全域 NSNotificationCenter
     * 宣告 NSNotificationCenter, Keyboard show/hide 使用
     * <BR>
     * 需要實作: <BR>
     *   keyboardWillShow(note: NSNotification)<BR>
     *   keyboardWillHide(note: NSNotification)<BR>
     *
     */
    func setKeyboardNotify() {
        NSNotificationCenter.defaultCenter().addObserver(
            mVCtrl,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            mVCtrl,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil)
        
        // 設定點取 view 空白處，執行鍵盤關閉程序
        let mTap = UITapGestureRecognizer(target: mVCtrl, action: "keyboardHide:")
        mTap.cancelsTouchesInView = false
        mVCtrl.view.addGestureRecognizer(mTap)
    }
    
    /**
     * Keyboard 相關<BR>
     * 虛擬鍵盤將要 [開啟] 時執行相關程序，view 往上提升
     */
    func KBShowProc(note: NSNotification) {
        let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
        let duration = NSTimeInterval(keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber)
        
        // 偵測虛擬鍵盤高度
        //let keyboardFrameValue = keyboardAnimationDetail[UIKeyboardFrameBeginUserInfoKey]! as! NSValue
        //let keyboardFrame = keyboardFrameValue.CGRectValue()
        //let hight_keyboard = -keyboardFrame.size.height
        
        // 使用固定高度
        let hight_fix: CGFloat = -40.0
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.mVCtrl.view.frame = CGRectOffset(self.mVCtrl.view.frame, 0, hight_fix)
        })
    }
    
    /**
     * Keyboard 相關<BR>
     * 虛擬鍵盤將要 [關閉] 時執行相關程序, ，view 往下
     */
    func KBHideProc(note: NSNotification) {
        let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
        let duration = NSTimeInterval(keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber)
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.mVCtrl.view.frame = CGRectOffset(self.mVCtrl.view.frame, 0, -(self.mVCtrl.view.frame.origin.y))
        })
    }
    
    /**
     * 設定 UIViewControler 的背景
     */
    func setVCBackgroundImg(strFilename: String) {
        UIGraphicsBeginImageContext(mVCtrl.view.frame.size);
        (UIImage(named: strFilename))?.drawInRect(mVCtrl.view.bounds)
        let mImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        mVCtrl.view.backgroundColor = UIColor(patternImage: mImage)
    }
    
    // ********** 以下為本專案使用 ********** //
    
    /**
    * JSON string 轉為 Array
    */
    func JSONStrToAry(strJSON: String)->Array<AnyObject> {
        var aryRS: Array<AnyObject> = []
        
        do {
            let mNSData: NSData = strJSON.dataUsingEncoding(NSUTF8StringEncoding)!
            let jobjRoot = try NSJSONSerialization.JSONObjectWithData(mNSData, options:NSJSONReadingOptions(rawValue: 0))
            
            guard let tmpAllData = jobjRoot as? Array<AnyObject> else {
                return aryRS
            }
            
            aryRS = tmpAllData
        }
        catch let err as NSError {
            print("err_data:\n\(err)")
            return aryRS
        }
        
        return aryRS
    }
    
    /**
     * JSON string 轉為 Dictionary
     */
    func JSONStrToDict(strJSON: String)->Dictionary<String, AnyObject> {
        var aryRS: Dictionary<String, AnyObject> = [:]
        
        do {
            let mNSData: NSData = strJSON.dataUsingEncoding(NSUTF8StringEncoding)!
            let jobjRoot = try NSJSONSerialization.JSONObjectWithData(mNSData, options:NSJSONReadingOptions(rawValue: 0))
            
            guard let tmpAllData = jobjRoot as? Dictionary<String, AnyObject> else {
                return aryRS
            }
            
            aryRS = tmpAllData
        } catch let err as NSError {
            print("err_data:\n\(err)")
        }
        
        return aryRS
    }
    
    
    /**
     * Dictionary | Array 轉為 JSON string
     */
    func DictAryToJSONStr(mData: AnyObject)->String {
        var strJSON = ""
        
        do {
            let jsonData = try
                NSJSONSerialization.dataWithJSONObject(mData, options: NSJSONWritingOptions(rawValue: 0))
            strJSON = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
        } catch let err as NSError {
            print("err_data:\n\(err)")
        }
        
        return strJSON
    }
    
    
}