@objc protocol MSRSegmentedViewControllerDelegate: NSObjectProtocol {
    optional func msr_segmentedViewController(segmentedViewController: MSRSegmentedViewController, didDeselectViewController viewController: UIViewController)
    optional func msr_segmentedViewController(segmentedViewController: MSRSegmentedViewController, didSelectViewController viewController: UIViewController)
}

@objc enum MSRSegmentedControlPosition: Int {
    case Top = 1
    case Bottom
}

var _MSRSegmentedControlDefaultHeightAtTop: CGFloat { return 32 }
var _MSRSegmentedControlDefaultHeightAtBottom: CGFloat { return 50 }

@objc class MSRSegmentedViewController: UIViewController, UIToolbarDelegate, UIScrollViewDelegate, MSRSegmentedControlDelegate {
    private(set) var viewControllers: [UIViewController] = []
    let segmentedControl = MSRSegmentedControl()
    let scrollView = UIScrollView()
    var delegate: MSRSegmentedViewControllerDelegate?
    var wrappers = [_MSRSegmentedViewControllerWrapperView]()
    var backgroundBar = UIToolbar()
    private let leftView = _MSRSegmentedViewControllerWrapperView()
    private let rightView = _MSRSegmentedViewControllerWrapperView()
    class var positionOfSegmentedControl: MSRSegmentedControlPosition {
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
        view.addSubview(scrollView)
        view.addSubview(segmentedControl)
        scrollView.addSubview(leftView)
        scrollView.addSubview(rightView)
        let position = self.dynamicType.positionOfSegmentedControl
        let heights: [MSRSegmentedControlPosition: CGFloat] = [
            .Top: _MSRSegmentedControlDefaultHeightAtTop,
            .Bottom: _MSRSegmentedControlDefaultHeightAtBottom]
        segmentedControl.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        segmentedControl.msr_addHeightConstraintWithValue(heights[position]!)
        segmentedControl.msr_addHorizontalEdgeAttachedConstraintsToSuperview()
        segmentedControl.backgroundView = backgroundBar
        segmentedControl.delegate = self
        segmentedControl.addTarget(self, action: "segmentedControlValueDidChange:", forControlEvents: .ValueChanged)
        backgroundBar.delegate = self
        segmentedControl.indicator = MSRBlockIndicator()
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        scrollView.msr_addHorizontalEdgeAttachedConstraintsToSuperview()
        wrappers = [leftView, rightView]
        leftView.msr_addVerticalEdgeAttachedConstraintsToSuperview()
        leftView.msr_addLeftAttachedConstraintToSuperview()
        leftView.msr_addWidthConstraintWithValue(0)
        rightView.msr_addVerticalEdgeAttachedConstraintsToSuperview()
        rightView.msr_addRightAttachedConstraintToSuperview()
        rightView.msr_addWidthConstraintWithValue(0)
        let vs: [String: AnyObject] = ["l": leftView, "r": rightView, "sc": segmentedControl, "sv": scrollView, "tg": topLayoutGuide, "bg": bottomLayoutGuide]
        wrapperConstraints = NSLayoutConstraint.constraintsWithVisualFormat("[l][r]", options: nil, metrics: nil, views: vs) as! [NSLayoutConstraint]
        scrollView.addConstraints(wrapperConstraints)
        let formats: [MSRSegmentedControlPosition: String] = [
            .Top: "V:[tg][sc]-(>=0)-[bg]",
            .Bottom: "V:[tg]-(>=0)-[sc][bg]"]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(formats[position]!, options: nil, metrics: nil, views: vs))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sv][bg]", options: nil, metrics: nil, views: vs))
        automaticallyAdjustsScrollViewInsets = false
    }
    func appendViewController(viewController: UIViewController, animated: Bool) {
        extendViewControllers([viewController], animated: animated)
    }
    func extendViewControllers(viewControllers: [UIViewController], animated: Bool) {
        replaceViewControllersInRange(numberOfViewControllers..<numberOfViewControllers, withViewControllers: viewControllers, animated: animated)
    }
    func indexOfViewController(viewController: UIViewController) -> Int? {
        return find(viewControllers, viewController)
    }
    func insertViewController(viewController: UIViewController, atIndex index: Int, animated: Bool) {
        insertViewControllers([viewController], atIndex: index, animated: animated)
    }
    func insertViewControllers(viewControllers: [UIViewController], atIndex index: Int, animated: Bool) {
        replaceViewControllersInRange(index..<index, withViewControllers: viewControllers, animated: animated)
    }
    func removeViewController(viewController: UIViewController, animated: Bool) {
        removeViewControllerAtIndex(indexOfViewController(viewController)!, animated: animated)
    }
    func removeViewControllerAtIndex(index: Int, animated: Bool) {
        removeViewControllersInRange(index...index, animated: animated)
    }
    func removeViewControllersInRange(range: Range<Int>, animated: Bool) {
        replaceViewControllersInRange(range, withViewControllers: [], animated: animated)
    }
    func replaceViewController(viewController: UIViewController, withViewController newViewController: UIViewController, animated: Bool) {
        replaceViewControllerAtIndex(indexOfViewController(viewController)!, withViewController: newViewController, animated: animated)
    }
    func replaceViewControllerAtIndex(index: Int, withViewController newViewController: UIViewController, animated: Bool) {
        replaceViewControllersInRange(index...index, withViewControllers: [newViewController], animated: animated)
    }
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
        var wrappersToBeInserted = [_MSRSegmentedViewControllerWrapperView]()
        for vc in viewControllersToBeInserted {
            addChildViewController(vc)
            let w = _MSRSegmentedViewControllerWrapperView()
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
        var segments = [MSRSegment]()
        for vc in newViewControllers {
            let s = MSRDefaultSegment(title: vc.title, image: nil)
            let sizes: [MSRSegmentedControlPosition: CGFloat] = [
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
        let index = indexOfViewController(viewController)!
    }
    func selectViewControllerAtIndex(index: Int?, animated: Bool) {
        if !animated {
            scrollView.contentOffset.x = view.bounds.width * CGFloat(index ?? 0)
        }
        segmentedControl.selectSegmentAtIndex(index, animated: animated)
    }
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        return viewControllers[index]
    }
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        if bar === backgroundBar {
            let ps: [MSRSegmentedControlPosition: UIBarPosition] = [
                .Top: .Top,
                .Bottom: .Bottom]
            return ps[self.dynamicType.positionOfSegmentedControl]!
        }
        return .Any
    }
    private var wrapperConstraints = [NSLayoutConstraint]()
    internal func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === self.scrollView && !segmentedControl.valueChangedByUserInteraction && selectedIndex != nil {
            let offset = scrollView.contentOffset
            let position = min(max(Float(offset.x / view.bounds.width), Float(-1)), Float(numberOfViewControllers))
            segmentedControl.setIndicatorPosition(position, animated: false)
            segmentedControl.scrollIndicatorToVisibleAnimated(false)
        }
    }
    internal func segmentedControlValueDidChange(segmentedControl: MSRSegmentedControl) {
        if segmentedControl === self.segmentedControl {
            if segmentedControl.valueChangedByUserInteraction {
                UIView.animateWithDuration(segmentedControl.animationDuration,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: .BeginFromCurrentState,
                    animations: {
                        [weak self] in
                        self?.scrollView.contentOffset.x = self!.view.bounds.width * CGFloat(self!.segmentedControl.selectedSegmentIndex ?? 0)
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
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let originalSize = view.bounds.size
        let originalOffset = scrollView.contentOffset
        coordinator.animateAlongsideTransition(
            /* animation: */ {
                [weak self] _ in
                self?.scrollView.contentOffset.x = originalOffset.x / originalSize.width * size.width
                // Not 'self?.scrollView.contentOffset.x *= size.width / originalSize.width',
                //     because self?.scrollView.contentOffset.x will be changed at the beginning,
                //     maybe the 2nd animation loop.
                return
            },
            completion: nil)
    }
    deinit {
        scrollView.delegate = nil // App may crash without it.
    }
    
}

@objc class _MSRSegmentedViewControllerWrapperView: UIView {
    var contentView: UIView? {
        willSet {
            if newValue != nil {
                addSubview(newValue!)
                newValue!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                newValue!.msr_addAllEdgeAttachedConstraintsToSuperview()
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
    override func didMoveToSuperview() {
        if superview != nil {
            msr_addVerticalEdgeAttachedConstraintsToSuperview()
        }
    }
    override func willMoveToSuperview(newSuperview: UIView?) {
        if superview != nil {
            msr_removeVerticalEdgeAttachedConstraintsFromSuperview()
        }
    }
}
