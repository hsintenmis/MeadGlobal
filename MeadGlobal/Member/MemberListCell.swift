//
// TableView cell
//

import Foundation
import UIKit

/**
 * 會員列表 Table Cell
 */
class MemberListCell: UITableViewCell {
    
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labTel: UILabel!
    @IBOutlet weak var labGender: UILabel!
    @IBOutlet weak var imgPict: UIImageView!
    
    private var pubClass = PubClass()
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, mMemberClass: MemberClass!) {
        labName.text = ditItem["name"] as? String
        labId.text = pubClass.getLang("member_id") + ": " + (ditItem["id"] as! String)
        labTel.text = pubClass.getLang("tel") + ": " + (ditItem["tel"] as! String)
        
        // 性別
        let strGender = pubClass.getLang("gender_" + (ditItem["gender"] as! String))
        
        // 年齡
        var strAge = mMemberClass.getBirthToAge(ditItem["birth"] as? String)
        if (strAge == "") {
            strAge = "--"
        }
        
        // 顯示性別年齡
        labGender.text = pubClass.getLang("gender") + ": " + strGender + ", " + pubClass.getLang("age") + ": " + strAge
        
        // 圖片設定
        imgPict.image = mMemberClass.getMemberPict(ditItem["id"] as! String)
    }
    
}