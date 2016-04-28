//
// TableView, SearchBar
//

import UIKit
import Foundation

/**
 * 會員列表 - 首頁導入
 */
class MemberList: UIViewController, PubClassDelegate {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navybarTop: UINavigationBar!
    @IBOutlet weak var labeDelMember: UILabel!

    // common property
    private var pubClass = PubClass()
    
    // TableView, SearchBar 相關
    private var currIndexPath: NSIndexPath? = nil
    private var searchActive : Bool = false
    private var aryAllData: Array<Dictionary<String, String>> = [] // 原始的 TableView data source
    private var aryNewAllData: Array<Dictionary<String, String>> = []
    
    // 其他 class, property
    private var strMode: String!
    private let mFileMang = FileMang()
    private var mMemberClass: MemberClass!
    private var strToday: String!
    private var bolReload = true
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        mMemberClass = MemberClass()
        strToday = pubClass.getDevToday()
        setPageLang()
    }
    
    
    /**
     * viewDidAppear
     */
    override func viewDidAppear(animated: Bool) {
        if (bolReload == true) {
            bolReload = false
            
            self.reloadTableData()
        }
    }
    
    /**
     * 設定頁面顯示文字
     */
    private func setPageLang() {
        pubClass.setNavybarTxt(navybarTop, aryTxtCode: ["header_memberlist", "homepage", "add"])
        labeDelMember.text = pubClass.getLang("slipleftdeldata")
    }
    
    /**
     * #mark: PubClassDelegate, page reload
     */
    func PageNeedReload(needReload: Bool) {
        bolReload = needReload
        
        if (strMode == "add") {
            currIndexPath = nil
        }
    }
    
    /**
    * 重新整理 TableView 資料
    */
    private func reloadTableData() {
        // 取得會員全部資料
        aryAllData = mMemberClass.getAll(isSortASC: false)
        aryNewAllData = aryAllData
        tableData.reloadData()
        
        // 移動到指定Item
        if (currIndexPath != nil) {
            tableData.selectRowAtIndexPath(currIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    /**
     * #mark: TableView VC delegate
     * 指定 section 的 row 數量
     */
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return aryNewAllData.count
    }
    
    /**
     * #mark: TableView VC delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (aryNewAllData.count < 1) {
            return nil
        }
        
        let mCell: MemberListCell = tableView.dequeueReusableCellWithIdentifier("cellMemberList", forIndexPath: indexPath) as! MemberListCell
        let ditItem = aryNewAllData[indexPath.row] as Dictionary<String, AnyObject>
        mCell.initView(ditItem, mMemberClass: mMemberClass)
        
        return mCell
    }
    
    /**
     * #mark: TableView VC delegate
     * table view Item 點取, 跳轉會員編輯頁面
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 取得此 Item 正確的 indexparh
        let dictUser = aryNewAllData[indexPath.row]
        for loopi in (0..<aryAllData.count) {
            if (aryAllData[loopi]["id"] == dictUser["id"]) {
                currIndexPath = NSIndexPath(forRow: loopi, inSection: 0)
                
                break
            }
        }
        
        // 設定跳轉頁面辨識標記為 'edit'
        self.performSegueWithIdentifier("MemberAdEd", sender: "edit")
    }
    
    /**
     * #mark: TableView VC delegate
     * UITableView, Cell 刪除，cell 向左滑動
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // 彈出 confirm 視窗, 點取 'OK' 執行實際刪除資料程序
            pubClass.popConfirm(self, aryMsg: [pubClass.getLang("syswarring"), pubClass.getLang("member_delconfirmmsg")], withHandlerYes: { self.delProc(indexPath) }, withHandlerNo: {return} )
        }
    }
    
    /**
     * 刪除資料程序
     */
    private func delProc(indexPath: NSIndexPath!) {
        // 資料庫檔案刪除資料
        let strId = self.aryNewAllData[indexPath.row]["id"]
        let dictRS = self.mMemberClass.del(strId)
        
        if (dictRS["rs"] as! Bool != true) {
            self.pubClass.popIsee(self, Msg: pubClass.getLang("err_member_delfailure"))
            
            return
        }
        
        // 刪除會員圖片
        self.mFileMang.delete(strId! + ".png")
        
        // TODO 刪除 mead 檢測資料
        
        // TableView data source 資料重整
        currIndexPath = nil
        //self.reloadTableData()
    }
    
    /** mark: SearchBar delegate Start */
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    /** mark: SearchBar delegate End */
    
    /**
     * mark: SearchBar delegate
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
            searchBar.resignFirstResponder()
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

    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        strMode = sender as! String
        
        let mVC = segue.destinationViewController as! MemberAdEd
        mVC.strMode = strMode
        mVC.delegate = self
        
        // 編輯頁面
        if (sender as! String == "edit") {
            mVC.dictMember = aryAllData[currIndexPath!.row]
        }
        
        return
    }
    
    /**
     * act, 點取 '新增'
     */
    @IBAction func actAdd(sender: UIBarButtonItem) {
        // 設定跳轉頁面辨識標記為 'add'
        self.performSegueWithIdentifier("MemberAdEd", sender: "add")
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