@objc class MSRNavigationWrapperController: UINavigationController {
    let overlay = MSRAutoExpandingView()
    override func loadView() {
        super.loadView()
        view.insertSubview(overlay, aboveSubview: navigationBar)
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.masksToBounds = false
        overlay.backgroundColor = UIColor.blackColor()
        overlay.alpha = 0
        interactivePopGestureRecognizer.enabled = false
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.superview != nil {
            view.bounds = view.superview!.bounds
            view.center = view.superview!.center
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.shadowPath = UIBezierPath(rect: view.layer.bounds).CGPath
    }
}
