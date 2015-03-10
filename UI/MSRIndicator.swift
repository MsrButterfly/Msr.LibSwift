@objc class MSRIndicator: MSRAutoExpandingView {
    weak var segmentedControl: MSRSegmentedControl?
    class var aboveSegments: Bool {
        return true
    }
    override var tintColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    override func msr_initialize() {
        super.msr_initialize()
        opaque = false
    }
}
