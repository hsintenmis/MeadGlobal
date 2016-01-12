//
// PageViewController
//

import Foundation
import UIKit

class TestingUserPager: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var mVCtrl: UIPageViewController!
    
    // Pager 包含的 sub VC
    var pages = [UIViewController]()
    var indexPages = 0;
    var indexNextPages = 0;
    
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
        setViewControllers([page1], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

    }
    
    func moveToPage(position: Int) {
        //self.select(<#T##sender: AnyObject?##AnyObject?#>)
    }
    
    /** Start #mark: UIPageViewController **/
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
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if(completed){
            self.indexPages = self.indexNextPages;
            print(self.indexPages)
        }
        
        self.indexNextPages = 0;
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {

        let controller = pendingViewControllers.first
        self.indexNextPages = pages.indexOf(controller!)!
    }
    

    
    /** End #mark: UIPageViewController **/
}