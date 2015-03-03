import UIKit

extension Msr.UI {
    class Segment: AutoExpandingView {
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
        weak var segmentedControl: SegmentedControl? {
            willSet {
                newValue?.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents: .ValueChanged)
            }
            didSet {
                oldValue?.removeTarget(self, action: "segmentedControlValueChanged:", forControlEvents: .ValueChanged)
            }
        }
        internal func segmentedControlValueChanged(segmentedControl: SegmentedControl) {}
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
        override var tintColor: UIColor! {
            didSet {
                imageView.tintColor = tintColor
                titleLabel.textColor = tintColor
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
            tintColor = UIColor.grayColor()
            opaque = false
        }
        override func segmentedControlValueChanged(segmentedControl: SegmentedControl) {
            super.segmentedControlValueChanged(segmentedControl)
            if segmentedControl.selectedSegment === self {
                tintColor = UIColor.purpleColor()
            } else {
                tintColor = UIColor.grayColor()
            }
        }
    }
}
