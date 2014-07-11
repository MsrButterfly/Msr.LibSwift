import UIKit

extension Msr.UI {
    class Sidebar: UIView {
        class Handle: UIView {
            weak var sidebar: Sidebar!
            init(sidebar: Sidebar, width: CGFloat) {
                self.sidebar = sidebar
                super.init(frame: CGRect(x: sidebar.bounds.width - width, y: 0, width: width, height: UIScreen.mainScreen().bounds.height))
                backgroundColor = UIColor.clearColor()
                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
                panGestureRecognizer.maximumNumberOfTouches = 1
                addGestureRecognizer(panGestureRecognizer)
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
            var sidebarInitFrame: CGRect!
            func pan(gestureRecognizer: UIPanGestureRecognizer?) {
                if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
                    let translation = recognizer.translationInView(self)
                    let location = recognizer.locationInView(sidebar.window)
                    let velocity = recognizer.velocityInView(self)
                    var frame = sidebar!.frame
                    switch recognizer.state {
                    case .Began:
                        sidebarInitFrame = sidebar.frame
                        break
                    case .Changed:
                        frame.origin.x = sidebarInitFrame.origin.x + translation.x
                        sidebar.frame = frame
                        break
                    case .Ended:
                        if velocity.x > 0 || location.x > sidebar.bounds.width - sidebar.offset {
                            sidebar.show(nil)
                        } else {
                            sidebar.hide(nil)
                        }
                        break
                    default:
                        break
                    }
                }
            }
            override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView! {
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
        let scrollView: UIScrollView
        let handle: Handle!
        let offset: CGFloat
        var showing: Bool {
        get {
            return frame.origin.x == -offset
        }
        }
        var hiding: Bool {
        get {
            return !showing
        }
        }
        init(width: CGFloat, blurEffect: UIBlurEffect) {
            scrollView = UIScrollView()
            let handleWidth = CGFloat(12)
            offset = UIScreen.mainScreen().bounds.width - width + handleWidth
            var frame = UIScreen.mainScreen().bounds
            frame.size.width += handleWidth
            frame.origin.x = -offset
            super.init(frame: frame)
            let backgroundView = UIVisualEffectView(effect: blurEffect)
            backgroundView.frame = bounds
            addSubview(backgroundView)
            handle = Handle(sidebar: self, width: handleWidth)
            let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
            vibrancyEffectView.frame = bounds
            backgroundView.contentView.addSubview(vibrancyEffectView)
            vibrancyEffectView.contentView.addSubview(handle)
            scrollView.frame = CGRect(x: offset, y: 0, width: width - handle.bounds.width, height: backgroundView.bounds.height)
            scrollView.alwaysBounceVertical = true
            backgroundView.contentView.addSubview(scrollView)
        }
        override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView! {
            if let view = handle.hitTest(point, withEvent: event) {
                return view
            }
            return super.hitTest(point, withEvent: event)
        }
        func show(completion: ((Bool) -> Void)!) {
            UIView.animateWithDuration(0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: {
                    [weak self] in
                    var frame = self!.frame
                    frame.origin.x = -self!.offset
                    self!.frame = frame
                }, completion: completion)
        }
        func hide(completion: ((Bool) -> Void)!) {
            UIView.animateWithDuration(0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: {
                    [weak self] in
                    var frame = self!.frame
                    frame.origin.x = -frame.width
                    self!.frame = frame
                }, completion: completion)
        }
        func toggleShow(completion: ((Bool) -> Void)!) {
            if showing {
                hide(completion)
            } else {
                show(completion)
            }
        }
    }
}
