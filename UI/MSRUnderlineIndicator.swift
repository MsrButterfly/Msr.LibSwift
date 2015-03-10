@objc class MSRUnderlineIndicator: MSRLinearIndicator {
    override var linePath: CGPath {
        let p = CGPathCreateMutable()
        CGPathMoveToPoint(p, nil, 0, bounds.height - lineWidth / 2)
        CGPathAddLineToPoint(p, nil, bounds.width, bounds.height - lineWidth / 2)
        return p
    }
}
