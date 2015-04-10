import UIKit

class MSRCollectionView: UICollectionView {
    
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
