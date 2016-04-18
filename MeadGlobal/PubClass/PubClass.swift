//
// 網路存取設定
// info.plist 設定 NSAppTransportSecurity => dict: NSAllowsArbitraryLoads = YES
//

import Foundation
import UIKit

/**
 * protocol, PubClass Delegate
 */
@objc protocol PubClassDelegate {
    /**
     * PubClassDelegate, 設定上層 class page 是否需要 reload
     */
    optional func PageNeedReload(needReload: Bool)
    
    /**
     * PubClassDelegate, 設定上層 class page 是否需要 reload
     * arg0, 辨識參數
     */
    optional func PageNeedReload(needReload: Bool, arg0: String?)
}

/**
 * 自訂色彩型別
 */
enum myColor: String {
    /** #FFFFFF */
    case White = "FFFFFF"
    case Red = "FFCCCC"
    case Gray = "C0C0C0"
    case Sliver = "F0F0F0"
    case Blue = "66CCFF"
    case Black = "000000"
    case Green = "99CC33"
}

/**
* 本專案所有的設定檔與公用 method
*/
class PubClass {
    /** 語系代碼<BR>"Base", "zh-Hans", "zh-Hant", "es" */
    var aryLangCode = ["Base", "zh-Hans", "zh-Hant", "es"]  // 語系相關
    
    /**
    * init
    */
    init() {
    }
    
    /**
     * 取得 'AppDelegate'
     */
    func getAppDelg()->AppDelegate! {
        return UIApplication.sharedApplication().delegate! as! AppDelegate
    }
    
    /**
     * 設定 AppDelegate 全域變數的 value
     */
    func setAppDelgVal(strKey: String, withVal mVal: AnyObject) {
        let AppDelg = self.getAppDelg()
        AppDelg.setValue(mVal, forKey: strKey)
    }
    
    /**
     * 設定 AppDelegate 全域變數的 value
     */
    func getAppDelgVal(strKey: String)->AnyObject {
        let AppDelg = self.getAppDelg()
        return AppDelg.valueForKey(strKey)!
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
        let AppDelg = self.getAppDelg()
        let strLang = AppDelg.V_LANGCODE + ".lproj/Localizable"
        
        return NSLocalizedString(strCode, tableName: strLang, bundle:NSBundle.mainBundle(), value: "", comment: "")
    }
    
    /**
     * SubString
     */
    func subStr(mStr: String!, strFrom: Int, strEnd: Int)->String {
        let nsStr = mStr as NSString
        return nsStr.substringWithRange(NSRange(location: strFrom, length: (strEnd - strFrom))) as String
    }
    
    /**
     * [我知道了] 彈出視窗
     */
    func popIsee(mVC: UIViewController, Title strTitle: String? = nil, Msg strMsg: String!) {
        var title = getLang("sysprompt")
        
        if strTitle != nil {
            title = strTitle!
        }
        
        let mAlert = UIAlertController(title: title, message: strMsg, preferredStyle:UIAlertControllerStyle.Alert)
        
        mAlert.addAction(UIAlertAction(title:getLang("i_see"), style: UIAlertActionStyle.Default, handler:nil))
        
        dispatch_async(dispatch_get_main_queue(), {
            mVC.presentViewController(mAlert, animated: true, completion: nil)
        })
    }
    
    /**
     * [我知道了] 彈出視窗, with 'handler'
     */
    func popIsee(mVC: UIViewController, Title strTitle: String? = nil, Msg strMsg: String!, withHandler mHandler:()->Void) {
        
        var title = getLang("sysprompt")
        
        if strTitle != nil {
            title = strTitle!
        }
        
        let mAlert = UIAlertController(title: title, message: strMsg, preferredStyle:UIAlertControllerStyle.Alert)
        
        mAlert.addAction(UIAlertAction(title:getLang("i_see"), style: UIAlertActionStyle.Default, handler:
            {(action: UIAlertAction!) in mHandler()}
            ))
        
        dispatch_async(dispatch_get_main_queue(), {
            mVC.presentViewController(mAlert, animated: true, completion: nil)
        })
    }
    
    /**
     * 確認[是/否] 彈出視窗, with 'handler'
     *
     * @param aryMsg: ex. ary[0]=title, ary[1]=msg
     * @param withHandlerYes, withHandlerNo: 點取 Y,N 執行程序
     */
    func popConfirm(mVC: UIViewController, aryMsg: Array<String>!, withHandlerYes mHandlerYes:()->Void, withHandlerNo mHandlerNo:()->Void) {
        let strTitle = (aryMsg[0] == "") ? getLang("sysprompt") : aryMsg[0]
        let mAlert = UIAlertController(title: strTitle, message: aryMsg[1], preferredStyle:UIAlertControllerStyle.Alert)
        
        // btn 'Yes', 執行 執行程序
        mAlert.addAction(UIAlertAction(title:self.getLang("confirm_yes"), style:UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) in
            mHandlerYes()
        }))
        
        // btn ' No', 取消，關閉 popWindow
        mAlert.addAction(UIAlertAction(title:self.getLang("confirm_no"), style:UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) in
            mHandlerNo()
        }))
        
        dispatch_async(dispatch_get_main_queue(), {
            mVC.presentViewController(mAlert, animated: true, completion: nil)
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
     * HTTP 連線, 開啟 'PopLoading' AlertView
     * 帶入自訂的 URL
     */
    func HTTPConnWithURL(mVC: UIViewController, withURL strURL: String!, ConnParm dictParm: Dictionary<String, String>, callBack: (Dictionary<String, AnyObject>)->Void) {
        
        let vcPopLoading = self.getPopLoading(nil)
        mVC.presentViewController(vcPopLoading, animated: true, completion:{
            self.taskHTTPConn(dictParm, mURL: strURL, AlertVC: vcPopLoading, callBack: callBack, VC: mVC)
        })
    }
    
    /**
     * HTTP 連線, 使用 post 方式, 產生 'task' 使用閉包
     */
    private func taskHTTPConn(dictParm: Dictionary<String, String>!, mURL: String!, AlertVC vcPopLoading: UIAlertController, callBack: (Dictionary<String, AnyObject>)->Void, VC mVC: UIViewController) {
        // 將 dict 參數轉為 string
        var strConnParm: String = "";
        var loopi = 0
        
        for (strKey, strVal) in dictParm {
            strConnParm += "\(strKey)=\(strVal)"
            loopi += 1
            
            if loopi != dictParm.count {
                strConnParm += "&"
            }
        }
        // 產生 http Request
        let mRequest = NSMutableURLRequest(URL: NSURL(string: mURL)!)
        mRequest.HTTPBody = strConnParm.dataUsingEncoding(NSUTF8StringEncoding)
        mRequest.HTTPMethod = "POST"
        mRequest.timeoutInterval = 30
        mRequest.HTTPShouldHandleCookies = false
        
        // 產生 'task' 使用閉包
        let task = NSURLSession.sharedSession().dataTaskWithRequest(mRequest) {
            (data, response, error) -> Void in
            var dictRS = Dictionary<String, AnyObject>();
            
            if error != nil {
                dictRS = self.getHTTPJSONData(nil)
            } else {
                dictRS = self.getHTTPJSONData(data!)
            }
            
            // 關閉 'vcPopLoading'
            dispatch_async(dispatch_get_main_queue(), {
                vcPopLoading.dismissViewControllerAnimated(true, completion: {
                    callBack(dictRS)
                })
            })
        }
        
        task.resume()
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
                dictRS["msg"] = "err_data"
                return dictRS
            }
            
            if ( dictRespon["result"] as! Bool != true) {
                dictRS["msg"] = "err_data"
                
                // 檢查 content ['msg'] 是否有訊息
                if let errTmp = dictRespon["content"]?["msg"] as? String {
                    if (errTmp.characters.count > 0) {
                        dictRS["msg"] = errTmp
                    }
                }
                
                return dictRS
            }
            
            // 解析正確的 jobj data
            dictRS["result"] = true
            dictRS["msg"] = nil
            dictRS["data"] = dictRespon
            
            return dictRS
        }
        catch _ as NSError {
            dictRS["msg"] = "err_data"
            //print(err)
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
        
        let nsStrDate = strDate as NSString
        var strYY: String, strMM: String, strDD: String
        
        strYY = nsStrDate.substringWithRange(NSRange(location: 0, length: 4))
        strMM = nsStrDate.substringWithRange(NSRange(location: 4, length: 2))
        strDD = nsStrDate.substringWithRange(NSRange(location: 6, length: 2))
        
        if (type == 8) {
            return "\(strYY)年\(Int(strMM)!)月\(Int(strDD)!)日"
        }
        
        if (type > 8) {
            var strHH: String, strMin: String
            
            strHH = nsStrDate.substringWithRange(NSRange(location: 8, length: 2))
            strMin = nsStrDate.substringWithRange(NSRange(location: 10, length: 2))
            
            return "\(strYY)年\(strMM)月\(strDD)日 \(strHH):\(strMin)"
        }
        
        return strDate
    }
    
    /**
     * 字串格式化可閱讀的日期文字, 簡短顯示 ex. '20150131235959' = 2015/01/31 23:59<BR>
     * @param type: 8s or 14s (String)
     */
    func formatDateWithStr(strDate: String!, type: String?)->String {
        if (strDate.characters.count < 8) {
            return strDate
        }
        
        let nsStrDate = strDate as NSString
        var strYY: String, strMM: String, strDD: String
        
        strYY = nsStrDate.substringWithRange(NSRange(location: 0, length: 4))
        strMM = nsStrDate.substringWithRange(NSRange(location: 4, length: 2))
        strDD = nsStrDate.substringWithRange(NSRange(location: 6, length: 2))
        
        if (type == "8s") {
            return "\(strYY)/\(strMM)/\(strDD)"
        }
        
        if (type == "14s") {
            var strHH: String, strMin: String
            
            strHH = nsStrDate.substringWithRange(NSRange(location: 8, length: 2))
            strMin = nsStrDate.substringWithRange(NSRange(location: 10, length: 2))
            
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
    func resizeImageWithWidth(sourceImage: UIImage!, imgWidth: CGFloat)->UIImage! {
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
    
    // ********** 以下為本專案使用 ********** //
    
    /**
     * 取得對應語系 Mead DB JSON data, 檔案來源為本機存檔
     * 檔名對應如: meaddb_Base, meaddb_zh-Hans ...
     */
    func getMeadDB()->Dictionary<String, AnyObject>! {
        let mJSONClass = JSONClass()
        let mFile = "meaddb_" + (self.getPrefData("lang") as! String)
        
        do {
            let fileRoot = NSBundle.mainBundle().pathForResource(mFile, ofType: "txt")
            let strJSON = try String(contentsOfFile: fileRoot!, encoding: NSUTF8StringEncoding)
            return mJSONClass.JSONStrToDict(strJSON) as Dictionary<String, AnyObject>
        } catch {
            return [:]
        }
    }
    
    /**
     * DISABLE
     * 取得對應語系 Mead DB JSON data, 直接設定到 appdelege
     * 檔名對應如: meaddb_Base, meaddb_zh-Hans ...
     */
    func setMeadDB() {
        let mJSONClass = JSONClass()
        let mFile = "meaddb_" + (self.getPrefData("lang") as! String)

        do {
            let fileRoot = NSBundle.mainBundle().pathForResource(mFile, ofType: "txt")
            let strJSON = try String(contentsOfFile: fileRoot!, encoding: NSUTF8StringEncoding)
            let dictData = mJSONClass.JSONStrToDict(strJSON) as Dictionary<String, AnyObject>
            
            setAppDelgVal("V_DICTMEADDB", withVal: dictData)
        } catch {
        }
        
        return
    }
    
}