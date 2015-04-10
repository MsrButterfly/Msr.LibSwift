/*

Functional Synopsis

@objc protocol MSRSegmentedControlDelegate {
    // Segments won't be selected by user interaction if one of these methods return false.
    optional func msr_segmentedControl(segmentedControl: Msr.UI.SegmentedControl, shouldSelectSegment: Msr.UI.SegmentedControl.Segment) -> Bool
    optional func msr_segmentedControl(segmentedControl: Msr.UI.SegmentedControl, shouldSelectSegmentAtIndex: Int) -> Bool
}

@objc class MSRSegmentedControl: UIControl, UILayoutSupport {

    init()
    init(segments: [Segment])
    init(frame: CGRect)
    init(coder aDecoder: NSCoder)

    func msr_initialize()

    var animationDuration: NSTimeInterval         // default 0.5
    var backgroundView: UIView?                   // default nil
    weak var delegate: Delegate?                  // default nil
    var indicatorPosition: Float?                 // default nil, range [-1, numberOfSegments]
                                                  //     indicatorPosition = selectedSegmentIndex if indicatorPosition is an integer (excepts -1 & numberOfSegments)
    var indicator: Indicator                      // default UnderlineIndicator
    var numberOfSegments: Int { get }
    var selected: Bool                            // selectedSegmentIndex != nil. Select 1st if changed false to true from externals.
    var selectedSegmentIndex: Int?                // default nil, range [0, numberOfSegments - 1]
    var selectedSegmentIndexChanged: Bool { get } // true if selectedSegmentIndex has been changed since last .ValueChanged action was sent, otherwise false.
    var selectedSegment: Segment? { get }         // default nil
    var valueChangedByUserInteraction: Bool       // true if value changed by user interaction since last .ValueChanged action was sent, otherwise false.
                                                  //     Make it 'public' for subclass customization
    func appendSegment(segment: Segment, animated: Bool)
    func extendSegments(segments: [Segment], animated: Bool)
    func indexOfSegment(segment: Segment) -> Int?
    func insertSegment(segment: Segment, atIndex index: Int, animated: Bool)
    func insertSegments(segments: [Segment], atIndex index: Int, animated: Bool)
    func removeSegment(segment: Segment, animated: Bool)
    func removeSegmentAtIndex(index: Int, animated: Bool)
    func removeSegmentsInRange(range: Range<Int>, animated: Bool)
    func replaceSegment(segment: Segment, withSegment newSegment: Segment, animated: Bool)
    func replaceSegmentAtIndex(index: Int, withSegment newSegment: Segment, animated: Bool)
    func replaceSegmentsInRange(range: Range<Int>, withSegments newSegments: [Segment], animated: Bool)
    func setSegments(newSegments: [Segment], animated: Bool)
    func scrollIndicatorToVisibleAnimated(animated: Bool)
    func scrollIndicatorToCenterAnimated(animated: Bool)
    func segmentAtIndex(index: Int) -> Segment
    func selectSegment(segment: Segment?, animated: Bool)
    func selectSegmentAtIndex(index: Int?, animated: Bool)
    func selectSegmentAtIndex(index: Int?, animated: Bool, byUserInteraction userInteraction: Bool)
    func setIndicatorPosition(position: Float?, animated: Bool)
    func setIndicatorPosition(position: Float?, animated: Bool, byUserInteraction userInteraction: Bool)

}

*/

import UIKit

@objc protocol MSRSegmentedControlDelegate {
    optional func msr_segmentedControl(segmentedControl: MSRSegmentedControl, shouldSelectSegmentByUserInteraction: MSRSegment) -> Bool
    optional func msr_segmentedControl(segmentedControl: MSRSegmentedControl, shouldSelectSegmentAtIndexByUserInteraction: Int) -> Bool
}

@objc class MSRSegmentedControl: UIControl, UILayoutSupport {
    override init() {
        super.init()
        // msr_initialize() will be called by super.init() -> self.init(frame:)
    }
    init(segments: [MSRSegment]) {
        super.init()
        // msr_initialize() will be called by super.init() -> self.init(frame:)
        setSegments(segments, animated: false)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        msr_initialize()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        msr_initialize()
    }
    func msr_initialize() {
        addSubview(scrollView)
        scrollView.addSubview(wrappersView)
        scrollView.addSubview(indicatorWrapper)
        wrappersView.addSubview(leftView)
        wrappersView.addSubview(rightView)
        scrollView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        scrollView.msr_addAllEdgeAttachedConstraintsToSuperview()
        leftView.msr_addVerticalEdgeAttachedConstraintsToSuperview()
        leftView.msr_addLeftAttachedConstraintToSuperview()
        leftView.msr_addWidthConstraintWithValue(0)
        rightView.msr_addVerticalEdgeAttachedConstraintsToSuperview()
        rightView.msr_addRightAttachedConstraintToSuperview()
        rightView.msr_addWidthConstraintWithValue(0)
        wrappers = [leftView, rightView]
        let vs = ["l": leftView, "r": rightView]
        segmentConstraints = NSLayoutConstraint.constraintsWithVisualFormat("[l][r]", options: nil, metrics: nil, views: vs) as! [NSLayoutConstraint]
        minWidthConstraint = NSLayoutConstraint(item: rightView, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: wrappersView, attribute: .Leading, multiplier: 1, constant: 0)
        wrappersView.addConstraints(segmentConstraints)
        wrappersView.addConstraint(minWidthConstraint)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = true
        indicatorWrapper.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        indicatorWrapper.msr_addVerticalEdgeAttachedConstraintsToSuperview()
        indicatorWrapper.userInteractionEnabled = false
        indicator = MSRSegmentedControlUnderlineIndicator()
        indicatorWrapperLeftConstraint = NSLayoutConstraint(item: indicatorWrapper, attribute: .Leading, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1, constant: 0)
        indicatorWrapperRightConstraint = NSLayoutConstraint(item: indicatorWrapper, attribute: .Trailing, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1, constant: 0)
        scrollView.addConstraint(indicatorWrapperLeftConstraint)
        scrollView.addConstraint(indicatorWrapperRightConstraint)
        scrollView.addConstraint(NSLayoutConstraint(item: wrappersView, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0))
        tintColor = UIColor.purpleColor()
    }
    var animationDuration = NSTimeInterval(0.5)
    var backgroundView: UIView? {
        willSet {
            if newValue != nil {
                addSubview(newValue!)
                sendSubviewToBack(newValue!)
                newValue!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                newValue!.msr_addAllEdgeAttachedConstraintsToSuperview()
            }
        }
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    weak var delegate: MSRSegmentedControlDelegate?
    var indicator: MSRSegmentedControlIndicator {
        set {
            _indicator?.removeFromSuperview()
            _indicator?.segmentedControl = nil
            _indicator = newValue
            _indicator.segmentedControl = self
            indicatorWrapper.addSubview(_indicator)
            scrollView.bringSubviewToFront(indicator.dynamicType.aboveSegments ? indicatorWrapper : wrappersView)
        }
        get {
            return _indicator
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
    var numberOfSegments: Int {
        get {
            return wrappers.count - 2
        }
    }
    override var selected: Bool {
        set {
            selectSegmentAtIndex(0, animated: false)
        }
        get {
            return selectedSegmentIndex != nil
        }
    }
    var selectedSegmentIndex: Int? {
        set {
            selectSegmentAtIndex(newValue, animated: false)
        }
        get {
            return segmentIndexFromIndicatorPosition(indicatorPosition)
        }
    }
    private(set) var selectedSegmentIndexChanged: Bool = false
    var selectedSegment: MSRSegment? {
        return selectedSegmentIndex == nil ? nil : segmentAtIndex(selectedSegmentIndex!)
    }
    var valueChangedByUserInteraction: Bool = false
    func appendSegment(segment: MSRSegment, animated: Bool) {
        insertSegment(segment, atIndex: numberOfSegments, animated: animated)
    }
    func extendSegments(segments: [MSRSegment], animated: Bool) {
        insertSegments(segments, atIndex: numberOfSegments, animated: animated)
    }
    func indexOfSegment(segment: MSRSegment) -> Int? {
        if numberOfSegments == 0 {
            return nil
        }
        return find(map(wrappers[0...wrappers.endIndex - 2], { $0.segment ?? MSRSegment() }), segment)
    }
    func insertSegment(segment: MSRSegment, atIndex index: Int, animated: Bool) {
        insertSegments([segment], atIndex: index, animated: animated)
    }
    func insertSegments(segments: [MSRSegment], atIndex index: Int, animated: Bool) {
        replaceSegmentsInRange(index..<index, withSegments: segments, animated: animated)
    }
    func removeSegment(segment: MSRSegment, animated: Bool) {
        removeSegmentAtIndex(indexOfSegment(segment)!, animated: animated)
    }
    func removeSegmentAtIndex(index: Int, animated: Bool) {
        replaceSegmentsInRange(index...index, withSegments: [], animated: animated)
    }
    func removeSegmentsInRange(range: Range<Int>, animated: Bool) {
        replaceSegmentsInRange(range, withSegments: [], animated: animated)
    }
    func replaceSegment(segment: MSRSegment, withSegment newSegment: MSRSegment, animated: Bool) {
        replaceSegmentAtIndex(indexOfSegment(segment)!, withSegment: newSegment, animated: animated)
    }
    func replaceSegmentAtIndex(index: Int, withSegment newSegment: MSRSegment, animated: Bool) {
        replaceSegmentsInRange(index...index, withSegments: [newSegment], animated: animated)
    }
    func replaceSegmentsInRange(range: Range<Int>, withSegments newSegments: [MSRSegment], animated: Bool) {
        assert(range.isEmpty || (0 <= range.startIndex && range.endIndex <= numberOfSegments), "out of range: [0, numberOfSegments - 1]")
        // calculate value
        let numberOfSegmentsToBeRemoved = range.endIndex - range.startIndex
        let numberOfSegmentsToBeInserted = newSegments.count
        let numberOfWrappersToBeRemoved = numberOfSegmentsToBeRemoved
        let numberOfWrappersToBeInserted = numberOfSegmentsToBeInserted
        let numberOfConstraintsToBeRemoved = numberOfWrappersToBeRemoved + 1
        let numberOfConstraintsToBeInserted = numberOfWrappersToBeInserted + 1
        let indexOfFirstSegmentToBeRemoved = range.startIndex
        let indexOfLastSegmentToBeRemoved = range.endIndex - 1
        let indexOfFirstWrapperToBeRemoved = indexOfFirstSegmentToBeRemoved + 1
        let indexOfLastWrapperToBeRemoved = indexOfFirstWrapperToBeRemoved + numberOfWrappersToBeRemoved - 1
        let indexOfFirstWrapperToBeInserted = indexOfFirstWrapperToBeRemoved
        let indexOfLastWrapperToBeInserted = indexOfFirstWrapperToBeInserted + numberOfWrappersToBeInserted - 1
        let indexOfFirstConstraintToBeRemoved = indexOfFirstSegmentToBeRemoved
        let indexOfLastConstraintToBeRemoved = indexOfFirstConstraintToBeRemoved + numberOfConstraintsToBeRemoved - 1
        let indexOfFirstConstraintToBeInserted = indexOfFirstConstraintToBeRemoved
        let indexOfLastConstraintToBeInserted = indexOfFirstConstraintToBeInserted + numberOfConstraintsToBeInserted - 1
        let rangeOfWrappersToBeRemoved = indexOfFirstWrapperToBeRemoved..<indexOfLastWrapperToBeRemoved + 1
        let rangeOfConstraintsToBeRemoved = indexOfFirstConstraintToBeRemoved..<indexOfLastConstraintToBeRemoved + 1
        // calculate selected segment
        var selectedSegmentIndexAfterReplacing = selectedSegmentIndex
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
        // replace wrappers
        var wrappersToBeInserted = [_MSRSegmentWrapper]()
        let wrappersToBeRemoved = wrappers[rangeOfWrappersToBeRemoved]
        for s in newSegments {
            s.tintColor = tintColor
            let w = _MSRSegmentWrapper()
            wrappersView.addSubview(w)
            w.segment = s
            w.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTapGesture:"))
            w.msr_addVerticalEdgeAttachedConstraintsToSuperview()
            wrappersToBeInserted.append(w)
        }
        wrappers.replaceRange(rangeOfWrappersToBeRemoved, with: wrappersToBeInserted)
        // replace constraints
        var constraintsToBeInserted = [NSLayoutConstraint]()
        let constraintsToBeRemoved = Array(segmentConstraints[rangeOfConstraintsToBeRemoved])
        wrappersView.removeConstraints(constraintsToBeRemoved)
        for i in indexOfFirstConstraintToBeInserted...indexOfLastConstraintToBeInserted {
            let lw = wrappers[i]
            let rw = wrappers[i + 1]
            if i < indexOfLastConstraintToBeInserted {
                rw.alpha = 0
            }
            constraintsToBeInserted.extend(NSLayoutConstraint.constraintsWithVisualFormat("[l][r]", options: nil, metrics: nil, views: ["l": lw, "r": rw]) as! [NSLayoutConstraint])
        }
        segmentConstraints.replaceRange(rangeOfConstraintsToBeRemoved, with: constraintsToBeInserted)
        wrappersView.addConstraints(constraintsToBeInserted)
        // move indicator
        var indicatorPositionAfterReplacing: Float? = selectedSegmentIndexAfterReplacing == nil ? nil : Float(selectedSegmentIndexAfterReplacing!)
        if _indicatorPosition != indicatorPositionAfterReplacing {
            valueChangedByUserInteraction = false
            _indicatorPosition = selectedSegmentIndexAfterReplacing == nil ? nil : Float(selectedSegmentIndexAfterReplacing!)
        }
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
        setNeedsUpdateConstraints()
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
    func setSegments(newSegments: [MSRSegment], animated: Bool) {
        replaceSegmentsInRange(0..<numberOfSegments, withSegments: newSegments, animated: animated)
    }
    func scrollIndicatorToVisibleAnimated(animated: Bool) {
        let x = indicatorWrapperLeftConstraint.constant
        let width = indicatorWrapperRightConstraint.constant - indicatorWrapperLeftConstraint.constant
        scrollView.scrollRectToVisible(CGRect(x: x, y: 0, width: width, height: 1), animated: animated)
    }
    func scrollIndicatorToCenterAnimated(animated: Bool) {
        var s: CGFloat = 0
        for w in wrappers {
            s += w.minimumLayoutSize.width
        }
        let centerX = (indicatorWrapperLeftConstraint.constant + indicatorWrapperRightConstraint.constant) / 2
        let offsetX = min(max(centerX - bounds.width / 2, 0), max(s - bounds.width, 0))
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
    }
    func segmentAtIndex(index: Int) -> MSRSegment {
        return wrappers[index + 1].segment!
    }
    func selectSegment(segment: MSRSegment?, animated: Bool) {
        selectSegmentAtIndex(segment == nil ? nil : indexOfSegment(segment!), animated: animated)
    }
    func selectSegmentAtIndex(index: Int?, animated: Bool) {
        selectSegmentAtIndex(index, animated: animated, byUserInteraction: false)
    }
    func selectSegmentAtIndex(index: Int?, animated: Bool, byUserInteraction userInteraction: Bool) {
        setIndicatorPosition(index == nil ? nil : Float(index!), animated: animated, byUserInteraction: userInteraction)
    }
    func setIndicatorPosition(position: Float?, animated: Bool) {
        setIndicatorPosition(position, animated: animated, byUserInteraction: false)
    }
    func setIndicatorPosition(position: Float?, animated: Bool, byUserInteraction userInteraction: Bool) {
        valueChangedByUserInteraction = userInteraction
        _indicatorPosition = position
        setNeedsUpdateConstraints()
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
    override var tintColor: UIColor! {
        didSet {
            for w in wrappers {
                w.segment?.tintColor = tintColor
            }
            indicator.tintColor = tintColor
        }
    }
    override func updateConstraints() {
        let value = indicatorPosition ?? 0
        let l = Int(floor(value))
        let r = Int(ceil(value))
        var lp: CGFloat = 0
        var mp: CGFloat = 0
        var rp: CGFloat = 0
        var s: CGFloat = 0
        if wrappers.count > 2 {
            for (i, w) in enumerate(wrappers[1...wrappers.endIndex - 2]) {
                let c = w.minimumLayoutSize.width
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
                    w.widthConstraint.constant = w.minimumLayoutSize.width + increment
                }
            } else {
                for w in wrappers[1...wrappers.endIndex - 2] {
                    w.widthConstraint.constant = w.minimumLayoutSize.width
                }
            }
        }
        let p = CGFloat(value) - CGFloat(l)
        indicatorWrapperLeftConstraint.constant = 0
        indicatorWrapperRightConstraint.constant = mp + (rp - mp) * p
        indicatorWrapperLeftConstraint.constant = lp + (mp - lp) * p
        if indicatorPosition == nil {
            indicatorWrapperLeftConstraint.constant = 0
            indicatorWrapperRightConstraint.constant = 0
        }
        indicator.setNeedsUpdateConstraints()
        indicator.setNeedsLayout()
        indicator.setNeedsDisplay()
        super.updateConstraints()
    }
    override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                setNeedsUpdateConstraints() // It's not elegant but still needed.
            }
        }
    }
    override var frame: CGRect {
        didSet {
            if frame.size != oldValue.size {
                setNeedsUpdateConstraints() // It's not elegant but still needed.
            }
        }
    }
    var length: CGFloat {
        return bounds.height
    }
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    internal func handleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        let sw = gestureRecognizer.view!
        for (i, w) in enumerate(wrappers[1...wrappers.endIndex - 2]) {
            if w === sw {
                var shouldBeSelected = true
                shouldBeSelected = shouldBeSelected && delegate?.msr_segmentedControl?(self, shouldSelectSegmentByUserInteraction: segmentAtIndex(i)) ?? true
                shouldBeSelected = shouldBeSelected && delegate?.msr_segmentedControl?(self, shouldSelectSegmentAtIndexByUserInteraction: i) ?? true
                if shouldBeSelected {
                    valueChangedByUserInteraction = true
                    selectSegmentAtIndex(i, animated: true, byUserInteraction: true)
                    scrollIndicatorToVisibleAnimated(true)
                }
                break
            }
        }
    }
    private func segmentIndexFromIndicatorPosition(position: Float?) -> Int? {
        if position != nil {
            let value = position!
            let l = Int(floor(value))
            let r = Int(ceil(value))
            let p = value - Float(l)
            return min(max(p < 0.5 ? l : r, 0), numberOfSegments - 1)
        } else {
            return nil
        }
    }
    private var wrappers = [_MSRSegmentWrapper]()
    private var segmentConstraints = [NSLayoutConstraint]() // initially [left][right]
    private let leftView = _MSRSegmentWrapper()
    private let rightView = _MSRSegmentWrapper()
    private let scrollView = UIScrollView()
    private let wrappersView = MSRAutoExpandingView()
    private var minWidthConstraint: NSLayoutConstraint!
    private var indicatorWrapperLeftConstraint: NSLayoutConstraint!
    private var indicatorWrapperRightConstraint: NSLayoutConstraint!
    private var indicatorWrapper = UIView()
    private var _indicatorPosition: Float? {
        willSet {
            assert(newValue == nil || newValue >= -1 && newValue <= Float(numberOfSegments), "out of range: [-1, numberOfSegments]")
        }
        didSet {
            selectedSegmentIndexChanged = selectedSegmentIndex != segmentIndexFromIndicatorPosition(oldValue)
            if _indicatorPosition != oldValue {
                sendActionsForControlEvents(.ValueChanged)
            }
        }
    }
    private var _indicator: MSRSegmentedControlIndicator!
}
