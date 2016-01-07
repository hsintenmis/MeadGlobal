//
//
//

import UIKit
import Foundation

/**
 * 會員列表 (會員主頁面)
 */
class MemberList: UIViewController {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!

    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 會員資料 Array data
    var aryAllData: Array<Dictionary<String, String>> = []
    
    // 檔案存取
    var mFileMang: FileMang!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        mFileMang = FileMang()
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        self.reloadTableData()
    }
    
    /**
    * 重新整理 TableView 資料
    */
    func reloadTableData() {
        let strJSON = mFileMang.read(pubClass.D_FILE_MEMBER)
        if (strJSON.isEmpty) {
            aryAllData = []
        } else {
           aryAllData = pubClass.JSONStrToAry(strJSON) as! Array<Dictionary<String, String>>
        }
        
        tableData.reloadData()
    }
    
    /**
     * #Delegate: 系統的 UITableView
     * 宣告這個 UITableView 畫面上的控制項總共有多少筆資料<BR>
     * 可根據 'section' 回傳指定的數量
     */
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return aryAllData.count
    }
    
    /**
     * #Delegate: 系統的 UITableView
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (aryAllData.count < 1) {
            return nil
        }
        
        let mCell: MemberListCell = tableView.dequeueReusableCellWithIdentifier("cellMemberList", forIndexPath: indexPath) as! MemberListCell
        let ditItem = aryAllData[indexPath.row] as Dictionary<String, AnyObject>
        
        mCell.labName.text = ditItem["name"] as? String
        mCell.labId.text = ditItem["id"] as? String
        mCell.labTel.text = ditItem["tel"] as? String
        mCell.labGender.text = ditItem["gender"] as? String
        
        let imgFileName = (ditItem["id"] as! String) + ".png"
        if (mFileMang.isFilePath(imgFileName)) {
            mCell.imgPict.image = UIImage(contentsOfFile: mFileMang.mDocPath + imgFileName)
        }
        
        return mCell
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