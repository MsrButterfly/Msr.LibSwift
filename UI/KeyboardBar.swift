import UIKit

extension Msr.UI {
    class KeyboardBar: UIToolbar, UIToolbarDelegate {
        private(set) var horizontalConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
        private(set) var bottomConstraint: NSLayoutConstraint?
        override init() {
            super.init()
            initialize()
        }
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            initialize()
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            initialize()
        }
        private func initialize() {
            delegate = self
            let views = ["self": self]
            setTranslatesAutoresizingMaskIntoConstraints(false)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        }
        override func willMoveToSuperview(newSuperview: UIView?) {
            super.willMoveToSuperview(newSuperview)
            if superview != nil && bottomConstraint != nil {
                superview!.removeConstraints(horizontalConstraints + [bottomConstraint!])
                horizontalConstraints = []
                bottomConstraint = nil
            }
        }
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            if superview != nil {
                let views = ["self": self]
                bottomConstraint = (NSLayoutConstraint.constraintsWithVisualFormat("V:[self]|", options: nil, metrics: nil, views: views).first as NSLayoutConstraint)
                horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|[self]|", options: nil, metrics: nil, views: views) as [NSLayoutConstraint]
                superview!.addConstraints(horizontalConstraints + [bottomConstraint!])
            }
        }
        internal func keyboardWillShow(notification: NSNotification) {}
        internal func keyboardWillHide(notification: NSNotification) {}
        internal func keyboardWillChangeFrame(notification: NSNotification) {
            let info = notification.userInfo!
            let frameEnd = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
            let duration = info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!
            let curve = UIViewAnimationOptions(rawValue: UInt(info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!))
            UIView.animateWithDuration(duration,
                delay: 0,
                options: curve,
                animations: {
                    [weak self] in
                    self?.bottomConstraint?.constant = min((self?.window?.frame.height ?? 0) - frameEnd.origin.y, frameEnd.height)
                    return
                },
                completion: nil)
        }
        override func intrinsicContentSize() -> CGSize {
            return CGSize(width: 0, height: 44)
        }
        func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
            if bar === self {
                return .Bottom
            }
            return .Any
        }
        deinit {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
}