import UIKit

extension UIImage {
    func msr_averageColorWithAccuracy(accuracy: CGFloat) -> UIColor? {
        let size = CGSize(width: self.size.width * accuracy, height: self.size.height * accuracy)
        let c = _MSRDefaultRGBBitmapContextWithSize(size)
        CGContextDrawImage(c, CGRect(origin: CGPointZero, size: size), self.CGImage)
        let data = UnsafePointer<UInt8>(CGBitmapContextGetData(c))
        if data == nil {
            return nil
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        let width = CGBitmapContextGetWidth(c)
        let height = CGBitmapContextGetHeight(c)
        let count = width * height / 4
        for i in 0..<count {
            r += CGFloat(data.advancedBy(i * 4).memory)
            g += CGFloat(data.advancedBy(i * 4 + 1).memory)
            b += CGFloat(data.advancedBy(i * 4 + 2).memory)
            a += CGFloat(data.advancedBy(i * 4 + 3).memory)
        }
        return UIColor(red: r / (255 * CGFloat(count)), green: g / (255 * CGFloat(count)), blue: b / (255 * CGFloat(count)), alpha: a / (255 * CGFloat(count)))
    }
}
