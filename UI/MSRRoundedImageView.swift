import UIKit

class MSRRoundedImageView: UIImageView {
    override var image: UIImage? {
        set {
            super.image = newValue?.msr_roundedImage
        }
        get {
            return super.image
        }
    }
}
