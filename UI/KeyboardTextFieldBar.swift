import UIKit

extension Msr.UI {
    class KeyboardTextFieldBar: UIToolbar, UIToolbarDelegate {
        let textField = UITextField()
        var textFieldBarButtonItem: UIBarButtonItem!
        var bottomConstraint: NSLayoutConstraint?
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
            textFieldBarButtonItem = UIBarButtonItem(customView: textField)
            textFieldBarButtonItem.width = 100
            delegate = self
            setItems([textFieldBarButtonItem, UIBarButtonItem(title: "发布", style: .Done, target: nil, action: nil)], animated: false)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
            let views = ["textField": textField, "self": self]
            textField.backgroundColor = UIColor.yellowColor()
            textField.placeholder = "PLACEHOLDER"
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[textField]-|", options: nil, metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[textField]-|", options: nil, metrics: nil, views: views))
            textField.setTranslatesAutoresizingMaskIntoConstraints(false)
            setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        override func didMoveToSuperview() {
            if superview != nil {
                let views = ["self": self]
                bottomConstraint = (NSLayoutConstraint.constraintsWithVisualFormat("V:[self]|", options: nil, metrics: nil, views: views).first as NSLayoutConstraint)
                superview!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[self]|", options: nil, metrics: nil, views: views))
                superview!.addConstraint(bottomConstraint!)
            }
        }
        internal func keyboardWillShow(notification: NSNotification) {
            print("\(unsafeAddressOf(self))-SHOW: ")
            println(notification.userInfo)
            let info = notification.userInfo!
            let frameEnd = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
            let duration = info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!
            let curve = UIViewAnimationOptions(rawValue: UInt(info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!))
            UIView.animateWithDuration(duration,
                delay: 0,
                options: curve,
                animations: {
                    self.bottomConstraint?.constant = frameEnd.height
                    return
                },
                completion: nil)
        }
        internal func keyboardWillHide(notification: NSNotification) {
            print("\(unsafeAddressOf(self))-HIDE: ")
            println(notification.userInfo)
            let info = notification.userInfo!
            let duration = info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!
            let curve = UIViewAnimationOptions(rawValue: UInt(info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!))
            UIView.animateWithDuration(duration,
                delay: 0,
                options: curve,
                animations: {
                    self.bottomConstraint?.constant = 0
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
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
}