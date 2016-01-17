//
// Container, segure to 公用 'MemberList' VC
//

import UIKit
import Foundation

/**
 * 檢測資料首頁，先顯示會員列表
 */
class RecordMemberMain: UIViewController {
    // @IBOutlet
    @IBOutlet weak var containerPager: UIView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        
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