import UIKit

@objc class MSRSegmentedControlLinearIndicator: MSRSegmentedControlIndicator {
    var lineCap: CGLineCap { return .Square }
    var lineColor: UIColor { return tintColor }
    var lineJoin: CGLineJoin { return .Miter }
    var linePath: CGPath { return CGPathCreateMutable() }
    var lineWidth: CGFloat = 3
    override func drawRect(rect: CGRect) {
        let c = UIGraphicsGetCurrentContext()
        CGContextSaveGState(c)
        CGContextSetStrokeColorWithColor(c, lineColor.CGColor)
        CGContextSetLineCap(c, lineCap)
        CGContextSetLineWidth(c, lineWidth)
        CGContextAddPath(c, linePath)
        CGContextStrokePath(c)
        CGContextRestoreGState(c)
    }
}
