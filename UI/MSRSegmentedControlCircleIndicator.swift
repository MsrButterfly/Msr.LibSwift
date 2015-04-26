import UIKit

@objc class MSRSegmentedControlCircleIndicator: MSRSegmentedControlIndicator {
    override class var aboveSegments: Bool {
        return false
    }
    var circleColor: UIColor { return tintColor }
    override func drawRect(rect: CGRect) {
        let c = UIGraphicsGetCurrentContext()
        CGContextSaveGState(c)
        circleColor.setFill()
        UIBezierPath(roundedRect: CGRect(x: bounds.msr_center.x - bounds.height / 2, y: 0, width: bounds.height, height: bounds.height), cornerRadius: bounds.height / 2).fill()
        CGContextRestoreGState(c)
    }
}
