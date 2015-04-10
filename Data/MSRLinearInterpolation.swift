import CoreGraphics

func MSRLinearInterpolation(a: Float, b: Float, progress: Double) -> Float {
    return (b - a) * Float(progress) + a
}

func MSRLinearInterpolation(a: Double, b: Double, progress: Double) -> Double {
    return (b - a) * Double(progress) + a
}

func MSRLinearInterpolation(a: CGFloat, b: CGFloat, progress: Double) -> CGFloat {
    return (b - a) * CGFloat(progress) + a
}

func MSRLinearInterpolation(a: CGSize, b: CGSize, progress: Double) -> CGSize {
    return CGSize(
        width: MSRLinearInterpolation(a.width, b.width, progress),
        height: MSRLinearInterpolation(a.height, b.height, progress))
}

func MSRLinearInterpolation(a: CGVector, b: CGVector, progress: Double) -> CGVector {
    return CGVector(
        dx: MSRLinearInterpolation(a.dx, b.dx, progress),
        dy: MSRLinearInterpolation(a.dy, b.dy, progress))
}

func MSRLinearInterpolation(a: CGPoint, b: CGPoint, progress: Double) -> CGPoint {
    return CGPoint(
        x: MSRLinearInterpolation(a.x, b.x, progress),
        y: MSRLinearInterpolation(a.y, b.y, progress))
}

func MSRLinearInterpolation(a: CGRect, b: CGRect, progress: Double) -> CGRect {
    return CGRect(
        origin: MSRLinearInterpolation(a.origin, b.origin, progress),
        size: MSRLinearInterpolation(a.size, b.size, progress))
}
