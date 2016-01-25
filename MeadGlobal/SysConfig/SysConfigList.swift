//
// Zip file class, iCloud function
// TableView Static, ContainerView 的延伸 view
//

import Foundation
import UIKit

/**
 * 會員資料編輯與儲存
 */
class SysConfigList: UITableViewController, UIDocumentPickerDelegate {
    /** 備份檔案名稱: 'backup.zip' */
    private let D_ZIPFILENAME  = "backup.zip"
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private var mMemberClass: MemberClass!
    private let mFileMang = FileMang()
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        mMemberClass = MemberClass(ProjectPubClass: pubClass)
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {

    }
    
    /**
     * 設定頁面內容
     */
    private func initViewField() {
        
    }

    /**
    * #Mark UITableViewController: Cell 點取執行 prepareForSegue
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // DocumentPicker
        
        
        // get cell identify name
        let strIdent = tableList.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        
        // 資料備份, export,  資料上傳 iCloud or 其他的 app
        if (strIdent == "cellBackup") {
            // 檔案壓縮程序
            let zipPath = mFileMang.mDocPath + D_ZIPFILENAME
            let sampleDataPath = mFileMang.mDocPath + mFileMang.D_ROOT_PATH

            SSZipArchive.createZipFileAtPath(zipPath, withContentsOfDirectory: sampleDataPath, keepParentDirectory: true)

            // 設定 'DocumentPicker' 並顯示
            let localDocumentsURL = mFileMang.mFileMgr.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: .UserDomainMask).last
            let myLocalFile = localDocumentsURL!.URLByAppendingPathComponent(D_ZIPFILENAME)
            
            // 設定 'UIDocumentPickerViewController' 並顯示
            let mDocumentPicker = UIDocumentPickerViewController(URL: myLocalFile, inMode: UIDocumentPickerMode.ExportToService)
            mDocumentPicker.delegate = self
            mDocumentPicker.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            
            self.presentViewController(mDocumentPicker, animated: true, completion: {})
        
            return
        }
        
        // 資料回復, import, 從 iCloud or 其他 app 下載(import) 檔案
        if (strIdent == "cellRestore") {
            // 設定 'DocumentPicker' 並顯示 ("public.archive")
            let aryMime = ["public.data"]
            //let aryMime = [D_ZIPFILENAME]
            
            let mDocumentPicker = UIDocumentPickerViewController(documentTypes: aryMime, inMode: UIDocumentPickerMode.Import)
            mDocumentPicker.delegate = self
            mDocumentPicker.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            
            self.presentViewController(mDocumentPicker, animated: false, completion: {})
            
            return
        }
    }
    
    /**
     * #mark UIDocumentPickerViewController
     * 'presentViewController' 使用
     */
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        
        // Mode = 'ExportToService', 上傳完成
        if (controller.documentPickerMode == UIDocumentPickerMode.ExportToService) {
            // 刪除壓縮檔
            if (mFileMang.isFilePath(D_ZIPFILENAME)) {
                mFileMang.delete(D_ZIPFILENAME)
            }
            
            pubClass.popIsee(Msg: pubClass.getLang("sysconfig_backupcompleted"))

            return
        }
        
        // Mode = "Import"
        if (controller.documentPickerMode == UIDocumentPickerMode.Import) {
            print("file download: \(url)")
            
            // 檢查檔案是否已下載
            if (mFileMang.isFilePath(D_ZIPFILENAME)) {
                
            }
            
            // 解開下載檔案，檢查資料正確性
            
            pubClass.popIsee(Msg: pubClass.getLang("sysconfig_restorecompleted"))
            
            return
        }
    }

    /*
    * #mark UIDocumentPickerViewController, Cancl
    */
    func documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
        return
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        print(strIdentName)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}