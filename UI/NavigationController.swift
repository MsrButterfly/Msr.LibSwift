import UIKit
import QuartzCore

extension Msr.UI {
    class NavigationController: UIViewController, UINavigationBarDelegate, UIToolbarDelegate, UIGestureRecognizerDelegate {
        private(set) var viewControllers = [UIViewController]()
        var rootViewController: UIViewController {
            return viewControllers.firstOne
        }
        private var gestures = [UIPanGestureRecognizer]()
        private var wrappers = [WrapperView]()
        init(rootViewController: UIViewController) {
            super.init(nibName: nil, bundle: nil)
            pushViewController(rootViewController, animated: false, completion: nil)
            view.backgroundColor = UIColor.blackColor()

        }
        func pushViewController(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)?) {
            viewControllers += viewController
            addChildViewController(currentViewController)
            wrappers += createWrapperForViewController(viewController)
            currentWrapper.frame = CGRectOffset(currentWrapper.frame, currentWrapper.frame.width, 0)
            currentGesture?.setValue(false, forKey: "enabled")
            gestures += createPanGestureRecognizerForWrapper(currentWrapper)
            if viewControllers.count == 1 {
                currentGesture.enabled = false
            }
            view.addSubview(currentWrapper)
            if animated && previousViewController != nil {
                UIView.animateWithDuration(0.5,
                    delay: 0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 0.2,
                    options: .BeginFromCurrentState,
                    animations: {
                        finished in
                        self.transformAtPercentage(1, frontView: self.currentWrapper, backView: self.previousWrapper)
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
                completion?(true)
            }
        }
        func pushViewControllers(viewControllers: [UIViewController], animated: Bool, completion: ((Bool) -> Void)?) {
            pushViewController(viewControllers.lastOne, animated: animated) {
                finished in
                if finished {
                    for viewController in viewControllers[0..<viewControllers.count - 1] {
                        self.addChildViewController(viewController)
                        let wrapper = self.createWrapperForViewController(viewController)
                        let gesture = self.createPanGestureRecognizerForWrapper(wrapper)
                        gesture.enabled = false
                        self.transformAtPercentage(1, frontView: nil, backView: wrapper)
                        self.viewControllers.insert(viewController, atIndex: self.viewControllers.endIndex - 1)
                        self.wrappers.insert(wrapper, atIndex: self.wrappers.endIndex - 1)
                        self.gestures.insert(gesture, atIndex: self.gestures.endIndex - 1)
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
                if gesture.velocityInView(currentWrapper).x > 0 {
                    popViewController(true, completion: nil)
                } else {
                    UIView.animateWithDuration(0.5,
                        delay: 0,
                        usingSpringWithDamping: 1.0,
                        initialSpringVelocity: 0.2,
                        options: .BeginFromCurrentState,
                        animations: {
                            finished in
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
                view.insertSubview(previousWrapper?, belowSubview: currentWrapper)
            }
            let viewController = viewControllers.lastOne
            let animations: (Bool) -> Void = {
                finished in
                if finished {
                    self.removeWrapper(self.currentWrapper, fromViewController:self.currentViewController)
                    self.currentViewController.removeFromParentViewController()
                    self.currentViewController.view.removeFromSuperview()
                    self.wrappers.removeLast()
                    self.viewControllers.removeLast()
                    self.gestures.removeLast()
                    if self.viewControllers.count > 1 {
                        self.currentGesture.enabled = true
                    }
                }
            }
            if animated {
                UIView.animateWithDuration(0.5,
                    delay: 0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 0.2,
                    options: .BeginFromCurrentState,
                    animations: {
                        finished in
                        self.transformAtPercentage(0, frontView: self.currentWrapper, backView: self.previousWrapper)
                        return
                    },
                    completion: {
                        finished in
                        animations(finished)
                        completion?(finished)
                    })
            } else {
                self.transformAtPercentage(0, frontView: currentWrapper, backView: previousWrapper)
                animations(true)
                completion?(true)
            }
            return viewController
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
                    gestures.removeAtIndex(penultimate)
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
            let wrapper = createWrapperForViewController(viewController)
            let gesture = createPanGestureRecognizerForWrapper(wrapper)
            wrapper.alpha = 0
            view.addSubview(wrapper)
            let viewControllerToBeReplaced = viewControllers.lastOne
            let combinedCompletion: (Bool) -> Void = {
                finished in
                if finished {
                    self.removeWrapper(self.wrappers.lastOne, fromViewController: self.viewControllers.lastOne)
                    self.wrappers.lastOne.removeFromSuperview()
                    self.wrappers.removeLast()
                    self.wrappers += wrapper
                    self.gestures.removeLast()
                    self.gestures += gesture
                    self.viewControllers.lastOne.removeFromParentViewController()
                    self.viewControllers.removeLast()
                    self.viewControllers += viewController
                    if self.viewControllers.count == 1 {
                        self.currentGesture.enabled = false
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
            println("popCount = \(popCount); pushCount = \(pushCount)")
            if popCount == 1 && pushCount == 1 {
                replaceCurrentViewControllerWithViewController(viewControllersToBePushed.firstOne, animated: animated, completion: completion)
            } else if popCount == 0 && pushCount > 0 {
                pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
            } else if popCount > 0 && pushCount == 0 {
                popToViewController(self.viewControllers[i - 1], animated: animated, completion: completion)
            } else if popCount == 1 && pushCount > 1 {
                replaceCurrentViewControllerWithViewController(viewControllersToBePushed.firstOne, animated: animated) {
                    finished in
                    if finished {
                        viewControllersToBePushed.removeFirst()
                        self.pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
                    }
                }
            } else if popCount > 1 && pushCount == 1 {
                popToViewController(viewControllersToBePopped.firstOne, animated: animated) {
                    finished in
                    if finished {
                        self.replaceCurrentViewControllerWithViewController(viewControllersToBePushed.firstOne, animated: animated, completion: completion)
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
                        self.replaceCurrentViewControllerWithViewController(viewControllersToBePushed.firstOne, animated: animated) {
                            finished in
                            viewControllersToBePushed.removeFirst()
                            self.pushViewControllers(viewControllersToBePushed, animated: animated, completion: completion)
                        }
                    }
                }
            }
        }
        private func transformAtPercentage(percentage: CGFloat, frontView: WrapperView!, backView: WrapperView!) {
            var frame = view.bounds
            frame.origin.x = frame.width * (1 - percentage)
            if frontView != nil {
                frontView.frame = frame
            }
            if backView != nil {
                backView.transform = CGAffineTransformMakeScale(1 - percentage * 0.2, 1 - percentage * 0.2)
                backView.overlay.alpha = percentage
            }
        }
        var currentViewController: UIViewController! {
            return viewControllers.count > 0 ? viewControllers.lastOne : nil
        }
        var previousViewController: UIViewController! {
            return viewControllers.count > 1 ? viewControllers[viewControllers.endIndex - 2] : nil
        }
        private var currentWrapper: WrapperView! {
            return wrappers.count > 0 ? wrappers.lastOne : nil
        }
        private var previousWrapper: WrapperView! {
            return wrappers.count > 1 ? wrappers[wrappers.endIndex - 2] : nil
        }
        private var currentGesture: UIPanGestureRecognizer! {
            return gestures.count > 0 ? gestures.lastOne : nil
        }
        private var previousGesture: UIPanGestureRecognizer! {
            return gestures.count > 1 ? gestures[gestures.endIndex - 2] : nil
        }
        private func createWrapperForViewController(viewController: UIViewController) -> WrapperView {
            var frame = view.bounds
            viewController.view.frame = frame
            viewController.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            let wrapper = WrapperView(frame: frame)
            wrapper.insertSubview(viewController.view, belowSubview: wrapper.navigationBar)
            wrapper.navigationBar.setItems([viewController.navigationItem], animated: false)
            println(wrapper.navigationBar.frame)
            if let scrollView = viewController.view as? UIScrollView {
                var inset = scrollView.contentInset
                inset.top += wrapper.navigationBar.bounds.height
                scrollView.contentInset = inset
            } else {
                var frame = viewController.view.frame
                frame.size.height -= wrapper.navigationBar.bounds.height
                frame.origin.y += wrapper.navigationBar.bounds.height
            }
            return wrapper
        }
        private func removeWrapper(wrapper: WrapperView, fromViewController viewController: UIViewController) {
            if let scrollView = viewController.view as? UIScrollView {
                var inset = scrollView.contentInset
                inset.top -= wrapper.navigationBar.bounds.height
                scrollView.contentInset = inset
            } else {
                var frame = viewController.view.frame
                frame.size.height += wrapper.navigationBar.bounds.height
                frame.origin.y -= wrapper.navigationBar.bounds.height
            }
        }
        private func createPanGestureRecognizerForWrapper(wrapper: WrapperView) -> UIPanGestureRecognizer {
            let gesture = UIPanGestureRecognizer(target: self, action: "didPerformPanGesture:")
            wrapper.addGestureRecognizer(gesture)
            return gesture
        }
        class WrapperView: UIView {
            let navigationBar = UINavigationController().navigationBar
            let overlay = UIView()
            init(frame: CGRect) {
                super.init(frame: frame)
                overlay.frame = bounds
                overlay.backgroundColor = UIColor.blackColor()
                overlay.alpha = 0
                navigationBar.center.x = center.x
                addSubview(navigationBar)
                addSubview(overlay)
            }
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
        }
        return nil
    }
}
