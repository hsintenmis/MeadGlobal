//
// 檔案寫入(String / UIImage)
//

import UIKit
import Foundation

/**
 * 會員新增, 文字/圖片 資料儲存
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
    
    // 檔案存取/圖片處理
    var mFileMang: FileMang!
    var mImgPicker: UIImagePickerController!
    var isNewPict = false
    var strMemberID = ""
    
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
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
        // !! 顯示 'document' 圖片
        /*
        let imgFile = "m00001.png"
        if (mFileMang.isFilePath(imgFile)) {
            imgTarget.image = UIImage(contentsOfFile: mFileMang.mDocPath + imgFile)
        }
        */
    }
    
    /**
     * 設定頁面語系
     */
    private func setPageLang() {
        PageTitle.title = pubClass.getLang("member_add")
        btnBack.title = pubClass.getLang("back")
        btnSave.title = pubClass.getLang("save")
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
        if (edName.text!.isEmpty || edTel.text!.isEmpty) {
            pubClass.popIsee(Msg: "err_nameortel")
            return false
        }
        
        // 產生 Dictionary data
        var dictData = Dictionary<String, String>()
        dictData["name"] = edName.text!
        dictData["tel"] = edTel.text!
        dictData["gender"] = (swchGender.selectedSegmentIndex == 0) ? "M" : "F"
        dictData["birth"] = ""
        
        if let strBirth: String = edBirth.text {
            dictData["birth"] = strBirth
        }
        
        // 取得全部會員 JSON Array data
        var strJSON = mFileMang.read(pubClass.D_FILE_MEMBER)
        var aryAllData: Array<Dictionary<String, String>> = []
        
        if (strJSON.isEmpty) {
            strMemberID = pubClass.D_STR_IDHEAD + String(format: "%05d", 1)
            dictData["id"] = strMemberID
            aryAllData.append(dictData)
        }
        else {
            // JSON string 轉為 Array or Dictionary
            do {
                let mNSData: NSData = strJSON.dataUsingEncoding(NSUTF8StringEncoding)!
                let jobjRoot = try NSJSONSerialization.JSONObjectWithData(mNSData, options:NSJSONReadingOptions(rawValue: 0))
                
                guard let tmpAllData = jobjRoot as? Array<Dictionary<String, String>> else {
                    pubClass.popIsee(Msg: "err_data")
                    return false
                }
                
                strMemberID = pubClass.D_STR_IDHEAD + String(format: "%05d", tmpAllData.count + 1)
                dictData["id"] = strMemberID
                aryAllData = tmpAllData
                aryAllData.append(dictData)
            }
            catch let errJson as NSError {
                pubClass.popIsee(Msg: "err_data:\n\(errJson)")
                return false
            }
        }
        
        // Array/Dictionary data 轉為 JSON string
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(aryAllData, options: NSJSONWritingOptions(rawValue: 0))
            strJSON = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String

        } catch {
            pubClass.popIsee(Msg: pubClass.getLang("err_data"))
            return false
        }
        
        // 全部會員 String 資料存檔
        mFileMang.write(pubClass.D_FILE_MEMBER, strData: strJSON)
        
        return true
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
        
        // popWindow, 點取後 class close
        let mAlert = UIAlertController(title: "", message: pubClass.getLang("datasavecomplete"), preferredStyle:UIAlertControllerStyle.Alert)
        
        mAlert.addAction(UIAlertAction(title:pubClass.getLang("i_see"), style: UIAlertActionStyle.Default, handler:
            {(action: UIAlertAction!) in self.dismissViewControllerAnimated(true, completion: nil)}
            ))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mVCtrl.presentViewController(mAlert, animated: true, completion: nil)
        })
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