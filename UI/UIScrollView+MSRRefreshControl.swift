import UIKit
import ObjectiveC

private var _UIScrollViewMSRUIRefreshControlAssociationKey: UnsafePointer<Void> {
    struct _Static {
        static var key = CChar()
    }
    return UnsafePointer<Void>(msr_memory: &_Static.key)
}

private var _MSRUIScrollViewPanGestureTranslationAdjustmentIsInstalled = false

extension UIScrollView {
    var msr_uiRefreshControl: UIRefreshControl? {
        set {
            self.msr_uiRefreshControl?.removeFromSuperview()
            objc_setAssociatedObject(self, _UIScrollViewMSRUIRefreshControlAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            if self.msr_uiRefreshControl != nil {
                addSubview(self.msr_uiRefreshControl!)
            }
        }
        get {
            return objc_getAssociatedObject(self, _UIScrollViewMSRUIRefreshControlAssociationKey) as? UIRefreshControl
        }
    }
    class func msr_installPanGestureTranslationAdjustment() {
        if !_MSRUIScrollViewPanGestureTranslationAdjustmentIsInstalled {
            _MSRUIScrollViewPanGestureTranslationAdjustmentIsInstalled = true
            method_exchangeImplementations(
                class_getInstanceMethod(self, "setContentInset:"),
                class_getInstanceMethod(self, "msr_setContentInset:"))
        }
    }
    class func msr_removePanGestureTranslationAdjustment() {
        if _MSRUIScrollViewPanGestureTranslationAdjustmentIsInstalled {
            _MSRUIScrollViewPanGestureTranslationAdjustmentIsInstalled = false
            method_exchangeImplementations(
                class_getInstanceMethod(self, "setContentInset:"),
                class_getInstanceMethod(self, "msr_setContentInset:"))
        }
    }
    internal func msr_setContentInset(contentInset: UIEdgeInsets) {
        if !(nextResponder() is UITableViewController) && tracking {
            let offset = contentInset.top - self.contentInset.top
            var translation = panGestureRecognizer.translationInView(self)
            translation.y -= offset * 3 / 2
            panGestureRecognizer.setTranslation(translation, inView: self)
        }
        msr_setContentInset(contentInset) // This is correct because the implementation has been exchanged with setContentInset:
    }
}
