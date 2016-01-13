//
// 會員公用程式
//
// 專案進入頁面，必須使用 'chkData' 檢查是否有會員與初始資料
// 流水號記錄檔 max 六碼，1 ~ 999999
//

import Foundation

/**
 * 本專案會員的設定檔與公用 method
 */
class MemberClass {
    private let isDebug = true
    
    /** 會員資料檔 JSON string, 檔名: member.txt */
    let D_FILE_MEMBER = "member.txt"
    
    /** 會員編號 流水號記錄檔 */
    let D_FILE_MEMBER_SERIAL = "member_serial.txt"
    
    /** 會員資料，唯一識別碼前置字串，ex. 'MD' + '000001' */
    let D_IDHEAD = "MD"
    
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
    }
    
    /**
     * 檢查是否首次使用，初始資料
     *
     * @return Boolean
     */
    func chkData()->Bool {
        // 檢查 '會員資料檔'
        if (!mFileMang.isFilePath(D_FILE_MEMBER)) {
            let bolRS0 = mFileMang.write(D_FILE_MEMBER, strData: "")
            if (isDebug) {print("create file \(D_FILE_MEMBER): \(bolRS0)")}
            
            if (!bolRS0) {
                return false
            }
        }
        
        // 檢查 '流水號記錄檔'
        if (!mFileMang.isFilePath(D_FILE_MEMBER_SERIAL)) {
            let bolRS1 = mFileMang.write(D_FILE_MEMBER_SERIAL, strData: "1")
            if (isDebug) {print("create file \(D_FILE_MEMBER): \(bolRS1)")}
            
            if (!bolRS1) {
                return false
            }
        }
        
        return true
    }
    
    /**
     * 取得會員編號'流水號', 6碼 String
     *
     * @return String : ex. 00000001, "" = false
     */
    private func getSerial()->String {
        let strSerial = mFileMang.read(D_FILE_MEMBER_SERIAL)
        
        if (strSerial.isEmpty) {
            return strSerial
        }
        
        return String(format: "%06d", Int(strSerial)!)
    }
    
    /**
     * 會員編號 流水號記錄檔 count++
     * 
     * @return String: "" = true or err code
     */
    private func updateSerial()->String {
        let strSerial = mFileMang.read(D_FILE_MEMBER_SERIAL)
        
        if (strSerial.isEmpty) {
            return "err_memberclass_updateSerial"
        }

        mFileMang.write(D_FILE_MEMBER_SERIAL, strData: String(Int(strSerial)! + 1))
        
        return ""
    }
    
    /**
     * 取得全部會員資料 Array data
     *
     * @param isSortASC: false(預設), 資料反向整理，新資料在前
     */
    func getAll(isSortASC isASC: Bool)->Array<Dictionary<String, String>> {
        var aryAllData: Array<Dictionary<String, String>> = []
        let strJSON = mFileMang.read(D_FILE_MEMBER)
        
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
     * 取得指定會員資料 Dictionary data
     *
     * @param strId: 會員編號
     * @return nil or Dictionary<String, String>
     */
    func getSingle(strId: String!)->AnyObject {
        let dictEmpty: Dictionary<String, String> = [:]
        let strJSON = mFileMang.read(D_FILE_MEMBER)
        
        if (strJSON.isEmpty) {
            return dictEmpty
        }
        
        // loop all data, 比對指定會員 id 修改資料
        let aryAllData: Array<Dictionary<String, String>> = self.getAll(isSortASC: true)
        for dictItem in aryAllData {
            if (dictItem["id"] == strId) {
                return dictItem
            }
        }
        
        return dictEmpty
    }
    
    /**
     * 會員新增(會員資料檔必定存在)
     *
     * @param dictData: 會員資料
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
        
        dictRS["rs"] = mFileMang.write(D_FILE_MEMBER, strData: mJSONClass.DictAryToJSONStr(aryAllData))
        
        if (dictRS["rs"] as! Bool != true) {
            return dictRS
        }
        
        self.updateSerial()
        
        return dictRS
    }
    
    /**
     * 會員資料更新
     *
     * @param dictData: 會員資料(包含會員ID)
     * @return Dict: 'rs'=Bool, 'err'='' or error msg
     */
    func update(dictData: Dictionary<String, String>!)->Dictionary<String, AnyObject> {
        var dictRS: Dictionary<String, AnyObject> = ["rs": false, "err": ""]
    
        // 指定 id 的資料是否存在
        if (self.getSingle(dictData["id"]).count < 1) {
            dictRS["err"] = "err_memberclass_datanotexists"
            
            return dictRS
        }
        
        // loop all data, 比對指定會員 id 取代資料
        let aryAllData = self.getAll(isSortASC: true)
        var newAllData: Array<Dictionary<String, String>> = []
        
        for dictItem in aryAllData {
            if (dictItem["id"] == dictData["id"]) {
                newAllData.append(dictData)
            } else {
                newAllData.append(dictItem)
            }
        }
        
        // 寫入檔案
        let bolRS = mFileMang.write(D_FILE_MEMBER, strData: mJSONClass.DictAryToJSONStr(newAllData))
        if (!bolRS) {
            dictRS["err"] = "err_memberclass_update"
            
            return dictRS
        }
        
        dictRS["rs"] = true
        
        return dictRS
    }
    
    /**
     * 會員刪除
     *
     * @param dictData: 會員ID
     * @return Dict: 'rs'=Bool, 'err'='' or error msg
     */
    func del(strId: String!)->Dictionary<String, AnyObject> {
        var dictRS: Dictionary<String, AnyObject> = ["rs": false, "err": ""]
        
        // 指定 id 的資料是否存在
        if (self.getSingle(strId).count < 1) {
            dictRS["err"] = "err_memberclass_datanotexists"
            
            return dictRS
        }
        
        // loop all data, 比對指定會員 id 跳過該筆資料
        let aryAllData = self.getAll(isSortASC: true)
        var newAllData: Array<Dictionary<String, String>> = []
        
        for dictItem in aryAllData {
            if (dictItem["id"] != strId) {
                newAllData.append(dictItem)
            }
        }
        
        // 是否還有資料
        if (newAllData.count < 1) {
            mFileMang.write(D_FILE_MEMBER, strData: "")
        } else {
            mFileMang.write(D_FILE_MEMBER, strData: mJSONClass.DictAryToJSONStr(newAllData))
        }
        
        dictRS["rs"] = true
        
        return dictRS
    }
    
    /**
    * 根據生日 YMD 取得年齡
    *
    * @param strBirth: ex. 20000131 八碼
    */
    func getBirthToAge(strBirth: String?)->String! {
        var strAge = ""
        
        if let mBirth = strBirth {
            if (mBirth.characters.count == 8) {
                strAge = String(Int(pubClass.subStr(strToday, strFrom: 0, strEnd: 4))! - Int(pubClass.subStr(mBirth, strFrom: 0, strEnd: 4))!)
            }
        }
        
        return strAge
    }
    
}