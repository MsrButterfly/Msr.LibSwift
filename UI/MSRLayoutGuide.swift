import UIKit

@objc class MSRLayoutGuide: UIView, UILayoutSupport {
    convenience init() {
        self.init(frame: CGRectZero)
        // msr_initialize() will be invoked by init(frame:)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        msr_initialize()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        msr_initialize()
    }
    func msr_initialize() {
        translatesAutoresizingMaskIntoConstraints = false
        hidden = true
    }
    var length: CGFloat {
        return 0
    }
}

@objc class MSRVerticalLayoutGuide: MSRLayoutGuide {
    override var length: CGFloat {
        return bounds.height
    }
    override var bounds: CGRect {
        willSet {
            if bounds.height != newValue.height {
                willChangeValueForKey("length")
            }
        }
        didSet {
            if bounds.height != oldValue.height {
                didChangeValueForKey("length")
            }
        }
    }
}

@objc class MSRHorizontalLayoutGuide: MSRLayoutGuide {
    override var length: CGFloat {
        return bounds.width
    }
    override var bounds: CGRect {
        willSet {
            if bounds.width != newValue.width {
                willChangeValueForKey("length")
            }
        }
        didSet {
            if bounds.width != oldValue.width {
                didChangeValueForKey("length")
            }
        }
    }
}
