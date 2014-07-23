import UIKit

extension UIColor {
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