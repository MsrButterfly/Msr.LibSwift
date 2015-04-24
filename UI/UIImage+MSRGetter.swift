import UIKit

extension UIImage {
    @objc var msr_roundedImage: UIImage {
        let rect = CGRect(origin: CGPointZero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        UIBezierPath(roundedRect: rect, cornerRadius: min(size.width, size.height) / 2).addClip()
        drawInRect(rect)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage
    }
}
