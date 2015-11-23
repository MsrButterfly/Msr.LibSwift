import CoreGraphics

func _MSRDefaultRGBBitmapContextWithSize(size: CGSize) -> CGContext {
    return CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, CGColorSpaceCreateDeviceRGB(), CGImageAlphaInfo.PremultipliedLast.rawValue)!
}
