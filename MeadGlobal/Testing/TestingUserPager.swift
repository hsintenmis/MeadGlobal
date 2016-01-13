//
// PageViewController
//

import Foundation
import UIKit

/**
 * 顯示訪客或會員的 pager
 */
class TestingUserPager: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // VC 設定
    var mTestingUser: TestingUser!
    private var mVCtrl: UIPageViewController!
    
    // Pager 包含的 sub VC
    var pages: Array<UIViewController> = []
    var indexPages = 0;  // 目前以滑動完成的 page position
    var indexNextPages = 1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mVCtrl = self
        self.delegate = self
        self.dataSource = self
        
        // 加入 subViewController
        let page1: UIViewController! = storyboard?.instantiateViewControllerWithIdentifier("PagerGuest")
        let page2: UIViewController! = storyboard?.instantiateViewControllerWithIdentifier("PagerMember")
        pages.append(page1)
        pages.append(page2)
        
        // 初始與顯示第一個頁面
        self.moveToPage(0)
    }
    
    // viewDidAppear
    override func viewDidAppear(animated: Bool) {
    }
    
    /**
    * 根據代入的 position 滑動到指定的頁面
    */
    func moveToPage(position: Int) {
        let mDirect = (position == 0) ? UIPageViewControllerNavigationDirection.Reverse : UIPageViewControllerNavigationDirection.Forward
        
        setViewControllers([pages[position]], direction: mDirect, animated: true, completion: nil)
    }
    
    /** Start #mark: UIPageViewController **/
     
    /**
     * page 前一個頁面
     */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = pages.indexOf(viewController)!
        
        //let previousIndex = abs((currentIndex - 1) % pages.count)
        let previousIndex = (currentIndex - 1)
        indexPages = previousIndex
        
        if (previousIndex < 0) {
            indexPages = 0
            return nil
        }
        
        return pages[previousIndex]
    }
    
    /**
     * page 下個頁面
     */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = pages.indexOf(viewController)!
        
        //let nextIndex = abs((currentIndex + 1) % pages.count)
        let nextIndex = currentIndex + 1
        indexPages = nextIndex
        
        if (nextIndex == pages.count) {
            indexPages = currentIndex
            return nil
        }

        return pages[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        
        return pages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        
        //return 0
        return self.indexPages
    }
    
    /**
     * page 滑動至下一個頁面狀態
     */
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if(completed){
            self.indexPages = self.indexNextPages;
            // TODO 設定目前已選擇的 page position
            mTestingUser.changBtnColor(self.indexPages)
            
            return
        }
        
        self.indexNextPages = 0;
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {

        let controller = pendingViewControllers.first
        self.indexNextPages = pages.indexOf(controller!)!
    }
    
    /** End #mark: UIPageViewController **/
}