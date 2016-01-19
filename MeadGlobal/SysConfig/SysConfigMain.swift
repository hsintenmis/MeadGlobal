//
// Container
//

import UIKit
import Foundation

/**
 * '設定'主頁面
 */
class SysConfig: UIViewController {
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