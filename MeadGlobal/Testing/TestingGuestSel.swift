//
// UIPickerView, 點取 edittext, 彈出虛擬鍵盤視窗為 PickerView
//

import UIKit
import Foundation

/**
 * 受測者身份 - 訪客資料輸入頁面
 */
class TestingGuestSel: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // @IBOutlet
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var edAge: UITextField!
    @IBOutlet weak var swchGender: UISegmentedControl!
    @IBOutlet weak var btnStart: UIButton!
    
    // common property
    private var pubClass = PubClass()
    
    // 受測者資料 array data
    private var dictUser: Dictionary<String, String> = [:]
    
    // UIPickerView 設定
    private var aryPickerData: Array<String> = []
    private let mPickerView:UIPickerView = UIPickerView()
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定頁面語系
        self.setPageLang()
        
        // PickerView 初始設定, 點取 'edAge' 彈出 PickerView 視窗取代 '鍵盤視窗'
        initPickDateView()
    }
    
    /**
     * 設定頁面語系
     */
    private func setPageLang() {
        swchGender.setTitle(pubClass.getLang("gender_M"), forSegmentAtIndex: 0)
        swchGender.setTitle(pubClass.getLang("gender_F"), forSegmentAtIndex: 1)
        
        labName.text = pubClass.getLang("member_guestname")
        edAge.placeholder = pubClass.getLang("inputage")
        btnStart.setTitle(pubClass.getLang("starttesting"), forState: UIControlState.Normal)
    }
    
    /**
     * 'Age' 欄位，Picker 初始設定
     */
    private func initPickDateView() {
        mPickerView.delegate = self
        initInputViewTopBar()
        
        for i in (17..<120) {
            aryPickerData.append(String(i))
        }
        
        edAge.inputView = mPickerView
        mPickerView.selectRow(30, inComponent: 0, animated: false)
    }
    
    /**
     * edit 點取彈出 資料輸入視窗 (虛擬鍵盤), 'InputView' 的頂端顯示 'navyBar'
     */
    private func initInputViewTopBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true  // 半透明
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)  // 文字顏色
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: pubClass.getLang("btnact_done"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.PickerDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: pubClass.getLang("cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.PickerCancel))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        edAge.inputAccessoryView = toolBar
    }
    
    /**
     * Picker 點取　'done'
     */
    @objc private func PickerDone() {
        self.edAge.resignFirstResponder()
        
        // 取得 picker 選擇的 position
        let strAge = self.aryPickerData[self.mPickerView.selectedRowInComponent(0)]
        self.edAge.text = strAge
        dictUser["age"] = strAge
    }
    
    /**
     * Picker 點取　'cancel'
     */
    @objc private func PickerCancel() {
        self.edAge.resignFirstResponder()
    }
    
    /** 
     * #mark: UIPickerViewDataSource
     * Components 數量
     */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     * #mark: UIPickerViewDataSource
     * 指定 Components 內的 item 數量
     */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return aryPickerData.count
    }
    
    /**
     * #mark: UIPickerViewDataSource
     * 指定 Components 內的 item 顯示名稱
     */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return aryPickerData[row]
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdnt = segue.identifier
        
        if (strIdnt == "BLEMeadMain") {
            let mVC = segue.destinationViewController as! BLEMeadMain
            mVC.dictUser = dictUser

            return
        }
        
        return
    }
    
    /**
    * Action, 點取 '開始檢測'
    */
    @IBAction func actSubmit(sender: UIButton) {
        // 檢查必要傳送資料
        dictUser["id"] = ""
        dictUser["name"] = labName.text!
        dictUser["age"] = edAge.text!
        dictUser["gender"] = (swchGender.selectedSegmentIndex == 0) ? "M" : "F"
        
        if (dictUser["age"]?.characters.count < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_userage"))
            
            return
        }

        // 跳轉 Segue
        self.performSegueWithIdentifier("BLEMeadMain", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}