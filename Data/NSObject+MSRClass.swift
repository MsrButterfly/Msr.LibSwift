import Foundation

extension NSObject {
    @objc class func msr_isClass(aClass: AnyClass) -> Bool {
        return isSubclassOfClass(aClass) && aClass.isSubclassOfClass(self)
    }
}
