import UIKit

extension Msr.UI {
    class Rectangle: Shape {
        init(color: UIColor, size: CGSize) {
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            CGContextBeginTransparencyLayer(context, nil)
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillRect(context, CGRect(x: 0, y: 0, width: size.width, height: size.height))
            CGContextEndTransparencyLayer(context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            super.init(image: image)
            self.color = color
        }
    }
    class RoundedRectangle: Shape {
        init(color: UIColor, size: CGSize, cornerRadius: (topLeft: CGFloat, topRight: CGFloat, bottomRight: CGFloat, bottomLeft: CGFloat)) {
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            CGContextBeginTransparencyLayer(context, nil)
            CGContextSetFillColorWithColor(context, color.CGColor);
            let w = size.width
            let h = size.height
            let tl = cornerRadius.topLeft
            let tr = cornerRadius.topRight
            let br = cornerRadius.bottomRight
            let bl = cornerRadius.bottomLeft
            CGContextMoveToPoint(context, tl, 0);
            CGContextAddLineToPoint(context, w - tr, 0);
            CGContextAddArcToPoint(context, w, 0, w, tr, tr);
            CGContextAddLineToPoint(context, w, h - br);
            CGContextAddArcToPoint(context, w, h, w - br, h, br);
            CGContextAddLineToPoint(context, bl, h);
            CGContextAddArcToPoint(context, 0, h, 0, h - bl, bl);
            CGContextAddLineToPoint(context, 0, tl);
            CGContextAddArcToPoint(context, 0, 0, tl, 0, tl);
            CGContextFillPath(context);
            CGContextEndTransparencyLayer(context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            super.init(image: image)
            self.color = color
        }
    }
}
