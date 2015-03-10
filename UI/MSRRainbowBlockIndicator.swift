@objc class MSRRainbowBlockIndicator: MSRBlockIndicator {
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
