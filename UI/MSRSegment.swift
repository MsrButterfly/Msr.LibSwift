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

class MSRDefaultSegment: MSRSegment {
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
        l.font = UIFont.systemFontOfSize(10)
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
    override func segmentedControlDidSelectedSelf(segmentedControl: MSRSegmentedControl) {
        updateColor()
    }
    override func segmentedControlDidDeselectedSelf(segmentedControl: MSRSegmentedControl) {
        updateColor()
    }
    func updateColor() {
        let color = selected ? tintColor : UIColor.lightGrayColor()
        imageView.tintColor = color
        titleLabel.textColor = color
    }
}
