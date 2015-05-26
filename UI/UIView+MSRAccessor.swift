import UIKit

@IBDesignable extension UIView {
    
    @IBInspectable @objc var msr_borderColor: UIColor {
        set {
            layer.borderColor = newValue.CGColor
        }
        get {
            return UIColor(CGColor: layer.borderColor)!
        }
    }
    
    @IBInspectable @objc var msr_borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable @objc var msr_cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable @objc var msr_masksToBounds: Bool {
        set {
            layer.masksToBounds = newValue
        }
        get {
            return layer.masksToBounds
        }
    }
    
    @IBInspectable @objc var msr_shadowColor: UIColor {
        set {
            layer.shadowColor = newValue.CGColor
        }
        get {
            return UIColor(CGColor: layer.shadowColor)!
        }
    }
    
    @IBInspectable @objc var msr_shadowOpacity: CGFloat {
        set {
            let v = Float(newValue)
            layer.shadowOpacity = v < 0 ? 0 : v > 1 ? 1 : v
        }
        get {
            return CGFloat(layer.shadowOpacity)
        }
    }
    
    @IBInspectable @objc var msr_shadowOffset: CGPoint {
        set {
            let v = newValue
            layer.shadowOffset = CGSize(width: v.x, height: v.y)
        }
        get {
            let o = layer.shadowOffset
            return CGPoint(x: o.width, y: o.height)
        }
    }
    
    @IBInspectable @objc var msr_shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    
    @IBInspectable @objc var msr_shadowPath: UIBezierPath {
        set {
            layer.shadowPath = newValue.CGPath
        }
        get {
            return UIBezierPath(CGPath: layer.shadowPath)
        }
    }
    
}
