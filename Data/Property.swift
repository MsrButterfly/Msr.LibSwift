import UIKit

extension Msr.Data {
    class Property {
        let data: AnyObject
        init(module: NSString, bundle: NSBundle) {
            let path = bundle.pathForResource(module, ofType: "plist")
            data = NSDictionary(contentsOfFile: path)
        }
        init(data: AnyObject) {
            self.data = data
        }
        func asColor() -> UIColor {
            return UIColor(
                red: data["Red"] as CGFloat / 255,
                green: data["Green"] as CGFloat / 255,
                blue: data["Blue"] as CGFloat / 255,
                alpha: data["Alpha"] as CGFloat)
        }
        subscript(key: String) -> Property {
            get {
                return Property(data: data[key])
            }
        }
    }
}
