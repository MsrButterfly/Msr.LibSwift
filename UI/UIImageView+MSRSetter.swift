import UIKit

extension UIImageView {
    var msr_imageRenderingMode: UIImageRenderingMode? {
        set {
            image = image?.imageWithRenderingMode(newValue ?? .Automatic)
        }
        get {
            return image?.renderingMode
        }
    }
}
