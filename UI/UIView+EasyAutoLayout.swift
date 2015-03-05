import UIKit

extension Msr.UI._Detail {
    static var UIViewEdgeAttachedConstraintAssociationKeys: [Msr.UI.FrameEdge: UnsafePointer<Void>] {
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
    func msr_edgeAttachedConstraintAtEdge(edge: Msr.UI.FrameEdge) -> NSLayoutConstraint? {
        return objc_getAssociatedObject(self, Msr.UI._Detail.UIViewEdgeAttachedConstraintAssociationKeys[edge]!) as? NSLayoutConstraint
    }
    private func msr_setEdgeAttachedConstraintAtEdge(edge: Msr.UI.FrameEdge, toNil: Bool) {
        let views = ["self": self]
        let formats: [Msr.UI.FrameEdge: String] = [
            .Top: "V:|[self]",
            .Bottom: "V:[self]|",
            .Left: "|[self]",
            .Right: "[self]|"]
        objc_setAssociatedObject(self, Msr.UI._Detail.UIViewEdgeAttachedConstraintAssociationKeys[edge]!, toNil ? nil : NSLayoutConstraint.constraintsWithVisualFormat(formats[edge]!, options: nil, metrics: nil, views: views).first, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
    }
    var msr_shouldTranslateAutoresizingMaskIntoConstraints: Bool {
        get {
            return translatesAutoresizingMaskIntoConstraints()
        }
        set {
            setTranslatesAutoresizingMaskIntoConstraints(newValue)
        }
    }
    func msr_addEdgeAttachedConstraintToSuperviewAtEdge(edge: Msr.UI.FrameEdge) {
        if msr_edgeAttachedConstraintAtEdge(edge) == nil {
            msr_setEdgeAttachedConstraintAtEdge(edge, toNil: false)
            superview!.addConstraint(msr_edgeAttachedConstraintAtEdge(edge)!)
        }
    }
    var msr_topAttachedConstraint: NSLayoutConstraint? {
        return msr_edgeAttachedConstraintAtEdge(.Top)
    }
    var msr_bottomAttachedConstraint: NSLayoutConstraint? {
        return msr_edgeAttachedConstraintAtEdge(.Bottom)
    }
    var msr_leftAttachedConstraint: NSLayoutConstraint? {
        return msr_edgeAttachedConstraintAtEdge(.Left)
    }
    var msr_rightAttachedConstraint: NSLayoutConstraint? {
        return msr_edgeAttachedConstraintAtEdge(.Right)
    }
    func msr_addTopAttachedConstraintToSuperview() {
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Top)
    }
    func msr_addBottomAttachedConstraintToSuperview() {
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Bottom)
    }
    func msr_addLeftAttachedConstraintToSuperview() {
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Left)
    }
    func msr_addRightAttachedConstraintToSuperview() {
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Right)
    }
    func msr_addHorizontalEdgeAttachedConstraintsToSuperview() {
        msr_addLeftAttachedConstraintToSuperview()
        msr_addRightAttachedConstraintToSuperview()
    }
    func msr_addVerticalEdgeAttachedConstraintsToSuperview() {
        msr_addTopAttachedConstraintToSuperview()
        msr_addBottomAttachedConstraintToSuperview()
    }
    func msr_addAllEdgeAttachedConstraintsToSuperview() {
        msr_addHorizontalEdgeAttachedConstraintsToSuperview()
        msr_addVerticalEdgeAttachedConstraintsToSuperview()
    }
    func msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(edge: Msr.UI.FrameEdge) {
        let constraint = msr_edgeAttachedConstraintAtEdge(edge)
        if constraint != nil {
            superview!.removeConstraint(constraint!)
            msr_setEdgeAttachedConstraintAtEdge(edge, toNil: true)
        }
    }
    func msr_removeTopAttachedConstraintFromSuperview() {
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Top)
    }
    func msr_removeBottomAttachedConstraintFromSuperview() {
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Bottom)
    }
    func msr_removeLeftAttachedConstraintFromSuperview() {
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Left)
    }
    func msr_removeRightAttachedConstraintFromSuperview() {
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Right)
    }
    func msr_removeHorizontalEdgeAttachedConstraintsFromSuperview() {
        msr_removeLeftAttachedConstraintFromSuperview()
        msr_removeRightAttachedConstraintFromSuperview()
    }
    func msr_removeVerticalEdgeAttachedConstraintsFromSuperview() {
        msr_removeTopAttachedConstraintFromSuperview()
        msr_removeBottomAttachedConstraintFromSuperview()
    }
    func msr_removeAllEdgeAttachedConstraintsFromSuperview() {
        msr_removeHorizontalEdgeAttachedConstraintsFromSuperview()
        msr_removeVerticalEdgeAttachedConstraintsFromSuperview()
    }
}

extension Msr.UI._Detail {
    static var UIViewSizeConstraintAssociationKeys: [UILayoutConstraintAxis: UnsafePointer<Void>] {
        struct _Static {
            static var _keys: Int16 = 0
            static var keys: UnsafePointer<Void> {
                return UnsafePointer<Void>.msr_to(&_keys)
            }
        }
        return [
            .Horizontal: _Static.keys.advancedBy(0),
            .Vertical: _Static.keys.advancedBy(1)]
    }
}

extension UIView {
    func msr_sizeConstraintForAxis(axis: UILayoutConstraintAxis) -> NSLayoutConstraint? {
        return objc_getAssociatedObject(self, Msr.UI._Detail.UIViewSizeConstraintAssociationKeys[axis]!) as? NSLayoutConstraint
    }
    func msr_addSizeConstraintForAxis(axis: UILayoutConstraintAxis, value: CGFloat) {
        if msr_sizeConstraintForAxis(axis) == nil {
            let views = ["self": self]
            let formats: [UILayoutConstraintAxis: String] = [
                .Horizontal: "[self(==0)]",
                .Vertical: "V:[self(==0)]|"]
            objc_setAssociatedObject(self, Msr.UI._Detail.UIViewSizeConstraintAssociationKeys[axis]!, NSLayoutConstraint.constraintsWithVisualFormat(formats[axis]!, options: nil, metrics: nil, views: views).first, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            addConstraint(msr_sizeConstraintForAxis(axis)!)
        }
        msr_sizeConstraintForAxis(axis)!.constant = value
    }
    func msr_removeSizeConstraintForAxis(axis: UILayoutConstraintAxis) {
        if msr_sizeConstraintForAxis(axis) != nil {
            removeConstraint(msr_sizeConstraintForAxis(axis)!)
        }
    }
    var msr_widthConstraint: NSLayoutConstraint? {
        return msr_sizeConstraintForAxis(.Horizontal)
    }
    var msr_heightConstraint: NSLayoutConstraint? {
        return msr_sizeConstraintForAxis(.Vertical)
    }
    func msr_addWidthConstraintWithValue(value: CGFloat) {
        msr_addSizeConstraintForAxis(.Horizontal, value: value)
    }
    func msr_addHeightConstraintWithValue(value: CGFloat) {
        msr_addSizeConstraintForAxis(.Vertical, value: value)
    }
    func msr_removeWidthConstraint() {
        msr_removeSizeConstraintForAxis(.Horizontal)
    }
    func msr_removeHeightConstraint() {
        msr_removeSizeConstraintForAxis(.Vertical)
    }
    func msr_addSizeConstraintsWithSize(size: CGSize) {
        msr_addWidthConstraintWithValue(size.width)
        msr_addHeightConstraintWithValue(size.height)
    }
    func msr_removeSizeConstraints() {
        msr_removeWidthConstraint()
        msr_removeHeightConstraint()
    }
}

extension Msr.UI._Detail {
    static var UIViewCenterConstraintAssociationKeys: [UILayoutConstraintAxis: UnsafePointer<Void>] {
        struct _Static {
            static var _keys: Int16 = 0
            static var keys: UnsafePointer<Void> {
                return UnsafePointer<Void>.msr_to(&_keys)
            }
        }
        return [
            .Horizontal: _Static.keys.advancedBy(0),
            .Vertical: _Static.keys.advancedBy(1)]
    }
}

extension UIView {
    func msr_centerConstraintOfDirection(direction: UILayoutConstraintAxis) -> NSLayoutConstraint? {
        return objc_getAssociatedObject(self, Msr.UI._Detail.UIViewCenterConstraintAssociationKeys[direction]!) as? NSLayoutConstraint
    }
    func msr_addCenterConstraintToSuperviewWithDirection(direction: UILayoutConstraintAxis) {
        if msr_centerConstraintOfDirection(direction) == nil {
            let constraints: [UILayoutConstraintAxis: NSLayoutConstraint] = [
                .Horizontal: NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: superview!, attribute: .CenterX, multiplier: 1, constant: 0),
                .Vertical: NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: superview!, attribute: .CenterY, multiplier: 1, constant: 0)]
            objc_setAssociatedObject(self, Msr.UI._Detail.UIViewCenterConstraintAssociationKeys[direction]!, constraints[direction]!, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            superview!.addConstraint(msr_centerConstraintOfDirection(direction)!)
        }
    }
    func msr_removeCenterConstraintFromSuperviewWithDirection(direction: UILayoutConstraintAxis) {
        if msr_centerConstraintOfDirection(direction) != nil {
            removeConstraint(msr_centerConstraintOfDirection(direction)!)
        }
    }
    var msr_centerXConstraint: NSLayoutConstraint? {
        return msr_centerConstraintOfDirection(.Horizontal)
    }
    var msr_centerYConstraint: NSLayoutConstraint? {
        return msr_centerConstraintOfDirection(.Vertical)
    }
    func msr_addCenterXConstraintToSuperview() {
        msr_addCenterConstraintToSuperviewWithDirection(.Horizontal)
    }
    func msr_addCenterYConstraintToSuperview() {
        msr_addCenterConstraintToSuperviewWithDirection(.Vertical)
    }
    func msr_removeCenterXConstraintFromSuperview() {
        msr_removeCenterConstraintFromSuperviewWithDirection(.Horizontal)
    }
    func msr_removeCenterYConstraintFromSuperview() {
        msr_removeCenterConstraintFromSuperviewWithDirection(.Vertical)
    }
    func msr_addCenterConstraintsToSuperview() {
        msr_addCenterXConstraintToSuperview()
        msr_addCenterYConstraintToSuperview()
    }
    func msr_removeCenterConstraintsFromSuperview() {
        msr_removeCenterXConstraintFromSuperview()
        msr_removeCenterYConstraintFromSuperview()
    }
}
