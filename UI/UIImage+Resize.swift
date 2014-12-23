extension UIImage {
    func msr_imageOfSize(size: CGSize) -> UIImage {
        let sourceSize = CGSize(width: CGFloat(CGImageGetWidth(CGImage)), height: CGFloat(CGImageGetHeight(CGImage)))
        var destinationSize = size
        if (sourceSize == destinationSize) {
            return self
        }
        let scaleRatio = destinationSize.width / sourceSize.width
        var transform = CGAffineTransformIdentity
        switch imageOrientation {
        case .Up:
            break
        case .UpMirrored:
            transform = CGAffineTransformMakeTranslation(sourceSize.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        case .Down:
            transform = CGAffineTransformMakeTranslation(sourceSize.width, sourceSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
        case .DownMirrored:
            transform = CGAffineTransformMakeTranslation(0, sourceSize.height);
            transform = CGAffineTransformScale(transform, 1, -1);
            break
        case .Left:
            destinationSize = CGSize(width: destinationSize.height, height: destinationSize.width)
            transform = CGAffineTransformMakeTranslation(0, sourceSize.width)
            transform = CGAffineTransformRotate(transform, CGFloat(3.0 * M_PI_2))
            break
        case .LeftMirrored:
            destinationSize = CGSize(width: destinationSize.height, height: destinationSize.width)
            transform = CGAffineTransformMakeTranslation(sourceSize.height, sourceSize.width)
            transform = CGAffineTransformScale(transform, -1, 1)
            transform = CGAffineTransformRotate(transform, CGFloat(3.0 * M_PI_2))
            break
        case .Right:
            destinationSize = CGSize(width: destinationSize.height, height: destinationSize.width)
            transform = CGAffineTransformMakeTranslation(sourceSize.height, 0);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2));
            break
        case .RightMirrored:
            destinationSize = CGSize(width: destinationSize.height, height: destinationSize.width)
            transform = CGAffineTransformMakeScale(-1, 1)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
        default:
            break
        }
        let context = Msr.UI.DefaultRGBBitmapContextWithSize(destinationSize)
        CGContextSetShouldAntialias(context, true)
        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        CGContextScaleCTM(context, scaleRatio, scaleRatio)
        CGContextConcatCTM(context, transform)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: sourceSize), CGImage)
        return UIImage(CGImage: CGBitmapContextCreateImage(context), scale: scale, orientation: imageOrientation)!
    }
}
