import CoreGraphics

extension CGRect {
    var msr_left: CGFloat {
        set {
            self = CGRect(x: newValue, y: origin.y, width: width - (newValue - msr_left), height: height)
        }
        get {
            return minX
        }
    }
    var msr_right: CGFloat {
        set {
            size.width = newValue - msr_left
        }
        get {
            return maxX
        }
    }
    var msr_top: CGFloat {
        set {
            self = CGRect(x: origin.x, y: newValue, width: width, height: height - (newValue - msr_top))
        }
        get {
            return minY
        }
    }
    var msr_bottom: CGFloat {
        set {
            size.height = newValue - msr_top
        }
        get {
            return maxY
        }
    }
    var msr_center: CGPoint {
        set {
            origin = CGPoint(x: newValue.x - width / 2, y: newValue.y - height / 2)
        }
        get {
            return CGPoint(x: midX, y: midY)
        }
    }
}
