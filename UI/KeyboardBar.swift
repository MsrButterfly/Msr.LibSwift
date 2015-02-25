import UIKit

protocol MsrKeyboardBarDelegate: NSObjectProtocol {
    func msr_keyboardBarWillChangeFrame(keyboardBar: Msr.UI.KeyboardBar, animationInfo: Msr.UI.AnimationInfo)
    func msr_keyboardBarDidChangeFrame(keyboardBar: Msr.UI.KeyboardBar, animationInfo: Msr.UI.AnimationInfo)
}

extension Msr.UI {
    class KeyboardBar: UIView {
        private(set) var horizontalConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
        private(set) var bottomConstraint: NSLayoutConstraint?
        var backgroundView: UIView!
        typealias Delegate = MsrKeyboardBarDelegate
        weak var keyboardBarDelegate: Delegate?
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
        private func msr_initialize() {
            let views = ["self": self]
            setTranslatesAutoresizingMaskIntoConstraints(false)
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
        internal func keyboardWillChangeFrame(notification: NSNotification) {
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
            keyboardBarDelegate?.msr_keyboardBarWillChangeFrame(self, animationInfo: AnimationInfo(keyboardNotification: notification))
            bottomConstraint?.constant = min((window?.frame.height ?? 0) - frameEnd.origin.y, frameEnd.height)
            UIView.animateWithDuration(duration,
                delay: 0,
                options: UIViewAnimationOptions(rawValue: UInt((curve ?? .EaseOut).rawValue)),
                animations: {
                    [weak self] in
                    self?.layoutIfNeeded()
                    return
                },
                completion: {
                    [weak self] finished in
                    self?.keyboardBarDelegate?.msr_keyboardBarWillChangeFrame(self!, animationInfo: AnimationInfo(keyboardNotification: notification))
                    return
                })
        }
        deinit {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
}