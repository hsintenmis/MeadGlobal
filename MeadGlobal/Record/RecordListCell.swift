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
    
    private var pubClass = PubClass()
    
    /**
     * 設定 IBOutlet value
     */
    func initView(dictItem: Dictionary<String, String>!) {
        labDate.text = pubClass.formatDateWithStr(dictItem["sdate"], type: "8s")
        labAvg.text = dictItem["avg"]
        labAvgH.text = dictItem["avgH"]
        labAvgL.text = dictItem["avgL"]
    }
    
}