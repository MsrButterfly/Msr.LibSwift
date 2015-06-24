import UIKit

@objc class MSRSegmentedControlCircleIndicator: MSRSegmentedControlIndicator {
    override class var aboveSegments: Bool {
        return false
    }
    var fillColor: UIColor = .blackColor()
    var borderColor: UIColor = .clearColor()
    var borderWidth: CGFloat = 1
    override func drawRect(rect: CGRect) {
        let c = UIGraphicsGetCurrentContext()
        CGContextSaveGState(c)
        fillColor.setFill()
        UIBezierPath(roundedRect: CGRect(x: bounds.midX - bounds.height / 2, y: 0, width: bounds.height, height: bounds.height), cornerRadius: bounds.height / 2).fill()
        borderColor.setStroke()
        let path = UIBezierPath(roundedRect: CGRect(x: bounds.midX - (bounds.height - borderWidth) / 2, y: borderWidth / 2, width: bounds.height - borderWidth, height: bounds.height - borderWidth), cornerRadius: (bounds.height - borderWidth) / 2)
        path.lineWidth = borderWidth
        path.stroke()
        CGContextRestoreGState(c)
    }
}
