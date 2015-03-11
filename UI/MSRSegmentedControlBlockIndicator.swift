@objc class MSRSegmentedControlBlockIndicator: MSRSegmentedControlIndicator {
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
