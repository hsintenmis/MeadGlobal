//
// UIDatePicker, 檔案寫入(String / UIImage)
//

import UIKit
import Foundation

/**
 * 會員新增/編輯, 文字/圖片 資料儲存
 */
class MemberAdEdContainer: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CutImageDelegate {
    
    // @IBOutlet
    @IBOutlet weak var imgTarget: UIImageView!
    @IBOutlet weak var edName: UITextField!
    @IBOutlet weak var edTel: UITextField!
    @IBOutlet weak var edBirth: UITextField!
    @IBOutlet weak var swchGender: UISegmentedControl!
    @IBOutlet weak var cellBirth: UITableViewCell!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnCmaera: UIButton!
    
    // common property
    private var pubClass = PubClass()
    
    // public, parent 設定
    var dictMember: Dictionary<String, String> = [:]
    var strMode: String!  // 本頁面模式, 'add' or 'edit'
    
    // 檔案存取/圖片處理
    private var mImgPicker: UIImagePickerController!
    private let sizeZoom: CGFloat = 3.0  // 图片缩放的最大倍数
    private let sizeCute: CGFloat = 120.0  // 裁剪框的長寬
    private let typeCut: Int = 1; // 裁剪框的形狀, 0=圓, 1=方
    private var imgNew = UIImage()  // 是否有設定會員圖片
    
    // UIDatePicker, 日期預設值設定
    private let defBirth = "19600101"
    private let defMaxYMD = "20101231"
    private let defMinYMD = "19150101"
    
    private var strBirth = ""
    private let dateFmt_YMD = NSDateFormatter()  // YYMMDD
    private let dateFmt_Read = NSDateFormatter()  // 根據local顯示, ex. 2015年1月1日
    
    private let datePickerView: UIDatePicker = UIDatePicker()
    
    // 其他
    private var strMemberID: String?  // 若為 'edit' 模式一定有值
    private let mFileMang = FileMang()
    private var mMemberClass = MemberClass()
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // view field 設定, 'edBirth' 彈出日期視窗取代 '鍵盤視窗'
        edBirth.inputView = datePickerView
        initInputViewTopBar()
        btnGallery.layer.cornerRadius = 5.0
        btnCmaera.layer.cornerRadius = 5.0
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
        
        let doneButton = UIBarButtonItem(title: pubClass.getLang("btnact_done"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.PickerDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: pubClass.getLang("cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.PickerCancel))
        
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
     * #mark: UIImagePickerControllerDelegate
     * UIImagePicker VC 圖片選取完成
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // 選擇圖片後，執行第三方圖片處理 'CutImage' class
        dismissViewControllerAnimated(true, completion: {()->Void in
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
     * #mark: UIImagePickerControllerDelegate
     * UIImagePicker VC 點取 cancel
     */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * #mark: CutImageDelegate, 圖片裁切完成
     */
    func imageCutDone(vcCutImage: CutImage, FinishCutImage editImage: UIImage) {
        vcCutImage.dismissViewControllerAnimated(true, completion: {
            self.imgTarget.image = editImage
            self.imgNew = editImage
        })
    }
    
    /**
     * #mark: 系統 Delegate, UITextFieldDelegate<BR>
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    /**
     * public, parent 調用
     * 檢查本頁面資料，回傳輸入的資料給 parent
     * @return: 'data', 'img'
     */
    func getPageData()->Dictionary<String, AnyObject>? {
        var errMsg = ""
        
        // 檢查輸入資料
        if (edName.text?.characters.count < 2) {
            errMsg = "err_membername"
        }
        else if (edTel.text?.characters.count < 6) {
            errMsg = "err_tel"
        }
        else if (edBirth.text?.characters.count < 1) {
            errMsg = "err_birth"
        }
        
        if (errMsg.characters.count > 0) {
            pubClass.popIsee(self, Msg: pubClass.getLang(errMsg))
            
            return nil
        }
        
        // 產生 Dictionary data
        var dictData: Dictionary<String, String> = [:]
        dictData["id"] = ""
        dictData["name"] = edName.text!
        dictData["tel"] = edTel.text!
        dictData["gender"] = (swchGender.selectedSegmentIndex == 0) ? "M" : "F"
        dictData["birth"] = strBirth

        return ["data": dictData, "img": imgNew]
    }
    
    /**
     * act, 點取 '圖片選取'
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}