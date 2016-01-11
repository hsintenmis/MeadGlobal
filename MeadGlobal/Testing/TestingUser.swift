//
// 點取 textView 顯示 PickView 選擇年齡
// 

import UIKit
import Foundation

/**
 * 檢測進入首頁，先設定受測者資料
 */
class TestingUser: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    // @IBOutlet
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var swchGender: UISegmentedControl!
    @IBOutlet weak var edAge: UITextField!
    @IBOutlet weak var pickAge: UIPickerView!
    @IBOutlet weak var btnClosePick: UIButton!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // public, 目前user身份, 'guest' or 'member'
    var strMemberType = "guest"  //
    
    // public, 受測者資料 user data, 傳送給檢測主頁面
    var dictUser: Dictionary<String, String> = ["id":"", "name":"guest", "age":"0", "gender":"M"]
    
    // pickView 設定
    private var pickData: Array<String> = [] // 年齡 string, 18~120
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // IBOutlet 顯示狀態
        btnClosePick.hidden = true
        pickAge.hidden = true
        
        // pickView 設定
        self.pickAge.dataSource = self
        self.pickAge.delegate = self
        
        for (var i=18; i<=120; i++) {
            pickData.append(String(i))
        }
        pickAge.selectRow(17, inComponent: 0, animated: false)
        
        // textView age, 其他 prpoerty
        edAge.delegate = self
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
        // 根據目前 user type, 設定頁面內容
        if (strMemberType == "guest") {
            dictUser = ["id":"", "name":pubClass.getLang("member_guestname"), "age":"", "gender":""]
            swchGender.enabled = true
        }
        else {
            swchGender.enabled = false
            swchGender.selectedSegmentIndex = (dictUser["gender"] == "M") ? 0 : 1
        }
        
        labName.text = dictUser["name"]
        edAge.text = dictUser["age"]
    }
    
    /** Start #mark: UIPickerView Delegate **/
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickData.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        edAge.text = pickData[row]
    }
    /** End #mark: UIPickerView Delegate **/
    
    /**
     * #mark: UITextField Delegate
     * Action, 點取 '年齡' TextView
     */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // 訪客需要設定年齡, 顯示 picker
        if (strMemberType == "guest") {
            pickAge.hidden = false
            btnClosePick.hidden = false
        }
        
        return false
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        // 選擇會員 segue
        if (strIdentName == "TestingMemberSel") {
            let cvChild = segue.destinationViewController as! TestingMemberSel
            cvChild.mParentClass = self
            
            return
        }
        
        return
    }
    
    /**
     * Action, 點取'訪客'
     */
    @IBAction func actGuest(sender: UIButton) {
    }
    
    /**
     * Action, 關閉 pickview
     */
    @IBAction func actClosePick(sender: UIButton) {
        pickAge.hidden = true
        btnClosePick.hidden = true
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