import UIKit

@objc class MSRSegmentedControlOverlineIndicator: MSRSegmentedControlLinearIndicator {
    override var linePath: CGPath {
        let p = CGPathCreateMutable()
        CGPathMoveToPoint(p, nil, 0, lineWidth / 2)
        CGPathAddLineToPoint(p, nil, bounds.width, lineWidth / 2)
        return p
    }
}
