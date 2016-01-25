//
// 檢測記錄檔公用程式
//
// 專案進入頁面，必須使用 'chkData' 檢查是否有會員與初始資料
// 流水號記錄檔 max 六碼，1 ~ 999999
// 記錄編號如.  R000001
//

import Foundation

/**
 * 本專案會員的設定檔與公用 method
 */
class RecordClass {
    private let isDebug = true
    
    /** 根目錄參考 'FileMang class', 沒有 '/' */
    private var D_ROOT_PATH: String!
    
    /** 會員資料檔 JSON string, 檔名: member.txt */
    var D_FILE_REPORT = "record.txt"
    
    /** 會員編號 流水號記錄檔 */
    var D_FILE_REPORT_SERIAL = "record_serial.txt"
    
    /** 會員資料，唯一識別碼前置字串，ex. 'R' + '000001' */
    let D_IDHEAD = "R"
    
    // 其他 class
    private var pubClass: PubClass!
    private var mFileMang = FileMang()
    private var mJSONClass = JSONClass()
    private var strToday: String!
    
    /**
     * init
     * @today: ex. YMD hms 14碼
     */
    init(ProjectPubClass mPubClass: PubClass) {
        pubClass = mPubClass
        strToday = pubClass.getDevToday()
        
        D_ROOT_PATH = mFileMang.D_ROOT_PATH
        D_FILE_REPORT = D_ROOT_PATH + "/" + D_FILE_REPORT
        D_FILE_REPORT_SERIAL = D_ROOT_PATH + "/" + D_FILE_REPORT_SERIAL
    }
    
    /**
     * 檢查是否首次使用，初始資料
     *
     * @return Boolean
     */
    func chkData()->Bool {
        var bolRS = false
        
        // 檢查 '資料檔'
        if (!mFileMang.isFilePath(D_FILE_REPORT)) {
            bolRS = mFileMang.write(D_FILE_REPORT, strData: "")
            if (isDebug) {print("create file \(D_FILE_REPORT): \(bolRS)")}
            if (!bolRS) {return false}
        }
        
        // 檢查 '流水號記錄檔'
        if (!mFileMang.isFilePath(D_FILE_REPORT_SERIAL)) {
            bolRS = mFileMang.write(D_FILE_REPORT_SERIAL, strData: "1")
            if (isDebug) {print("create file \(D_FILE_REPORT_SERIAL): \(bolRS)")}
            if (!bolRS) {return false}
        }
        
        return true
    }
    
    /**
     * 記錄編號'流水號', 6碼 String
     *
     * @return String : ex. 00000001, "" = false
     */
    private func getSerial()->String {
        let strSerial = mFileMang.read(D_FILE_REPORT_SERIAL)
        
        if (strSerial.isEmpty) {
            return strSerial
        }
        
        return String(format: "%06d", Int(strSerial)!)
    }
    
    /**
     * 記錄編號 流水號記錄檔 count++
     *
     * @return String: "" = true or err code
     */
    private func updateSerial()->String {
        let strSerial = mFileMang.read(D_FILE_REPORT_SERIAL)
        
        if (strSerial.isEmpty) {
            return "err_recordclass_updateSerial"
        }
        
        mFileMang.write(D_FILE_REPORT_SERIAL, strData: String(Int(strSerial)! + 1))
        
        return ""
    }
    
    /**
     * 取得全部記錄資料 Array data
     *
     * @param isSortASC: false(預設), 資料反向整理，新資料在前
     */
    func getAll(isSortASC isASC: Bool)->Array<Dictionary<String, String>> {
        var aryAllData: Array<Dictionary<String, String>> = []
        let strJSON = mFileMang.read(D_FILE_REPORT)
        
        if (!strJSON.isEmpty) {
            let tmpAllData = mJSONClass.JSONStrToAry(strJSON) as! Array<Dictionary<String, String>>
            
            // 資料反向整理，新資料在前
            if (!isASC) {
                for (var loopi = (tmpAllData.count - 1); loopi >= 0; loopi--) {
                    aryAllData.append(tmpAllData[loopi])
                }
            }
            else {
                aryAllData = tmpAllData
            }
        }
        
        return aryAllData
    }
    
    /**
     * 取得指定ID(流水號)的記錄資料 array data
     *
     * @param strId: 記錄編號
     * @return [:] or Dictionary<String, String>
     */
    func getSingle(strId: String!)->Dictionary<String, String> {
        let dictEmpty: Dictionary<String, String> = [:]
        let strJSON = mFileMang.read(D_FILE_REPORT)
        
        if (strJSON.isEmpty) {
            return dictEmpty
        }
        
        // loop all data, 比對指定 id 的資料
        let aryAllData: Array<Dictionary<String, String>> = self.getAll(isSortASC: true)
        for dictItem in aryAllData {
            if (dictItem["id"] == strId) {
                return dictItem
            }
        }
        
        return dictEmpty
    }
    
    /**
     * 取得指定會員的記錄資料 array data
     *
     * @param strId: 會員編號
     * @return [] or array Array<Dictionary<String, AnyObject>>
     */
    func getDataWithMemberId(strId: String!)->Array<Dictionary<String, String>> {
        var aryRS: Array<Dictionary<String, String>> = []
        
        let strJSON = mFileMang.read(D_FILE_REPORT)
        if (strJSON.isEmpty) {
            return aryRS
        }
        
        // loop all data, 比對指定會員 id 加入資料到 Array
        let aryAllData: Array<Dictionary<String, String>> = self.getAll(isSortASC: false)
        
        for dictItem in aryAllData {
            if (dictItem["memberid"] == strId) {
                aryRS.append(dictItem)
            }
        }
        
        return aryRS
    }
    
    /**
     * 記錄新增(記錄資料檔必定存在)
     *
     * @param dictData: 記錄資料, 格式如下：
     *  'id': 流水號, ex. 'R000001'
     *  'sdate': 14碼, 作為唯一識別 key
     *  'memberid': ex. MD000001
     *  'membername': 會員姓名
     *  'age': ex. "35"
     *  'gender': ex. "M"
     *  'avg', 'avgH', 'avgL'
     *  'val': ex. "27,12,33,56,34,67,..."
     *  'problem': 超出高低標的檢測項目, ex. "F220,H101,H420,..." or ""
     
     * @return Dict: 'rs'=Bool, 'err'='' or error msg, 'id'= serial text or ''
     */
    func add(var dictData: Dictionary<String, String>!)->Dictionary<String, AnyObject> {
        var dictRS: Dictionary<String, AnyObject> = ["rs": false, "err": "", "id": ""]
        var aryAllData = self.getAll(isSortASC: true)
        
        // 產生 ID, dict data 轉為 JSON string 寫入檔案
        dictData["id"] = D_IDHEAD + self.getSerial()
        dictRS["id"] = dictData["id"]
        
        aryAllData.append(dictData)
        //aryAllData.insert(dictData, atIndex: aryAllData.count)
        
        dictRS["rs"] = mFileMang.write(D_FILE_REPORT, strData: mJSONClass.DictAryToJSONStr(aryAllData))
        
        if (dictRS["rs"] as! Bool != true) {
            return dictRS
        }
        
        self.updateSerial()
        
        return dictRS
    }
    
    /**
     * 記錄刪除
     *
     * @param strId: 資料 ID (唯一編號)
     * @return Dict: 'rs'=Bool, 'err'='' or error msg
     */
    func del(strId: String!)->Dictionary<String, AnyObject> {
        var dictRS: Dictionary<String, AnyObject> = ["rs": false, "err": ""]
        
        // 指定 id 的資料是否存在
        if (self.getSingle(strId).count < 1) {
            dictRS["err"] = "err_recordclass_datanotexists"
            
            return dictRS
        }
        
        // loop all data, 比對指定 id 跳過該筆資料
        let aryAllData = self.getAll(isSortASC: true)
        var newAllData: Array<Dictionary<String, String>> = []
        
        for dictItem in aryAllData {
            if (dictItem["id"] != strId) {
                newAllData.append(dictItem)
            }
        }
        
        // 是否還有資料
        if (newAllData.count < 1) {
            mFileMang.write(D_FILE_REPORT, strData: "")
        } else {
            mFileMang.write(D_FILE_REPORT, strData: mJSONClass.DictAryToJSONStr(newAllData))
        }
        
        dictRS["rs"] = true
        
        return dictRS
    }
    
    /**
     * 記錄刪除, 指定會員ID
     *
     * @param strId: 會員 ID
     * @return Dict: 'rs'=Bool, 'err'='' or error msg
     */
    func delWithMemberId(strId: String!)->Dictionary<String, AnyObject> {
        var dictRS: Dictionary<String, AnyObject> = ["rs": false, "err": ""]
        
        // 指定會員 id 的是否有記錄資料
        if (self.getDataWithMemberId(strId).count < 1) {
            dictRS["err"] = "err_recordclass_datanotexists"
            
            return dictRS
        }
        
        // loop all data, 比對指定 id 跳過該筆資料
        let aryAllData = self.getAll(isSortASC: true)
        var newAllData: Array<Dictionary<String, String>> = []
        
        for dictItem in aryAllData {
            if (dictItem["memberid"] != strId) {
                newAllData.append(dictItem)
            }
        }
        
        // 是否還有資料
        if (newAllData.count < 1) {
            mFileMang.write(D_FILE_REPORT, strData: "")
        } else {
            mFileMang.write(D_FILE_REPORT, strData: mJSONClass.DictAryToJSONStr(newAllData))
        }
        
        dictRS["rs"] = true
        
        return dictRS
    }
    
}