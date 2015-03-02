import UIKit

extension Msr.UI {
    class SegmentedViewController: UIViewController, UIToolbarDelegate {
        private var _viewControllers = [UIViewController]()
        var viewControllers: [UIViewController] {
            return _viewControllers
        }
        let segmentedControl = SegmentedControl()
        let scrollView = UIScrollView()
        override init() {
            super.init()
            // msr_initialize() will be invoked by super.init() -> self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        init(viewControllers: [UIViewController]) {
            super.init()
            // msr_initialize() will be invoked by super.init() -> self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            for vc in viewControllers {
                
            }
        }
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            msr_initialize()
        }
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            msr_initialize()
        }
        internal func msr_initialize() {
//            UITabBarController
        }
        func appendViewController(viewController: UIViewController, animated: Bool) {
            
        }
        func insertViewController(viewController: UIViewController, atIndex index: Int, animated: Bool) {
            
        }
        func removeViewController(viewController: UIViewController, atIndex index: Int, animated: Bool) {
            
        }
    }
}
