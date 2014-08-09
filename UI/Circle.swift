import UIKit

extension Msr.UI {
    class Circle: Shape {
        init(color: UIColor, radius: CGFloat) {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: radius * 2, height: radius * 2), false, UIScreen.mainScreen().scale)
            let context = UIGraphicsGetCurrentContext()
            CGContextBeginPath(context)
            CGContextAddArc(context, radius, radius, radius, 0, 360, 0)
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextClosePath(context)
            CGContextFillPath(context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            super.init(image: image)
            self.color = color
        }
    }
}