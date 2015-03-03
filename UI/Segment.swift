import UIKit

extension Msr.UI {
    class Segment: AutoExpandingView {
        typealias SegmentedControl = Msr.UI.SegmentedControl
        private var needsRecalculateSystemLayoutSize: Bool = true // for efficency
        func setNeedsRecalculateSystemLayoutSize() {
            needsRecalculateSystemLayoutSize = true
        }
        private var _minimumLayoutSize = CGSizeZero
        var minimumLayoutSize: CGSize {
            if needsRecalculateSystemLayoutSize {
                needsRecalculateSystemLayoutSize = false
                _minimumLayoutSize = systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) ?? CGSizeZero
            }
            return _minimumLayoutSize
        }
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            println(superview)
            if var sv: UIView? = superview as? Msr.UI._Detail.SegmentWrapper {
                while !(sv is SegmentedControl) && sv != nil {
                    println(sv!.superview)
                    sv = sv!.superview
                }
                segmentedControl = sv as? SegmentedControl
            }
        }
        private weak var segmentedControl: SegmentedControl? {
            willSet {
                newValue?.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents: .ValueChanged)
            }
            didSet {
                oldValue?.removeTarget(self, action: "segmentedControlValueChanged:", forControlEvents: .ValueChanged)
            }
        }
        private var selectedBefore: Bool = false
        private var selected: Bool = false
        // If you want to override this method, you must invoke super at the beginning.
        func segmentedControlValueChanged(segmentedControl: SegmentedControl) {
            selectedBefore = selected
            selected = segmentedControl.selectedSegment === self
            if selected != selectedBefore {
                if selected {
                    segmentedControlDidSelectedSelf(segmentedControl)
                } else {
                    segmentedControlDidDeselectedSelf(segmentedControl)
                }
            }
        }
        func segmentedControlDidSelectedSelf(segmentedControl: SegmentedControl) {}
        func segmentedControlDidDeselectedSelf(segmentedControl: SegmentedControl) {}
        override func layoutSubviews() {
            super.layoutSubviews()
            setNeedsDisplay()
        }
        deinit {
            segmentedControl = nil
        }
    }
}

extension Msr.UI {
    class DefaultSegment: Segment {
        private lazy var containerView: UIView = {
            [weak self] in
            let cv = UIView()
            if self != nil {
                cv.addSubview(self!.imageView)
                cv.addSubview(self!.titleLabel)
                cv.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                self!.imageView.msr_addCenterXConstraintToSuperview()
                self!.titleLabel.msr_addCenterXConstraintToSuperview()
                self!.titleLabel.textAlignment = .Center
                let vs = ["u": self!.imageView, "d": self!.titleLabel]
                cv.addConstraints(
                    NSLayoutConstraint.constraintsWithVisualFormat("V:|[u]-5-[d]|", options: nil, metrics: nil, views: vs) +
                        NSLayoutConstraint.constraintsWithVisualFormat("|-(>=10)-[u]-(>=10)-|", options: nil, metrics: nil, views: vs) +
                        NSLayoutConstraint.constraintsWithVisualFormat("|-(>=10)-[d]-(>=10)-|", options: nil, metrics: nil, views: vs))
            }
            return cv
        }()
        private(set) lazy var imageView: UIImageView = {
            let iv = UIImageView()
            iv.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            return iv
        }()
        private(set) lazy var titleLabel: UILabel = {
            let l = UILabel()
            l.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            l.font = UIFont.systemFontOfSize(12)
            return l
        }()
        var image: UIImage? {
            set {
                imageView.image = newValue?.imageWithRenderingMode(.AlwaysTemplate)
                setNeedsRecalculateSystemLayoutSize()
            }
            get {
                return imageView.image
            }
        }
        var title: String? {
            set {
                titleLabel.text = newValue
                setNeedsRecalculateSystemLayoutSize()
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
            addSubview(containerView)
            let vs = ["c": containerView]
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(>=10)-[c]-(>=10)-|", options: nil, metrics: nil, views: vs))
            containerView.msr_addCenterConstraintsToSuperview()
            opaque = false
        }
        override var tintColor: UIColor! {
            didSet {
                updateColor()
            }
        }
        override func segmentedControlDidSelectedSelf(segmentedControl: SegmentedControl) {
            updateColor()
        }
        override func segmentedControlDidDeselectedSelf(segmentedControl: SegmentedControl) {
            updateColor()
        }
        func updateColor() {
            let color = selected ? tintColor : UIColor.lightGrayColor()
            imageView.tintColor = color
            titleLabel.textColor = color
        }
    }
}
