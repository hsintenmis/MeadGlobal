//
// CollectionView,
//

import UIKit
import Foundation

/**
 * 檢測主頁面
 * 1.藍芽設備連接    2.會員選擇(USER資料輸入)
 * 3.測量完後檢測報告 4. 儲存
 */
class Testing: UIViewController {
    // @IBOutlet
    @IBOutlet weak var viewCollect: UICollectionView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 顏色
    let dictColor = ["white":"FFFFFF", "green":"99CC33", "red":"FF6666"]
    
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    /**
     * #package
     * CollectionView, 設定列數 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     * #package
     * CollectionView, 設定每列 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
    }
    
    /**
     * #package
     * CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let mCell: CellCollect = collectionView.dequeueReusableCellWithReuseIdentifier("cellCollect", forIndexPath: indexPath) as! CellCollect
        
        dispatch_async(dispatch_get_main_queue(), {
            mCell.btnName.setTitle("Item" + String(indexPath.row), forState: .Normal)
        })
        
        // 樣式/外觀/顏色
        //mCell.btnName.layer.borderWidth = 1
        mCell.btnName.layer.cornerRadius = 2
        mCell.btnName.backgroundColor = pubClass.ColorHEX(dictColor["white"])
        
        return mCell
    }

    /**
     * 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}