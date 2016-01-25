//
// TableView, SearchBar
//

import UIKit
import Foundation

/**
 * 會員列表 (會員主頁面)
 */
class MemberList: UIViewController, UISearchBarDelegate {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // public, 若 child 頁面為新增資料是否儲存完成
    var hasNewDataAdd = false
    
    // 原始的 TableView data
    private var aryAllData: Array<Dictionary<String, String>> = []
    
    // 點取 Table Item 的 indexPath 相關
    private var newIndexPath: NSIndexPath? = nil
    
    // SearchBar 相關
    private var searchActive : Bool = false
    private var aryNewAllData: Array<Dictionary<String, String>> = []
    
    // 其他 class, property
    private let mFileMang = FileMang()
    private var mMemberClass: MemberClass!
    private var strToday: String!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        mMemberClass = MemberClass(ProjectPubClass: pubClass)
        
        searchBar.delegate = self
        strToday = pubClass.getDevToday()
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        // 若 child 頁面為新增資料且儲存完成，position = 0
        if (hasNewDataAdd) {
            newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            hasNewDataAdd = false
        }
        
        self.reloadTableData()
    }
    
    /**
    * 重新整理 TableView 資料
    */
    func reloadTableData() {
        // 取得會員全部資料
        aryAllData = mMemberClass.getAll(isSortASC: false)
        aryNewAllData = aryAllData
        tableData.reloadData()
        
        // 移動到指定Item
        tableData.selectRowAtIndexPath(newIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * 宣告這個 UITableView 畫面上的控制項總共有多少筆資料<BR>
     * 可根據 'section' 回傳指定的數量
     */
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return aryNewAllData.count
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (aryNewAllData.count < 1) {
            return nil
        }
        
        let mCell: MemberListCell = tableView.dequeueReusableCellWithIdentifier("cellMemberList", forIndexPath: indexPath) as! MemberListCell
        let ditItem = aryNewAllData[indexPath.row] as Dictionary<String, AnyObject>
        
        mCell.labName.text = ditItem["name"] as? String
        mCell.labId.text = pubClass.getLang("member_id") + ": " + (ditItem["id"] as! String)
        mCell.labTel.text = pubClass.getLang("tel") + ": " + (ditItem["tel"] as! String)
        
        // 性別
        let strGender = pubClass.getLang("gender_" + (ditItem["gender"] as! String))
        
        // 年齡
        var strAge = mMemberClass.getBirthToAge(ditItem["birth"] as? String)
        if (strAge == "") {
            strAge = "--"
        }

        // 顯示性別年齡
        mCell.labGender.text = pubClass.getLang("gender") + ": " + strGender + ", " + pubClass.getLang("age") + ": " + strAge
        
        // 圖片設定
        mCell.imgPict.image = mMemberClass.getMemberPict(ditItem["id"] as! String)
        
        return mCell
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * UITableView, Cell 刪除，cell 向左滑動
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // 彈出 confirm 視窗, 點取 'OK' 執行實際刪除資料程序
            pubClass.popConfirm([pubClass.getLang("syswarring"), pubClass.getLang("member_delconfirmmsg")], withHandlerYes:
                {
                    // 資料庫檔案刪除資料
                    let strId = self.aryNewAllData[indexPath.row]["id"]!
                    let dictRS = self.mMemberClass.del(strId)
                    if (dictRS["rs"] as! Bool != true) {
                        // 顯示刪除失敗訊息
                        self.pubClass.popIsee(Msg: "err_member_delfailure")
                        
                        return
                    }
                    
                    // TableView data source 資料移除
                    self.aryNewAllData.removeAtIndex(indexPath.row)
                    self.aryAllData = self.mMemberClass.getAll(isSortASC: false)
                    self.tableData.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                    // 刪除會員圖片
                    self.mFileMang.delete(strId + ".png")
                    
                    // TODO 刪除 mead 檢測資料
                    
                }, withHandlerNo: {})
        }
    }
    
    //********** #Delegate: 系統的 UISearchBar, Start **********//
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    /**
    * 搜尋字元改變時
    */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (aryAllData.count < 1) {
            searchActive = false;
            return
        }
        
        // 沒有輸入字元
        if (searchText.isEmpty) {
            searchActive = false;
            aryNewAllData = aryAllData
            self.tableData.reloadData()
            
            return
        }
        
        // 比對字元
        aryNewAllData = aryAllData.filter({ (dictItem) -> Bool in
            var tmp: NSString = dictItem["name"]!
            let range0 = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            
            tmp = dictItem["tel"]!
            let range1 = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            
            if (range0.location == NSNotFound && range1.location == NSNotFound) {
                return false
            }
            
            return true
            
            //return range.location != NSNotFound
        })
        
        if(aryNewAllData.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableData.reloadData()
    }
    
    //********** #Delegate: 系統的 UISearchBar, End **********//

    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        searchBar.text = ""
        
        // 編輯會員資料 segue
        if (strIdentName == "MemverEdit") {
            // 取得點取 cell 的 index
            let indexPath = self.tableData.indexPathForSelectedRow!
            let ditItem = aryNewAllData[indexPath.row]
            let cvChild = segue.destinationViewController as! MemberAdEd
            cvChild.dictMember = ditItem
            cvChild.strMode = "edit"
            cvChild.mParentClass = self
            
            // 取得此 Item 正確的 indexparh
            for (var loopi = 0; loopi<aryAllData.count; loopi++) {
                if (aryAllData[loopi]["id"] == ditItem["id"]) {
                    newIndexPath = NSIndexPath(forRow: loopi, inSection: 0)
                    
                    break
                }
            }
            
            return
        }
        
        // 預設 segue 為會員新增
        if (strIdentName == "MemverAdd") {
            let cvChild = segue.destinationViewController as! MemberAdEd
            cvChild.strMode = "add"
            cvChild.mParentClass = self
            
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