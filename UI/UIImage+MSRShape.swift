import UIKit

extension UIImage {
    class func msr_imageWithColor(color: UIColor) -> Self {
        return msr_rectangleWithColor(color, size: CGSize(width: 1, height: 1))
    }
    class func msr_circleWithColor(color: UIColor, radius: CGFloat) -> Self {
        let context = _MSRDefaultRGBBitmapContextWithSize(CGSize(width: radius * 2, height: radius * 2))
        CGContextBeginPath(context)
        CGContextAddArc(context, radius, radius, radius, 0, 360, 0)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextClosePath(context)
        CGContextFillPath(context)
        return self.init(CGImage: CGBitmapContextCreateImage(context)!)
    }
    class func msr_rectangleWithColor(color: UIColor, size: CGSize) -> Self {
        let context = _MSRDefaultRGBBitmapContextWithSize(size)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRect(x: 0, y: 0, width: size.width, height: size.height))
        return self.init(CGImage: CGBitmapContextCreateImage(context)!)
    }
    class func msr_roundedRectangleWithColor(color: UIColor, size: CGSize, cornerRadius: (topLeft: CGFloat, topRight: CGFloat, bottomRight: CGFloat, bottomLeft: CGFloat)) -> Self {
        let context = _MSRDefaultRGBBitmapContextWithSize(size)
        let w = size.width
        let h = size.height
        let tl = cornerRadius.topLeft
        let tr = cornerRadius.topRight
        let br = cornerRadius.bottomRight
        let bl = cornerRadius.bottomLeft
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
        return self.init(CGImage: CGBitmapContextCreateImage(context)!)
    }
}
