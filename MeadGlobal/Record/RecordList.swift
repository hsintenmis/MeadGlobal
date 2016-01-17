//
// TableView
//

import UIKit
import Foundation

/**
 * 檢測資料列表
 */
class RecordList: UIViewController {
    // @IBOutlet
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // public, 由上層設定的參數
    var dictUser: Dictionary<String, String> = [:]
    
    // 指定會員檢測資料 ary data
    private var aryMeadData: Array<Dictionary<String, AnyObject>> = []
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        print(dictUser)
        
        //取得指定 user 的檢測資料，設定到 'aryMeadData'
        self.getMeadData()
    }
    
    /**
    *  讀取 Mead 資料檔，取得指定 user 的檢測資料，設定到 'aryMeadData'
    */
    private func getMeadData() {
        // 讀取檔案, 轉為 JSON 資料格式
        
        //
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * 宣告這個 UITableView 畫面上的控制項總共有多少筆資料<BR>
     */
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return aryMeadData.count
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (aryMeadData.count < 1) {
            return nil
        }
        
        let cell: RecordListCell = tableView.dequeueReusableCellWithIdentifier("cellRecordList", forIndexPath: indexPath) as! RecordListCell
        let ditItem = aryMeadData[indexPath.row] as! Dictionary<String, String>
        
        cell.labDate.text = pubClass.formatDateWithStr(ditItem["sdate"], type: 8)
        cell.labAvg.text = ditItem["avg"]
        cell.labAvgH.text = ditItem["avgH"]
        cell.labAvgL.text = ditItem["avgL"]
        
        return cell
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