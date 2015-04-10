import UIKit

@objc class MSRAutoExpandingView: UIView {
    convenience init() {
        self.init(frame: CGRectZero)
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
    }
    override func willMoveToSuperview(newSuperview: UIView?) {
        if superview != nil {
            msr_removeAllEdgeAttachedConstraintsFromSuperview()
        }
    }
    override func didMoveToSuperview() {
        if superview != nil {
            msr_addAllEdgeAttachedConstraintsToSuperview()
        }
    }
}
