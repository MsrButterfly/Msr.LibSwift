import UIKit

@objc class MSRSegment: MSRAutoExpandingView {
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
        if var sv: UIView? = superview as? _MSRSegmentWrapper {
            while !(sv is MSRSegmentedControl) && sv != nil {
                sv = sv!.superview
            }
            segmentedControl = sv as? MSRSegmentedControl
        }
    }
    private weak var segmentedControl: MSRSegmentedControl? {
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
    func segmentedControlValueChanged(segmentedControl: MSRSegmentedControl) {
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
    func segmentedControlDidSelectedSelf(segmentedControl: MSRSegmentedControl) {}
    func segmentedControlDidDeselectedSelf(segmentedControl: MSRSegmentedControl) {}
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    deinit {
        segmentedControl?.removeTarget(self, action: "segmentedControlValueChanged:", forControlEvents: .ValueChanged)
        // segmentedControl = nil // Swift *WONT* invoke didSet in deinit
    }
}

@objc class MSRDefaultSegment: MSRSegment {
    private var imageTitleDistanceConstraint: NSLayoutConstraint!
    private lazy var containerView: UIView = {
        [weak self] in
        let cv = UIView()
        if self != nil {
            cv.addSubview(self!.imageView)
            cv.addSubview(self!.titleLabel)
            cv.translatesAutoresizingMaskIntoConstraints = false
            self!.imageView.msr_addCenterXConstraintToSuperview()
            self!.titleLabel.msr_addCenterXConstraintToSuperview()
            self!.titleLabel.textAlignment = .Center
            let vs = ["u": self!.imageView, "d": self!.titleLabel]
            self!.imageTitleDistanceConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[u]-5-[d]", options: [], metrics: nil, views: vs).first!
            cv.addConstraint(self!.imageTitleDistanceConstraint)
            cv.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[u]", options: [], metrics: nil, views: vs))
            cv.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[d]|", options: [], metrics: nil, views: vs))
            cv.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(>=10)-[u]-(>=10)-|", options: [], metrics: nil, views: vs))
            cv.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(>=10)-[d]-(>=10)-|", options: [], metrics: nil, views: vs))
        }
        return cv
    }()
    private(set) lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private(set) lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFontOfSize(10)
        return l
    }()
    var image: UIImage? {
        set {
            imageView.image = newValue?.imageWithRenderingMode(.AlwaysTemplate)
            imageTitleDistanceConstraint.constant = newValue == nil || title == nil ? 0 : 5
            setNeedsRecalculateSystemLayoutSize()
        }
        get {
            return imageView.image
        }
    }
    var title: String? {
        set {
            titleLabel.text = newValue
            imageTitleDistanceConstraint.constant = newValue == nil || image == nil ? 0 : 5
            setNeedsRecalculateSystemLayoutSize()
        }
        get {
            return titleLabel.text
        }
    }
    convenience init(title: String?, image: UIImage?) {
        self.init(frame: CGRectZero)
        self.title = title
        self.image = image
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override func msr_initialize() {
        super.msr_initialize()
        addSubview(containerView)
        let vs = ["c": containerView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(>=10)-[c]-(>=10)-|", options: [], metrics: nil, views: vs))
        containerView.msr_addCenterConstraintsToSuperview()
        opaque = false
    }
    override var tintColor: UIColor! {
        didSet {
            updateColor()
        }
    }
    override func segmentedControlDidSelectedSelf(segmentedControl: MSRSegmentedControl) {
        updateColor()
    }
    override func segmentedControlDidDeselectedSelf(segmentedControl: MSRSegmentedControl) {
        updateColor()
    }
    func updateColor() {
        let color = selected ? tintColor : tintColor.colorWithAlphaComponent(0.3)
        imageView.tintColor = color
        titleLabel.textColor = color
    }
}
