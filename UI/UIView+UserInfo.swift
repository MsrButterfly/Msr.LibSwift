import UIKit

extension Msr.UI._Constant {
    static var UIViewUserInfoAssociationKey: UnsafePointer<Void> {
        struct _Static {
            static var key = CChar()
        }
        return UnsafePointer<Void>(UnsafePointer.msr_of(&_Static.key))
    }
}

extension UIView {
    @objc var msr_userInfo: AnyObject? {
        get {
            return objc_getAssociatedObject(self, Msr.UI._Constant.UIViewUserInfoAssociationKey)
        }
        set {
            objc_setAssociatedObject(self, Msr.UI._Constant.UIViewUserInfoAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
}
