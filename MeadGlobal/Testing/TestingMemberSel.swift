//
// TableView, SearchBar
//

import UIKit
import Foundation

/**
 * 進入檢測程序前，顯示會員列表並選擇會員
 */
class TestingMemberSel: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // segue 來源的 VC 辨識標記
    private var strParentIdentName = ""
    
    // 受測者資料 array data
    var dictUser: Dictionary<String, String> = [:]
    
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
        
        tableData.delegate = self
        tableData.dataSource  = self
        searchBar.delegate = self
        
        strToday = pubClass.getDevToday()
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        if let parentIdent = self.parentViewController?.restorationIdentifier {
            strParentIdentName = parentIdent
        }
        
        searchBar.text = ""
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
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryNewAllData.count
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
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
     * #Mark Delegate: UITableView, Cell 點取時
     * 判斷來源VC, 手動執行 Segue
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dictUser = aryNewAllData[indexPath.row]
        
        // 取得此 Item 正確的 indexparh
        for (var loopi = 0; loopi<aryAllData.count; loopi++) {
            if (aryAllData[loopi]["id"] == dictUser["id"]) {
                newIndexPath = NSIndexPath(forRow: loopi, inSection: 0)
                
                break
            }
        }
        
        /* segue to 檢測主頁面 */
        if (strParentIdentName == "TestingUserPager") {
            // 檢查會員資料
            let strAge = mMemberClass.getBirthToAge(dictUser["birth"])
            if (strAge == "") {
                pubClass.popIsee(Msg: pubClass.getLang("member_err_birth"))
                return
            }
            
            dictUser["age"] = strAge
            self.performSegueWithIdentifier("TestingMemberSel", sender: nil)
            
            return
        }
        
        /* segue to 檢測檢測資料列表 */
        if (strParentIdentName == "RecordMemberMain") {
            self.performSegueWithIdentifier("RecordMemberSel", sender: nil)
            
            return
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
        // user 清空
        dictUser = [:]
        
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
        let strIdnt = segue.identifier
        
        if (strIdnt == "TestingMemberSel") {
            let vcChild = segue.destinationViewController as! BLEMeadMain
            vcChild.dictUser = dictUser
            
            return
        }
        
        if (strIdnt == "RecordMemberSel") {
            let vcChild = segue.destinationViewController as! RecordList
            vcChild.dictUser = dictUser
            
            return
        }
        
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
