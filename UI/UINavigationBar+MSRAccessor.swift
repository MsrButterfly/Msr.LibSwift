import UIKit

extension UINavigationBar {
    @objc var msr_backgroundView: UIImageView? {
        return valueForKey("_backgroundView") as? UIImageView
    }
    @objc var msr_shadowImageView: UIImageView? {
        return msr_backgroundView?.valueForKey("_shadowView") as? UIImageView
    }
}
