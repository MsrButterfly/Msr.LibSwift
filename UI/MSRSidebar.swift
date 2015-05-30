/*

Functional Synopsis

import UIKit

@objc protocol MSRSidebarDelegate {
    optional func msr_sidebar(sidebar: MSRSidebar, didShowAtPercentage percentage: CGFloat)
    optional func msr_sidebarDidCollapse(sidebar: MSRSidebar)
    optional func msr_sidebarDidExpand(sidebar: MSRSidebar)
}

@objc class MSRSidebar: UIView, UIGestureRecognizerDelegate {

    init(width: CGFloat, edge: MSRFrameEdge)

    var backgroundView: UIView?     // default is UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    var collapsed: Bool             // default is true
    var contentView: UIView         // the view container
    var delegate: MSRSidebarDelegate?
    var edge: MSRFrameEdge { get }  // default is .Left, initialized by init(width:edge:)
    var enableBouncing: Bool        // default is true
    var overlay: UIView?            // default is nil, the view above contents and attachs to sidebar
    var overlayPanGestureRecognizer: UIPanGestureRecognizer { get }
    var overlayTapGestureRecognizer: UITapGestureRecognizer { get }
    var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer { get }
    var width: CGFloat              // default is 0, animatable

    func collapse()
    func collapse(#animated: Bool)
    func setCollapsed(collapsed: Bool, animated: Bool)
    func expand()
    func expand(#animated: Bool)

}

*/

import UIKit

@objc protocol MSRSidebarDelegate {
    optional func msr_sidebar(sidebar: MSRSidebar, didShowAtPercentage percentage: CGFloat)
    optional func msr_sidebarDidCollapse(sidebar: MSRSidebar)
    optional func msr_sidebarDidExpand(sidebar: MSRSidebar)
}

@objc class MSRSidebar: UIView, UIGestureRecognizerDelegate {
    // MARK: - Initializers
    init(width: CGFloat, edge: MSRFrameEdge) {
        self.edge = edge
        self.width = width
        super.init(frame: CGRectZero)
        msr_initialize()
    }
    required init(coder aDecoder: NSCoder) {
        edge = .Left
        width = 0
        super.init(coder: aDecoder)
        msr_initialize()
    }
    override init(frame: CGRect) {
        edge = .Left
        width = frame.width
        super.init(frame: frame)
        msr_initialize()
    }
    func msr_initialize() {
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        collapsed = true
        addSubview(contentView)
        contentView.msr_addVerticalEdgeAttachedConstraintsToSuperview()
        contentView.msr_addEdgeAttachedConstraintToSuperviewAtEdge(edge == .Left ? .Right : .Left)
        contentView.addConstraint(contentViewWidthConstraint)
    }
    // MARK: - Variables
    var backgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if backgroundView != nil {
                backgroundView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                backgroundView!.bounds = bounds
                backgroundView!.center = center
                insertSubview(backgroundView!, belowSubview: contentView)
            }
        }
    }
    var collapsed: Bool = true {
        didSet {
            updateUIWithValue(collapsed ? 0 : width)
            if collapsed {
                delegate?.msr_sidebarDidCollapse?(self)
            } else {
                delegate?.msr_sidebarDidExpand?(self)
            }
        }
    }
    lazy var contentView: UIView = {
        let v = UIView()
        v.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        return v
    }()
    var delegate: MSRSidebarDelegate?
    let edge: MSRFrameEdge
    var enableBouncing: Bool = true
    var overlay: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if overlay != nil {
                overlay!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                overlay!.bounds = overlayWrapper.bounds
                overlay!.center = overlayWrapper.center
                overlayWrapper.addSubview(overlay!)
            }
        }
    }
    private(set) lazy var overlayPanGestureRecognizer: UIPanGestureRecognizer = {
        [weak self] in
        let recognizer = UIPanGestureRecognizer(target: self!, action: "handleOverlayPanGesture:")
        return recognizer
    }()
    private(set) lazy var overlayTapGestureRecognizer: UITapGestureRecognizer = {
        [weak self] in
        let recognizer = UITapGestureRecognizer(target: self!, action: "handleOverlayTapGesture:")
        return recognizer
    }()
    private(set) lazy var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        [weak self] in
        let recognizer = UIScreenEdgePanGestureRecognizer(target: self!, action: "handleScreenEdgePanGesture:")
        recognizer.delegate = self
        recognizer.edges = self!.edge == .Left ? .Left : .Right
        return recognizer
    }()
    var width: CGFloat {
        didSet {
            widthConstraint?.constant = width
            contentViewWidthConstraint.constant = width
            layoutIfNeeded()
        }
    }
    // MARK: - Methods
    func collapse() {
        collapse(animated: true)
    }
    func collapse(#animated: Bool) {
        setCollapsed(true, animated: animated)
    }
    func setCollapsed(collapsed: Bool, animated: Bool) {
        let animations: () -> Void = {
            [weak self] in
            self?.collapsed = collapsed
            return
        }
        if animated {
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: collapsed || !enableBouncing ? 1 : 0.5,
                initialSpringVelocity: 0.7,
                options: .BeginFromCurrentState,
                animations: animations,
                completion: nil)
        } else {
            animations()
        }
    }
    func expand() {
        expand(animated: true)
    }
    func expand(#animated: Bool) {
        setCollapsed(false, animated: animated)
    }
    // MARK: - Override Methods
    override func willMoveToSuperview(newSuperview: UIView?) {
        if superview != nil {
            overlayWrapper.removeFromSuperview()
            overlayWrapper.msr_removeAllEdgeAttachedConstraintsFromSuperview()
            msr_removeVerticalEdgeAttachedConstraintsFromSuperview()
            edgeConstraint = nil
            widthConstraint = nil
            overlayWrapper.removeGestureRecognizer(overlayPanGestureRecognizer)
            overlayWrapper.removeGestureRecognizer(overlayTapGestureRecognizer)
            superview!.removeGestureRecognizer(screenEdgePanGestureRecognizer)
        }
    }
    override func didMoveToSuperview() {
        if superview != nil {
            superview!.insertSubview(overlayWrapper, belowSubview: self)
            overlayWrapper.msr_addVerticalEdgeAttachedConstraintsToSuperview()
            overlayWrapper.msr_addEdgeAttachedConstraintToSuperviewAtEdge(edge == .Left ? .Right : .Left)
            
            msr_addVerticalEdgeAttachedConstraintsToSuperview()
            edgeConstraint = NSLayoutConstraint(item: self, attribute: edge == .Left ? .Right : .Left, relatedBy: .Equal, toItem: superview, attribute: edge == .Left ? .Left : .Right, multiplier: 1, constant: 0)
            widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: superview, attribute: .Width, multiplier: 1, constant: width)
            superview!.addConstraint(edgeConstraint!)
            superview!.addConstraint(widthConstraint!)
            superview!.addConstraint(NSLayoutConstraint(item: self, attribute: edge == .Left ? .Right : .Left, relatedBy: .Equal, toItem: overlayWrapper, attribute: edge == .Left ? .Left : .Right, multiplier: 1, constant: 0))
            overlayWrapper.addGestureRecognizer(overlayPanGestureRecognizer)
            overlayWrapper.addGestureRecognizer(overlayTapGestureRecognizer)
            superview!.addGestureRecognizer(screenEdgePanGestureRecognizer)
        }
    }
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === screenEdgePanGestureRecognizer {
            return collapsed
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    // MARK: - Private Variables
    private lazy var contentViewWidthConstraint: NSLayoutConstraint = {
        [weak self] in
        return NSLayoutConstraint(item: self!.contentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self!.width)
        }()
    private var edgeConstraint: NSLayoutConstraint?
    private lazy var overlayWrapper: UIView = {
        let v = UIView()
        v.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        return v
    }()
    private var widthConstraint: NSLayoutConstraint?
    // MARK: - Private Methods
    internal func handleScreenEdgePanGesture(recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer === screenEdgePanGestureRecognizer {
            updateTranslationByHandlingPanGesture(recognizer)
        }
    }
    internal func handleOverlayPanGesture(recognizer: UIPanGestureRecognizer) {
        if recognizer === overlayPanGestureRecognizer {
            updateTranslationByHandlingPanGesture(recognizer)
        }
    }
    internal func handleOverlayTapGesture(recognizer: UITapGestureRecognizer) {
        if recognizer === overlayTapGestureRecognizer {
            collapse(animated: true)
        }
    }
    private func updateTranslationByHandlingPanGesture(recognizer: UIPanGestureRecognizer) {
        var location = recognizer.locationInView(superview!).x
        var velocity = recognizer.velocityInView(superview!).x
        if edge == .Right {
            location = superview!.bounds.width - location
            velocity = -velocity
        }
        switch recognizer.state {
        case .Began:
            UIView.animateWithDuration(0.1,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0.7,
                options: .BeginFromCurrentState,
                animations: {
                    [weak self] in
                    self?.updateUIWithValue(location)
                    return
                },
                completion: nil)
            break
        case .Changed:
            updateUIWithValue(location)
            break
        case .Cancelled, .Ended:
            setCollapsed(velocity < 0, animated: true)
            break
        default:
            break
        }
    }
    private func updateUIWithValue(value: CGFloat) {
        let translation = value <= width ? value : enableBouncing ? ((value + width) / 2) : width
        let percentage = translation / width
        edgeConstraint?.constant = edge == .Left ? translation : -translation
        overlayWrapper.alpha = max(0, min(1, percentage))
        overlayWrapper.layoutIfNeeded()
        layoutIfNeeded()
        delegate?.msr_sidebar?(self, didShowAtPercentage: percentage)
    }
    // MARK: Deinitializer
    deinit {
        screenEdgePanGestureRecognizer.delegate = nil
    }
}
