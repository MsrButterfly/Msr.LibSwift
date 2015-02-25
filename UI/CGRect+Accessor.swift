import UIKit

extension CGRect {
    var msr_leftX: CGFloat {
        set {
            origin.x = newValue
        }
        get {
            return origin.x
        }
    }
    var msr_rightX: CGFloat {
        set {
            size.width = newValue - origin.x
        }
        get {
            return origin.x + width
        }
    }
    var msr_topY: CGFloat {
        set {
            origin.y = newValue
        }
        get {
            return origin.y
        }
    }
    var msr_downY: CGFloat {
        set {
            size.height = newValue - origin.x
        }
        get {
            return origin.y + height
        }
    }
    var msr_center: CGPoint {
        set {
            msr_leftX = newValue.x - width / 2
            msr_topY = newValue.y - height / 2
        }
        get {
            return CGPoint(x: msr_leftX + width / 2, y: msr_topY + height / 2)
        }
    }
}
