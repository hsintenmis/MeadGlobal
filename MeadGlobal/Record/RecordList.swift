//
// TableView
//

import UIKit
import Foundation

/**
 * 檢測資料列表
 */
class RecordList: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // public, 由上層設定的參數
    var dictUser: Dictionary<String, String> = [:]
    
    // 指定會員檢測資料 ary data
    private var aryMeadData: Array<Dictionary<String, String>> = []
    
    // 其他 class, property
    private var mRecordClass: RecordClass!
    private var strToday: String!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        tableData.delegate = self
        tableData.dataSource = self
        
        mRecordClass = RecordClass(ProjectPubClass: pubClass)
        
        //取得指定 user 的檢測資料，設定到 'aryMeadData'
        aryMeadData = mRecordClass.getDataWithMemberId(dictUser["id"])
    }

    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        //  沒有檢測資料跳離
        if (aryMeadData.count < 1) {
            pubClass.popIsee(Msg: pubClass.getLang("nodata"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            
            return
        }
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * 宣告這個 UITableView 畫面上的控制項總共有多少筆資料<BR>
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryMeadData.count
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryMeadData.count < 1) {
            return UITableViewCell()
        }
        
        let mCell: RecordListCell = tableView.dequeueReusableCellWithIdentifier("cellRecordList", forIndexPath: indexPath) as! RecordListCell
        let ditItem = aryMeadData[indexPath.row] as Dictionary<String, String>
        
        mCell.labDate.text = pubClass.formatDateWithStr(ditItem["sdate"], type: "8s")
        mCell.labAvg.text = ditItem["avg"]
        mCell.labAvgH.text = ditItem["avgH"]
        mCell.labAvgL.text = ditItem["avgL"]
        
        return mCell
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * UITableView, Cell 刪除，cell 向左滑動
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // 彈出 confirm 視窗, 點取 'OK' 執行實際刪除資料程序
            pubClass.popConfirm([pubClass.getLang("syswarring"), pubClass.getLang("delselconfrimmsg")], withHandlerYes:
                {
                    // 資料庫檔案刪除資料
                    let strId = self.aryMeadData[indexPath.row]["id"]!
                    let dictRS = self.mRecordClass.del(strId)
                    if (dictRS["rs"] as! Bool != true) {
                        // 顯示刪除失敗訊息
                        self.pubClass.popIsee(Msg: "err_delfailure")
                        
                        return
                    }
                    
                    // TableView data source 資料移除
                    self.aryMeadData.removeAtIndex(indexPath.row)
                    self.tableData.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                }, withHandlerNo: {})
        }
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        // 取得點取 cell
        if (strIdentName == "RecordList") {
            let indexPath = self.tableData.indexPathForSelectedRow!
            let dictItem = aryMeadData[indexPath.row]
            let cvChild = segue.destinationViewController as! RecordDetail
            cvChild.dictMeadData = dictItem
            
            return
        }
        
        return
    }
    
    /**
     * 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}