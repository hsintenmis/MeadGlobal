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
    @IBOutlet weak var btnGuest: UIButton!
    @IBOutlet var btnMember: UIView!

    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 顏色設定
    private let dictColor = ["white":"FFFFFF", "red":"FFCCCC", "gray":"C0C0C0", "silver":"F0F0F0"]
    
    // public, 目前user身份, 'guest' or 'member'
    var strMemberType = "guest"
    
    // 選擇'guest' or 'member' 的 pager class
    var mTestingUserPager: TestingUserPager!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 樣式/外觀/顏色
        btnGuest.layer.cornerRadius = 5
        btnGuest.layer.borderWidth = 1
        btnGuest.layer.borderColor = pubClass.ColorCGColor(dictColor["gray"])
        btnGuest.layer.backgroundColor = pubClass.ColorCGColor(dictColor["silver"])
        
        btnMember.layer.cornerRadius = 5
        btnMember.layer.borderWidth = 1
        btnMember.layer.borderColor = pubClass.ColorCGColor(dictColor["gray"])
        btnMember.layer.backgroundColor = pubClass.ColorCGColor(dictColor["white"])
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {

    }

    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        if (strIdentName == "TestingUserPager") {
            let cvChild = segue.destinationViewController as! TestingUserPager
            cvChild.mTestingUser = self
            mTestingUserPager = cvChild
            
            return
        }
        
        return
    }
    
    /**
    * 根據代入的 'position' 改變 '訪客' or '會員' btn 顏色style
    *
    * @param position: 0=訪客 1=會員
    */
    func changBtnColor(position: Int) {
        // 訪客
        if (position == 0) {
            btnGuest.layer.backgroundColor = pubClass.ColorCGColor(dictColor["silver"])
            btnMember.layer.backgroundColor = pubClass.ColorCGColor(dictColor["white"])
        }
        // 會員
        else {
            btnGuest.layer.backgroundColor = pubClass.ColorCGColor(dictColor["white"])
            btnMember.layer.backgroundColor = pubClass.ColorCGColor(dictColor["silver"])
        }
    }
    
    /**
     * Action, 點取'訪客'
     */
    @IBAction func actGuest(sender: UIButton) {
        self.changBtnColor(0)
        mTestingUserPager.moveToPage(0)
    }
    
    /**
     * Action, 點取'會員'
     */
    @IBAction func actMember(sender: UIButton) {
        self.changBtnColor(1)
        mTestingUserPager.moveToPage(1)
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