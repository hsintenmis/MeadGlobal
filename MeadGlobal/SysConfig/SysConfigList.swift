//
// Zip file class, iCloud function
// TableView Static, ContainerView 的延伸 view
//

import Foundation
import UIKit

/**
 * 設定項目列表
 */
class SysConfigList: UITableViewController, UIDocumentPickerDelegate, SSZipArchiveDelegate {
    
    private let isDebug = false
    
    /** 備份檔案名稱: 'backup.zip' */
    private let D_ZIPFILENAME  = "backup.zip"
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    
    // property
    private var pubClass = PubClass()
    private let mFileMang = FileMang()
    private var mMemberClass = MemberClass()
    private var mRecordClass = RecordClass()
    
    /**
     * View load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * #mark: TableView VC delegate
     * table view Item 點取
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
            let mDocumentPicker = UIDocumentPickerViewController(documentTypes: aryMime, inMode: UIDocumentPickerMode.Import)
            
            mDocumentPicker.delegate = self
            mDocumentPicker.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            
            self.presentViewController(mDocumentPicker, animated: false, completion: {})
            
            return
        }
    }
    
    /**
     * #mark: UIDocumentPickerViewController
     * 'presentViewController' 使用
     */
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        // Mode = 'ExportToService', 上傳完成
        if (controller.documentPickerMode == UIDocumentPickerMode.ExportToService) {
            // 刪除壓縮檔
            if (mFileMang.isFilePath(D_ZIPFILENAME)) {
                mFileMang.delete(D_ZIPFILENAME)
            }
            pubClass.popIsee(self, Msg: pubClass.getLang("sysconfig_backupcompleted"))
            
            return
        }
        
        // Mode = "Import"
        if (controller.documentPickerMode == UIDocumentPickerMode.Import) {
            // 資料回復程序
            let strMsg = (self.procRestore(url)) ? "sysconfig_restorecompleted" : "err_data"
            pubClass.popIsee(self, Msg: pubClass.getLang(strMsg))
            
            return
        }
    }
    
    /**
     * 資料回復程序
     * 1. 下載取得 .zip 檔案, 2. 解開壓縮檔比對資料正確性
     * 3. 解開的目錄更名為正式的目錄名稱
     *
     * @param NSURL: 由 'UIDocumentPickerViewController' 傳入
     */
    private func procRestore(url: NSURL)->Bool {
        var bolRS = false
        
        // 下載的檔案複製到指定目錄
        let strFixZipFileName = "dbdata.zip"
        let strDLFilePath = mFileMang.mDocPath + strFixZipFileName
        mFileMang.delete(strFixZipFileName)
        
        do {
            try mFileMang.mFileMgr.moveItemAtURL(url, toURL: NSURL(fileURLWithPath: strDLFilePath))
        }
        catch {
            if (isDebug) {print("err: 下載的檔案複製到指定目錄")}
            return false
        }
        
        // 設定解壓縮暫存目錄
        let strTmpDir = "ziptmp"
        let strTmpDirPath = mFileMang.mDocPath + strTmpDir
        mFileMang.delete(strTmpDir)
        mFileMang.createDir(strTmpDir)
        
        // 解壓縮檔案至暫存目錄, 解開目錄將成為 ziptmp/dedata/...
        bolRS = SSZipArchive.unzipFileAtPath(strDLFilePath, toDestination: strTmpDirPath)
        do {
            try mFileMang.mFileMgr.removeItemAtURL(url)
        } catch {
        }
        
        // 刪除下載的檔案
        mFileMang.delete(strFixZipFileName)
        
        // 解壓縮錯誤，跳離
        if (!bolRS) {
            if (isDebug) {print("err: 解壓縮錯誤")}
            return false
        }
        
        // 檢查解壓縮的資料, ex. D_FILE_MEMBER = dbdata/member.txt
        let aryChkFile = [mMemberClass.D_FILE_MEMBER, mMemberClass.D_FILE_MEMBER_SERIAL, mRecordClass.D_FILE_REPORT, mRecordClass.D_FILE_REPORT_SERIAL]
        
        for strFilename in aryChkFile {
            if (!(mFileMang.isFilePath(strTmpDir + "/" + strFilename))) {
                if (isDebug) {print("err: 解壓縮的資料錯誤")}
                return false
            }
        }
        
        // 解開的目錄，直接更名, ex. ziptmp/dbdata => dbdata
        let targetPath = mFileMang.mDocPath + mFileMang.D_ROOT_PATH
        mFileMang.delete(mFileMang.D_ROOT_PATH)
        mFileMang.rename(SourceName: strTmpDirPath + "/" + mFileMang.D_ROOT_PATH, TargetName: targetPath)
        
        return true
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