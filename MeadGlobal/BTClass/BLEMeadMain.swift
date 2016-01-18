//
// CollectionView,
//

import UIKit
import Foundation

/**
 * 檢測儀檢測 主頁面
 * 1.藍芽設備連接    2.會員選擇(USER資料輸入)
 * 3.測量完後檢測報告 4. 儲存
 */
class BLEMeadMain: UIViewController, BLEMeadServiceDelegate {
    private let IS_DEBUG = false
    
    // @IBOutlet
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labGender: UILabel!
    @IBOutlet weak var imgBody: UIImageView!
    @IBOutlet weak var viewCollect: UICollectionView!
    
    @IBOutlet weak var labBTMsg: UILabel!
    @IBOutlet weak var labPointMsg: UILabel!
    @IBOutlet weak var labPointMsg1: UILabel!
    @IBOutlet weak var labTestVal: UILabel!
    
    @IBOutlet weak var labTxtExistVal: UILabel!
    @IBOutlet weak var labExistVal: UILabel!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 本頁面檢測的狀態參數設定
    private let STATU_READY = 3001;   // 等待接收資料中, 檢測值=1
    private let STATU_RECEIVE = 3002; // 資料接收中, 檢測值>1
    private let STATU_FINISH = 3003;  // 單一檢測項目完成, 已達到 maxCount
    private let STATU_STOP = 3004;    // 檢測結束(判別 positionTestItem 已到最後一筆資料)
    private var CURR_STATU = 3004     // 目前檢測的狀態
    
    // 數值取樣設定
    private let D_MAXCOUNT = 200 // 接收到的檢測數值, 計算加總的最大次數
    private var currValCount = 0  // 目前檢測數值計算加總的次數
    private var mapTestValCount: Dictionary<String, Int> = [:] // 檢測數值 => 出現次數, 目的取得最多次數的 val
    
    /* public property, 由 parent segue 設定 */
    // 受測者資料，存檔至檢測數值DB, key: id, name, age, gender
    var dictUser: Dictionary<String, String> = [:]
    
    /** var 檢測數值 array data, 從 MeadConfig 初始取得
     * 資料設定如下<br>
     * id :辨識 id, ex. H1, H2 ...<br>
     * body : 身體部位, ex. 'H' or 'F'<BR>
     * direction : 左右, ex. L or R ...<br>
     * val : 檢測值, 預設 0, String 型態<br>
     * serial : 身體與方向對應序號, 1 ~ 6<br>
    */
    var aryTestingData: Array<Dictionary<String, String>> = []
    
    // 目前檢測資料的 position, 與 CollectionView 的 position 一樣
    var currDataPosition = 0;
    var currIndexPath = NSIndexPath(forRow: 0, inSection:0)
    var D_TOTNUMS_TESTINGITEM = 24  // 共有 24 個檢測項目, 參考 'aryTestingData'
    
    // 顏色
    private let dictColor = ["white":"FFFFFF", "red":"FFCCCC", "gray":"C0C0C0", "silver":"F0F0F0", "blue":"66CCFF", "black":"000000", "green":"99CC33"]
    
    // 其他 class, property
    private var mBLEMeadService: BLEMeadService!
    private var mMeadCFG: MeadCFG! // MEAD 設定檔
    private var mMeadClass: MeadClass!  // MEAD 主 class
    private let mFileMang = FileMang()
    private var mRecordClass: RecordClass!
    private var strToday: String!
    
    private var strDate: String!  // 目前時間
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        mBLEMeadService = BLEMeadService()
        mBLEMeadService.mBLEMeadServiceDelegate = self
        mMeadCFG = MeadCFG(ProjectPubClass: pubClass)
        mMeadClass = MeadClass(ProjectPubClass: pubClass)
        mRecordClass = RecordClass(ProjectPubClass: pubClass)
        
        // Mead, 其他 相關資料初始
        labTxtExistVal.text = pubClass.getLang("mead_existtestingval")
        setUserView()
        strDate = pubClass.getDevToday()
        
        // 檢測數值 array data 初始與產生
        aryTestingData = mMeadCFG.getAryAllTestData()
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        viewCollect.reloadData()
        
        // 開始連接藍芽設備
        mBLEMeadService.startUpCentralManager()
    }
    
    /**
    * 設定上方受測者 View
    */
    private func setUserView() {
        labName.text = dictUser["name"]
        let strGender = pubClass.getLang("gender_" + (dictUser["gender"])!)
        labGender.text = pubClass.getLang("gender") + ": " + strGender + ", " + pubClass.getLang("age") + ": \(dictUser["age"]! as String)"
        
        // user 圖片
        let imgFileName = dictUser["id"]! + ".png"
        let mImg = (mFileMang.isFilePath(imgFileName)) ? UIImage(contentsOfFile: self.mFileMang.mDocPath + imgFileName) : UIImage(named: pubClass.D_DEFPICTUSER )
        imgUser.image = mImg
    }
    
    /**
     * #mark: CollectionView, 檢測項目, 設定列數 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     * #mark: CollectionView, 檢測項目, 設定每列 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
    }
    
    /**
     * #mark, CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let mCell: CellCollect = collectionView.dequeueReusableCellWithReuseIdentifier("cellCollect", forIndexPath: indexPath) as! CellCollect
        
        let dictItem = aryTestingData[indexPath.row]
        let strItemName = pubClass.getLang("mead_body_" + (dictItem["body"]! + dictItem["direction"]!)) + " " + dictItem["serial"]!
        mCell.labName.text = strItemName
        
        // 樣式/外觀/顏色
        mCell.layer.cornerRadius = 2
        
        var strColor = "gray"
        
        if (indexPath == currIndexPath) {
            strColor = "blue"
        }
        else if (dictItem["val"] != "0") {
            strColor = "green"
        }
        
        mCell.backgroundColor = pubClass.ColorHEX(dictColor[strColor])
        
        return mCell
    }
    
    /**
     * #mark, CollectionView, Cell 點取, 檢測項目的 scroll item
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // 重新改變狀態
        CURR_STATU = STATU_FINISH
        self.moveCollectCell(indexPath.row)
    }
    
    /**
    * CollectionView 移動到指定的 position cell
    * 本頁面 IBOutlet 跟著變動
    */
    private func moveCollectCell(mRow: Int) {
        let dictItem = aryTestingData[mRow]
        currDataPosition = mRow
        currIndexPath = NSIndexPath(forRow: mRow, inSection:0)
        
        // 設定穴位圖片, 圖片路徑 'pict_testing', 圖片名稱 ex. F1_R_P.jpg
        let strPict = dictItem["id"]! + "_" + dictItem["direction"]! + "_P.jpg"
        imgBody.image = UIImage(named: "pict_testing/" + strPict)
        
        // CollectionView 更新
        viewCollect.scrollToItemAtIndexPath(currIndexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        viewCollect.reloadData()
        
        // 其他 IBOutlet 更新
        labPointMsg.text = pubClass.getLang("MERIDIAN_" + dictItem["id"]!)
        labPointMsg1.text = pubClass.getLang("ORAGN_" + dictItem["id"]!)
        labExistVal.text = dictItem["val"]
    }
    
    /**
    * 解析檢測儀傳來的數值資料
    * <P>
    * 檢測狀態: <BR>
    * STATU_READY: 檢測值 = 1, 探針未與任何量測點接觸<BR>
    * STATU_RECEIVE: 檢測值 > 1, 量測點正在確認中<BR>
    * STATU_FINISH: 到達 maxCount, 完成數值讀取，移到下一個/檢測完成(Item position = 最後一個)<BR>
    *
    * @param intVal
    *            : 檢測值
    */
    private func analyBTData(intVal: Int) {
        if (CURR_STATU == STATU_STOP) {
            return
        }
        
        let strVal = String(intVal)
    
        // STATU_READY, 檢測值 = 1, 探針未與任何量測點接觸
        if (intVal == 1) {
            
            // 設定目前檢測狀態，顯示提示訊息
            if ( CURR_STATU != STATU_READY ) {
				CURR_STATU = STATU_READY
                mapTestValCount = [:] // 重設 val 對應次數 dict data
                labBTMsg.text = pubClass.getLang("mead_point_ready")
				labTestVal.text = "0"
            }
            
            // 數值計算 maxCount = 0
            currValCount = 0
            
            return
        }

        // STATU_RECEIVE, 檢測值 > 1, 預設狀態為：量測點正在確認中
        
        // 目前狀態 = STATU_FINISH, 無動作
        if (CURR_STATU == STATU_FINISH) {
            return
        }
        
        // 設定目前檢測狀態，顯示提示訊息
        if (CURR_STATU != STATU_RECEIVE) {
            CURR_STATU = STATU_RECEIVE
            labBTMsg.text = pubClass.getLang("mead_point_recive")
        }
        
        // 螢幕顯示檢測數值
        self.labTestVal.text = String(strVal)
        
        // 數值資料加入 '取樣設定' dict array
        if ( currValCount <= D_MAXCOUNT ) {
            if let count: Int = mapTestValCount[strVal] {
                mapTestValCount[strVal] = count + 1
            } else {
                mapTestValCount[strVal] = 1
            }
            
            currValCount++
            
            return
        }
            
        // 取樣程序, 已經達到最大的計算次數，該檢測項目檢測完成
        currValCount = 0
        
        // 取得出現次數最多的值，將數值資料設定到 'aryTestingData'
        var strMaxCountVal = "0" // 次數最多的檢測值
        var currCount = 0  // 暫存比較用的 count
        
        // key/value loop 資料, 找出現次數最多的數值 'strMaxCountVal'
        for (tmpVal, tmpCount) in mapTestValCount {
            if (tmpCount > currCount) {
                strMaxCountVal = tmpVal
                currCount = tmpCount
            }
        }
        
        // 將出現次數最多的數值 加入 'aryTestingData'
        aryTestingData[currDataPosition]["val"] = strMaxCountVal
        labExistVal.text = strMaxCountVal
        
        // 是否已到最後一筆 檢測項目, 所有項目檢測完成，執行相關程序
        if ( currDataPosition >= (D_TOTNUMS_TESTINGITEM - 1) ) {
            CURR_STATU = STATU_STOP
            labBTMsg.text = pubClass.getLang("mead_point_finish")
            
            return
        }
        
        // 設定目前狀態為 'STATU_FINISH'
        CURR_STATU = STATU_FINISH;
        labBTMsg.text = pubClass.getLang("mead_point_movenext")
        
        // 目前檢測項目 position + 1, collectionView position 移動
        currDataPosition++
        moveCollectCell(currDataPosition)
        
        return
    }
    
    /**
     * #mark: 自訂 Delegate, BLEMeadServiceDelegate
     *
     * 接收藍芽設備 handler
     * Flag: 'BT_statu', 'BT_conn', 'BT_data'
     * BLEMeadService protocol, 實作 method
     */
    func handlerBLEMeadService(mBLEMeadService: BLEMeadService, identCode: String!, result: Bool!, msgCode: String!) {
        
        switch (identCode) {
          
        // 一般狀態
        case "BT_statu":
            labBTMsg.text = pubClass.getLang(msgCode)
            break
            
        // 連線狀態
        case "BT_conn":
            // 藍芽接續成功，準備接收資料
            if (result == true) {
                CURR_STATU = STATU_READY
                self.labBTMsg.text = self.pubClass.getLang(msgCode)
                
                break
            }
            
            // 藍芽斷線
            CURR_STATU = STATU_STOP
            self.labBTMsg.text = self.pubClass.getLang(msgCode)
            
            break
            
        // 資料傳輸標記
        case "BT_data":
            // 數值資料開始分析
            var val = Int(msgCode)!
            
            if (val <= 1) {
                val = 1
            }
            else {
                // 檢查最大值/最小值
                val = (val > mMeadCFG.D_VALUE_MAX) ? (mMeadCFG.D_VALUE_MAX - 1) : val
                val = (val <= mMeadCFG.D_VALUE_MIN) ? (mMeadCFG.D_VALUE_MIN) : val
            }
 
            self.analyBTData(val)
            
            break
    
        default:
            break
        }
        
        if (IS_DEBUG) { print(identCode + ":" + msgCode) }
    }
    
    /**
    * 檢查檢測數值資料 array, '資料存檔'與'檢測報告'使用
    * @return boolean
    */
    private func chkTestingData()->Bool {
        for (var i=0; i<24; i++) {
            var dictItem = aryTestingData[i]
            if (dictItem["val"] == "0") {
                // 數值資料 "0" 為錯誤
                self.moveCollectCell(i)
                pubClass.popIsee(Msg: pubClass.getLang("mead_errval"))
                
                return false
            }
        }
        
        return true
    }
    
    /**
     * act 資料重設
     */
    @IBAction func actReset(sender: UIBarButtonItem) {
        let mAlert = UIAlertController(title: pubClass.getLang("sysprompt"), message: pubClass.getLang("mead_resetmsg"), preferredStyle:UIAlertControllerStyle.Alert)
        
        // btn 'Yes', 執行重設資料程序
        mAlert.addAction(UIAlertAction(title:pubClass.getLang("confirm_yes"), style:UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) in
            
            self.strDate = self.pubClass.getDevToday()  // 日期時間重新取得
            self.currValCount = 0  // 目前檢測數值計算加總的次數
            self.mapTestValCount = [:] // 檢測數值 => 出現次數, 目的取得最多次數的 val
            self.aryTestingData = self.mMeadCFG.getAryAllTestData()
            self.moveCollectCell(0)
        }))
        
        // btn ' No', 取消，關閉 popWindow
        mAlert.addAction(UIAlertAction(title:pubClass.getLang("confirm_no"), style:UIAlertActionStyle.Cancel, handler:nil ))
        
        // 顯示本彈出視窗
        dispatch_async(dispatch_get_main_queue(), {
            self.mVCtrl.presentViewController(mAlert, animated: true, completion: nil)
        })
    }
    
    /**
    * act, 顯示檢測報告
    */
    @IBAction func actReport(sender: UIBarButtonItem) {
        if (!self.chkTestingData()) {
            return
        }
    }
    
    /**
     * act, 資料存檔
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        if (!self.chkTestingData()) { return }
        
        // 取得整理好準備存檔的 檢測資料
        let dictRs = mRecordClass.add(self.getPreSaveData(aryTestingData))
        let strMsg = (dictRs["rs"] as! Bool == true) ? "mead_recordaddcomplete" : "mead_recordaddfailure"
        
        pubClass.popIsee(Msg: pubClass.getLang(strMsg))
        return
    }
    
    /**
     * 將已檢測完的數值資料，整理成為 存檔用的 Dict data
     *   格式如下：
     *  'sdate': 14碼, 作為唯一識別 key
     *  'memberid': ex. MD000001
     *  'membername': 會員姓名
     *  'age': ex. "35"
     *  'gender': ex. "M"
     *  'avg', 'avgH', 'avgL'
     *  'val': ex. "27,12,33,56,34,67,..."
     *  'problem': 超出高低標的檢測項目, ex. "F220,H101,H420,..." or ""
     */
    private func getPreSaveData(aryData: Array<Dictionary<String, String>>)->Dictionary<String, String>! {
        var dictRS: Dictionary<String, String> = [:]
        
        dictRS["sdate"] = strDate
        dictRS["memberid"] = dictUser["id"]
        dictRS["membername"] = dictUser["name"]
        dictRS["age"] = dictUser["age"]
        dictRS["gender"] = dictUser["gender"]
        
        // 已檢測的數值
        dictRS["val"] = ""
        for (var i=0; i < mMeadCFG.D_TOTDATANUMS; i++) {
            dictRS["val"] = dictRS["val"]! + aryData[i]["val"]!
            
            if (i < (mMeadCFG.D_TOTDATANUMS - 1)) { dictRS["val"]! += "," }
        }
        
        // 平均值, 高低標
        let dictAvg = mMeadClass.GetAvgValue(aryTestingData)
        dictRS["avg"] = String(dictAvg["avg"])
        dictRS["avgH"] = String(dictAvg["avgH"])
        dictRS["avgL"] = String(dictAvg["avgL"])
        
        // 有問題的檢測項目
        dictRS["problem"] = mMeadClass.GetProblemItem(aryTestingData)

        return dictRS
    }
    
    /**
     * act 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        mBLEMeadService.BTDisconn()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}