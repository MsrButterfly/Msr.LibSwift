@objc class MSRLayoutGuide: UIView, UILayoutSupport {
    override init() {
        super.init()
        // msr_initialize() will be invoked by init(frame:)
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
        msr_shouldTranslateAutoresizingMaskIntoConstraints = false
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
}

@objc class MSRHorizontalLayoutGuide: MSRLayoutGuide {
    override var length: CGFloat {
        return bounds.width
    }
}
