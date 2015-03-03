import UIKit

extension Msr.UI {
    class Indicator: AutoExpandingView {
        override func msr_initialize() {
            super.msr_initialize()
            opaque = false
            tintColor = UIColor.purpleColor()
        }
        override func tintColorDidChange() {
            super.tintColorDidChange()
            setNeedsDisplay()
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            setNeedsDisplay()
        }
    }
}

extension Msr.UI {
    class OverlineIndicator: Indicator {
        override func drawRect(rect: CGRect) {
            let context = UIGraphicsGetCurrentContext()
            CGContextSaveGState(context)
            CGContextSetStrokeColorWithColor(context, tintColor?.CGColor)
            CGContextSetLineCap(context, kCGLineCapSquare)
            CGContextSetLineWidth(context, 2)
            CGContextMoveToPoint(context, 0, rect.msr_top + 1)
            CGContextAddLineToPoint(context, rect.msr_right, rect.msr_bottom)
            CGContextStrokePath(context)
            CGContextRestoreGState(context)
        }
    }
}

extension Msr.UI {
    class UnderlineIndicator: Indicator {
        override func drawRect(rect: CGRect) {
            let context = UIGraphicsGetCurrentContext()
            CGContextSaveGState(context)
            CGContextSetStrokeColorWithColor(context, tintColor?.CGColor)
            CGContextSetLineCap(context, kCGLineCapSquare)
            CGContextSetLineWidth(context, 2)
            CGContextMoveToPoint(context, 0, rect.msr_bottom - 1)
            CGContextAddLineToPoint(context, rect.msr_right, rect.msr_bottom - 1)
            CGContextStrokePath(context)
            CGContextRestoreGState(context)
        }
    }
}
