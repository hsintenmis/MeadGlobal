//
// TableView Statuc, ContainerView 的延伸 view
//

import Foundation
import UIKit

/**
 * 會員資料編輯與儲存
 */
class SysConfigList: UITableViewController {
    @IBOutlet var tableList: UITableView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {

    }
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // get cell identify name
        //let strIdent = tableList.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
    }
    */
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        print(strIdentName)
    }
    
    /**
     * 設定頁面內容
     */
    private func initViewField() {
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}