//
// Container 使用, 檔案寫入(String / UIImage)
//

import UIKit
import Foundation

/**
 * 會員新增/編輯, 文字/圖片 資料儲存
 */
class MemberAdEd: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var PageTitle: UINavigationItem!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 由 parent 'prepareForSegue' 設定, 有資料表示本頁面編輯模式
    var dictMember: Dictionary<String, String> = [:]
    var strMode = "add"  // 本頁面模式, 'add' or 'edit'
    var mParentClass: MemberList!
    var hasNewDataAdd = false
    
    // 其他 class
    private var mMemberAdEdContainer: MemberAdEdContainer!
    private let mFileMang = FileMang()
    private var mMemberClass: MemberClass!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        mMemberClass = MemberClass(ProjectPubClass: pubClass)
        
        // 設定頁面語系
        self.setPageLang()
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
    }
    
    /**
     * 設定頁面語系
     */
    private func setPageLang() {
        PageTitle.title = (strMode == "add") ?
            pubClass.getLang("member_add") : pubClass.getLang("member_edit")
        btnBack.title = pubClass.getLang("back")
        btnSave.title = pubClass.getLang("save")
    }
    
    /**
     * Segue 判別跳轉哪個頁面, 給 container 的 childView 使用
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 跳轉 'MemberEdit' class
        if segue.identifier == "MemberAdEdContainer"{
            mMemberAdEdContainer = segue.destinationViewController as! MemberAdEdContainer
            
            mMemberAdEdContainer.mMemberAdEd = self
            mMemberAdEdContainer.dictMember = dictMember
            mMemberAdEdContainer.strMode = strMode
            
            return
        }
        
        return
    }

    /**
     * action 資料儲存
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        // 調用 'mMemberAdEdContainer' 的 startSaveData
        if (!(mMemberAdEdContainer.startSaveData())) {
            return
        }
        
        // 是否新增資料完成，設定 parent 'hasNewDataAdd'
        if (strMode == "add") {
            mParentClass.hasNewDataAdd = true
        }
        
        // popWindow, 點取後 class close
        pubClass.popIsee(Msg: pubClass.getLang("datasavecomplete"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
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