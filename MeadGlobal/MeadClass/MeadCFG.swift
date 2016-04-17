//
// 本專案 MEAD class 設定檔
//

import Foundation

/**
 * 本專案 MEAD class 設定檔
 */
class MeadCFG {
    /** 紀錄資料數值的 最小值 = 8 */
    let D_VALUE_MIN = 8;
    
    /** 最大的資料數值  = 200*/
    let D_VALUE_MAX = 200;
    
    /** 設備連線後,固定傳送數值 = 1*/
    let D_DEVICE_CONNVALUE = 1;
    
    /** 高低值與平均數的差距值 = 15 */
    let D_ENGVALUE_HIGHLOW_GAP = 15;
    
    /** [分析]報告最多取得n筆項目 */
    let D_REPORT_ANALY_MAXNUMS = 4;
    
    /** [商品]報告最多取得n筆項目 */
    let D_REPORT_PD_MAXNUMS = 1;
    
    /** 檢測儀的檢測項目總數 */
    let D_TOTDATANUMS = 24;
    
    // 身體部位,方向
    let aryBody = ["H", "F"]  // 手, 腳
    let aryDirection = ["L", "R"]  // 左, 右
    let intTestingNums = 6 // 身體部位, 方向 檢測點的數目
    
    /** 穴位固定顯示的順序格式, ex. {H1, H2, H3, ...., F5, F6} */
    let D_ARY_POINTCODE = ["H1", "H2", "H3", "H4", "H5", "H6", "F1", "F2", "F3", "F4", "F5", "F6"]
    
    /** MEAD 資料, 檢測項目的 id code 順序 */
    let D_ARY_MEADDBID = "H1L,H2L,H3L,H4L,H5L,H6L,H1R,H2R,H3R,H4R,H5R,H6R,F1L,F2L,F3L,F4L,F5L,F6L,F1R,F2R,F3R,F4R,F5R,F6R"
    
    /**
     * init
     */
    init() {
    }
    
    /**
     * 取得檢測項目 dictAllData, 共24筆資料
     *
     * 實際檢測時, 左手=>右手=>左腳=>右腳<br>
     * L-H1, L-H2, L-H6, R-H1, ... L-F1, ...<BR>
     *
     * 檢測資料 Dict data, Array<Dictionary<String, String>>
     * 資料設定如下<br>
     * id : 檢測項目的辨識 id, ex. H1, H2 ...<br>
     * body : 身體部位, ex. 'H' or 'F'<BR>
     * direction : 左右, ex. L or R ...<br>
     * val : 檢測值, 預設 0, String 型態<br>
     * serial : 身體與方向 目前序號, 1 ~ 6<br>
     *
     * @return Array<Dictionary<String, String>>
     */
    func getAryAllTestData()->Array<Dictionary<String, String>> {
        var aryAllTestData: Array<Dictionary<String, String>> = []
        
        // 身體部位先開始
        for i in (0..<aryBody.count) {
            // 左右
            for j in (0..<aryDirection.count) {
                // 檢測點的數目
                for k in (0..<intTestingNums) {
                    var dictItem: Dictionary<String, String> = [:]
                    dictItem["serial"] = String(k + 1)
                    dictItem["id"] = aryBody[i] + dictItem["serial"]!
                    dictItem["body"] = aryBody[i]
                    dictItem["direction"] = aryDirection[j]
                    dictItem["val"] = "0"
                    
                    aryAllTestData.append(dictItem)
                }
            }
        }
        
        return aryAllTestData
    }
    
}