import UIKit

extension UIImage {
    func imageOfSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextBeginTransparencyLayer(context, nil)
        drawInRect(CGRect(origin: CGPointZero, size: size))
        CGContextEndTransparencyLayer(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}