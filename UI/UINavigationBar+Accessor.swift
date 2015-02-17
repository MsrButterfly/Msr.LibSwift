import UIKit

extension UINavigationBar {
    var msr_backgroundView: UIImageView? {
        return subviews.filter({ NSStringFromClass($0.dynamicType) == "_UINavigationBarBackground" }).first as? UIImageView
    }
}