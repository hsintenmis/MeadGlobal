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
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 檢查裝置是否有指定檔案(會員/Mead 資料檔)
        self.DBCheck()
        
        // 語系 switch 預設
        let langCode = pubClass.getPrefData("lang") as! String
        pubClass.setAppDelgVal("V_LANGCODE", withVal: langCode)
        
        for (var loopi = 0; loopi < pubClass.aryLangCode.count; loopi++) {
            if (langCode == pubClass.aryLangCode[loopi]) {
                swchLang.selectedSegmentIndex = loopi
                
                break
            }
        }
        
        // 設定頁面語系
        self.setPageLang()
    }

    /**
    * 設定頁面語系
    */
    private func setPageLang() {
        labTitle.text = pubClass.getLang("app_name")
    }
    
    /**
     * 檢查裝置是否有指定檔案(會員/Mead 資料檔)
     */
    private func DBCheck() {
        let mFileMang = FileMang()
        
        if (mFileMang.isFilePath(pubClass.D_FILE_MEMBER)) {
            return
        }
        
        mFileMang.write(pubClass.D_FILE_MEMBER, strData: "")
    }
    
    /**
    * act 語系改變
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