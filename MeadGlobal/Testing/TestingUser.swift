//
// Container 為 PageViewController
// 

import UIKit
import Foundation

/**
 * 受測者設定
 * 檢測進入首頁，先設定受測者資料
 */
class TestingUser: UIViewController, TestingUserPagerDelg {
    // @IBOutlet
    @IBOutlet weak var containerPager: UIView!
    @IBOutlet weak var btnGuest: UIButton!
    @IBOutlet var btnMember: UIView!

    // common property
    private var pubClass = PubClass()
    
    // 其他 property
    private var mTestingUserPager: TestingUserPager!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 樣式/外觀/顏色
        btnGuest.layer.cornerRadius = 5
        btnGuest.layer.borderWidth = 1
        btnGuest.layer.borderColor = pubClass.ColorCGColor(myColor.Gray.rawValue)
        btnMember.layer.cornerRadius = 5
        btnMember.layer.borderWidth = 1
        btnMember.layer.borderColor = pubClass.ColorCGColor(myColor.Gray.rawValue)
        self.changBtnColor(0)
    }
    
    /**
     * #mark: TestingUserPagerDelg
     * pager 滑動頁面 '完成', 回傳完成頁面的 position, 本頁面執行相關程序
     */
    func PageChangeDone(position: Int) {
        self.changBtnColor(position)
    }

    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        if (strIdentName == "TestingUserPager") {
            mTestingUserPager = segue.destinationViewController as! TestingUserPager
            mTestingUserPager.delegateCust = self
            
            return
        }
        
        return
    }
    
    /**
     * 根據代入的 'position' 改變 '訪客' or '會員' btn 顏色style
     * @param position: 0=訪客 1=會員
     */
    private func changBtnColor(position: Int) {
        // 訪客
        if (position == 0) {
            btnGuest.layer.backgroundColor = pubClass.ColorCGColor(myColor.Sliver.rawValue)
            btnMember.layer.backgroundColor = pubClass.ColorCGColor(myColor.White.rawValue)
        }
        // 會員
        else {
            btnGuest.layer.backgroundColor = pubClass.ColorCGColor(myColor.White.rawValue)
            btnMember.layer.backgroundColor = pubClass.ColorCGColor(myColor.Sliver.rawValue)
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