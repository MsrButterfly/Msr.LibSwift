import UIKit

@objc class MSRNavigationController: UIViewController, UIGestureRecognizerDelegate {
    private(set) var viewControllers = [UIViewController]()
    var rootViewController: UIViewController? {
        return viewControllers.first
    }
    var topViewController: UIViewController? {
        return viewControllers.last
    }
    private(set) var gesture: UIPanGestureRecognizer!
    var interactivePopGestureRecognizer: UIPanGestureRecognizer {
        return gesture
    }
    private(set) var wrappers = [MSRNavigationWrapperController]()
    let maxDuration = NSTimeInterval(0.5)
    var backButtonImage: UIImage?
    init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        msr_initialize()
        pushViewController(rootViewController, animated: false)
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
        gesture = UIPanGestureRecognizer(target: self, action: "didPerformPanGesture:")
        gesture.delegate = self
        modalPresentationCapturesStatusBarAppearance = true
        let _ = view // Views should be loaded in initializers.
    }
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.whiteColor()
    }
    func pushViewController(viewController: UIViewController, animated: Bool) {
        pushViewController(viewController, animated: animated, completion: nil)
    }
    func pushViewController(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)?) {
        viewControllers.append(viewController)
        wrappers.append(createWrapperForViewController(viewControllers.last!, previousViewController: viewControllers.msr_penultimate))
        addChildViewController(wrappers.last!)
        wrappers.last!.view.transform = CGAffineTransformMakeTranslation(view.bounds.width, 0)
        if viewControllers.count > 1 {
            wrappers.last!.view.addGestureRecognizer(gesture)
        }
        view.addSubview(wrappers.last!.view)
        let animations: () -> Void = {
            [weak self] in
            self?.transformAtPercentage(1, frontViewController: self?.wrappers.last, backViewController: self?.wrappers.msr_penultimate)
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        let combinedCompletion: (Bool) -> Void = {
            [weak self] finished in
            self?.wrappers.msr_penultimate?.view.removeFromSuperview()
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
        }
        pushViewController(viewControllers.last!, animated: animated) {
            [weak self] finished in
            if finished && self != nil {
                for (i, viewController) in enumerate(viewControllers[0..<viewControllers.count - 1]) {
                    let wrapper = self!.createWrapperForViewController(viewController, previousViewController: self!.viewControllers[self!.viewControllers.endIndex - viewControllers.count + i - 1])
                    self!.addChildViewController(wrapper)
                    self!.transformAtPercentage(1, frontViewController: nil, backViewController: wrapper)
                    self!.wrappers.insert(wrapper, atIndex: self!.wrappers.endIndex - 1)
                }
            }
            completion?(finished)
        }
    }
    func didPerformPanGesture(gesture: UIPanGestureRecognizer) {
        var percentage = 1 - gesture.translationInView(wrappers.last!.view).x / view.bounds.width
        if percentage > 1 {
            percentage = 1
        }
        switch gesture.state {
        case .Began:
            view.insertSubview(wrappers.msr_penultimate!.view, belowSubview: wrappers.last!.view)
            break
        case .Changed:
            transformAtPercentage(percentage, frontViewController: wrappers.last, backViewController: wrappers.msr_penultimate)
            break
        case .Ended, .Cancelled:
            // velocity
            // 1024|./////////////////////////////////
            //     |./////////////////////////////////
            //     | .////////////////////////////////
            //     |  .///////////////////////////////
            //     |    ./////////////////////////////
            //  512|      .///////////////////////////
            //     |        ./////////////////////////
            //     |          .///////////////////////
            //  256|             .////////////////////
            //     |                ./////////////////
            //  128|                    ./////////////
            //   64|                           .//////
            //    0|__________________________________
            //     0      0.2    0.4    0.6    0.8   1 location
            // (0, 1024), (0.2, 512), (0.4, 256), (0.6, 128), (0.8, 64)
            // velocity = 1024 / pow(2, location * 5)
            let minVelocity = 1024 / pow(2, gesture.locationInView(view).x / view.bounds.width * 5)
            if gesture.velocityInView(view).x > minVelocity {
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
                        self?.transformAtPercentage(1, frontViewController: self?.wrappers.last, backViewController: self?.wrappers.msr_penultimate)
                        return
                    },
                    completion: {
                        [weak self] finished in
                        self?.wrappers.msr_penultimate?.view.removeFromSuperview()
                        return
                    })
            }
            break
        case .Failed:
            break
        default:
            break
        }
    }
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === gesture {
            let velocity = gesture.velocityInView(view)
            let x = abs(velocity.x)
            let y = abs(velocity.y)
            return velocity.x > 256 && atan(y / x) < CGFloat(M_PI / 4)
        }
        return true
    }
    func popViewController(#animated: Bool) -> UIViewController {
        return popViewController(animated: animated, completion: nil)
    }
    func popViewController(#animated: Bool, completion: ((Bool) -> Void)?) -> UIViewController {
        assert(viewControllers.count > 1, "Already at root view controller. Nothing to be popped.")
        if wrappers.msr_penultimate!.view.superview == nil {
            view.insertSubview(wrappers.msr_penultimate!.view, belowSubview: wrappers.last!.view)
        }
        let viewControllerToBePopped = viewControllers.last!
        let wrapperToBeRemoved = wrappers.last!
        wrapperToBeRemoved.removeFromParentViewController()
        viewControllers.removeLast()
        wrappers.removeLast()
        let combinedCompletion: (Bool) -> Void = {
            [weak self] finished in
            if finished {
                wrapperToBeRemoved.view.removeFromSuperview()
                wrapperToBeRemoved.viewControllers = []
                if self?.viewControllers.count > 1 {
                    self?.wrappers.last!.view.addGestureRecognizer(self!.gesture)
                }
            }
            completion?(finished)
        }
        let animations: () -> Void = {
            [weak self] in
            self?.transformAtPercentage(0, frontViewController: wrapperToBeRemoved, backViewController: self?.wrappers.last)
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
                wrappers[penultimate].viewControllers = []
                wrappers[penultimate].view.removeFromSuperview()
                wrappers[penultimate].removeFromParentViewController()
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
        wrappers.last!.viewControllers = []
        wrappers.last!.removeFromParentViewController()
        viewControllers.removeLast()
        viewControllers.append(viewController)
        let wrapper = createWrapperForViewController(viewController, previousViewController: viewControllers.msr_penultimate)
        addChildViewController(wrapper)
        wrappers.removeLast()
        wrappers.append(wrapper)
        view.addSubview(wrappers.last!.view)
        wrappers.last!.view.alpha = 0
        let animations: () -> Void = {
            [weak self] in
            self?.wrappers.last!.view.alpha = 1
            wrapperToBeReplaced.view.alpha = 0
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        let combinedCompletion: (Bool) -> Void = {
            [weak self] finished in
            if finished {
                wrapperToBeReplaced.view.removeFromSuperview()
                if self?.viewControllers.count > 1 {
                    self?.wrappers.last!.view.addGestureRecognizer(self!.gesture)
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
        /********************************************************
        * <-: pop, ->: push, x: change
        * 1.        : popCount = pushCount = 0
        * 2. x      : popCount = pushCount = 1
        * 3. ->     : popCount = 0, pushCount > 0
        * 4. <-     : popCount > 0, pushCount = 0
        * 5. x ->   : popCount = 1, pushCount > 1
        * 6. <- x   : popCount > 1, pushCount = 1
        * 7. <- ->  : popCount > 1, pushCount > 1, remaining > 0
        * 8. <- x ->: popCount > 1, pushCount > 1, remaining = 0
        ********************************************************/
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
                    viewControllersToBePushed.msr_removeFirst()
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
                        viewControllersToBePushed.msr_removeFirst()
                        self?.pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
                    }
                }
            }
        }
    }
    private func transformAtPercentage(percentage: CGFloat, frontViewController: MSRNavigationWrapperController?, backViewController: MSRNavigationWrapperController?) {
        frontViewController?.view.transform = CGAffineTransformMakeTranslation(view.bounds.width * (1 - percentage), 0)
        frontViewController?.view.layer.shadowRadius = percentage * 5
        backViewController?.view.transform = CGAffineTransformMakeTranslation(-view.bounds.width / 4 * percentage, 0)
        backViewController?.overlay.alpha = percentage * 0.2
    }
    private func createWrapperForViewController(viewController: UIViewController, previousViewController: UIViewController?) -> MSRNavigationWrapperController {
        let wrapper = MSRNavigationWrapperController(rootViewController: viewController)
        if viewController.navigationItem.leftBarButtonItems == nil && previousViewController != nil {
            // TODO: - SET TO DEFAULT NAVIGATION BUTTON
            let backButton = UIBarButtonItem(image: backButtonImage, style: .Plain, target: self, action: "didPressBackButton")
            (wrapper.navigationBar.items[0] as! UINavigationItem).leftBarButtonItem = backButton
        }
        return wrapper
    }
    func didPressBackButton() {
        popViewController(animated: true)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return viewControllers.last?.preferredStatusBarStyle() ?? .Default
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

extension UIViewController {
    @objc var msr_navigationController: MSRNavigationController? {
        var current = parentViewController
        while current != nil {
            if current is MSRNavigationController {
                return current as? MSRNavigationController
            }
            current = current!.parentViewController
        }
        return nil
    }
    @objc var msr_navigationBar: UINavigationBar? {
        return msr_navigationWrapperController?.navigationBar
    }
    @objc var msr_navigationWrapperController: MSRNavigationWrapperController? {
        var current = parentViewController
        while current != nil {
            if current is MSRNavigationWrapperController {
                return current as? MSRNavigationWrapperController
            }
            current = current!.parentViewController
        }
        return nil
    }
 }
