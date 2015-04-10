import UIKit

@objc class _MSRSegmentWrapper: UIView {
    var segment: MSRSegment? {
        willSet {
            if newValue != nil {
                addSubview(newValue!)
                newValue!.frame = bounds
                newValue!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                newValue!.msr_addAllEdgeAttachedConstraintsToSuperview()
            }
        }
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
    var widthConstraint: NSLayoutConstraint!
    override init() {
        super.init()
        // msr_initialize() will be invoked by super.init() -> self.init(frame:).
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
        msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: minimumLayoutSize.width)
        addConstraint(widthConstraint)
    }
    var minimumLayoutSize: CGSize {
        return segment?.minimumLayoutSize ?? CGSizeZero
    }
}
