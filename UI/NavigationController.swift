import UIKit
import QuartzCore

extension Msr.UI {
    class NavigationController: UIViewController, UINavigationBarDelegate, UIToolbarDelegate, UIGestureRecognizerDelegate {
        private(set) var viewControllers = [UIViewController]()
        var rootViewController: UIViewController? {
            return viewControllers.first
        }
        private(set) var gesture: UIPanGestureRecognizer!
        var interactivePopGestureRecognizer: UIPanGestureRecognizer {
            return gesture
        }
        private(set) var wrappers = [WrapperView]()
        let maxDuration = NSTimeInterval(0.5)
        init(rootViewController: UIViewController) {
            super.init(nibName: nil, bundle: nil)
            gesture = UIPanGestureRecognizer(target: self, action: "didPerformPanGesture:")
            pushViewController(rootViewController, animated: false)
            view.backgroundColor = UIColor.blackColor()
            modalPresentationCapturesStatusBarAppearance = true
        }
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func pushViewController(viewController: UIViewController, animated: Bool) {
            pushViewController(viewController, animated: animated, completion: nil)
        }
        func pushViewController(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)?) {
            viewControllers.append(viewController)
            addChildViewController(viewController)
            wrappers.append(createWrapperForViewController(viewControllers.last!, previousViewController: viewControllers.penultimate))
            wrappers.last!.transform = CGAffineTransformMakeTranslation(view.bounds.width, 0)
            if viewControllers.count > 1 {
                wrappers.last!.addGestureRecognizer(gesture)
            }
            view.addSubview(wrappers.last!)
            let animations: () -> Void = {
                [weak self] in
                self?.transformAtPercentage(1,
                    frontView: self!.wrappers.last!,
                    backView: self!.wrappers.penultimate)
                self?.setNeedsStatusBarAppearanceUpdate()
            }
            let combinedCompletion: (Bool) -> Void = {
                [weak self] finished in
                self?.wrappers.penultimate?.removeFromSuperview()
                completion?(finished)
            }
            if animated && viewControllers.count > 1 {
                UIView.animateWithDuration(maxDuration,
                    delay: 0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 0.2,
                    options: .BeginFromCurrentState,
                    animations: animations,
                    completion: combinedCompletion)
            } else {
                animations()
                combinedCompletion(true)
            }
        }
        func pushViewControllers(viewControllers: [UIViewController], animated: Bool) {
            pushViewControllers(viewControllers, animated: animated, completion: nil)
        }
        func pushViewControllers(viewControllers: [UIViewController], animated: Bool, completion: ((Bool) -> Void)?) {
            for viewController in viewControllers[viewControllers.startIndex..<viewControllers.endIndex - 1] {
                self.viewControllers.append(viewController)
                addChildViewController(viewController)
            }
            pushViewController(viewControllers.last!, animated: animated) {
                [weak self] finished in
                if finished && self != nil {
                    for (i, viewController) in enumerate(viewControllers[0..<viewControllers.count - 1]) {
                        let wrapper = self!.createWrapperForViewController(viewController, previousViewController: self!.viewControllers[self!.viewControllers.endIndex - viewControllers.count + i - 1])
                        self!.transformAtPercentage(1, frontView: nil, backView: wrapper)
                        self!.wrappers.insert(wrapper, atIndex: self!.wrappers.endIndex - 1)
                    }
                }
                completion?(finished)
            }
        }
        func didPerformPanGesture(gesture: UIPanGestureRecognizer) {
            var percentage = 1 - gesture.translationInView(wrappers.last!).x / view.bounds.width
            if percentage > 1 {
                percentage = 1
            }
            switch gesture.state {
            case .Began, .Changed:
                view.insertSubview(wrappers.penultimate!, belowSubview: wrappers.last!)
                transformAtPercentage(percentage, frontView: wrappers.last!, backView: wrappers.penultimate!)
                break
            case .Ended, .Cancelled:
                if gesture.velocityInView(view).x > 0 {
                    popViewController(animated: true, completion: nil)
                } else {
                    let distance = gesture.translationInView(view).x
                    let velocity = abs(-gesture.velocityInView(view).x)
                    let duration = NSTimeInterval(distance / velocity)
                    UIView.animateWithDuration(min(duration, maxDuration),
                        delay: 0,
                        usingSpringWithDamping: 1.0,
                        initialSpringVelocity: 0,
                        options: .BeginFromCurrentState,
                        animations: {
                            [weak self] in
                            self?.transformAtPercentage(1, frontView: self!.wrappers.last!, backView: self!.wrappers.penultimate)
                            return
                        },
                        completion: {
                            [weak self] finished in
                            self?.wrappers.penultimate?.removeFromSuperview()
                            return
                        })
                }
                break
            default:
                break
            }
        }
        func popViewController(#animated: Bool) -> UIViewController {
            return popViewController(animated: animated, completion: nil)
        }
        func popViewController(#animated: Bool, completion: ((Bool) -> Void)?) -> UIViewController {
            assert(viewControllers.count > 1, "Already at root view controller. Nothing to be popped.")
            if wrappers.penultimate?.superview == nil {
                view.insertSubview(wrappers.penultimate!, belowSubview: wrappers.last!)
            }
            let viewControllerToBePopped = viewControllers.last!
            viewControllers.last!.removeFromParentViewController()
            viewControllers.removeLast()
            let combinedCompletion: (Bool) -> Void = {
                [weak self] finished in
                if finished {
                    self?.removeWrapper(self!.wrappers.last!, fromViewController: viewControllerToBePopped)
                    self?.wrappers.last!.removeFromSuperview()
                    self?.wrappers.removeLast()
                    if self?.viewControllers.count > 1 {
                        self?.wrappers.last!.addGestureRecognizer(self!.gesture)
                    }
                }
                completion?(finished)
            }
            let animations: () -> Void = {
                [weak self] in
                self?.transformAtPercentage(0, frontView: self!.wrappers.last!, backView: self!.wrappers.penultimate!)
                self?.setNeedsStatusBarAppearanceUpdate()
            }
            if animated {
                let distance = view.bounds.width - gesture.translationInView(view).x
                let velocity = gesture.velocityInView(view).x
                let duration = NSTimeInterval(distance / velocity)
                UIView.animateWithDuration(min(duration, maxDuration),
                    delay: 0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 0,
                    options: .BeginFromCurrentState,
                    animations: animations,
                    completion: combinedCompletion)
            } else {
                animations()
                combinedCompletion(true)
            }
            return viewControllerToBePopped
        }
        func popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController] {
            return popToViewController(viewController, animated: animated, completion: nil)
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
                popViewController(animated: animated, completion: completion)
            } else {
                completion?(true)
            }
            return viewControllersToBePopped
        }
        func popToRootViewController(#animated: Bool) -> [UIViewController] {
            return popToRootViewController(animated: animated, completion: nil)
        }
        func popToRootViewController(#animated: Bool, completion: ((Bool) -> Void)?) -> [UIViewController] {
            return popToViewController(rootViewController!, animated: animated, completion: completion)
        }
        func replaceCurrentViewControllerWithViewController(viewController: UIViewController, animated: Bool) -> UIViewController {
            return replaceCurrentViewControllerWithViewController(viewController, animated: animated, completion: nil)
        }
        func replaceCurrentViewControllerWithViewController(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)?) -> UIViewController {
            let viewControllerToBeReplaced = viewControllers.last!
            let wrapperToBeReplaced = wrappers.last!
            addChildViewController(viewController)
            viewControllers.last!.removeFromParentViewController()
            viewControllers.removeLast()
            viewControllers.append(viewController)
            wrappers.removeLast()
            wrappers.append(createWrapperForViewController(viewController, previousViewController: viewControllers.penultimate))
            view.addSubview(wrappers.last!)
            wrappers.last!.alpha = 0
            let animations: () -> Void = {
                [weak self] in
                self?.wrappers.last!.alpha = 1
                wrapperToBeReplaced.alpha = 0
                self?.setNeedsStatusBarAppearanceUpdate()
            }
            let combinedCompletion: (Bool) -> Void = {
                [weak self] finished in
                if finished {
                    self?.removeWrapper(wrapperToBeReplaced, fromViewController: viewControllerToBeReplaced)
                    wrapperToBeReplaced.removeFromSuperview()
                    if self?.viewControllers.count > 1 {
                        self?.wrappers.last!.addGestureRecognizer(self!.gesture)
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
                    animations: animations,
                    completion: combinedCompletion)
            } else {
                animations()
                combinedCompletion(true)
            }
            return viewControllerToBeReplaced
        }
        func setViewControllers(viewControllers: [UIViewController], animated: Bool) {
            setViewControllers(viewControllers, animated: animated, completion: nil)
        }
        func setViewControllers(viewControllers: [UIViewController], animated: Bool, completion: ((Bool) -> Void)?) {
            assert(viewControllers.count > 0, "No view controllers in the stack.")
            var i = 0
            for i = 0; i < min(self.viewControllers.count, viewControllers.count); ++i {
                if self.viewControllers[i] !== viewControllers[i] {
                    break
                }
            }
            var viewControllersToBePopped = [UIViewController](self.viewControllers[i..<self.viewControllers.count])
            var viewControllersToBePushed = [UIViewController](viewControllers[i..<viewControllers.count])
            let popCount = viewControllersToBePopped.count
            let pushCount = viewControllersToBePushed.count
            // <-: pop, ->: push, x: change
            // 1.        : popCount = pushCount = 0
            // 2. x      : popCount = pushCount = 1
            // 3. ->     : popCount = 0, pushCount > 0
            // 4. <-     : popCount > 0, pushCount = 0
            // 5. x ->   : popCount = 1, pushCount > 1
            // 6. <- x   : popCount > 1, pushCount = 1
            // 7. <- ->  : popCount > 1, pushCount > 1, remaining > 0
            // 8. <- x ->: popCount > 1, pushCount > 1, remaining = 0
            if popCount == 1 && pushCount == 1 {
                replaceCurrentViewControllerWithViewController(viewControllersToBePushed.first!, animated: animated, completion: completion)
            } else if popCount == 0 && pushCount > 0 {
                pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
            } else if popCount > 0 && pushCount == 0 {
                popToViewController(self.viewControllers[i - 1], animated: animated, completion: completion)
            } else if popCount == 1 && pushCount > 1 {
                replaceCurrentViewControllerWithViewController(viewControllersToBePushed.first!, animated: animated) {
                    [weak self] finished in
                    if finished {
                        viewControllersToBePushed.removeFirst()
                        self?.pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
                    }
                }
            } else if popCount > 1 && pushCount == 1 {
                popToViewController(viewControllersToBePopped.first!, animated: animated) {
                    [weak self] finished in
                    if finished {
                        self?.replaceCurrentViewControllerWithViewController(viewControllersToBePushed.first!, animated: animated, completion: completion)
                    }
                }
            } else if popCount > 1 && pushCount > 1 && i > 0 {
                popToViewController(self.viewControllers[i - 1], animated: animated) {
                    [weak self] finished in
                    if finished {
                        self?.pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
                    }
                }
            } else if popCount > 1 && pushCount > 1 && i == 0 {
                popToRootViewController(animated: animated) {
                    [weak self] finished in
                    if finished {
                        self?.replaceCurrentViewControllerWithViewController(viewControllersToBePushed.first!, animated: animated) {
                            finished in
                            viewControllersToBePushed.removeFirst()
                            self?.pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
                        }
                    }
                }
            }
        }
        private func transformAtPercentage(percentage: CGFloat, frontView: WrapperView!, backView: WrapperView!) {
            if frontView != nil {
                frontView.transform = CGAffineTransformMakeTranslation(frontView.bounds.width * (1 - percentage), 0)
                frontView.layer.shadowRadius = percentage * 5
            }
            if backView != nil {
                backView.transform = CGAffineTransformMakeTranslation(-view.bounds.width / 4 * percentage, 0)
                backView.overlay.alpha = percentage * 0.1
            }
        }
        private func createWrapperForViewController(viewController: UIViewController, previousViewController: UIViewController?) -> WrapperView {
            let wrapper = WrapperView()
            switch viewController.preferredStatusBarStyle() {
            case .Default:
                wrapper.navigationBar.barStyle = UIBarStyle.Default
                wrapper.navigationBar.tintColor = UIColor.blackColor()
                break
            case .LightContent:
                wrapper.navigationBar.barStyle = UIBarStyle.Black
                wrapper.navigationBar.tintColor = UIColor.whiteColor()
                break
            default:
                break
            }
            wrapper.bodyView = viewController.view
            wrapper.navigationItem = viewController.navigationItem
            if viewController.navigationItem.leftBarButtonItems == nil && previousViewController != nil {
                let backButton = UIBarButtonItem(image: UIImage(named: "Arrow-Left"), style: UIBarButtonItemStyle.Bordered, target: self, action: "didPressBackButton")
                wrapper.navigationItem.leftBarButtonItem = backButton
            }
            if let segmentedViewController = viewController as? SegmentedViewController {
                segmentedViewController.toolBar.removeFromSuperview()
                segmentedViewController.segmentedControl.removeFromSuperview()
                wrapper.navigationBar.bounds.size.height += segmentedViewController.toolBar.bounds.height
                wrapper.navigationBar.frame.origin.y = 0
                wrapper.navigationBar.setTitleVerticalPositionAdjustment(-segmentedViewController.toolBar.bounds.height, forBarMetrics: .Default)
                for navigationItem in wrapper.navigationBar.items as [UINavigationItem] {
                    if navigationItem.leftBarButtonItems != nil {
                        for item in navigationItem.leftBarButtonItems as [UIBarButtonItem] {
                            item.setBackgroundVerticalPositionAdjustment(-segmentedViewController.toolBar.bounds.height, forBarMetrics: .Default)
                        }
                    }
                    if navigationItem.rightBarButtonItems != nil {
                        for item in navigationItem.rightBarButtonItems as [UIBarButtonItem] {
                            item.setBackgroundVerticalPositionAdjustment(-segmentedViewController.toolBar.bounds.height, forBarMetrics: .Default)
                        }
                    }
                }
                segmentedViewController.segmentedControl.center.x = wrapper.center.x
                segmentedViewController.segmentedControl.center.y = wrapper.navigationBar.bounds.height - segmentedViewController.toolBar.bounds.height / 2
                wrapper.navigationBar.addSubview(segmentedViewController.segmentedControl)
            }
            return wrapper
        }
        func didPressBackButton() {
            popViewController(animated: true)
        }
        private func removeWrapper(wrapper: WrapperView, fromViewController viewController: UIViewController) {
            if let segmentedViewController = viewController as? SegmentedViewController {
                (segmentedViewController.view as UIScrollView).contentInset.top += segmentedViewController.toolBar.bounds.height
                segmentedViewController.segmentedControl.removeFromSuperview()
                segmentedViewController.view.addSubview(segmentedViewController.toolBar)
                segmentedViewController.toolBar.setItems([
                    UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(customView: segmentedViewController.segmentedControl),
                    UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)],
                    animated: true)
            }
        }
        class WrapperView: AutoExpandingView {
            let navigationBar = UINavigationBar()
            var navigationItem: UINavigationItem {
                get {
                    return navigationBar.items[0] as UINavigationItem
                }
                set {
                    navigationBar.setItems([newValue], animated: false)
                }
            }
            let contentView = UIView()
            let overlay = UIView()
            var bodyView: UIView? {
                willSet {
                    if newValue != nil {
                        newValue!.autoresizingMask = .FlexibleHeight | .FlexibleWidth
                        newValue!.frame = contentView.bounds
                        contentView.addSubview(newValue!)
                    }
                }
                didSet {
                    oldValue?.removeFromSuperview()
                }
            }
            override func msr_initialize() {
                super.msr_initialize()
                backgroundColor = UIColor.whiteColor()
                layer.shadowColor = UIColor.blackColor().CGColor
                layer.shadowOpacity = 0.5
                layer.shadowOffset = CGSize(width: 0, height: 0)
                layer.masksToBounds = false
                overlay.backgroundColor = UIColor.blackColor()
                overlay.alpha = 0
                contentView.layer.masksToBounds = false
                addSubview(contentView)
                addSubview(navigationBar)
                addSubview(overlay)
                contentView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                navigationBar.autoresizingMask = .FlexibleWidth
                layer.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.New, context: nil)
            }
            internal override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
                if object === layer && keyPath == "bounds" {
                    layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath
                }
            }
            override func layoutSubviews() {
                let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
                let orientation = UIApplication.sharedApplication().statusBarOrientation
                super.layoutSubviews()
                navigationBar.frame.origin.y = statusBarFrame.height
                navigationBar.frame.size.height = orientation.isPortrait ? 44 : 32
                navigationBar.msr_backgroundView!.frame.size.height = navigationBar.frame.height + statusBarFrame.height
                navigationBar.msr_backgroundView!.frame.origin.y = -statusBarFrame.height
                contentView.frame.msr_top = navigationBar.frame.msr_bottom
            }
            deinit {
                layer.removeObserver(self, forKeyPath: "bounds")
            }
        }
        override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
            return viewControllers.last?.preferredStatusBarUpdateAnimation() ?? .Fade
        }
        override func childViewControllerForStatusBarHidden() -> UIViewController? {
            return viewControllers.last
        }
        override func childViewControllerForStatusBarStyle() -> UIViewController? {
            return viewControllers.last
        }
    }
}

extension UIViewController {
    @objc var msr_navigationController: Msr.UI.NavigationController? {
        var current = parentViewController
        while current != nil {
            if current is Msr.UI.NavigationController {
                return current as? Msr.UI.NavigationController
            }
            current = current!.parentViewController
        }
        return nil
    }
    @objc var msr_navigationBar: UINavigationBar? {
        let navigationController = msr_navigationController
        if navigationController != nil {
            for (i, viewController) in enumerate(navigationController!.viewControllers) {
                var isSelfViewController = (viewController === self)
                var isParentViewController = false
                var parent = parentViewController
                while parent !== navigationController {
                    if parent === viewController {
                        isParentViewController = true
                        break
                    }
                    parent = parent?.parentViewController
                }
                if isSelfViewController || isParentViewController {
                    return navigationController?.wrappers[i].navigationBar
                }
            }
        }
        return nil
    }
    @objc var msr_navigationWrapperView: Msr.UI.NavigationController.WrapperView? {
        var current = view
        while current != nil {
            typealias Wrapper = Msr.UI.NavigationController.WrapperView
            if current is Wrapper {
                return (current as Wrapper)
            }
            current = current!.superview
        }
        return nil
    }
 }
