//
// JSON 相關公用程式
//

import Foundation

/**
 * 本專案會員的設定檔與公用 method
 */
class JSONClass {
    let isDebug = false
    
    /**
     * init
     */
    init() {
    }
 
    /**
     * JSON string 轉為 Array
     */
    func JSONStrToAry(strJSON: String)->Array<AnyObject> {
        var aryRS: Array<AnyObject> = []
        
        do {
            let mNSData: NSData = strJSON.dataUsingEncoding(NSUTF8StringEncoding)!
            let jobjRoot = try NSJSONSerialization.JSONObjectWithData(mNSData, options:NSJSONReadingOptions(rawValue: 0))
            
            guard let tmpAllData = jobjRoot as? Array<AnyObject> else {
                return aryRS
            }
            
            aryRS = tmpAllData
        }
        catch let err as NSError {
            if (isDebug) {print("err_data:\n\(err)")}
            return aryRS
        }
        
        return aryRS
    }
    
    /**
     * JSON string 轉為 Dictionary
     */
    func JSONStrToDict(strJSON: String)->Dictionary<String, AnyObject> {
        var aryRS: Dictionary<String, AnyObject> = [:]
        
        do {
            let mNSData: NSData = strJSON.dataUsingEncoding(NSUTF8StringEncoding)!
            let jobjRoot = try NSJSONSerialization.JSONObjectWithData(mNSData, options:NSJSONReadingOptions(rawValue: 0))
            
            guard let tmpAllData = jobjRoot as? Dictionary<String, AnyObject> else {
                return aryRS
            }
            
            aryRS = tmpAllData
        } catch let err as NSError {
            if (isDebug) {print("err_data:\n\(err)")}
        }
        
        return aryRS
    }
    
    
    /**
     * Dictionary | Array 轉為 JSON string
     */
    func DictAryToJSONStr(mData: AnyObject)->String {
        var strJSON = ""
        
        do {
            let jsonData = try
                NSJSONSerialization.dataWithJSONObject(mData, options: NSJSONWritingOptions(rawValue: 0))
            strJSON = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
        } catch let err as NSError {
            if (isDebug) {print("err_data:\n\(err)")}
        }
        
        return strJSON
    }
    
}