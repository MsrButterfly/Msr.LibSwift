import UIKit

extension Msr.UI {
    class SegmentedControl: UIControl {
        private var wrappers = [WrapperView]()
        private var segmentConstraints = [NSLayoutConstraint]() // initially [left][right]
        let leftView = WrapperView(frame: CGRectZero)
        let rightView = WrapperView(frame: CGRectZero)
        let scrollView = UIScrollView()
        private var minWidthConstraint: NSLayoutConstraint!
        var backgroundView: UIView? {
            willSet {
                if newValue != nil {
                    insertSubview(newValue!, belowSubview: scrollView)
                    newValue!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                    newValue!.msr_addAutoExpandingConstraintsToSuperview()
                }
            }
            didSet {
                oldValue?.removeFromSuperview()
            }
        }
        var numberOfSegments: Int {
            get {
                return wrappers.count - 2
            }
        }
        class DefaultHighlightView: AutoExpandingView {
            override func msr_initialize() {
                super.msr_initialize()
                opaque = false
            }
            override func drawRect(rect: CGRect) {
                let context = UIGraphicsGetCurrentContext()
                CGContextSaveGState(context)
                CGContextSetStrokeColorWithColor(context, UIColor.purpleColor().CGColor)
                CGContextSetLineCap(context, kCGLineCapSquare)
                CGContextSetLineWidth(context, 10)
                CGContextMoveToPoint(context, 0, rect.msr_bottom)
                CGContextAddLineToPoint(context, rect.msr_right, rect.msr_bottom)
                CGContextStrokePath(context)
                CGContextRestoreGState(context)
            }
            override func layoutSubviews() {
                super.layoutSubviews()
                setNeedsDisplay()
            }
        }
        private var highlightViewWrapperLeftConstraint: NSLayoutConstraint!
        private var highlightViewWrapperRightConstraint: NSLayoutConstraint!
        private var highlightViewWrapper = UIView()
        private var _highlightView: UIView!
        var highlightView: UIView {
            set {
                _highlightView?.removeFromSuperview()
                _highlightView = newValue
                highlightViewWrapper.addSubview(_highlightView)
                newValue.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                newValue.msr_addAutoExpandingConstraintsToSuperview()
            }
            get {
                return _highlightView
            }
        }
        private var _selectedSegmentIndex: Int?
        var selectedSegmentIndex: Int? {
            set {
                selectSegmentAtIndex(newValue, animated: false)
            }
            get {
                return _selectedSegmentIndex
            }
        }
        func selectSegmentAtIndex(index: Int?, animated: Bool) {
            _selectedSegmentIndex = index
            setNeedsLayout()
            if animated {
                UIView.animateWithDuration(defaultDuration,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: .BeginFromCurrentState,
                    animations: {
                        [weak self] in
                        self?.layoutIfNeeded()
                        return
                    },
                    completion: nil)
            } else {
                layoutIfNeeded()
            }
        }
        var indicatorPosition: CGFloat? // [0, numberOfSegments]
        let defaultDuration = NSTimeInterval(0.5)
        init(views: [UIView]) {
            super.init()
            // msr_initialize() will be called by super.init() -> self.init(frame:)
            for v in views {
                appendSegmentWithView(v, animated: false)
            }
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            msr_initialize()
        }
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func msr_initialize() {
            addSubview(scrollView)
            scrollView.addSubview(leftView)
            scrollView.addSubview(rightView)
            scrollView.addSubview(highlightViewWrapper)
            scrollView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            scrollView.msr_addAutoExpandingConstraintsToSuperview()
            leftView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            leftView.msr_addVerticalExpandingConstraintsToSuperview()
            leftView.msr_addLeftAttachedConstraintToSuperview()
            rightView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            rightView.msr_addVerticalExpandingConstraintsToSuperview()
            rightView.msr_addRightAttachedConstraintToSuperview()
            rightView.msr_addWidthConstraintWithValue(0)
            wrappers = [leftView, rightView]
            let vs = ["l": leftView, "r": rightView]
            segmentConstraints = NSLayoutConstraint.constraintsWithVisualFormat("[l][r]", options: nil, metrics: nil, views: vs) as! [NSLayoutConstraint]
            minWidthConstraint = NSLayoutConstraint(item: rightView, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: scrollView, attribute: .Leading, multiplier: 1, constant: 0)
            scrollView.addConstraints(segmentConstraints)
            scrollView.addConstraint(minWidthConstraint)
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.delaysContentTouches = true
            highlightViewWrapper.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            highlightViewWrapper.msr_addVerticalExpandingConstraintsToSuperview()
            highlightViewWrapper.userInteractionEnabled = false
            highlightView = DefaultHighlightView()
            highlightViewWrapperLeftConstraint = NSLayoutConstraint(item: highlightViewWrapper, attribute: .Leading, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1, constant: 0)
            highlightViewWrapperRightConstraint = NSLayoutConstraint(item: highlightViewWrapper, attribute: .Trailing, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1, constant: 0)
            scrollView.addConstraint(highlightViewWrapperLeftConstraint)
            scrollView.addConstraint(highlightViewWrapperRightConstraint)
        }
        func appendSegmentWithView(view: UIView, animated: Bool) {
            insertSegmentWithView(view, atIndex: numberOfSegments, animated: animated)
        }
        func insertSegmentWithView(view: UIView, atIndex index: Int, animated: Bool) {
            if index <= selectedSegmentIndex {
                _selectedSegmentIndex! += 1
            }
            let wrapper = WrapperView()
            wrapper.contentView = view
            wrapper.button.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
            wrappers.insert(wrapper, atIndex: index + 1)
            scrollView.insertSubview(wrapper, belowSubview: highlightViewWrapper)
            let vs = ["l": wrappers[index], "r": wrappers[index + 2], "w": wrapper]
            scrollView.removeConstraint(segmentConstraints[index])
            wrapper.msr_addTopAttachedConstraintToSuperview()
            addConstraint(NSLayoutConstraint(item: wrapper, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[w]|", options: nil, metrics: nil, views: vs))
            segmentConstraints.replaceRange(index...index, with: NSLayoutConstraint.constraintsWithVisualFormat("[l][w][r]", options: nil, metrics: nil, views: vs) as! [NSLayoutConstraint])
            scrollView.addConstraints(Array(segmentConstraints[index...index + 1]))
            wrapper.bounds.size = CGSize(width: wrapper.defaultValueOfWidthConstraint, height: bounds.height)
            wrapper.frame.origin = CGPoint(x: wrappers[index].frame.msr_left, y: 0)
            wrapper.alpha = 0
            setNeedsLayout()
            if animated {
                UIView.animateWithDuration(defaultDuration,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: .BeginFromCurrentState,
                    animations: {
                        [weak self] in
                        wrapper.alpha = 1
                        self?.layoutIfNeeded()
                        return
                    },
                    completion: nil)
            } else {
                wrapper.alpha = 1
                layoutIfNeeded()
            }
        }
        func removeSegmentAtIndex(index: Int, animated: Bool) {
            if index <= selectedSegmentIndex {
                _selectedSegmentIndex! -= 1
            }
            let wrapper = wrappers.removeAtIndex(index + 1)
            scrollView.removeConstraints(Array(segmentConstraints[index...index + 1]))
            let vs = ["l": wrappers[index], "r": wrappers[index + 1]]
            segmentConstraints.replaceRange(index...index + 1, with: NSLayoutConstraint.constraintsWithVisualFormat("[l][r]", options: nil, metrics: nil, views: vs) as! [NSLayoutConstraint])
            scrollView.addConstraint(segmentConstraints[index])
            setNeedsLayout()
            if animated {
                UIView.animateWithDuration(defaultDuration,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: .BeginFromCurrentState,
                    animations: {
                        [weak self] in
                        wrapper.alpha = 0
                        self?.layoutIfNeeded()
                        return
                    },
                    completion: {
                        finished in
                        wrapper.removeFromSuperview()
                        return
                    })
            } else {
                wrapper.alpha = 0
                layoutIfNeeded()
                wrapper.removeFromSuperview()
            }
        }
        internal func didPressButton(button: UIButton) {
            for (i, w) in enumerate(wrappers[1...wrappers.endIndex - 2]) {
                if button === w.button {
                    selectSegmentAtIndex(i, animated: true)
                    break
                }
            }
        }
        override func layoutSubviews() {
            minWidthConstraint.constant = bounds.width
            var s: CGFloat = 0
            for w in wrappers {
                s += w.defaultValueOfWidthConstraint
            }
            var highlightLeft: CGFloat = 0
            var highlightRight: CGFloat = 0
            if numberOfSegments > 0 {
                var currentLeft: CGFloat = 0
                if s < bounds.width {
                    let increment = (bounds.width - s) / CGFloat(numberOfSegments)
                    for (i, w) in enumerate(wrappers[1...wrappers.endIndex - 2]) {
                        w.setAdditionWidthToWidthConstraintWithValue(increment)
                        if selectedSegmentIndex == i {
                            highlightLeft = currentLeft
                            highlightRight = currentLeft + w.widthConstraint.constant
                        }
                        currentLeft += w.widthConstraint.constant
                    }
                } else {
                    for (i, w) in enumerate(wrappers[1...wrappers.endIndex - 2]) {
                        w.resetWidthConstraint()
                        if selectedSegmentIndex == i {
                            highlightLeft = currentLeft
                            highlightRight = currentLeft + w.widthConstraint.constant
                        }
                        currentLeft += w.widthConstraint.constant
                    }
                }
            }
            highlightViewWrapperLeftConstraint.constant = 0
            highlightViewWrapperRightConstraint.constant = highlightRight
            highlightViewWrapperLeftConstraint.constant = highlightLeft
            super.layoutSubviews()
        }
        class WrapperView: UIView {
            var contentView: UIView? {
                willSet {
                    if newValue != nil {
                        insertSubview(newValue!, aboveSubview: button)
                        newValue!.frame = bounds
                        newValue!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                        newValue!.msr_addAutoExpandingConstraintsToSuperview()
                    }
                }
                didSet {
                    oldValue?.removeFromSuperview()
                    resetWidthConstraint()
                }
            }
            override var frame: CGRect {
                didSet {
                    contentView?.frame = bounds
                }
            }
            override var bounds: CGRect {
                didSet {
                    contentView?.frame = bounds
                }
            }
            override var center: CGPoint {
                didSet {
                    contentView?.center = center
                }
            }
            private var widthConstraint: NSLayoutConstraint!
            var button: UIButton!
            override init() {
                super.init()
                // msr_initialize() will be invoked by init(frame:).
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
                button = UIButton(frame: bounds)
                button.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                button.setBackgroundImage(UIImage.msr_rectangleWithColor(UIColor.blackColor().colorWithAlphaComponent(0.2), size: CGSize(width: 1, height: 1)), forState: .Highlighted)
                addSubview(button)
                msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: defaultValueOfWidthConstraint)
                addConstraint(widthConstraint)
            }
            func resetWidthConstraint() {
                widthConstraint.constant = defaultValueOfWidthConstraint
            }
            func setAdditionWidthToWidthConstraintWithValue(value: CGFloat) {
                widthConstraint.constant = defaultValueOfWidthConstraint + value
            }
            var defaultValueOfWidthConstraint: CGFloat {
                return contentView?.intrinsicContentSize().width ?? 0
            }
        }
    }
}
