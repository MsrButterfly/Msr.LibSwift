import UIKit

extension Msr.UI._Constant {
    static var UIViewEdgeAttachedConstraintAssociationKeys: [Msr.UI.Edge: UnsafePointer<Void>] {
        struct _Static {
            static var _keys: Int32 = 0
            static var keys: UnsafePointer<Void> {
                return UnsafePointer<Void>.msr_to(&_keys)
            }
        }
        return [
            .Top: _Static.keys.advancedBy(0),
            .Bottom: _Static.keys.advancedBy(1),
            .Left: _Static.keys.advancedBy(2),
            .Right: _Static.keys.advancedBy(3)]
    }
}

extension UIView {
    func msr_edgeAttachedConstraintAtEdge(edge: Msr.UI.Edge) -> NSLayoutConstraint? {
        return objc_getAssociatedObject(self, Msr.UI._Constant.UIViewEdgeAttachedConstraintAssociationKeys[edge]!) as? NSLayoutConstraint
    }
    private func msr_setEdgeAttachedConstraintAtEdge(edge: Msr.UI.Edge, toNil: Bool) {
        let views = ["self": self]
        let formats: [Msr.UI.Edge: String] = [
            .Top: "V:|[self]",
            .Bottom: "V:[self]|",
            .Left: "|[self]",
            .Right: "[self]|"]
        objc_setAssociatedObject(self, Msr.UI._Constant.UIViewEdgeAttachedConstraintAssociationKeys[edge]!, toNil ? nil : NSLayoutConstraint.constraintsWithVisualFormat(formats[edge]!, options: nil, metrics: nil, views: views).first, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
    }
    var msr_shouldTranslateAutoresizingMaskIntoConstraints: Bool {
        get {
            return translatesAutoresizingMaskIntoConstraints()
        }
        set {
            setTranslatesAutoresizingMaskIntoConstraints(newValue)
        }
    }
    func msr_addEdgeAttachedConstraintToSuperviewAtEdge(edge: Msr.UI.Edge) {
        if msr_edgeAttachedConstraintAtEdge(edge) == nil {
            msr_setEdgeAttachedConstraintAtEdge(edge, toNil: false)
            superview!.addConstraint(msr_edgeAttachedConstraintAtEdge(edge)!)
        }
    }
    func msr_addHorizontalExpandingConstraintsToSuperView() {
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Left)
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Right)
    }
    func msr_addVerticalExpandingConstraintsToSuperView() {
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Top)
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Bottom)
    }
    func msr_addAutoExpandingConstraintsToSuperview() {
        msr_addHorizontalExpandingConstraintsToSuperView()
        msr_addVerticalExpandingConstraintsToSuperView()
    }
    func msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(edge: Msr.UI.Edge) {
        let constraint = msr_edgeAttachedConstraintAtEdge(edge)
        if constraint != nil {
            superview!.removeConstraint(constraint!)
            msr_setEdgeAttachedConstraintAtEdge(edge, toNil: true)
        }
    }
    func msr_removeHorizontalExpandingConstraintsFromSuperview() {
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Left)
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Right)
    }
    func msr_removeVerticalExpandingConstraintsFromSuperview() {
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Top)
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Bottom)
    }
    func msr_removeAutoExpandingConstraintsFromSuperview() {
        msr_removeHorizontalExpandingConstraintsFromSuperview()
        msr_removeVerticalExpandingConstraintsFromSuperview()
    }
}
