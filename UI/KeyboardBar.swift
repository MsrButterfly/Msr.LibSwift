import UIKit

//protocol MsrKeyboardBarDelegate: NSObjectProtocol {
//    func msr_keyboardBarWillRaiseUp(keyboardBar: Msr.UI.KeyboardBar, animationInfo: Msr.UI.AnimationInfo)
//    func msr_keyboardBarDidRaiseUp(keyboardBar: Msr.UI.KeyboardBar, animationInfo: Msr.UI.AnimationInfo)
//    func msr_keyboardBarWillFallDown(keyboardBar: Msr.UI.KeyboardBar, animationInfo: Msr.UI.AnimationInfo)
//    func msr_keyboardBarDidFallDown(keyboardBar: Msr.UI.KeyboardBar, animationInfo: Msr.UI.AnimationInfo)
//    func msr_keyboardBarWillChangeFrame(keyboardBar: Msr.UI.KeyboardBar, animationInfo: Msr.UI.AnimationInfo)
//    func msr_keyboardBarDidChangeFrame(keyboardBar: Msr.UI.KeyboardBar, animationInfo: Msr.UI.AnimationInfo)
//}

extension Msr.UI {
    class KeyboardBar: UIToolbar, UIToolbarDelegate {
        private(set) var horizontalConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
        private(set) var bottomConstraint: NSLayoutConstraint?
//        typealias Delegate = MsrKeyboardBarDelegate
//        weak var keyboardBarDelegate: Delegate?
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
        internal func keyboardWillShow(notification: NSNotification) {
            println(__FUNCTION__)
            println(notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!)
        }
        internal func keyboardWillHide(notification: NSNotification) {
            println(__FUNCTION__)
            println(notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!)
        }
        internal func keyboardWillChangeFrame(notification: NSNotification) {
            println(__FUNCTION__)
            println(notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!)
            updateFrame(notification) {
                [weak self] finished in
                return
            }
        }
        private func updateFrame(notification: NSNotification, completion: ((Bool) -> Void)?) {
            let info = notification.userInfo!
            let frameEnd = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
            let duration = info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!
            let curve = UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue)
            bottomConstraint?.constant = min((window?.frame.height ?? 0) - frameEnd.origin.y, frameEnd.height)
            UIView.animateWithDuration(duration,
                delay: 0,
                options: UIViewAnimationOptions(rawValue: UInt((curve ?? .EaseOut).rawValue)),
                animations: {
                    [weak self] in
                    self?.layoutIfNeeded()
                    return
                },
                completion: nil)
        }
        func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
            if bar === self {
                return .Bottom
            }
            return .Any
        }
        deinit {
            println(__FUNCTION__)
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
}