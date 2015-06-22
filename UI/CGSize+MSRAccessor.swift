import CoreGraphics

extension CGSize {
    var msr_sizeByExchangingWidthAndHeight: CGSize {
        return CGSize(width: height, height: width)
    }
    func msr_sizeByApplyingScale(scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
}

prefix operator %~ {}

prefix func %~(x: CGSize) -> CGSize {
    return x.msr_sizeByExchangingWidthAndHeight
}

infix operator <*> {
    associativity left
    precedence 150
}

infix operator </> {
    associativity left
    precedence 150
}

func <*>(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return lhs.msr_sizeByApplyingScale(rhs)
}

func <*>(lhs: CGFloat, rhs: CGSize) -> CGSize {
    return rhs.msr_sizeByApplyingScale(lhs)
}

func </>(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return lhs.msr_sizeByApplyingScale(1 / rhs)
}

func </>(lhs: CGFloat, rhs: CGSize) -> CGSize {
    return rhs.msr_sizeByApplyingScale(1 / lhs)
}
