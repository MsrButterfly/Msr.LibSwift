import UIKit

extension Msr.UI._Detail {
    class SegmentWrapper: UIView {
        typealias Segment = Msr.UI.Segment
        var segment: Segment? {
            willSet {
                if newValue != nil {
                    insertSubview(newValue!, belowSubview: button)
                    newValue!.frame = bounds
                    newValue!.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                    newValue!.msr_addAutoExpandingConstraintsToSuperview()
                }
            }
            didSet {
                oldValue?.removeFromSuperview()
            }
        }
        var widthConstraint: NSLayoutConstraint!
        var button: UIButton!
        override init() {
            super.init()
            // msr_initialize() will be invoked by super.init() -> self.init(frame:).
        }
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            msr_initialize()
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            msr_initialize()
        }
        func msr_initialize() {
            button = UIButton(frame: bounds)
            button.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            button.setBackgroundImage(UIImage.msr_rectangleWithColor(UIColor.blackColor().colorWithAlphaComponent(0.2), size: CGSize(width: 1, height: 1)), forState: .Highlighted)
            addSubview(button)
            msr_shouldTranslateAutoresizingMaskIntoConstraints = false
            widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: minimumLayoutSize.width)
            addConstraint(widthConstraint)
        }
        var minimumLayoutSize: CGSize {
            return segment?.minimumLayoutSize ?? CGSizeZero
        }
    }
}

