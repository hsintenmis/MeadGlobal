//
// iCloud class
//

import UIKit

class FileiCloud {

    let mFileMgr = NSFileManager.defaultManager()
    let mSaveFileName = "member.txt"
    
    var ubiquityURL: NSURL?
    var metaDataQuery: NSMetadataQuery?
    
    init() {
        ubiquityURL = mFileMgr.URLForUbiquityContainerIdentifier(nil)!.URLByAppendingPathComponent("Documents")
        ubiquityURL = ubiquityURL!.URLByAppendingPathComponent(mSaveFileName)
        
        metaDataQuery = NSMetadataQuery()
        metaDataQuery?.predicate = NSPredicate(format: "%K like '\(mSaveFileName)'", NSMetadataItemFSNameKey)
        metaDataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        
        /*
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "metadataQueryDidFinishGathering:", name: NSMetadataQueryDidFinishGatheringNotification, object: metaDataQuery!)
        */
        metaDataQuery!.startQuery()
        
    }
    
    
    
}
