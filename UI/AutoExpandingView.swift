import UIKit

extension Msr.UI {
    class AutoExpandingView: UIView {
        var layoutConstrains = [NSLayoutConstraint]()
        override init() {
            super.init()
            msr_initialize()
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
            setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        override func willMoveToSuperview(newSuperview: UIView?) {
            superview?.removeConstraints(layoutConstrains)
            layoutConstrains = []
        }
        override func didMoveToSuperview() {
            if superview != nil {
                let views = ["self": self]
                layoutConstrains = (
                    NSLayoutConstraint.constraintsWithVisualFormat("|[self]|", options: nil, metrics: nil, views: views) +
                        NSLayoutConstraint.constraintsWithVisualFormat("V:|[self]|", options: nil, metrics: nil, views: views)) as [NSLayoutConstraint]
                superview!.addConstraints(layoutConstrains)
            }
        }
    }
}
