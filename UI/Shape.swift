import UIKit

extension Msr.UI {
    class Shape {
        private var _color: UIColor!
        var color: UIColor! {
            get {
                return _color
            }
            set {
                _color = newValue
                UIGraphicsBeginImageContext(image.size)
                let context = UIGraphicsGetCurrentContext()
                CGContextBeginTransparencyLayer(context, nil)
                CGContextSetFillColorWithColor(context, color.CGColor)
                let frame = CGRect(origin: CGPointZero, size: image.size)
                CGContextClipToMask(context, frame, image.CGImage)
                CGContextFillRect(context, frame)
                CGContextEndTransparencyLayer(context)
                image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
        private(set) var image: UIImage
        init(image: UIImage) {
            self.image = image
        }
    }
}
