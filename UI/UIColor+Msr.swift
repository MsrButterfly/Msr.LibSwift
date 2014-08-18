import UIKit

extension UIColor {
    dynamic convenience init(RGBA: UInt32) {
        var v = [CGFloat]()
        var rgba = RGBA
        for _ in 1...4 {
            v.append(CGFloat(rgba % UInt32(0x100)) / CGFloat(0xff))
            rgba >>= 8
        }
        self.init(red: v[3], green: v[2], blue: v[1], alpha: v[0])
    }
    dynamic convenience init(RGB: UInt32) {
        var RGBA = UInt32(RGB) << UInt32(8)
        RGBA += 0xff
        self.init(RGBA: RGBA)
    }
    class func randomColor(opaque: Bool) -> UIColor {
        let max = 255 as UInt32
        let red = CGFloat(Int(arc4random_uniform(max))) / CGFloat(255)
        let green = CGFloat(Int(arc4random_uniform(max))) / CGFloat(255)
        let blue = CGFloat(Int(arc4random_uniform(max))) / CGFloat(255)
        var alpha = CGFloat(1)
        if !opaque {
            alpha = CGFloat(Int(arc4random_uniform(max))) / CGFloat(255)
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
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
