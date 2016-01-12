//
// Container 為 PageViewController
// 

import UIKit
import Foundation

/**
 * 檢測進入首頁，先設定受測者資料
 */
class TestingUser: UIViewController {
    // @IBOutlet
    @IBOutlet weak var containerPager: UIView!

    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // public, 目前user身份, 'guest' or 'member'
    var strMemberType = "guest"  //
    
    let mTestingUserPager = TestingUserPager()
    
    
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
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        return
    }
    
    /**
     * Action, 點取'訪客'
     */
    @IBAction func actGuest(sender: UIButton) {
        mTestingUserPager.moveToPage(0)
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