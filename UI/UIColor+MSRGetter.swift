import UIKit

extension UIColor {
    
    @objc var msr_hue: CGFloat {
        var hue: CGFloat = 0
        getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }
    
    @objc var msr_saturation: CGFloat {
        var saturation: CGFloat = 0
        getHue(nil, saturation: &saturation, brightness: nil, alpha: nil)
        return saturation
    }
    
    @objc var msr_brightness: CGFloat {
        var brightness: CGFloat = 0
        getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return brightness
    }
    
    @objc var msr_hsbAlpha: CGFloat {
        var alpha: CGFloat = 0
        getHue(nil, saturation: nil, brightness: nil, alpha: &alpha)
        return alpha
    }
    
    @objc var msr_red: CGFloat {
        var red: CGFloat = 0
        getRed(&red, green: nil, blue: nil, alpha: nil)
        return red
    }
    
    @objc var msr_green: CGFloat {
        var green: CGFloat = 0
        getRed(nil, green: &green, blue: nil, alpha: nil)
        return green
    }
    
    @objc var msr_blue: CGFloat {
        var blue: CGFloat = 0
        getRed(nil, green: nil, blue: &blue, alpha: nil)
        return blue
    }
    
    @objc var msr_rgbAlpha: CGFloat {
        var alpha: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }
    
}
