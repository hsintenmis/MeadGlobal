//
// Container
//

import UIKit
import Foundation

/**
 * 系統設定, 由首頁導入
 */
class SysConfig: UIViewController {
    // @IBOutlet
    @IBOutlet weak var navybarTop: UINavigationBar!
    
    // common property
    private var pubClass = PubClass()
    
    /**
     * View load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pubClass.setNavybarTxt(navybarTop, aryTxtCode: ["menu_config", "homepage"])
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