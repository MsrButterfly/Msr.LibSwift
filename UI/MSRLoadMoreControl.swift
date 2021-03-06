import UIKit

@objc class MSRLoadMoreControl: UIControl {
    private(set) var loadingMore: Bool = false
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        backgroundColor = UIColor.clearColor()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func beginLoadingMore() {
        if !loadingMore {
            loadingMore = true
            scrollView!.contentInset.bottom += self.triggerHeight
        }
    }
    func endLoadingMore() {
        loadingMore = false
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object === scrollView {
            if keyPath == "contentOffset" {
//                let offset = (change![NSKeyValueChangeNewKey] as! NSValue).CGPointValue
                transform = CGAffineTransformMakeTranslation(0, scrollView!.contentSize.height + overHeight - frame.height)
                if !loadingMore {
                    alpha = min(max(overHeight, 0), frame.height) / frame.height
                    if overHeight > 0 {
                        setNeedsDisplay()
                        if overHeight > triggerHeight && !loadingMore && !scrollView!.dragging {
                            loadingMore = true
                            beginLoadingMore()
                            sendActionsForControlEvents(.ValueChanged)
                        }
                    }
                } else {
                    alpha = 1
                }
            } else if keyPath == "frame" {
                let frame = (change![NSKeyValueChangeNewKey] as! NSValue).CGRectValue()
                self.frame.size.width = frame.width
            }
        }
    }
    override func drawRect(rect: CGRect) {
        let space = CGFloat(14)
        let lineWidth = CGFloat(2)
        let lineHeight = CGFloat(5.5)
        let context = UIGraphicsGetCurrentContext()
        let color = tintColor
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, lineWidth)
        CGContextTranslateCTM(context, frame.width / 2, frame.height / 2)
        if !loadingMore {
            let percentage = min(max(overHeight, 0), triggerHeight) / triggerHeight
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            let numberOfLines = Int(percentage * 11) + 1
            if numberOfLines > 0 {
                for _ in 1...numberOfLines {
                    CGContextMoveToPoint(context, 0, space / 2)
                    CGContextAddLineToPoint(context, 0, space / 2 + lineHeight)
                    CGContextStrokePath(context)
                    CGContextRotateCTM(context, CGFloat(M_PI) * 2 / 12)
                }
            }
        } else {
//                CGContextRotateCTM(context, CGFloat(M_PI) * 2 / 12 * CGFloat(arc4random_uniform(12)))
            for i in 0..<12 {
                CGContextSetStrokeColorWithColor(context, color.colorWithAlphaComponent(CGFloat(1) / CGFloat(i)).CGColor)
                CGContextMoveToPoint(context, 0, space / 2)
                CGContextAddLineToPoint(context, 0, space / 2 + lineHeight)
                CGContextStrokePath(context)
                CGContextRotateCTM(context, CGFloat(M_PI) * 2 / 12)
            }
        }
    }
    override func willMoveToSuperview(newSuperview: UIView?) {
        if let scrollView = superview as? UIScrollView {
            if scrollView !== newSuperview {
                scrollView.removeObserver(self, forKeyPath: "contentOffset")
                scrollView.removeObserver(self, forKeyPath: "frame")
            }
        }
    }
    private weak var _scrollView: UIScrollView? = nil
    private weak var scrollView: UIScrollView? {
        get {
            return _scrollView
        }
        set {
            _scrollView?.removeObserver(self, forKeyPath: "contentOffset")
            _scrollView?.removeObserver(self, forKeyPath: "frame")
            _scrollView = newValue
            _scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
            _scrollView?.addObserver(self, forKeyPath: "frame", options: .New, context: nil)
        }
    }
    private let triggerHeight = CGFloat(100)
    private var overHeight: CGFloat {
        if scrollView!.contentSize.height < scrollView!.bounds.height {
            return scrollView!.contentOffset.y + scrollView!.contentInset.top
        } else {
            return scrollView!.contentOffset.y + scrollView!.bounds.height - scrollView!.contentInset.bottom - scrollView!.contentSize.height
        }
    }
}

var _UITableViewControllerMSRLoadMoreControlAssociationKey: UnsafePointer<Void> {
    struct _Static {
        static var key = CChar()
    }
    return UnsafePointer<Void>(msr_memory: &_Static.key)
}

extension UITableViewController {
    @objc var msr_loadMoreControl: MSRLoadMoreControl? {
        set {
            self.msr_loadMoreControl?.removeFromSuperview()
            self.msr_loadMoreControl?.scrollView = nil
            objc_setAssociatedObject(self, _UITableViewControllerMSRLoadMoreControlAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            if newValue != nil {
                tableView.insertSubview(newValue!, belowSubview: tableView.subviews[0])
                newValue!.scrollView = tableView
            }
        }
        get {
            return objc_getAssociatedObject(self, _UITableViewControllerMSRLoadMoreControlAssociationKey) as? MSRLoadMoreControl
        }
    }
}
