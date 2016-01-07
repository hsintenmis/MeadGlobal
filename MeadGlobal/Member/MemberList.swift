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

    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 檔案存取
    var mFileMang: FileMang!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        mFileMang = FileMang()
        
        print(mFileMang.read(pubClass.D_FILE_MEMBER))
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