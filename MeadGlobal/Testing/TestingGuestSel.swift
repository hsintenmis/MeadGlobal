//
// UIPickerView, 點取 edittext, 彈出虛擬鍵盤視窗為 PickerView
//

import UIKit
import Foundation

/**
 * 進入檢測程序前，顯示訪客資料輸入頁面
 */
class TestingGuestSel: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // @IBOutlet
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var edAge: UITextField!
    @IBOutlet weak var labAge: UILabel!
    @IBOutlet weak var swchGender: UISegmentedControl!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 受測者資料 array data
    var dictUser: Dictionary<String, String> = [:]
    
    // UIPickerView 設定
    private var aryPickerData: Array<String> = []
    private let mPickerView:UIPickerView = UIPickerView()
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 設定頁面語系
        self.setPageLang()
        
        // PickerView 初始設定, 點取 'edAge' 彈出 PickerView 視窗取代 '鍵盤視窗'
        initAgePickDateView()
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        
    }
    
    /**
     * 設定頁面語系
     */
    private func setPageLang() {
        labAge.text = pubClass.getLang("age")
        swchGender.setTitle(pubClass.getLang("gender_M"), forSegmentAtIndex: 0)
        swchGender.setTitle(pubClass.getLang("gender_F"), forSegmentAtIndex: 1)
    }
    
    /**
     * 'Age' 欄位，Picker 初始設定
     */
    private func initAgePickDateView() {
        mPickerView.delegate = self
        initInputViewTopBar()
        
        for (var i=17; i<=100; i++) {
            aryPickerData.append(String(i))
        }
        
        edAge.inputView = mPickerView
        mPickerView.selectRow(18, inComponent: 0, animated: false)
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
        
        let doneButton = UIBarButtonItem(title: pubClass.getLang("btnact_done"), style: UIBarButtonItemStyle.Plain, target: self, action: "PickerDone")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: pubClass.getLang("cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: "PickerCancel")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        edAge.inputAccessoryView = toolBar
    }
    
    /**
     * Picker 點取　'done'
     */
    @objc private func PickerDone() {
        self.edAge.resignFirstResponder()
        
        // edAge 顯示文字
        dispatch_async(dispatch_get_main_queue(), {
            self.edAge.text = self.aryPickerData[self.mPickerView.selectedRowInComponent(0)]
        })
    }
    
    /**
     * Picker 點取　'cancel'
     */
    @objc private func PickerCancel() {
        self.edAge.resignFirstResponder()
    }
    
    /** Start mMark: UIPickerViewDelegate **/
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return aryPickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return aryPickerData[row]
    }
    /** End mMark: UIPickerViewDelegate **/
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdnt = segue.identifier
        
        if (strIdnt == "TestingGuestSel") {
            let vcChild = segue.destinationViewController as! BLEMeadMain
            vcChild.dictUser = dictUser

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
        
        if (dictUser["age"]!.isEmpty) {
            pubClass.popIsee(Msg: pubClass.getLang("err_userage"))
            return
        }
        
        // 手動執行 Segue
        self.performSegueWithIdentifier("TestingGuestSel", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}