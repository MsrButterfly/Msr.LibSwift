import UIKit

extension UIImage {
    func msr_imageByClippingToRect(rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        drawAtPoint(CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
