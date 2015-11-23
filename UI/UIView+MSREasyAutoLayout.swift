import ObjectiveC
import UIKit

var _UIViewMSREdgeAttachedConstraintAssociationKeys: [MSRFrameEdge: UnsafePointer<Void>] {
    struct _Static {
        static var _keys: Int32 = 0
        static var keys: UnsafePointer<Void> {
            return UnsafePointer<Void>(msr_memory: &_keys)
        }
    }
    return [
        .Top: _Static.keys.advancedBy(0),
        .Bottom: _Static.keys.advancedBy(1),
        .Left: _Static.keys.advancedBy(2),
        .Right: _Static.keys.advancedBy(3)]
}

extension UIView {
    @objc func msr_edgeAttachedConstraintAtEdge(edge: MSRFrameEdge) -> NSLayoutConstraint? {
        return (objc_getAssociatedObject(self, _UIViewMSREdgeAttachedConstraintAssociationKeys[edge]!) as? MSRWeak<NSLayoutConstraint>)?.object
    }
    @objc func msr_addEdgeAttachedConstraintToSuperviewAtEdge(edge: MSRFrameEdge) {
        if msr_edgeAttachedConstraintAtEdge(edge) == nil {
            let views = ["self": self]
            let formats: [MSRFrameEdge: String] = [
                .Top: "V:|[self]",
                .Bottom: "V:[self]|",
                .Left: "|[self]",
                .Right: "[self]|"]
            let c = NSLayoutConstraint.constraintsWithVisualFormat(formats[edge]!, options: [], metrics: nil, views: views).first!
            let w = MSRWeak(object: c)
            objc_setAssociatedObject(self, _UIViewMSREdgeAttachedConstraintAssociationKeys[edge]!, w, .OBJC_ASSOCIATION_RETAIN)
            superview!.addConstraint(c)
        }
    }
    @objc var msr_topAttachedConstraint: NSLayoutConstraint? {
        return msr_edgeAttachedConstraintAtEdge(.Top)
    }
    @objc var msr_bottomAttachedConstraint: NSLayoutConstraint? {
        return msr_edgeAttachedConstraintAtEdge(.Bottom)
    }
    @objc var msr_leftAttachedConstraint: NSLayoutConstraint? {
        return msr_edgeAttachedConstraintAtEdge(.Left)
    }
    @objc var msr_rightAttachedConstraint: NSLayoutConstraint? {
        return msr_edgeAttachedConstraintAtEdge(.Right)
    }
    @objc func msr_addTopAttachedConstraintToSuperview() {
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Top)
    }
    @objc func msr_addBottomAttachedConstraintToSuperview() {
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Bottom)
    }
    @objc func msr_addLeftAttachedConstraintToSuperview() {
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Left)
    }
    @objc func msr_addRightAttachedConstraintToSuperview() {
        msr_addEdgeAttachedConstraintToSuperviewAtEdge(.Right)
    }
    @objc func msr_addHorizontalEdgeAttachedConstraintsToSuperview() {
        msr_addLeftAttachedConstraintToSuperview()
        msr_addRightAttachedConstraintToSuperview()
    }
    @objc func msr_addVerticalEdgeAttachedConstraintsToSuperview() {
        msr_addTopAttachedConstraintToSuperview()
        msr_addBottomAttachedConstraintToSuperview()
    }
    @objc func msr_addAllEdgeAttachedConstraintsToSuperview() {
        msr_addHorizontalEdgeAttachedConstraintsToSuperview()
        msr_addVerticalEdgeAttachedConstraintsToSuperview()
    }
    @objc func msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(edge: MSRFrameEdge) {
        let constraint = msr_edgeAttachedConstraintAtEdge(edge)
        if constraint != nil {
            superview!.removeConstraint(constraint!)
        }
    }
    @objc func msr_removeTopAttachedConstraintFromSuperview() {
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Top)
    }
    @objc func msr_removeBottomAttachedConstraintFromSuperview() {
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Bottom)
    }
    @objc func msr_removeLeftAttachedConstraintFromSuperview() {
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Left)
    }
    @objc func msr_removeRightAttachedConstraintFromSuperview() {
        msr_removeEdgeAttachedConstraintFromSuperviewAtEdge(.Right)
    }
    @objc func msr_removeHorizontalEdgeAttachedConstraintsFromSuperview() {
        msr_removeLeftAttachedConstraintFromSuperview()
        msr_removeRightAttachedConstraintFromSuperview()
    }
    @objc func msr_removeVerticalEdgeAttachedConstraintsFromSuperview() {
        msr_removeTopAttachedConstraintFromSuperview()
        msr_removeBottomAttachedConstraintFromSuperview()
    }
    @objc func msr_removeAllEdgeAttachedConstraintsFromSuperview() {
        msr_removeHorizontalEdgeAttachedConstraintsFromSuperview()
        msr_removeVerticalEdgeAttachedConstraintsFromSuperview()
    }
}

var _UIViewMSRSizeConstraintAssociationKeys: [UILayoutConstraintAxis: UnsafePointer<Void>] {
    struct _Static {
        static var _keys: Int16 = 0
        static var keys: UnsafePointer<Void> {
            return UnsafePointer<Void>(msr_memory: &_keys)
        }
    }
    return [
        .Horizontal: _Static.keys.advancedBy(0),
        .Vertical: _Static.keys.advancedBy(1)]
}

extension UIView {
    @objc func msr_sizeConstraintForAxis(axis: UILayoutConstraintAxis) -> NSLayoutConstraint? {
        return (objc_getAssociatedObject(self, _UIViewMSRSizeConstraintAssociationKeys[axis]!) as? MSRWeak<NSLayoutConstraint>)?.object
    }
    @objc func msr_addSizeConstraintForAxis(axis: UILayoutConstraintAxis, value: CGFloat) {
        if msr_sizeConstraintForAxis(axis) == nil {
            let views = ["self": self]
            let formats: [UILayoutConstraintAxis: String] = [
                .Horizontal: "[self(==0)]",
                .Vertical: "V:[self(==0)]"]
            let c = NSLayoutConstraint.constraintsWithVisualFormat(formats[axis]!, options: [], metrics: nil, views: views).first!
            let w = MSRWeak(object: c)
            objc_setAssociatedObject(self, _UIViewMSRSizeConstraintAssociationKeys[axis]!, w, .OBJC_ASSOCIATION_RETAIN)
            addConstraint(msr_sizeConstraintForAxis(axis)!)
        }
        msr_sizeConstraintForAxis(axis)!.constant = value
    }
    @objc func msr_removeSizeConstraintForAxis(axis: UILayoutConstraintAxis) {
        if msr_sizeConstraintForAxis(axis) != nil {
            removeConstraint(msr_sizeConstraintForAxis(axis)!)
        }
    }
    @objc var msr_widthConstraint: NSLayoutConstraint? {
        return msr_sizeConstraintForAxis(.Horizontal)
    }
    @objc var msr_heightConstraint: NSLayoutConstraint? {
        return msr_sizeConstraintForAxis(.Vertical)
    }
    @objc func msr_addWidthConstraintWithValue(value: CGFloat) {
        msr_addSizeConstraintForAxis(.Horizontal, value: value)
    }
    @objc func msr_addHeightConstraintWithValue(value: CGFloat) {
        msr_addSizeConstraintForAxis(.Vertical, value: value)
    }
    @objc func msr_removeWidthConstraint() {
        msr_removeSizeConstraintForAxis(.Horizontal)
    }
    @objc func msr_removeHeightConstraint() {
        msr_removeSizeConstraintForAxis(.Vertical)
    }
    @objc func msr_addSizeConstraintsWithSize(size: CGSize) {
        msr_addWidthConstraintWithValue(size.width)
        msr_addHeightConstraintWithValue(size.height)
    }
    @objc func msr_removeSizeConstraints() {
        msr_removeWidthConstraint()
        msr_removeHeightConstraint()
    }
}

var _UIViewMSRCenterConstraintAssociationKeys: [UILayoutConstraintAxis: UnsafePointer<Void>] {
    struct _Static {
        static var _keys: Int16 = 0
        static var keys: UnsafePointer<Void> {
            return UnsafePointer<Void>(msr_memory: &_keys)
        }
    }
    return [
        .Horizontal: _Static.keys.advancedBy(0),
        .Vertical: _Static.keys.advancedBy(1)]
}

extension UIView {
    @objc func msr_centerConstraintOfDirection(direction: UILayoutConstraintAxis) -> NSLayoutConstraint? {
        return (objc_getAssociatedObject(self, _UIViewMSRCenterConstraintAssociationKeys[direction]!) as? MSRWeak<NSLayoutConstraint>)?.object
    }
    @objc func msr_addCenterConstraintToSuperviewWithDirection(direction: UILayoutConstraintAxis) {
        if msr_centerConstraintOfDirection(direction) == nil {
            let constraints: [UILayoutConstraintAxis: NSLayoutConstraint] = [
                .Horizontal: NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: superview!, attribute: .CenterX, multiplier: 1, constant: 0),
                .Vertical: NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: superview!, attribute: .CenterY, multiplier: 1, constant: 0)]
            let c = constraints[direction]!
            let w = MSRWeak(object: c)
            objc_setAssociatedObject(self, _UIViewMSRCenterConstraintAssociationKeys[direction]!, w, .OBJC_ASSOCIATION_RETAIN)
            superview!.addConstraint(c)
        }
    }
    @objc func msr_removeCenterConstraintFromSuperviewWithDirection(direction: UILayoutConstraintAxis) {
        if msr_centerConstraintOfDirection(direction) != nil {
            removeConstraint(msr_centerConstraintOfDirection(direction)!)
        }
    }
    @objc var msr_centerXConstraint: NSLayoutConstraint? {
        return msr_centerConstraintOfDirection(.Horizontal)
    }
    @objc var msr_centerYConstraint: NSLayoutConstraint? {
        return msr_centerConstraintOfDirection(.Vertical)
    }
    @objc func msr_addCenterXConstraintToSuperview() {
        msr_addCenterConstraintToSuperviewWithDirection(.Horizontal)
    }
    @objc func msr_addCenterYConstraintToSuperview() {
        msr_addCenterConstraintToSuperviewWithDirection(.Vertical)
    }
    @objc func msr_removeCenterXConstraintFromSuperview() {
        msr_removeCenterConstraintFromSuperviewWithDirection(.Horizontal)
    }
    @objc func msr_removeCenterYConstraintFromSuperview() {
        msr_removeCenterConstraintFromSuperviewWithDirection(.Vertical)
    }
    @objc func msr_addCenterConstraintsToSuperview() {
        msr_addCenterXConstraintToSuperview()
        msr_addCenterYConstraintToSuperview()
    }
    @objc func msr_removeCenterConstraintsFromSuperview() {
        msr_removeCenterXConstraintFromSuperview()
        msr_removeCenterYConstraintFromSuperview()
    }
}
