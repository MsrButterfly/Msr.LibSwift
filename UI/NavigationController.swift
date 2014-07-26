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
                    completion: completion)
            } else {
                transformAtPercentage(1)
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
                        completion: nil)
                }
                break
            default:
                break
            }
        }
        func popViewController(animated: Bool, completion: ((Bool) -> Void)?) -> UIViewController {
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
                    self!.currentViewController.removeFromParentViewController()
                    self!.currentViewController.view.removeFromSuperview()
                    self!.wrappers.removeLast()
                    self!.viewControllers.removeLast()
                    self!.gestures.removeLast()
                    if self!.viewControllers.count > 1 {
                        self!.currentGesture.enabled = true
                    }
                })
            return viewController
        }
        func transformAtPercentage(percentage: CGFloat) {
            var frame = view.bounds
            frame.origin.x = frame.width * (1 - percentage)
            currentWrapper.frame = frame
            if previousWrapper != nil {
                previousWrapper!.transform = CGAffineTransformMakeScale(1 - percentage * 0.2, 1 - percentage * 0.2)
                previousWrapper!.alpha = 1 - percentage
            }
        }
        var currentViewController: UIViewController! {
            get {
                return viewControllers.lastOne
            }
        }
        var previousViewController: UIViewController! {
            get {
                return viewControllers.count > 1 ? viewControllers[viewControllers.lastIndex - 1] : nil
            }
        }
        private var currentWrapper: WrapperView! {
            get {
                return wrappers.lastOne
            }
        }
        private var previousWrapper: WrapperView! {
            get {
                return wrappers.count > 1 ? wrappers[wrappers.lastIndex - 1] : nil
            }
        }
        private var currentGesture: UIPanGestureRecognizer! {
            get {
                return gestures.lastOne
            }
        }
        private var previousGesture: UIPanGestureRecognizer! {
            get {
                return gestures.count > 1 ? gestures[gestures.lastIndex - 1] : nil
            }
        }
        class WrapperView: UIView {
            let navigationBar = UINavigationController().navigationBar
            init(frame: CGRect) {
                super.init(frame: frame)
                navigationBar.center.x = center.x
                addSubview(navigationBar)
            }
        }
    }
}
