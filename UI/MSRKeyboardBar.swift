@objc class MSRKeyboardBar: UIView {
    var backgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if backgroundView != nil {
                addSubview(backgroundView!)
                sendSubviewToBack(backgroundView!)
                backgroundView!.frame = bounds
                backgroundView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            }
        }
    }
    override init() {
        super.init()
        // msr_initialize() will be invoked by init(frame:)
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
        let views = ["self": self]
        msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if superview != nil {
            msr_removeHorizontalEdgeAttachedConstraintsFromSuperview()
        }
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            msr_addHorizontalEdgeAttachedConstraintsToSuperview()
            msr_addBottomAttachedConstraintToSuperview()
        }
    }
    internal func keyboardWillChangeFrame(notification: NSNotification) {
        updateFrame(notification, completion: nil)
    }
    private func updateFrame(notification: NSNotification, completion: ((Bool) -> Void)?) {
        let info = MSRAnimationInfo(keyboardNotification: notification)
        let bottom = min((superview?.bounds.height ?? 0) - info.frameEnd.msr_top, info.frameEnd.height)
        UIView.animateWithDuration(info.animationDuration,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: UInt(info.animationCurve.rawValue)),
            animations: {
                [weak self] in
                self?.transform = CGAffineTransformMakeTranslation(0, -bottom)
                self?.layoutIfNeeded()
                return
            },
            completion: nil)
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
