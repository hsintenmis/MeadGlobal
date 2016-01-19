//
// TableView list data
// 選取檔案並讀取 JSON string, 轉為 array data
//

import UIKit
import Foundation

/**
 * 能量檢測詳細內容 class, 學理報告文字顯示
 *
 * 代碼解釋 F201 :F3 => 經絡代號, 0=正常, 1=低, 2=高, 後兩碼數字表示 左右
 * TableList datasource dict 如下：(有兩個 Section, 0=前四個bad, 1=顯示商品建議)
 *   title: 'F3(腎經)'
 *   L_val: '99' or '', L_img: 'up' or 'down', 右邊 R 同樣方式設定
 *   msg : 說明文字
 */
class RecordDetailTxt: UIViewController {
    // 固定參數設定
    private let D_FILE_MEADDB = "mead_db"
    private let D_IMGUP = "engval_up.png"  // 圖片
    private let D_IMGDOWN = "engval_down.png"  // 圖片
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // TableView 需要的資料
    private var aryDataSource_0: Array<Dictionary<String, String>> = []  // sect 0
    private var aryDataSource_1: Array<Dictionary<String, String>> = []  // sect 1
    
    // public, 檢測數值相關資料, 由parent segue設定資料
    var dictMeadData: Dictionary<String, String> = [:]  // parent 設定
    
    // mead 96 種結果的 DB data
    private var dictMeadDB: Dictionary<String, AnyObject> = [:]
    
    // 其他 class, property
    private var mMeadCFG: MeadCFG! // MEAD 設定檔
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        mMeadCFG = MeadCFG(ProjectPubClass: pubClass)
        
        // 檢查是否需要顯示本頁面, 判別欄位 'problem_id'
        if (dictMeadData["problem"]?.characters.count < 1) {
            pubClass.popIsee(Msg: pubClass.getLang("testingvalokmsg"))
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        // 取得 mead_db 檔案的 JSON string, 解析為 array or dict
        dictMeadDB = pubClass.getAppDelgVal("V_DICTMEADDB") as! Dictionary<String, AnyObject>
        
        if (dictMeadDB.count < 1) {
            pubClass.popIsee(Msg: pubClass.getLang("err_data"))
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        /* 初始與設定 TableView 需要的 datasource */
        // TableCell autoheight
        self.tableList.estimatedRowHeight = 100.0
        self.tableList.rowHeight = UITableViewAutomaticDimension
        self.initTableDataSource()
        self.tableList.reloadData()
    }
    
    // View DidAppear
    override func viewDidAppear(animated: Bool) {
        
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * 初始與設定 TableView 需要的 datasource
     * 代碼解釋 F201 :F3 => 經絡代號, 0=正常, 1=低, 2=高, 後兩碼數字表示 左右
     * TableList datasource dict 如下：(有兩個 Section, 0=前四個bad, 1=顯示商品建議)
     *   title: 'F3(腎經)'
     *   val_L: '99' or '', img_L: 'up' or 'down', 右邊 R 同樣方式設定
     *   msg : 說明文字
     */
    private func initTableDataSource() {
        // 其他參數設定
        let strGender = dictMeadData["gender"]!
        let strAvg = dictMeadData["avg"]!
        var loopi = 0;
        
        // 重整數值資料對應的 key, ex. 'H1R' = '35', 'F3L' = '102'
        let aryKey = mMeadCFG.D_ARY_MEADDBID.componentsSeparatedByString(",")
        let aryVal = dictMeadData["val"]!.componentsSeparatedByString(",")
        
        var dictKeyVal: Dictionary<String, String> = [:]
        for (loopi = 0; loopi < aryKey.count; loopi++ ) {
            dictKeyVal[aryKey[loopi]] = aryVal[loopi]
        }
        
        // 取得有問題的 iNo 代碼 array, 重新整理取得前四筆資料
        var aryOrgData = dictMeadData["problem"]!.componentsSeparatedByString(",")
        
        for (loopi=0; loopi<aryOrgData.count; loopi++) {
            if (loopi == mMeadCFG.D_REPORT_ANALY_MAXNUMS) {
                break
            }
            
            // 設定 dictItem data
            var dictItem: Dictionary<String, String> = [:]
            dictItem["val_L"] = ""
            dictItem["val_R"] = ""
            dictItem["img_L"] = ""
            dictItem["img_R"] = ""
            dictItem["avg"] = strAvg
            
            // 取得左右數值，圖片(up/down)名稱
            let strKey = pubClass.subStr(aryOrgData[loopi], strFrom: 0, strEnd: 2)
            let strVal_L = pubClass.subStr(aryOrgData[loopi], strFrom: 2, strEnd: 3)
            let strVal_R = pubClass.subStr(aryOrgData[loopi], strFrom: 3, strEnd: 4)
            
            if (strVal_L != "0") {
                dictItem["val_L"] = dictKeyVal[strKey + "L"]
                dictItem["img_L"] = (strVal_L == "1") ? D_IMGDOWN : D_IMGUP
            }
            
            if (strVal_R != "0") {
                dictItem["val_R"] = dictKeyVal[strKey + "R"]
                dictItem["img_R"] = (strVal_R == "1") ? D_IMGDOWN : D_IMGUP
            }
            
            // 根據 Mead DB array data, 取得相關對應資料
            let dictMeadData = dictMeadDB[aryOrgData[loopi]] as! Dictionary<String, AnyObject>
            //dictItem["title"] = dictMeadData["PrnHead"]! as? String
            dictItem["title"] = pubClass.getLang("MERIDIAN_" + strKey)
            
            // 設定學理資料, 根據 'strGender' 有不同說明
            let strEast = dictMeadData["East" + strGender] as? String
            let strWest = dictMeadData["West" + strGender] as? String
            dictItem["msg"] = "[" + pubClass.getLang("meadreport_east") + "]\n" + strEast! + "\n\n" + "[" + pubClass.getLang("meadreport_west") + "]\n" + strWest!
            
            // TableView Sec0 資料加入
            aryDataSource_0.append(dictItem)
            
            // TableView Sec1 資料加入
            if (loopi == 0) {
                // 設定商品使用資料
                dictItem["msg"] = dictMeadData["WorkA"] as? String
                aryDataSource_1.append(dictItem)
            }
        }
    }
    
    /**
     * UITableView, 'section' 回傳指定的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView!)->Int {
        return 2
    }
    
    /**
     * UITableView<BR>
     * 宣告這個 UITableView 畫面上的控制項總共有多少筆資料<BR>
     * 可根據 'section' 回傳指定的數量
     */
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return (section == 0) ? aryDataSource_0.count : 1
    }
    
    /**
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let dictItem: Dictionary<String, String> = (indexPath.section == 0) ? aryDataSource_0[indexPath.row] : aryDataSource_1[indexPath.row]
        if (dictItem.count < 1) {
            return nil
        }
        
        let mCell: RecordDetailCell = tableView.dequeueReusableCellWithIdentifier("cellRecordDetailCell", forIndexPath: indexPath) as! RecordDetailCell
        
        mCell.labTitle.text = dictItem["title"]
        mCell.labMsg.text = dictItem["msg"]
        mCell.labL_avg.text = dictItem["avg"]
        mCell.labR_avg.text = dictItem["avg"]
        mCell.labL_val.text = dictItem["val_L"]
        mCell.labR_val.text = dictItem["val_R"]
        
        // 判斷使否要顯示 左右數值
        if (dictItem["val_L"] == "") {
            mCell.view_L.alpha = 0.0
        } else {
            mCell.view_L.alpha = 1.0
            mCell.img_L.image = UIImage(named: dictItem["img_L"]!)
        }
        
        if (dictItem["val_R"] == "") {
            mCell.view_R.alpha = 0.0
        } else {
            mCell.view_R.alpha = 1.0
            mCell.img_R.image = UIImage(named: dictItem["img_R"]!)
        }
        
        return mCell
    }
    
    /**
     * UITableView, Header 內容
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? pubClass.getLang("meadreport_analy") : pubClass.getLang("meadreport_pdsuggest")
    }
    
    /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
