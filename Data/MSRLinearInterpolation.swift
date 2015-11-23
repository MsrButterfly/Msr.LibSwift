import CoreGraphics

func MSRLinearInterpolation(a a: Float, b: Float, progress: Double) -> Float {
    return (b - a) * Float(progress) + a
}

func MSRLinearInterpolation(a a: Double, b: Double, progress: Double) -> Double {
    return (b - a) * Double(progress) + a
}

func MSRLinearInterpolation(a a: CGFloat, b: CGFloat, progress: Double) -> CGFloat {
    return (b - a) * CGFloat(progress) + a
}

func MSRLinearInterpolation(a a: CGSize, b: CGSize, progress: Double) -> CGSize {
    return CGSize(
        width: MSRLinearInterpolation(a: a.width, b: b.width, progress: progress),
        height: MSRLinearInterpolation(a: a.height, b: b.height, progress: progress))
}

func MSRLinearInterpolation(a a: CGVector, b: CGVector, progress: Double) -> CGVector {
    return CGVector(
        dx: MSRLinearInterpolation(a: a.dx, b: b.dx, progress: progress),
        dy: MSRLinearInterpolation(a: a.dy, b: b.dy, progress: progress))
}

func MSRLinearInterpolation(a a: CGPoint, b: CGPoint, progress: Double) -> CGPoint {
    return CGPoint(
        x: MSRLinearInterpolation(a: a.x, b: b.x, progress: progress),
        y: MSRLinearInterpolation(a: a.y, b: b.y, progress: progress))
}

func MSRLinearInterpolation(a a: CGRect, b: CGRect, progress: Double) -> CGRect {
    return CGRect(
        origin: MSRLinearInterpolation(a: a.origin, b: b.origin, progress: progress),
        size: MSRLinearInterpolation(a: a.size, b: b.size, progress: progress))
}
