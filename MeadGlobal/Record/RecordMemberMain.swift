//
// Container, segure to 公用 'MemberList' VC
//

import UIKit
import Foundation

/**
 * 檢測資料首頁，顯示會員列表
 */
class RecordMemberMain: UIViewController {
    // @IBOutlet
    @IBOutlet weak var containerPager: UIView!
    
    // common property
    private var pubClass = PubClass()
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * Segue 跳轉頁面，本頁面直接跳轉 'TestingMemberList'
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "TestingMemberList") {
            let mVC = segue.destinationViewController as! TestingMemberList
            mVC.identTarget = "RecordList"
            
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