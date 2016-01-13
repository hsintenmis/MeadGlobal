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
class TestingMain: UIViewController {
    // @IBOutlet
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labGender: UILabel!
    
    @IBOutlet weak var imgBody: UIImageView!
    
    
    @IBOutlet weak var viewCollect: UICollectionView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // public property, 由 parent segue 設定
    var dictUser: Dictionary<String, String> = [:]  // id, name, age, gender
    
    // var 檢測數值 array data, 從 MeadConfig 初始取得
    var aryTestingData: Array<Dictionary<String, String>> = []
    
    // 目前檢測資料的 position, 與 CollectionView 的 position 一樣
    var currDataPosition = 0;
    
    // 顏色
    let dictColor = ["white":"FFFFFF", "green":"99CC33", "red":"FF6666"]
    
    // 其他 class
    private var mMeadConfig: MeadConfig!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // Mead 相關資料初始
        mMeadConfig = MeadConfig(ProjectPubClass: pubClass)
        aryTestingData = mMeadConfig.getAryAllTestData()
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        viewCollect.reloadData()
    }
    
    /**
     * #mark: CollectionView, 檢測項目, 設定列數 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     * #mark: CollectionView, 檢測項目, 設定每列 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
    }
    
    /**
     * #mark, CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let mCell: CellCollect = collectionView.dequeueReusableCellWithReuseIdentifier("cellCollect", forIndexPath: indexPath) as! CellCollect
        
        let dictItem = aryTestingData[indexPath.row]
        let strItemName = pubClass.getLang("mead_body_" + (dictItem["body"]! + dictItem["direction"]!)) + " " + dictItem["serial"]!
        
        dispatch_async(dispatch_get_main_queue(), {
            mCell.labName.text = strItemName
        })
        
        // 樣式/外觀/顏色
        mCell.layer.cornerRadius = 2
        mCell.backgroundColor = pubClass.ColorHEX(dictColor["red"])
        
        return mCell
    }
    
    /**
     * #mark, CollectionView, Cell 點取
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        currDataPosition = indexPath.row
        let dictItem = aryTestingData[currDataPosition]
        //print(dictItem)
        
        // 設定身體圖片, ex. F1_R_P.jpg
        let strPict = dictItem["id"]! + "_" + dictItem["direction"]! + "_P.jpg"
        print(strPict)
        
        let image1 = UIImage(named: strPict)
        imgBody = UIImageView(image: image1)
        
        //imgBody.image = UIImage(named: strPict)
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