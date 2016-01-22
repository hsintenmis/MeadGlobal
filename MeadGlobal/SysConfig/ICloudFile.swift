//
// iCloud , https://github.com/binaryghost/DocPick
//

import Foundation
import UIKit

class ICloudFile: UIViewController, UIDocumentPickerDelegate {
    // @IBOutlet
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // common property
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        

    }
    
    override func viewDidAppear(animated: Bool) {
        let mDocumentPicker = UIDocumentPickerViewController(documentTypes: ["public.text", "public.image"], inMode: UIDocumentPickerMode.Import)
        mDocumentPicker.delegate = self
        
        mDocumentPicker.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.presentViewController(mDocumentPicker, animated: true, completion: {})
    }
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        print(url)
    }
    
}