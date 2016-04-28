//
// 本 class 使用 webview, 取得 HTML string code
// 帶入 'webView.loadHTMLString'
//

import UIKit
import Foundation

/**
 * 能量檢測詳細內容 class, 圖表顯示
 */
class RecordDetail: UIViewController {
    // !!TODO!! WebHTML, 圖表固定參數
    let D_HTML_FILENAME = "mead01"
    let D_HTML_URL = "html/mead"
    let D_BASE_FILENAME = "index"
    let D_BASE_URL = "html"
    
    // @IBOutlet
    @IBOutlet weak var webChart: UIWebView!
    @IBOutlet weak var viewLoading: UIActivityIndicatorView!
    @IBOutlet weak var labLoading: UILabel!
    @IBOutlet weak var navybarTop: UINavigationBar!

    // common property
    private var pubClass = PubClass()
    
    // 檢測結果的 val 與  key array, 高低標與平均值
    private var aryKey: Array<String> = []
    private var aryVal: Array<String> = []
    private var strAvg = "0", strAvgH = "0", strAvgL = "0";
    
    // 其他 class, property
    private var mMeadCFG = MeadCFG() // MEAD 設定檔
    
    /**
     * public, 檢測數值相關資料, 由parent segue設定資料
     *   格式如下：<BR>
     *  'sdate': 14碼, 作為唯一識別 key<BR>
     *  'memberid': ex. MD000001<BR>
     *  'membername': 會員姓名<BR>
     *  'age': ex. "35"<BR>
     *  'gender': ex. "M"<BR>
     *  'avg', 'avgH', 'avgL'<BR>
     *  'val': ex. "27,12,33,56,34,67,..."<BR>
     *  'problem': 超出高低標的檢測項目, ex. "F220,H101,H420,..." or ""<BR>
     */
    var dictMeadData: Dictionary<String, String>!
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pubClass.setNavybarTxt(navybarTop, aryTxtCode: ["meaddataanaly", "back", "theoretical_analysis"])
        labLoading.text = pubClass.getLang("dataloading")
        
        // 產生'項目'與'數值'的 array data, 設定其他檢測數值參數
        aryKey = mMeadCFG.D_ARY_MEADDBID.componentsSeparatedByString(",")
        aryVal = dictMeadData["val"]!.componentsSeparatedByString(",")
        strAvg = dictMeadData["avg"]!
        strAvgH = dictMeadData["avgH"]!
        strAvgL = dictMeadData["avgL"]!
    }
    
    /**
     * viewDidAppear
     */
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        self.setViewChartHTML()
    }
    
    /**
     * 產生圖表需要的文字
     */
    private func setChartTxt(strHTML: String!) -> String! {
        var newStrHTML = strHTML
        
        // 左右側
        newStrHTML = newStrHTML.stringByReplacingOccurrencesOfString("D_SIDE_L", withString: pubClass.getLang("direct_L"))
        newStrHTML = newStrHTML.stringByReplacingOccurrencesOfString("D_SIDE_R", withString: pubClass.getLang("direct_R"))
        
        // 經絡名稱
        let aryBody = ["H", "F"]
        
        for strBody in aryBody {
            for loopi in (1..<7) {
                let strDefnKey = "D_" + strBody + String(loopi)
                newStrHTML = newStrHTML.stringByReplacingOccurrencesOfString(strDefnKey, withString: pubClass.getLang("MERIDIAN_" + strBody + String(loopi)))
            }
        }
        
        
        return newStrHTML
    }
    
    /**
     * View ChartHTML 方式顯示<P>
     * 設定 Chart view, 設定到 'viewChart', '橫向', 數值資料要重新排列順序
     */
    private func setViewChartHTML() {
        var mapVal: Dictionary<String, String> = [:]
        
        // 取得數組 'aryVal' 最大值作為圖表 Y 軸最大值
        var currMax = 0, newMax = 0;
        
        for loopi in (0..<mMeadCFG.D_TOTDATANUMS) {
            newMax = Int(aryVal[loopi])!
            if (newMax > currMax) {
                currMax = newMax;
            }
        }

        mapVal["D_YAXIS_MAX"] = String(currMax)
        
        // 檢測的全部數值，前12個為 'H', 後12個為 'F', 解析為 '左右'
        var strD_L_VAL = "", strD_R_VAL = ""

        for loopi in (12..<18).reverse() {
            strD_L_VAL += aryVal[loopi] + ","
        }
        
        for loopi in (0..<6).reverse() {
            strD_L_VAL += aryVal[loopi];
            
            if (loopi > 0) {
                strD_L_VAL += ","
            }
        }
        mapVal["D_L_VAL"] = strD_L_VAL
        
        for loopi in (18..<24).reverse() {
            strD_R_VAL += aryVal[loopi] + ","
        }
        
        for loopi in (6..<12).reverse() {
            strD_R_VAL += aryVal[loopi];
            
            if (loopi > 6) {
                strD_R_VAL += ","
            }
        }
        mapVal["D_R_VAL"] = strD_R_VAL
        
        // 設定平均值, 高低標數值
        mapVal["D_AVG"] = strAvg
        mapVal["D_HI"] = strAvgH
        mapVal["D_LOW"] = strAvgL
        
        // 設定圖表尺寸
        mapVal["D_CHART_HEIGHT"] = "500px"
        mapVal["D_CHART_WIDTH"] = "420px"
        
        // 圖表相關, 標題/次標題, 帶入會員資料
        let strGender = pubClass.getLang("gender_" + dictMeadData["gender"]!)
        let strAge = dictMeadData["age"]! + pubClass.getLang("age_name")
        let strDate = pubClass.getLang("mead_testingdate") + ":" + pubClass.formatDateWithStr(dictMeadData["sdate"], type: 8)
        let strChartSubTitle = strGender + ", " + strAge + ", " + strDate
        
        mapVal["D_CHART_TITLE"] = dictMeadData["membername"]!
        mapVal["D_CHART_SUBTITLE"] = strChartSubTitle
        
        // 取得原始 HTML String code
        do {
            let htmlFile = NSBundle.mainBundle().pathForResource(D_HTML_FILENAME, ofType: "html", inDirectory: D_HTML_URL)!
            var strHTML = try NSString(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding)
            
            // 開始執行字串取代
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_HEIGHT", withString: mapVal["D_CHART_HEIGHT"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_WIDTH", withString: mapVal["D_CHART_WIDTH"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_AVG", withString: mapVal["D_AVG"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_HI", withString: mapVal["D_HI"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_LOW", withString: mapVal["D_LOW"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_L_VAL", withString: mapVal["D_L_VAL"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_R_VAL", withString: mapVal["D_R_VAL"]!)
            
            // 取得圖表 Y 軸 MAX, 取得數組最大值
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_YAXIS_MAX", withString: mapVal["D_YAXIS_MAX"]!)
            
            // 設定圖表標題
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_TITLE", withString: mapVal["D_CHART_TITLE"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_SUBTITLE", withString: mapVal["D_CHART_SUBTITLE"]!)
            
            strHTML = setChartTxt(strHTML as String)
            
            // 以 HTML code 產生新的 WebView
            let baseFile = NSBundle.mainBundle().pathForResource(D_BASE_FILENAME, ofType: "html", inDirectory: D_BASE_URL)!
            let baseUrl = NSURL(fileURLWithPath: baseFile)
            self.webChart.loadHTMLString(strHTML as String, baseURL: baseUrl)
            
        } catch {
            // 資料錯誤
            //print("err")
            return
        }
    }
    
    /** WebView delegate Start */
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        //print("Webview fail with error \(error)");
        labLoading.alpha = 0.0
        viewLoading.stopAnimating()
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType)->Bool {
        return true;
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        labLoading.alpha = 1.0
        viewLoading.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        labLoading.alpha = 0.0
        viewLoading.stopAnimating()
    }
    /** WebView delegate End */
     
     /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        // segue 為點取 button '學理分析'
        if (strIdentName == "RecordDetail") {
            let mVC = segue.destinationViewController as! RecordDetailTxt
            mVC.dictMeadData = dictMeadData
            
            return
        }
        
        return
    }
    
    /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}