import Foundation
import ObjectiveC

var _NSObjectMSRUserInfoAssociationKey: UnsafePointer<Void> {
    struct _Static {
        static var key = CChar()
    }
    return UnsafePointer<Void>(msr_memory: &_Static.key)
}

extension NSObject {
    @objc var msr_userInfo: AnyObject? {
        get {
            return objc_getAssociatedObject(self, _NSObjectMSRUserInfoAssociationKey)
        }
        set {
            objc_setAssociatedObject(self, _NSObjectMSRUserInfoAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
}
