import UIKit

extension UITableViewCell {
    var msr_scrollView: UIScrollView? {
        let systemVersion = (UIDevice.currentDevice().systemVersion as NSString).floatValue
        if systemVersion < 7.0 && systemVersion >= 8.0 {
            return nil
        }
        for view in subviews {
            if NSStringFromClass(view.dynamicType).componentsSeparatedByString(".").last == "UITableViewCellScrollView" {
                return view as? UIScrollView
            }
        }
        return nil
    }
}
