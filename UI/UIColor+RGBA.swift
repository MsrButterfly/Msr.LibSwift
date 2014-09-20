import UIKit

extension UIColor {
    dynamic convenience init(RGBA: UInt32) {
        var v = [CGFloat]()
        var value = RGBA
        for _ in 1...4 {
            v.append(CGFloat(value & UInt32(0xff)) / CGFloat(0xff))
            value >>= 8
        }
        self.init(red: v[3], green: v[2], blue: v[1], alpha: v[0])
    }
    dynamic convenience init(RGB: UInt32) {
        self.init(RGBA: (RGB << 8) + 0xff)
    }
}

prefix operator %+ {}

prefix operator %- {}

prefix func %+(rhs: UInt32) -> UIColor {
    return UIColor(RGB: rhs)
}

prefix func %-(rhs: UInt32) -> UIColor {
    return UIColor(RGBA: rhs)
}
