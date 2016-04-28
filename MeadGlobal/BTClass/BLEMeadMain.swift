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
    @IBOutlet weak var btnConn: UIButton!
    
    @IBOutlet weak var navybarTop: UINavigationBar!
    @IBOutlet weak var btnRecord: UIBarButtonItem!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnConnect: UIButton!
    
    // common property
    private var pubClass = PubClass()
    
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
    
    // 其他 class, property
    private var mBLEMeadService: BLEMeadService!
    private var mMeadCFG = MeadCFG() // MEAD 設定檔
    private var mMeadClass = MeadClass()  // MEAD 主 class
    private let mFileMang = FileMang()
    private var mRecordClass = RecordClass()
    
    private var strToday: String!
    private var strDate: String!  // 目前時間
    private var isDataSave = false  // 檢測資料是否已存檔
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setPageLang()
        
        // BTScaleService 實體化與相關參數設定
        mBLEMeadService = BLEMeadService()
        mBLEMeadService.delegate = self
        
        // Mead, 其他 相關資料初始
        labTxtExistVal.text = pubClass.getLang("mead_existtestingval")
        setUserView()
        strDate = pubClass.getDevToday()
        
        // 檢測數值 array data 初始與產生
        aryTestingData = mMeadCFG.getAryAllTestData()
        
        // view filed 設定
        btnConn.alpha = 0.0
        btnConn.enabled = false
        btnConn.layer.cornerRadius = 5.0
    }
    
    /**
     * viewDidAppear
     */
    override func viewDidAppear(animated: Bool) {
        viewCollect.reloadData()
        
        // 開始連接藍芽設備
        mBLEMeadService.BTConnStart()
    }
    
    /**
     * 設定頁面顯示文字
     */
    private func setPageLang() {
        pubClass.setNavybarTxt(navybarTop, aryTxtCode: ["menu_testing", "back", "retesting"])
        btnRecord.title = pubClass.getLang("testingreport")
        btnSave.title = pubClass.getLang("save")
        btnConnect.setTitle(pubClass.getLang("connect"), forState: UIControlState.Normal)
    }
    
    /**
     * 設定上方受測者 View
     */
    private func setUserView() {
        labName.text = dictUser["name"]
        let strGender = pubClass.getLang("gender_" + (dictUser["gender"])!)
        labGender.text = pubClass.getLang("gender") + ": " + strGender + ", " + pubClass.getLang("age") + ": \(dictUser["age"]! as String)"
        
        // user 圖片
        let mMemberClass = MemberClass()
        imgUser.image = mMemberClass.getMemberPict(dictUser["id"]!)
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
        let mCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellBLEMeadMain", forIndexPath: indexPath) as! BLEMeadMainCell
        
        let dictItem = aryTestingData[indexPath.row]
        let strItemName = pubClass.getLang("mead_body_" + (dictItem["body"]! + dictItem["direction"]!)) + " " + dictItem["serial"]!
        mCell.labName.text = strItemName
        
        // 樣式/外觀/顏色
        mCell.layer.cornerRadius = 2
        
        var strColor = myColor.Gray.rawValue
        
        if (indexPath == currIndexPath) {
            strColor = myColor.Blue.rawValue
        }
        else if (dictItem["val"] != "0") {
            strColor = myColor.Green.rawValue
        }
        
        mCell.backgroundColor = pubClass.ColorHEX(strColor)
        
        return mCell
    }
    
    /**
     * #mark, CollectionView, Cell 點取, 檢測項目的 scroll item
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if (mBLEMeadService.BT_ISREADYFOTESTING) {
            currIndexPath = indexPath
            
            // 重新改變狀態
            CURR_STATU = STATU_FINISH
            self.moveCollectCell(indexPath.row)
        }
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
        
        // 重新改變狀態
        CURR_STATU = STATU_FINISH;
    }
    
    /**
     * 解析檢測儀傳來的數值資料
     * <P>
     * 檢測狀態: <BR>
     * STATU_READY: 檢測值 <= 1, 探針未與任何量測點接觸<BR>
     * STATU_RECEIVE: 檢測值 >= 1, 量測點正在確認中<BR>
     * STATU_FINISH: 到達 maxCount, 完成數值讀取，
     *   移到下一個/檢測完成(Item position = 最後一個)<BR>
     *
     * @param intVal
     *            : 檢測值
     */
    private func analyBTData(intVal: Int) {
        if (CURR_STATU == STATU_STOP) {
            return
        }
        
        let strVal = String(intVal)
        
        // STATU_READY, 檢測值 <= 1, 探針未與任何量測點接觸
        if (intVal <= 1) {
            
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
            
            currValCount += 1
            
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
        if ( currDataPosition >= (mMeadCFG.D_TOTDATANUMS - 1) ) {
            CURR_STATU = STATU_STOP
            labBTMsg.text = pubClass.getLang("mead_point_finish")
            
            return
        }
        
        // 設定目前狀態為 'STATU_FINISH'
        CURR_STATU = STATU_FINISH;
        labBTMsg.text = pubClass.getLang("mead_point_movenext")
        
        // 目前檢測項目 position + 1, collectionView position 移動
        currDataPosition += 1
        moveCollectCell(currDataPosition)
        
        return
    }
    
    /**
     * #mark: BTMeadServiceDelegate
     * 檢測儀 Service class, handler
     */
    func handlerBLE(identCode: String!, result: Bool!, msg: String!, intVal: Int?) {
        switch (identCode) {
            
        // 一般狀態
        case "BT_statu":
            if (result != true) {
                pubClass.popIsee(self, Msg: pubClass.getLang("err_data"), withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
                return
            }
            
            // 搜尋不到藍芽設備=1, 手機藍牙未開=3
            if let code = intVal {
                if (code == 1 || code == 3) {
                    labBTMsg.text = msg
                    
                    btnConn.alpha = 1.0
                    btnConn.enabled = true
                    
                    return
                }
                
                // 不能使用藍芽設備，跳離
                if (code == 2) {
                    pubClass.popIsee(self, Msg: msg, withHandler: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    return
                }
            }
            
            labBTMsg.text = msg
            break
            
        // 連線狀態
        case "BT_conn":
            // 表示 BT 斷線
            if (result != true) {
                pubClass.popIsee(self, Msg: msg, withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
                return
            }
            
            // BT 設備連線成功
            labBTMsg.text = msg
            self.moveCollectCell(0)
            CURR_STATU = STATU_READY
            
            break
            
        // 資料傳輸標記
        case "BT_data":
            // 有回傳資料 Int val NOT nil
            if (result == true ) {
                if (intVal! < mMeadCFG.D_VALUE_MAX) {
                    
                    // 數值介於 1 ~ 最小值，回傳  1
                    if (intVal! <= mMeadCFG.D_VALUE_MIN) {
                        analyBTData(1)
                    } else {
                        analyBTData(intVal!)
                    }
                }
            }
            
            break
            
        default:
            break
        }
    }
    
    /**
     * 檢查檢測數值資料 array, '資料存檔'與'檢測報告'使用
     *
     * @param showPopMsg: 是否顯示彈出視窗
     * @return boolean
     */
    private func chkTestingData(showPopMsg isShow: Bool)->Bool {
        for i in (0..<24) {
            var dictItem = aryTestingData[i]
            if (dictItem["val"] == "0") {
                // 數值資料 "0" 為錯誤
                self.moveCollectCell(i)
                
                if (isShow) {
                    pubClass.popIsee(self, Msg: pubClass.getLang("mead_errval"))
                }
                
                return false
            }
        }
        
        return true
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 能量檢測詳細內容 class, 圖表顯示
        if (segue.identifier == "RecordDetail") {
            let mVC = segue.destinationViewController as! RecordDetail
            mVC.dictMeadData = sender as! Dictionary<String, String>
            
            return
        }
        
        return
    }
    
    /**
     * act 資料重設
     */
    @IBAction func actReset(sender: UIBarButtonItem) {
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("sysprompt"), pubClass.getLang("mead_resetmsg")], withHandlerYes: {
            
            // 需要重設的 property
            self.strDate = self.pubClass.getDevToday()  // 日期時間重新取得
            self.currValCount = 0  // 目前檢測數值計算加總的次數
            self.mapTestValCount = [:] // 檢測數值 => 出現次數, 目的取得最多次數的 val
            self.aryTestingData = self.mMeadCFG.getAryAllTestData()
            self.moveCollectCell(0)
            self.isDataSave = false
            
            }, withHandlerNo: {return})
    }
    
    /**
     * act, 顯示檢測報告
     */
    @IBAction func actReport(sender: UIBarButtonItem) {
        if (!self.chkTestingData(showPopMsg: true)) {
            return
        }
        
        // 跳轉檢測資料分析頁面
        self.performSegueWithIdentifier("RecordDetail", sender: self.getPreSaveData(aryTestingData))
        
        return
    }
    
    /**
     * act, 資料存檔
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        if (!self.chkTestingData(showPopMsg: true) || self.isDataSave == true) { return }
        
        if (dictUser["id"] == "") {
            pubClass.popIsee(self, Msg: pubClass.getLang("mead_guestcantsave"))
            return
        }
        
        // 取得整理好準備存檔的 '檢測資料'
        let saveRS = mRecordClass.add(self.getPreSaveData(aryTestingData))
        var strMsg = "mead_recordaddfailure"
        
        if (saveRS["rs"] as! Bool == true) {
            isDataSave = true
            strMsg = "mead_recordaddcomplete"
        }
        
        pubClass.popIsee(self, Msg: pubClass.getLang(strMsg))
        
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
        for i in (0..<mMeadCFG.D_TOTDATANUMS) {
            dictRS["val"] = dictRS["val"]! + aryData[i]["val"]!
            if (i < (mMeadCFG.D_TOTDATANUMS - 1)) { dictRS["val"]! += "," }
        }
        
        // 平均值, 高低標
        let dictAvg = mMeadClass.GetAvgValue(aryTestingData)
        dictRS["avg"] = "\(dictAvg["avg"]!)"
        dictRS["avgH"] = "\(dictAvg["avgH"]!)"
        dictRS["avgL"] = "\(dictAvg["avgL"]!)"
        
        // 有問題的檢測項目
        dictRS["problem"] = mMeadClass.GetProblemItem(aryTestingData)
        
        return dictRS
    }
    
    /**
     * act, 點取 '連線'
     */
    @IBAction func actConn(sender: UIButton) {
        self.mBLEMeadService.BTConnStart()
        btnConn.alpha = 0.0
        btnConn.enabled = false
    }
    
    /**
     * act 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        // 檢測完成尚未存檔, 顯示確認視窗
        if (self.chkTestingData(showPopMsg: false) && !isDataSave) {
            pubClass.popConfirm(self, aryMsg: [pubClass.getLang("sysprompt"), pubClass.getLang("mead_notsaveinfomsg")], withHandlerYes: {
                self.mBLEMeadService.BTDisconn()
                self.dismissViewControllerAnimated(true, completion: {})
                }, withHandlerNo: {})
            
            return
        }
        
        // 跳離
        if (self.mBLEMeadService.BT_ISREADYFOTESTING == true) {
            self.mBLEMeadService.BTDisconn()
        }
        else {
            self.dismissViewControllerAnimated(true, completion: {})
        }
        
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}