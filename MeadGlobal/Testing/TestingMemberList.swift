//
// TableView, SearchBar
//

import UIKit
import Foundation

/**
 * 受測者身份 - 會員列表
 */
class TestingMemberList: UIViewController {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // common property
    private var pubClass = PubClass()
    
    // pubcli, parent 設定
    var dictUser: Dictionary<String, String> = [:] // 受測者資料
    var identTarget: String! // 來源的 VC 辨識標記, 跳轉其他頁面使用, 'TestingUserPager' or '?'
    
    // tableView, SearchBar 參數
    private var aryAllData: Array<Dictionary<String, String>> = []  // 原始 data
    private var currIndexPath: NSIndexPath? = nil
    private var searchActive : Bool = false
    private var aryNewAllData: Array<Dictionary<String, String>> = []
    
    // 其他
    private let mFileMang = FileMang()
    private var mMemberClass: MemberClass!
    private var strToday: String!
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mMemberClass = MemberClass()
        strToday = pubClass.getDevToday()
    }
    
    /**
     * viewDidAppear
     */
    override func viewDidAppear(animated: Bool) {
        searchBar.text = ""

        // 取得會員全部資料
        aryAllData = mMemberClass.getAll(isSortASC: false)
        aryNewAllData = aryAllData
        tableData.reloadData()
        
        // TableView 移動到指定Item
        if (currIndexPath != nil) {
            tableData.selectRowAtIndexPath(currIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
        
        // search bar 初始
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    /**
     * #mark: TableView VC delegate
     * 指定 section 的 row 數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryNewAllData.count
    }
    
    /**
     * #mark: TableView VC delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryNewAllData.count < 1) {
            return UITableViewCell()
        }
        
        let mCell: MemberListCell = tableView.dequeueReusableCellWithIdentifier("cellTestingMemberList", forIndexPath: indexPath) as! MemberListCell
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
     * #mark: TableView VC delegate
     * table view Item 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dictUser = aryNewAllData[indexPath.row]
        
        // 取得此 Item 正確的 indexparh
        for loopi in (0..<aryAllData.count) {
            if (aryAllData[loopi]["id"] == dictUser["id"]) {
                currIndexPath = NSIndexPath(forRow: loopi, inSection: 0)
                
                break
            }
        }
        
        // 跳轉檢測主頁面
        if (identTarget == "TestingUserPager") {
            // 檢查會員資料
            let strAge = mMemberClass.getBirthToAge(dictUser["birth"])
            if (strAge == "") {
                pubClass.popIsee(self, Msg: pubClass.getLang("member_err_birth"))
                
                return
            }
            
            dictUser["age"] = strAge
            self.performSegueWithIdentifier("BLEMeadMain", sender: nil)
            
            return
        }
        
        // 跳轉檢測數值資料列表
        if (identTarget == "RecordMemberMain") {
            self.performSegueWithIdentifier("RecordList", sender: nil)
            
            return
        }
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
        // user 清空
        dictUser = [:]
        
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
        let strIdnt = segue.identifier
        
        if (strIdnt == "BLEMeadMain") {
            let mVC = segue.destinationViewController as! BLEMeadMain
            mVC.dictUser = dictUser
            
            return
        }
        
        if (strIdnt == "RecordList") {
            let mVC = segue.destinationViewController as! RecordList
            mVC.dictUser = dictUser
            
            return
        }
        
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}