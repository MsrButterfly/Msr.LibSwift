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
        var selectedSegmentIndex: Int?
        var indicatorPosition: CGFloat? // [0, numberOfSegments]
        let maxDuration = NSTimeInterval(0.5)
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
            addConstraint(minWidthConstraint)
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceHorizontal = true
        }
        func appendSegmentWithView(view: UIView, animated: Bool) {
            insertSegmentWithView(view, atIndex: numberOfSegments, animated: animated)
        }
        func insertSegmentWithView(view: UIView, atIndex index: Int, animated: Bool) {
            let wrapper = WrapperView()
            wrapper.contentView = view
            wrappers.insert(wrapper, atIndex: index + 1)
            scrollView.addSubview(wrapper)
            /*********************************************************************
            * now             deletion  addition                after
            * |...[a][b]...|  [a][b](i) [a][w](i), [w][b](i+1)  |...[a][w][b]...|
            *********************************************************************/
            let vs = ["l": wrappers[index], "r": wrappers[index + 2], "w": wrapper]
            scrollView.removeConstraint(segmentConstraints[index])
            wrapper.msr_addTopAttachedConstraintToSuperview()
            addConstraint(NSLayoutConstraint(item: wrapper, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[w]|", options: nil, metrics: nil, views: vs))
            segmentConstraints.replaceRange(index...index, with: NSLayoutConstraint.constraintsWithVisualFormat("[l][w][r]", options: nil, metrics: nil, views: vs) as! [NSLayoutConstraint])
            scrollView.addConstraints(Array(segmentConstraints[index...index + 1]))
            setNeedsLayout()
            layoutIfNeeded()
            // scrollView.contentSize = CGSize(width: wrappers.last!.frame.msr_right, height: frame.height)
            println(segmentConstraints)
            println(wrappers.last!.frame.msr_right)
        }
        func removeSegmentAtIndex(index: Int, animated: Bool) {
            
        }
        func removeAllSegments() {
            
        }
        func replaceSegmentView(view: UIView, atIndex index: Int, animated: Bool) {
            
        }
        func replaceSegmentView(view: UIView, withView newView: UIView, animated: Bool) {
            
        }
        override func layoutSubviews() {
            minWidthConstraint.constant = bounds.width
            super.layoutSubviews()
            if wrappers.second?.frame.msr_left > 0 {
                let sum = wrappers.second!.frame.msr_left
                let addition = sum / CGFloat(numberOfSegments)
                for w in wrappers[1..<wrappers.endIndex - 2] {
                    w.setAdditionWidthToWidthConstraintWithValue(addition)
                }
                super.layoutSubviews()
            }
        }
        class WrapperView: UIView {
            var contentView: UIView? {
                willSet {
                    if newValue != nil {
                        addSubview(newValue!)
                        newValue!.userInteractionEnabled = false
                        newValue!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                        newValue!.msr_addAutoExpandingConstraintsToSuperview()
                    }
                }
                didSet {
                    oldValue?.removeFromSuperview()
                    resetWidthConstraint()
                }
            }
            var overlayButton: UIButton!
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
                overlayButton = UIButton(frame: bounds)
                overlayButton.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                addSubview(overlayButton)
                msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                msr_addWidthConstraintWithValue(0)
            }
            func resetWidthConstraint() {
                msr_widthConstraint!.constant = defaultValueOfWidthConstraint
            }
            func setAdditionWidthToWidthConstraintWithValue(value: CGFloat) {
                msr_widthConstraint!.constant = defaultValueOfWidthConstraint + value
            }
            var defaultValueOfWidthConstraint: CGFloat {
                return contentView?.intrinsicContentSize().width ?? 0
            }
        }
    }
}
