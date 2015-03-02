import UIKit

/*

Functional Synopsis

@objc protocol MsrSegmentedControlDelegate {

}

extension Msr.UI {

    class SegmentedControl: UIControl {

        init(views: [UIView])
        override init(frame: CGRect)
        required init(coder: NSCoder)

        var animationDuration: NSTimeInterval // default 0.5
        var backgroundView: UIView? // default nil
        var indicatorPosition: Float? // 0...numberOfSegments - 1
        var indicatorView: UIView // default Msr.UI.SegmentedControl.DefaultIndicatorView
        var numberOfSegments: Int
        var selectedSegmentIndex: Int? // 0...numberOfSegments - 1

        func appendSegmentWithView(view: UIView, animated: Bool)
        func indexOfSegment(segment: Segment) -> Int?
        func insertSegmentWithView(view: UIView, atIndex index: Int, animated: Bool)
        func removeSegmentAtIndex(index: Int, animated: Bool)
        func scrollIndicatorToVisibleAnimated(animated: Bool)
        func scrollIndicatorToCenterAnimated(animated: Bool)
        func segmentAtIndex(index: Int) -> UIView
        func selectSegmentAtIndex(index: Int?, animated: Bool)
        func setIndicatorPosition(position: Float?, animated: Bool)

        class DefaultIndicatorView: AutoExpandingView
        class Segment: AutoExpandingView
        class DefaultSegment: Segment
        class WrapperView: UIView

    }

}

*/

extension Msr.UI {
    @objc class SegmentedControl: UIControl {
        override init() {
            super.init()
            // msr_initialize() will be called by super.init() -> self.init(frame:)
        }
        init(segments: [Segment]) {
            super.init()
            // msr_initialize() will be called by super.init() -> self.init(frame:)
            for s in segments {
                appendSegment(s, animated: false)
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
        var indicatorPosition: Float? {
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
                return selectedSegmentIndexFromIndicatorPosition(indicatorPosition)
            }
        }
        func appendSegment(segment: Segment, animated: Bool) {
            insertSegment(segment, atIndex: numberOfSegments, animated: animated)
        }
        func indexOfSegment(segment: Segment) -> Int? {
            if numberOfSegments == 0 {
                return nil
            }
            return find(map(wrappers[0...wrappers.endIndex - 2], { $0.segment ?? Segment() }), segment)
        }
        func insertSegment(segment: Segment, atIndex index: Int, animated: Bool) {
            replaceSegmentsInRange(index..<index, withSegments: [segment], animated: animated)
        }
        func removeSegmentAtIndex(index: Int, animated: Bool) {
            replaceSegmentsInRange(index...index, withSegments: [], animated: animated)
        }
        func replaceSegmentsInRange(range: Range<Int>, withSegments segments: [Segment], animated: Bool) {
            println("ATTEMPING TO REPLACE SEGMENTS ON RANGE \(range) WITH \(segments.count) NEW SEGMENTS.")
            assert(range.isEmpty || (0 <= range.startIndex && range.endIndex <= numberOfSegments), "out of range: [0, numberOfSegments - 1]")
            // selected segment index calculation
            let numberOfSegmentsToBeRemoved = range.endIndex - range.startIndex
            let numberOfSegmentsToBeInserted = segments.count
            let indexOfFirstSegmentToBeRemoved = range.startIndex
            let indexOfLastSegmentToBeRemoved = range.endIndex - 1
            let indexOfFirstSegmentToBeInserted = indexOfFirstSegmentToBeRemoved
            let indexOfLastSegmentToBeInserted = indexOfFirstSegmentToBeInserted + numberOfSegmentsToBeInserted - 1
            var selectedSegmentIndexAfterReplacing = selectedSegmentIndex
            println("number of segments to be removed: \(numberOfSegmentsToBeRemoved)")
            println("number of segments to be inserted: \(numberOfSegmentsToBeInserted)")
            println("index of first segment to be removed: \(indexOfFirstSegmentToBeRemoved)")
            println("index of last segment to be removed: \(indexOfLastSegmentToBeRemoved)")
            println("index of first segment to be inserted: \(indexOfFirstSegmentToBeInserted)")
            println("index of last segment to be inserted: \(indexOfLastSegmentToBeInserted)")
            if selectedSegmentIndex != nil {
                if numberOfSegments == numberOfSegmentsToBeRemoved {
                    selectedSegmentIndexAfterReplacing = nil
                } else if selectedSegmentIndex >= indexOfFirstSegmentToBeRemoved && selectedSegmentIndex <= indexOfLastSegmentToBeRemoved {
                    if indexOfFirstSegmentToBeRemoved != 0 {
                        selectedSegmentIndexAfterReplacing = indexOfFirstSegmentToBeRemoved - 1
                    } else {
                        selectedSegmentIndexAfterReplacing = indexOfLastSegmentToBeRemoved + 1
                    }
                } else if selectedSegmentIndex > indexOfLastSegmentToBeRemoved {
                    selectedSegmentIndexAfterReplacing = selectedSegmentIndex! - numberOfSegmentsToBeRemoved + numberOfSegmentsToBeInserted
                }
            }
            // wrapper replacing
            let rangeOfWrappersToBeRemoved = indexOfFirstSegmentToBeRemoved + 1..<indexOfLastSegmentToBeRemoved + 2
            println("range of wrappers to be removed: \(rangeOfWrappersToBeRemoved)")
            var wrappersToBeInserted = [WrapperView]()
            let wrappersToBeRemoved = wrappers[rangeOfWrappersToBeRemoved]
            for s in segments {
                s.segmentedControl = self
                let w = WrapperView()
                w.segment = s
                w.button.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
                scrollView.insertSubview(w, belowSubview: indicatorViewWrapper)
                println(CGRect(x: wrappers[indexOfFirstSegmentToBeRemoved].frame.msr_left, y: 0, width: w.defaultValueOfWidthConstraint, height: bounds.height))
                w.frame = CGRect(x: wrappers[indexOfFirstSegmentToBeRemoved].frame.msr_left, y: 0, width: w.defaultValueOfWidthConstraint, height: bounds.height)
                addConstraint(NSLayoutConstraint(item: w, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0))
                w.msr_addVerticalExpandingConstraintsToSuperview()
                wrappersToBeInserted.append(w)
            }
            for w in wrappersToBeRemoved {
                w.segment?.segmentedControl = nil
            }
            wrappers.replaceRange(rangeOfWrappersToBeRemoved, with: wrappersToBeInserted)
            // constraint replacing
            let rangeOfConstraintsToBeRemoved = indexOfFirstSegmentToBeRemoved..<indexOfLastSegmentToBeRemoved + 2
            println("range of constraints to be removed: \(rangeOfConstraintsToBeRemoved)")
            println(segmentConstraints)
            var constraintsToBeInserted = [NSLayoutConstraint]()
            let constraintsToBeRemoved = Array(segmentConstraints[rangeOfConstraintsToBeRemoved])
            scrollView.removeConstraints(constraintsToBeRemoved)
            for i in indexOfFirstSegmentToBeInserted...indexOfLastSegmentToBeInserted + 1 {
                let lw = wrappers[i]
                let rw = wrappers[i + 1]
                if i > indexOfFirstSegmentToBeInserted {
                    lw.alpha = 0
                }
                constraintsToBeInserted.extend(NSLayoutConstraint.constraintsWithVisualFormat("[l][r]", options: nil, metrics: nil, views: ["l": lw, "r": rw]) as! [NSLayoutConstraint])
                println("ADDING: [\(unsafeAddressOf(lw))][\(unsafeAddressOf(rw))]")
            }
            segmentConstraints.replaceRange(rangeOfConstraintsToBeRemoved, with: constraintsToBeInserted)
            scrollView.addConstraints(constraintsToBeInserted)
            // indicator moving if needed
            println(selectedSegmentIndexAfterReplacing)
            _indicatorPosition = selectedSegmentIndexAfterReplacing == nil ? nil : Float(selectedSegmentIndexAfterReplacing!)
            // layout
            let animations: () -> Void = {
                [weak self] in
                for w in wrappersToBeInserted {
                    w.alpha = 1
                }
                for w in wrappersToBeRemoved {
                    w.alpha = 0
                }
                self?.layoutIfNeeded()
                return
            }
            let completion: (Bool) -> Void = {
                finished in
                for w in wrappersToBeRemoved {
                    w.removeFromSuperview()
                }
            }
            setNeedsLayout()
            if animated {
                UIView.animateWithDuration(animationDuration,
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
        }
        func scrollIndicatorToVisibleAnimated(animated: Bool) {
            let x = indicatorViewWrapperLeftConstraint.constant
            let width = indicatorViewWrapperRightConstraint.constant - indicatorViewWrapperLeftConstraint.constant
            scrollView.scrollRectToVisible(CGRect(x: x, y: 0, width: width, height: 1), animated: animated)
        }
        func scrollIndicatorToCenterAnimated(animated: Bool) {
            var s: CGFloat = 0
            for w in wrappers {
                s += w.defaultValueOfWidthConstraint
            }
            let centerX = (indicatorViewWrapperLeftConstraint.constant + indicatorViewWrapperRightConstraint.constant) / 2
            let offsetX = min(max(centerX - bounds.width / 2, 0), max(s - bounds.width, 0))
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
        }
        func segmentAtIndex(index: Int) -> UIView? {
            return wrappers[index + 1].segment
        }
        func selectSegmentAtIndex(index: Int?, animated: Bool) {
            setIndicatorPosition(index == nil ? nil : Float(index!), animated: animated)
        }
        func setIndicatorPosition(position: Float?, animated: Bool) {
            _indicatorPosition = position
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
            if wrappers.count > 2 {
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
            }
            let p = CGFloat(value) - CGFloat(l)
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
                tintColor = UIColor.purpleColor()
            }
            override func tintColorDidChange() {
                super.tintColorDidChange()
                setNeedsDisplay()
            }
            override func drawRect(rect: CGRect) {
                let context = UIGraphicsGetCurrentContext()
                CGContextSaveGState(context)
                CGContextSetStrokeColorWithColor(context, tintColor?.CGColor)
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
            var segment: Segment? {
                willSet {
                    if newValue != nil {
                        insertSubview(newValue!, belowSubview: button)
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
                    segment?.frame = CGRect(origin: CGPointZero, size: frame.size) // for immediately changing before inserting
                }
            }
            override var bounds: CGRect {
                didSet {
                    segment?.frame = bounds // for immediately changing before inserting
                }
            }
            override var center: CGPoint {
                didSet {
                    segment?.center = center // for immediately changing before inserting
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
                return segment?.intrinsicContentSize().width ?? 0
            }
        }
        class Segment: AutoExpandingView {
            weak var segmentedControl: SegmentedControl? {
                willSet {
                    newValue?.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents: .ValueChanged)
                }
                didSet {
                    oldValue?.removeTarget(self, action: "segmentedControlValueChanged:", forControlEvents: .ValueChanged)
                }
            }
            internal func segmentedControlValueChanged(segmentedControl: SegmentedControl) {
                let sc = segmentedControl
                let index = sc.selectedSegmentIndex
                if sc === self.segmentedControl && index != nil && sc.segmentAtIndex(index!) === self {
                    segmentedControlDidSelectSelf()
                }
            }
            func segmentedControlDidSelectSelf() {
                // ...
            }
            override func layoutSubviews() {
                super.layoutSubviews()
                setNeedsDisplay()
            }
            deinit {
                segmentedControl = nil
            }
        }
        class DefaultSegment: Segment {
            private(set) lazy var imageView = {
                return UIImageView()
            }()
            private(set) lazy var titleLabel = {
                return UILabel()
            }()
            var image: UIImage? {
                set {
                    imageView.image = newValue
                }
                get {
                    return imageView.image
                }
            }
            var title: String? {
                set {
                    titleLabel.text = newValue
                }
                get {
                    return titleLabel.text
                }
            }
            init(title: String?, image: UIImage?) {
                super.init()
                self.title = title
                self.image = image
            }
            required override init(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
            }
            override init(frame: CGRect) {
                super.init(frame: frame)
            }
            override func msr_initialize() {
                super.msr_initialize()
//                addSubview(imageView)
                addSubview(titleLabel)
//                imageView.msr_addCenterXConstraintToSuperview()
//                titleLabel.msr_addCenterXConstraintToSuperview()
                titleLabel.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                titleLabel.msr_addAutoExpandingConstraintsToSuperview()
                //
                opaque = false
            }
        }
        func msr_initialize() {
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
        private func selectedSegmentIndexFromIndicatorPosition(position: Float?) -> Int? {
            if position != nil {
                let value = position!
                let l = Int(floor(value))
                let r = Int(ceil(value))
                let p = value - Float(l)
                return p < 0.5 ? l : r
            } else {
                return nil
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
        private var _indicatorPosition: Float? {
            willSet {
                assert(newValue == nil || newValue >= 0 && newValue <= Float(numberOfSegments - 1), "out of range: [0, numberOfSegments - 1]")
            }
            didSet {
                if selectedSegmentIndex != selectedSegmentIndexFromIndicatorPosition(oldValue) {
                    sendActionsForControlEvents(.ValueChanged)
                }
            }
        }
        private var _indicatorView: UIView!
    }
}
