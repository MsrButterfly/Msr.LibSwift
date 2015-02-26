import UIKit

protocol MsrKeyboardBarDelegate: NSObjectProtocol {
    func msr_keyboardBarWillChangeFrame(keyboardBar: Msr.UI.KeyboardBar, animationInfo: Msr.UI.AnimationInfo)
    func msr_keyboardBarDidChangeFrame(keyboardBar: Msr.UI.KeyboardBar, animationInfo: Msr.UI.AnimationInfo)
}

extension Msr.UI {
    class KeyboardBar: UIView {
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
            msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        }
        override func willMoveToSuperview(newSuperview: UIView?) {
            super.willMoveToSuperview(newSuperview)
            if superview != nil {
                msr_removeAutoExpandingConstraintsFromSuperview()
            }
        }
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            if superview != nil {
                msr_addHorizontalExpandingConstraintsToSuperView()
                msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Bottom)
            }
        }
        internal func keyboardWillChangeFrame(notification: NSNotification) {
            updateFrame(notification, completion: nil)
        }
        private func updateFrame(notification: NSNotification, completion: ((Bool) -> Void)?) {
            let info = notification.userInfo!
            let frameEnd = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
            let duration = info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!
            let curve = UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue)
            keyboardBarDelegate?.msr_keyboardBarWillChangeFrame(self, animationInfo: AnimationInfo(keyboardNotification: notification))
            msr_edgeAttachedConstraintAtEdge(.Bottom)?.constant = min((window?.frame.height ?? 0) - frameEnd.msr_top, frameEnd.height)
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
