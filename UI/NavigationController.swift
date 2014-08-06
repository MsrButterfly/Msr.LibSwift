import UIKit
import QuartzCore

extension Msr.UI {
    class NavigationController: UIViewController, UINavigationBarDelegate, UIToolbarDelegate, UIGestureRecognizerDelegate {
        private(set) var viewControllers = [UIViewController]()
        var rootViewController: UIViewController {
            return viewControllers.first!
        }
        private var gesture: UIPanGestureRecognizer!
        var interactivePopGestureRecognizer: UIPanGestureRecognizer {
            return gesture
        }
        private var wrappers = [WrapperView]()
        let maxDuration = NSTimeInterval(0.5)
        let minDuration = NSTimeInterval(0.3)
        let maxVelocity = CGFloat(10)
        init(rootViewController: UIViewController) {
            super.init(nibName: nil, bundle: nil)
            gesture = UIPanGestureRecognizer(target: self, action: "didPerformPanGesture:")
            pushViewController(rootViewController, animated: false, completion: nil)
            view.backgroundColor = UIColor.blackColor()
        }
        required init(coder aDecoder: NSCoder!) {
            super.init(coder: aDecoder)
        }
        func pushViewController(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)?) {
            viewControllers.append(viewController)
            addChildViewController(currentViewController)
            wrappers.append(createWrapperForViewController(viewController, previousViewController: previousViewController))
            currentWrapper.transform = CGAffineTransformMakeTranslation(currentWrapper.bounds.width, 0)
            if viewControllers.count > 1 {
                currentWrapper.addGestureRecognizer(gesture)
            }
            view.addSubview(currentWrapper)
            if animated && previousViewController != nil {
                UIView.animateWithDuration(maxDuration,
                    delay: 0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 0.2,
                    options: .BeginFromCurrentState,
                    animations: {
                        finished in
                        self.transformAtPercentage(1, frontView: self.currentWrapper, backView: self.previousWrapper)
                        self.setNeedsStatusBarAppearanceUpdate()
                        return
                    },
                    completion: {
                        finished in
                        self.previousWrapper?.removeFromSuperview()
                        completion?(finished)
                    })
            } else {
                transformAtPercentage(1, frontView: currentWrapper, backView: previousWrapper)
                previousWrapper?.removeFromSuperview()
                setNeedsStatusBarAppearanceUpdate()
                completion?(true)
            }
        }
        func pushViewControllers(viewControllers: [UIViewController], animated: Bool, completion: ((Bool) -> Void)?) {
            for viewController in viewControllers[viewControllers.startIndex..<viewControllers.endIndex - 1] {
                self.viewControllers.append(viewController)
                self.addChildViewController(viewController)
            }
            pushViewController(viewControllers.last!, animated: animated) {
                finished in
                if finished {
                    for (i, viewController) in enumerate(viewControllers[0..<viewControllers.count - 1]) {
                        let wrapper = self.createWrapperForViewController(viewController, previousViewController: self.viewControllers[self.viewControllers.endIndex - viewControllers.count + i - 1])
                        self.transformAtPercentage(1, frontView: nil, backView: wrapper)
                        self.wrappers.insert(wrapper, atIndex: self.wrappers.endIndex - 1)
                    }
                }
                completion?(finished)
            }
        }
        func didPerformPanGesture(gesture: UIPanGestureRecognizer) {
            var percentage = 1 - gesture.translationInView(currentWrapper).x / view.bounds.width
            if percentage > 1 {
                percentage = 1
            }
            switch gesture.state {
            case .Began, .Changed:
                view.insertSubview(previousWrapper, belowSubview: currentWrapper)
                transformAtPercentage(percentage, frontView: currentWrapper, backView: previousWrapper)
                break
            case .Ended, .Cancelled:
                if gesture.velocityInView(view).x >= 0 {
                    popViewController(true, completion: nil)
                } else {
                    let distance = view.bounds.width - gesture.locationInView(view).x
                    let velocity = -gesture.velocityInView(view).x
                    let duration = NSTimeInterval(distance / velocity)
                    UIView.animateWithDuration(max(min(duration, maxDuration), minDuration),
                        delay: 0,
                        usingSpringWithDamping: 1.0,
                        initialSpringVelocity: min(velocity / distance, maxVelocity),
                        options: .BeginFromCurrentState,
                        animations: {
                            self.transformAtPercentage(1, frontView: self.currentWrapper, backView: self.previousWrapper)
                            return
                        },
                        completion: {
                            finished in
                            self.previousWrapper?.removeFromSuperview()
                            return
                        })
                }
                break
            default:
                break
            }
        }
        func popViewController(animated: Bool, completion: ((Bool) -> Void)?) -> UIViewController {
            assert(viewControllers.count > 1, "Already at root view controller. Nothing to be popped.")
            if previousWrapper?.superview == nil {
                view.insertSubview(previousWrapper, belowSubview: currentWrapper)
            }
            let viewControllerToBePopped = viewControllers.last!
            self.currentViewController.removeFromParentViewController()
            self.viewControllers.removeLast()
            let combinedCompletion: (Bool) -> Void = {
                finished in
                if finished {
                    self.removeWrapper(self.currentWrapper, fromViewController:viewControllerToBePopped)
                    self.currentWrapper.removeFromSuperview()
                    self.wrappers.removeLast()
                    if self.viewControllers.count > 1 {
                        self.currentWrapper.addGestureRecognizer(self.gesture)
                    }
                }
                completion?(finished)
            }
            if animated {
                let distance = view.bounds.width - gesture.locationInView(view).x
                let velocity = gesture.velocityInView(view).x
                let duration = NSTimeInterval(distance / velocity)
                UIView.animateWithDuration(max(min(duration, maxDuration), minDuration),
                    delay: 0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: min(velocity / distance, maxVelocity),
                    options: .BeginFromCurrentState,
                    animations: {
                        finished in
                        self.transformAtPercentage(0, frontView: self.currentWrapper, backView: self.previousWrapper)
                        self.setNeedsStatusBarAppearanceUpdate()
                        return
                    },
                    completion: combinedCompletion)
            } else {
                self.transformAtPercentage(0, frontView: currentWrapper, backView: previousWrapper)
                combinedCompletion(true)
            }
            return viewControllerToBePopped
        }
        func popToViewController(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)?) -> [UIViewController] {
            assert(contains(viewControllers, viewController), "The specific view controller is not in the view controller hierarchy.")
            let p = find(viewControllers, viewController)
            var viewControllersToBePopped = [UIViewController]()
            viewControllersToBePopped.extend(viewControllers[p! + 1..<viewControllers.endIndex])
            let count = viewControllersToBePopped.count
            if count > 0 {
                for i in 1..<count {
                    let penultimate = viewControllers.endIndex - 2
                    removeWrapper(wrappers[penultimate], fromViewController: viewControllers[penultimate])
                    viewControllers[penultimate].removeFromParentViewController()
                    wrappers[penultimate].removeFromSuperview()
                    viewControllers.removeAtIndex(penultimate)
                    wrappers.removeAtIndex(penultimate)
                }
                popViewController(animated, completion: completion)
            } else {
                completion?(true)
            }
            return viewControllersToBePopped
        }
        func popToRootViewControllerAnimated(animated: Bool, completion: ((Bool) -> Void)?) -> [UIViewController] {
            return popToViewController(rootViewController, animated: animated, completion: completion)
        }
        func replaceCurrentViewControllerWithViewController(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)?) -> UIViewController {
            addChildViewController(viewController)
            let wrapper = createWrapperForViewController(viewController, previousViewController: previousViewController)
            wrapper.alpha = 0
            view.addSubview(wrapper)
            let viewControllerToBeReplaced = viewControllers.last!
            self.viewControllers.last!.removeFromParentViewController()
            self.viewControllers.removeLast()
            self.viewControllers.append(viewController)
            let combinedCompletion: (Bool) -> Void = {
                finished in
                if finished {
                    self.removeWrapper(self.wrappers.last!, fromViewController: viewControllerToBeReplaced)
                    self.wrappers.last!.removeFromSuperview()
                    self.wrappers.removeLast()
                    self.wrappers.append(wrapper)
                    if self.viewControllers.count > 1 {
                        self.currentWrapper.addGestureRecognizer(self.gesture)
                    }
                }
                completion?(finished)
            }
            if animated {
                UIView.animateWithDuration(0.5,
                    delay: 0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 0.2,
                    options: .BeginFromCurrentState,
                    animations: {
                        wrapper.alpha = 1
                        self.currentWrapper.alpha = 0
                        self.setNeedsStatusBarAppearanceUpdate()
                    }, completion: combinedCompletion)
            } else {
                wrapper.alpha = 1
                currentWrapper.alpha = 0
                combinedCompletion(true)
            }
            return viewControllerToBeReplaced
        }
        func setViewControllers(viewControllers: [UIViewController], animated: Bool, completion: ((Bool) -> Void)?) {
            assert(viewControllers.count > 0, "No view controllers in the stack.")
            var i = 0
            for i = 0; i < min(self.viewControllers.count, viewControllers.count); ++i {
                if self.viewControllers[i] !== viewControllers[i] {
                    break
                }
            }
            var viewControllersToBePopped = [UIViewController]()
            viewControllersToBePopped.extend(self.viewControllers[i..<self.viewControllers.count])
            var viewControllersToBePushed = [UIViewController]()
            viewControllersToBePushed.extend(viewControllers[i..<viewControllers.count])
            let popCount = viewControllersToBePopped.count
            let pushCount = viewControllersToBePushed.count
            // <-: pop, ->: push, x: change
            // 1.        : popCount = pushCount = 0
            // 2. x      : popCount = pushCount = 1
            // 3. ->     : popCount = 0, pushCount > 0
            // 4. <-     : popCount > 0, pushCount = 0
            // 5. x ->   : popCount = 1, pushCount > 1
            // 6. <- x   : popCount > 1, pushCount = 1
            // 7. <- ->  : popCount > 1, pushCount > 1, i > 0
            // 8. <- x ->: popCount > 1, pushCount > 1, i == 0
            if popCount == 1 && pushCount == 1 {
                replaceCurrentViewControllerWithViewController(viewControllersToBePushed.first!, animated: animated, completion: completion)
            } else if popCount == 0 && pushCount > 0 {
                pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
            } else if popCount > 0 && pushCount == 0 {
                popToViewController(self.viewControllers[i - 1], animated: animated, completion: completion)
            } else if popCount == 1 && pushCount > 1 {
                replaceCurrentViewControllerWithViewController(viewControllersToBePushed.first!, animated: animated) {
                    finished in
                    if finished {
                        viewControllersToBePushed.removeFirst()
                        self.pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
                    }
                }
            } else if popCount > 1 && pushCount == 1 {
                popToViewController(viewControllersToBePopped.first!, animated: animated) {
                    finished in
                    if finished {
                        self.replaceCurrentViewControllerWithViewController(viewControllersToBePushed.first!, animated: animated, completion: completion)
                    }
                }
            } else if popCount > 1 && pushCount > 1 && i > 0 {
                popToViewController(self.viewControllers[i - 1], animated: animated) {
                    finished in
                    if finished {
                        self.pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
                    }
                }
            } else if popCount > 1 && pushCount > 1 && i == 0 {
                popToRootViewControllerAnimated(animated) {
                    finished in
                    if finished {
                        self.replaceCurrentViewControllerWithViewController(viewControllersToBePushed.first!, animated: animated) {
                            finished in
                            viewControllersToBePushed.removeFirst()
                            self.pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
                        }
                    }
                }
            }
        }
        private func transformAtPercentage(percentage: CGFloat, frontView: WrapperView!, backView: WrapperView!) {
            if frontView != nil {
                frontView.transform = CGAffineTransformMakeTranslation(frontView.bounds.width * (1 - percentage), 0)
                frontView.layer.shadowOpacity = Float(percentage)
            }
            if backView != nil {
                backView.transform = CGAffineTransformMakeTranslation(-view.bounds.width / 4 * percentage, 0)
                backView.overlay.alpha = percentage * 0.3
            }
        }
        var currentViewController: UIViewController! {
            return viewControllers.count > 0 ? viewControllers.last! : nil
        }
        var previousViewController: UIViewController! {
            return viewControllers.count > 1 ? viewControllers[viewControllers.endIndex - 2] : nil
        }
        private var currentWrapper: WrapperView! {
            return wrappers.count > 0 ? wrappers.last! : nil
        }
        private var previousWrapper: WrapperView! {
            return wrappers.count > 1 ? wrappers[wrappers.endIndex - 2] : nil
        }
        private func createWrapperForViewController(viewController: UIViewController, previousViewController: UIViewController?) -> WrapperView {
            var frame = view.bounds
            viewController.view.frame = frame
            viewController.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            let wrapper = WrapperView(frame: frame, statusBarStyle: viewController.preferredStatusBarStyle())
            wrapper.insertSubview(viewController.view, belowSubview: wrapper.navigationBar)
            wrapper.navigationItem = viewController.navigationItem
            if !viewController.navigationItem.leftBarButtonItems && previousViewController != nil {
                let backButton = UIBarButtonItem(title: "《  ", style: UIBarButtonItemStyle.Bordered, target: self, action: "didPressBackButton")
                backButton.title = backButton.title! + (previousViewController!.title != nil ? previousViewController!.title! : "Back")
                wrapper.navigationItem.leftBarButtonItem = backButton
            }
            if let scrollView = viewController.view as? UIScrollView {
                scrollView.contentInset.top += wrapper.navigationBar.bounds.height
                if let tableView = scrollView as? UITableView {
                    tableView.scrollIndicatorInsets.top += wrapper.navigationBar.bounds.height
                }
            } else {
                var frame = viewController.view.frame
                frame.size.height -= wrapper.navigationBar.bounds.height
                frame.origin.y += wrapper.navigationBar.bounds.height
                viewController.view.frame = frame
            }
            if let segmentedViewController = viewController as? SegmentedViewController {
                segmentedViewController.toolBar.removeFromSuperview()
                segmentedViewController.segmentedControl.removeFromSuperview()
                wrapper.navigationBar.bounds.size.height += segmentedViewController.toolBar.bounds.height
                wrapper.navigationBar.frame.origin.y = 0
                wrapper.navigationBar.setTitleVerticalPositionAdjustment(-segmentedViewController.toolBar.bounds.height, forBarMetrics: .Default)
                segmentedViewController.segmentedControl.center.x = wrapper.center.x
                segmentedViewController.segmentedControl.center.y = wrapper.navigationBar.bounds.height - segmentedViewController.toolBar.bounds.height / 2
                wrapper.navigationBar.addSubview(segmentedViewController.segmentedControl)
            }
            return wrapper
        }
        func didPressBackButton() {
            popViewController(true, completion: nil)
        }
        private func removeWrapper(wrapper: WrapperView, fromViewController viewController: UIViewController) {
            if let scrollView = viewController.view as? UIScrollView {
                scrollView.contentInset.top -= wrapper.navigationBar.bounds.height
                if let tableView = scrollView as? UITableView {
                    tableView.scrollIndicatorInsets.top -= wrapper.navigationBar.bounds.height
                }
            } else {
                var frame = viewController.view.frame
                frame.size.height += wrapper.navigationBar.bounds.height
                frame.origin.y -= wrapper.navigationBar.bounds.height
                viewController.view.frame = frame
            }
            if let segmentedViewController = viewController as? SegmentedViewController {
                (segmentedViewController.view as UIScrollView).contentInset.top += segmentedViewController.toolBar.bounds.height
                segmentedViewController.segmentedControl.removeFromSuperview()
                segmentedViewController.view.addSubview(segmentedViewController.toolBar)
                segmentedViewController.toolBar.setItems([
                    UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(customView: segmentedViewController.segmentedControl),
                    UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
                    ], animated: true)
            }
        }
        override func viewDidLayoutSubviews() {
            if let scrollView = viewControllers.last!.view as? UIScrollView {
                scrollView.contentOffset.y = -scrollView.contentInset.top
            }
        }
        class WrapperView: UIView {
            let navigationBar = UINavigationController().navigationBar
            var navigationItem: UINavigationItem {
                get {
                    return navigationBar.items[0] as UINavigationItem
                }
                set {
                    navigationBar.setItems([newValue], animated: false)
                }
            }
            let overlay = UIView()
            init(frame: CGRect, statusBarStyle: UIStatusBarStyle) {
                switch statusBarStyle {
                case .Default:
                    navigationBar.barStyle = UIBarStyle.Default
                    navigationBar.tintColor = UIColor.blackColor()
                    break
                case .LightContent:
                    navigationBar.barStyle = UIBarStyle.Black
                    navigationBar.tintColor = UIColor.whiteColor()
                    break
                default:
                    break
                }
                super.init(frame: frame)
                backgroundColor = UIColor.whiteColor()
                layer.shadowColor = UIColor.grayColor().CGColor
                layer.shadowOpacity = 1
                layer.shadowOffset = CGSize(width: 0, height: 0)
                layer.masksToBounds = false
                layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath
                overlay.frame = bounds
                overlay.backgroundColor = UIColor.blackColor()
                overlay.alpha = 0
                navigationBar.center.x = center.x
                var navigationBarFrame = navigationBar.frame
                navigationBarFrame.size.height += UIApplication.sharedApplication().statusBarFrame.height
                navigationBarFrame.origin.y = 0
                navigationBar.frame = navigationBarFrame
                addSubview(navigationBar)
                addSubview(overlay)
            }
            required init(coder aDecoder: NSCoder!) {
                super.init(coder: aDecoder)
            }
        }
        override func preferredStatusBarStyle() -> UIStatusBarStyle {
            return currentViewController.preferredStatusBarStyle()
        }
    }
}

extension UIViewController {
    @objc var msrNavigationController: Msr.UI.NavigationController! {
        var current = parentViewController
        while current != nil {
            if current is Msr.UI.NavigationController {
                return current as Msr.UI.NavigationController
            }
            current = current.parentViewController
        }
        return nil
    }
}
