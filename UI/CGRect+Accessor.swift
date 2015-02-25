import UIKit

extension CGRect {
    var msr_left: CGFloat {
        set {
            let right = msr_right
            origin.x = newValue
            msr_right = right
        }
        get {
            return origin.x
        }
    }
    var msr_right: CGFloat {
        set {
            size.width = newValue - msr_left
        }
        get {
            return msr_left + width
        }
    }
    var msr_top: CGFloat {
        set {
            let bottom = msr_bottom
            origin.y = newValue
            msr_bottom = bottom
        }
        get {
            return origin.y
        }
    }
    var msr_bottom: CGFloat {
        set {
            size.height = newValue - msr_top
        }
        get {
            return msr_top + height
        }
    }
    var msr_center: CGPoint {
        set {
            msr_left = newValue.x - width / 2
            msr_top = newValue.y - height / 2
        }
        get {
            return CGPoint(x: msr_left + width / 2, y: msr_top + height / 2)
        }
    }
}
