import UIKit

extension Msr.UI {
    class Indicator: AutoExpandingView {
        weak var segmentedControl: UISegmentedControl?
        class var aboveSegments: Bool {
            return true
        }
        override func msr_initialize() {
            super.msr_initialize()
            opaque = false
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
            let c = UIGraphicsGetCurrentContext()
            CGContextSaveGState(c)
            CGContextSetStrokeColorWithColor(c, tintColor.CGColor)
            CGContextSetLineCap(c, kCGLineCapSquare)
            CGContextSetLineWidth(c, 2)
            CGContextMoveToPoint(c, 0, rect.msr_top + 1)
            CGContextAddLineToPoint(c, rect.msr_right, rect.msr_bottom)
            CGContextStrokePath(c)
            CGContextRestoreGState(c)
        }
    }
}

extension Msr.UI {
    class UnderlineIndicator: Indicator {
        override func drawRect(rect: CGRect) {
            let c = UIGraphicsGetCurrentContext()
            CGContextSaveGState(c)
            CGContextSetStrokeColorWithColor(c, tintColor.CGColor)
            CGContextSetLineCap(c, kCGLineCapSquare)
            CGContextSetLineWidth(c, 2)
            CGContextMoveToPoint(c, 0, rect.msr_bottom - 1)
            CGContextAddLineToPoint(c, rect.msr_right, rect.msr_bottom - 1)
            CGContextStrokePath(c)
            CGContextRestoreGState(c)
        }
    }
}

extension Msr.UI {
    class BlockIndicator: Indicator {
        override class var aboveSegments: Bool {
            return false
        }
        override func drawRect(rect: CGRect) {
            let c = UIGraphicsGetCurrentContext()
            CGContextSaveGState(c)
            CGContextSetFillColorWithColor(c, tintColor.colorWithAlphaComponent(0.2).CGColor)
            CGContextFillRect(c, rect)
            CGContextRestoreGState(c)
        }
    }
}
