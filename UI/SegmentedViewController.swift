import UIKit

extension Msr.UI {
    class SegmentedViewController: UIViewController, UIToolbarDelegate {
        let viewControllers: [UIViewController]
        let segmentedControl: UISegmentedControl
        let toolBar: UIToolbar
        init(frame: CGRect, toolBarStyle: UIBarStyle, viewControllers: [UIViewController]) {
            self.viewControllers = viewControllers
            segmentedControl = UISegmentedControl(items: viewControllers.map({ $0.title ?? "" }))
            toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.width, height: 44))
            toolBar.barStyle = toolBarStyle
            super.init(nibName: nil, bundle: nil)
            view = UIScrollView(frame: frame)
            segmentedControl.bounds.size.width = toolBar.bounds.width - 20
            segmentedControl.addTarget(self, action: "switchView", forControlEvents: .ValueChanged)
            segmentedControl.selectedSegmentIndex = 0
            toolBar.delegate = self
            toolBar.tintColor = (toolBarStyle == .Default) ? UIColor.blackColor() : UIColor.whiteColor()
            toolBar.setItems([
                UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
                UIBarButtonItem(customView: segmentedControl),
                UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
                ], animated: false)
            view.addSubview(toolBar)
            for viewController in viewControllers {
                addChildViewController(viewController)
                view.insertSubview(viewController.view, belowSubview: toolBar)
            }
            switchView()
        }
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func switchView() {
            for viewController in viewControllers {
                viewController.view.hidden = true
            }
            let selectedViewController = viewControllers[segmentedControl.selectedSegmentIndex]
            selectedViewController.view.hidden = false
        }
        func positionForBar(bar: UIBarPositioning!) -> UIBarPosition {
            return .TopAttached
        }
        override func viewDidLayoutSubviews() {
            for viewController in viewControllers {
                viewController.view.frame = view.bounds
                if let scrollView = viewController.view as? UIScrollView {
                    scrollView.contentInset.top = toolBar.bounds.height + (view as UIScrollView).contentInset.top
                    scrollView.contentOffset.y = -scrollView.contentInset.top
                    if let tableView = scrollView as? UITableView {
                        tableView.scrollIndicatorInsets.top = toolBar.bounds.height + (view as UIScrollView).contentInset.top
                    }
                } else {
                    viewController.view.frame.origin.y += toolBar.bounds.height
                    viewController.view.frame.size.height += toolBar.bounds.height
                }
            }
        }
        override func preferredStatusBarStyle() -> UIStatusBarStyle {
            return (toolBar.barStyle == .Default) ? .Default : .LightContent
        }
    }
}
