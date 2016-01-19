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
}