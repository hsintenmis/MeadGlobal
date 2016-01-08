//
// 檔案寫入(String / UIImage)
//

import UIKit
import Foundation

/**
 * 會員新增/編輯, 文字/圖片 資料儲存
 */
class MemberAdEd: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ClipViewControllerDelegate {
    
    // @IBOutlet
    @IBOutlet weak var PageTitle: UINavigationItem!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    @IBOutlet weak var imgTarget: UIImageView!
    @IBOutlet weak var edName: UITextField!
    @IBOutlet weak var edTel: UITextField!
    @IBOutlet weak var edBirth: UITextField!
    @IBOutlet weak var swchGender: UISegmentedControl!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 由 parent 'prepareForSegue' 設定, 有資料表示本頁面編輯模式
    var dictMember: Dictionary<String, String> = [:]
    var strMode = "add"  // 本頁面模式, 'add' or 'edit'
    var mParentClass: MemberList!
    
    // 檔案存取/圖片處理
    var mFileMang: FileMang!
    var mImgPicker: UIImagePickerController!
    var isNewPict = false
    var strMemberID: String = ""  // 若為 'edit' 模式一定有值
    
    let sizeZoom: CGFloat = 3.0  // 图片缩放的最大倍数
    let sizeCute: CGFloat = 120.0  // 裁剪框的長寬
    let typeCut: Int = 1; // 裁剪框的形狀, 0=圓, 1=方
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        mFileMang = FileMang()
        
        // 圖片處理相關
        mImgPicker = UIImagePickerController()
        mImgPicker.delegate = self
        mImgPicker.allowsEditing = false
        
        // 設定頁面語系
        self.setPageLang()
        
        // 編輯模式特殊處理
        self.procEditMode()
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
     * 編輯模式特殊處理
     */
    private func procEditMode() {
        if (strMode != "edit") {
            return
        }
        
        strMemberID = dictMember["id"]!
        edName.text = dictMember["name"]
        edTel.text = dictMember["tel"]
        edBirth.text = dictMember["birth"]
        swchGender.selectedSegmentIndex = (dictMember["gender"] == "M") ? 0 : 1
        
        let imgFileName = dictMember["id"]! + ".png"
        if (mFileMang.isFilePath(imgFileName)) {
            imgTarget.image = UIImage(contentsOfFile: mFileMang.mDocPath + imgFileName)
        }
    }
    
    /**
    * Action, 點取進入圖片選取程序
    */
    @IBAction func actGallery(sender: UIButton) {
        // 產生 UIImagePickerController, 選取圖片
        mImgPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(mImgPicker, animated: true, completion:nil)
    }
    
    /**
     * Action, 點取 button '選擇相機
     */
    @IBAction func actCamera(sender: UIButton) {
        if (UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil) {
            mImgPicker.sourceType = UIImagePickerControllerSourceType.Camera
            mImgPicker.cameraCaptureMode = .Photo
            presentViewController(mImgPicker, animated: true, completion: nil)
        } else {
            return
        }
    }
    
    /**
     * #Delegate: 系統的 UIImagePickerControllerDelegate
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        // 選擇圖片後，執行第三方圖片處理
        dismissViewControllerAnimated(true, completion: {
            ()->Void in
            
            let mCutImage: CutImage = CutImage()
            mCutImage.delegate = self
            mCutImage.scaleRation = self.sizeZoom
            mCutImage.clipType = self.typeCut
            mCutImage.radius = self.sizeCute
            mCutImage.initWithImage(info[UIImagePickerControllerOriginalImage] as! UIImage)
            
            self.presentViewController(mCutImage, animated: true, completion: nil)
        })
    }

    /**
     * #Delegate: ClipViewControllerDelegate
     * UIImagePickerController 的 protocol (implements)
     */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * #Delegate: ClipViewControllerDelegate
     * ClipViewControllerDelegate, 實作 method
     */
    func ClipViewController(clipViewController: CutImage, FinishClipImage editImage: UIImage) {
        
        clipViewController.dismissViewControllerAnimated(true, completion: {
            self.isNewPict = true
            self.imgTarget.image = editImage
        })
    }
    
    /**
     * 會員資料儲存
     */
    private func startSaveData()->Bool {
        // 檢查輸入資料
        if (edName.text!.isEmpty) {
            pubClass.popIsee(Msg: "err_membername")
            return false
        }
        
        if (edTel.text!.isEmpty) {
            pubClass.popIsee(Msg: "err_tel")
            return false
        }
        
        // 產生 Dictionary data
        var dictData = Dictionary<String, String>()
        dictData["id"] = ""
        dictData["name"] = edName.text!
        dictData["tel"] = edTel.text!
        dictData["gender"] = (swchGender.selectedSegmentIndex == 0) ? "M" : "F"
        dictData["birth"] = ""
        
        if let strBirth: String = edBirth.text {
            dictData["birth"] = strBirth
        }
        
        // 取得全部會員 JSON String, 資料存檔
        let strJSON = (self.strMode == "add") ? addDataProc(dictData) : editDataProc(dictData)
        if (strJSON.isEmpty) {
            pubClass.popIsee(Msg: "err_data")
            
            return false
        }
        
        mFileMang.write(pubClass.D_FILE_MEMBER, strData: strJSON)
        
        return true
    }
    
    /**
    * 資料新增作業
    * @param dictData: 會員輸入的資料
    * @return String: JSON string, 已整理好的全部會員資料
    */
    private func addDataProc(var dictData: Dictionary<String, String>)->String {
        let strJSON = mFileMang.read(pubClass.D_FILE_MEMBER)
        var aryAllData: Array<Dictionary<String, String>> = []
        
        // 第一筆資料
        if (strJSON.isEmpty) {
            strMemberID = pubClass.D_STR_IDHEAD + String(format: "%05d", 1)
            dictData["id"] = strMemberID
            aryAllData.append(dictData)
        }
        else {
            // JSON string 轉為 Array or Dictionary
            aryAllData = pubClass.JSONStrToAry(strJSON) as! Array<Dictionary<String, String>>
            if (aryAllData.count < 1) {
                return ""
            }
            
            // 取得新會員ID, 最後一個 id 流水號 +1
            strMemberID = pubClass.D_STR_IDHEAD + String(format: "%05d", aryAllData.count + 1)
            
            dictData["id"] = strMemberID
            aryAllData.append(dictData)
        }
        
        return pubClass.DictAryToJSONStr(aryAllData)
    }
    
    /**
     * 資料更新作業
     * @param dictData: 會員輸入的資料
     * @return String: JSON string, 已整理好的全部會員資料
     */
    private func editDataProc(dictData: Dictionary<String, String>)->String {
        let strJSON = mFileMang.read(pubClass.D_FILE_MEMBER)
        
        if (strJSON.isEmpty) {
            return ""
        }
            
        // JSON string 轉為 Array or Dictionary
        let aryAllData = pubClass.JSONStrToAry(strJSON) as! Array<Dictionary<String, String>>
        if (aryAllData.count < 1) {
            return ""
        }
        
        // loop all data, 比對指定會員 id 修改資料
        var newAllData: Array<Dictionary<String, String>> = []
        
        for dictItem in aryAllData {
            if (dictItem["id"] == strMemberID) {
                var tmpItem = dictData
                tmpItem["id"] = strMemberID
                newAllData.append(tmpItem)
            } else {
                newAllData.append(dictItem)
            }
        }
        
        return pubClass.DictAryToJSONStr(newAllData)
    }
    
    /**
     * action 資料儲存
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        // 文字資料儲存程序
        if (!self.startSaveData()) {
            return
        }
        
        // 圖片儲存
        if (self.isNewPict == true) {
            mFileMang.write(strMemberID + ".png", withUIImage: imgTarget.image)
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