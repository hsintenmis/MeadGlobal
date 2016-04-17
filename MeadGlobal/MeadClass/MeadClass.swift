//
// Mead 主 class
//

import Foundation

/**
 * 本專案 MEAD 主 class
 *
 * 檢測儀相關數值與邏輯運算定義
 * 1. 穴位有左右手腳各6個穴點, 總共有 2*2*6 = 24個值
 *
 * 2. 順序為 手 => 腳, 左 => 右 2. 檢測儀傳入的數值,
 *       需要:
 *         a.取得出現次數最多的值
 *         b.最多的值需要出現n次
 * 3. 數值分析判定:低,正常,高, 分析後取得對應的檢測說明文字
 *
 * 4. 平均值取得方式, 全部數值加總平均, +- 15 為最高最低值
 *
 * 5. 判定需要作[學理分析報告],僅取出單一數值超標的前四個,僅按順序排列
 *
 * 6. 各項分析報告總共有 12 項, 代碼 H1 ~ H6, F1 ~ F6
 *
 * 7. 檢測數值資料存檔, 以 JSONArray => JSONObj0, JSONObj1 ... 儲存
 *
 * 8. 檢測報告文字檔代碼, 根據原始 VB 程式碼代碼表示意義如下
 *    代碼左右數字表示左右邊, 1 = 低, 0 = 正常, 2 = 高
 *    10 :  左低
 *    01 :  右低
 *    11 :  左右低
 *    20 :  左高
 *    02 :  右高
 *    22 :  左右高
 *    12 :  左低右高
 *    21 :  左高右低
 */
class MeadClass {
    // 其他 class
    private var mMeadCFG = MeadCFG()
    private var pubClass = PubClass()
    
    /**
     * init
     */
    init() {
    }
    
    /**
     * 取得檢測數值的 平均值, 高標值, 低標值
     *
     * @param aryData: Array<Dictionary<String, String>>, 檢測資料
     *
     * @return Dictionary<String, Integer>, ex. <br>
     *         "avg" => 30, "avgH" => 45, "avgL" => 60
     */
    func GetAvgValue(aryData:Array<Dictionary<String, String>>!)->Dictionary<String,Int> {
        
        var avg = 0, avgH = 0, avgL = 0
        var totVal = 0
        
        // loop data, 加總 val
        for dictItem in aryData {
            totVal += Int(dictItem["val"]!)!
        }
        
        // 取得avg, 高低標數值
        avg = Int(totVal / (mMeadCFG.D_TOTDATANUMS))
        avgL = (avg - mMeadCFG.D_ENGVALUE_HIGHLOW_GAP)
        if (avgL <= mMeadCFG.D_VALUE_MIN) {
            avgL = mMeadCFG.D_VALUE_MIN
        }
        
        avgH = (avg + mMeadCFG.D_ENGVALUE_HIGHLOW_GAP)
        if (avgH >= (mMeadCFG.D_VALUE_MAX - 1)) {
            avgH = (mMeadCFG.D_VALUE_MAX - 1)
        }
        
        return ["avg":avg, "avgH":avgH, "avgL":avgL]
    }
    
    /**
     * 取得檢測數值有問題的 '代碼', ex. F522,F222
     *
     * @param aryData: Array<Dictionary<String, String>>, 檢測資料
     *
     * @return String: "" or "F522,F222, ..."
     */
    func GetProblemItem(aryData:Array<Dictionary<String, String>>!)->String {
        let dictAVG = self.GetAvgValue(aryData)
        var strRS = ""
        var intVal = 0
        var strKey = ""
        
        // 暫存排序的資料, ex. ary["P_key"] = [id:"H1", "L"=20, "R"=1,]
        var tmpSortDict: Dictionary<String, Dictionary<String, AnyObject>> = [:]
        var tmpItem: Dictionary<String, AnyObject> = [:]
        
        // loop data
        for i in (0..<mMeadCFG.D_TOTDATANUMS) {
            var intAbs = 0  // 高低標差距值
            var intLRval = 0 // ex. L: 10, R: 2
            let dictItem = aryData[i]
            intVal = Int(dictItem["val"]!)!
            
            // 產生可排序的 'key'
            if (intVal > dictAVG["avgH"]) {
                intAbs = abs(intVal - dictAVG["avgH"]!)
                intLRval = (dictItem["direction"] == "L") ? 20 : 2
            }
            else if (intVal < dictAVG["avgL"]) {
                intAbs = abs(intVal - dictAVG["avgL"]!)
                intLRval = (dictItem["direction"] == "L") ? 10 : 1
            }
            
            if (intLRval > 0) {
                tmpItem["id"] = dictItem["id"]
                tmpItem["stat"] = intLRval
                
                strKey = "P" + String(format: "%03d", intAbs) + dictItem["direction"]!
                tmpSortDict[strKey] = tmpItem
            }
        }
        
        // 無資料直接返回
        if (tmpSortDict.count < 1) { return strRS }
        
        // Dictionary 排序, 重新產生 array data
        let arySortedDict = tmpSortDict.sort { $0.0 > $1.0 }
        var aryNewData: Array<Dictionary<String, AnyObject>> = []
        
        for aryItem in arySortedDict {
            var dictVal = aryItem.1
            tmpItem = [:]
            
            // 比對 id 是否重複
            tmpItem["id"] = dictVal["id"] as! String
            //tmpItem["stat"] = dictVal["stat"] as! Int
            
            if (aryNewData.count > 0) {
                var hasData = false
                
                for i in (0..<aryNewData.count) {
                    let tmpItem1 = aryNewData[i]
                    if (tmpItem1["id"] as! String == tmpItem["id"] as! String) {
                        aryNewData[i]["stat"] = (tmpItem1["stat"] as! Int) + (dictVal["stat"] as! Int)
                        
                        hasData = true
                    }
                }
                
                if (!hasData) {
                    tmpItem["stat"] = dictVal["stat"] as! Int
                    aryNewData.append(tmpItem)
                }
            }
            else {
                tmpItem["stat"] = dictVal["stat"] as! Int
                aryNewData.append(tmpItem)
            }
        }
        
        // 產生回傳 String
        for i in (0..<aryNewData.count) {
            let strHead = aryNewData[i]["id"] as! String
            let strStat = String(format: "%02d", aryNewData[i]["stat"] as! Int)
            
            strRS += strHead + strStat
            
            if (i < (aryNewData.count - 1)) { strRS += "," }
        }
        
        return strRS
    }
    
}