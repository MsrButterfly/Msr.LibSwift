import UIKit

extension UITextField {
    @objc class func msr_defaltClearButton() -> UIButton {
        struct _Static {
            static var id: dispatch_once_t = 0
            static var singleton: UITextField!
        }
        dispatch_once(&_Static.id) {
            _Static.singleton = UITextField()
            _Static.singleton.clearButtonMode = .Always
        }
        return _Static.singleton.msr_clearButton!.msr_clone() as! UIButton
    }
    @objc var msr_clearButton: UIButton? {
        return valueForKey("_clearButton") as? UIButton
    }
}
