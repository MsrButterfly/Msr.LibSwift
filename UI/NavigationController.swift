import UIKit
import QuartzCore

extension Msr.UI {
    class NavigationController: UIViewController, UINavigationBarDelegate, UIToolbarDelegate, UIGestureRecognizerDelegate {
        private var viewControllers = [UIViewController]()
        private var gestures = [UIPanGestureRecognizer]()
        private var wrappers = [WrapperView]()
        init() {
            super.init(nibName: nil, bundle: nil)
            view.backgroundColor = UIColor.blackColor()
        }
        func pushViewController(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)?) {
            viewControllers += viewController
            addChildViewController(currentViewController)
            var frame = view.bounds
            currentViewController.view.frame = frame
            currentViewController.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            wrappers += WrapperView(frame: frame)
            frame = CGRectOffset(frame, frame.width, 0)
            currentWrapper.frame = frame
            currentWrapper.insertSubview(currentViewController.view, belowSubview: currentWrapper.navigationBar)
            currentWrapper.navigationBar.setItems([UINavigationItem(title: currentViewController.title)], animated: false)
            currentGesture?.setValue(false, forKey: "enabled")
            gestures += UIPanGestureRecognizer(target: self, action: "didPerformPanGesture:")
            currentWrapper.addGestureRecognizer(currentGesture)
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
                        [weak self] in
                        self?.transformAtPercentage(1)
                        return
                    },
                    completion: {
                        [weak self] finished in
                        self?.previousWrapper?.removeFromSuperview()
                        completion?(finished)
                    })
            } else {
                transformAtPercentage(1)
                previousWrapper?.removeFromSuperview()
                completion?(true)
            }
        }
        func didPerformPanGesture(gesture: UIPanGestureRecognizer) {
            var percentage = 1 - gesture.translationInView(currentWrapper).x / view.bounds.width
            println(percentage)
            if percentage > 1 {
                percentage = 1
            }
            switch gesture.state {
            case .Began, .Changed:
                view.insertSubview(previousWrapper, belowSubview: currentWrapper)
                transformAtPercentage(percentage)
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
                            [weak self] in
                            self?.transformAtPercentage(1)
                            return
                        },
                        completion: {
                            [weak self] finished in
                            self?.previousWrapper?.removeFromSuperview()
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
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0.2,
                options: .BeginFromCurrentState,
                animations: {
                    [weak self] in
                    self?.transformAtPercentage(0)
                    return
                },
                completion: {
                    [weak self] finished in
                    if finished {
                        self!.currentViewController.removeFromParentViewController()
                        self!.currentViewController.view.removeFromSuperview()
                        self!.wrappers.removeLast()
                        self!.viewControllers.removeLast()
                        self!.gestures.removeLast()
                        if self!.viewControllers.count > 1 {
                            self!.currentGesture.enabled = true
                        }
                    }
                    completion?(finished)
                })
            return viewController
        }
        func popToViewController(viewController: UIViewController, animated: Bool, completion: ((Bool) -> Void)?) -> [UIViewController] {
            assert(contains(viewControllers, viewController), "The specific view controller is not in the view controller hierarchy.")
            let p = find(viewControllers, viewController)
            var viewControllersToBePopped = [UIViewController]()
            viewControllersToBePopped.extend(viewControllers[p! + 1..<viewControllers.endIndex])
            let count = viewControllersToBePopped.count
            for _ in 1..<count {
                println("???")
                let penultimate = viewControllers.endIndex - 2
                viewControllers[penultimate].removeFromParentViewController()
                wrappers[penultimate].removeFromSuperview()
                viewControllers.removeAtIndex(penultimate)
                gestures.removeAtIndex(penultimate)
                wrappers.removeAtIndex(penultimate)
            }
            popViewController(animated, completion: completion)
            return viewControllersToBePopped
        }
        func popToRootViewControllerAnimated(animated: Bool, completion: ((Bool) -> Void)?) -> [UIViewController] {
            return popToViewController(viewControllers.firstOne, animated: animated, completion: completion)
        }
        func transformAtPercentage(percentage: CGFloat) {
            var frame = view.bounds
            frame.origin.x = frame.width * (1 - percentage)
            currentWrapper.frame = frame
            if previousWrapper != nil {
                previousWrapper!.transform = CGAffineTransformMakeScale(1 - percentage * 0.2, 1 - percentage * 0.2)
                previousWrapper!.overlay.alpha = percentage
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
