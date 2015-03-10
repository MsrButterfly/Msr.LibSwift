extension UINavigationBar {
    @objc var msr_backgroundView: UIImageView? {
        return subviews.filter({
            (v: AnyObject) in
            NSStringFromClass(v.dynamicType) == "_UINavigationBarBackground"
        }).first as? UIImageView
    }
}
