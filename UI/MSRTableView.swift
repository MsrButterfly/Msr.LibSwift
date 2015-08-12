import UIKit

class MSRTableView: UITableView {
    
    override var contentSize: CGSize {
        didSet {
            if contentSize != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return contentSize
    }
    
}
