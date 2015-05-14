import UIKit

@objc class MSRAnimationInfo: NSObject {
    override init() {
        super.init()
    }
    init(keyboardNotification: NSNotification) {
        let info = keyboardNotification.userInfo! as! [NSString: AnyObject]
        frameBegin = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        frameEnd = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        duration = info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!
        curve = UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!)!
        super.init()
    }
    func animate(animation: (() -> Void)) {
        animate(animation, completion: nil)
    }
    func animate(animation: (() -> Void), completion: ((Bool) -> Void)?) {
        animate(delay: 0, options: nil, animation: animation, completion: completion)
    }
    func animate(#delay: NSTimeInterval, options: UIViewAnimationOptions, animation: (() -> Void), completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(duration,
            delay: delay,
            options: UIViewAnimationOptions(rawValue: UInt(curve.rawValue)) | options,
            animations: animation,
            completion: completion)
    }
    var frameBegin: CGRect = CGRectZero
    var frameEnd: CGRect = CGRectZero
    var duration: NSTimeInterval = 0
    var curve: UIViewAnimationCurve = .Linear
}
