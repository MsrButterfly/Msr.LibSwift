import UIKit

extension Msr.UI {
    class Rectangle: Shape {
        init(color: UIColor, size: CGSize) {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
            let context = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillRect(context, CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            super.init(image: image)
            self.color = color
        }
    }
    class RoundedRectangle: Shape {
        init(color: UIColor, size: CGSize, cornerRadius: (topLeft: CGFloat, topRight: CGFloat, bottomRight: CGFloat, bottomLeft: CGFloat)) {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
            let w = size.width
            let h = size.height
            let tl = cornerRadius.topLeft
            let tr = cornerRadius.topRight
            let br = cornerRadius.bottomRight
            let bl = cornerRadius.bottomLeft
            let context = UIGraphicsGetCurrentContext()
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, bl, 0)
            CGContextAddLineToPoint(context, w - br, 0)
            CGContextAddArcToPoint(context, w, 0, w, br, br)
            CGContextAddLineToPoint(context, w, h - tr)
            CGContextAddArcToPoint(context, w, h, w - tr, h, tr)
            CGContextAddLineToPoint(context, tl, h)
            CGContextAddArcToPoint(context, 0, h, 0, h - tl, tl)
            CGContextAddLineToPoint(context, 0, bl)
            CGContextAddArcToPoint(context, 0, 0, bl, 0, bl)
            CGContextClosePath(context)
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillPath(context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            super.init(image: image)
            self.color = color
        }
    }
}
