@objc class MSRSidebar: UIView {
    let contentView: UIView
    let backgroundEffect: UIBlurEffect
    private var handle: _MSRSidebarHandle!
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
        handle = _MSRSidebarHandle(sidebar: self, width: handleWidth)
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: backgroundView.effect as! UIBlurEffect))
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
    func show(#animated: Bool) {
        show(animated: animated, completion: nil)
    }
    func show(#animated: Bool, completion: ((Bool) -> Void)?) {
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
    func hide(#animated: Bool) {
        hide(animated: animated, completion: nil)
    }
    func hide(#animated: Bool, completion: ((Bool) -> Void)?) {
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
    internal func pan(gestureRecognizer: UIGestureRecognizer?) {
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
    internal func tap(gestureRecognizer: UIGestureRecognizer?) {
        if let recognizer = gestureRecognizer as? UITapGestureRecognizer {
            hide(animated: true, completion: nil)
        }
    }
    internal func offsetForTouchPoint(point: CGPoint) -> CGFloat {
        if point.x < width {
            return point.x - (UIScreen.mainScreen().bounds.width + handle.bounds.width)
        }
        return 0.5 * (point.x + width) - (UIScreen.mainScreen().bounds.width + handle.bounds.width)
    }
    internal func alphaForTouchPoint(point: CGPoint) -> CGFloat {
        if point.x < width {
            return point.x / width * overlayMaxAlpha
        }
        return overlayMaxAlpha
    }
}

extension MSRSidebar {
    func toggleShow(#animated: Bool) {
        toggleShow(animated: animated, completion: nil)
    }
    func toggleShow(#animated: Bool, completion: ((Bool) -> Void)?) {
        if hidden {
            show(animated: animated, completion: completion)
        } else {
            hide(animated: animated, completion: completion)
        }
    }
}
