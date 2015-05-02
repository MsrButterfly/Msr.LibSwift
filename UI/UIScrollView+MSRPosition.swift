import UIKit

extension UIScrollView {
    var msr_reachedBottom: Bool {
        return contentOffset.y >= contentSize.height - bounds.height + contentInset.bottom
    }
    var msr_reachedTop: Bool {
        return contentOffset.y <= -contentInset.top
    }
}
