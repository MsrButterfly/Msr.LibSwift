import UIKit

extension CGRect {
    var msr_leftX: CGFloat {
        return origin.x
    }
    var msr_rightX: CGFloat {
        return origin.x + width
    }
    var msr_topY: CGFloat {
        return origin.y
    }
    var msr_downY: CGFloat {
        return origin.y + height
    }
    var msr_center: CGPoint {
        return CGPoint(x: msr_leftX + width / 2, y: msr_topY + height / 2)
    }
}
