//
// Container 使用, 檔案寫入(String / UIImage)
//

import UIKit
import Foundation

/**
 * 會員新增/編輯, 文字/圖片 資料儲存
 */
class MemberAdEd: UIViewController {
    // delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var PageTitle: UINavigationItem!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    // common property
    private var pubClass = PubClass()
    
    // public, parent 設定
    var dictMember: Dictionary<String, String> = [:]
    var strMode: String!  // 本頁面模式, 'add' or 'edit'
    
    // 其他
    private var mMemberAdEdContainer: MemberAdEdContainer!
    private let mFileMang = FileMang()
    private var mMemberClass: MemberClass!
    private var isDataSave = false // 本頁面是否有資料儲存
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mMemberClass = MemberClass()
        
        // 設定頁面語系
        self.setPageLang()
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
        // 跳轉 Container 會員編輯輸入頁面
        if segue.identifier == "MemberAdEdContainer"{
            mMemberAdEdContainer = segue.destinationViewController as! MemberAdEdContainer
            mMemberAdEdContainer.dictMember = dictMember
            mMemberAdEdContainer.strMode = strMode
            
            return
        }
        
        return
    }

    /**
     * act, 點取 '儲存'
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        let dictRS = mMemberAdEdContainer.getPageData()
        if (dictRS == nil) {
            return
        }
        
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("sysprompt"), pubClass.getLang("savedataconfrimmsg")], withHandlerYes: {self.saveProc(dictRS)}, withHandlerNo: {return})
        
        // popWindow, 點取後 class close
        //pubClass.popIsee(Msg: pubClass.getLang("datasavecomplete"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
    }
    
    /**
     * 資料儲存程序
     * @param mImage: 是否有圖片 UIImage
     */
    private func saveProc(dictRS: Dictionary<String, AnyObject>!) {
        var strMemberID = ""
        var dictData = dictRS["data"] as! Dictionary<String, String>
        
        // 新增儲存
        if (self.strMode == "add") {
            let dictRS = mMemberClass.add(dictData )
            if (dictRS["rs"] as! Bool != true) {
                pubClass.popIsee(self, Msg: pubClass.getLang("err_member_newadd"))
                
                return
            }
            
            strMemberID = dictRS["id"] as! String
        }
        
        // 編輯儲存
        else if (self.strMode == "edit") {
            dictData["id"] = dictMember["id"]
            let dictRS = mMemberClass.update(dictData)
            
            if (dictRS["rs"] as! Bool != true) {
                pubClass.popIsee(self, Msg: dictRS["err"] as! String)
                
                return
            }
            
            strMemberID = dictRS["id"] as! String
        }
        
        // 圖片儲存
        if let imgTmp = dictRS["img"] as? UIImage {
            if (strMemberID != "") {
                mFileMang.write(mMemberClass.D_PATH_MEMBER_PICT + "/" + strMemberID + ".png", withUIImage: imgTmp)
            }
        }

        // 彈出確認視窗
        isDataSave = true
        pubClass.popIsee(self, Msg: pubClass.getLang("datasavecomplete"), withHandler: {
            if (self.strMode == "add") {
                self.delegate?.PageNeedReload!(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
        
        return
    }
 
    /**
     * 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        if (isDataSave == true) {
            delegate?.PageNeedReload!(true)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}