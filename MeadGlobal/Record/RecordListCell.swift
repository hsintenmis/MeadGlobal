//
// UITableViewCell
//

import Foundation
import UIKit

class RecordListCell: UITableViewCell {
    
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labAvg: UILabel!
    @IBOutlet weak var labAvgH: UILabel!
    @IBOutlet weak var labAvgL: UILabel!
    @IBOutlet weak var labTitleAvg: UILabel!
    @IBOutlet weak var labTitleH: UILabel!
    @IBOutlet weak var labTitleL: UILabel!
    
    private var pubClass = PubClass()
    
    /**
     * 設定 IBOutlet value
     */
    func initView(dictItem: Dictionary<String, String>!) {
        labDate.text = pubClass.formatDateWithStr(dictItem["sdate"], type: "8s")
        labAvg.text = dictItem["avg"]
        labAvgH.text = dictItem["avgH"]
        labAvgL.text = dictItem["avgL"]
        
        labTitleAvg.text = pubClass.getLang("cellmead_avg")
        labTitleH.text = pubClass.getLang("cellmead_h")
        labTitleL.text = pubClass.getLang("cellmead_l")
    }
    
}