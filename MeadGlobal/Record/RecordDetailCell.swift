//
//  Cell @IBOutlet
//

import Foundation
import UIKit

/**
 * 能量檢測分析文字說明, TableView Cell IBOutlet
 */
class RecordDetailCell: UITableViewCell {
    
    @IBOutlet weak var labTitle: UILabel!
    @IBOutlet weak var labMsg: UILabel!
    
    @IBOutlet weak var labL_val: UILabel!
    @IBOutlet weak var img_L: UIImageView!
    @IBOutlet weak var labL_avg: UILabel!
    
    @IBOutlet weak var labR_val: UILabel!
    @IBOutlet weak var img_R: UIImageView!
    @IBOutlet weak var labR_avg: UILabel!
    
    @IBOutlet weak var view_L: UIView!
    @IBOutlet weak var view_R: UIView!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(dictItem: Dictionary<String, String>!) {
        labTitle.text = dictItem["title"]
        labMsg.text = dictItem["msg"]
        labL_avg.text = dictItem["avg"]
        labR_avg.text = dictItem["avg"]
        labL_val.text = dictItem["val_L"]
        labR_val.text = dictItem["val_R"]
        
        // 判斷使否要顯示 左右數值
        if (dictItem["val_L"] == "") {
            view_L.alpha = 0.0
        } else {
            view_L.alpha = 1.0
            img_L.image = UIImage(named: dictItem["img_L"]!)
        }
        
        if (dictItem["val_R"] == "") {
            view_R.alpha = 0.0
        } else {
            view_R.alpha = 1.0
            img_R.image = UIImage(named: dictItem["img_R"]!)
        }
    }
}