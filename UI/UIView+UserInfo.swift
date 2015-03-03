import UIKit

extension Msr.UI._Detail {
    static var UIViewUserInfoAssociationKey: UnsafePointer<Void> {
        struct _Static {
            static var key = CChar()
        }
        return UnsafePointer<Void>.msr_to(&_Static.key)
    }
}

extension UIView {
    @objc var msr_userInfo: AnyObject? {
        get {
            return objc_getAssociatedObject(self, Msr.UI._Detail.UIViewUserInfoAssociationKey)
        }
        set {
            objc_setAssociatedObject(self, Msr.UI._Detail.UIViewUserInfoAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
}
