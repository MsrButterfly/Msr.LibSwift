import UIKit

extension Msr.Data {
    class Property: Printable, DebugPrintable {
        let value: AnyObject
        init(module: NSString, bundle: NSBundle) {
            let path = bundle.pathForResource(module, ofType: "plist")
            value = NSDictionary(contentsOfFile: path)
        }
        init(value: AnyObject) {
            self.value = value
        }
        func asColor() -> UIColor {
            return UIColor(
                red: value["Red"] as CGFloat / 255,
                green: value["Green"] as CGFloat / 255,
                blue: value["Blue"] as CGFloat / 255,
                alpha: value["Alpha"] as CGFloat)
        }
        func asString() -> String {
            return value as String
        }
        func asInt() -> Int {
            return value as Int
        }
        func asFloat() -> Float {
            return value as Float
        }
        func asData() -> NSData {
            return value as NSData
        }
        func asDate() -> NSDate {
            return value as NSDate
        }
        func asBool() -> Bool {
            return value as Bool
        }
        func asArray() -> [AnyObject] {
            return value as [AnyObject]
        }
        func asDictionary() -> [String: AnyObject] {
            return value as [String: AnyObject]
        }
        func asURL() -> NSURL {
            return NSURL(string: asString())
        }
        subscript(key: String) -> Property {
            get {
                return Property(value: value[key])
            }
        }
        var description: String {
            get {
                return value.description!
            }
        }
        var debugDescription: String {
            get {
                return value.debugDescription!
            }
        }
    }
}
