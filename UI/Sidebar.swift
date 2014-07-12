import UIKit

extension Msr.UI {
    class Sidebar: UIView {
        class Handle: UIView {
            weak var sidebar: Sidebar!
            init(sidebar: Sidebar, width: CGFloat) {
                self.sidebar = sidebar
                super.init(frame: CGRect(x: UIScreen.mainScreen().bounds.width, y: 0, width: width, height: UIScreen.mainScreen().bounds.height))
                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
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
            func pan(gestureRecognizer: UIPanGestureRecognizer?) {
                if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
                    let translation = recognizer.translationInView(self)
                    let location = recognizer.locationInView(sidebar.window)
                    let velocity = recognizer.velocityInView(self)
                    var frame = sidebar!.frame
                    switch recognizer.state {
                    case .Began:
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
                        if velocity.x > 0 || location.x > sidebar.width {
                            sidebar.show(completion: nil, animated: true)
                        } else {
                            sidebar.hide(completion: nil, animated: true)
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
        let width: CGFloat
        let overlay: UIView
        let overlayMaxAlpha = CGFloat(0.5)
        override var hidden: Bool {
            get {
                return frame.origin.x != -offset
            }
            set(value) {
                if value {
                    hide(completion: nil, animated: false)
                } else {
                    show(completion: nil, animated: false)
                }
            }
        }
        init(width: CGFloat, blurEffectStyle: UIBlurEffectStyle) {
            scrollView = UIScrollView()
            overlay = UIView()
            self.width = width
            let handleWidth = CGFloat(12)
            offset = UIScreen.mainScreen().bounds.width - width + handleWidth
            var frame = UIScreen.mainScreen().bounds
            frame.size.width *= 2
            frame.size.width += handleWidth
            frame.origin.x = -offset
            super.init(frame: frame)
            let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: blurEffectStyle))
            frame = UIScreen.mainScreen().bounds
            frame.size.width += handleWidth
            backgroundView.frame = frame
            addSubview(backgroundView)
            handle = Handle(sidebar: self, width: handleWidth)
            let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: backgroundView.effect as UIBlurEffect))
            vibrancyEffectView.frame = bounds
            backgroundView.contentView.addSubview(vibrancyEffectView)
            vibrancyEffectView.contentView.addSubview(handle)
            scrollView.frame = CGRect(x: offset, y: 0, width: width - handle.bounds.width, height: backgroundView.bounds.height)
            scrollView.alwaysBounceVertical = true
            backgroundView.contentView.addSubview(scrollView)
            frame = bounds
            frame.origin.x = backgroundView.bounds.width
            frame.size.width = UIScreen.mainScreen().bounds.width
            if blurEffectStyle == .Dark {
                overlay.backgroundColor = UIColor.clearColor()
            } else {
                overlay.backgroundColor = UIColor.blackColor()
            }
            overlay.frame = frame
            overlay.alpha = overlayMaxAlpha
            addSubview(overlay)
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
            overlay.addGestureRecognizer(panGestureRecognizer)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
            overlay.addGestureRecognizer(tapGestureRecognizer)
        }
        override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView! {
            if let view = handle.hitTest(point, withEvent: event) {
                return view
            }
            return super.hitTest(point, withEvent: event)
        }
        func show(#completion: ((Bool) -> Void)!, animated: Bool) {
            let animations: () -> Void = {
                [weak self] in
                var frame = self!.frame
                frame.origin.x = -self!.offset
                self!.frame = frame
                self!.overlay.alpha = self!.overlayMaxAlpha
            }
            if animated {
                UIView.animateWithDuration(0.3,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: UIViewAnimationOptions.BeginFromCurrentState,
                    animations: animations,
                    completion: completion)
            } else {
                animations()
            }
        }
        func hide(#completion: ((Bool) -> Void)!, animated: Bool) {
            let animations: () -> Void = {
                [weak self] in
                var frame = self!.frame
                frame.origin.x = -(UIScreen.mainScreen().bounds.width + self!.handle.bounds.width)
                self!.frame = frame
                self!.overlay.alpha = 0
            }
            if animated {
                UIView.animateWithDuration(0.3,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: UIViewAnimationOptions.BeginFromCurrentState,
                    animations: animations,
                    completion: completion)
            } else {
                animations()
            }
        }
        func pan(gestureRecognizer: UIPanGestureRecognizer?) {
            if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
                let offset = recognizer.locationInView(handle).x
                switch recognizer.state {
                case .Began:
                    handle.pan(recognizer)
                    break
                case .Changed:
                    handle.pan(recognizer)
                    break
                case .Ended:
                    handle.pan(recognizer)
                default:
                    break
                }
            }
        }
        func tap(gestureRecognizer: UITapGestureRecognizer?) {
            if let recognizer = gestureRecognizer as? UITapGestureRecognizer {
                hide(completion: nil, animated: true)
            }
        }
        func offsetForTouchPoint(point: CGPoint) -> CGFloat {
            if point.x < width {
                return point.x - (UIScreen.mainScreen().bounds.width + handle.bounds.width)
            }
            return 0.5 * (point.x + width) - (UIScreen.mainScreen().bounds.width + handle.bounds.width)
        }
        func alphaForTouchPoint(point: CGPoint) -> CGFloat {
            if point.x < width {
                return point.x / width * overlayMaxAlpha
            }
            return overlayMaxAlpha
        }
    }
}

extension Msr.UI.Sidebar {
    func toggleShow(#completion: ((Bool) -> Void)!, animated: Bool) {
        if hidden {
            show(completion: completion, animated: animated)
        } else {
            hide(completion: completion, animated: animated)
        }
    }
}
