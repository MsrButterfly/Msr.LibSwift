import UIKit

extension UITableView {
    @objc var msr_wrapperView: UIScrollView? {
        let systemVersion = (UIDevice.currentDevice().systemVersion as NSString).floatValue
        if systemVersion < 8.0 {
            return nil
        }
        for view in subviews as! [UIView] {
            if NSStringFromClass(view.dynamicType).componentsSeparatedByString(".").last == "UITableViewWrapperView" {
                return view as? UIScrollView
            }
        }
        return nil
    }
}
