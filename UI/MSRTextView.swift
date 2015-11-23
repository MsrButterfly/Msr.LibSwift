import UIKit

@IBDesignable class MSRTextView: UITextView {
    
    override var text: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var placeholder: String? {
        get {
            return attributedPlaceholder?.string
        }
        set {
            if let string = newValue {
                let s = NSMutableParagraphStyle()
                s.alignment = textAlignment
                attributedPlaceholder = NSAttributedString(
                    string: string,
                    attributes: [
                        NSFontAttributeName: font!,
                        NSForegroundColorAttributeName: UIColor(white: 0.7, alpha: 1),
                        NSParagraphStyleAttributeName: s
                    ])
            } else {
                attributedPlaceholder = nil
            }
        }
    }
    
    @IBInspectable @NSCopying var attributedPlaceholder: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        msr_initialize()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        msr_initialize()
    }
    
    func msr_initialize() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange", name: UITextViewTextDidChangeNotification, object: self)
    }
    
    func textDidChange() {
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if text ?? "" == "" {
            if let ap = attributedPlaceholder {
                var rect = CGRect(origin: CGPointZero, size: bounds.size)
                rect = UIEdgeInsetsInsetRect(rect, textContainerInset)
                rect = CGRectInset(rect, textContainer.lineFragmentPadding, 0)
                
                ap.drawInRect(rect)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
