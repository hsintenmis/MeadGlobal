//
// CollectionView,
//

import UIKit
import Foundation

/**
 * 檢測儀檢測 主頁面
 * 1.藍芽設備連接    2.會員選擇(USER資料輸入)
 * 3.測量完後檢測報告 4. 儲存
 */
class BLEMeadMain: UIViewController, BLEMeadServiceDelegate {
    // @IBOutlet
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labGender: UILabel!
    @IBOutlet weak var imgBody: UIImageView!
    @IBOutlet weak var viewCollect: UICollectionView!
    
    @IBOutlet weak var labBTMsg: UILabel!
    @IBOutlet weak var labPointMsg: UILabel!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    /* public property, 由 parent segue 設定 */
    // 受測者資料，存檔至檢測數值DB, key: id, name, age, gender
    var dictUser: Dictionary<String, String> = [:]
    
    // var 檢測數值 array data, 從 MeadConfig 初始取得
    var aryTestingData: Array<Dictionary<String, String>> = []
    
    // 目前檢測資料的 position, 與 CollectionView 的 position 一樣
    var currDataPosition = 0;
    var currIndexPath = NSIndexPath(forRow: 0, inSection:0)
    
    // 顏色
    private let dictColor = ["white":"FFFFFF", "red":"FFCCCC", "gray":"C0C0C0", "silver":"F0F0F0", "blue":"66CCFF", "black":"000000"]
    
    // 其他 class, property
    private var mBLEMeadService: BLEMeadService!
    private var mMeadConfig: MeadConfig! // MEAD 設定檔
    private let mFileMang = FileMang()
    private var strToday: String!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        mBLEMeadService = BLEMeadService()
        mMeadConfig = MeadConfig(ProjectPubClass: pubClass)
        
        // Mead, 其他 相關資料初始
        setUserView()
        
        // 檢測數值 array data 初始與產生
        aryTestingData = mMeadConfig.getAryAllTestData()
        
        // 開始連接藍芽設備
        mBLEMeadService.mBLEMeadServiceDelegate = self
        mBLEMeadService.startUpCentralManager()
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        viewCollect.reloadData()
    }
    
    /**
    * 設定上方受測者 View
    */
    private func setUserView() {
        labName.text = dictUser["name"]
        let strGender = pubClass.getLang("gender_" + (dictUser["gender"])!)
        labGender.text = pubClass.getLang("gender") + ": " + strGender + ", " + pubClass.getLang("age") + ": \(dictUser["age"]! as String)"
        
        // user 圖片
        let imgFileName = dictUser["id"]! + ".png"
        let mImg = (mFileMang.isFilePath(imgFileName)) ? UIImage(contentsOfFile: self.mFileMang.mDocPath + imgFileName) : UIImage(named: pubClass.D_DEFPICTUSER )
        imgUser.image = mImg
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
        mCell.labName.text = strItemName
        
        // 樣式/外觀/顏色
        mCell.layer.cornerRadius = 2
        
        if (indexPath == currIndexPath) {
            mCell.backgroundColor = pubClass.ColorHEX(dictColor["blue"])
        }
        else {
            mCell.backgroundColor = pubClass.ColorHEX(dictColor["gray"])
        }
        
        return mCell
    }
    
    /**
     * #mark, CollectionView, Cell 點取, 檢測項目的 scroll item
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        currDataPosition = indexPath.row
        let dictItem = aryTestingData[currDataPosition]
        //print(dictItem)
        
        // 設定穴位圖片, 圖片路徑 'pict_testing', 圖片名稱 ex. F1_R_P.jpg
        let strPict = dictItem["id"]! + "_" + dictItem["direction"]! + "_P.jpg"
        imgBody.image = UIImage(named: "pict_testing/" + strPict)
        
        // 設定目前的 indexPath
        currIndexPath = indexPath
        viewCollect.reloadData()
    }
    
    /**
    * CollectionView 移動到指定的 position cell
    */
    private func moveCollectCell(mRow: Int) {
        let mIndex = NSIndexPath(forRow: mRow, inSection:0)
        self.collectionView(viewCollect, didSelectItemAtIndexPath: mIndex)
        viewCollect.scrollToItemAtIndexPath(mIndex, atScrollPosition: .CenteredHorizontally, animated: true)
        viewCollect.reloadData()
    }
    
    /**
     * #mark: 自訂 Delegate, BLEMeadServiceDelegate
     * 
     * 接收藍芽設備 handler
     * BLEMeadService protocol, 實作 method
     */
    func handlerBLEMeadService(mBLEMeadService: BLEMeadService, identCode: String!, result: Bool!, msgCode: String!) {
        
        switch (identCode) {
        case "BT_statu":
            print(identCode + ":" + msgCode)
            break
        default:
            break
        }
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