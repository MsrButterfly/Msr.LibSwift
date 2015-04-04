@objc class MSRAnimationInfo: NSObject {
    override init() {
        super.init()
    }
    init(keyboardNotification: NSNotification) {
        let info = keyboardNotification.userInfo! as! [NSString: AnyObject]
        frameBegin = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        frameEnd = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        animationDuration = info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!
        animationCurve = UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!)!
        super.init()
    }
    var frameBegin: CGRect = CGRectZero
    var frameEnd: CGRect = CGRectZero
    var animationDuration: NSTimeInterval = 0
    var animationCurve: UIViewAnimationCurve = .Linear
}
