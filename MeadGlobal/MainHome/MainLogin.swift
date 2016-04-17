//
// App 進入頁面
//

import UIKit

/**
 * 本專案首頁，USER登入頁面
 */
class MainLogin: UIViewController {
    // @IBOutlet
    @IBOutlet weak var swchLang: UISegmentedControl!
    @IBOutlet weak var labTitle: UILabel!
    
    // common property
    private var pubClass = PubClass()
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 語系 switch 預設
        let langCode = pubClass.getPrefData("lang") as! String
        pubClass.setAppDelgVal("V_LANGCODE", withVal: langCode)
        
        for loopi in (0..<pubClass.aryLangCode.count) {
            if (langCode == pubClass.aryLangCode[loopi]) {
                swchLang.selectedSegmentIndex = loopi
                
                break
            }
        }
        
        // 設定頁面語系
        self.setPageLang()
        
        // 檢查裝置是否有指定檔案(會員/Mead 資料檔)
        self.DBCheck()
    }
    
    
    /**
     * 設定頁面顯示文字
     */
    private func setPageLang() {
        labTitle.text = pubClass.getLang("app_name")
    }
    
    /**
     * 檢查裝置是否有指定資料庫檔案 (會員/Mead記錄 資料檔)
     */
    private func DBCheck() {
        let mMemberClass = MemberClass()
        mMemberClass.chkData()
        
        let mRecordClass = RecordClass()
        mRecordClass.chkData()
    }
    
    /**
     * act 語系改變, prefer data 'langCode' 更新
     * swicth lang: Base, zh-Hans, zh-Hant, es
     */
    @IBAction func actLang(sender: UISegmentedControl) {
        let aryLang = pubClass.aryLangCode
        
        // 資料存入 'Prefer'
        let mPref = NSUserDefaults(suiteName: "standardUserDefaults")!
        let langCode = aryLang[sender.selectedSegmentIndex]
        mPref.setObject(langCode, forKey: "lang")
        mPref.synchronize()
        
        pubClass.setAppDelgVal("V_LANGCODE", withVal: langCode)
        self.setPageLang()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}