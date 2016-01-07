//
// FileManage, Add / Write / Read, 目錄為 app 的 Documents
//

import Foundation
import UIKit

/**
 * 檔案增刪修寫讀處理
 */
class FileMang {
    var isDebug = true;
    let mDocPath: String!  // 取得 documentsPath 路徑
    let mFileMgr = NSFileManager.defaultManager()
    
    /**
     * init
     */
    init() {
        mDocPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "/"
    }
    
    /**
     * 檔案/目錄 是否存在
     */
    func isFilePath(strFileName: String) -> Bool{
        return self.mFileMgr.fileExistsAtPath(self.mDocPath + strFileName)
    }
    
    /**
     * 刪除 檔案/目錄
     */
    func delete(strFileName: String) -> Bool{
        if (!isFilePath(strFileName)) {
            return false
        }
        
        do {
            try self.mFileMgr.removeItemAtPath(self.mDocPath + strFileName)
        }
        catch let error as NSError {
            if (isDebug) { print("err: delete failure!\n\(error)") }
            return false
        }
        
        return true
    }
    
    /**
    * 檔案寫資料 / 建立檔案 (String 寫入)
    *
    * @param strData : string or nil
    */
    func write(strFileName: String, strData: String) {
        let mFile = self.mDocPath + strFileName
        let mData = (strData.isEmpty) ? "" : strData
        let databuffer = mData.dataUsingEncoding(NSUTF8StringEncoding)
        self.mFileMgr.createFileAtPath(mFile, contents: databuffer, attributes: nil)
    }
    
    /**
     * 檔案寫資料 / 建立檔案 (UIImage 寫入, jpeg)
     *
     * @param mImg : UIImage!
     */
    func write(strFileName: String, withUIImage mImg: UIImage!) {
        if let data = UIImageJPEGRepresentation(mImg, 0.8) {
            let mFile = self.mDocPath + strFileName
            data.writeToFile(mFile, atomically: true)
        }
    }
    
    /**
    * 讀取檔案資料
    * @return: String or ""
    */
    func read(strFileName: String!) -> String {
        let mFile = self.mDocPath + strFileName
        if (!self.isFilePath(strFileName)) {
            if (isDebug) { print("err: file/path not exists!") }
            return ""
        }
        
        let mBuff = self.mFileMgr.contentsAtPath(mFile)
        if (mBuff == nil) {
            return ""
        }
        
        return String(data: mBuff!, encoding: NSUTF8StringEncoding)!
    }

    
}


