//
// TableView, SearchBar
//

import UIKit
import Foundation

/**
 * 會員列表 (檢測頁面選擇會員)
 */
class TestingMemberSel: UIViewController, UISearchBarDelegate {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 原始的 TableView data
    private var aryAllData: Array<Dictionary<String, String>> = []
    
    // puclic, 上層 VC, 點取 Table Item 的 indexPath 相關
    var mParentClass: TestingUser!
    var newIndexPath: NSIndexPath?
    
    // SearchBar 相關
    private var searchActive : Bool = false
    private var aryNewAllData: Array<Dictionary<String, String>> = []
    
    // 其他 class
    private let mFileMang = FileMang()
    private let mMemberClass = MemberClass()
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        searchBar.delegate = self
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
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
        mCell.labId.text = ditItem["id"] as? String
        mCell.labTel.text = ditItem["tel"] as? String
        mCell.labGender.text = ditItem["gender"] as? String
        
        // 圖片設定
        let imgFileName = (ditItem["id"] as! String) + ".png"
        if (mFileMang.isFilePath(imgFileName)) {
            mCell.imgPict.image = UIImage(contentsOfFile: self.mFileMang.mDocPath + imgFileName)
        }
        else {
            mCell.imgPict.image = UIImage(named: pubClass.D_DEFPICTUSER )
        }
        
        return mCell
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * UITableView, Cell click
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mParentClass.dictUser = aryNewAllData[indexPath.row]
        mParentClass.strMemberType = "member"
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
     * 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}