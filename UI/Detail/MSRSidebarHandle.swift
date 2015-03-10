@objc class _MSRSidebarHandle: UIView {
    weak var sidebar: MSRSidebar!
    var panGestureRecognizer: UIPanGestureRecognizer!
    convenience init(sidebar: MSRSidebar, width: CGFloat) {
        self.init(frame: CGRect(x: UIScreen.mainScreen().bounds.width, y: 0, width: width, height: UIScreen.mainScreen().bounds.height))
        self.sidebar = sidebar
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
        panGestureRecognizer.maximumNumberOfTouches = 1
        addGestureRecognizer(panGestureRecognizer)
        backgroundColor = UIColor.clearColor()
    }
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let x = rect.origin.x
        let y = rect.origin.y
        let width = rect.size.width
        let height = rect.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        CGContextSaveGState(context)
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextSetLineCap(context, kCGLineCapSquare)
        CGContextSetLineWidth(context, 0.5)
        CGContextMoveToPoint(context, x, y + statusBarHeight)
        CGContextAddLineToPoint(context, x, y + height - statusBarHeight)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
    }
    func pan(gestureRecognizer: UIGestureRecognizer?) {
        if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = recognizer.translationInView(self)
            let location = recognizer.locationInView(sidebar.window)
            let velocity = recognizer.velocityInView(self)
            var frame = sidebar!.frame
            switch recognizer.state {
            case .Began:
                if recognizer == panGestureRecognizer {
                    sidebar.overlayPanGestureRecognizer.enabled = false
                    sidebar.overlayTapGestureRecognizer.enabled = false
                } else {
                    panGestureRecognizer.enabled = false
                }
                UIView.animateWithDuration(0.1,
                    delay: 0,
                    options: UIViewAnimationOptions.BeginFromCurrentState,
                    animations: {
                        [weak self] in
                        var frame = self!.sidebar.frame
                        frame.origin.x = self!.sidebar.offsetForTouchPoint(location)
                        self!.sidebar.frame = frame
                        self!.sidebar.overlay.alpha = self!.sidebar.alphaForTouchPoint(location)
                    }, completion: nil)
                break
            case .Changed:
                frame.origin.x = sidebar.offsetForTouchPoint(location)
                sidebar.frame = frame
                sidebar.overlay.alpha = sidebar.alphaForTouchPoint(location)
                break
            case .Ended:
                sidebar.overlayPanGestureRecognizer.enabled = true
                sidebar.overlayTapGestureRecognizer.enabled = true
                panGestureRecognizer.enabled = true
                if velocity.x > 0 || location.x > sidebar.width {
                    sidebar.show(animated: true, completion: nil)
                } else {
                    sidebar.hide(animated: true, completion: nil)
                }
                break
            default:
                break
            }
        }
    }
    override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView? {
        if pointInside(point, withEvent: event) {
            return self
        }
        return nil
    }
    override func pointInside(point: CGPoint, withEvent event: UIEvent!) -> Bool {
        var bounds = self.frame
        bounds = CGRectInset(bounds, -10, 0)
        return CGRectContainsPoint(bounds, point)
    }
}
