import UIKit
import ObjectiveC

private var _UIScrollViewMSRClassesOfContentViewsWhereTouchesShouldCancelAssociationKey: UnsafePointer<Void> {
    struct _Static {
        static var key = CChar()
    }
    return UnsafePointer<Void>(msr_memory: &_Static.key)
}

private var _UIScrollViewMSRBaseClassesOfContentViewsWhereTouchesShouldCancelAssociationKey: UnsafePointer<Void> {
    struct _Static {
        static var key = CChar()
    }
    return UnsafePointer<Void>(msr_memory: &_Static.key)
}

private var _UIScrollViewMSRContentViewsWhereTouchesShouldCancelAssociationKey: UnsafePointer<Void> {
    struct _Static {
        static var key = CChar()
    }
    return UnsafePointer<Void>(msr_memory: &_Static.key)
}

extension UIScrollView {
    
    // UIView.Type is not Hashable
    private var msr_classesOfContentViewsWhereTouchesShouldCancel: [(UIView.Type, Bool)] {
        set {
            let s = MSRValue(value: newValue)
            objc_setAssociatedObject(self, _UIScrollViewMSRClassesOfContentViewsWhereTouchesShouldCancelAssociationKey, s, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            let getWrapper = {
                return objc_getAssociatedObject(self, _UIScrollViewMSRClassesOfContentViewsWhereTouchesShouldCancelAssociationKey) as? MSRValue<[(UIView.Type, Bool)]>
            }
            if getWrapper() == nil {
                self.msr_classesOfContentViewsWhereTouchesShouldCancel = []
            }
            return getWrapper()!.value
        }
    }
    
    // This should be ordered to present a tree.
    private var msr_baseClassesOfContentViewsWhereTouchesShouldCancel: [(UIView.Type, Bool)] {
        set {
            let s = MSRValue(value: newValue)
            objc_setAssociatedObject(self, _UIScrollViewMSRBaseClassesOfContentViewsWhereTouchesShouldCancelAssociationKey, s, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            let getWrapper = {
                return objc_getAssociatedObject(self, _UIScrollViewMSRBaseClassesOfContentViewsWhereTouchesShouldCancelAssociationKey) as? MSRValue<[(UIView.Type, Bool)]>
            }
            if getWrapper() == nil {
                self.msr_baseClassesOfContentViewsWhereTouchesShouldCancel = [
                    (UIControl.self, false),
                    (UIView.self, true)]
            }
            return getWrapper()!.value
        }
    }
    
    private var msr_contentViewsWhereTouchesShouldCancel: [UIView: Bool] {
        set {
            objc_setAssociatedObject(self, _UIScrollViewMSRContentViewsWhereTouchesShouldCancelAssociationKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
        get {
            let getCurrentValue = {
                return objc_getAssociatedObject(self, _UIScrollViewMSRContentViewsWhereTouchesShouldCancelAssociationKey)
            }
            if getCurrentValue() == nil {
                self.msr_contentViewsWhereTouchesShouldCancel = [:]
            }
            return getCurrentValue() as! [UIView: Bool]
        }
    }
    
    @objc func msr_setTouchesShouldCancel(value: Bool, inContentViewWhichIsMemberOfClass aClass: UIView.Type) {
        if let index = msr_classesOfContentViewsWhereTouchesShouldCancel.map({ aClass === $0.0 }).indexOf(true) {
            msr_classesOfContentViewsWhereTouchesShouldCancel[index].1 = value
        } else {
            msr_classesOfContentViewsWhereTouchesShouldCancel.append((aClass, value))
        }
    }
    
    @objc func msr_setTouchesShouldCancel(value: Bool, inContentViewWhichIsKindOfClass aClass: UIView.Type) {
        if let index = msr_baseClassesOfContentViewsWhereTouchesShouldCancel.map({ aClass === $0.0 }).indexOf(true) {
            msr_baseClassesOfContentViewsWhereTouchesShouldCancel[index].1 = value
        } else if let index = msr_baseClassesOfContentViewsWhereTouchesShouldCancel.map({ aClass.isSubclassOfClass($0.0) }).indexOf(true) {
            msr_baseClassesOfContentViewsWhereTouchesShouldCancel.insert((aClass, value), atIndex: index)
        } else {
            msr_baseClassesOfContentViewsWhereTouchesShouldCancel.append((aClass, value))
        }
    }
    
    @objc func msr_setTouchesShouldCancel(value: Bool, inContentView view: UIView) {
        msr_contentViewsWhereTouchesShouldCancel[view] = value
    }
    
    internal func msr_touchesShouldCancelInContentView(view: UIView!) -> Bool {
        for (v, value) in msr_contentViewsWhereTouchesShouldCancel {
            if view === v {
                return value
            }
        }
        for (c, value) in msr_classesOfContentViewsWhereTouchesShouldCancel {
            if view.isMemberOfClass(c) {
                return value
            }
        }
        for (c, value) in msr_baseClassesOfContentViewsWhereTouchesShouldCancel {
            if view.isKindOfClass(c) {
                return value
            }
        }
        fatalError("There must be a bug here. Please contact the author to fix it, with the messages below.\n msr_contentViewsWhereTouchesShouldCancel: \(msr_contentViewsWhereTouchesShouldCancel)\nmsr_classesOfContentViewsWhereTouchesShouldCancel: \(msr_classesOfContentViewsWhereTouchesShouldCancel)\nmsr_baseClassesOfContentViewsWhereTouchesShouldCancel: \(msr_baseClassesOfContentViewsWhereTouchesShouldCancel)")
    }
    
    @objc class func msr_installTouchesCancellingExtension() {
        struct _Static {
            static var id: dispatch_once_t = 0
        }
        dispatch_once(&_Static.id) {
            method_exchangeImplementations(
                class_getInstanceMethod(self, "touchesShouldCancelInContentView:"),
                class_getInstanceMethod(self, "msr_touchesShouldCancelInContentView:"))
        }
    }
    
}
