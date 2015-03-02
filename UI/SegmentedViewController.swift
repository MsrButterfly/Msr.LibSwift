import UIKit

@objc protocol MsrSegmentedViewControllerDelegate: NSObjectProtocol {
    optional func msr_segmentedViewController(segmentedViewController: Msr.UI.SegmentedViewController, didSelectViewController viewController: UIViewController)
    optional func msr_segmentedViewController(segmentedViewController: Msr.UI.SegmentedViewController, titleViewOfViewController viewController: UIViewController) -> UIView?
}

extension Msr.UI {
    @objc class SegmentedViewController: UIViewController, UIToolbarDelegate {
        typealias Delegate = MsrSegmentedViewControllerDelegate
        private var _viewControllers = [UIViewController]()
        var viewControllers: [UIViewController] {
            return _viewControllers
        }
        let segmentedControl = SegmentedControl()
        let scrollView = UIScrollView()
        var delegate: Delegate?
        override init() {
            super.init()
            // msr_initialize() will be invoked by super.init() -> self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        init(viewControllers: [UIViewController]) {
            super.init()
            // msr_initialize() will be invoked by super.init() -> self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            for vc in viewControllers {
                appendViewController(vc, animated: false)
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
        func msr_initialize() {
            
        }
        func appendViewController(viewController: UIViewController, animated: Bool) {
            
        }
        func insertViewController(viewController: UIViewController, atIndex index: Int, animated: Bool) {
            
        }
        func removeViewController(viewController: UIViewController, animated: Bool) {
            
        }
        func removeViewControllerAtIndex(index: Int, animated: Bool) {
            
        }
        func setViewControllers(viewControllers: [UIViewController], animated: Bool) {
            
        }
        func selectViewController(viewController: UIViewController, animated: Bool) {
            
        }
        func selectViewControllerAtIndex(index: Int, animated: Bool) {
            
        }
        
    }
}
