import UIKit

extension Msr.UI {
    class Sidebar: UIView {
        class _Handle: UIView {
            weak var sidebar: Sidebar!
            var panGestureRecognizer: UIPanGestureRecognizer!
            convenience init(sidebar: Sidebar, width: CGFloat) {
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
        let contentView: UIView
        let backgroundEffect: UIBlurEffect
        let handle: _Handle!
        let offset: CGFloat
        let width: CGFloat
        let overlay: UIView
        let overlayMaxAlpha = CGFloat(0.5)
        var overlayPanGestureRecognizer: UIPanGestureRecognizer!
        var overlayTapGestureRecognizer: UITapGestureRecognizer!
        override var hidden: Bool {
            get {
                return frame.origin.x != -offset
            }
            set(value) {
                if value {
                    hide(animated: false, completion: nil)
                } else {
                    show(animated: false, completion: nil)
                }
            }
        }
        init(width: CGFloat, blurEffectStyle: UIBlurEffectStyle) {
            contentView = UIView()
            overlay = UIView()
            backgroundEffect = UIBlurEffect(style: blurEffectStyle)
            self.width = width
            let handleWidth = CGFloat(12)
            offset = UIScreen.mainScreen().bounds.width - width + handleWidth
            var frame = UIScreen.mainScreen().bounds
            frame.size.width *= 2
            frame.size.width += handleWidth
            frame.origin.x = -(offset + width)
            super.init(frame: frame)
            let backgroundView = UIVisualEffectView(effect: backgroundEffect)
            frame = UIScreen.mainScreen().bounds
            frame.size.width += handleWidth
            backgroundView.frame = frame
            addSubview(backgroundView)
            handle = _Handle(sidebar: self, width: handleWidth)
            let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: backgroundView.effect as UIBlurEffect))
            vibrancyEffectView.frame = bounds
            backgroundView.contentView.addSubview(vibrancyEffectView)
            vibrancyEffectView.contentView.addSubview(handle)
            contentView.frame = CGRect(x: offset, y: 0, width: width - handle.bounds.width, height: backgroundView.bounds.height)
            backgroundView.contentView.addSubview(contentView)
            frame = bounds
            frame.origin.x = backgroundView.bounds.width
            frame.size.width = UIScreen.mainScreen().bounds.width
            if blurEffectStyle == .Dark {
                overlay.backgroundColor = UIColor.clearColor()
            } else {
                overlay.backgroundColor = UIColor.blackColor()
            }
            overlay.frame = frame
            overlay.alpha = 0
            addSubview(overlay)
            overlayPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
            overlay.addGestureRecognizer(overlayPanGestureRecognizer)
            overlayTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
            overlay.addGestureRecognizer(overlayTapGestureRecognizer)
        }
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView? {
            if let view = handle.hitTest(point, withEvent: event) {
                return view
            }
            return super.hitTest(point, withEvent: event)
        }
        func show(#animated: Bool, completion: ((Bool) -> Void)!) {
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
        func hide(#animated: Bool, completion: ((Bool) -> Void)!) {
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
        func pan(gestureRecognizer: UIGestureRecognizer?) {
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
        func tap(gestureRecognizer: UIGestureRecognizer?) {
            if let recognizer = gestureRecognizer as? UITapGestureRecognizer {
                hide(animated: true, completion: nil)
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
    func toggleShow(#animated: Bool, completion: ((Bool) -> Void)!) {
        if hidden {
            show(animated: animated, completion: completion)
        } else {
            hide(animated: animated, completion: completion)
        }
    }
}
