import UIKit
import ObjectiveC
import QuartzCore

extension Msr.UI {
    class LoadMoreControl: UIControl {
        private(set) var loadingMore: Bool = false
        override init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
            backgroundColor = UIColor.clearColor()
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        required init(coder aDecoder: NSCoder!) {
            super.init(coder: aDecoder)
        }
//        var tintColor: UIColor!
//        var attributedTitle: NSAttributedString!
        func beginLoadingMore() {
            loadingMore = true
            sendActionsForControlEvents(.ValueChanged)
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                self.scrollView!.contentSize.height += 80
            }, completion: nil)
        }
        func endLoadingMore() {
            loadingMore = false
            
            
        }
        internal override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
            if object === scrollView {
                if keyPath == "contentOffset" {
                    let offset = (change["new"] as NSValue).CGPointValue()
                    transform = CGAffineTransformMakeTranslation(0, scrollView!.contentSize.height + overHeight - frame.height)
                    if !loadingMore {
                        alpha = min(max(overHeight, 0), frame.height) / frame.height
                        if overHeight > 0 {
                            setNeedsDisplay()
                            if overHeight > triggerHeight && !loadingMore {
                                beginLoadingMore()
                            }
                        }
                    } else {
                        alpha = 1
                    }
                } else if keyPath == "frame" {
                    let frame = (change["new"] as NSValue).CGRectValue()
                    self.frame.size.width = frame.width
                }
            }
        }
        override func drawRect(rect: CGRect) {
            let space = CGFloat(14)
            let lineWidth = CGFloat(2)
            let lineHeight = CGFloat(5.5)
            let context = UIGraphicsGetCurrentContext()
            let color = UIColor.darkGrayColor()
            CGContextSetLineCap(context, kCGLineCapRound)
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
                CGContextRotateCTM(context, CGFloat(M_PI) * 2 / 12 * CGFloat(arc4random_uniform(12)))
                for i in 0..<12 {
                    CGContextSetStrokeColorWithColor(context, color.colorWithAlphaComponent(CGFloat(1) / CGFloat(i)).CGColor)
                    CGContextMoveToPoint(context, 0, space / 2)
                    CGContextAddLineToPoint(context, 0, space / 2 + lineHeight)
                    CGContextStrokePath(context)
                    CGContextRotateCTM(context, CGFloat(M_PI) * 2 / 12)
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
                newValue?.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
                newValue?.addObserver(self, forKeyPath: "frame", options: .New, context: nil)
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
}

var LoadMoreControlKey = CChar()

extension UITableViewController {
    var loadMoreControl: Msr.UI.LoadMoreControl! {
        set {
            if (loadMoreControl != nil) {
                objc_setAssociatedObject(self, &LoadMoreControlKey, nil, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            }
            objc_setAssociatedObject(self, &LoadMoreControlKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            tableView.insertSubview(loadMoreControl, belowSubview: tableView.subviews[0] as UIView)
            newValue.scrollView = tableView
        }
        get {
            return objc_getAssociatedObject(self, &LoadMoreControlKey) as? Msr.UI.LoadMoreControl
        }
    }
}
