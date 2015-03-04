import UIKit

@objc protocol MsrSegmentedViewControllerDelegate: NSObjectProtocol {
    optional func msr_segmentedViewController(segmentedViewController: Msr.UI.SegmentedViewController, didDeselectViewController viewController: UIViewController)
    optional func msr_segmentedViewController(segmentedViewController: Msr.UI.SegmentedViewController, didSelectViewController viewController: UIViewController)
}

extension Msr.UI {
    @objc class SegmentedViewController: UIViewController, UIToolbarDelegate, UIScrollViewDelegate, SegmentedControl.Delegate {
        typealias Delegate = MsrSegmentedViewControllerDelegate
        private(set) var viewControllers: [UIViewController] = []
        let segmentedControl = SegmentedControl()
        let scrollView = UIScrollView()
        var delegate: Delegate?
        var wrappers = [WrapperView]()
        var backgroundBar = UIToolbar()
        private let leftView = WrapperView()
        private let rightView = WrapperView()
        enum SegmentedControlPosition {
            case Top
            case Bottom
        }
        class var positionOfSegmentedControl: SegmentedControlPosition {
            return .Bottom
        }
        var selectedIndex: Int? {
            return segmentedControl.selectedSegmentIndex
        }
        var selectedViewController: UIViewController? {
            return selectedIndex == nil ? nil : viewControllers[selectedIndex!]
        }
        var numberOfViewControllers: Int {
            return viewControllers.count
        }
        override init() {
            super.init()
            // msr_initialize() will be invoked by super.init() -> self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        init(viewControllers: [UIViewController]) {
            super.init()
            // msr_initialize() will be invoked by super.init() -> self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            setViewControllers(viewControllers, animated: false)
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
            let _ = view // Views should be loaded in intializers.
        }
        override func loadView() {
            super.loadView()
            view = AutoExpandingView()
            view.removeConstraints(view.constraints() as! [NSLayoutConstraint])
            view.addSubview(scrollView)
            view.addSubview(segmentedControl)
            scrollView.addSubview(leftView)
            scrollView.addSubview(rightView)
            let position = self.dynamicType.positionOfSegmentedControl
            let heights: [SegmentedControlPosition: CGFloat] = [
                .Top: _Detail.SegmentedControlDefaultHeightAtTop,
                .Bottom: _Detail.SegmentedControlDefaultHeightAtBottom]
            segmentedControl.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            segmentedControl.msr_addHeightConstraintWithValue(heights[position]!)
            segmentedControl.msr_addHorizontalExpandingConstraintsToSuperview()
            segmentedControl.backgroundView = backgroundBar
            segmentedControl.delegate = self
            segmentedControl.addTarget(self, action: "segmentedControlValueDidChange:", forControlEvents: .ValueChanged)
            segmentedControl.addObserver(self, forKeyPath: "indicatorPosition", options: .New, context: nil)
            backgroundBar.delegate = self
            scrollView.delegate = self
            scrollView.pagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            scrollView.msr_addHorizontalExpandingConstraintsToSuperview()
            // If write UILayoutPriorityDefaultLow in iOS8 SDK, a link error will occur. This might be a bug.
            scrollView.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0))
            wrappers = [leftView, rightView]
            leftView.msr_addVerticalExpandingConstraintsToSuperview()
            leftView.msr_addLeftAttachedConstraintToSuperview()
            leftView.msr_addWidthConstraintWithValue(0)
            rightView.msr_addVerticalExpandingConstraintsToSuperview()
            rightView.msr_addRightAttachedConstraintToSuperview()
            rightView.msr_addWidthConstraintWithValue(0)
            let vs = ["l": leftView, "r": rightView, "sc": segmentedControl, "v": scrollView]
            wrapperConstraints = NSLayoutConstraint.constraintsWithVisualFormat("[l][r]", options: nil, metrics: nil, views: vs) as! [NSLayoutConstraint]
            scrollView.addConstraints(wrapperConstraints)
            let formats: [SegmentedControlPosition: String] = [
                .Top: "V:|[sc][v]|",
                .Bottom: "V:|[v][sc]|"]
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(formats[position]!, options: nil, metrics: nil, views: vs))
        }
        func appendViewController(viewController: UIViewController, animated: Bool) {}
        func extendViewControllers(viewControllers: [UIViewController], animated: Bool) {}
        func indexOfViewController(viewController: UIViewController) -> Int? { return nil }
        func insertViewController(viewController: UIViewController, animated: Bool) {}
        func insertViewControllers(viewControllers: [UIViewController], animated: Bool) {}
        func removeViewController(viewController: UIViewController, animated: Bool) {}
        func removeViewControllerAtIndex(index: Int, animated: Bool) {}
        func removeViewControllersInRange(range: Range<Int>, animated: Bool) {}
        func replaceViewController(viewController: UIViewController, withViewController newViewController: UIViewController, animated: Bool) {}
        func replaceViewControllerAtIndex(index: Int, withViewController newViewController: UIViewController, animated: Bool) {}
        func replaceViewControllersInRange(range: Range<Int>, withViewControllers newViewControllers: [UIViewController], animated: Bool) {
            // calculate value
            let numberOfWrappersToBeRemoved = range.endIndex - range.startIndex
            let numberOfWrappersToBeInserted = newViewControllers.count
            let numberOfConstraintsToBeRemoved = numberOfWrappersToBeRemoved + 1
            let numberOfConstraintsToBeInserted = numberOfWrappersToBeInserted + 1
            let indexOfFirstWrapperToBeRemoved = range.startIndex + 1
            let indexOfLastWrapperToBeRemoved = range.endIndex
            let indexOfFirstWrapperToBeInserted = indexOfFirstWrapperToBeRemoved
            let indexOfLastWrapperToBeInserted = indexOfFirstWrapperToBeInserted + numberOfWrappersToBeInserted - 1
            let indexOfFirstConstraintToBeRemoved = indexOfFirstWrapperToBeRemoved - 1
            let indexOfLastConstraintToBeRemoved = indexOfFirstConstraintToBeRemoved + numberOfConstraintsToBeRemoved - 1
            let indexOfFirstConstraintToBeInserted = indexOfFirstConstraintToBeRemoved
            let indexOfLastConstraintToBeInserted = indexOfFirstConstraintToBeInserted + numberOfConstraintsToBeInserted - 1
            let viewControllersToBeRemoved = viewControllers[range]
            let viewControllersToBeInserted = newViewControllers
            let rangeOfViewControllersToBeRemoved = range
            let rangeOfSegmentsToBeRemoved = range
            let rangeOfWrappersToBeRemoved = indexOfFirstWrapperToBeRemoved..<indexOfLastWrapperToBeRemoved + 1
            let rangeOfConstraintsToBeRemoved = indexOfFirstConstraintToBeRemoved..<indexOfLastConstraintToBeRemoved + 1
            // replace wrappers
            let wrappersToBeRemoved = wrappers[rangeOfWrappersToBeRemoved]
            var wrappersToBeInserted = [WrapperView]()
            for vc in viewControllersToBeInserted {
                addChildViewController(vc)
                let w = WrapperView()
                w.contentView = vc.view
                scrollView.addSubview(w)
                scrollView.addConstraint(NSLayoutConstraint(item: w, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0))
                scrollView.addConstraint(NSLayoutConstraint(item: w, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0))
                wrappersToBeInserted.append(w)
            }
            for vc in viewControllersToBeRemoved {
                vc.removeFromParentViewController()
            }
            wrappers.replaceRange(rangeOfWrappersToBeRemoved, with: wrappersToBeInserted)
            viewControllers.replaceRange(rangeOfViewControllersToBeRemoved, with: viewControllersToBeInserted)
            // replace constraints
            let constraintsToBeRemoved = Array(wrapperConstraints[rangeOfConstraintsToBeRemoved])
            var constraintsToBeInserted = [NSLayoutConstraint]()
            scrollView.removeConstraints(constraintsToBeRemoved)
            for i in indexOfFirstConstraintToBeInserted...indexOfLastConstraintToBeInserted {
                let lw = wrappers[i]
                let rw = wrappers[i + 1]
                if i < indexOfLastConstraintToBeInserted {
                    rw.alpha = 0
                }
                constraintsToBeInserted.extend(NSLayoutConstraint.constraintsWithVisualFormat("[l][r]", options: nil, metrics: nil, views: ["l": lw, "r": rw]) as! [NSLayoutConstraint])
            }
            wrapperConstraints.replaceRange(rangeOfConstraintsToBeRemoved, with: constraintsToBeInserted)
            scrollView.addConstraints(constraintsToBeInserted)
            // layout
            let animations: () -> Void = {
                [weak self] in
                for w in wrappersToBeInserted {
                    w.alpha = 1
                }
                for w in wrappersToBeRemoved {
                    w.alpha = 0
                }
                self?.view.layoutIfNeeded()
                return
            }
            let completion: (Bool) -> Void = {
                finished in
                for w in wrappersToBeRemoved {
                    w.removeFromSuperview()
                }
            }
            scrollView.setNeedsUpdateConstraints()
            scrollView.setNeedsLayout()
            if animated {
                UIView.animateWithDuration(segmentedControl.animationDuration,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: .BeginFromCurrentState,
                    animations: animations,
                    completion: completion)
            } else {
                animations()
                completion(true)
            }
            var segments = [Segment]()
            for vc in newViewControllers {
                let s = DefaultSegment(title: vc.title, image: nil)
                let sizes: [SegmentedControlPosition: CGFloat] = [
                    .Top: 12,
                    .Bottom: 9
                ]
                let position = self.dynamicType.positionOfSegmentedControl
                s.titleLabel.font = s.titleLabel.font.fontWithSize(sizes[position]!)
                if position == .Bottom {
                    s.image = UIImage.msr_rectangleWithColor(UIColor.blackColor(), size: CGSize(width: 20, height: 20))
                }
                segments.append(s)
            }
            segmentedControl.replaceSegmentsInRange(rangeOfSegmentsToBeRemoved, withSegments: segments, animated: animated)
            if segmentedControl.selectedSegmentIndex == nil && viewControllers.count >= 1 {
                segmentedControl.selectSegmentAtIndex(0, animated: animated)
            }
        }
        func setViewControllers(newViewControllers: [UIViewController], animated: Bool) {
            replaceViewControllersInRange(0..<numberOfViewControllers, withViewControllers: newViewControllers, animated: animated)
        }
        func selectViewController(viewController: UIViewController, animated: Bool) {
            
        }
        func selectViewControllerAtIndex(index: Int?, animated: Bool) {}
        func viewControllerAtIndex(index: Int) -> UIViewController? { return nil }
        func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
            if bar === backgroundBar {
                let ps: [SegmentedControlPosition: UIBarPosition] = [
                    .Top: .Top,
                    .Bottom: .Bottom]
                return ps[self.dynamicType.positionOfSegmentedControl]!
            }
            return .Any
        }
        private var wrapperConstraints = [NSLayoutConstraint]()
        func scrollViewDidScroll(scrollView: UIScrollView) {
            if scrollView === self.scrollView && !segmentedControl.valueChangedByUserInteraction {
                let offset = scrollView.contentOffset
                let position = min(max(Float(offset.x / view.bounds.width), Float(0)), Float(numberOfViewControllers - 1))
                segmentedControl.setIndicatorPosition(position, animated: false)
                segmentedControl.scrollIndicatorToVisibleAnimated(false)
            }
        }
        func segmentedControlValueDidChange(segmentedControl: SegmentedControl) {
            if segmentedControl === self.segmentedControl {
                if segmentedControl.valueChangedByUserInteraction {
                    UIView.animateWithDuration(segmentedControl.animationDuration,
                        delay: 0,
                        usingSpringWithDamping: 1,
                        initialSpringVelocity: 0,
                        options: .BeginFromCurrentState,
                        animations: {
                            [weak self] in
                            self?.scrollView.setContentOffset(CGPoint(x: self!.view.bounds.width * CGFloat(self!.segmentedControl.selectedSegmentIndex ?? 0), y: 0), animated: false)
                            return
                        },
                        completion: {
                            [weak self] finished in
                            self?.segmentedControl.valueChangedByUserInteraction = false
                            return
                        })
                }
                if segmentedControl.selectedSegmentIndexChanged {
                    title = selectedViewController?.title ?? ""
                }
            }
        }
        class WrapperView: UIView {
            var contentView: UIView? {
                willSet {
                    if newValue != nil {
                        addSubview(newValue!)
                        newValue!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                        newValue!.msr_addAutoExpandingConstraintsToSuperview()
                    }
                }
                didSet {
                    oldValue?.removeFromSuperview()
                }
            }
            override init() {
                super.init()
                // msr_initialize() will be invoked by super.init() -> self.init(frame:)
            }
            required init(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
                msr_initialize()
            }
            override init(frame: CGRect) {
                super.init(frame: frame)
                msr_initialize()
            }
            func msr_initialize() {
                msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            }
        }
        deinit {
            segmentedControl.removeObserver(self, forKeyPath: "indicatorPosition")
        }
    }
}
