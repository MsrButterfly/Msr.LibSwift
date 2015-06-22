import UIKit

extension UIImage {
    @objc func msr_imageOfSize(size: CGSize) -> UIImage {
        var sourceSize = self.size
        var destinationSize = size
        if (sourceSize == destinationSize) {
            return self
        }
        let scaleRatio = destinationSize.width / sourceSize.width
        var transform = CGAffineTransformIdentity
        switch imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            sourceSize = %~sourceSize
            destinationSize = %~destinationSize
            break
        default:
            break
        }
        let context = _MSRDefaultRGBBitmapContextWithSize(destinationSize)
        CGContextSetShouldAntialias(context, true)
        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        CGContextScaleCTM(context, scaleRatio, scaleRatio)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: sourceSize), CGImage)
        return UIImage(CGImage: CGBitmapContextCreateImage(context), scale: scale, orientation: imageOrientation)!
    }
}
