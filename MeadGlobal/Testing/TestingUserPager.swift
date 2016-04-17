//
// UIPageViewController
//

import Foundation
import UIKit

/**
 * TestingUserPager Delegate
 */
protocol TestingUserPagerDelg {
    /**
     * pager 滑動頁面 '完成', 回傳完成頁面的 position
     */
    func PageChangeDone(position: Int)
}

/**
 * 顯示訪客或會員的 pager
 */
class TestingUserPager: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // delegate
    var delegateCust = TestingUserPagerDelg?()
    
    // Pager 包含的 sub VC
    private var pages: Array<UIViewController> = []
    private var indexPages = 0;  // 目前已滑動完成的 page position
    private var indexNextPages = 1;
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIPageViewController 的 delegate
        self.delegate = self
        self.dataSource = self
        
        // 加入 subViewController
        let mVCGuest = storyboard?.instantiateViewControllerWithIdentifier("PagerGuest") as! TestingGuestSel
        let mVCMember = storyboard?.instantiateViewControllerWithIdentifier("PagerMember") as! TestingMemberList
        mVCMember.identTarget = "TestingUserPager"
        pages.append(mVCGuest)
        pages.append(mVCMember)
        
        // 初始與顯示第一個頁面
        self.moveToPage(0)
    }
    
    /**
     * Public, 根據代入的 position 滑動到指定的頁面
     */
    func moveToPage(position: Int) {
        let mDirect = (position == 0) ? UIPageViewControllerNavigationDirection.Reverse : UIPageViewControllerNavigationDirection.Forward
        
        setViewControllers([pages[position]], direction: mDirect, animated: true, completion: nil)
    }
    
    /**
     * #mark: UIPageViewControllerDelegate
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
     * #mark: UIPageViewControllerDelegate
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
    
    /**
     * #mark: UIPageViewControllerDataSource
     * pager 有幾個頁面
     */
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return (pages.count == 2) ? 0 : pages.count
    }
    
    /**
     * #mark: UIPageViewControllerDataSource
     * 回傳目前頁面的 position
     */
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.indexPages
    }
    
    /**
     * #mark: UIPageViewControllerDelegate
     * page 滑動頁面 '完成'
     */
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if(completed){
            self.indexPages = self.indexNextPages;
            delegateCust?.PageChangeDone(self.indexPages)
            
            return
        }
        
        self.indexNextPages = 0;
    }
    
    /**
     * #mark: UIPageViewControllerDelegate
     * page '即將' 滑動頁面
     */
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {

        let controller = pendingViewControllers.first
        self.indexNextPages = pages.indexOf(controller!)!
    }

}