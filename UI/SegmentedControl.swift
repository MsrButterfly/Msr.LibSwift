import UIKit

/*

Functional Synopsis

extension Msr.UI {

    class SegmentedControl: UIControl {

        init(views: [UIView])
        override init(frame: CGRect)
        required init(coder: NSCoder)

        var animationDuration: NSTimeInterval // default 0.5
        var backgroundView: UIView?
        var indicatorPosition: CGFloat?
        var indicatorView: UIView // default Msr.UI.SegmentedControl.DefaultIndicatorView
        var numberOfSegments: Int
        var selectedSegmentIndex: Int?

        func appendSegmentWithView(view: UIView, animated: Bool)
        func insertSegmentWithView(view: UIView, atIndex index: Int, animated: Bool)
        func removeSegmentAtIndex(index: Int, animated: Bool)
        func selectSegmentAtIndex(index: Int?, animated: Bool)
        func setIndicatorPosition(position: CGFloat?, animated: Bool)

        class DefaultIndicatorView: AutoExpandingView
        class WrapperView: UIView

    }

}

*/

extension Msr.UI {
    class SegmentedControl: UIControl {
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
            super.init(coder: aDecoder)
            msr_initialize()
        }
        var animationDuration = NSTimeInterval(0.5)
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
        var indicatorPosition: CGFloat? {
            set {
                setIndicatorPosition(newValue, animated: false)
            }
            get {
                return _indicatorPosition
            }
        }
        var indicatorView: UIView {
            set {
                _indicatorView?.removeFromSuperview()
                _indicatorView = newValue
                indicatorViewWrapper.addSubview(_indicatorView)
                newValue.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                newValue.msr_addAutoExpandingConstraintsToSuperview()
            }
            get {
                return _indicatorView
            }
        }
        var numberOfSegments: Int {
            get {
                return wrappers.count - 2
            }
        }
        var selectedSegmentIndex: Int? {
            set {
                selectSegmentAtIndex(newValue, animated: false)
            }
            get {
                return _selectedSegmentIndex
            }
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
            scrollView.insertSubview(wrapper, belowSubview: indicatorViewWrapper)
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
                UIView.animateWithDuration(animationDuration,
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
                UIView.animateWithDuration(animationDuration,
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
        func selectSegmentAtIndex(index: Int?, animated: Bool) {
            setIndicatorPosition(index == nil ? nil : CGFloat(index!), animated: animated)
        }
        func setIndicatorPosition(position: CGFloat?, animated: Bool) {
            _indicatorPosition = position
            if position != nil {
                let value = position!
                let l = Int(floor(value))
                let r = Int(ceil(value))
                let p = value - CGFloat(l)
                _selectedSegmentIndex = p < 0.5 ? l : r
            } else {
                _selectedSegmentIndex = nil
            }
            setNeedsLayout()
            if animated {
                UIView.animateWithDuration(animationDuration,
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
        override func layoutSubviews() {
            minWidthConstraint.constant = bounds.width
            let value = indicatorPosition ?? 0
            let l = Int(floor(value))
            let r = Int(ceil(value))
            var lp: CGFloat = 0
            var mp: CGFloat = 0
            var rp: CGFloat = 0
            var s: CGFloat = 0
            for (i, w) in enumerate(wrappers[1...wrappers.endIndex - 2]) {
                let c = w.defaultValueOfWidthConstraint
                s += c
                if i < l {
                    lp += c
                }
                if i <= l {
                    mp += c
                }
                if i <= r {
                    rp += c
                }
            }
            if s < bounds.width {
                let increment = (bounds.width - s) / CGFloat(numberOfSegments)
                lp += CGFloat(l) * increment
                mp += CGFloat(l + 1) * increment
                rp += CGFloat(r + 1) * increment
                for w in wrappers[1...wrappers.endIndex - 2] {
                    w.setAdditionWidthToWidthConstraintWithValue(increment)
                }
            } else {
                for w in wrappers[1...wrappers.endIndex - 2] {
                    w.resetWidthConstraint()
                }
            }
            let p = value - CGFloat(l)
            indicatorViewWrapperLeftConstraint.constant = 0
            indicatorViewWrapperRightConstraint.constant = mp + (rp - mp) * p
            indicatorViewWrapperLeftConstraint.constant = lp + (mp - lp) * p
            if indicatorPosition == nil {
                indicatorViewWrapperLeftConstraint.constant = 0
                indicatorViewWrapperRightConstraint.constant = 0
            }
            super.layoutSubviews()
        }
        class DefaultIndicatorView: AutoExpandingView {
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
        internal func msr_initialize() {
            addSubview(scrollView)
            scrollView.addSubview(leftView)
            scrollView.addSubview(rightView)
            scrollView.addSubview(indicatorViewWrapper)
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
            indicatorViewWrapper.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            indicatorViewWrapper.msr_addVerticalExpandingConstraintsToSuperview()
            indicatorViewWrapper.userInteractionEnabled = false
            indicatorView = DefaultIndicatorView()
            indicatorViewWrapperLeftConstraint = NSLayoutConstraint(item: indicatorViewWrapper, attribute: .Leading, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1, constant: 0)
            indicatorViewWrapperRightConstraint = NSLayoutConstraint(item: indicatorViewWrapper, attribute: .Trailing, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1, constant: 0)
            scrollView.addConstraint(indicatorViewWrapperLeftConstraint)
            scrollView.addConstraint(indicatorViewWrapperRightConstraint)
        }
        internal func didPressButton(button: UIButton) {
            for (i, w) in enumerate(wrappers[1...wrappers.endIndex - 2]) {
                if button === w.button {
                    selectSegmentAtIndex(i, animated: true)
                    break
                }
            }
        }
        private var wrappers = [WrapperView]()
        private var segmentConstraints = [NSLayoutConstraint]() // initially [left][right]
        private let leftView = WrapperView(frame: CGRectZero)
        private let rightView = WrapperView(frame: CGRectZero)
        private let scrollView = UIScrollView()
        private var minWidthConstraint: NSLayoutConstraint!
        private var indicatorViewWrapperLeftConstraint: NSLayoutConstraint!
        private var indicatorViewWrapperRightConstraint: NSLayoutConstraint!
        private var indicatorViewWrapper = UIView()
        private var _indicatorPosition: CGFloat?
        private var _indicatorView: UIView!
        private var _selectedSegmentIndex: Int? {
            didSet {
                if _selectedSegmentIndex != oldValue {
                    sendActionsForControlEvents(.ValueChanged)
                }
            }
        }
    }
}
