import UIKit

extension Msr.UI._Constant {
    static var UIControlUserInfoAssociationKey = CChar()
}

extension UIControl {
    var msrUserInfo: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &Msr.UI._Constant.UIControlUserInfoAssociationKey)
        }
        set {
            objc_setAssociatedObject(self, &Msr.UI._Constant.UIControlUserInfoAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
}
