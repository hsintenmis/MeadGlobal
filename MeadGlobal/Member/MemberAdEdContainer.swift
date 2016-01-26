//
// UIDatePicker, 檔案寫入(String / UIImage)
//

import UIKit
import Foundation

/**
 * 會員新增/編輯, 文字/圖片 資料儲存
 */
class MemberAdEdContainer: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ClipViewControllerDelegate {
    
    // @IBOutlet
    @IBOutlet weak var imgTarget: UIImageView!
    @IBOutlet weak var edName: UITextField!
    @IBOutlet weak var edTel: UITextField!
    @IBOutlet weak var edBirth: UITextField!
    @IBOutlet weak var swchGender: UISegmentedControl!
    
    @IBOutlet weak var cellBirth: UITableViewCell!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 由 parent 'prepareForSegue' 設定, 有資料表示本頁面編輯模式
    var dictMember: Dictionary<String, String> = [:]
    var strMode = "add"  // 本頁面模式, 'add' or 'edit'
    var mMemberAdEd: MemberAdEd!
    
    // 檔案存取/圖片處理
    var mImgPicker: UIImagePickerController!
    var isNewPict = false
    var strMemberID: String = ""  // 若為 'edit' 模式一定有值
    
    let sizeZoom: CGFloat = 3.0  // 图片缩放的最大倍数
    let sizeCute: CGFloat = 120.0  // 裁剪框的長寬
    let typeCut: Int = 1; // 裁剪框的形狀, 0=圓, 1=方
    
    // UIDatePicker 設定
    private let defBirth = "19600101"
    private let defMaxYMD = "20101231"
    private let defMinYMD = "19150101"
    
    private var strBirth = ""
    private let dateFmt_YMD = NSDateFormatter()  // YYMMDD
    private let dateFmt_Read = NSDateFormatter()  // 根據local顯示, ex. 2015年1月1日
    
    private let datePickerView:UIDatePicker = UIDatePicker()
    
    // textView array 與 val 值對應的 array data
    private var aryTxtView: Array<UITextField> = []
    
    // 其他 class
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
        
        // 圖片處理相關
        mImgPicker = UIImagePickerController()
        mImgPicker.delegate = self
        mImgPicker.allowsEditing = false
        
        // 生日欄位， date Picker 初始設定
        initBirthPickDateView()
        
        // 編輯模式特殊處理
        self.procEditMode()
        
        // 點取 'edBirth' 彈出日期視窗取代 '鍵盤視窗'
        edBirth.inputView = datePickerView
        initInputViewTopBar()
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
        initViewField()
    }
    
    /**
     * 設定頁面內容
     */
    private func initViewField() {
        // text 輸入欄位設定
        edName.delegate = self
        edTel.delegate = self
    }
    
    /**
     * 設定頁面語系
     */
    private func setPageLang() {
        swchGender.setTitle(pubClass.getLang("gender_M"), forSegmentAtIndex: 0)
        swchGender.setTitle(pubClass.getLang("gender_F"), forSegmentAtIndex: 1)
    }
    
    /**
    * 生日欄位， date Picker 初始設定
    * "dd-MM-yyyy HH:mm:ss"
    */
    private func initBirthPickDateView() {
        // 設定日期顯示樣式
        dateFmt_YMD.dateFormat = "yyyyMMdd"
        dateFmt_Read.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFmt_Read.timeStyle = NSDateFormatterStyle.NoStyle
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        datePickerView.minimumDate = dateFmt_YMD.dateFromString(defMinYMD)!
        datePickerView.maximumDate = dateFmt_YMD.dateFromString(defMaxYMD)!
        
        // 設定 datePick value change 要執行的程序
        //datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    /**
    * edit 點取彈出 資料輸入視窗 (虛擬鍵盤), 'InputView' 的頂端顯示 'navyBar'
    */
    private func initInputViewTopBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true  // 半透明
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)  // 文字顏色
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: pubClass.getLang("btnact_done"), style: UIBarButtonItemStyle.Plain, target: self, action: "PickerDone")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: pubClass.getLang("cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: "PickerCancel")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        edBirth.inputAccessoryView = toolBar
    }
    
    /**
     * DatePicker 點取　'done'
    */
    @objc private func PickerDone() {
        self.edBirth.resignFirstResponder()
        self.datePickerValueChanged(self.datePickerView)
    }
    
    /**
     * DatePicker 點取　'cancel'
     */
    @objc private func PickerCancel() {
        self.edBirth.resignFirstResponder()
    }
    
    /**
     * UIDatePicker 自訂的 value change method
     * 使用方式如下:
     * datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), 
     *   forControlEvents: UIControlEvents.ValueChanged)
     */
    @objc private func datePickerValueChanged(sender:UIDatePicker) {
        // edBirth 顯示文字
        dispatch_async(dispatch_get_main_queue(), {
            self.edBirth.text = self.dateFmt_Read.stringFromDate(sender.date)
        })
        
        // 設定 strBirth value
        strBirth = dateFmt_YMD.stringFromDate(sender.date)
    }
    
    /**
     * 編輯模式特殊處理
     */
    private func procEditMode() {
        if (strMode != "edit") {
            // 生日初始預設值
            let mDate = dateFmt_YMD.dateFromString(defBirth)!
            datePickerView.setDate(mDate, animated: false)
            //edBirth.text = dateFmt_Read.stringFromDate(mDate)
            
            return
        }
        
        strMemberID = dictMember["id"]!
        edName.text = dictMember["name"]
        edTel.text = dictMember["tel"]
        swchGender.selectedSegmentIndex = (dictMember["gender"] == "M") ? 0 : 1
        imgTarget.image = mMemberClass.getMemberPict(dictMember["id"]!)

        // 'birth' 文字處理
        strBirth = dictMember["birth"]!
        let mDate = dateFmt_YMD.dateFromString(strBirth)!
        edBirth.text = dateFmt_Read.stringFromDate(mDate)
        datePickerView.setDate(mDate, animated: false)
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
     * #mark: 系統 Delegate, ClipViewControllerDelegate
     * UIImagePickerController 的 protocol (implements)
     */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * #mark: 自訂 Delegate, ClipViewControllerDelegate
     * ClipViewControllerDelegate, 實作 method
     */
    func ClipViewController(clipViewController: CutImage, FinishClipImage editImage: UIImage) {
        
        clipViewController.dismissViewControllerAnimated(true, completion: {
            self.isNewPict = true
            self.imgTarget.image = editImage
        })
    }
    
    /**
     * #mark: 系統 Delegate, UITextFieldDelegate<BR>
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == edName) {
            edTel.becomeFirstResponder()
            return true
        }
        if textField == edTel {
            edBirth.becomeFirstResponder()
            return true
        }
        
        return true
    }
    
    /**
     * 會員資料儲存(新增 or 更新資料)
     */
    func startSaveData()->Bool {
        // 檢查輸入資料
        if (edName.text!.isEmpty) {
            pubClass.popIsee(Msg: "err_membername")
            return false
        }
        
        if (edTel.text!.isEmpty) {
            pubClass.popIsee(Msg: "err_tel")
            return false
        }
        
        if (edBirth.text!.isEmpty) {
            pubClass.popIsee(Msg: "err_birth")
            return false
        }
        
        // 產生 Dictionary data
        var dictData = Dictionary<String, String>()
        dictData["id"] = ""
        dictData["name"] = edName.text!
        dictData["tel"] = edTel.text!
        dictData["gender"] = (swchGender.selectedSegmentIndex == 0) ? "M" : "F"
        dictData["birth"] = strBirth
        
        // 會員新增 or 資料更新
        if (self.strMode == "add") {
            let dictRS = mMemberClass.add(dictData)
            if (dictRS["rs"] as! Bool != true) {
                pubClass.popIsee(Msg: "err_member_newadd")
                
                return false
            }
            
            strMemberID = dictRS["id"] as! String
        } else {
            dictData["id"] = dictMember["id"]
            let dictRS = mMemberClass.update(dictData)
            
            if (dictRS["rs"] as! Bool != true) {
                pubClass.popIsee(Msg: dictRS["err"] as! String)
                
                return false
            }
            
            strMemberID = dictData["id"]!
        }
        
        // 圖片儲存
        if (self.isNewPict == true) {
            //mFileMang.write(strMemberID + ".png", withUIImage: imgTarget.image)
            mFileMang.write(mMemberClass.D_PATH_MEMBER_PICT + "/" + strMemberID + ".png", withUIImage: imgTarget.image)
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}