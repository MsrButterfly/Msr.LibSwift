import UIKit

extension Msr.UI {
    class Indicator: AutoExpandingView {
        weak var segmentedControl: SegmentedControl?
        class var aboveSegments: Bool {
            return true
        }
        override func msr_initialize() {
            super.msr_initialize()
            opaque = false
        }
    }
}

extension Msr.UI {
    class LinearIndicator: Indicator {
        var lineCap: CGLineCap { return kCGLineCapSquare }
        var lineColor: UIColor { return tintColor }
        var lineJoin: CGLineJoin { return kCGLineJoinMiter }
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
}

extension Msr.UI {
    class OverlineIndicator: LinearIndicator {
        override var linePath: CGPath {
            let p = CGPathCreateMutable()
            CGPathMoveToPoint(p, nil, 0, lineWidth / 2)
            CGPathAddLineToPoint(p, nil, bounds.width, lineWidth / 2)
            return p
        }
    }
}

extension Msr.UI {
    class UnderlineIndicator: LinearIndicator {
        override var linePath: CGPath {
            let p = CGPathCreateMutable()
            CGPathMoveToPoint(p, nil, 0, bounds.height - lineWidth / 2)
            CGPathAddLineToPoint(p, nil, bounds.width, bounds.height - lineWidth / 2)
            return p
        }
    }
}

extension Msr.UI {
    class BlockIndicator: Indicator {
        override class var aboveSegments: Bool {
            return false
        }
        var count: UIntMax = 0
        var blockColor: UIColor { return tintColor.colorWithAlphaComponent(0.2) }
        override func drawRect(rect: CGRect) {
            let c = UIGraphicsGetCurrentContext()
            CGContextSaveGState(c)
            CGContextSetFillColorWithColor(c, blockColor.CGColor)
            CGContextFillRect(c, rect)
            CGContextRestoreGState(c)
        }
    }
}

extension Msr.UI {
    class RainbowBlockIndicator: BlockIndicator {
        override var blockColor: UIColor {
            let indicatorPosition = segmentedControl?.indicatorPosition
            let numberOfSegments = segmentedControl?.numberOfSegments
            if indicatorPosition == nil || numberOfSegments == nil {
                return UIColor.clearColor()
            }
            let maxValue = CGFloat(numberOfSegments! - 1)
            let minValue = CGFloat(0)
            if minValue >= maxValue {
                return UIColor.clearColor()
            }
            let value = min(max(CGFloat(indicatorPosition!), minValue), maxValue)
            let hue = (value - minValue) / (maxValue - minValue)
            return UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
        }
    }
}
